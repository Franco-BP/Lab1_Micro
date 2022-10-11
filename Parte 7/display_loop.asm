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

.equ Shift_Clock = B1	// SDI = B0 // Serial Ck = B1 // Latch Ck = B4
.equ Latch_Clock = B4

.def ValueIn = r16
.def DigitIn = r17

.def TimesCounter = r17
.def SerialData = r18		

loop:
	ldi ValueIn, 1
	ldi DigitIn, 3
	rcall send_digit
	// Necesitamos un delay de 2ms
	rcall delay
	ldi ValueIn, 2
	ldi DigitIn, 4

	//Necesitamos un delay de 2 segundos, para visualizar el cambio
	rcall delay

	ldi ValueIn, 10
	ldi DigitIn, 3
	rcall send_digit
	//Necesitamos un delay de 2 ms
	rcall delay
	inc DigitIn
	rcall send_digit

	//Necesitamos un delay de 2 segundos, para visualizar el cambio
	rcall delay
	rjmp loop



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

	out PORTD, Latch_Clock

	end:
		ret



//**********************************************************
//	value_to_ss
//	Toma un valor de ingreso y lo convierte a su valor en el display de ss. 10 para limpiar.
//	Argumento de ingreso y retorno en r16. Valores válidos (0:9)
//**********************************************************
value_to_ss:
	ldi ZL, LOW(2*ss_value)
	ldi ZH, HIGH(2*ss_value)

	add ZL, ValueIn	//Agregamos el valor ingresado, para que Z apunte al valor correspondiente de la lista
	adc ZH, 0
	
	lpm ValueIn, Z
	ret

//**********************************************************
//	digit_to_display:
//	Toma un digito de ingreso y lo convierte a su valor en el display.
//	Argumento de entrada y retorno en r17. Valores válidos (0:3)
//**********************************************************
digit_to_display:
	ldi ZL, LOW(2*display_digit_value)
	ldi ZH, HIGH(2*display_digit_value)

	add ZL, DigitIn
	adc ZH, 0
	lpm DigitIn, Z
	ret
	

//*************************************************
// send_byte
// Esta función toma un byte de ingreso y lo envía al 74HC595
// Argumento de entrada r16.
//*************************************************

send_byte:
	push TimesCounter
	push SerialData

	ldi TimesCounter, 8
	
	loadLoop:
		clr SerialData

		ror ValueIn
		adc SerialData, 0

		out PORTD, SerialData
		out PORTD, (SerialData + Shift_Clock)
		nop		//Delay necesario para evitar fallos con la carga del dato
		nop
		out PORTD, (SerialData + (Shift_Clock XOR Shift_Clock))

		dec TimesCounter
		cpi TimesCounter, 0
		brne loadLoop		//Finaliza el Loop luego de cargar el último bit (8 veces)
	
	pop SerialData
	pop TimesCounter
	ret


ss_value:		//Código en hexa correspondiente al display de cada número (0:9 o 10 para borrar)
	.db 0x03, 0x9F, 0x25, 0x0D, 0x99, 0x49, 0x41, 0x1F, 0x01, 0x19, 0xFF

display_digit_value:	//Código en hexa correspondiente al dígito (1:4)
	.db 0x80, 0x40, 0x20, 0x10
