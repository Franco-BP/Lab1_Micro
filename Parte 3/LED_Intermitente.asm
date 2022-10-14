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
.def ContadorIn = r24

ldi OutRegister, LED1
out DDRB, OutRegister

start:
	ldi OutRegister, (LED1^LED1)
	out PORTB, OutRegister
	
	ldi ContadorIn, 1
	rcall delay_500ms
    
	ldi OutRegister, LED1
	out PORTB, OutRegister
	
	ldi ContadorIn, 1
	rcall delay_500ms
    
    rjmp start
    

// ***************************************
// delay_ms
// Esta función hace un delay de 500ms, repitiéndose una cantidad de veces dada por el ingreso.
// Argumento de entrada en ContadorIn (r24). Valores Válidos (1:255)
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

			ldi Contador1, 255	// 1 clk
			ldi Contador2, 197	// 1 clk
			dec ContadorIn		// 1 clk - Settea el flag Z si es 0

			brne loop1	// 2 clk (-1 al final)
			// Se hace 41 veces el loop de 5 clks y repite 41 veces el ciclo anterior de 196.095 clks
			//El ciclo demora 8.040.100 clks = 0,5025 s

	pop Contador2
	pop Contador1
	ret 
