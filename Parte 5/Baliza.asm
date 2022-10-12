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
.def Contador3 = r21

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
// delay_1s
// Esta función hace un delay de 1s.
// Sin argumento de entrada.
// ***************************************
delay_1s:
	push Contador1
	push Contador2
	push Contador3
	
	ldi Contador1, 255	// 1 clk
	ldi Contador2, 255	// 1 clk
	ldi Contador3, 82	// 1 clk
	// Estos 3 clks se agregan al final de la cuenta, porque no estan loopeados

	loop1:
	dec Contador1		// 1 clk
	cpi Contador1, 0	// 1 clk
	
	brne loop1	// 1/2 clk
	// Se hace 255 veces el loop de 3 clks

		dec Contador2		// 1 clk
		ldi Contador1, 255	// 1 clk

		cpi Contador2, 0	// 1clk
		brne loop1	// 1/2 clk
		// Se hace 255 veces el loop de 4 clks y repite 255 veces el ciclo anterior
		// 196.095 clks

			dec Contador3		// 1 clk
			ldi Contador1, 255	// 1 clk
			ldi Contador2, 255	// 1 clk

			cpi Contador3, 0	// 1 clk
			brne loop1	// 1/2 clk
			// Se hace 82 veces el loop de 5 clks y repite 82 veces el ciclo anterior de 196.095 clks
			//El delay demora 16.080.200clks = 1,05s (aprox)
	
	pop Contador3
	pop Contador2
	pop Contador1
	ret 
