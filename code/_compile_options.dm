#define DEBUG
//#define TESTING

// If defined, we will NOT defer asset generation till later in the game, and will instead do it all at once, during initiialize
//#define DO_NOT_DEFER_ASSETS
// Uncomment the following line to compile unit tests.
// #define UNIT_TESTS


#ifdef CIBUILDING
#define UNIT_TESTS
#endif

///Used to find the sources of harddels, quite laggy, don't be surpised if it freezes your client for a good while
//#define REFERENCE_TRACKING
#ifdef REFERENCE_TRACKING
#warn Reference tracking is enabled
///Run a lookup on things hard deleting by default.
//#define GC_FAILURE_HARD_LOOKUP
#ifdef GC_FAILURE_HARD_LOOKUP
//Ensures all early assets can actually load early
#define DO_NOT_DEFER_ASSETS
#warn Lookup on things hard deleted is enabled
///Don't stop when searching, go till you're totally done
#define FIND_REF_NO_CHECK_TICK
#endif //ifdef GC_FAILURE_HARD_LOOKUP

// Log references in their own file, rather then in runtimes.log
#endif //ifdef REFERENCE_TRACKING

#ifdef TESTING
#warn Testing mode is enabled

#endif

#define IS_MODE_COMPILED(MODE) (ispath(text2path("/datum/game_mode/"+(MODE))))

//Don't set this very much higher then 1024 unless you like inviting people in to dos your server with message spam
#define MAX_MESSAGE_LEN 1024
#define MAX_PAPER_MESSAGE_LEN 4096
#define MAX_PAPER_FIELDS 50
#define MAX_BOOK_MESSAGE_LEN 9216
#define MAX_NAME_LEN 50 	//diona names can get loooooooong

/// Removes characters incompatible with file names.
#define SANITIZE_FILENAME(text) (GLOB.filename_forbidden_chars.Replace(text, ""))

//Update this whenever you need to take advantage of more recent byond features
#define MIN_COMPILER_VERSION 513
#define MIN_COMPILER_BUILD 1514
#if DM_VERSION < MIN_COMPILER_VERSION || DM_BUILD < MIN_COMPILER_BUILD
//Don't forget to update this part
#error Your version of BYOND is too out-of-date to compile this project. Go to https://secure.byond.com/download and update.
#error You need version 513.1514 or higher
#endif

// Macros that must exist before world.dm
// #define to_chat to_chat_filename=__FILE__;to_chat_line=__LINE__;to_chat_src=src;__to_chat

// If this is uncommented, will attempt to load and initialize prof.dll/libprof.so.
// We do not ship byond-tracy. Build it yourself here: https://github.com/mafemergency/byond-tracy/
// #define USE_BYOND_TRACY

#ifndef PRELOAD_RSC //set to:
#define PRELOAD_RSC 0 // 0 to allow using external resources or on-demand behaviour;
#endif // 1 to use the default behaviour;
	   // 2 for preloading absolutely everything;
