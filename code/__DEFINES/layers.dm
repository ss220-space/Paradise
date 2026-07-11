//Defines for atom layers and planes
//KEEP THESE IN A NICE ACSCENDING ORDER, PLEASE

//-------------------- PLANES ---------------------

// NEVER HAVE ANYTHING BELOW THIS PLANE ADJUST IF YOU NEED MORE SPACE
#define LOWEST_EVER_PLANE -50

// Doesn't really layer, just throwing this in here cause it's the best place imo
#define FIELD_OF_VISION_BLOCKER_PLANE -45
#define FIELD_OF_VISION_BLOCKER_RENDER_TARGET "*FIELD_OF_VISION_BLOCKER_RENDER_TARGET"

#define CLICKCATCHER_PLANE -40

#define PLANE_SPACE -21
#define PLANE_SPACE_PARALLAX -20

#define DISPLACEMENT_PLANE -12
#define DISPLACEMENT_RENDER_TARGET "*DISPLACEMENT_RENDER_TARGET"

/// Transparent plane that shows openspace underneath the floor
#define RENDER_PLANE_TRANSPARENT -11

#define TRANSPARENT_FLOOR_PLANE -10

#define FLOOR_PLANE -7

#define WALL_PLANE -6
#define BELOW_GAME_PLANE -5
#define GAME_PLANE -4

#define ABOVE_GAME_PLANE -3

/// Slightly above the game plane but does not catch mouse clicks. Useful for certain visuals that should be clicked through, like seethrough trees
#define SEETHROUGH_PLANE -2

#define RENDER_PLANE_GAME_WORLD -1

/// Marks out the default plane, even if we don't use it
#define DEFAULT_PLANE 0

#define WEATHER_PLANE 1
#define AREA_PLANE 2
#define MASSIVE_OBJ_PLANE 3
#define GHOST_PLANE 4
#define POINT_PLANE 5

//---------- LIGHTING -------------
/// Normal 1 per turf dynamic lighting underlays
#define LIGHTING_PLANE 10

/// Lighting objects that are "free floating"
#define O_LIGHTING_VISUAL_PLANE 11

/// Render plate used by overlay lighting to mask turf lights
#define RENDER_PLANE_TURF_LIGHTING 12

#define EMISSIVE_PLANE 13
/// This plane masks out lighting to create an "emissive" effect, ie for glowing lights in otherwise dark areas.
#define RENDER_PLANE_EMISSIVE 14
#define EMISSIVE_RENDER_TARGET "*RENDER_PLANE_EMISSIVE"
// Ensures all the render targets that point at the emissive plate layer correctly
#define EMISSIVE_Z_BELOW_LAYER 1
#define EMISSIVE_FLOOR_LAYER 2
#define EMISSIVE_SPACE_LAYER 3
#define EMISSIVE_WALL_LAYER 4

#define RENDER_PLANE_EMISSIVE_BLOOM_MASK 15
#define EMISSIVE_BLOOM_MASK_RENDER_TARGET "*RENDER_PLANE_EMISSIVE_BLOOM_MASK"
#define RENDER_PLANE_EMISSIVE_BLOOM 16

#define RENDER_PLANE_SPECULAR_MASK 17
#define SPECULAR_MASK_RENDER_TARGET "*RENDER_PLANE_SPECULAR_MASK"

//-------------------- Lighting ---------------------

/// Main game plane to which everything renders, which then is multiplied by light
/// Should not be lit directly as it is sourced for emissive bloom
#define RENDER_PLANE_UNLIT_GAME 18

#define RENDER_PLANE_O_LIGHTING 19

#define RENDER_PLANE_LIGHTING 20

/// Masks the lighting plane with turfs, so we never light up the void
/// Failing that, masks emissives and the overlay lighting plane
#define RENDER_PLANE_LIGHT_MASK 21
#define LIGHT_MASK_RENDER_TARGET "*RENDER_PLANE_LIGHT_MASK"

/// We cannot render speculars to ABOVE_LIGHTING, as then they give it alpha and end up masking things in darkness
/// So we need to render it directly to RENDER_PLANE_GAME above RENDER_PLANE_LIGHTING
#define RENDER_PLANE_SPECULAR 22

/// Things that should render ignoring lighting
#define ABOVE_LIGHTING_PLANE 23

#define WEATHER_GLOW_PLANE 24

///---------------- MISC -----------------------

///Pipecrawling images
#define PIPECRAWL_IMAGES_PLANE 25

///AI Camera Static
#define CAMERA_STATIC_PLANE 26

///Anything that wants to be part of the game plane, but also wants to draw above literally everything else
#define HIGH_GAME_PLANE 27

#define FULLSCREEN_PLANE 28

//--------------- FULLSCREEN RUNECHAT BUBBLES ------------

///Popup Chat Messages
#define RUNECHAT_PLANE 30
/// Plane for balloon text (text that fades up)
#define BALLOON_CHAT_PLANE 31

//-------------------- HUD ---------------------
// HUD layer defines
#define HUD_PLANE 40
#define ABOVE_HUD_PLANE 41

/// Plane of the "splash" icon used that shows on the lobby screen. Only render plate planes should be above this.
#define SPLASHSCREEN_PLANE 42

//-------------------- Rendering ---------------------
#define RENDER_PLANE_GAME 50
/// If fov is enabled we'll draw game to this and do shit to it
#define RENDER_PLANE_GAME_MASKED 51
/// The bit of the game plane that is let alone is sent here
#define RENDER_PLANE_GAME_UNMASKED 52

#define RENDER_PLANE_NON_GAME 55

// Only VERY special planes should be here, as they are above not just the game, but the UI planes as well.

/// Plane related to the menu when pressing Escape.
/// Needed so that we can apply a blur effect to EVERYTHING, and guarantee we are above all UI.
#define ESCAPE_MENU_PLANE 56

#define RENDER_PLANE_MASTER 57

// NOTE! You can only ever have planes greater then -10000, if you add too many with large offsets you will brick multiz
// Same can be said for large multiz maps. Tread carefully mappers
#define HIGHEST_EVER_PLANE RENDER_PLANE_MASTER
/// The range unique planes can be in
/// Try and keep this to a nice whole number, so it's easy to look at a plane var and know what's going on
#define PLANE_RANGE (HIGHEST_EVER_PLANE - LOWEST_EVER_PLANE)

// Plane master controller keys
#define PLANE_MASTERS_GAME "plane_masters_game"
#define PLANE_MASTERS_NON_MASTER "plane_masters_non_master"
#define PLANE_MASTERS_COLORBLIND "plane_masters_colorblind"

//Plane master critical flags
//Describes how different plane masters behave when they are being culled for performance reasons
/// This plane master will not go away if its layer is culled. useful for preserving effects
#define PLANE_CRITICAL_DISPLAY (1<<0)
/// This plane master will temporarially remove relays to all other planes
/// Allows us to retain the effects of a plane while cutting off the changes it makes
#define PLANE_CRITICAL_NO_RELAY (1<<1)
/// We assume this plane master has a render target starting with *, it'll be removed, forcing it to render in place
#define PLANE_CRITICAL_CUT_RENDER (1<<2)

#define PLANE_CRITICAL_FUCKO_PARALLAX (PLANE_CRITICAL_DISPLAY|PLANE_CRITICAL_NO_RELAY|PLANE_CRITICAL_CUT_RENDER)

//---------- Plane Master offsetting_flags -------------
// Describes how different plane masters behave regarding being offset
/// This plane master will not be offset itself, existing only once with an offset of 0
/// Mostly used for planes that really don't need to be duplicated, like the hud planes
#define BLOCKS_PLANE_OFFSETTING (1<<0)
/// This plane master will have its relays offset to match the highest rendering plane that matches the target
/// Required for making things like the blind fullscreen not render over runechat
#define OFFSET_RELAYS_MATCH_HIGHEST (1<<1)

/// A value of /datum/preference/numeric/multiz_performance that disables the option
#define MULTIZ_PERFORMANCE_DISABLE -1
/// We expect at most 3 layers of multiz
/// Increment this define if you make a huge map. We unit test for it too just to make it easy for you
/// If you modify this, you'll need to modify the tsx file too
#define MAX_EXPECTED_Z_DEPTH 3

//-------------------- LAYERS ---------------------

/// Used to shift all topdown layer emissives to a the game plane equivalent layers, as otherwise they render above everything else due to being KEEP_APART
#define TOPDOWN_TO_EMISSIVE_LAYER(layer) LERP(FLOOR_EMISSIVE_START_LAYER, FLOOR_EMISSIVE_END_LAYER, (layer - (TOPDOWN_LAYER + 1)) / TOPDOWN_LAYER_COUNT)

// Must be equal to the offset of the highest topdown layer
#define TOPDOWN_LAYER_COUNT 18

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
#define ABOVE_PLATING_LAYER 1.76 // generic for /datum/element/undertile
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
#define FLOOR_EMISSIVE_START_LAYER 2.09
#define FLOOR_EMISSIVE_END_LAYER 2.26
#define ABOVE_ICYOVERLAY_LAYER 2.27
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
///Anything below this layer is to be considered completely (visually) under water by the immerse layer.
#define WATER_LEVEL_LAYER 2.61
#define BLASTDOOR_LAYER 2.65
#define OPEN_DOOR_LAYER 2.7
#define DOOR_HELPER_LAYER 2.71 //keep this above OPEN_DOOR_LAYER
#define PROJECTILE_HIT_THRESHOLD_LAYER 2.75 //projectiles won't hit objects at or below this layer if possible
#define TABLE_LAYER 2.8
#define BELOW_OBJ_LAYER 2.9
#define LOW_ITEM_LAYER 2.95
//#define OBJ_LAYER 3 //For easy recordkeeping; this is a byond define
#define CLOSED_DOOR_LAYER 3.1
#define CLOSED_FIREDOOR_LAYER 3.11
#define ABOVE_OBJ_LAYER 3.2
#define SHUTTER_LAYER 3.21 // HERE BE DRAGONS
#define ABOVE_WINDOW_LAYER 3.3
#define BUTTONS_LAYER 3.31
#define CLOSED_BLASTDOOR_LAYER 3.35
#define SIGN_LAYER 3.4
#define NOT_HIGH_OBJ_LAYER 3.5
#define HIGH_OBJ_LAYER 3.6

#define BELOW_MOB_LAYER 3.7
#define LYING_MOB_LAYER 3.8
#define BEHIND_MOB_LAYER 3.9
#define VEHICLE_LAYER 3.91
#define MOB_BELOW_PIGGYBACK_LAYER 3.94
//#define MOB_LAYER 4 //For easy recordkeeping; this is a byond define
#define MOB_ABOVE_PIGGYBACK_LAYER 4.06
#define HITSCAN_PROJECTILE_LAYER 4.09
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

//---------- LIGHTING -------------

// LIGHTING_PLANE layers
// The layer of turf underlays starts at 0.01 and goes up by 0.01
// Based off the z level. No I do not remember why, should check that
/// Typically overlays, that "hide" portions of the turf underlay layer
/// I'm allotting 100 z levels before this breaks. That'll never happen
/// --Lemon
#define LIGHTING_MASK_LAYER 10
/// Misc things that draw on the turf lighting plane
/// Space, solar beams, etc
#define LIGHTING_PRIMARY_LAYER 15
/// Stuff that needs to draw above everything else on this plane
#define LIGHTING_ABOVE_ALL 20

//---------- EMISSIVES -------------
//Layering order of these is not particularly meaningful.
//Important part is the separation of the planes for control via plane_master

/// The layer you should use if you _really_ don't want an emissive overlay to be blocked.
#define EMISSIVE_LAYER_UNBLOCKABLE 9999

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
#define BLOODY_SCREEN_LAYER 30.6

#define HUD_LAYER 31
#define BUILDMOD_LAYER 31.1
#define ABOVE_HUD_LAYER 32

#define SPLASHSCREEN_LAYER 33

///Layer for screentips
#define SCREENTIP_LAYER 34

/// Layer for light overlays
#define LIGHT_DEBUG_LAYER 35

//-------------------- Radial ---------------------

#define RADIAL_BACKGROUND_LAYER 0
///1000 is an unimportant number, it's just to normalize copied layers
#define RADIAL_CONTENT_LAYER 1000
