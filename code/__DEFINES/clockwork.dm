// Clockwork Raret (Power)
/// REMINDER: The clockwork_power(var) and clockwork_beacons(list) have been moved at _glovalvars/game_modes

//Clockwork Magic
/// How many on-hand spells
#define CLOCK_MAX_HANDSPELLS 2

// state for spell
#define NO_SPELL 0
#define A_SPELL 1
#define CASTING_SPELL -1

// Clockslab enchant type
#define STUN_SPELL 1
#define EMP_SPELL 2
#define KNOCK_SPELL 3
#define TIME_SPELL 4
#define REFORM_SPELL 5
#define TELEPORT_SPELL 6
// Ratvarian spear enchant type
#define CONFUSE_SPELL 1
#define DISABLE_SPELL 2
// Clock hammer
#define CRUSH_SPELL 1
#define KNOCKOFF_SPELL 2
// Clockwork robe
#define WEAK_REFLECT_SPELL 1
#define WEAK_ABSORB_SPELL 2
#define INVIS_SPELL 3
// armour
#define REFLECT_SPELL 1
#define FLASH_SPELL 2
#define ABSORB_SPELL 3
#define ARMOR_SPELL 4
// Clockwork gloves
#define FASTPUNCH_SPELL 1
#define STUNHAND_SPELL 2
#define FIRE_SPELL 3

// spell_enchant(name, type_SPELL, cost, time, action needs)
GLOBAL_LIST_INIT(clockslab_spells, list(
	new /datum/spell_enchant("Stun", STUN_SPELL, 125),
	new /datum/spell_enchant("Electromagnetic Pulse", EMP_SPELL, 200),
	new /datum/spell_enchant("Force Passage", KNOCK_SPELL, 100),
	new /datum/spell_enchant("Stop the time", TIME_SPELL, 225, 30),
	new /datum/spell_enchant("Terraform", REFORM_SPELL, 75),
	new /datum/spell_enchant("Teleportation", TELEPORT_SPELL, 50)
))
GLOBAL_LIST_INIT(spear_spells, list(
	new /datum/spell_enchant("Confusion", CONFUSE_SPELL, 125),
	new /datum/spell_enchant("Electrical touch", DISABLE_SPELL, 200)
))
GLOBAL_LIST_INIT(hammer_spells, list(
	new /datum/spell_enchant("Crusher", CRUSH_SPELL, 125),
	new /datum/spell_enchant("Knock off", KNOCKOFF_SPELL, 200)
))
GLOBAL_LIST_INIT(robe_spells, list(
	new /datum/spell_enchant("Weak Reflection", WEAK_REFLECT_SPELL, 75),
	new /datum/spell_enchant("Invisibility", INVIS_SPELL, 100)
))
GLOBAL_LIST_INIT(armour_spells, list(
	new /datum/spell_enchant("Reflection", REFLECT_SPELL, 150, 15),
	new /datum/spell_enchant("Flash", FLASH_SPELL, 25, TRUE),
	new /datum/spell_enchant("Absorb", ABSORB_SPELL, 150, 15),
	new /datum/spell_enchant("Harden plates", ARMOR_SPELL, 150, 30, TRUE)
))
GLOBAL_LIST_INIT(gloves_spell, list(
	new /datum/spell_enchant("Hands of North Star", FASTPUNCH_SPELL, 100, TRUE),
	new /datum/spell_enchant("Stunning", STUNHAND_SPELL, 100),
	new /datum/spell_enchant("Red Flame", FIRE_SPELL, 75, TRUE)
))
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
#define COG_MAX_SIPHON_THRESHOLD 0.25 //The cog will not siphon power if the APC's cell is at this % of power

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
#define CLOCK_COLOER "#ffb700"
// #define SUMMON_POSSIBILITIES 3

// Clockwork objective status
#define RATVAR_IS_ASLEEP 0
#define RATVAR_DEMANDS_POWER 1
#define RATVAR_NEEDS_SUMMONING 2
#define RATVAR_HAS_RISEN 3
#define RATVAR_HAS_FALLEN -1
