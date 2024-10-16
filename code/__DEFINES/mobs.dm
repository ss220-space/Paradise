///////////////////ORGAN DEFINES///////////////////

// Organ defines.
#define ORGAN_BROKEN		(1<<0)
#define ORGAN_ROBOT			(1<<1)
#define ORGAN_SPLINTED		(1<<2)
#define ORGAN_DEAD			(1<<3)
#define ORGAN_MUTATED		(1<<4)
#define ORGAN_INT_BLEED		(1<<5)
#define ORGAN_DISFIGURED	(1<<6)

#define PROCESS_ACCURACY 10

#define DROPLIMB_SHARP 0
#define DROPLIMB_BLUNT 1
#define DROPLIMB_BURN 2

#define TOXIN_TO_INTERNAL_DAMAGE_MULTIPLIER 2 // coefficient wich defines ratio of toxin into internal organs damage transfer

#define AGE_MIN 17			//youngest a character can be
#define AGE_MAX 85			//oldest a character can be


#define LEFT 1
#define RIGHT 2

#define SPLINT_LIFE 2000 //number of steps splints stay on


//Pulse levels, very simplified
#define PULSE_NONE		0	//so !M.pulse checks would be possible
#define PULSE_SLOW		1	//<60 bpm
#define PULSE_NORM		2	//60-90 bpm
#define PULSE_FAST		3	//90-120 bpm
#define PULSE_2FAST		4	//>120 bpm
#define PULSE_THREADY	5	//occurs during hypovolemic shock
//feel free to add shit to lists below


//proc/get_pulse methods
#define GETPULSE_HAND	0	//less accurate (hand)
#define GETPULSE_TOOL	1	//more accurate (med scanner, sleeper, etc)

//Reagent Metabolization flags, defines the type of reagents that affect this mob
#define PROCESS_ORG 1		//Only processes reagents with "ORGANIC" or "ORGANIC | SYNTHETIC"
#define PROCESS_SYN 2		//Only processes reagents with "SYNTHETIC" or "ORGANIC | SYNTHETIC"
#define PROCESS_DUO 4		//Only processes reagents with "ORGANIC | SYNTHETIC"

#define HUMAN_STRIP_DELAY 40 //takes 40ds = 4s to strip someone.
#define ALIEN_SELECT_AFK_BUFFER 1 // How many minutes that a person can be AFK before not being allowed to be an alien.
#define SHOES_SLOWDOWN 0			// How much shoes slow you down by default. Negative values speed you up

#define DISGUST_LEVEL_MAXEDOUT 150 STATUS_EFFECT_CONSTANT
#define DISGUST_LEVEL_DISGUSTED 75 STATUS_EFFECT_CONSTANT
#define DISGUST_LEVEL_VERYGROSS 50 STATUS_EFFECT_CONSTANT
#define DISGUST_LEVEL_GROSS 25 STATUS_EFFECT_CONSTANT

//Mob attribute defaults.
#define DEFAULT_MARKING_STYLES list("head" = "None", "body" = "None", "tail" = "None") //Marking styles. Use instead of initial() for m_styles.
#define DEFAULT_MARKING_COLOURS list("head" = "#000000", "body" = "#000000", "tail" = "#000000") //Marking colours. Use instead of initial() for m_colours.

#define OXYCONCEN_PLASMEN_IGNITION 0.5 //Moles of oxygen in the air needed to light up a poorly clothed Plasmaman. Same as LINDA requirements for plasma burning.

////////REAGENT STUFF////////
// How many units of reagent are consumed per tick, by default.
#define  REAGENTS_METABOLISM 0.4

// Factor of how fast mob nutrition decreases
#define	HUNGER_FACTOR 0.1

// Factor of how fast vampire nutrition decreases
#define	HUNGER_FACTOR_VAMPIRE 0.1

// Taste sensitivity - lower is more sensitive
// Represents the minimum portion of total taste the mob can sense
#define TASTE_SENSITIVITY_NORMAL 15
#define TASTE_SENSITIVITY_SHARP 10
#define TASTE_SENSITIVITY_DULL 25
#define TASTE_SENSITIVITY_NO_TASTE 101

// Reagent type flags, defines the types of mobs this reagent will affect
#define ORGANIC 1
#define SYNTHETIC 2

// Appearance change flags
#define APPEARANCE_UPDATE_DNA (1<<0)
#define APPEARANCE_RACE	(1<<1|APPEARANCE_UPDATE_DNA)
#define APPEARANCE_GENDER (1<<2|APPEARANCE_UPDATE_DNA)
#define APPEARANCE_SKIN (1<<3)
#define APPEARANCE_HAIR (1<<4)
#define APPEARANCE_HAIR_COLOR (1<<5)
#define APPEARANCE_SECONDARY_HAIR_COLOR (1<<6)
#define APPEARANCE_FACIAL_HAIR (1<<7)
#define APPEARANCE_FACIAL_HAIR_COLOR (1<<8)
#define APPEARANCE_SECONDARY_FACIAL_HAIR_COLOR (1<<9)
#define APPEARANCE_EYE_COLOR (1<<10)
#define APPEARANCE_ALL_HAIR APPEARANCE_HAIR|APPEARANCE_HAIR_COLOR|APPEARANCE_SECONDARY_HAIR_COLOR|APPEARANCE_FACIAL_HAIR|APPEARANCE_FACIAL_HAIR_COLOR|APPEARANCE_SECONDARY_FACIAL_HAIR_COLOR
#define APPEARANCE_HEAD_ACCESSORY (1<<11)
#define APPEARANCE_MARKINGS (1<<12)
#define APPEARANCE_BODY_ACCESSORY (1<<13)
#define APPEARANCE_ALT_HEAD (1<<14)
#define APPEARANCE_ALL_BODY APPEARANCE_ALL_HAIR|APPEARANCE_HEAD_ACCESSORY|APPEARANCE_MARKINGS|APPEARANCE_BODY_ACCESSORY|APPEARANCE_ALT_HEAD
#define APPEARANCE_ALL APPEARANCE_RACE|APPEARANCE_GENDER|APPEARANCE_SKIN|APPEARANCE_EYE_COLOR|APPEARANCE_ALL_HAIR|APPEARANCE_ALL_BODY

#define STAMINA_REGEN_BLOCK_TIME (10 SECONDS)

//Slime evolution threshold. Controls how fast slimes can split/grow
#define SLIME_EVOLUTION_THRESHOLD 10
#define SLIME_EVOLUTION_THRESHOLD_OLD 30
#define SLIME_EVOLUTION_THRESHOLD_EVOLVE 50
#define SLIME_EVOLUTION_THRESHOLD_EVOLVE_SLIMEMAN 100

#define SLIME_BABY 		"baby"
#define SLIME_ADULT 	"adult"
#define SLIME_OLD 		"old"
#define SLIME_ELDER 	"elder"
#define SLIME_SLIMEMAN 	"slimeman"

//Slime extract crossing. Controls how many extracts is required to feed to a slime to core-cross.
#define SLIME_EXTRACT_CROSSING_REQUIRED 10

//Slime commands defines
#define SLIME_FRIENDSHIP_FOLLOW 			3 //Min friendship to order it to follow
#define SLIME_FRIENDSHIP_STOPEAT 			5 //Min friendship to order it to stop eating someone
#define SLIME_FRIENDSHIP_STOPEAT_NOANGRY	7 //Min friendship to order it to stop eating someone without it losing friendship
#define SLIME_FRIENDSHIP_STOPCHASE			4 //Min friendship to order it to stop chasing someone (their target)
#define SLIME_FRIENDSHIP_STOPCHASE_NOANGRY	6 //Min friendship to order it to stop chasing someone (their target) without it losing friendship
#define SLIME_FRIENDSHIP_STAY				3 //Min friendship to order it to stay
#define SLIME_FRIENDSHIP_ATTACK				8 //Min friendship to order it to attack

//Hostile simple animals
//If you add a new status, be sure to add a list for it to the simple_animals global in _globalvars/lists/mobs.dm
#define AI_ON 1
#define AI_IDLE 2
#define AI_OFF 3
#define AI_Z_OFF 4

//The range at which a mob should wake up if you spawn into the z level near it
#define MAX_SIMPLEMOB_WAKEUP_RANGE 5

// Intents
#define INTENT_HELP		"help"
#define INTENT_DISARM	"disarm"
#define INTENT_GRAB		"grab"
#define INTENT_HARM		"harm"

// Movement Intents
#define MOVE_INTENT_WALK "walk"
#define MOVE_INTENT_RUN  "run"

// AI wire/radio settings
#define AI_CHECK_WIRELESS 1
#define AI_CHECK_RADIO 2

// Robot notify AI type
#define ROBOT_NOTIFY_AI_CONNECTED 1 //New Cyborg
#define ROBOT_NOTIFY_AI_MODULE 2 //New Module
#define ROBOT_NOTIFY_AI_NAME 3 //New Name
//determines if a mob can smash through it
#define ENVIRONMENT_SMASH_NONE 0
#define ENVIRONMENT_SMASH_STRUCTURES 1 //crates, lockers, ect
#define ENVIRONMENT_SMASH_WALLS 2   //walls
#define ENVIRONMENT_SMASH_RWALLS 4  //rwalls

#define POCKET_STRIP_DELAY			4 SECONDS	//time taken to search somebody's pockets

#define DEFAULT_ITEM_STRIP_DELAY		4 SECONDS  //time taken to strip somebody
#define DEFAULT_ITEM_PUTON_DELAY		2 SECONDS  //time taken to reverse-strip somebody

#define IGNORE_ACCESS -1

//gold slime core spawning
#define NO_SPAWN 0
#define HOSTILE_SPAWN 1
#define FRIENDLY_SPAWN 2

///Max amount of living Xenobio mobs allowed at any given time (excluding slimes).
#define MAX_GOLD_CORE_MOBS 45

#define TINT_IMPAIR 2			//Threshold of tint level to apply weld mask overlay
#define TINT_BLIND 3			//Threshold of tint level to obscure vision fully
#define EYE_SHINE_THRESHOLD 6	//dark_view threshold past which a humanoid's eyes will 'shine' in the dark.

#define STATUS_UPDATE_HEALTH (1<<0)
#define STATUS_UPDATE_STAT (1<<1)
#define STATUS_UPDATE_STAMINA (1<<2)
#define STATUS_UPDATE_BLIND (1<<3)
#define STATUS_UPDATE_NEARSIGHTED (1<<4)

#define STATUS_UPDATE_NONE 0
#define STATUS_UPDATE_ALL (~0)

// Incorporeal movement
#define INCORPOREAL_NONE 0
#define INCORPOREAL_NORMAL 1
#define INCORPOREAL_NINJA 2
#define INCORPOREAL_REVENANT 3

//Human sub-species
#define isshadowling(A) (is_species(A, /datum/species/shadow/ling))
#define isshadowlinglesser(A) (is_species(A, /datum/species/shadow/ling/lesser))
#define isabductor(A) (is_species(A, /datum/species/abductor))
#define isgolem(A) (is_species(A, /datum/species/golem))
#define isfarwa(A) (is_species(A, /datum/species/monkey/tajaran))
#define iswolpin(A) (is_species(A, /datum/species/monkey/vulpkanin))
#define isneara(A) (is_species(A, /datum/species/monkey/skrell))
#define isstok(A) (is_species(A, /datum/species/monkey/unathi))
#define isplasmaman(A) (is_species(A, /datum/species/plasmaman))
#define isshadowperson(A) (is_species(A, /datum/species/shadow))
#define isskeleton(A) (is_species(A, /datum/species/skeleton))
#define ishumanbasic(A) (is_species(A, /datum/species/human))
#define isunathi(A) (is_species(A, /datum/species/unathi))
#define istajaran(A) (is_species(A, /datum/species/tajaran))
#define isvulpkanin(A) (is_species(A, /datum/species/vulpkanin))
#define isskrell(A) (is_species(A, /datum/species/skrell))
#define isvox(A) (is_species(A, /datum/species/vox))
#define isvoxarmalis(A) (is_species(A, /datum/species/vox/armalis))
#define iskidan(A) (is_species(A, /datum/species/kidan))
#define isslimeperson(A) (is_species(A, /datum/species/slime))
#define isnucleation(A) (is_species(A, /datum/species/nucleation))
#define isgrey(A) (is_species(A, /datum/species/grey))
#define isdiona(A) (is_species(A, /datum/species/diona))
#define ismachineperson(A) (is_species(A, /datum/species/machine))
#define isdrask(A) (is_species(A, /datum/species/drask))
#define iswryn(A) (is_species(A, /datum/species/wryn))
#define ismoth(A) (is_species(A, /datum/species/moth))

//Human sub-species names
#define SPECIES_ABDUCTOR "Abductor"
#define SPECIES_DIONA "Diona"
#define SPECIES_DRASK "Drask"

#define SPECIES_GOLEM_BASIC "Голем" //basic-golem used in gamemodes, but not subtypes? whoever find this comment - take a closer look at this
#define SPECIES_GOLEM_RANDOM "Случайный Голем"
#define SPECIES_GOLEM_ADAMANTINE "Адамантиновый Голем"
#define SPECIES_GOLEM_PLASMA "Плазменный Голем"
#define SPECIES_GOLEM_DIAMOND "Алмазный Голем"
#define SPECIES_GOLEM_GOLD "Золотой Голем"
#define SPECIES_GOLEM_SILVER "Серебрянный Голем"
#define SPECIES_GOLEM_PLASTEEL "Пласталиевый Голем"
#define SPECIES_GOLEM_TITANIUM "Титановый Голем"
#define SPECIES_GOLEM_PLASTITANIUM "Пластитановый Голем"
#define SPECIES_GOLEM_ALLOY "Голем из инопланетных сплавов"
#define SPECIES_GOLEM_WOOD "Деревянный Голем"
#define SPECIES_GOLEM_URANIUM "Урановый Голем"
#define SPECIES_GOLEM_PLASTIC "Пластиковый Голем"
#define SPECIES_GOLEM_SAND "Песчаный Голем"
#define SPECIES_GOLEM_GLASS "Стеклянный Голем"
#define SPECIES_GOLEM_BLUESPACE "Блюспейс-Голем"
#define SPECIES_GOLEM_BANANIUM "Бананиевый Голем"
#define SPECIES_GOLEM_TRANQUILLITITE "Транквилитовый Голем"
#define SPECIES_GOLEM_CLOCKWORK "Латунный Голем"

#define SPECIES_GREY "Grey"
#define SPECIES_HUMAN "Human"
#define SPECIES_KIDAN "Kidan"
#define SPECIES_MACNINEPERSON "Machine"
#define SPECIES_MONKEY "Monkey"
#define SPECIES_FARWA "Farwa"
#define SPECIES_WOLPIN "Wolpin"
#define SPECIES_NEARA "Neara"
#define SPECIES_STOK "Stok"
#define SPECIES_MOTH "Nian"
#define SPECIES_NUCLEATION "Nucleation"
#define SPECIES_PLASMAMAN "Plasmaman"

#define SPECIES_SHADOW_BASIC "Shadow"
#define SPECIES_SHADOWLING "Shadowling"
#define SPECIES_LESSER_SHADOWLING "Lesser Shadowling"

#define SPECIES_SKELETON "Skeleton"
#define SPECIES_SKRELL "Skrell"
#define SPECIES_SLIMEPERSON "Slime People"
#define SPECIES_TAJARAN "Tajaran"

#define SPECIES_UNATHI "Unathi"
#define SPECIES_ASHWALKER_BASIC "Ash Walker"
#define SPECIES_ASHWALKER_SHAMAN "Ash Walker Shaman"
#define SPECIES_DRACONOID "Draconid"

#define SPECIES_VOX "Vox"
#define SPECIES_VOX_ARMALIS "Vox Armalis"
#define SPECIES_VULPKANIN "Vulpkanin"
#define SPECIES_WRYN "Wryn"

#define isanimal(A)		(istype((A), /mob/living/simple_animal))
#define iscat(A)		(istype((A), /mob/living/simple_animal/pet/cat))
#define isdog(A)		(istype((A), /mob/living/simple_animal/pet/dog))
#define iscorgi(A)		(istype((A), /mob/living/simple_animal/pet/dog/corgi))
#define ismouse(A)		(istype((A), /mob/living/simple_animal/mouse))
#define isbot(A)		(istype((A), /mob/living/simple_animal/bot))
#define isswarmer(A)	(istype((A), /mob/living/simple_animal/hostile/swarmer))
#define isguardian(A)	(istype((A), /mob/living/simple_animal/hostile/guardian))
#define isnymph(A)      (istype((A), /mob/living/simple_animal/diona))
#define ishostile(A) 	(istype(A, /mob/living/simple_animal/hostile))
#define isterrorspider(A) (istype((A), /mob/living/simple_animal/hostile/poison/terror_spider))
#define isslaughterdemon(A) (istype((A), /mob/living/simple_animal/demon/slaughter))
#define isdemon(A) 			(istype((A), /mob/living/simple_animal/demon))
#define ismorph(A)		(istype((A), /mob/living/simple_animal/hostile/morph))
#define isborer(A)		(istype((A), /mob/living/simple_animal/borer))

#define issilicon(A)	(istype((A), /mob/living/silicon))
#define isAI(A)			(istype((A), /mob/living/silicon/ai))
#define isrobot(A)		(istype((A), /mob/living/silicon/robot))
#define ispAI(A)		(istype((A), /mob/living/silicon/pai))
#define isdrone(A)		(istype((A), /mob/living/silicon/robot/drone))
#define iscogscarab(A)	(istype((A), /mob/living/silicon/robot/cogscarab))

// For the tcomms monitor
#define ispathhuman(A)		(ispath(A, /mob/living/carbon/human))
#define ispathbrain(A)		(ispath(A, /mob/living/carbon/brain))
#define ispathslime(A)		(ispath(A, /mob/living/simple_animal/slime))
#define ispathbot(A)			(ispath(A, /mob/living/simple_animal/bot))
#define ispathsilicon(A)	(ispath(A, /mob/living/silicon))
#define ispathanimal(A)		(ispath(A, /mob/living/simple_animal))

#define isAutoAnnouncer(A)	(istype((A), /mob/living/automatedannouncer))

#define isAIEye(A)		(istype((A), /mob/camera/aiEye))
#define isovermind(A)	(istype((A), /mob/camera/blob))

#define isSpirit(A)		(istype((A), /mob/spirit))
#define ismask(A)		(istype((A), /mob/spirit/mask))

#define isobserver(A)	(istype((A), /mob/dead/observer))

#define isnewplayer(A)  (istype((A), /mob/new_player))

#define isexternalorgan(A)		(istype((A), /obj/item/organ/external))

#define hasorgans(A)	(iscarbon(A))

#define is_admin(user)	(check_rights(R_ADMIN, 0, (user)) != 0)

#define SLEEP_CHECK_DEATH(A, X) \
	sleep(X); \
	if(QDELETED(A)) return; \
	if(ismob(A)) { \
		var/mob/sleep_check_death_mob = A; \
		if(sleep_check_death_mob.stat == DEAD) return; \
	}

/// Until a condition is true, sleep. If target is qdeleted or dead, return.
#define UNTIL_DEATH_CHECK(target, expression) \
	while(!(expression)) { \
		stoplag(); \
		if(QDELETED(target)) return; \
		if(ismob(target)) { \
			var/mob/sleep_check_death_mob = target; \
			if(sleep_check_death_mob.stat == DEAD) return; \
		}; \
	};

// Locations
#define is_ventcrawling(A)  (istype(A.loc, /obj/machinery/atmospherics))

// Hearing protection
#define HEARING_PROTECTION_NONE	0
#define HEARING_PROTECTION_MINOR	1
#define HEARING_PROTECTION_MAJOR	2
#define HEARING_PROTECTION_TOTAL	3

// Eye protection
#define FLASH_PROTECTION_VERYVUNERABLE -4
#define FLASH_PROTECTION_SENSITIVE -1
#define FLASH_PROTECTION_NONE 0
#define FLASH_PROTECTION_FLASH 1
#define FLASH_PROTECTION_WELDER 2

#define MAX_EYE_BLURRY_FILTER_SIZE 5
#define EYE_BLUR_TO_FILTER_SIZE_MULTIPLIER 0.1

#define FIRE_DMI(target) (is_monkeybasic(target) ? 'icons/mob/clothing/species/monkey/OnFire.dmi' : 'icons/mob/OnFire.dmi')

///Define for spawning megafauna instead of a mob for cave gen
#define SPAWN_MEGAFAUNA "bluh bluh huge boss"

// Body position defines.
/// Mob is standing up, usually associated with lying_angle value of 0.
#define STANDING_UP 0
/// Mob is lying down, usually associated with lying_angle values of 90 or 270.
#define LYING_DOWN 1

///How much a mob's sprite should be moved when they're lying down
#define PIXEL_Y_OFFSET_LYING -6

// Slip flags, also known as lube flags
/// The mob will not slip if they're walking intent
#define NO_SLIP_WHEN_WALKING (1<<0)
/// Slipping on this will send them sliding a few tiles down
#define SLIDE (1<<1)
/// Ice slides only go one tile and don't knock you over, they're intended to cause a "slip chain"
/// where you slip on ice until you reach a non-slippable tile (ice puzzles)
#define SLIDE_ICE (1<<2)
/// [TRAIT_NO_SLIP_WATER] does not work on this slip. ONLY [TRAIT_NO_SLIP_ALL] will
#define SLIP_IGNORE_NO_SLIP_WATER (1<<3)
/// Slip works even if you're already on the ground
#define SLIP_WHEN_LYING (1<<4)
/// the mob won't slip if the turf has the TRAIT_TURF_IGNORE_SLIPPERY trait.
#define SLIPPERY_TURF (1<<5)

/// Possible value of [/atom/movable/buckle_lying]. If set to a different (positive-or-zero) value than this, the buckling thing will force a lying angle on the buckled.
#define NO_BUCKLE_LYING -1

#define GRAB_PIXEL_SHIFT_PASSIVE 6
#define GRAB_PIXEL_SHIFT_AGGRESSIVE 12
#define GRAB_PIXEL_SHIFT_NECK 10
#define GRAB_PIXEL_SHIFT_KILL 16

#define PULL_LYING_MOB_SLOWDOWN 1.3
#define PUSH_STANDING_MOB_SLOWDOWN 1.3

#define ACTIVE_HAND_RIGHT 0
#define ACTIVE_HAND_LEFT 1

#define PULL_WITHOUT_HANDS "pull_without_hands"
#define PULL_HAND_RIGHT 0
#define PULL_HAND_LEFT 1

/// Times it takes for a mob to be eaten by default.
#define DEVOUR_TIME_DEFAULT (10 SECONDS)
/// Time it takes for a simple mob to be eaten.
#define DEVOUR_TIME_ANIMAL (3 SECONDS)


//Flags used by the flags parameter of electrocute act.
///Makes it so that the shock doesn't take gloves into account.
#define SHOCK_NOGLOVES (1<<0)
///Used when the shock is from a tesla bolt.
#define SHOCK_TESLA (1<<1)
///Used when an illusion shocks something. Makes the shock deal stamina damage and not trigger certain secondary effects.
#define SHOCK_ILLUSION (1<<2)
///The shock doesn't stun.
#define SHOCK_NOSTUN (1<<3)
/// No default message is sent from the shock
#define SHOCK_SUPPRESS_MESSAGE (1<<4)
/// Ignores TRAIT_SHOCKIMMUNE / TRAIT_TESLA_SHOCKIMMUNE
#define SHOCK_IGNORE_IMMUNITY (1<<5)
/// Prevents the immediate stun, instead only gives the delay
#define SHOCK_DELAY_STUN (1<<6)
/// Makes the weaken into a knockdown
#define SHOCK_KNOCKDOWN (1<<7)

/// Vomit defines
#define VOMIT_NUTRITION_LOSS	10
#define VOMIT_STUN_TIME			(8 SECONDS)
#define VOMIT_DISTANCE			1
#define VOMIT_SAFE_NUTRITION	90
/// Vomit modes
#define VOMIT_BLOOD	(1<<0)

/// When reached - we'll apply status effect which will force carbon to vomit
#define TOX_VOMIT_THRESHOLD_REACHED(mob, toxloss)	(mob.getToxLoss() >= toxloss)
#define TOX_VOMIT_REQUIRED_TOXLOSS	45
