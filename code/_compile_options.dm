#define DEBUG
#define MULTIINSTANCE
//#define TESTING

//#define DATUMVAR_DEBUGGING_MODE //Enables the ability to cache datum vars and retrieve later for debugging which vars changed.

/**
 * If defined, we will NOT defer asset generation till later in the game, and will instead do it all at once, during initiialize.
 */
//#define DO_NOT_DEFER_ASSETS

// If defined, we will compile with FULL timer debug info, rather then a limited scope
// Be warned, this increases timer creation cost by 5x
// #define TIMER_DEBUG

/// If defined, we boot up, run world.run_performance_tests() and then shut down the server
// #define PERFORMANCE_TESTS


/**
 * Uncomment the following line to compile unit tests on a local server.
 * The output will be in a test_run-[DATE].log file in the ./data folder.
 */
//#define LOCAL_UNIT_TESTS

#ifdef LOCAL_UNIT_TESTS
#define UNIT_TESTS
#define MAP_TESTS
#endif

#if defined(CIBUILDING) && defined(LOCAL_UNIT_TESTS)
#error CIBUILDING and LOCAL_UNIT_TESTS should not be enabled at the same time!
#endif

#if defined(UNIT_TESTS) || defined(MAP_TESTS)
#define TEST_RUNNER
// Ensures all early assets can actually load early
#define DO_NOT_DEFER_ASSETS
//Test at full capacity, the extra cost doesn't matter
#define TIMER_DEBUG
#endif

/// Used to find the sources of harddels, quite laggy, don't be surpised if it freezes your client for a good while
//#define REFERENCE_TRACKING
//#define REFERENCE_TRACKING_DEBUG

#ifdef REFERENCE_TRACKING
#warn Reference tracking is enabled.
/// Run a lookup on things hard deleting by default.
#define GC_FAILURE_HARD_LOOKUP
#ifdef GC_FAILURE_HARD_LOOKUP
// Ensures all early assets can actually load early
#define DO_NOT_DEFER_ASSETS
#warn Lookup on things hard deleted is enabled
/// Don't stop when searching, go till you're totally done
#define FIND_REF_NO_CHECK_TICK
#endif //ifdef GC_FAILURE_HARD_LOOKUP

// Log references in their own file, rather then in runtimes.log
#endif //ifdef REFERENCE_TRACKING

/// If this is uncommented, we set up the ref tracker to be used in a live environment
//#define REFERENCE_DOING_IT_LIVE
#ifdef REFERENCE_DOING_IT_LIVE
// compile the backend
#define REFERENCE_TRACKING
// actually look for refs
#define GC_FAILURE_HARD_LOOKUP
#endif // REFERENCE_DOING_IT_LIVE

/// Sets up the reftracker to be used locally, to hunt for hard deletions
//#define REFERENCE_TRACKING_STANDARD
#ifdef REFERENCE_TRACKING_STANDARD
// compile the backend
#define REFERENCE_TRACKING
// actually look for refs
#define GC_FAILURE_HARD_LOOKUP
// spend ALL our time searching, not just part of it
#define FIND_REF_NO_CHECK_TICK
#endif // REFERENCE_TRACKING_STANDARD

#ifdef TESTING
#warn Compiling in TESTING mode.
#endif

/**
 * If this is uncommented, will attempt to load and initialize prof.dll/libprof.so.
 * We do not ship byond-tracy. Build it yourself here: https://github.com/mafemergency/byond-tracy/
 */
//#define USE_BYOND_TRACY

#ifndef PRELOAD_RSC
/**
 * Set to:
 * 0 to allow using external resources or on-demand behaviour;
 * 1 to use the default behaviour;
 * 2 for preloading absolutely everything;
 */
#define PRELOAD_RSC 0
#endif

//#define PASSIVE_GC

#if defined(TGS_V3_API)
// TGS performs its own build of dm.exe, but includes a prepended TGS define.
#define CBT
#endif

#if defined(OPENDREAM)
	#if !defined(CIBUILDING)
		#warn You are building with OpenDream. Remember to build TGUI manually.
		#warn You can do this by running tgui-build.cmd from the bin directory.
	#endif
#else
	#if !defined(CBT) && !defined(SPACEMAN_DMM)
		#warn Building with Dream Maker is no longer supported and will result in errors.
		#warn In order to build, run BUILD.cmd in the root directory.
		#warn Consider switching to VSCode editor instead, where you can press Ctrl+Shift+B to build.
	#endif
#endif
