
// for secHUDs and medHUDs and variants. The number is the location of the image on the list hud_list
// note: if you add more HUDs, even for non-human atoms, make sure to use unique numbers for the defines!
// /datum/atom_hud expects these to be unique
// these need to be strings in order to make them associative lists
/// Dead, alive, sick, health status
#define HEALTH_HUD "1"
/// A simple line rounding the mob's number health
#define STATUS_HUD "2"
/// The job asigned to your ID
#define ID_HUD "3"
/// Wanted, released, parroled, security status
#define WANTED_HUD "4"
/// Mindshield implant
#define IMPMINDSHIELD_HUD "5"
/// Chemical implant
#define IMPCHEM_HUD "6"
/// Ttracking implant
#define IMPTRACK_HUD "7"
/// Silicon/Mech Status
#define DIAG_STAT_HUD "8"
/// Silicon health bar
#define DIAG_HUD "9"
/// Borg/Mech power meter
#define DIAG_BATT_HUD "10"
/// Mech health bar
#define DIAG_MECH_HUD "11"
/// Airlock shock overlay
#define DIAG_AIRLOCK_HUD "12"
/// Mech tracking beacon
#define DIAG_TRACK_HUD "13"
/// Bot path indicators
#define DIAG_PATH_HUD "14"
/// Bot HUDS
#define DIAG_BOT_HUD "15"
/// STATUS_HUD without virus db check for someone being ill
#define STATUS_HUD_OOC "16"
/// for antag huds. these are used at the /mob level
#define SPECIALROLE_HUD "17"
/// Plant nutrient level
#define PLANT_NUTRIENT_HUD "18"
/// Plant water level
#define PLANT_WATER_HUD "19"
/// Plant harvest/dead
#define PLANT_STATUS_HUD "20"
/// Plant health
#define PLANT_HEALTH_HUD "21"
/// Toxin level
#define PLANT_TOXIN_HUD "22"
/// Pest level
#define PLANT_PEST_HUD "23"
/// Weed level
#define PLANT_WEED_HUD "24"
/// Gland indicators for abductors
#define GLAND_HUD "25"
/// Pressure coloring for tiles
#define PRESSURE_HUD "26"
/// Telepathy bubbles
#define THOUGHT_HUD "thoughts_hud"
/// Kidan pheromones hud
#define KIDAN_PHEROMONES_HUD "pheromone_hud"
/// Hud for pacifists(only for dantalion for now)
#define PACIFISM_HUD "pacifism_hud"
/// Hud for vampires only to see default diablerie aura
#define DIABLERIE_AURA_HUD "diablerie_aura_hud"
/// Insurance level
#define INSURANCE_HUD "insurance_hud"


//by default everything in the hud_list of an atom is an image
//a value in hud_list with one of these will change that behavior
#define HUD_LIST_LIST 1

/// cooldown for being shown the images for any particular data hud
#define ADD_HUD_TO_COOLDOWN 20

//data HUD (medhud, sechud) defines
//Don't forget to update human/New() if you change these!
#define DATA_HUD_SECURITY_BASIC 1
#define DATA_HUD_SECURITY_ADVANCED 2
#define DATA_HUD_MEDICAL_BASIC 3
#define DATA_HUD_MEDICAL_ADVANCED 4
#define DATA_HUD_DIAGNOSTIC 5
#define DATA_HUD_DIAGNOSTIC_ADVANCED 6
#define DATA_HUD_HYDROPONIC 7
#define DATA_HUD_PRESSURE 8
//antag HUD defines
#define ANTAG_HUD_CULT 9
#define ANTAG_HUD_CLOCK 10
#define ANTAG_HUD_REV 11
#define ANTAG_HUD_OPS 12
#define ANTAG_HUD_WIZ 13
#define ANTAG_HUD_SHADOW 14
#define ANTAG_HUD_TRAITOR 15
#define ANTAG_HUD_NINJA 16
#define ANTAG_HUD_CHANGELING 17
#define ANTAG_HUD_VAMPIRE 18
#define ANTAG_HUD_ABDUCTOR 19
#define DATA_HUD_ABDUCTOR 20
#define ANTAG_HUD_DEVIL 21
#define ANTAG_HUD_SINTOUCHED 22
#define ANTAG_HUD_SOULLESS 23
#define ANTAG_HUD_EVENTMISC 24
#define ANTAG_HUD_BLOB 25
#define TAIPAN_HUD 26
#define ANTAG_HUD_THIEF 27
#define ANTAG_HUD_PRISONER_TRAITOR 28
#define ANTAG_HUD_TEAM_1 29
#define ANTAG_HUD_TEAM_2 30
#define ANTAG_HUD_TEAM_3 31
#define THOUGHTS_HUD 32
//species hud
#define DATA_HUD_KIDAN_PHEROMONES 33

// Notification action types
#define NOTIFY_JUMP "jump"
#define NOTIFY_ATTACK "attack"
#define NOTIFY_FOLLOW "orbit"

// Icon_state for MEDICAL_HUD
#define STATUS_HUD_DEAD "huddead"
#define STATUS_HUD_DNR "huddeaddnr"
#define STATUS_HUD_FLATLINE "hudflatline"
#define STATUS_HUD_XENO "hudxeno"
#define STATUS_HUD_TUMOUR "hudtumour"
#define STATUS_HUD_BRAINWORM "hudbrainworm"
#define STATUS_HUD_DEFIB "huddefib"
#define STATUS_HUD_RAPID_BLEEDING "hudbleeding2"
#define STATUS_HUD_BLEEDING "hudbleeding1"
#define STATUS_HUD_ILL "hudill"
#define STATUS_HUD_HEALTHY "hudhealthy"

// The kind of things granted by HUD items in game, that do not manifest as
// on-screen icons, but rather go to examine text.
#define EXAMINE_HUD_NONE 0 //"none"
#define EXAMINE_HUD_SECURITY_READ (1<<0) //"security_read"
#define EXAMINE_HUD_SECURITY_WRITE (1<<1) //"security_write"
#define EXAMINE_HUD_MEDICAL (1<<2) //"medical"
#define EXAMINE_HUD_SKILLS (1<<3) //"skills"
#define EXAMINE_HUD_BOTANY (1<<4) //"botany"
#define EXAMINE_HUD_SCIENCE (1<<5) //"science"

// Consider these images/atoms as part of the UI/HUD (apart of the appearance_flags)
/// Used for progress bars and chat messages
#define APPEARANCE_UI_IGNORE_ALPHA (RESET_COLOR|RESET_TRANSFORM|NO_CLIENT_COLOR|RESET_ALPHA|PIXEL_SCALE)
/// Used for HUD objects
#define APPEARANCE_UI (RESET_COLOR|RESET_TRANSFORM|NO_CLIENT_COLOR|PIXEL_SCALE)

//Just for comfortable thoughts_hud management.
#define THOUGHTS_HUD_PRECISE 1
#define THOUGHTS_HUD_DISPERSE -1


// Defines relating to action button positions
/// Whatever the base action datum thinks is best
#define SCRN_OBJ_DEFAULT "default"
/// Floating somewhere on the hud, not in any predefined place
#define SCRN_OBJ_FLOATING "floating"
/// In the list of buttons stored at the top of the screen
#define SCRN_OBJ_IN_LIST "list"
/// In the collapseable palette
#define SCRN_OBJ_IN_PALETTE "palette"
///Inserted first in the list
#define SCRN_OBJ_INSERT_FIRST "first"


//Upper left (action buttons)
#define ui_action_palette "WEST+0:23,NORTH-1:5"
#define ui_action_palette_offset(north_offset) ("WEST+0:23,NORTH-[1+north_offset]:5")
#define ui_palette_scroll "WEST+1:8,NORTH-6:28"
#define ui_palette_scroll_offset(north_offset) ("WEST+1:8,NORTH-[6+north_offset]:28")

// Plane group keys, used to group swaths of plane masters that need to appear in subwindows
/// The primary group, holds everything on the main window
#define PLANE_GROUP_MAIN "main"
/// A secondary group, used when a client views a generic window
#define PLANE_GROUP_POPUP_WINDOW(screen) "popup-[screen.UID()]"

//Blobbernauts
#define ui_blobbernaut_overmind_health "EAST-1:28,CENTER+0:19"
