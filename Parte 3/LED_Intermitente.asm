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

.def Contador1 = r23
.def Contador2 = r22
.def Contador3 = r21

out DDRB LED1

start:
    out PORTB (LED1 XOR LED1)
    rcall delay_500ms
    
    out PORTB LED1
    rcall delay_500ms
    
    rjmp start
    

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
