// Language keys.
#define LANGUAGE_NONE				null
#define LANGUAGE_NOISE				"key"
#define LANGUAGE_UNATHI				"un"
#define LANGUAGE_TAJARAN			"ta"
#define LANGUAGE_VULPKANIN			"vu"
#define LANGUAGE_SKRELL				"sk"
#define LANGUAGE_VOX				"vo"
#define LANGUAGE_DIONA				"di"
#define LANGUAGE_TRINARY			"tr"
#define LANGUAGE_KIDAN				"ki"
#define LANGUAGE_SLIME				"sl"
#define LANGUAGE_GREY				"gr"
#define LANGUAGE_DRASK				"dr"
#define LANGUAGE_MOTH				"ni"
#define LANGUAGE_GALACTIC_COMMON	"gc"
#define LANGUAGE_SOL_COMMON			"sc"
#define LANGUAGE_TRADER				"tb"
#define LANGUAGE_GUTTER				"gt"
#define LANGUAGE_CLOWN				"cl"
#define LANGUAGE_NEO_RUSSIAN		"nr"
#define LANGUAGE_WRYN				"wr"
#define LANGUAGE_XENOS				"xm"
#define LANGUAGE_HIVE_XENOS			"xh"
#define LANGUAGE_HIVE_TERRORSPIDER	"ts"
#define LANGUAGE_HIVE_CHANGELING	"ch"
#define LANGUAGE_HIVE_EVENTLING		"hs"
#define LANGUAGE_HIVE_SHADOWLING	"sh"
#define LANGUAGE_ABDUCTOR			"ab"
#define LANGUAGE_HIVE_GOLEM			"gl"
#define LANGUAGE_HIVE_BORER			"bo"
#define LANGUAGE_BINARY				"bi"
#define LANGUAGE_DRONE_BINARY		"dt"
#define LANGUAGE_DRONE				"db"
#define LANGUAGE_HIVE_SWARMER		"sw"
#define LANGUAGE_MONKEY_HUMAN		"mo"
#define LANGUAGE_MONKEY_SKRELL		"ne"
#define LANGUAGE_MONKEY_UNATHI		"st"
#define LANGUAGE_MONKEY_TAJARAN		"fa"
#define LANGUAGE_MONKEY_VULPKANIN	"wo"


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
