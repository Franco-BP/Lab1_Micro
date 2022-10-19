;
; Contador_Display.asm
;

.equ B0 = (1<<0)
.equ B1 = (1<<1)
.equ B2 = (1<<2)
.equ B3 = (1<<3)
.equ B4 = (1<<4)
.equ B5 = (1<<5)
.equ B6 = (1<<6) 
.equ B7 = (1<<7) 

.equ SHIFT_CLOCK = B7	// PORT D
.equ LATCH_CLOCK = B4	// PORT D
.equ SERIAL_DATA = B0	//PORT B


.def PortOut = r20
.def ValueIn = r16
.def DigitIn = r17

.def TimesCounter = r19
.def SerialData = r18

.def Contador1 = r25	//En delay tiene push, no interfiere con el programa
.def Contador2 = r22	//No interfiere con otros .def
.def ADCRegister = r21	//No interfiere con otros .def

.def Unidad = r21
.def Decena = r22
.def Centena = r23
.def UMil = r24

	.org 0
	jmp start

start:
ldi PortOut, (SHIFT_CLOCK | LATCH_CLOCK | SERIAL_DATA)
out DDRD, PortOut

ldi PortOut, SERIAL_DATA
out DDRB, PortOut

ldi Contador1, 0
ldi Unidad, 0
ldi Decena, 0
ldi Centena, 0
ldi UMil, 0

loop:
	mov ValueIn, UMil
	ldi DigitIn, 1
	call send_digit
	// Necesitamos un delay de 2ms
	call delay_ms

	mov ValueIn, Centena
	ldi DigitIn, 2
	call send_digit
	// Necesitamos un delay de 2ms
	call delay_ms

	mov ValueIn, Decena
	ldi DigitIn, 3
	call send_digit
	//Necesitamos un delay de 2 ms
	call delay_ms
	
	mov ValueIn, Unidad
	ldi DigitIn, 4
	call send_digit
	// Necesitamos un delay de 2ms
	call delay_ms

	inc Contador1
	cpi Contador1, 62
	brlt loop_end

	rcall increase_counter
	ldi Contador1, 0

loop_end:
	rjmp loop

//*********************************************
//	increase_counter
//	Incrementa un contador ingresado en unidad, decena, centena y unidad de mil.
//	Argumentos de entrada crecientes: r21, r22, r23, r24.
//*********************************************

increase_counter:
	inc Unidad
	cpi Unidad, 10
	brge carry_unidad
	ret

carry_unidad:
	ldi Unidad, 0
	inc Decena

	cpi Decena, 10
	brge carry_decena
	ret

carry_decena:
	ldi Decena, 0
	inc Centena

	cpi Centena, 10
	brge carry_centena
	ret

carry_centena:
	ldi Centena, 0
	inc UMil

	cpi UMil, 10
	brge clear_counter
	ret


clear_counter:
	ldi Unidad, 0
	ldi Decena, 0
	ldi Centena, 0
	ldi UMil, 0
	ret


//*********************************************
//	send_digit
//	Recibe un valor y el dígito y lo muestra en el display. Valor 10 para limpiar el dígito.
//	Argumentos de entrada: valor (0:9 o 10) en r16 / dígito (1-4) en r17.
//*********************************************
send_digit:
	cpi ValueIn, 11	//Control para evitar ingresos mayores a 10
	brge end
	dec DigitIn	//Tanto para la lista (.db) como para el control, nos sirve que Digit sea de 0 -> 3
	cpi DigitIn, 4
	brge end

	rcall value_to_ss	//ingreso y retorno en r16 
	rcall send_byte		//ingreso en r16

	rcall digit_to_display	//ingreso y retorno en r17
	mov r16, DigitIn
	rcall send_byte

	ldi PortOut, LATCH_CLOCK
	out PORTD, PortOut
	nop
	nop
	ldi PortOut, 0
	out PORTD, PortOut

	end:
		ret



//**********************************************************
//	value_to_ss
//	Toma un valor de ingreso y lo convierte a su valor en el display de ss. 10 para limpiar.
//	Argumento de ingreso y retorno en r16. Valores válidos (0:9)
//**********************************************************
value_to_ss:
	push ADCRegister
	ldi ADCRegister, 0
  
	ldi ZL, LOW(2*ss_value)
	ldi ZH, HIGH(2*ss_value)

	add ZL, ValueIn	//Agregamos el valor ingresado, para que Z apunte al valor correspondiente de la lista
	adc ZH, ADCRegister
	
	lpm ValueIn, Z
  
	pop ADCRegister
	ret

//**********************************************************
//	digit_to_display:
//	Toma un digito de ingreso y lo convierte a su valor en el display.
//	Argumento de entrada y retorno en r17. Valores válidos (0:3)
//**********************************************************
digit_to_display:
  push ADCRegister
  ldi ADCRegister, 0

	ldi ZL, LOW(2*display_digit_value)
	ldi ZH, HIGH(2*display_digit_value)

	add ZL, DigitIn
	adc ZH, ADCRegister
	lpm DigitIn, Z
  
  pop ADCRegister
	ret
	

//*************************************************
// send_byte
// Esta función toma un byte de ingreso y lo envía al 74HC595
// Argumento de entrada r16.
//*************************************************

send_byte:
	push TimesCounter
	push SerialData
	push PortOut
	push ADCRegister

	ldi TimesCounter, 8
	ldi ADCRegister, 0
	
	loadLoop:
		ldi SerialData, 0

		ror ValueIn
		adc SerialData, ADCRegister

		out PORTB, SerialData

		ldi PortOut, SHIFT_CLOCK
		out PORTD, PortOut
		nop		//Delay necesario para evitar fallos con la carga del dato
		nop
		ldi PortOut, 0	//(SHIFT_CLOCK xor SHIFT_CLOCK))
		out PORTD, PortOut

		dec TimesCounter
		cpi TimesCounter, 0
		brne loadLoop		//Finaliza el Loop luego de cargar el último bit (8 veces)
	
  pop ADCRegister
  pop PortOut
	pop SerialData
	pop TimesCounter
	ret


//Código en hexa correspondiente al display de cada número (0:9 o 10 para borrar)
ss_value:
	.db 0x03, 0x9F, 0x25, 0x0D, 0x99, 0x49, 0x41, 0x1F, 0x01, 0x19, 0xFF, 0x00	//Se agrega 0x00 para evitar padding

//Código en hexa correspondiente al dígito (1:4)
display_digit_value:
	.db 0x80, 0x40, 0x20, 0x10


// ***************************************
// delay_ms
// Esta función hace un delay de 2ms.
// ***************************************
delay_ms:
	push Contador1
	push Contador2
	
	ldi Contador1, 255	// 1 clk
	ldi Contador2, 40	// 1 clk
	
	loop1:
	dec Contador1		// 1 clk - Settea el flag Z si es 0
	
	brne loop1	// 1/2 clk

		ldi Contador1, 255	// 1 clk
		dec Contador2		// 1 clk - Settea el flag Z si es 0

		brne loop1	// 2 clk (-1 al final)

	pop Contador2
	pop Contador1
	ret
