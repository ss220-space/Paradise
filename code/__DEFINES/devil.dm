GLOBAL_LIST_INIT(whiteness, list(
	/obj/item/clothing/under/color/white = 2,
	/obj/item/clothing/under/rank/bartender = 1,
	/obj/item/clothing/under/rank/chef = 1,
	/obj/item/clothing/under/rank/chief_engineer = 1,
	/obj/item/clothing/under/rank/scientist = 1,
	/obj/item/clothing/under/rank/chemist = 1,
	/obj/item/clothing/under/rank/chief_medical_officer = 1,
	/obj/item/clothing/under/rank/geneticist = 1,
	/obj/item/clothing/under/rank/virologist = 1,
	/obj/item/clothing/under/rank/nursesuit = 1,
	/obj/item/clothing/under/rank/medical = 1,
	/obj/item/clothing/under/rank/psych = 1,
	/obj/item/clothing/under/rank/orderly = 1,
	/obj/item/clothing/under/rank/security/brigphys = 1,
	/obj/item/clothing/under/rank/internalaffairs = 1,
	/obj/item/clothing/under/rank/ntrep = 1,
	/obj/item/clothing/under/det = 1,
	/obj/item/clothing/under/wedding/bride_white = 1,
	/obj/item/clothing/under/mafia/white = 1,
	/obj/item/clothing/under/noble_clothes = 1,
	/obj/item/clothing/under/sl_suit = 1,
	/obj/item/clothing/under/burial = 1
))

#define ENRAGED_THRESHOLD	4
#define BLOOD_THRESHOLD 	7
#define TRUE_THRESHOLD 		10

#define BASIC_DEVIL 	0
#define ENRAGED_DEVIL 	1
#define BLOOD_LIZARD 	2
#define TRUE_DEVIL 		3

#define SOULVALUE (LAZYLEN(soulsOwned))

#define BASIC_DEVIL_REGEN_THRESHOLD 	10 SECONDS
#define ENRAGED_DEVIL_REGEN_THRESHOLD 	10 SECONDS
#define BLOOD_LIZARD_REGEN_THRESHOLD 	5 SECONDS
#define TRUE_DEVIL_REGEN_THRESHOLD 		3 SECONDS

#define BASIC_DEVIL_REGEN_AMOUNT 		20
#define ENRAGED_DEVIL_REGEN_AMOUNT		40
#define BLOOD_LIZARD_REGEN_AMOUNT 		60
#define TRUE_DEVIL_REGEN_AMOUNT 		80

#define BASIC_DEVIL_RANK	/datum/devil_rank/basic_devil
#define ENRAGED_DEVIL_RANK	/datum/devil_rank/enraged_devil
#define BLOOD_LIZARD_RANK	/datum/devil_rank/blood_lizard
#define TRUE_DEVIL_RANK		/datum/devil_rank/true_devil

#define BANE_SALT "salt"
#define BANE_LIGHT "light"
#define BANE_IRON "iron"
#define BANE_WHITECLOTHES "whiteclothes"
#define BANE_SILVER "silver"
#define BANE_HARVEST "harvest"
#define BANE_TOOLBOX "toolbox"

#define OBLIGATION_FOOD "food"
#define OBLIGATION_FIDDLE "fiddle"
#define OBLIGATION_DANCEOFF "danceoff"
#define OBLIGATION_GREET "greet"
#define OBLIGATION_PRESENCEKNOWN "presenceknown"
#define OBLIGATION_SAYNAME "sayname"
#define OBLIGATION_ANNOUNCEKILL "announcekill"
#define OBLIGATION_ANSWERTONAME "answername"

#define BAN_HURTWOMAN "hurtwoman"
#define BAN_HURTMAN "hurtman"
#define BAN_CHAPEL "chapel"
#define BAN_HURTPRIEST "hurtpriest"
#define BAN_AVOIDWATER "avoidwater"
#define BAN_STRIKEUNCONCIOUS "strikeunconcious"
#define BAN_HURTLIZARD "hurtlizard"
#define BAN_HURTANIMAL "hurtanimal"

#define BANISH_WATER "water"
#define BANISH_COFFIN "coffin"
#define BANISH_FORMALDYHIDE "embalm"
#define BANISH_RUNES "runes"
#define BANISH_CANDLES "candles"
#define BANISH_DESTRUCTION "destruction"
#define BANISH_FUNERAL_GARB "funeral"

#define LORE 1
#define LAW 2

#define BANE_TOOLBOX_DAMAGE_MODIFIER 	2.5
#define BANE_HARVEST_DAMAGE_MULTIPLIER 	2

GLOBAL_LIST_EMPTY(allDevils)
GLOBAL_LIST_INIT(lawlorify, list (
		LORE = list(
			OBLIGATION_FOOD = "This devil seems to always offer its victims food before slaughtering them.",
			OBLIGATION_FIDDLE = "This devil will never turn down a musical challenge.",
			OBLIGATION_DANCEOFF = "This devil will never turn down a dance off.",
			OBLIGATION_GREET = "This devil seems to only be able to converse with people it knows the name of.",
			OBLIGATION_PRESENCEKNOWN = "This devil seems to be unable to attack from stealth.",
			OBLIGATION_SAYNAME = "He will always chant his name upon killing someone.",
			OBLIGATION_ANNOUNCEKILL = "This devil always loudly announces his kills for the world to hear.",
			OBLIGATION_ANSWERTONAME = "This devil always responds to his truename.",
			BAN_HURTWOMAN = "This devil seems to prefer hunting men.",
			BAN_CHAPEL = "This devil avoids holy ground.",
			BAN_HURTPRIEST = "The annointed clergy appear to be immune to his powers.",
			BAN_AVOIDWATER = "The devil seems to have some sort of aversion to water, though it does not appear to harm him.",
			BAN_STRIKEUNCONSCIOUS = "This devil only shows interest in those who are awake.",
			BAN_HURTLIZARD = "This devil will not strike a lizardman first.",
			BAN_HURTANIMAL = "This devil avoids hurting animals.",
		),
		LAW = list(
			OBLIGATION_FOOD = "When not acting in self defense, you must always offer your victim food before harming them.",
			OBLIGATION_FIDDLE = "When not in immediate danger, if you are challenged to a musical duel, you must accept it.  You are not obligated to duel the same person twice.",
			OBLIGATION_DANCEOFF = "When not in immediate danger, if you are challenged to a dance off, you must accept it. You are not obligated to face off with the same person twice.",
			OBLIGATION_GREET = "You must always greet other people by their last name before talking with them.",
			OBLIGATION_PRESENCEKNOWN = "You must always make your presence known before attacking.",
			OBLIGATION_SAYNAME = "You must always say your true name after you kill someone.",
			OBLIGATION_ANNOUNCEKILL = "Upon killing someone, you must make your deed known to all within earshot, over comms if reasonably possible.",
			OBLIGATION_ANSWERTONAME = "If you are not under attack, you must always respond to your true name.",
			BAN_HURTWOMAN = "You must never harm a female outside of self defense.",
			BAN_CHAPEL = "You must never attempt to enter the chapel.",
			BAN_HURTPRIEST = "You must never attack a priest.",
			BAN_AVOIDWATER = "You must never willingly touch a wet surface.",
			BAN_STRIKEUNCONSCIOUS = "You must never strike an unconscious person.",
			BAN_HURTLIZARD = "You must never harm a lizardman outside of self defense.",
			BAN_HURTANIMAL = "You must never harm a non-sentient creature or robot outside of self defense.",
		)
	))

//These are also used in the codex gigas, so let's declare them globally.
GLOBAL_LIST_INIT(devil_pre_title, list("Dark ", "Hellish ", "Fallen ", "Fiery ", "Sinful ", "Blood ", "Fluffy "))
GLOBAL_LIST_INIT(devil_title, list("Lord ", "Prelate ", "Count ", "Viscount ", "Vizier ", "Elder ", "Adept "))
GLOBAL_LIST_INIT(devil_syllable, list("hal", "ve", "odr", "neit", "ci", "quon", "mya", "folth", "wren", "geyr", "hil", "niet", "twou", "phi", "coa"))
GLOBAL_LIST_INIT(devil_suffix, list(" the Red", " the Soulless", " the Master", ", the Lord of all things", ", Jr."))
