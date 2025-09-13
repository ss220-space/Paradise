// Off:
#define SMITE_DEFAULT		"Кара"
#define SMITE_BURN			"Сжечь"
#define SMITE_HALLUCIONATE 	"Вызвать галлюцинации"
#define SMITE_COLD			"Заморозить"
#define SMITE_COOKIE		"Проклятое печенье"

// On:
#define SMITE_LIGHTING		"Удар молнией"
#define SMITE_GIB			"Разорвать на органы"
#define	SMITE_BRAINLOSS 	"Повредить разум"
#define SMITE_HONKTUMOR 	"Банановая опухоль"
#define SMITE_CLUWNE 		"Клунефикация"
#define SMITE_HUNGER		"Голод"
#define SMITE_HUNTER		"Охотник"
#define SMITE_TRAITORHUNTER "Агент-охотник"

GLOBAL_LIST_INIT(smites_not_human, list(
	SMITE_LIGHTING = 		/datum/smite/lighting,
	SMITE_GIB = 			/datum/smite/gib,
	SMITE_HUNTER =			/datum/smite/hunter,
	SMITE_TRAITORHUNTER =	/datum/smite/traitor_hunter,
))

GLOBAL_LIST_INIT(smites_human, list(
	SMITE_BRAINLOSS = 	/datum/smite/brainloss,
	SMITE_HONKTUMOR = 	/datum/smite/honktumor,
	SMITE_CLUWNE = 		/datum/smite/cluwne,
	SMITE_HUNGER =  	/datum/smite/hunger,
))
