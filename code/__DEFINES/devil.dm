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

#define BLOOD_THRESHOLD 3 //How many souls are needed per stage.
#define TRUE_THRESHOLD 7

#define BASIC_DEVIL 0
#define BLOOD_LIZARD 1
#define TRUE_DEVIL 2

#define SOULVALUE (LAZYLEN(soulsOwned))

#define BASIC_DEVIL_REGEN_THRESHOLD 15 SECONDS
#define BLOOD_LIZARD_REGEN_THRESHOLD 7.5 SECONDS
#define TRUE_DEVIL_REGEN_THRESHOLD 2 SECONDS

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
			BANE_SILVER = "Silver seems to gravely injure this devil.",
			BANE_SALT = "Throwing salt at this devil will hinder his ability to use infernal powers temporarily.",
			BANE_LIGHT = "Bright flashes will disorient the devil, likely causing him to flee.",
			BANE_IRON = "Cold iron will slowly injure him, until he can purge it from his system.",
			BANE_WHITECLOTHES = "Wearing clean white clothing will help ward off this devil.",
			BANE_HARVEST = "Presenting the labors of a harvest will disrupt the devil.",
			BANE_TOOLBOX = "That which holds the means of creation also holds the means of the devil's undoing.",
			BAN_HURTWOMAN = "This devil seems to prefer hunting men.",
			BAN_CHAPEL = "This devil avoids holy ground.",
			BAN_HURTPRIEST = "The annointed clergy appear to be immune to his powers.",
			BAN_AVOIDWATER = "The devil seems to have some sort of aversion to water, though it does not appear to harm him.",
			BAN_STRIKEUNCONSCIOUS = "This devil only shows interest in those who are awake.",
			BAN_HURTLIZARD = "This devil will not strike a lizardman first.",
			BAN_HURTANIMAL = "This devil avoids hurting animals.",
			BANISH_WATER = "To banish the devil, you must infuse its body with holy water.",
			BANISH_COFFIN = "This devil will return to life if its remains are not placed within a coffin.",
			BANISH_FORMALDYHIDE = "To banish the devil, you must inject its lifeless body with embalming fluid.",
			BANISH_RUNES = "This devil will resurrect after death, unless its remains are within a rune.",
			BANISH_CANDLES = "A large number of nearby lit candles will prevent it from resurrecting.",
			BANISH_DESTRUCTION = "Its corpse must be utterly destroyed to prevent resurrection.",
			BANISH_FUNERAL_GARB = "If clad in funeral garments, this devil will be unable to resurrect.  Should the clothes not fit, lay them gently on top of the devil's corpse."
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
			BANE_SILVER = "Silver, in all of its forms shall be your downfall.",
			BANE_SALT = "Salt will disrupt your magical abilities.",
			BANE_LIGHT = "Blinding lights will prevent you from using offensive powers for a time.",
			BANE_IRON = "Cold wrought iron shall act as poison to you.",
			BANE_WHITECLOTHES = "Those clad in pristine white garments will strike you true.",
			BANE_HARVEST = "The fruits of the harvest shall be your downfall.",
			BANE_TOOLBOX = "Toolboxes are bad news for you, for some reason.",
			BANISH_WATER = "If your corpse is filled with holy water, you will be unable to resurrect.",
			BANISH_COFFIN = "If your corpse is in a coffin, you will be unable to resurrect.",
			BANISH_FORMALDYHIDE = "If your corpse is embalmed, you will be unable to resurrect.",
			BANISH_RUNES = "If your corpse is placed within a rune, you will be unable to resurrect.",
			BANISH_CANDLES = "If your corpse is near lit candles, you will be unable to resurrect.",
			BANISH_DESTRUCTION = "If your corpse is destroyed, you will be unable to resurrect.",
			BANISH_FUNERAL_GARB = "If your corpse is clad in funeral garments, you will be unable to resurrect."
		)
	))

//These are also used in the codex gigas, so let's declare them globally.
GLOBAL_LIST_INIT(devil_pre_title, list("Dark ", "Hellish ", "Fallen ", "Fiery ", "Sinful ", "Blood ", "Fluffy "))
GLOBAL_LIST_INIT(devil_title, list("Lord ", "Prelate ", "Count ", "Viscount ", "Vizier ", "Elder ", "Adept "))
GLOBAL_LIST_INIT(devil_syllable, list("hal", "ve", "odr", "neit", "ci", "quon", "mya", "folth", "wren", "geyr", "hil", "niet", "twou", "phi", "coa"))
GLOBAL_LIST_INIT(devil_suffix, list(" the Red", " the Soulless", " the Master", ", the Lord of all things", ", Jr."))
