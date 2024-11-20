/// Used in ritual variables
#define DEFAULT_RITUAL_RANGE_FIND       1
#define DEFAULT_RITUAL_COOLDOWN         (100 SECONDS)
#define DEFAULT_RITUAL_DISASTER_PROB    10
#define DEFAULT_RITUAL_FAIL_PROB        10
/// Ritual object bitflags
#define RITUAL_STARTED							(1<<0)
#define RITUAL_ENDED							(1<<1)
#define RITUAL_FAILED 							(1<<2)
/// Ritual datum bitflags
#define RITUAL_SUCCESSFUL						(1<<0)
/// Invocation checks, should not be used in extra checks.
#define RITUAL_FAILED_INVALID_SPECIES			(1<<1)
#define RITUAL_FAILED_EXTRA_INVOKERS			(1<<2)
#define RITUAL_FAILED_MISSED_REQUIREMENTS		(1<<3)
#define RITUAL_FAILED_ON_PROCEED				(1<<4)
#define RITUAL_FAILED_INVALID_SPECIAL_ROLE		(1<<5)

