;
; Baliza.asm
;

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
.def Contador3 = r24

.def ChangeState = r25
.def Invert = r23

		.org	0
		jmp		start			;Reset Vector  (note jmp 2 words rjmp 1 word)
		.org	PCI1addr
		jmp		PCI1_IRQSRV		;PCI1 (ISR for Por C) Vector
		
start:
	ldi OutRegister, (LED1)
	out DDRB, OutRegister

	ldi Read, (S1^S1) // Pulsador S1 como entrada
	out DDRC, Read
	
	ldi ChangeState, 0

	// 1-Enable Interrupts from Port C => PCICR=(1<<PCIE1)
	ldi	r20,(1<<PCIE1)
	sts	PCICR,r20

	// 2-Enable specific pin interrupt on PSMSK1 (Port C pin Change mask register)
	//   PCMSK1= (1<< PCINT9)
	ldi	r20,(1<<PCINT9)
	sts	PCMSK1,r20

	sei			//Enable processor interrupts


//////////////////////////////////////////////
/////////////// Programa ////////////////////
/////////////////////////////////////////////

apagado:
	ldi OutRegister, 0xFF
	out PORTB, OutRegister
apagadoloop:
	nop		//Para saturar menos la cpu colocamos dos nop
	nop
	rjmp apagadoloop

encendido:
	ldi OutRegister, (~LED1)
	out PORTB, OutRegister
	rcall delay_1s

	ldi OutRegister, 0xFF
	out PORTB, OutRegister
	rcall delay_1s

	rjmp encendido


////////////////////////////////////////////
//////////// Interrupciones ////////////////
////////////////////////////////////////////

PCI1_IRQSRV:
	in Read, SREG
	push Read
	push r17
	push Invert

	in  r17, PINC		// Check for rising edge
	andi r17, S1
	breq	endisr		// Rising edge


toggle:	
	ldi ZL, LOW(2*transiciones)
	ldi ZH, HIGH(2*transiciones)

	ldi Invert, 1
	eor ChangeState, Invert
//Se necesita un registro para el ADC y se reutiliza el registro para evitar sobrecargar los push, pop
	ldi Invert, 0

	add ChangeState, ChangeState	//Se incrementa a 2 o se mantiene en 0 para cambiar el puntero
	add ZL, ChangeState
	adc ZH, Invert

endisr:
	pop Invert
	pop r17
	pop Read
	out SREG, Read

	ijmp



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
	push Contador3
	
	ldi Contador1, 255	// 1 clk
	ldi Contador2, 255	// 1 clk
	ldi Contador3, 82

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


transiciones:
	.dw	apagado, encendido
					
