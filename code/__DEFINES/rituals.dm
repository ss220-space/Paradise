/// Used in ritual variables
#define DEFAULT_RITUAL_RANGE_FIND       2
#define DEFAULT_RITUAL_COOLDOWN         (100 SECONDS)
#define DEFAULT_RITUAL_DISASTER_PROB    10
#define DEFAULT_RITUAL_FAIL_PROB        10

/// Stages of ritual. Used in ritual custom effects on every stage of ritual.
#define RITUAL_STARTED							(1<<0)
#define RITUAL_ENDED							(1<<1)
#define RITUAL_FAILED 							(1<<2)

/// Tells, that ritual accomplished successfully
#define RITUAL_SUCCESSFUL						(1<<0)

/// Invocation checks, should not be used in extra checks.
#define RITUAL_FAILED_INVALID_SPECIES			    (1<<1)
#define RITUAL_FAILED_MISSED_INVOKER_REQUIREMENTS	(1<<2)
#define RITUAL_FAILED_MISSED_REQUIREMENTS		    (1<<3)
#define RITUAL_FAILED_ON_PROCEED				    (1<<4)
#define RITUAL_FAILED_INVALID_SPECIAL_ROLE		    (1<<5)

