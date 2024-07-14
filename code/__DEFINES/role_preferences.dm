

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
	ROLE_ABDUCTOR = /datum/game_mode/abduction, 		// Abductor
	ROLE_BLOB = /datum/game_mode/blob, 					// Blob
	ROLE_CHANGELING = /datum/game_mode/changeling, 		// Changeling
	ROLE_BORER, 										// Cortical borer
	ROLE_CULTIST = /datum/game_mode/cult, 				// Cultist
	ROLE_CLOCKER = /datum/game_mode/clockwork,			// Clockwork Cultist
	ROLE_DEMON, 										// Demons (Slaughter/Laughter/Shadow)
	ROLE_DEVIL = /datum/game_mode/devil/devil_agents, 	// Devil
	ROLE_GSPIDER, 										// Giant spider
	ROLE_GUARDIAN, 										// Guardian
	ROLE_ELITE,											// Lavaland Elite
	ROLE_MALF_AI = /datum/game_mode/traitor,			// Malf AI
	ROLE_MORPH, 										// Morph
	ROLE_OPERATIVE = /datum/game_mode/nuclear, 			// Operative
	ROLE_PAI, 											// PAI
	ROLE_POSIBRAIN, 									// Positronic brain
	ROLE_REVENANT, 										// Revenant
	ROLE_REV = /datum/game_mode/revolution, 			// Revolutionary
	ROLE_SENTIENT, 										// Sentient animal
	ROLE_SHADOWLING = /datum/game_mode/shadowling, 		// Shadowling
	ROLE_SPACE_DRAGON,									// Space dragon
	ROLE_NINJA, 										// Space ninja
	ROLE_TERROR_SPIDER,									// Terror Spider
	ROLE_THIEF = /datum/game_mode/thief,				// Thief
	ROLE_THUNDERDOME,									// Thunderdome
	ROLE_TRADER, 										// Trader
	ROLE_TRAITOR = /datum/game_mode/traitor, 			// Traitor
	ROLE_VAMPIRE = /datum/game_mode/vampire, 			// Vampire
	ROLE_RAIDER = /datum/game_mode/heist, 				// Vox raider
	ROLE_WIZARD = /datum/game_mode/wizard, 				// Wizard
	ROLE_ALIEN, 										// Xenomorph
	// UNUSED/BROKEN ANTAGS
//	ROLE_HOG_GOD = /datum/game_mode/hand_of_god,
//	ROLE_HOG_CULTIST = /datum/game_mode/hand_of_god,
//	ROLE_MONKEY = /datum/game_mode/monkey, Sooner or later these are going to get ported
//	ROLE_GANG = /datum/game_mode/gang
))
