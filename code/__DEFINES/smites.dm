// Off:
#define SMITE_DEFAULT			"Кара"
#define SMITE_BURN				"Сжечь"
#define SMITE_HALLUCIONATE	 	"Вызвать галлюцинации"
#define SMITE_COLD				"Заморозить"
#define SMITE_COOKIE			"Проклятое печенье"
#define SMITE_HRP				"ХРП опухоль"

// On:
#define SMITE_LIGHTING			"Удар молнией"
#define SMITE_GIB				"Разорвать на органы"
#define	SMITE_BRAINLOSS 		"Повредить разум"
#define SMITE_HONKTUMOR 		"Банановая опухоль"
#define SMITE_CLUWNE 			"Клунефикация"
#define SMITE_HUNGER			"Голод"
#define SMITE_HUNTER			"Охотник"
#define SMITE_TRAITORHUNTER 	"Агент-охотник"
#define SMITE_TRANSFORM 		"Трансформация"
#define SMITE_ANTIDROP_EQUIP	"Проклятый предмет одежды"
#define SMITE_NUGGET			"Оторвать конечности"
#define SMITE_ROD				"Стержень"
#define SMITE_DUST				"Испепелить"
#define SMITE_SUMMON			"Призвать агрессивное животное"


GLOBAL_LIST_INIT(smites_not_human, list(
	SMITE_LIGHTING = 		/datum/smite/lighting,
	SMITE_GIB = 			/datum/smite/gib,
	SMITE_HUNTER =			/datum/smite/hunter,
	SMITE_TRAITORHUNTER =	/datum/smite/traitor_hunter,
	SMITE_TRANSFORM = 		/datum/smite/transform,
	SMITE_ROD =				/datum/smite/rod,
	SMITE_DUST = 			/datum/smite/dust,
	SMITE_SUMMON = 			/datum/smite/summon,
))

GLOBAL_LIST_INIT(smites_human, list(
	SMITE_BRAINLOSS = 		/datum/smite/brainloss,
	SMITE_HONKTUMOR = 		/datum/smite/honktumor,
	SMITE_CLUWNE = 			/datum/smite/cluwne,
	SMITE_HUNGER =  		/datum/smite/hunger,
	SMITE_ANTIDROP_EQUIP =  /datum/smite/antidrop_equip,
	SMITE_NUGGET = 			/datum/smite/nugget,
))
