//Bot defines, placed here so they can be read by other things!

#define BOT_STEP_DELAY 4 //Delay between movemements
#define BOT_STEP_MAX_RETRIES 5 //Maximum times a bot will retry to step from its position

#define DEFAULT_SCAN_RANGE 7 //default view range for finding targets.

//Mode defines
#define BOT_IDLE 0 // idle
#define BOT_HUNT 1 // found target, hunting
#define BOT_PREP_ARREST 2 // at target, preparing to arrest
#define BOT_ARREST 3 // arresting target
#define BOT_START_PATROL 4 // start patrol
#define BOT_PATROL 5 // patrolling
#define BOT_SUMMON 6 // summoned by PDA
#define BOT_CLEANING 7 // cleaning (cleanbots)
#define BOT_REPAIRING 8 // repairing hull breaches (floorbots)
#define BOT_MOVING 9 // for clean/floor/med bots, when moving.
#define BOT_HEALING 10 // healing people (medbots)
#define BOT_RESPONDING 11 // responding to a call from the AI
#define BOT_DELIVER 12 // moving to deliver
#define BOT_GO_HOME 13 // returning to home
#define BOT_BLOCKED 14 // blocked
#define BOT_NAV 15 // computing navigation
#define BOT_WAIT_FOR_NAV 16 // waiting for nav computation
#define BOT_NO_ROUTE 17 // no destination beacon found (or no route)

// Bot types
/// Secutritrons (Beepsky)
#define SEC_BOT "Securitron"
/// ED-209s
#define ADVANCED_SEC_BOT "ED-209"
/// MULEbots
#define MULE_BOT "MULEbot"
/// Floorbots
#define FLOOR_BOT "Floorbot"
/// Cleanbots
#define CLEAN_BOT "Cleanbot"
/// Medibots
#define MED_BOT "Medibot"
/// Honkbots
#define HONK_BOT "Honkbot"
/// Griefsky
#define GRIEF_BOT "Grief"

//Sentience types
#define SENTIENCE_ORGANIC 1
#define SENTIENCE_ARTIFICIAL 2
#define SENTIENCE_OTHER 3
#define SENTIENCE_MINEBOT 4
#define SENTIENCE_BOSS 5
