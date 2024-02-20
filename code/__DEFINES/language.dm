// Language keys.
#define LANGUAGE_NONE				"None"
#define LANGUAGE_NOISE				"Noise"
#define LANGUAGE_UNATHI				"Sinta'unathi"
#define LANGUAGE_TAJARAN			"Siik'tajr"
#define LANGUAGE_VULPKANIN			"Canilunzt"
#define LANGUAGE_SKRELL				"Skrellian"
#define LANGUAGE_VOX				"Vox-pidgin"
#define LANGUAGE_DIONA				"Rootspeak"
#define LANGUAGE_TRINARY			"Trinary"
#define LANGUAGE_KIDAN				"Chittin"
#define LANGUAGE_SLIME				"Bubblish"
#define LANGUAGE_GREY				"Psionic Communication"
#define LANGUAGE_DRASK				"Orluum"
#define LANGUAGE_MOTH				"Tkachi"
#define LANGUAGE_GALACTIC_COMMON	"Galactic Common"
#define LANGUAGE_SOL_COMMON			"Sol Common"
#define LANGUAGE_TRADER				"Tradeband"
#define LANGUAGE_GUTTER				"Gutter"
#define LANGUAGE_CLOWN				"Clownish"
#define LANGUAGE_NEO_RUSSIAN		"Neo-Russkiya"
#define LANGUAGE_WRYN				"Wryn Hivemind"
#define LANGUAGE_XENOS				"Xenomorph"
#define LANGUAGE_HIVE_XENOS			"Xenomorph Hivemind"
#define LANGUAGE_HIVE_TERRORSPIDER	"Spider Hivemind"
#define LANGUAGE_HIVE_CHANGELING	"Changeling Hivemind"
#define LANGUAGE_HIVE_EVENTLING		"Infiltrated Changeling Hivemind"
#define LANGUAGE_HIVE_SHADOWLING	"Shadowling Hivemind"
#define LANGUAGE_HIVE_ABDUCTOR		"Abductor Mindlink"
#define LANGUAGE_HIVE_GOLEM			"Golem Mindlink"
#define LANGUAGE_HIVE_BORER			"Cortical Link"
#define LANGUAGE_BINARY				"Robot Talk"
#define LANGUAGE_DRONE_BINARY		"Drone Talk"
#define LANGUAGE_DRONE				"Drone"
#define LANGUAGE_HIVE_SWARMER		"Swarmer"
#define LANGUAGE_MONKEY_HUMAN		"Chimpanzee"
#define LANGUAGE_MONKEY_SKRELL		"Neara"
#define LANGUAGE_MONKEY_UNATHI		"Stok"
#define LANGUAGE_MONKEY_TAJARAN		"Farwa"
#define LANGUAGE_MONKEY_VULPKANIN	"Wolpin"


// Language flags.
#define WHITELISTED (1<<0)	// Language is available if the speaker is whitelisted.
#define RESTRICTED (1<<1)	// Language can only be accquired by spawning or an admin.
#define HIVEMIND (1<<4)		// Broadcast to all mobs with this language.
#define NONGLOBAL (1<<5)	// Do not add to general languages list
#define INNATE (1<<6)		// All mobs can be assumed to speak and understand this language (audible emotes)
#define NO_TALK_MSG (1<<7)	// Do not show the "\The [speaker] talks into \the [radio]" message
#define NO_STUTTER (1<<8)	// No stuttering, slurring, or other speech problems
#define NOBABEL (1<<9)		// Not granted by book of babel. Typically antag languages.
#define UNIQUE (1<<10)		// Secondary languages for species.

//Auto-accent level defines.
#define AUTOHISS_OFF 0
#define AUTOHISS_BASIC 1
#define AUTOHISS_FULL 2
#define AUTOHISS_NUM 3 //Number of auto-accent options.
