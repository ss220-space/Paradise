#define ASSIGNMENT_ANY "Any"
#define ASSIGNMENT_AI "AI"
#define ASSIGNMENT_CYBORG "Cyborg"
#define ASSIGNMENT_ENGINEER "Engineer"
#define ASSIGNMENT_BOTANIST "Botanist"
#define ASSIGNMENT_JANITOR "Janitor"
#define ASSIGNMENT_MEDICAL "Medical"
#define ASSIGNMENT_SCIENTIST "Scientist"
#define ASSIGNMENT_SECURITY "Security"

/*
GLOBAL_LIST_INIT(brs_severity_to_string, list(
	BRS_EVENT_MESS 		= "Mess",
	BRS_EVENT_MINOR 	= "Minor",
	BRS_EVENT_MAJOR 	= "Major",
	BRS_EVENT_CRITICAL 	= "Critical"
	))*/

//event_container.dm
//====================BRS GOAL====================
/datum/event_container/brs_mess
	severity = BRS_EVENT_MESS
	available_events = list(
		// Severity level, event name, event type, base weight, role weights, one shot, min weight, max weight. Last two only used if set.
		new /datum/event_meta(BRS_EVENT_MESS, 	"Ничего",				/datum/event/nothing,			150),
		new /datum/event_meta(BRS_EVENT_MESS, 	"Денежная лотерея",		/datum/event/money_lotto, 		50, 	list(ASSIGNMENT_ANY = 1)),
		new /datum/event_meta(BRS_EVENT_MESS, 	"Взлом аккаунта",		/datum/event/money_hacker, 		50, 	list(ASSIGNMENT_ANY = 4)),
		new /datum/event_meta(BRS_EVENT_MESS, 	"Стенной грибок",		/datum/event/wallrot, 			50,		list(ASSIGNMENT_ENGINEER = 30, ASSIGNMENT_GARDENER = 50)),
		new /datum/event_meta(BRS_EVENT_MESS, "Отходы из вытяжек",		/datum/event/vent_clog,			100),
		new /datum/event_meta(BRS_EVENT_MESS, "Гравитационная аномалия",/datum/event/anomaly/anomaly_grav,		200),
		new /datum/event_meta(BRS_EVENT_MESS, "Блюспейс-аномалия",		/datum/event/anomaly/anomaly_bluespace,	100,	list(ASSIGNMENT_ENGINEER = 25)),
		new /datum/event_meta(BRS_EVENT_MESS, "Массовые галлюцинации",	/datum/event/mass_hallucination,		25),
	)

/datum/event_container/brs_minor
	severity = BRS_EVENT_MINOR
	available_events = list(
		new /datum/event_meta(BRS_EVENT_MINOR, 	"Ничего",					/datum/event/nothing,					100),
		new /datum/event_meta(BRS_EVENT_MINOR, "Пространственный разрыв",	/datum/event/tear,						150,	list(ASSIGNMENT_SECURITY = 35)),
		new /datum/event_meta(BRS_EVENT_MINOR, "Червоточины",				/datum/event/wormholes,					150),
		new /datum/event_meta(BRS_EVENT_MINOR, "Атмосферная аномалия",		/datum/event/anomaly/anomaly_pyro,		150,	list(ASSIGNMENT_ENGINEER = 60)),
		new /datum/event_meta(BRS_EVENT_MINOR, "Вортекс-аномалия",			/datum/event/anomaly/anomaly_vortex,	75,		list(ASSIGNMENT_ENGINEER = 25)),
		new /datum/event_meta(BRS_EVENT_MINOR, "Блюспейс-аномалия",			/datum/event/anomaly/anomaly_bluespace,	200,	list(ASSIGNMENT_ENGINEER = 25)),
		new /datum/event_meta(BRS_EVENT_MINOR, "Флюкс-аномалия",			/datum/event/anomaly/anomaly_flux,		200,	list(ASSIGNMENT_ENGINEER = 50)),
		new /datum/event_meta(BRS_EVENT_MINOR, "Гравитационная аномалия",	/datum/event/anomaly/anomaly_grav,		300),
		new /datum/event_meta(BRS_EVENT_MINOR, 	"Скопление кои",			/datum/event/carp_migration/koi,		80),
		new /datum/event_meta(BRS_EVENT_MINOR, "Телекоммуникационный сбой",/datum/event/communications_blackout,	500,	list(ASSIGNMENT_AI = 150, ASSIGNMENT_SECURITY = 120)),
		new /datum/event_meta(BRS_EVENT_MINOR, "Массовые галлюцинации",		/datum/event/mass_hallucination,		500),
		new /datum/event_meta(BRS_EVENT_MINOR, "Сбой работы дверей",		/datum/event/door_runtime,				50,		list(ASSIGNMENT_ENGINEER = 25, ASSIGNMENT_AI = 150)),
		new /datum/event_meta(BRS_EVENT_MINOR, "Space Dust",				/datum/event/dust,						50,		list(ASSIGNMENT_ENGINEER = 50)),
		new /datum/event_meta(BRS_EVENT_MINOR, "Мясной дождь",				/datum/event/dust/meaty,				50,		list(ASSIGNMENT_ENGINEER = 20)),
	)

/datum/event_container/brs_major
	severity = BRS_EVENT_MAJOR
	available_events = list(
		new /datum/event_meta(BRS_EVENT_MAJOR, 	"Ничего",					/datum/event/nothing,					100),
		new /datum/event_meta(BRS_EVENT_MAJOR, "Солнечная вспышка",			/datum/event/solar_flare,				150,	list(ASSIGNMENT_ENGINEER = 25)),
		new /datum/event_meta(BRS_EVENT_MAJOR, "Электрический шторм",		/datum/event/electrical_storm, 			250,	list(ASSIGNMENT_ENGINEER = 20, ASSIGNMENT_JANITOR = 150)),
		new /datum/event_meta(BRS_EVENT_MAJOR, "Радиационный шторм",		/datum/event/radiation_storm, 			50,		list(ASSIGNMENT_MEDICAL = 50)),
		new /datum/event_meta(BRS_EVENT_MAJOR, "Побег",						/datum/event/prison_break,				100,	list(ASSIGNMENT_SECURITY = 100)),
		new /datum/event_meta(BRS_EVENT_MAJOR, "Замыкание ЛКП",				/datum/event/apc_short, 				300,	list(ASSIGNMENT_ENGINEER = 60)),
		new /datum/event_meta(BRS_EVENT_MAJOR, "Хонкономалия",				/datum/event/tear/honk,					50),
		new /datum/event_meta(BRS_EVENT_MAJOR, "Сбойные дроны",				/datum/event/rogue_drone, 				10,		list(ASSIGNMENT_SECURITY = 20)),
		new /datum/event_meta(BRS_EVENT_MAJOR, "Скопление карпов",			/datum/event/carp_migration,			100, 	list(ASSIGNMENT_ENGINEER = 10, ASSIGNMENT_SECURITY = 20)),
		new /datum/event_meta(BRS_EVENT_MAJOR, "Ионный шторм",				/datum/event/ion_storm, 				25,		list(ASSIGNMENT_AI = 50, ASSIGNMENT_CYBORG = 50, ASSIGNMENT_ENGINEER = 15, ASSIGNMENT_SCIENTIST = 5)),
		new /datum/event_meta(BRS_EVENT_MAJOR, "Вспышка болезни",			/datum/event/disease_outbreak, 			10,		list(ASSIGNMENT_MEDICAL = 150)),
		new /datum/event_meta(BRS_EVENT_MAJOR, "Хедкрабы",					/datum/event/headcrabs, 				100,	list(ASSIGNMENT_SECURITY = 20)),
		new /datum/event_meta(BRS_EVENT_MAJOR, "Сбой работы дверей",		/datum/event/door_runtime,				80,		list(ASSIGNMENT_ENGINEER = 25, ASSIGNMENT_AI = 150))
	)

/datum/event_container/brs_critical
	severity = BRS_EVENT_CRITICAL
	available_events = list(
		new /datum/event_meta(BRS_EVENT_CRITICAL, "Червоточины",			/datum/event/wormholes,					150),
		new /datum/event_meta(BRS_EVENT_CRITICAL, "Вортекс-аномалия",		/datum/event/anomaly/anomaly_vortex,	75,			list(ASSIGNMENT_ENGINEER = 25)),
		new /datum/event_meta(BRS_EVENT_CRITICAL, "Цифровой вирус",			/datum/event/brand_intelligence,		50, 		list(ASSIGNMENT_ENGINEER = 25)),
		new /datum/event_meta(BRS_EVENT_CRITICAL, "Миграция карпов",		/datum/event/carp_migration,			25,			list(ASSIGNMENT_SECURITY =  3)),
		new /datum/event_meta(BRS_EVENT_CRITICAL, "Перегрузка ЛКП",			/datum/event/apc_overload,				50),
	)



#undef ASSIGNMENT_ANY
#undef ASSIGNMENT_AI
#undef ASSIGNMENT_CYBORG
#undef ASSIGNMENT_ENGINEER
#undef ASSIGNMENT_BOTANIST
#undef ASSIGNMENT_JANITOR
#undef ASSIGNMENT_MEDICAL
#undef ASSIGNMENT_SCIENTIST
#undef ASSIGNMENT_SECURITY
