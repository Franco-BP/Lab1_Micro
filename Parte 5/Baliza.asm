;
; Baliza.asm
;

.org 0

.equ B0 = (1<<0)
.equ B1 = (1<<1)
.equ B2 = (1<<2)
.equ B3 = (1<<3)
.equ B4 = (1<<4)
.equ B5 = (1<<5)
.equ B6 = (1<<6) 
.equ B7 = (1<<7) 

.equ LED1 = B5
.equ S1 = B1

.def Read = r19

.def OutRegister = r20
.def Contador1 = r23
.def Contador2 = r22
.def ContadorIn = r24

ldi OutRegister, (LED1)
out DDRB, OutRegister

ldi Read, (S1^S1) // Pulsador S1 como entrada
out DDRC, Read

//////////////////////////////////////////////
/////////////// Programa ////////////////////
/////////////////////////////////////////////

encendido:
	ldi OutRegister, (~LED1)
	out PORTB, OutRegister
	rcall delay_1s

	in Read, PINC
	andi Read, S1
	cpi Read, 0		//El input en 0 (LOW) es cuando se apreta el botón
	breq apagar

	ldi OutRegister, 0xFF
	out PORTB, OutRegister
	rcall delay_1s

	in Read, PINC 
	andi Read, S1
	cpi Read, 0
	breq apagar

	rjmp encendido

apagado:
	in Read, PINC 
	andi Read, S1
	cpi Read, 0
	breq encender

	nop		//Para saturar menos la cpu colocamos dos nop
	nop
	rjmp apagado


/////////////////////////////////////////////////
/////////////// Trancisiones ////////////////////
/////////////////////////////////////////////////
apagar:
	ldi OutRegister, 0xFF
    out PORTB, OutRegister
	apagarloop:
		in Read, PINC 
		andi Read, S1
		cpi Read, 2		//El input en 2 (HIGH) es cuando se suelta el botón
		breq apagado
		nop
		nop
		rjmp apagarloop

encender:
	ldi OutRegister, (~LED1)
 	out PORTB, OutRegister
	encenderloop:
		in Read, PINC 
		andi Read, S1
		cpi Read, 2		//El input en 2 (HIGH) es cuando se suelta el botón
		breq encendido
		nop
		nop
		rjmp encenderloop



////////////////////////////////////////////
/////////////// subrutinas //////////////////
////////////////////////////////////////////

// ***************************************
// delay_ms
// Esta función hace un delay de 1s.
// ***************************************
delay_1s:
	push Contador1
	push Contador2
	push ContadorIn
	
	ldi ContadorIn, 2
	ldi Contador1, 255	// 1 clk
	ldi Contador2, 197	// 1 clk

	loop1:
	dec Contador1		// 1 clk - Settea el flag Z si es 0
	
	brne loop1	// 2 clk (-1 al final)

		ldi Contador1, 255	// 1 clk
		dec Contador2		// 1 clk - Settea el flag Z si es 0

		brne loop1	// 2 clk (-1 al final)

			ldi Contador1, 255	// 1 clk
			ldi Contador2, 197	// 1 clk
			dec ContadorIn		// 1 clk - Settea el flag Z si es 0

			brne loop1	// 2 clk (-1 al final)

	pop ContadorIn
	pop Contador2
	pop Contador1
	ret 
