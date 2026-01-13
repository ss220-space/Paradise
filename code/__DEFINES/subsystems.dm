//! ## Timing subsystem
/**
 * Don't run if there is an identical unique timer active
 *
 * if the arguments to addtimer are the same as an existing timer, it doesn't create a new timer,
 * and returns the id of the existing timer
 */
#define TIMER_UNIQUE (1<<0)
///For unique timers: Replace the old timer rather then not start this one
#define TIMER_OVERRIDE (1<<1)
/**
 * Timing should be based on how timing progresses on clients, not the server.
 *
 * Tracking this is more expensive,
 * should only be used in conjunction with things that have to progress client side, such as
 * animate() or sound()
 */
#define TIMER_CLIENT_TIME (1<<2)
///Timer can be stopped using deltimer()
#define TIMER_STOPPABLE (1<<3)
///Prevents distinguishing identical timers with the wait variable.
///To be used with TIMER_UNIQUE
#define TIMER_NO_HASH_WAIT (1<<4)
///Loops the timer repeatedly until qdeleted.
///In most cases you want a subsystem instead, so don't use this unless you have a good reason.
#define TIMER_LOOP (1<<5)
///Delete the timer on parent datum Destroy() and when deltimer'd
#define TIMER_DELETE_ME (1<<6)

///Empty ID define
#define TIMER_ID_NULL -1

/// Used to trigger object removal from a processing list
#define PROCESS_KILL 26

///New should not call Initialize
#define INITIALIZATION_INSSATOMS 0
///New should call Initialize(TRUE)
#define INITIALIZATION_INNEW_MAPLOAD 2
///New should call Initialize(FALSE)
#define INITIALIZATION_INNEW_REGULAR 1
///Nothing happens
#define INITIALIZE_HINT_NORMAL 0

/**
 * call LateInitialize at the end of all atom Initialization
 *
 * The item will be added to the late_loaders list, this is iterated over after
 * initialization of subsystems is complete and calls LateInitalize on the atom
 * see [this file for the LateIntialize proc](atom.html#proc/LateInitialize)
 */
#define INITIALIZE_HINT_LATELOAD 1

///Call qdel on the atom after initialization
#define INITIALIZE_HINT_QDEL 2

///type and all subtypes should always immediately call Initialize in New()
#define INITIALIZE_IMMEDIATE(X) ##X/New(loc, ...){\
	..();\
	if(!(flags & INITIALIZED)) {\
		var/previous_initialized_value = SSatoms.initialized;\
		SSatoms.initialized = INITIALIZATION_INNEW_MAPLOAD;\
		args[1] = TRUE;\
		SSatoms.InitAtom(src, args);\
		SSatoms.initialized = previous_initialized_value;\
	}\
}

//! ### SS initialization hints
/**
 * Negative values incidate a failure or warning of some kind, positive are good.
 * 0 and 1 are unused so that TRUE and FALSE are guarenteed to be invalid values.
 */

/// Subsystem failed to initialize entirely. Print a warning, log, and disable firing.
#define SS_INIT_FAILURE -2
/// The default return value which must be overriden. Will succeed with a warning.
#define SS_INIT_NONE -1
/// Subsystem initialized sucessfully.
#define SS_INIT_SUCCESS 2
/// If your system doesn't need to be initialized (by being disabled or something)
#define SS_INIT_NO_NEED 3
/// Succesfully initialized, BUT do not announce it to players (generally to hide game mechanics it would otherwise spoil)
#define SS_INIT_NO_MESSAGE 4

// Subsystem init_order, from highest priority to lowest priority
// Subsystems shutdown in the reverse of the order they initialize in
// The numbers just define the ordering, they are meaningless otherwise.
#define INIT_ORDER_TITLE 100 // This **MUST** load first or people will se blank lobby screens
#define INIT_ORDER_SPEECH_CONTROLLER 95
#define INIT_ORDER_GARBAGE 92
#define INIT_ORDER_DBCORE 91
#define INIT_ORDER_REDIS 90
#define INIT_ORDER_BLACKBOX 56
#define INIT_ORDER_ADMIN_VERBS 55
#define INIT_ORDER_CLEANUP 54
#define INIT_ORDER_INPUT 50
#define INIT_ORDER_SOUNDS 45
#define INIT_ORDER_INSTRUMENTS 44
#define INIT_ORDER_ACHIEVEMENTS 43
#define INIT_ORDER_DONATIONS 42
#define INIT_ORDER_GREYSCALE 41
#define INIT_ORDER_GREYSCALE_PREVIEW 40
#define INIT_ORDER_EVENTS 39
#define INIT_ORDER_HOLIDAY 38
#define INIT_ORDER_JOBS 37
#define INIT_ORDER_AI_MOVEMENT 36 //We need the movement setup
#define INIT_ORDER_AI_CONTROLLERS 35 //So the controller can get the ref
#define INIT_ORDER_TICKER 30
#define INIT_ORDER_NEW_PLAYERS_INFO 31
#define INIT_ORDER_MAPPING 20
#define INIT_ORDER_HOLOMAP 10 // after map loads, but before atoms init
#define INIT_ORDER_EARLY_ASSETS 9
#define INIT_ORDER_SPATIAL_GRID 8
#define INIT_ORDER_FLUIDS 7 // Needs to be above atoms, as some atoms may want to start fluids/gases on init
#define INIT_ORDER_ATOMS 6
#define INIT_ORDER_MACHINES 5
#define INIT_ORDER_IDLENPCS 4
#define INIT_ORDER_MOBS 3
#define INIT_ORDER_ASSETS 2
#define INIT_ORDER_TIMER 1
#define INIT_ORDER_DEFAULT 0
#define INIT_ORDER_AIR -1
#define INIT_ORDER_SUN -2
#define INIT_ORDER_ICON_SMOOTHING -5
#define INIT_ORDER_OVERLAY -6
#define INIT_ORDER_XKEYSCORE -10
#define INIT_ORDER_TICKETS -11
#define INIT_ORDER_LIGHTING -20
#define INIT_ORDER_CAPITALISM -21
#define INIT_ORDER_SHUTTLE -22
#define INIT_ORDER_CARGO_QUESTS -23
#define INIT_ORDER_NIGHTSHIFT -24
#define INIT_ORDER_GAME_EVENTS -26
#define INIT_ORDER_PATH -50
#define INIT_ORDER_EXPLOSIONS -69
#define INIT_ORDER_PERSISTENCE -95
#define INIT_ORDER_STATPANELS -98
#define INIT_ORDER_DEMO -99 // To avoid a bunch of changes related to initialization being written, do this last
#define INIT_ORDER_CHAT -100 // Should be last to ensure chat remains smooth during init.

// Subsystem fire priority, from lowest to highest priority
// If the subsystem isn't listed here it's either DEFAULT or PROCESS (if it's a processing subsystem child)
#define FIRE_PRIORITY_PING 10
#define FIRE_PRIORITY_NIGHTSHIFT 10
#define FIRE_PRIORITY_IDLE_NPC 10
#define FIRE_PRIORITY_CLEANUP 10
#define FIRE_PRIORITY_TICKETS 10
#define FIRE_PRIORITY_AMBIENCE 10
#define FIRE_PRIORITY_GARBAGE 15
#define FIRE_PRIORITY_TERRAFORMING 15
#define FIRE_PRIORITY_TURFS_VISUALIZATION 15
#define FIRE_PRIORITY_DONATIONS 15
#define FIRE_PRIORITY_WET_FLOORS 20
#define FIRE_PRIORITY_AIR 20
#define FIRE_PRIORITY_NPC 20
#define FIRE_PRIORITY_NPC_MOVEMENT 21
#define FIRE_PRIORITY_NPC_ACTIONS 22
#define FIRE_PRIORITY_PATHFINDING 23
#define FIRE_PRIORITY_PROCESS 25
#define FIRE_PRIORITY_THROWING 25
#define FIRE_PRIORITY_SPACEDRIFT 30
#define FIRE_PRIORITY_SMOOTHING 35
#define FIRE_PRIORITY_OBJ 40
#define FIRE_PRIORITY_ACID 40
#define FIRE_PRIORITY_BURNING 40
#define FIRE_PRIORITY_DEFAULT 50
#define FIRE_PRIORITY_PARALLAX 65
#define FIRE_PRIORITY_FLUIDS 80
#define FIRE_PRIORITY_MOBS 100
#define FIRE_PRIORITY_ASSETS 105
#define FIRE_PRIORITY_TGUI 110
#define FIRE_PRIORITY_NEW_PLAYERS_INFO 199
#define FIRE_PRIORITY_TICKER 200
#define FIRE_PRIORITY_STATPANEL 390
#define FIRE_PRIORITY_CHAT 400
#define FIRE_PRIORITY_RUNECHAT 410 // I hate how high the fire priority on this is -aa
#define FIRE_PRIORITY_MOUSE_ENTERED 450
#define FIRE_PRIORITY_OVERLAYS 500
#define FIRE_PRIORITY_EXPLOSIONS 666
#define FIRE_PRIORITY_TIMER 700
#define FIRE_PRIORITY_SOUND_LOOPS 800
#define FIRE_PRIORITY_SPEECH_CONTROLLER 900
#define FIRE_PRIORITY_DELAYED_VERBS 950
#define FIRE_PRIORITY_INPUT 1000 // This must always always be the max highest priority. Player input must never be lost.

// SS runlevels
#define RUNLEVEL_LOBBY (1<<0)
#define RUNLEVEL_SETUP (1<<1)
#define RUNLEVEL_GAME (1<<2)
#define RUNLEVEL_POSTGAME (1<<3)
#define RUNLEVELS_DEFAULT (RUNLEVEL_SETUP|RUNLEVEL_GAME|RUNLEVEL_POSTGAME)

/// The timer key used to know how long subsystem initialization takes
#define SS_INIT_TIMER_KEY "ss_init"

// SS CPU display category flags
#define SS_CPUDISPLAY_LOW 1
#define SS_CPUDISPLAY_DEFAULT 2
#define SS_CPUDISPLAY_HIGH 3

// SSticker.current_state values
/// Game is loading
#define GAME_STATE_STARTUP 0
/// Game is loaded and in pregame lobby
#define GAME_STATE_PREGAME 1
/// Game is attempting to start the round
#define GAME_STATE_SETTING_UP 2
/// Game has round in progress
#define GAME_STATE_PLAYING 3
/// Game has round finished
#define GAME_STATE_FINISHED 4

#define SPEEDRUN_ROUND_TIME (720 SECONDS)
