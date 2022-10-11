;
; Micro.asm
;
; Created: 8/31/2022 12:06:32 PM
; Author : pijua
;


; Replace with your application code
.org 0
			jmp start //salta al jump

.equ B0 = (1<<0)
.equ B1 = (1<<1)
.equ B2 = (1<<2)
.equ B3 = (1<<3)
.equ B4 = (1<<4)
.equ B5 = (1<<5)
.equ B6 = (1<<6) 
.equ B7 = (1<<7) 

start:
    ldi r20,B5
	out PORTD, r20

loop_LED_1s:
	rcall delay_1s
	rcall apagar_LED
	rcall delay_1s
	rcall prender_LED

	rjmp loop_LED_1s


prender_LED:
	ldi r20, B5
	out PORTB, r20
	ret


apagar_LED:
	ldi r20, 0
	out PORTB, r20
	ret


delay_1s:
	ldi r23,255	// 1 clk
	ldi r22,255	// 1 clk
	ldi r21,41	// 1 clk
	// Estos 3 clks se agregan al final de la cuenta, porque no estan loopeados

	loop1:
	dec r23		// 1 clk
	cpi r23,0	// 1 clk
	
	brne loop1	// 1/2 clk
	// Se hace 255 veces el loop de 3 clks

		dec r22		// 1 clk
		ldi r23,255	// 1 clk

		cpi r22,0	// 1clk
		brne loop1	// 1/2 clk
		// Se hace 255 veces el loop de 4 clks y repite 255 veces el ciclo anterior
		// 196.095 clks

			dec r21		// 1 clk
			ldi r23,255	// 1 clk
			ldi r22,255	// 1 clk

			cpi r21,0	// 1 clk
			brne loop1	// 1/2 clk
			// Se hace 41 veces el loop de 5 clks y repite 41 veces el ciclo anterior de 196.095 clks
	//El ciclo demora 8.040.100 clks = 0,5025 s
	ret 













