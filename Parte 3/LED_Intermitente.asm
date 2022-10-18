;
; LED_Intermitente.asm
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

.def OutRegister = r20
.def Contador1 = r23
.def Contador2 = r22
.def Contador3 = r21

ldi OutRegister, LED1
out DDRB, OutRegister

start:
	ldi OutRegister, (LED1^LED1)
	out PORTB, OutRegister
	rcall delay_ms
    
	ldi OutRegister, LED1
	out PORTB, OutRegister
	rcall delay_ms
    
    rjmp start
    

// ***************************************
// delay_ms
// Esta función hace un delay de 500ms.
// ***************************************
delay_ms:
	push Contador1
	push Contador2
	push Contador3
	
	ldi Contador1, 255	// 1 clk
	ldi Contador2, 255	// 1 clk
	ldi Contador3, 41

	loop1:
	dec Contador1		// 1 clk - Settea el flag Z si es 0
	
	brne loop1	// 2 clk (-1 al final)

		ldi Contador1, 255	// 1 clk
		dec Contador2		// 1 clk - Settea el flag Z si es 0

		brne loop1	// 2 clk (-1 al final)
			
			ldi Contador1, 255
			ldi Contador2, 255
			dec Contador3

			brne loop1

	pop Contador3
	pop Contador2
	pop Contador1
	ret 
