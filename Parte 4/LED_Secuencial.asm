;
; LED_Secuencial.asm
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
.equ LED2 = B4
.equ LED3 = B3
.equ LED4 = B2
.equ S1 = B1

.def Read = r19

.def OutRegister = r20
.def Contador1 = r23
.def Contador2 = r22
.def Contador3 = r21

ldi OutRegister, (LED1 + LED2 + LED3 + LED4)
out DDRB, OutRegister

ldi Read, (S1^S1) // Pulsador S1 como entrada
out DDRC, Read

///////////////////////////////////////////////////
/////////////// Sentido Normal ////////////////////
///////////////////////////////////////////////////
start1:
	ldi OutRegister, (~LED1)
    out PORTB, OutRegister
    rcall delay_500ms

	in Read, PINC // Leo Puerto C (la entrada)
	andi Read, S1
	cpi Read, 2
	breq op1

start2:
	ldi OutRegister, (~LED2)
    out PORTB, OutRegister
    rcall delay_500ms

	in Read, PINC // Leo Puerto C (la entrada)
	andi Read, S1
	cpi Read, 2
	breq op4

start3:
	ldi OutRegister, (~LED3)
    out PORTB, OutRegister
    rcall delay_500ms

	in Read, PINC // Leo Puerto C (la entrada)
	andi Read, S1
	cpi Read, 2
	breq op3

start4:
	ldi OutRegister, (~LED4)
    out PORTB, OutRegister
    rcall delay_500ms

	in Read, PINC // Leo Puerto C (la entrada)
	andi Read, S1
	cpi Read, 2
	breq op2

    rjmp start1
		
///////////////////////////////////////////////////
/////////////// Sentido Opuesto ///////////////////
///////////////////////////////////////////////////

op1:
	ldi OutRegister, (~LED4)
    out PORTB, OutRegister
    rcall delay_500ms

	in Read, PINC // Leo Puerto C (la entrada)
	andi Read, S1
	cpi Read, 2
	breq start1

op2:
	ldi OutRegister, (~LED3)
    out PORTB, OutRegister
    rcall delay_500ms

	in Read, PINC // Leo Puerto C (la entrada)
	andi Read, S1
	cpi Read, 2
	breq start4

op3:
	ldi OutRegister, (~LED2)
    out PORTB, OutRegister
    rcall delay_500ms

	in Read, PINC // Leo Puerto C (la entrada)
	andi Read, S1
	cpi Read, 2
	breq start3

op4:
	ldi OutRegister, (~LED1)
    out PORTB, OutRegister
    rcall delay_500ms

	in Read, PINC // Leo Puerto C (la entrada)
	andi Read, S1
	cpi Read, 2
	breq start2

	rjmp op1
    
////////////////////////////////////////////
/////////////// subrutinas //////////////////
////////////////////////////////////////////

// ***************************************
// delay_500ms
// Esta función hace un delay de 500ms.
// Sin argumento de entrada.
// ***************************************
delay_500ms:
	push Contador1
	push Contador2
	push Contador3
	
	ldi Contador1, 255	// 1 clk
	ldi Contador2, 255	// 1 clk
	ldi Contador3, 41	// 1 clk
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
			// Se hace 41 veces el loop de 5 clks y repite 41 veces el ciclo anterior de 196.095 clks
			//El ciclo demora 8.040.100 clks = 0,5025 s
	
	pop Contador3
	pop Contador2
	pop Contador1
	ret 
