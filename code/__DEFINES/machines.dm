// channel numbers for power
#define EQUIP           1
#define LIGHT           2
#define ENVIRON         3
#define TOTAL           4	//for total power used only
#define STATIC_EQUIP    5
#define STATIC_LIGHT    6
#define STATIC_ENVIRON  7

//Power use
#define NO_POWER_USE 0
#define IDLE_POWER_USE 1
#define ACTIVE_POWER_USE 2

//computer3 error codes, move lower in the file when it passes dev -Sayu
 #define PROG_CRASH				(1<<0)  // Generic crash
 #define MISSING_PERIPHERAL		(1<<1)  // Missing hardware
 #define BUSTED_ASS_COMPUTER	(1<<2)  // Self-perpetuating error.  BAC will continue to crash forever.
 #define MISSING_PROGRAM		(1<<3)  // Some files try to automatically launch a program.  This is that failing.
 #define FILE_DRM				(1<<4)  // Some files want to not be copied/moved.  This is them complaining that you tried.
 #define NETWORK_FAILURE		(1<<5)

#define	IMPRINTER		(1<<0)	//For circuits. Uses glass/chemicals.
#define PROTOLATHE		(1<<1)	//New stuff. Uses glass/metal/chemicals
#define	AUTOLATHE		(1<<2)	//Uses glass/metal only.
#define CRAFTLATHE		(1<<3)	//Uses fuck if I know. For use eventually.
#define MECHFAB			(1<<4) 	//Remember, objects utilising this flag should have construction_time and construction_cost vars.
#define PODFAB			(1<<5) 	//Used by the spacepod part fabricator. Same idea as the mechfab
#define BIOGENERATOR	(1<<6) 	//Uses biomass
#define SMELTER			(1<<7) //uses various minerals
//Note: More then one of these can be added to a design but imprinter and lathe designs are incompatable.

#define HYDRO_SPEED_MULTIPLIER 1


// Demotion Console (card/minor/*) departments
#define TARGET_DEPT_GENERIC 1
#define TARGET_DEPT_SEC 2
#define TARGET_DEPT_MED 3
#define TARGET_DEPT_SCI 4
#define TARGET_DEPT_ENG 5

// These are used by supermatter and supermatter monitor program, mostly for UI updating purposes. Higher should always be worse!
// These are warning defines, they should trigger before the state, not after.
#define SUPERMATTER_ERROR -1		// Unknown status, shouldn't happen but just in case.
#define SUPERMATTER_INACTIVE 0		// No or minimal energy
#define SUPERMATTER_NORMAL 1		// Normal operation
#define SUPERMATTER_NOTIFY 2		// Ambient temp > 80% of CRITICAL_TEMPERATURE
#define SUPERMATTER_WARNING 3		// Ambient temp > CRITICAL_TEMPERATURE OR integrity damaged
#define SUPERMATTER_DANGER 4		// Integrity < 75%
#define SUPERMATTER_EMERGENCY 5		// Integrity < 50%
#define SUPERMATTER_DELAMINATING 6	// Pretty obvious, Integrity < 25%

// Firelock states
#define FD_OPEN 1
#define FD_CLOSED 2

// Computer login types
#define LOGIN_TYPE_NORMAL 1
#define LOGIN_TYPE_AI 2
#define LOGIN_TYPE_ROBOT 3
#define LOGIN_TYPE_ADMIN 4
