;
; AssemblerApplication2.asm
;
; Created: 10/10/2022 9:57:41
; Author : Franco
;

//*************************************************
// SendByte
// Esta función toma un byte de ingreso y lo envía al 74HC595
// Argumento de entrada r15.
//*************************************************
.def ByteSent = r15
.def TimesCounter = r16
.def WriteBit = r17		// SDI = B0 // Serial Ck = B1 // Latch Ck = B4
.equ Shift_Clock = B1

SendByte:
	push TimesCounter
	push WriteBit

	ldi TimesCounter, 8
	
	loadLoop:
		clr WriteBit

		ror ByteSent
		adc WriteBit, 0

		out PORTD, WriteBit
		out PORTD, (WriteBit + Shift_Clock)
		nop		//Delay necesario para evitar fallos con la carga del dato
		nop
		out PORTD, (WriteBit + (Shift_Clock XOR Shift_Clock))

		dec TimesCounter
		cpi TimesCounter, 0
		brne loadLoop		//Finaliza el Loop luego de cargar el último bit (8 veces)
	
	pop WriteBit
	pop TimesCounter
	ret