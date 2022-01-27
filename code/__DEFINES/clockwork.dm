// Clockwork Power
/// REMINDER: The clockwork_power(var) and clockwork_beacons(list) have been moved at _glovalvars/game_modes

//Clockwork Magic
/// How many on-hand spells
#define CLOCK_MAX_HANDSPELLS 2
#define NO_SPELL 0
// Clockslab enchant type
#define STUN_SPELL 1
#define EMP_SPELL 2

/// Power per crew for summoning. For example if 45 players on station, the Ratvar will demand 45*number.
#define CLOCK_POWER_PER_CREW 400
#define CLOCK_POWER_GAIN_MAXIMUM 1000
/// Power gains permanent
#define CLOCK_POWER_CONVERT 150
#define CLOCK_POWER_SACRIFICE 300
/// Power gains as time progresses. Goes in process() so it makes x power per second.
#define CLOCK_POWER_BEACON 2
#define CLOCK_POWER_GENERATOR 10
#define CLOCK_POWER_COG 1

// Clockwork Status
/// At what population does it switch to highpop values
#define CLOCK_POPULATION_THRESHOLD 100
/// Percent for power to reveal (Lowpop)
#define CLOCK_POWER_REVEAL_LOW 0.5
/// Percent clockers to reveal (Lowpop)
#define CLOCK_CREW_REVEAL_LOW 0.25
/// Percent for power to reveal (Highpop)
#define CLOCK_POWER_REVEAL_HIGH 0.3
/// Percent clockers to reveal (Highpop)
#define CLOCK_CREW_REVEAL_HIGH 0.15

// Screen locations
#define DEFAULT_CLOCKSPELLS "6:-29,4:-2"

// Text
#define CLOCK_GREETING "<span class='clocklarge'>You catch a glimpse of the Realm of Ratvar, the Clockwork Justiciar. \
						You now see how flimsy the world is, you see that it should be open to the knowledge of Ratvar.</span>"

#define CLOCK_CURSES list("A fuel technician just slit his own throat and begged for death.",                                          \
			"The shuttle's navigation programming was replaced by a file containing two words, IT COMES.",                             \
			"The shuttle's custodian tore out his guts and began painting strange shapes on the floor.",                               \
			"A shuttle engineer began screaming 'DEATH IS NOT THE END' and ripped out wires until an arc flash seared off her flesh.", \
			"A shuttle inspector started laughing madly over the radio and then threw herself into an engine turbine.",                \
			"The shuttle dispatcher was found dead with bloody symbols carved into their flesh.",                                      \
			"Steve repeatedly touched a lightbulb until his hands fell off.")

// Misc
#define CLOCKCULT_EYE "#ffb700"
// #define SUMMON_POSSIBILITIES 3

// Clockwork objective status
#define RATVAR_IS_ASLEEP 0
#define RATVAR_DEMANDS_POWER 1
#define RATVAR_NEEDS_SUMMONING 2
#define RATVAR_HAS_RISEN 3
#define RATVAR_HAS_FALLEN -1
