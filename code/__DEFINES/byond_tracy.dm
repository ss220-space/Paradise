// Implements https://github.com/mafemergency/byond-tracy
// Client https://github.com/wolfpld/tracy
// As of now, only 0.8.2 is supported as a client, this might change in the future however

// In case you need to start the capture as soon as the server boots, uncomment the following lines and recompile:

// /world/New()
// 	prof_init()
// 	. = ..()

#ifndef PROF
// Default automatic PROF detection.
// On Windows, looks in the standard places for `prof.dll`.
// On Linux, looks in `.`, `$LD_LIBRARY_PATH`, and `~/.byond/bin` for either of
// `libprof.so` (preferred) or `prof` (old).

/* This comment bypasses grep checks */ /var/__prof

/proc/__detect_prof()
	if (world.system_type == UNIX)
		if (fexists("./libprof.so"))
			// No need for LD_LIBRARY_PATH badness.
			return __prof = "./libprof.so"
		else if (fexists("./prof"))
			// Old dumb filename.
			return __prof = "./prof"
		else if (fexists("[world.GetConfig("env", "HOME")]/.byond/bin/prof"))
			// Old dumb filename in `~/.byond/bin`.
			return __prof = "prof"
		else
			// It's not in the current directory, so try others
			return __prof = "libprof.so"
	else
		return __prof = "prof"

#define PROF (__prof || __detect_prof())
#endif

// Handle 515 call() -> call_ext() changes
#if DM_VERSION >= 515
#define PROF_CALL call_ext
#else
#define PROF_CALL call
#endif

GLOBAL_VAR_INIT(profiler_enabled, FALSE)

/client/proc/profiler_start()
	set name = "Tracy Profiler Start"
	set category = "Debug"
	set desc = "Starts the tracy profiler and writes the data to the server's data directory."

	if(holder && holder.rights != R_HOST)
		return

	switch(alert("Are you sure? Tracy will remain active until the server restarts.", "Tracy Init", "No", "Yes"))
		if("Yes")
			prof_init()

/client/proc/profiler_stop()
	set name = "Tracy Profiler Stop"
	set category = "Debug"
	set desc = "Stop the tracy profiler."

	if(holder && holder.rights != R_HOST)
		return

	switch(alert("Are you sure?", "Tracy Stop", "No", "Yes"))
		if("Yes")
			prof_stop()

/**
 * Starts Tracy
 */
/proc/prof_init()
	var/init = PROF_CALL(PROF, "init")()
	if("0" != init) CRASH("[PROF] init error: [init]")
	GLOB.profiler_enabled = TRUE

/**
 * Stops Tracy
 */
/proc/prof_stop()
	if(!GLOB.profiler_enabled)
		return

	var/destroy = PROF_CALL(PROF, "destroy")()
	if("0" != destroy) CRASH("[PROF] destroy error: [destroy]")
	GLOB.profiler_enabled = FALSE
