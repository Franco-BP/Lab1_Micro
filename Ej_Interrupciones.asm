;
; PinChange_interrupt.asm
;
; Created: 10/17/2022 12:21:09 PM
; Author : jacoby


.equ	B0 = (1<<0)
.equ	B1 = (1<<1)
.equ	B2 = (1<<2)
.equ	B3 = (1<<3)
.equ	B4 = (1<<4)
.equ	B5 = (1<<5)
.equ	B6 = (1<<6)
.equ	B7 = (1<<7)


.equ	SW1 = B1

		.org	0
		jmp		start			;Reset Vector  (note jmp 2 words rjmp 1 word)
		.org	PCI1addr
		jmp		PCI1_IRQSRV		;PCI1 (ISR for Por C) Vector

; Replace with your application code
start:
        ldi r23,B5
  
        out DDRB, r23
        out PORTB, r23





//  Interrupt Source:Button S1-A1 on xplained board
//  Button S1-A1 is on pin PC1 => Port C
//  PCICR (Pin Change Interrupt Control Register) defines which port is the source of interrupt
//  I has 3 bits PCIE<2-0>  PCIE2 for PORTD , PCIE1 for PORTC and PCIE0 for PORTB
//  In our case (PORTC) we use PCIE1.
//  After that we must enable which pin of PORTC will be the interrupt source
//  For PORTC we use PCMSK1  (Pin Change Mask Register 1) 
//  Each bit on PCMSK1 enable a PORT C pin as interrupt source in our case the 
//  interrupt Mask for pin PC1 is PCINT9)

 
// 1-Enable Interrupts from Port C => PCICR=(1<<PCIE1)
	ldi	r20,(1<<PCIE1)
	sts	PCICR,r20
// 2-Enable specific pin interrupt on PSMSK1 (Port C pin Change mask register)
//   PCMSK1= (1<< PCINT9)
	ldi	r20,(1<<PCINT9)
	sts	PCMSK1,r20

	sei			//Enable processor interrupts


lp1: jmp lp1	//endless loop



//Interrupt service routine (ISR) for pin PC1

PCI1_IRQSRV:
				in r16,SREG			//Save processor status register
				push r16

				in  r23,PINC		// Check for rising edge
				andi r23,SW1
				brne	endisr		// Rising edge


toggle:			in r24,PORTB		//Toggle led on Falling edge
				ldi r23,B5
				eor r24,r23
				out PORTB, r24		//PORTB->PORTB xor B5

endisr:			pop r16
				out SREG,r16
				
				reti



				
