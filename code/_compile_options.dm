#define DEBUG
#define MULTIINSTANCE
//#define TESTING

/**
 * If defined, we will NOT defer asset generation till later in the game, and will instead do it all at once, during initiialize.
 */
//#define DO_NOT_DEFER_ASSETS

/**
 * Enables the ability to cache datum vars and retrieve later for debugging which vars changed.
 */
//#define DATUMVAR_DEBUGGING_MODE

/**
 * Uncomment the following line to compile unit tests on a local server.
 * The output will be in a test_run-[DATE].log file in the ./data folder.
 */
#define LOCAL_UNIT_TESTS

#ifdef LOCAL_UNIT_TESTS
#define UNIT_TESTS
#endif

#if defined(CIBUILDING) && defined(LOCAL_UNIT_TESTS)
#error CIBUILDING and LOCAL_UNIT_TESTS should not be enabled at the same time!
#endif

#if defined(UNIT_TESTS) || defined(MAP_TEST)
#define TEST_RUNNER
#endif

#ifdef TESTING
#define DATUMVAR_DEBUGGING_MODE

/// Enables update_appearance "relevence" tracking
/// This allows us to check which update_appearance procs are actually doing anything. Good thing to look in on once a year or so
/// You'll need to run a two regexes/search and replaces to make it work
/// First, one to convert type refs (PROC_REF.*)(update_appearance\)) -> $1_$2
/// Second, one to convert definitions /update_appearance\( -> /_update_appearance(
/// We'll use another define to convert uses of the proc over. That'll be all
// #define APPEARANCE_SUCCESS_TRACKING

///Used to find the sources of harddels, quite laggy, don't be surprised if it freezes your client for a good while
//#define REFERENCE_TRACKING
#ifdef REFERENCE_TRACKING

///Used for doing dry runs of the reference finder, to test for feature completeness
///Slightly slower, higher in memory. Just not optimal
//#define REFERENCE_TRACKING_DEBUG

///Skips over a bunch of types that are "unlikely" to have any hanging refs,
///MASSIVELY speeding up finding references. Relatively speaking. The reftracker is still not very fast.
//#define FAST_REFERENCE_TRACKING

///Run a lookup on things hard deleting by default.
//#define GC_FAILURE_HARD_LOOKUP
#ifdef GC_FAILURE_HARD_LOOKUP
///Don't stop when searching, go till you're totally done
#define FIND_REF_NO_CHECK_TICK
#endif //ifdef GC_FAILURE_HARD_LOOKUP
#endif //ifdef REFERENCE_TRACKING

/*
* Enables debug messages for every single reaction step. This is 1 message per 0.5s for a SINGLE reaction. Useful for tracking down bugs/asking me for help in the main reaction handiler (equilibrium.dm).
*
* * Requires TESTING to be defined to work.
*/
//#define REAGENTS_TESTING

// Displays static object lighting updates
// Also enables some debug vars on sslighting that can be used to modify
// How extensively we prune lighting corners to update
#define VISUALIZE_LIGHT_UPDATES

#define VISUALIZE_ACTIVE_TURFS //Highlights atmos active turfs in green
#define TRACK_MAX_SHARE //Allows max share tracking, for use in the atmos debugging ui
#endif //ifdef TESTING

/// If this is uncommented, we set up the ref tracker to be used in a live environment
/// And to log events to [log_dir]/gc_debug.log
//#define REFERENCE_DOING_IT_LIVE
#ifdef REFERENCE_DOING_IT_LIVE
// compile the backend
#define REFERENCE_TRACKING
// actually look for refs
#define GC_FAILURE_HARD_LOOKUP
// use fast reftracking
#define FAST_REFERENCE_TRACKING
#endif // REFERENCE_DOING_IT_LIVE

/// Sets up the reftracker to be used locally, to hunt for hard deletions
/// Errors are logged to [log_dir]/gc_debug.log
//#define REFERENCE_TRACKING_STANDARD
#ifdef REFERENCE_TRACKING_STANDARD
// compile the backend
#define REFERENCE_TRACKING
// actually look for refs
#define GC_FAILURE_HARD_LOOKUP
// spend ALL our time searching, not just part of it
#define FIND_REF_NO_CHECK_TICK
#endif // REFERENCE_TRACKING_STANDARD

/**
 * If this is uncommented, will attempt to load and initialize prof.dll/libprof.so.
 * We do not ship byond-tracy. Build it yourself here: https://github.com/mafemergency/byond-tracy/
 */
//#define USE_BYOND_TRACY

/**
 * If defined, we will compile with FULL timer debug info, rather then a limited scope
 * Be warned, this increases timer creation cost by 5x
 */
//#define TIMER_DEBUG

#ifndef PRELOAD_RSC
/**
 * Set to:
 * 0 to allow using external resources or on-demand behaviour;
 * 1 to use the default behaviour;
 * 2 for preloading absolutely everything;
 */
#define PRELOAD_RSC 0
#endif

// Additional code for the above flags.
#ifdef TESTING
#warn Compiling in TESTING mode.
#endif

#if defined(UNIT_TESTS)
//Hard del testing defines
#define REFERENCE_TRACKING
#define REFERENCE_TRACKING_DEBUG
#define FIND_REF_NO_CHECK_TICK
#define GC_FAILURE_HARD_LOOKUP
//Ensures all early assets can actually load early
#define DO_NOT_DEFER_ASSETS
//Test at full capacity, the extra cost doesn't matter
#define TIMER_DEBUG
#endif

#if defined(TGS_V3_API) || defined(PARADISE_PRODUCTION_HARDWARE)
// TGS performs its own build of dm.exe, but includes a prepended TGS define.
#define CBT
#endif

/// Runs the game in "map test mode"
/// Map test mode prevents common annoyances, such as rats from spawning and random light fixture breakage,
/// so mappers can test important facets of their map (working powernet, atmos, good light coverage) without these interfering.
// #define MAP_TEST

#ifdef MAP_TEST
#warn Compiling in MAP_TEST mode. Certain game mechanics will be disabled.
#endif
