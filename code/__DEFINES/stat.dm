//mob/var/stat things
#define CONSCIOUS	0
#define UNCONSCIOUS	1
#define DEAD		2

// bitflags for machine stat variable
#define BROKEN		(1<<0)
#define NOPOWER		(1<<1)
#define POWEROFF	(1<<2)		// tbd
#define MAINT		(1<<3)			// under maintaince
#define EMPED		(1<<4)		// temporary broken by EMP pulse

/*
	Logic
*/
//	State						When to Use														Example
#define LOGIC_OFF 0		//Use this for when you want it to stay off						(continuous signal, lever)
#define LOGIC_ON 1		//Use this for when you want it to stay on						(continuous signal, lever)
#define LOGIC_FLICKER 2	//Use this for when you want it to turn on and then turn off	(buttons, clocks)

//Logic-related stuff (Misc. defines for logic things, to keep it organized or something)
#define LOGIC_FLICKER_TIME 10		//number of deciseconds LOGIC_TEMP_ON will remain active before turning off
