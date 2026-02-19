GLOBAL_VAR_INIT(total_runtimes, GLOB.total_runtimes || 0)
GLOBAL_VAR_INIT(total_runtimes_skipped, 0)

// The ifdef needs to be down here, since the error viewer references total_runtimes
#ifdef DEBUG
#define ERROR_USEFUL_LEN 2

/world/Error(exception/E, datum/e_src)
	GLOB.total_runtimes++

	if(!istype(E)) // Something threw an unusual exception
		log_world("\[[time_stamp()]] Uncaught exception: [E]")
		return ..()

	//this is snowflake because of a byond bug (ID:2306577), do not attempt to call non-builtin procs in this if
	if(copytext(E.name, 1, 32) == "Maximum recursion level reached")//32 == length() of that string + 1
		//log to world while intentionally triggering the byond bug.
		log_world("\[[time_stamp()]] runtime error: [E.name]\n[E.desc]")
		//if we got to here without silently ending, the byond bug has been fixed.
		log_world("\[[time_stamp()]] The bug with recursion runtimes has been fixed. Please remove the snowflake check from world/Error in [__FILE__]:[__LINE__]")
		return //this will never happen.

	var/static/regex/stack_workaround = regex("[WORKAROUND_IDENTIFIER](.+?)[WORKAROUND_IDENTIFIER]")
	var/static/list/error_last_seen = list()
	var/static/list/error_cooldown = list() /* Error_cooldown items will either be positive(cooldown time) or negative(silenced error)
												If negative, starts at -1, and goes down by 1 each time that error gets skipped*/

	if(!stack_workaround) // A runtime is occurring too early in start-up initialization
		return ..()

	if(stack_workaround.Find(E.name))
		var/list/data = json_decode(stack_workaround.group[1])
		E.file = data[1]
		E.line = data[2]
		E.name = stack_workaround.Replace(E.name, "")

	var/erroruid = "[E.file][E.line]"
	var/last_seen = error_last_seen[erroruid]
	var/cooldown = error_cooldown[erroruid] || 0

	if(last_seen == null)
		error_last_seen[erroruid] = world.time
		last_seen = world.time

	if(cooldown < 0)
		error_cooldown[erroruid]-- //Used to keep track of skip count for this error
		GLOB.total_runtimes_skipped++
		return //Error is currently silenced, skip handling it

	//Handle cooldowns and silencing spammy errors
	var/silencing = FALSE

	// We can runtime before config is initialized because BYOND initialize objs/map before a bunch of other stuff happens.
	// This is a bunch of workaround code for that. Hooray!
	var/configured_error_cooldown
	var/configured_error_limit
	var/configured_error_silence_time
	if(config?.entries)
		configured_error_cooldown = CONFIG_GET(number/error_cooldown)
		configured_error_limit = CONFIG_GET(number/error_limit)
		configured_error_silence_time = CONFIG_GET(number/error_silence_time)
	else
		var/datum/config_entry/CE = /datum/config_entry/number/error_cooldown
		configured_error_cooldown = initial(CE.default)
		CE = /datum/config_entry/number/error_limit
		configured_error_limit = initial(CE.default)
		CE = /datum/config_entry/number/error_silence_time
		configured_error_silence_time = initial(CE.default)

	//Each occurence of a unique error adds to its cooldown time...
	cooldown = max(0, cooldown - (world.time - last_seen)) + configured_error_cooldown
	// ... which is used to silence an error if it occurs too often, too fast
	if(cooldown > configured_error_cooldown * configured_error_limit)
		cooldown = -1
		silencing = TRUE
		spawn(0)
			usr = null
			sleep(configured_error_silence_time)
			var/skipcount = abs(error_cooldown[erroruid]) - 1
			error_cooldown[erroruid] = 0
			if(skipcount > 0)
				log_world("\[[time_stamp()]] Skipped [skipcount] runtimes in [E.file],[E.line].")
				GLOB.error_cache.log_error(E, skip_count = skipcount)

	error_last_seen[erroruid] = world.time
	error_cooldown[erroruid] = cooldown

	// This line will log a runtime summary to a file which can be publicly distributed without sending player data
	log_runtime_summary("Runtime in [E.file],[E.line]: [E]")

	var/list/srcinfo = null
	var/list/usrinfo = null
	var/locinfo
	if(istype(e_src))
		srcinfo = list("  src: [datum_info_line(e_src)]")
		locinfo = atom_loc_line(e_src)
		if(locinfo)
			srcinfo += "  src.loc: [locinfo]"
	if(istype(usr))
		usrinfo = list("  usr: [key_name(usr)]")
		locinfo = atom_loc_line(usr)
		if(locinfo)
			usrinfo += "  usr.loc: [locinfo]"
	// The proceeding mess will almost definitely break if error messages are ever changed
	var/list/splitlines = splittext(E.desc, "\n")
	var/list/desclines = list()
	if(LAZYLEN(splitlines) > ERROR_USEFUL_LEN) // If there aren't at least three lines, there's no info
		for(var/line in splitlines)
			if(LAZYLEN(line) < 3 || findtext(line, "source file:") || findtext(line, "usr.loc:"))
				continue
			if(findtext(line, "usr:"))
				if(usrinfo)
					desclines.Add(usrinfo)
					usrinfo = null
				continue // Our usr info is better, replace it
			if(srcinfo)
				if(findtext(line, "src.loc:"))
					continue
				if(findtext(line, "src:"))
					desclines.Add(srcinfo)
					srcinfo = null
					continue
			if(copytext(line, 1, 3) != "  ")//3 == length("  ") + 1
				desclines += ("  " + line) // Pad any unpadded lines, so they look pretty
			else
				desclines += line
	if(srcinfo) // If these aren't null, they haven't been added yet
		desclines.Add(srcinfo)
	if(usrinfo)
		desclines.Add(usrinfo)
	if(silencing)
		desclines += "  (This error will now be silenced for [DisplayTimeText(configured_error_silence_time)])"

	// Now to actually output the error info...
	log_world("\[[time_stamp()]] Runtime in [E.file],[E.line]: [E]")
	log_runtime_txt("Runtime in [E.file],[E.line]: [E]")
	for(var/line in desclines)
		log_world(line)
		log_runtime_txt(line)
	if(GLOB.error_cache)
		GLOB.error_cache.log_error(E, desclines, e_src = e_src)

#undef ERROR_USEFUL_LEN
#endif

/proc/log_runtime(exception/e, datum/e_src, extra_info)
	if(!istype(e))
		world.Error(e, e_src)
		return

	if(extra_info)
		// Adding extra info adds two newlines, because parsing runtimes is funky
		if(islist(extra_info))
			e.desc = "  [jointext(extra_info, "\n  ")]\n\n" + e.desc
		else
			e.desc = "  [extra_info]\n\n" + e.desc

	world.Error(e, e_src)
