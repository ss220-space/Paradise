//Language flags.
#define WHITELISTED (1<<0)	// Language is available if the speaker is whitelisted.
#define RESTRICTED (1<<1)	// Language can only be accquired by spawning or an admin.
#define HIVEMIND (1<<4)		// Broadcast to all mobs with this language.
#define NONGLOBAL (1<<5)	// Do not add to general languages list
#define INNATE (1<<6)		// All mobs can be assumed to speak and understand this language (audible emotes)
#define NO_TALK_MSG (1<<7)	// Do not show the "\The [speaker] talks into \the [radio]" message
#define NO_STUTTER (1<<8)	// No stuttering, slurring, or other speech problems
#define NOBABEL (1<<9)		// Not granted by book of babel. Typically antag languages.

//Auto-accent level defines.
#define AUTOHISS_OFF 0
#define AUTOHISS_BASIC 1
#define AUTOHISS_FULL 2
#define AUTOHISS_NUM 3 //Number of auto-accent options.
