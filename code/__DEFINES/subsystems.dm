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

/// Type and all subtypes should always immediately call Initialize in New()
#define INITIALIZE_IMMEDIATE(X) ##X/New(loc, ...){\
	..();\
	if(!(flags & INITIALIZED) && SSatoms) {\
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
#define FIRE_PRIORITY_DATABASE 16
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
#define FIRE_PRIORITY_INSTRUMENTS 80
#define FIRE_PRIORITY_FLUIDS 80
#define FIRE_PRIORITY_MOBS 100
#define FIRE_PRIORITY_ASSETS 105
#define FIRE_PRIORITY_TGUI 110
#define FIRE_PRIORITY_NEW_PLAYERS_INFO 199
#define FIRE_PRIORITY_TICKER 200
#define FIRE_PRIORITY_SINGULO 350
#define FIRE_PRIORITY_STATPANEL 390
#define FIRE_PRIORITY_CHAT 400
#define FIRE_PRIORITY_RUNECHAT 410 // I hate how high the fire priority on this is -aa
#define FIRE_PRIORITY_TTS 425
#define FIRE_PRIORITY_AUTOFIRE 449
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

// SS hibernation states
#define SS_NOT_HIBERNATING 0
#define SS_WAKING_UP 1
#define SS_IS_HIBERNATING 2

// Subsystem delta times or tickrates, in seconds. I.e, how many seconds in between each process() call for objects being processed by that subsystem.
// Only use these defines if you want to access some other objects processing seconds_per_tick, otherwise use the seconds_per_tick that is sent as a parameter to process()
#define SSMACHINES_DT (SSmachines.wait / 10)
#define SSMOBS_DT (SSmobs.wait / 10)
#define SSOBJ_DT (SSobj.wait / 10)

/// The change in the world's time from the subsystem's last fire in seconds.
#define DELTA_WORLD_TIME(ss) ((world.time - ss.last_fire) * 0.1)

/// Same as DELTA_WORLD_TIME but we ignore time spent hibernating
#define DELTA_WORLD_TIME_WITHOUT_HIBERNATION(ss) ss.hibernation_state ? ss.wait : DELTA_WORLD_TIME(ss)

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
