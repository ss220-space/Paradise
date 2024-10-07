//Timing subsystem
//Don't run if there is an identical unique timer active
//if the arguments to addtimer are the same as an existing timer, it doesn't create a new timer, and returns the id of the existing timer
#define TIMER_UNIQUE		(1<<0)
//For unique timers: Replace the old timer rather then not start this one
#define TIMER_OVERRIDE		(1<<1)
//Timing should be based on how timing progresses on clients, not the sever.
//	tracking this is more expensive,
//	should only be used in conjuction with things that have to progress client side, such as animate() or sound()
#define TIMER_CLIENT_TIME	(1<<2)
//Timer can be stopped using deltimer()
#define TIMER_STOPPABLE		(1<<3)
//To be used with TIMER_UNIQUE
//prevents distinguishing identical timers with the wait variable
#define TIMER_NO_HASH_WAIT  (1<<4)

//Loops the timer repeatedly until qdeleted
//In most cases you want a subsystem instead
#define TIMER_LOOP			(1<<5)

///Delete the timer on parent datum Destroy() and when deltimer'd
#define TIMER_DELETE_ME 	(1<<6)

#define TIMER_ID_NULL -1

//For servers that can't do with any additional lag, set this to none in flightpacks.dm in subsystem/processing.
#define FLIGHTSUIT_PROCESSING_NONE 0
#define FLIGHTSUIT_PROCESSING_FULL 1

#define INITIALIZATION_INSSATOMS 0	//New should not call Initialize
#define INITIALIZATION_INNEW_MAPLOAD 2	//New should call Initialize(TRUE)
#define INITIALIZATION_INNEW_REGULAR 1	//New should call Initialize(FALSE)

#define INITIALIZE_HINT_NORMAL 0    //Nothing happens
#define INITIALIZE_HINT_LATELOAD 1  //Call LateInitialize
#define INITIALIZE_HINT_QDEL 2  //Call qdel on the atom

//type and all subtypes should always call Initialize in New()
#define INITIALIZE_IMMEDIATE(X) ##X/New(loc, ...){\
    ..();\
    if(!(flags & INITIALIZED)) {\
        args[1] = TRUE;\
        SSatoms.InitAtom(src, args);\
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
#define INIT_ORDER_SPEECH_CONTROLLER 19
#define INIT_ORDER_GARBAGE 18
#define INIT_ORDER_DBCORE 17
#define INIT_ORDER_BLACKBOX 16
#define INIT_ORDER_CLEANUP 15
#define INIT_ORDER_INPUT 14
#define INIT_ORDER_SOUNDS 13
#define INIT_ORDER_INSTRUMENTS 12
#define INIT_ORDER_EVENTS 11
#define INIT_ORDER_HOLIDAY 10
#define INIT_ORDER_JOBS 9
#define INIT_ORDER_TICKER 8
#define INIT_ORDER_MAPPING 7
#define INIT_ORDER_EARLY_ASSETS 6
#define INIT_ORDER_ATOMS 5
#define INIT_ORDER_MACHINES 4
#define INIT_ORDER_IDLENPCS 3
#define INIT_ORDER_MOBS 2
#define INIT_ORDER_TIMER 1
#define INIT_ORDER_DEFAULT 0
#define INIT_ORDER_AIR -1
#define INIT_ORDER_SUN -2
#define INIT_ORDER_MINIMAP -3
#define INIT_ORDER_ASSETS -4
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
#define INIT_ORDER_PERSISTENCE -95
#define INIT_ORDER_STATPANELS -98
#define INIT_ORDER_DEMO	-99 // To avoid a bunch of changes related to initialization being written, do this last
#define INIT_ORDER_CHAT -100 // Should be last to ensure chat remains smooth during init.

// Subsystem fire priority, from lowest to highest priority
// If the subsystem isn't listed here it's either DEFAULT or PROCESS (if it's a processing subsystem child)

#define FIRE_PRIORITY_PING         	10
#define FIRE_PRIORITY_NIGHTSHIFT	10
#define FIRE_PRIORITY_IDLE_NPC		10
#define FIRE_PRIORITY_CLEANUP		10
#define FIRE_PRIORITY_TICKETS		10
#define FIRE_PRIORITY_AMBIENCE		10
#define FIRE_PRIORITY_GARBAGE		15
#define FIRE_PRIORITY_WET_FLOORS	20
#define FIRE_PRIORITY_AIR			20
#define FIRE_PRIORITY_NPC			20
#define FIRE_PRIORITY_PATHFINDING	23
#define FIRE_PRIORITY_PROCESS		25
#define FIRE_PRIORITY_THROWING		25
#define FIRE_PRIORITY_SPACEDRIFT	30
#define FIRE_PRIORITY_SMOOTHING		35
#define FIRE_PRIORITY_OBJ			40
#define FIRE_PRIORITY_ACID			40
#define FIRE_PRIORITY_BURNING		40
#define FIRE_PRIORITY_DEFAULT		50
#define FIRE_PRIORITY_PARALLAX		65
#define FIRE_PRIORITY_MOBS			100
#define FIRE_PRIORITY_ASSETS 		105
#define FIRE_PRIORITY_TGUI			110
#define FIRE_PRIORITY_TICKER		200
#define FIRE_PRIORITY_STATPANEL		390
#define FIRE_PRIORITY_CHAT 			400
#define FIRE_PRIORITY_RUNECHAT		410 // I hate how high the fire priority on this is -aa
#define FIRE_PRIORITY_OVERLAYS		500
#define FIRE_PRIORITY_TIMER			700
#define FIRE_PRIORITY_SPEECH_CONTROLLER 900
#define FIRE_PRIORITY_DELAYED_VERBS 950
#define FIRE_PRIORITY_INPUT			1000 // This must always always be the max highest priority. Player input must never be lost.


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

// Truly disgusting, TG. Truly disgusting.
//! ## Overlays subsystem

#define POST_OVERLAY_CHANGE(changed_on) \
	if(length(changed_on.overlays) >= MAX_ATOM_OVERLAYS) { \
		var/text_lays = overlays2text(changed_on.overlays); \
		stack_trace("Too many overlays on [changed_on.type] - [length(changed_on.overlays)], refusing to update and cutting.\
			\n What follows is a printout of all existing overlays at the time of the overflow \n[text_lays]"); \
		changed_on.overlays.Cut(); \
		changed_on.add_overlay(mutable_appearance('icons/Testing/greyscale_error.dmi')); \
	} \
	if(alternate_appearances) { \
		for(var/I in changed_on.alternate_appearances){\
			var/datum/atom_hud/alternate_appearance/AA = changed_on.alternate_appearances[I];\
			if(AA.transfer_overlays){\
				AA.copy_overlays(changed_on, TRUE);\
			}\
		} \
	}\
	if(isturf(changed_on)){SSdemo.mark_turf(changed_on);}\
	if(isobj(changed_on) || ismob(changed_on)){SSdemo.mark_dirty(changed_on);}\

