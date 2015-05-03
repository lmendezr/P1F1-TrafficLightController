/*******************************************************************************
/	INEL4206 - MICROPROCESSORS AND EMBEDDED SYSTEMS
/	P1-Phase 1: Traffic Lights Control System Config File
/ Description: Configuration file for the Traffic Lights Control System
/	assembly program. Changes to this file will only be reflected
/	upon re-compilation of the complete software.
*******************************************************************************/

/*******************************************************************************
/ Repetition Definitions: These affect how many times each particular state 
/	will be repeated.
*******************************************************************************/
#define	BLINKREP	(4)
#define	GREENREP	(4)
#define	YELLOWREP	(1)
#define	REDREP	(1)
#define	BLUEREP	(2)

/*******************************************************************************
/ Delay Definitions: These affect how long will each particular delay last.
/ Note: These values should not be tampered in order to avoid erratic behaviour.
*******************************************************************************/
#define	CLOCK	(460)		// provides time for a correct always-on appereance
#define	DELAY	(180)		// creates .5 seconds for a step
#define	BLINKS	(2)		// amount of blinks per blinking step
#define	BLINKDEL	(DELAY/(BLINKS*2))	// creates .5 seconds for a blinking step

/*******************************************************************************
/ Port Definitions: These affect which ports will be activated by the software.
/ Note: These values should not be tampered in order to avoid erratic behaviour.
*******************************************************************************/
// Primary Road Lights
#define	PBLUE	(0xE3)
#define	PGREEN	(0xD3)
#define	PYELLOW	(0xB3)
#define	PRED	(0x73)
// Secondary Road Lights
#define	SBLUE	(0xEC)
#define	SGREEN	(0xDC)
#define	SYELLOW	(0xBC)
#define	SRED	(0x7C)