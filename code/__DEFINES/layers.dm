//Defines for atom layers and planes
//KEEP THESE IN A NICE ACSCENDING ORDER, PLEASE


//-------------------- PLANES ---------------------

//NEVER HAVE ANYTHING BELOW THIS PLANE ADJUST IF YOU NEED MORE SPACE
//FOR MORE INFORMATION ON EVERY PLANE, SEE plane_master_subtypes.dm
#define LOWEST_EVER_PLANE -100

#define CLICKCATCHER_PLANE -80


#define PLANE_SPACE -25
#define PLANE_SPACE_PARALLAX -20

#define RENDER_PLANE_TRANSPARENT -11 //Transparent plane that shows openspace underneath the floor

#define FLOOR_PLANE -10

#define WALL_PLANE -9
#define GAME_PLANE -8

#define ABOVE_GAME_PLANE -2

#define RENDER_PLANE_GAME_WORLD -1

#define DEFAULT_PLANE 0 //Marks out the default plane, even if we don't use it

#define AREA_PLANE 2
#define MASSIVE_OBJ_PLANE 3
#define GHOST_PLANE 4
#define POINT_PLANE 5

//---------- LIGHTING -------------
///Normal 1 per turf dynamic lighting underlays
#define LIGHTING_PLANE 10

///Lighting objects that are "free floating"
#define O_LIGHTING_VISUAL_PLANE 11
#define O_LIGHTING_VISUAL_RENDER_TARGET "O_LIGHT_VISUAL_PLANE"

///Used in camerachunks to keep some turfs hidden on photo
#define BYOND_LIGHTING_PLANE 19

/// This plane masks out lighting to create an "emissive" effect, ie for glowing lights in otherwise dark areas.
#define EMISSIVE_PLANE 14
/// The render target used by the emissive.
#define EMISSIVE_RENDER_TARGET "*EMISSIVE_PLANE"

/// Masks the emissive plane
#define EMISSIVE_MASK_PLANE 15
#define EMISSIVE_MASK_RENDER_TARGET "*EMISSIVE_MASK_PLANE"

#define RENDER_PLANE_LIGHTING 16

///Things that should render ignoring lighting
#define ABOVE_LIGHTING_PLANE 17

//---------------- MISC -----------------------

///Pipecrawling images
#define PIPECRAWL_IMAGES_PLANE 20

///AI Camera Static
#define CAMERA_STATIC_PLANE 21

///Anything that wants to be part of the game plane, but also wants to draw above literally everything else
#define HIGH_GAME_PLANE 22

#define FULLSCREEN_PLANE 23

//--------------- FULLSCREEN RUNECHAT BUBBLES ------------

///Popup Chat Messages
#define RUNECHAT_PLANE 30
/// Plane for balloon text (text that fades up)
//#define BALLOON_CHAT_PLANE 31

//-------------------- HUD ---------------------
//HUD layer defines
#define HUD_PLANE 40
#define ABOVE_HUD_PLANE 41

///Plane of the "splash" icon used that shows on the lobby screen. only render plate planes should be above this
#define SPLASHSCREEN_PLANE 50

/// Buildmode HUD that in top-left corner
#define HUD_PLANE_BUILDMODE 40

/// Debug View. This should always be on top. No exceptions.
#define HUD_PLANE_DEBUGVIEW 50

//-------------------- Rendering ---------------------
#define RENDER_PLANE_GAME 100
#define RENDER_PLANE_NON_GAME 101
#define RENDER_PLANE_MASTER 102

// NOTE! You can only ever have planes greater then -10000, if you add too many with large offsets you will brick multiz
// Same can be said for large multiz maps. Tread carefully mappers
#define HIGHEST_EVER_PLANE RENDER_PLANE_MASTER
/// The range unique planes can be in
#define PLANE_RANGE (HIGHEST_EVER_PLANE - LOWEST_EVER_PLANE)

///Plane master controller keys
#define PLANE_MASTERS_GAME "plane_masters_game"

//Plane master critical flags
//Describes how different plane masters behave when they are being culled for performance reasons
/// This plane master will not go away if its layer is culled. useful for preserving effects
#define PLANE_CRITICAL_DISPLAY (1<<0)
/// This plane master will temporarially remove relays to non critical planes if it's layer is culled (and it's critical)
/// This is VERY hacky, but needed to ensure that some instances of BLEND_MULITPLY work as expected (fuck you god damn parallax)
/// It also implies that the critical plane has a *'d render target, making it mask itself
#define PLANE_CRITICAL_NO_EMPTY_RELAY (1<<1)

#define PLANE_CRITICAL_FUCKO_PARALLAX (PLANE_CRITICAL_DISPLAY|PLANE_CRITICAL_NO_EMPTY_RELAY)

/// A value of /datum/preference/numeric/multiz_performance that disables the option
#define MULTIZ_PERFORMANCE_DISABLE -1
/// We expect at most 3 layers of multiz
/// Increment this define if you make a huge map. We unit test for it too just to make it easy for you
/// If you modify this, you'll need to modify the tsx file too
#define MAX_EXPECTED_Z_DEPTH 2

//-------------------- LAYERS ---------------------

#define CINEMATIC_LAYER -1
#define SPACE_LAYER 1.5
#define GRASS_UNDER_LAYER 1.6
/// Which layer turfs appear on by default in the map editor. Should be unique!
#define MAP_EDITOR_TURF_LAYER 1.6999
#define PLATING_LAYER 1.7
#define LATTICE_LAYER 1.701
#define DISPOSAL_PIPE_LAYER 1.71
#define GAS_PIPE_HIDDEN_LAYER 1.72
#define WIRE_LAYER 1.73
#define WIRE_TERMINAL_LAYER 1.75
#define ABOVE_PLATING_LAYER 1.76 // generic for /obj/hide
#define TRAY_SCAN_LAYER_OFFSET 0.5 // place images above TURF_LAYER
#define TRANSPARENT_PLATING_LAYER 1.98
#define TRANSPARENT_GIRDER_LAYER 1.99 // for turf_transparency
//#define TURF_LAYER 2 //For easy recordkeeping; this is a byond define. Most floors (FLOOR_PLANE) and walls (WALL_PLANE) use this.
#define ABOVE_TRANSPARENT_TURF_LAYER 2.01
#define MID_TURF_LAYER 2.02
#define HIGH_TURF_LAYER 2.03
#define TURF_PLATING_DECAL_LAYER 2.031
#define TURF_DECAL_LAYER 2.039 //Makes turf decals appear in DM how they will look inworld.
#define ABOVE_OPEN_TURF_LAYER 2.04
#define CLEANABLES_LAYER 2.045

//WALL_PLANE layers
#define CLOSED_TURF_LAYER 2.05

// GAME_PLANE layers
#define BULLET_HOLE_LAYER 2.06
#define ABOVE_NORMAL_TURF_LAYER 2.08
#define ABOVE_ICYOVERLAY_LAYER 2.11
#define GAS_SCRUBBER_OFFSET -0.001
#define GAS_PIPE_VISIBLE_LAYER 2.47
#define GAS_PIPE_SCRUB_OFFSET 0.001
#define GAS_PIPE_SUPPLY_OFFSET 0.002
#define GAS_FILTER_OFFSET 0.003
#define GAS_PUMP_OFFSET 0.004
#define HOLOPAD_LAYER 2.491
#define CONVEYOR_LAYER 2.495
#define LOW_OBJ_LAYER 2.5
#define LOW_SIGIL_LAYER 2.52
#define SIGIL_LAYER 2.54
#define HIGH_SIGIL_LAYER 2.56

#define BELOW_OPEN_DOOR_LAYER 2.6
#define BLASTDOOR_LAYER 2.65
#define OPEN_DOOR_LAYER 2.7
#define DOOR_HELPER_LAYER 2.71 //keep this above OPEN_DOOR_LAYER
#define PROJECTILE_HIT_THRESHHOLD_LAYER 2.75 //projectiles won't hit objects at or below this layer if possible
#define TABLE_LAYER 2.8
#define BELOW_OBJ_LAYER 2.9
#define LOW_ITEM_LAYER 2.95
//#define OBJ_LAYER 3 //For easy recordkeeping; this is a byond define
#define CLOSED_DOOR_LAYER 3.1
#define CLOSED_FIREDOOR_LAYER 3.11
#define SHUTTER_LAYER 3.12 // HERE BE DRAGONS
#define ABOVE_OBJ_LAYER 3.2
#define ABOVE_WINDOW_LAYER 3.3
#define CLOSED_BLASTDOOR_LAYER 3.35
#define SIGN_LAYER 3.4
#define NOT_HIGH_OBJ_LAYER 3.5
#define HIGH_OBJ_LAYER 3.6

#define BELOW_MOB_LAYER 3.7
#define LYING_MOB_LAYER 3.8
#define BEHIND_MOB_LAYER 3.9
//#define MOB_LAYER 4 //For easy recordkeeping; this is a byond define
#define ABOVE_MOB_LAYER 4.1
#define WALL_OBJ_LAYER 4.25
#define EDGED_TURF_LAYER 4.3
#define ON_EDGED_TURF_LAYER 4.35
#define LARGE_MOB_LAYER 4.4
#define ABOVE_ALL_MOB_LAYER 4.5

// ABOVE_GAME_PLANE layers
#define SPACEVINE_LAYER 4.8
#define SPACEVINE_MOB_LAYER 4.9
//#define FLY_LAYER 5 //For easy recordkeeping; this is a byond define
#define GASFIRE_LAYER 5.05
#define RIPPLE_LAYER 5.1

#define GHOST_LAYER 6
#define LOW_LANDMARK_LAYER 9
#define MID_LANDMARK_LAYER 9.1
#define HIGH_LANDMARK_LAYER 9.2
#define AREA_LAYER 10
#define MASSIVE_OBJ_LAYER 11
#define POINT_LAYER 12
#define CHAT_LAYER 12.0001 // Do not insert layers between these two values
#define CHAT_LAYER_MAX 12.9999
#define LIGHTING_LAYER 15
#define ABOVE_LIGHTING_LAYER 17
#define BYOND_LIGHTING_LAYER 19
#define CAMERA_STATIC_LAYER 20

//HUD layer defines

#define FLASH_LAYER 30
#define FULLSCREEN_LAYER 30.1
#define UI_DAMAGE_LAYER 30.2
#define BLIND_LAYER 30.3
#define CRIT_LAYER 30.4
#define CURSE_LAYER 30.5

#define HUD_LAYER 31
#define ABOVE_HUD_LAYER 32

#define SPLASHSCREEN_LAYER 33

#define OPENSPACE_LAYER 600 //Openspace layer over all
