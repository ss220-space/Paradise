
// for secHUDs and medHUDs and variants. The number is the location of the image on the list hud_list
// note: if you add more HUDs, even for non-human atoms, make sure to use unique numbers for the defines!
// /datum/atom_hud expects these to be unique
// these need to be strings in order to make them associative lists
#define HEALTH_HUD		"1" // dead, alive, sick, health status
#define STATUS_HUD		"2" // a simple line rounding the mob's number health
#define ID_HUD			"3" // the job asigned to your ID
#define WANTED_HUD		"4" // wanted, released, parroled, security status
#define IMPMINDSHIELD_HUD	"5" // mindshield implant
#define IMPCHEM_HUD		"6" // chemical implant
#define IMPTRACK_HUD	"7" // tracking implant
#define DIAG_STAT_HUD	"8" // Silicon/Mech Status
#define DIAG_HUD		"9" // Silicon health bar
#define DIAG_BATT_HUD	"10"// Borg/Mech power meter
#define DIAG_MECH_HUD	"11"// Mech health bar
#define STATUS_HUD_OOC	"12"// STATUS_HUD without virus db check for someone being ill.
#define SPECIALROLE_HUD "13" //for antag huds. these are used at the /mob level
#define DIAG_BOT_HUD	"14"// Bot HUDS
#define PLANT_NUTRIENT_HUD	"15"// Plant nutrient level
#define PLANT_WATER_HUD		"16"// Plant water level
#define PLANT_STATUS_HUD	"17"// Plant harvest/dead
#define PLANT_HEALTH_HUD	"18"// Plant health
#define PLANT_TOXIN_HUD		"19"// Toxin level
#define PLANT_PEST_HUD		"20"// Pest level
#define PLANT_WEED_HUD		"21"// Weed level
#define DIAG_TRACK_HUD		"22"// Mech tracking beacon
#define DIAG_PATH_HUD 		"23"//Bot path indicators
#define GLAND_HUD 			"24"//Gland indicators for abductors
#define THOUGHT_HUD			"25"//Telepathy bubbles
#define KIDAN_PHEROMONES_HUD	"26"//Kidan pheromones hud

//by default everything in the hud_list of an atom is an image
//a value in hud_list with one of these will change that behavior
#define HUD_LIST_LIST 1

//data HUD (medhud, sechud) defines
//Don't forget to update human/New() if you change these!
#define DATA_HUD_SECURITY_BASIC		1
#define DATA_HUD_SECURITY_ADVANCED	2
#define DATA_HUD_MEDICAL_BASIC		3
#define DATA_HUD_MEDICAL_ADVANCED	4
#define DATA_HUD_DIAGNOSTIC			5
#define DATA_HUD_DIAGNOSTIC_ADVANCED	6
#define DATA_HUD_HYDROPONIC			7
//antag HUD defines
#define ANTAG_HUD_CULT 8
#define ANTAG_HUD_CLOCK 9
#define ANTAG_HUD_REV 10
#define ANTAG_HUD_OPS 11
#define ANTAG_HUD_WIZ 12
#define ANTAG_HUD_SHADOW 13
#define ANTAG_HUD_TRAITOR 14
#define ANTAG_HUD_NINJA 15
#define ANTAG_HUD_CHANGELING 16
#define ANTAG_HUD_VAMPIRE 17
#define ANTAG_HUD_ABDUCTOR 18
#define DATA_HUD_ABDUCTOR 19
#define ANTAG_HUD_DEVIL 20
#define ANTAG_HUD_EVENTMISC 21
#define ANTAG_HUD_BLOB 22
#define TAIPAN_HUD 23
#define ANTAG_HUD_THIEF 24
#define THOUGHTS_HUD 25
#define ANTAG_HUD_AFFIL_GORLEX 26
//species hud
#define DATA_HUD_KIDAN_PHEROMONES 27

// Notification action types
#define NOTIFY_JUMP "jump"
#define NOTIFY_ATTACK "attack"
#define NOTIFY_FOLLOW "orbit"


// The kind of things granted by HUD items in game, that do not manifest as
// on-screen icons, but rather go to examine text.
#define EXAMINE_HUD_NONE 					0		//"none"
#define EXAMINE_HUD_SECURITY_READ			(1<<0)	//"security_read"
#define EXAMINE_HUD_SECURITY_WRITE			(1<<1)	//"security_write"
#define EXAMINE_HUD_MEDICAL					(1<<2)	//"medical"
#define EXAMINE_HUD_SKILLS					(1<<3)	//"skills"
#define EXAMINE_HUD_BOTANY					(1<<4)	//"botany"
#define EXAMINE_HUD_SCIENCE					(1<<5)  //"science"


// Consider these images/atoms as part of the UI/HUD (apart of the appearance_flags)
/// Used for progress bars and chat messages
#define APPEARANCE_UI_IGNORE_ALPHA (RESET_COLOR|RESET_TRANSFORM|NO_CLIENT_COLOR|RESET_ALPHA|PIXEL_SCALE)
/// Used for HUD objects
#define APPEARANCE_UI (RESET_COLOR|RESET_TRANSFORM|NO_CLIENT_COLOR|PIXEL_SCALE)

//Just for comfortable thoughts_hud management.
#define THOUGHTS_HUD_PRECISE 1
#define THOUGHTS_HUD_DISPERSE -1

// Plane group keys, used to group swaths of plane masters that need to appear in subwindows
/// The primary group, holds everything on the main window
#define PLANE_GROUP_MAIN "main"
/// A secondary group, used when a client views a generic window
#define PLANE_GROUP_POPUP_WINDOW(screen) "popup-[screen.UID()]"
