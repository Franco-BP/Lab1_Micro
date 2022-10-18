;
; Send_digit.asm
;

.equ B0 = (1<<0)
.equ B1 = (1<<1)
.equ B2 = (1<<2)
.equ B3 = (1<<3)
.equ B4 = (1<<4)
.equ B5 = (1<<5)
.equ B6 = (1<<6) 
.equ B7 = (1<<7) 
.equ SHIFT_CLOCK = B1
.equ LATCH_CLOCK = B4

.def ValueIn = r16
.def DigitIn = r17

.def PortOut = r20
.def ADCRegister = r21

.def TimesCounter = r18
.def SerialData = r19		// SDI = B0 // Serial Ck = B1 // Latch Ck = B4

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
	mov r16, r17
	rcall send_byte

	ldi PortOut, LATCH_CLOCK
	out PORTD, PortOut
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
		clr SerialData

		ror ValueIn
		adc SerialData, ADCRegister

		out PORTD, SerialData

		ldi PortOut, SHIFT_CLOCK
		OR PortOut, SerialData
		out PORTD, PortOut
		nop		//Delay necesario para evitar fallos con la carga del dato
		nop
		out PORTD, SerialData //(SHIFT_CLOCK xor SHIFT_CLOCK))

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
