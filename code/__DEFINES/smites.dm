// Off:
#define SMITE_DEFAULT "Кара"
#define SMITE_BURN "Сжечь"
#define SMITE_HALLUCIONATE "Вызвать галлюцинации"
#define SMITE_COLD "Заморозить"
#define SMITE_COOKIE "Проклятое печенье"
#define SMITE_HRP "ХРП опухоль"

// On:
#define SMITE_LIGHTING "Удар молнией"
#define SMITE_GIB "Разорвать на органы"
#define	SMITE_BRAINLOSS "Повредить мозг"
#define SMITE_HONKTUMOR "Банановая опухоль"
#define SMITE_CLUWNE "Клунефикация"
#define SMITE_HUNGER "Голод"
#define SMITE_HUNTER "Охотник"
#define SMITE_TRAITORHUNTER "Агент-охотник"
#define SMITE_TRANSFORM "Трансформация"
#define SMITE_ANTIDROP_EQUIP "Проклятая одежда"
#define SMITE_NUGGET "Оторвать конечности"
#define SMITE_ROD "Стержень"
#define SMITE_DUST "Испепелить"
#define SMITE_SUMMON "Агрессивное животное"
#define SMITE_DEMOTE "Увольнение"
#define SMITE_VIRUS "Вирус"
#define	SMITE_POD "Ракета"
#define SMITE_GLOBALHUNTING "Охота"
#define SMITE_BRAINROTBRAINDAMAGE "Автобрейндамаг за брейнрот"
#define SMITE_PIANO "Уронить пианино/автомат"
#define SMITE_JACKBOOTS "Фантомный топот"
#define SMITE_MACHINERY "Разумная машинерия"
#define SMITE_HEADHIT "Головой об шлюзы"

GLOBAL_LIST_INIT(smites_not_human, list(
	SMITE_LIGHTING = /datum/smite/lighting,
	SMITE_GIB = /datum/smite/gib,
	SMITE_HUNTER = /datum/smite/hunter,
	SMITE_TRAITORHUNTER = /datum/smite/traitor_hunter,
	SMITE_TRANSFORM = /datum/smite/transform,
	SMITE_ROD = /datum/smite/rod,
	SMITE_DUST = /datum/smite/dust,
	SMITE_SUMMON = /datum/smite/summon,
	SMITE_POD = /datum/smite/pod,
	SMITE_GLOBALHUNTING = /datum/smite/global_hunting,
	SMITE_PIANO = /datum/smite/piano,
	SMITE_JACKBOOTS = /datum/smite/jackbots,
	SMITE_MACHINERY = /datum/smite/machinery,
	SMITE_HEADHIT = /datum/smite/headhit,
))

GLOBAL_LIST_INIT(smites_human, list(
	SMITE_BRAINLOSS = /datum/smite/brainloss,
	SMITE_HONKTUMOR = /datum/smite/honktumor,
	SMITE_CLUWNE = /datum/smite/cluwne,
	SMITE_HUNGER = /datum/smite/hunger,
	SMITE_ANTIDROP_EQUIP = /datum/smite/antidrop_equip,
	SMITE_NUGGET = /datum/smite/nugget,
	SMITE_DEMOTE = /datum/smite/demote, // Nothing that need being human, but you can't demote corgi.
	SMITE_VIRUS = /datum/smite/virus,
	SMITE_BRAINROTBRAINDAMAGE = /datum/smite/brainrot_braingamage,
))

GLOBAL_LIST_INIT(default_brainrot, list(
	"уву",
	"ума", // Don't ask.
	"увы",
	"ужас",
	"уэ",
	"аааа", // We have *scream.
	"эм",
	"скибиди",
	"ыы",
	"окак",
	"ахах", // We have *laugh.
	"горе",
))
