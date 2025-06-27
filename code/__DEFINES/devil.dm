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

#define ENRAGED_THRESHOLD	3
#define BLOOD_THRESHOLD 	6
#define TRUE_THRESHOLD 		9
#define ASCEND_THRESHOLD 	13

#define BLOOD_SACRIFICE 	1
#define TRUE_SACRIFICE 		2

#define ASCEND_SACRIFICE 	2

#define BASIC_DEVIL_REGEN_THRESHOLD 	8 SECONDS
#define ENRAGED_DEVIL_REGEN_THRESHOLD 	6 SECONDS
#define BLOOD_LIZARD_REGEN_THRESHOLD 	4 SECONDS
#define TRUE_DEVIL_REGEN_THRESHOLD 		3 SECONDS
#define ASCEND_DEVIL_REGEN_THRESHOLD 	1 SECONDS

#define BASIC_DEVIL_REGEN_AMOUNT 		15
#define ENRAGED_DEVIL_REGEN_AMOUNT		30
#define BLOOD_LIZARD_REGEN_AMOUNT 		40
#define TRUE_DEVIL_REGEN_AMOUNT 		60
#define	ASCEND_DEVIL_REGEN_AMOUNT 		100

#define DEVIL_REGEN_BOOST				2

#define BASIC_DEVIL_RANK	/datum/devil_rank/basic_devil
#define ENRAGED_DEVIL_RANK	/datum/devil_rank/enraged_devil
#define BLOOD_LIZARD_RANK	/datum/devil_rank/blood_lizard
#define TRUE_DEVIL_RANK		/datum/devil_rank/true_devil
#define ASCEND_DEVIL_RANK	/datum/devil_rank/ascend

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

#define CONTRACT_POWER "Сила"
#define CONTRACT_WEALTH "Богатство"
#define CONTRACT_PRESTIGE "Престиж"
#define CONTRACT_MAGIC "Магия"
#define CONTRACT_REVIVE "Воскрешение"
#define CONTRACT_KNOWLEDGE "Знание"
#define CONTRACT_UNWILLING "Безвозмездный контракт"
#define CONTRACT_FRIENDSHIP "Дружба"
#define CONTRACT_YOUTH "Вечная молодость"
#define CONTRACT_ETALENT "Инженерный талант"
#define CONTRACT_RETURNDEAD "Воскрешение мертвых"
#define CONTRACT_GUN "Оружия"

// FIXME: Implement these
#define CONTRACT_CTALENT "Chemistry Talent"
#define CONTRACT_AUGMENT "Cybernetic Augmentations"
#define CONTRACT_CANDY "Endless Candy"
#define CONTRACT_ECHANCE "An Extra Chance"
#define CONTRACT_ATECH "Advanced Technology"
#define CONTRACT_DEVILSMACHINE "Devil's Machinery"
#define CONTRACT_FOOD "Food"
#define CONTRACT_SPACE "Space Gear"
#define CONTRACT_CALAMITY "Calamity"


#define BANE_TOOLBOX_DAMAGE_MODIFIER 	2.5
#define BANE_HARVEST_DAMAGE_MULTIPLIER 	2
#define BANE_IRON_DAMAGE_MODIFIER 	2
#define BANE_SILVER_DAMAGE_MULTIPLIER 	3


#define DEVIL_ASCEND_START_STAGE 0
#define FIRST_DEVIL_ASCEND_STAGE 1
#define SECOND_DEVIL_ASCEND_STAGE 2
#define THIRD_DEVIL_ASCEND_STAGE 3
#define FOURTH_DEVIL_ASCEND_STAGE 4
#define FIFTH_DEVIL_ASCEND_STAGE 5
#define SIXTH_DEVIL_ASCEND_STAGE 6
#define SEVENTH_DEVIL_ASCEND_STAGE 7
#define EIGHTH_DEVIL_ASCEND_STAGE 8

GLOBAL_LIST_EMPTY(allDevils)
//These are also used in the codex gigas, so let's declare them globally.
GLOBAL_LIST_INIT(devil_pre_title, list("Dark ", "Hellish ", "Fallen ", "Fiery ", "Sinful ", "Blood ", "Fluffy "))
GLOBAL_LIST_INIT(devil_title, list("Lord ", "Prelate ", "Count ", "Viscount ", "Vizier ", "Elder ", "Adept "))
GLOBAL_LIST_INIT(devil_syllable, list("hal", "ve", "odr", "neit", "ci", "quon", "mya", "folth", "wren", "geyr", "hil", "niet", "twou", "phi", "coa"))
GLOBAL_LIST_INIT(devil_suffix, list(" the Red", " the Soulless", " the Master", ", the Lord of all things", ", Jr."))
