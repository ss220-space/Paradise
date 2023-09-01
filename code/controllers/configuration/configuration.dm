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
	if(fexists("[directory]/config.txt") && LoadEntries("config.txt") <= 1)
		var/list/legacy_configs = list("game_options.txt", "dbconfig.txt", "comms.txt")
		for(var/I in legacy_configs)
			if(fexists("[directory]/[I]"))
				log_config("No $include directives found in config.txt! Loading legacy [legacy_configs.Join("/")] files...")
				for(var/J in legacy_configs)
					LoadEntries(J)
				break

	if(CONFIG_GET(flag/usewhitelist))
		load_whitelist()

	loaded = TRUE

	if (Master)
		Master.OnConfigLoad()
	process_config_errors()

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
			log_config("Unknown setting in configuration: '[entry]'")
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
	return msg

/datum/controller/configuration/proc/Get(entry_type)
	var/datum/config_entry/E = entry_type
	var/entry_is_abstract = initial(E.abstract_type) == entry_type
	if(entry_is_abstract)
		CRASH("Tried to retrieve an abstract config_entry: [entry_type]")
	E = entries_by_type[entry_type]
	if(!E)
		CRASH("Missing config entry for [entry_type]!")
	if((E.protection & CONFIG_ENTRY_HIDDEN) && IsAdminAdvancedProcCall() && GLOB.LastAdminCalledProc == "Get" && GLOB.LastAdminCalledTargetUID == "[UID(src)]")
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
	if((E.protection & CONFIG_ENTRY_LOCKED) && IsAdminAdvancedProcCall() && GLOB.LastAdminCalledProc == "Set" && GLOB.LastAdminCalledTargetUID == "[UID(src)]")
		log_admin_private("Config rewrite of [entry_type] to [new_val] attempted by [key_name(usr)]")
		return
	return E.ValidateAndSet("[new_val]")

///datum/controller/configuration/proc/LoadMOTD()
//	var/list/motd_contents = list()
//
//	var/list/motd_list = CONFIG_GET(str_list/motd)
//	if (motd_list.len == 0 && fexists("[directory]/motd.txt"))
//		motd_list = list("motd.txt")
//
//	for (var/motd_file in motd_list)
//		if (fexists("[directory]/[motd_file]"))
//			motd_contents += file2text("[directory]/[motd_file]")
//		else
//			log_config("MOTD file [motd_file] didn't exist")
//			DelayedMessageAdmins("MOTD file [motd_file] didn't exist")
//
//	motd = motd_contents.Join("\n")
//
//	var/tm_info = GLOB.revdata.GetTestMergeInfo()
//	if(motd || tm_info)
//		motd = motd ? "[motd]<br>[tm_info]" : tm_info


//Message admins when you can.
/datum/controller/configuration/proc/DelayedMessageAdmins(text)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(message_admins), text), 0)
