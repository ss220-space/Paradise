/// Time-to-live of participants (default - 5 minutes)
#define DEFAULT_TIME_LIMIT 5 MINUTES
/// After which time thunderdome will be once again allowed to use
#define ARENA_COOLDOWN 5 MINUTES
/// How much tiles away from a center players will spawn
#define CQC_ARENA_RADIUS 6
#define RANGED_ARENA_RADIUS 10
#define VOTING_POLL_TIME 10 SECONDS
#define MAX_PLAYERS_COUNT 16
#define MIN_PLAYERS_COUNT 2
/// How many (polled * spawn_coefficent) players will go brawling
#define SPAWN_COEFFICENT 0.85
/// Prevents fast handed guys from picking polls twice in a row
#define PICK_PENALTY 10 SECONDS 

// Uncomment this if you want to mess up with thunderdome alone
/*
#define THUND_TESTING
#ifdef THUND_TESTING
#define DEFAULT_TIME_LIMIT	30 SECONDS
#define ARENA_COOLDOWN		30 SECONDS
#define VOTING_POLL_TIME	10 SECONDS
#define MIN_PLAYERS_COUNT	1
#define PICK_PENALTY		0
#endif
*/
