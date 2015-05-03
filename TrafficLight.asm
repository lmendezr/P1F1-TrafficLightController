;******************************************************************************;
;	INEL4206 - MICROPROCESSORS AND EMBEDDED SYSTEMS
;	P1-Phase 1: Traffic Lights Control System
; Description: Software that controls a corresponding circuit to emulate traffic
;	lights at an intersection. Such traffic lights are represented by LEDs
;	connected in a matrix-style circuit which permits the control of such
;	LEDs by selecting which rows and columns are to be activated at a spe-
;	cific time. Each traffic light includes the three conventional lights
;	(red, yellow, and green), as well as an arrow to turn left (blue LED).
;	Street running north-south is considered the main street and the one
;	running west-east is considered secondary.
; Traffic Lights Interface Diagram:
;	    | Primary Lights   | Secondary Lights |
;	     _______   _______   _______   _______
;	    |Light 1| |Light 2| |Light 3| |Light 4|
;     P1.4----| GREEN | | GREEN | | GREEN | | GREEN |
;     P1.5----| YELLOW| | YELLOW| | YELLOW| | YELLOW|
;     P1.6----|  RED  | |  RED  | |  RED  | |  RED  |
;     P1.7----| BLUE  | | BLUE  | | BLUE  | | BLUE  |
;	    |_______| |_______| |_______| |_______|
;       ^         |         |         |         |
;    [0 = ON]     |         |         |         |
;	      P1.0      P1.1      P1.2      P1.3  <--[1 = ON]
;
;	Writen by Lixhjideny Méndez Ríos
;	University of Puerto Rico, Mayagüez Campus
;	April 2015
;	Built with IAR Embedded Workbench Version: 6.30.1
;******************************************************************************;
;-------------------------------------------------------------------------------
; Includes and Variables
;-------------------------------------------------------------------------------
#include "msp430.h"                     ; #define controlled include file
#include "config.h"			; #define controlled config file
;-------------------------------------------------------------------------------
; Register Definitions
;-------------------------------------------------------------------------------
#define	TIMESCTR	R12		; step repetitions reg, a.k.a. state
#define	BLINKCTR	R13		; blinks per step repetitions reg
#define	CLOCKCTR	R14		; clock delay reg
#define	DELAYCTR	R15		; step delay reg
;-------------------------------------------------------------------------------
; MSP430 Initialization
;-------------------------------------------------------------------------------
	ORG	0F800h			; Program Reset
RESET	mov.w	#0300h, SP		; Initialize Stack
	mov.w	#WDTPW+WDTHOLD,&WDTCTL	; stop watchdog timer
	mov.b	#0xFF,&P1DIR		; set P1.0 to P1.7 to output

;-------------------------------------------------------------------------------
; clock macro: provides a delay for the time multiplexing method utilized in the
;		run_state macro.
; CLK: amount of repetitions for the internal iteration. The greater the value,
;		the greater the delay created by the clock macro.
;-------------------------------------------------------------------------------
clock MACRO, Clock
	LOCAL 	c_wait

	mov	#Clock,CLOCKCTR
c_wait	dec	CLOCKCTR
	jnz 	c_wait		; end of clock delay

	ENDM

;-------------------------------------------------------------------------------
; run_state macro: creates a traffic light state appereance on the led lights
;		connected to the P1.x outputs of the MSP430. This is
;		achieved by using time multiplexing between the primary and
;		the secondary lights.
; LED1: number specifying the leds to be active on the primary light (NS)
; LED2: number specifying the leds to be active on the secondary light (WE)
; Times: amount of times for this specific state to be run
; Delay: repetition delay to create an amount of time for a single run
; Clock: clock delay for the intended appereance of the leds
;-------------------------------------------------------------------------------
run_state	MACRO LED1, LED2, Times, Delay, Clock
	LOCAL	state_st, step_st, c_wait

	mov	#Times, TIMESCTR
state_st	mov	#Delay, DELAYCTR
step_st	mov.b	#LED1, &P1OUT	; turn ON the indicated primary lights
clock Clock
	mov.b	#LED2, &P1OUT	; turn ON the indicated secondary lights
clock Clock
	dec 	DELAYCTR
	jnz	step_st		; end of step
	dec	TIMESCTR
	jnz	state_st		; end of state

	ENDM

;-------------------------------------------------------------------------------
; run_blink macro: creates a blinking traffic light state appereance on the led
;		lights connected to the P1.x outputs of the MSP430. This is
;		achieved by using time multiplexing between the primary and
;		the secondary lights, with all-off spaces in between steps.
; LED1: number specifying the leds to be active on the primary light (NS)
; LED2: number specifying the leds to be active on the secondary light (WE)
; Times: amount of times for this specific state to be run
; Delay: repetition delay to create an amount of time for a single step
; Clock: clock delay for the intended appereance of the leds
; Blinks: the amount of blinks per step
;-------------------------------------------------------------------------------
run_blink	MACRO LED1, LED2, Times, Delay, Clock, Blinks
	LOCAL	state_st, blink_st, on_st, off_st
	
	mov	#Times, TIMESCTR
state_st	mov	#Blinks, BLINKCTR	; state start
blink_st	mov	#Delay, DELAYCTR	; blink start

on_st	mov.b	#LED1, &P1OUT	; turn ON the indicated primary lights
clock Clock
	mov.b	#LED2, &P1OUT	; turn ON the indicated secondary lights
clock Clock
	dec 	DELAYCTR
	jnz	on_st		; end of ON part
	
	mov #Delay, DELAYCTR
off_st	bic.b	#0xFF, &P1OUT	; turn OFF all lights
clock Clock			; run the clock twice, provides relative
clock Clock			; amount of time to the on-state
	dec	DELAYCTR
	jnz	off_st		; end of OFF part/step

	dec	BLINKCTR
	jnz	blink_st		; end of blink

	dec	TIMESCTR
	jnz	state_st		; end of state
	ENDM

;-------------------------------------------------------------------------------
; main declaration: executes the program following the plan of work previously 
;		established within the project's instruction/documentation.
;-------------------------------------------------------------------------------
main:
;- Reset State: Blinking Yellow Lights -;
	run_blink PYELLOW, SYELLOW, BLINKREP, BLINKDEL, CLOCK, BLINKS
;- Normal State: Continous loop through the steps of the traffic lights -;
loop:
	run_state PBLUE, SRED, BLUEREP, DELAY, CLOCK
	run_state PGREEN, SRED, GREENREP, DELAY, CLOCK
	run_state PYELLOW, SRED, YELLOWREP, DELAY, CLOCK
	run_state PRED, SRED, REDREP, DELAY, CLOCK
	
	run_state PRED, SBLUE, BLUEREP, DELAY, CLOCK
	run_state PRED, SGREEN, GREENREP, DELAY, CLOCK
	run_state PRED, SYELLOW, YELLOWREP, DELAY, CLOCK
	run_state PRED, SRED, REDREP, DELAY, CLOCK
	jmp loop
;-------------------------------------------------------------------------------
; Interrupt Vectors
;-------------------------------------------------------------------------------
	ORG	0FFFEh		; Address for
	DW	RESET		; RESET Vector
	
	END
