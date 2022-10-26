;
; Arrays.asm
;
; Created: 10/10/2022 3:52:19 PM
; Author : jacoby
;
;How to use 1-D arrays   
;Summary:
;EX1,EX2:This example initializes an array with values stored in progran memory 
;	     It copies data from program memory to an array in data memory (RAM)
;		 The array resides in procesor internal RAM
;
;EX3:Transfers data from a temporary area in RAM to an array in RAM area
;
; To DO transfer data from array to temorary area same element as EX3. (clear temp area first to see the transfer)


.macro		ldpmz
			ldi ZL,LOW(2*@0)	; Load program memory address into Z
			ldi ZH,HIGH(2*@0)
.endmacro

.macro		ldz
			ldi ZL,LOW(@0)		; Load data memory address into Z
			ldi ZH,HIGH(@0)
.endmacro

.macro		ldy
			ldi YL,LOW(@0)		; Load data memory address into Y
			ldi YH,HIGH(@0)
.endmacro

.macro		ldx
			ldi XL,LOW(@0)		; Load data memory address into X
			ldi XH,HIGH(@0)
.endmacro


.equ	ELSIZE=2			;Size of array element in byte

start:
   				.org 0
				rjmp tstarr1
				in zh,sph


tstarr1:
			//Ex1
			ldpmz	idata1					; Z=source address
			ldy		myarray1				; Y=destination address
			ldi		r16,idata1_len			; data size
			call	init_arr				; Init Array
			//EX2
			ldpmz	idata2					; Z=source address
			ldy		myarray1				; Y=destination address
			ldi		r16,idata2_len			; data size
			call	init_arr				; Init Array
			
			//EX3
//1-Store some data in a temporary ram area (same size as array element)
 
			ldi	r20,0x66
			sts  tmp,r20
			ldi	r20,0x55
			sts  tmp+1,r20

//2- point to temporary area z-->tmp

			ldz tmp

// Transfer temporary area into second arrray element

			ldy	myarray1			; Load array start address into Y
			ldi r17,2				; Load array Element index
			call Write_arr			; Write array element





			nop							;Set a breakpoint here
// **********************************************************************************************
// Write_arr: Write data at given array index 
//  
// Input arguments: Element index r17 (0-255) , Start of array:Y , Source of data Z
// Returns: none
// **********************************************************************************************

Write_arr:
			push r18
			push r16

			ldi	r16,ELSIZE				;Load Element Size in bytes
			call Get_element_Address	;Get element address

;Transfer all Element bytes from source to array element given by index

nextbyt:	ld	r18,Z+					;Load byte from source 
			st	Y+,r18					;Write byte to array 
			dec	r16						;
			brne	nextbyt

			
			pop	r16
			pop r18
			ret

// **********************************************************************************************
// init_arr: Copies data from program memory to an array in data memory (RAM) 
//  
// Input arguments: Z points to Data in program memory (source address)
//					Y points to an array in data memory (destination address)
//					
// Returns: Z to next array element
// **********************************************************************************************

init_arr:
			push r18
			push r16
			

;Transfer all bytes from source to destination

			
nextbyt1:	lpm	r18,Z+					;Load byte from source 
			st	Y+,r18					;Write byte to destination 
			dec	r16						
			brne	nextbyt1

			
			pop	r16
			pop r18
			ret
		
// **************************************************************************************************************
// Get_element_Address: Get_element_Address given an index , an Array address in YH:YL and the array element size
//  
// Input arguments: Array element size r16 (in bytes) ,Element index r17 (0-255) ,Start of array: Y  
// Returns element Address in Y=YH:YL
// **************************************************************************************************************


Get_element_Address:
			
				push r1
				push r0
			
//			Evaluate element offset     (index*ELSIZE)
				mul r17,r16				;Note: multiply result is always in r0:r1
//			Evaluate element address			
				add YL,r0
				adc YH,r1				;Y = Start Array Address + index*ELSIZE
			
				pop r0
				pop r1
			
				ret

//-------------------------------------------------------------

idata1:			.db			0x8,0x9, \
							0xA,0xB, \
							0xC,0xD
end_idata1:
.equ		idata1_len=(end_idata1-idata1)*2		

//-------------------------------------------------------------

idata2:			.db			0x1,0x2,0x3, \
							0x4,0x5,0x6, \
							0x7,0x8,0x9, \
							0xA,0xB,0xC
end_idata2:
.equ		idata2_len=(end_idata2-idata2)*2
//-------------------------------------------------------------

				.dseg					//Data Segment (i.e.RAM)

				.org 0x100				//Start of internal ram


myarray1:		.byte		10*ELSIZE
tmp:			.byte		10
var1:			.byte		2
var3:			.byte		3





