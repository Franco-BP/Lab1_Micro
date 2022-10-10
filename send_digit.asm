;
; Send_digit.asm
;

.def ValueIn = r16
.def DigitIn = r17

.def TimesCounter = r17
.def SerialData = r18		// SDI = B0 // Serial Ck = B1 // Latch Ck = B4
.equ Shift_Clock = B1
.equ Latch_Clock = B4


//*********************************************
//	send_digit
//	Recibe un valor y el d�gito y lo muestra en el display.
//	Argumentos de entrada: valor (0:9) en r16 / d�gito (1-4) en r17.
//*********************************************
send_digit:
	cpi ValueIn, 10	//Control para evitar ingresos mayores a 9
	brge end
	cpi (DigitIn - 1), 4
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
//	Toma un valor de ingreso y lo convierte a su valor en el display de ss.
//	Argumento de ingreso y retorno en r16. Valores v�lidos (0:9)
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
//	Argumento de entrada y retorno en r17. Valores v�lidos (1:4)
//**********************************************************
digit_to_display:
	ldi ZL, LOW(2*display_digit_value)
	ldi ZH, HIGH(2*display_digit_value)

	dec DigitIn
	add ZL, DigitIn
	adc ZH, 0
	lpm DigitIn, Z
	ret
	

//*************************************************
// send_byte
// Esta funci�n toma un byte de ingreso y lo env�a al 74HC595
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
		brne loadLoop		//Finaliza el Loop luego de cargar el �ltimo bit (8 veces)
	
	pop SerialData
	pop TimesCounter
	ret


ss_value:		//C�digo en hexa correspondiente al display de cada n�mero (0:9)
	.db 0x03, 0x9F, 0x25, 0x0D, 0x99, 0x49, 0x41, 0x1F, 0x01, 0x19

display_digit_value:	//C�digo en hexa correspondiente al d�gito (1:4)
	.db 0x80, 0x40, 0x20, 0x10
