GLOBAL_LIST(twitch_censor_list)
GLOBAL_LIST_EMPTY(overflow_whitelist)

/datum/controller/configuration
	name = "Configuration"

	var/directory = "config"

	var/warned_deprecated_configs = FALSE
	var/hiding_entries_by_type = TRUE //Set for readability, admins can set this to FALSE if they want to debug it
	var/list/entries
	var/list/entries_by_type

	var/list/maplist
	var/datum/map_config/defaultmap

	var/list/modes // allowed modes
	var/list/gamemode_cache
	var/list/votable_modes // votable modes
	var/list/mode_names
	var/list/mode_reports
	var/list/mode_false_report_weight
	var/list/mode_required_players
	var/list/probabilities

	var/motd
	var/policy

	/// If the configuration is loaded
	var/loaded = FALSE

	/// A list of configuration errors that occurred during load
	var/static/list/configuration_errors


/datum/controller/configuration/proc/admin_reload()
	if(IsAdminAdvancedProcCall())
		return
	log_admin("[key_name_admin(usr)] has forcefully reloaded the configuration from disk.")
	message_admins("[key_name_admin(usr)] has forcefully reloaded the configuration from disk.")
	full_wipe()
	Load(world.params[OVERRIDE_CONFIG_DIRECTORY_PARAMETER])

/datum/controller/configuration/proc/Load(_directory)
	if(IsAdminAdvancedProcCall()) //If admin proccall is detected down the line it will horribly break everything.
		return
	if(_directory)
		directory = _directory
	if(entries)
		CRASH("/datum/controller/configuration/Load() called more than once!")
	configuration_errors ||= list()
	InitEntries()

	//Note: `$include`s are supported. Feel free to use them.
	var/list/configs = list("game_options.txt", "dbconfig.txt", "config.txt", "emojis.txt", "resources.txt", "music.txt")
	for(var/I in configs)
		if(fexists("[directory]/[I]"))
			for(var/J in configs)
				LoadEntries(J)
			break

	LoadModes()

	load_overflow_whitelist()

	load_twitch_censor_list()

	loaded = TRUE

	if (Master)
		Master.OnConfigLoad()
	process_config_errors()

/datum/controller/configuration/proc/load_overflow_whitelist()
	if(fexists("[directory]/ofwhitelist.txt"))
		var/list/Lines = file2list("[directory]/ofwhitelist.txt")
		for(var/t in Lines)
			if(!t)
				continue
			t = trim(t)
			if(length(t) == 0)
				continue
			else if(copytext(t, 1, 2) == "#")
				continue

			GLOB.overflow_whitelist += t

/datum/controller/configuration/proc/full_wipe()
	if(IsAdminAdvancedProcCall())
		return
	entries_by_type.Cut()
	QDEL_LIST_ASSOC_VAL(entries)
	entries = null
	configuration_errors?.Cut()

/datum/controller/configuration/Destroy()
	full_wipe()
	config = null

	return ..()

/datum/controller/configuration/proc/log_config_error(error_message)
	configuration_errors += error_message
	log_config(error_message)

/datum/controller/configuration/proc/process_config_errors()
	if(!CONFIG_GET(flag/config_errors_runtime))
		return
	for(var/error_message in configuration_errors)
		stack_trace(error_message)

/datum/controller/configuration/proc/InitEntries()
	var/list/_entries = list()
	entries = _entries
	var/list/_entries_by_type = list()
	entries_by_type = _entries_by_type

	for(var/I in typesof(/datum/config_entry)) //typesof is faster in this case
		var/datum/config_entry/E = I
		if(initial(E.abstract_type) == I)
			continue
		E = new I
		var/esname = E.name
		var/datum/config_entry/test = _entries[esname]
		if(test)
			log_config_error("Error: [test.type] has the same name as [E.type]: [esname]! Not initializing [E.type]!")
			qdel(E)
			continue
		_entries[esname] = E
		_entries_by_type[I] = E

/datum/controller/configuration/proc/RemoveEntry(datum/config_entry/CE)
	entries -= CE.name
	entries_by_type -= CE.type

/datum/controller/configuration/proc/LoadEntries(filename, list/stack = list())
	if(IsAdminAdvancedProcCall())
		return

	var/filename_to_test = world.system_type == MS_WINDOWS ? lowertext(filename) : filename
	if(filename_to_test in stack)
		log_config_error("Warning: Config recursion detected ([english_list(stack)]), breaking!")
		return
	stack = stack + filename_to_test

	log_config("Loading config file [filename]...")
	var/list/lines = world.file2list("[directory]/[filename]")
	var/list/_entries = entries
	for(var/L in lines)
		L = trim(L)
		if(!L)
			continue

		var/firstchar = L[1]
		if(firstchar == "#")
			continue

		var/lockthis = firstchar == "@"
		if(lockthis)
			L = copytext(L, length(firstchar) + 1)

		var/pos = findtext(L, " ")
		var/entry = null
		var/value = null

		if(pos)
			entry = lowertext(copytext(L, 1, pos))
			value = copytext(L, pos + length(L[pos]))
		else
			entry = lowertext(L)

		if(!entry)
			continue

		if(entry == "$include")
			if(!value)
				log_config_error("Warning: Invalid $include directive: [value]")
			else
				LoadEntries(value, stack)
				++.
			continue

		// Reset directive, used for setting a config value back to defaults. Useful for string list config types
		if (entry == "$reset")
			var/datum/config_entry/resetee = _entries[lowertext(value)]
			if (!value || !resetee)
				log_config_error("Warning: invalid $reset directive: [value]")
				continue
			resetee.set_default()
			log_config("Reset configured value for [value] to original defaults")
			continue

		var/datum/config_entry/E = _entries[entry]
		if(!E)
			log_config_error("Unknown setting in configuration: '[entry]'")
			continue

		if(lockthis)
			E.protection |= CONFIG_ENTRY_LOCKED

		if(E.deprecated_by)
			var/datum/config_entry/new_ver = entries_by_type[E.deprecated_by]
			var/new_value = E.DeprecationUpdate(value)
			var/good_update = istext(new_value)
			log_config("Entry [entry] is deprecated and will be removed soon. Migrate to [new_ver.name]![good_update ? " Suggested new value is: [new_value]" : ""]")
			if(!warned_deprecated_configs)
				DelayedMessageAdmins("This server is using deprecated configuration settings. Please check the logs and update accordingly.")
				warned_deprecated_configs = TRUE
			if(good_update)
				value = new_value
				E = new_ver
			else
				warning("[new_ver.type] is deprecated but gave no proper return for DeprecationUpdate()")

		var/validated = E.ValidateAndSet(value)
		if(!validated)
			var/log_message = "Failed to validate setting \"[value]\" for [entry]"
			log_config(log_message)
			stack_trace(log_message)
		else
			if(E.modified && !E.dupes_allowed && E.resident_file == filename)
				log_config_error("Duplicate setting for [entry] ([value], [E.resident_file]) detected! Using latest.")

		E.resident_file = filename

		if(validated)
			E.modified = TRUE

	++.

/datum/controller/configuration/can_vv_get(var_name)
	return (var_name != NAMEOF(src, entries_by_type) || !hiding_entries_by_type) && ..()

/datum/controller/configuration/vv_edit_var(var_name, var_value)
	var/list/banned_edits = list(NAMEOF(src, entries_by_type), NAMEOF(src, entries), NAMEOF(src, directory))
	return !(var_name in banned_edits) && ..()

/datum/controller/configuration/stat_entry(msg)
	msg = "Edit"
	return ..()

/datum/controller/configuration/proc/Get(entry_type)
	var/datum/config_entry/E = entry_type
	var/entry_is_abstract = initial(E.abstract_type) == entry_type
	if(entry_is_abstract)
		CRASH("Tried to retrieve an abstract config_entry: [entry_type]")
	E = entries_by_type[entry_type]
	if(!E)
		CRASH("Missing config entry for [entry_type]!")
	if((E.protection & CONFIG_ENTRY_HIDDEN) && IsAdminAdvancedProcCall() && GLOB.LastAdminCalledProc == "Get" && GLOB.LastAdminCalledTargetUID == "[UID()]")
		log_admin_private("Config access of [entry_type] attempted by [key_name(usr)]")
		return
	return E.config_entry_value

/datum/controller/configuration/proc/Set(entry_type, new_val)
	var/datum/config_entry/E = entry_type
	var/entry_is_abstract = initial(E.abstract_type) == entry_type
	if(entry_is_abstract)
		CRASH("Tried to set an abstract config_entry: [entry_type]")
	E = entries_by_type[entry_type]
	if(!E)
		CRASH("Missing config entry for [entry_type]!")
	if((E.protection & CONFIG_ENTRY_LOCKED) && IsAdminAdvancedProcCall() && GLOB.LastAdminCalledProc == "Set" && GLOB.LastAdminCalledTargetUID == "[UID()]")
		log_admin_private("Config rewrite of [entry_type] to [new_val] attempted by [key_name(usr)]")
		return
	return E.ValidateAndSet("[new_val]")

/datum/controller/configuration/proc/pick_mode(mode_name)
	for(var/T in gamemode_cache)
		var/datum/game_mode/M = T
		if(initial(M.config_tag) && initial(M.config_tag) == mode_name)
			return new T()
	return new /datum/game_mode/extended()

/datum/controller/configuration/proc/get_runnable_modes()
	var/list/datum/game_mode/runnable_modes = new
	for(var/T in subtypesof(/datum/game_mode))
		var/datum/game_mode/M = new T()
//		log_debug(world, "DEBUG: [T], tag=[M.config_tag], prob=[probabilities[M.config_tag]]")
		if(!(M.config_tag in modes))
			qdel(M)
			continue
		if(probabilities[M.config_tag]<=0)
			qdel(M)
			continue
		if(M.can_start())
			runnable_modes[M] = probabilities[M.config_tag]
//			log_debug(world, "DEBUG: runnable_mode\[[runnable_modes.len]\] = [M.config_tag]")
	return runnable_modes

/datum/controller/configuration/proc/load_twitch_censor_list()
	var/list/twitch_censor_list = list()
	if(fexists("[directory]/twitch_censor.txt"))
		var/list/lines = file2list("[directory]/twitch_censor.txt")
		for(var/L in lines)
			L = trim(L)
			if(!L)
				continue

			var/firstchar = L[1]
			if(firstchar == "#")
				continue
			var/pos = findtext(L, "=")
			var/entry = null
			var/value = null
			if(pos)
				entry = copytext(L, 1, pos)
				value = copytext(L, pos + length(L[pos]))
			else
				continue

			if(!entry)
				continue

			twitch_censor_list[entry] = value

		GLOB.twitch_censor_list = twitch_censor_list
		return TRUE

	log_config("[directory]/twitch_censor.txt does not exist, twitch censoring disabled")
	return FALSE


//Message admins when you can.
/datum/controller/configuration/proc/DelayedMessageAdmins(text)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(message_admins), text), 0)


/datum/controller/configuration/proc/LoadModes()
	gamemode_cache = typecacheof(/datum/game_mode, TRUE)
	modes = list()
	mode_names = list()
	votable_modes = list()
	mode_required_players = list()
	probabilities = list()
	var/list/probabilities_conf = CONFIG_GET(keyed_list/probability)
	var/list/minplayers_conf = CONFIG_GET(keyed_list/minplayers)
	for(var/T in gamemode_cache)
		var/datum/game_mode/M = T

		if(initial(M.config_tag))
			if(!(initial(M.config_tag) in modes))		// ensure each mode is added only once
				modes += initial(M.config_tag)
				mode_names[initial(M.config_tag)] = initial(M.name)
				probabilities[initial(M.config_tag)] = initial(M.probability)
				mode_required_players[initial(M.config_tag)] = initial(M.required_players)
				if(initial(M.votable))
					votable_modes += initial(M.config_tag)

				if(initial(M.config_tag) in minplayers_conf)
					mode_required_players[initial(M.config_tag)] = minplayers_conf[initial(M.config_tag)]
				if(initial(M.config_tag) in probabilities_conf)
					probabilities[initial(M.config_tag)] = probabilities_conf[initial(M.config_tag)]

	votable_modes += "secret"
