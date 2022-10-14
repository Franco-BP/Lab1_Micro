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
	rcall delay_ms

	in Read, PINC // Leo Puerto C (la entrada)
	andi Read, S1
	cpi Read, 2
	breq op1

start2:
	ldi OutRegister, (~LED2)
	out PORTB, OutRegister
	rcall delay_ms

	in Read, PINC // Leo Puerto C (la entrada)
	andi Read, S1
	cpi Read, 2
	breq op4

start3:
	ldi OutRegister, (~LED3)
	out PORTB, OutRegister
	rcall delay_ms

	in Read, PINC // Leo Puerto C (la entrada)
	andi Read, S1
	cpi Read, 2
	breq op3

start4:
	ldi OutRegister, (~LED4)
	out PORTB, OutRegister
	rcall delay_ms

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
	rcall delay_ms

	in Read, PINC // Leo Puerto C (la entrada)
	andi Read, S1
	cpi Read, 2
	breq start1

op2:
	ldi OutRegister, (~LED3)
	out PORTB, OutRegister
	rcall delay_ms

	in Read, PINC // Leo Puerto C (la entrada)
	andi Read, S1
	cpi Read, 2
	breq start4

op3:
	ldi OutRegister, (~LED2)
	out PORTB, OutRegister
	rcall delay_ms

	in Read, PINC // Leo Puerto C (la entrada)
	andi Read, S1
	cpi Read, 2
	breq start3

op4:
	ldi OutRegister, (~LED1)
	out PORTB, OutRegister
	rcall delay_ms

	in Read, PINC // Leo Puerto C (la entrada)
	andi Read, S1
	cpi Read, 2
	breq start2

	rjmp op1
    
////////////////////////////////////////////
/////////////// subrutinas //////////////////
////////////////////////////////////////////

// ***************************************
// delay_ms
// Esta función hace un delay de 500ms.
// ***************************************
delay_ms:
	push Contador1
	push Contador2
	
	ldi Contador1, 255	// 1 clk
	ldi Contador2, 197	// 1 clk
	// Estos 3 clks se agregan al final de la cuenta, porque no estan loopeados

	loop1:
	dec Contador1		// 1 clk - Settea el flag Z si es 0
	
	brne loop1	// 1/2 clk
	// Se hace 255 veces el loop de 3 clks

		ldi Contador1, 255	// 1 clk
		dec Contador2		// 1 clk - Settea el flag Z si es 0

		brne loop1	// 2 clk (-1 al final)
		// Se hace 21 veces el loop de 4 clks y repite 21 veces el ciclo anterior
		// 16.150 clks = (aprox) 1,009ms

	pop Contador2
	pop Contador1
	ret 
