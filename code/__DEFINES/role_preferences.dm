

//Values for antag preferences, event roles, etc. unified here



//These are synced with the Database, if you change the values of the defines
//then you MUST update the database!
// If you're adding a new role, remember to update modules/admin/topic.dm, so admins can dish out
// justice if someone's abusing your role
#define ROLE_SYNDICATE			"Синдикат"
#define ROLE_TRAITOR			"предатель"
#define ROLE_OPERATIVE			"ядерный оперативник"
#define ROLE_CHANGELING			"генокрад"
#define ROLE_WIZARD				"маг"
#define ROLE_REV				"революционер"
#define ROLE_ALIEN				"ксеноморф"
#define ROLE_THUNDERDOME		"thunderdome"
#define ROLE_PAI				"пИИ"
#define ROLE_CULTIST			"культист"
#define ROLE_CLOCKER			"праведник Ратвара"
#define ROLE_BLOB				"блоб"
#define ROLE_NINJA				"космический ниндзя"
#define ROLE_MONKEY				"обезьяна"
#define ROLE_GANG				"гангстер"
#define ROLE_SHADOWLING			"тенеморф"
#define ROLE_ABDUCTOR			"абдуктор"
#define ROLE_REVENANT			"ревенант"
#define ROLE_HOG_GOD			"рука бога: бог" // We're prolly gonna port this one day or another
#define ROLE_HOG_CULTIST		"рука бога: культист"
#define ROLE_DEVIL				"торговец душ"
#define ROLE_RAIDER				"вокс-рейдер"
#define ROLE_TRADER				"торговцы ТСФ"
#define ROLE_VAMPIRE			"вампир"
#define ROLE_THIEF 				"вор"
#define ROLE_TERROR_SPIDER		"паук ужаса"
// Role tags for EVERYONE!
#define ROLE_BORER				"мозговой червь"
#define ROLE_DEMON				"демон"
#define ROLE_SENTIENT			"разумное животное"
#define ROLE_POSIBRAIN			"позитронный мозг"
#define ROLE_GUARDIAN			"страж"
#define ROLE_MORPH				"морф"
#define ROLE_ERT				"отряд быстрого реагирования"
#define ROLE_NYMPH				"нимфа"
#define ROLE_GSPIDER			"гигантский паук"
#define ROLE_DRONE				"дрон"
#define ROLE_DEATHSQUAD			"эскадрон смерти"
#define ROLE_EVENTMISC			"специальная ивентовая роль"
#define ROLE_GHOST				"призрачная роль"
#define ROLE_ELITE				"элита лаваленда"
#define ROLE_SPACE_DRAGON 		"космический дракон"
#define ROLE_MALF_AI			"сбойный ИИ"

#define ROLE_NONE				"ничего"	// special define used as a marker
#define ROLE_HIJACKER			"угонщик"	// another marker

//Missing assignment means it's not a gamemode specific role, IT'S NOT A BUG OR ERROR.
//The gamemode specific ones are just so the gamemodes can query whether a player is old enough
//(in game days played) to play that role
GLOBAL_LIST_INIT(special_roles, list(
	ROLE_ABDUCTOR = /datum/game_mode/abduction, 		// Абдуктор
	ROLE_BLOB = /datum/game_mode/blob, 					// Блоб
	ROLE_CHANGELING = /datum/game_mode/changeling, 		// Генокрад
	ROLE_BORER, 										// Мозговой червь
	ROLE_CULTIST = /datum/game_mode/cult, 				// Культист
	ROLE_CLOCKER = /datum/game_mode/clockwork,			// Праведник Ратвара
	ROLE_DEMON, 										// Демоны (Демон резни/Демон смеха/Теневой демон)
	ROLE_DEVIL = /datum/game_mode/devil/devil_agents, 	// Продавец душ
	ROLE_GSPIDER, 										// Гигантский паук
	ROLE_GUARDIAN, 										// Страж
	ROLE_ELITE,											// Элита Лаваленда
	ROLE_MALF_AI = /datum/game_mode/traitor,			// Сбойный ИИ
	ROLE_MORPH, 										// Морф
	ROLE_OPERATIVE = /datum/game_mode/nuclear, 			// Ядерный Оперативник
	ROLE_PAI, 											// ПИИ
	ROLE_POSIBRAIN, 									// Позитронный мозг
	ROLE_REVENANT, 										// Ревенант
	ROLE_REV = /datum/game_mode/revolution, 			// Революционер
	ROLE_SENTIENT, 										// Разумное животное 
	ROLE_SHADOWLING = /datum/game_mode/shadowling, 		// Тенеморф
	ROLE_SPACE_DRAGON,									// Космический дракон
	ROLE_NINJA, 										// Космический ниндзя
	ROLE_TERROR_SPIDER,									// Паук Ужаса
	ROLE_THIEF = /datum/game_mode/thief,				// Вор
	ROLE_THUNDERDOME,									// Thunderdome
	ROLE_TRADER, 										// Торговцы ТСФ
	ROLE_TRAITOR = /datum/game_mode/traitor, 			// Предатель
	ROLE_VAMPIRE = /datum/game_mode/vampire, 			// Вампир
	ROLE_RAIDER = /datum/game_mode/heist, 				// Вокс-рейдер
	ROLE_WIZARD = /datum/game_mode/wizard, 				// Маг
	ROLE_ALIEN, 										// Ксеноморф
	// UNUSED/BROKEN ANTAGS
//	ROLE_HOG_GOD = /datum/game_mode/hand_of_god,
//	ROLE_HOG_CULTIST = /datum/game_mode/hand_of_god,
//	ROLE_MONKEY = /datum/game_mode/monkey, Sooner or later these are going to get ported
//	ROLE_GANG = /datum/game_mode/gang
))
