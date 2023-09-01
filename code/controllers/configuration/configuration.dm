GLOBAL_VAR_INIT(config_dir, "config/")
GLOBAL_PROTECT(config_dir)

/datum/controller/configuration
	name = "Configuration"

	var/hiding_entries_by_type = TRUE	//Set for readability, admins can set this to FALSE if they want to debug it
	var/list/entries
	var/list/entries_by_type

	var/list/maplist
	var/datum/map_config/defaultmap

	var/list/modes			// allowed modes
	var/list/gamemode_cache
	var/list/votable_modes		// votable modes
	var/list/mode_names
	var/list/mode_reports
	var/list/mode_false_report_weight

/datum/controller/configuration/New()
	config = src
	var/list/config_files = InitEntries()
	for(var/I in config_files)
		LoadEntries(I)
	//if(Get(/datum/config_entry/flag/maprotation))
	//	loadmaplist(CONFIG_MAPS_FILE)

/datum/controller/configuration/Destroy()
	entries_by_type.Cut()
	QDEL_LIST_ASSOC_VAL(entries)
	QDEL_LIST_ASSOC_VAL(maplist)
	//QDEL_NULL(defaultmap)

	config = null

	return ..()

/datum/controller/configuration/proc/InitEntries()
	var/list/_entries = list()
	entries = _entries
	var/list/_entries_by_type = list()
	entries_by_type = _entries_by_type

	. = list()

	for(var/I in typesof(/datum/config_entry))	//typesof is faster in this case
		var/datum/config_entry/E = I
		if(initial(E.abstract_type) == I)
			continue
		E = new I
		_entries_by_type[I] = E
		var/esname = E.name
		var/datum/config_entry/test = _entries[esname]
		if(test)
			log_config("Error: [test.type] has the same name as [E.type]: [esname]! Not initializing [E.type]!")
			qdel(E)
			continue
		_entries[esname] = E
		.[E.resident_file] = TRUE

/datum/controller/configuration/proc/RemoveEntry(datum/config_entry/CE)
	entries -= CE.name
	entries_by_type -= CE.type

/datum/controller/configuration/proc/LoadEntries(filename)
	log_config("Loading config file [filename]...")
	var/list/lines = world.file2list("[GLOB.config_dir][filename]")
	var/list/_entries = entries
	for(var/L in lines)
		if(!L)
			continue

		if(copytext(L, 1, 2) == "#")
			continue

		var/pos = findtext(L, " ")
		var/entry = null
		var/value = null

		if(pos)
			entry = lowertext(copytext(L, 1, pos))
			value = copytext(L, pos + 1)
		else
			entry = lowertext(L)

		if(!entry)
			continue

		var/datum/config_entry/E = _entries[entry]
		if(!E)
			log_config("Unknown setting in configuration: '[entry]'")
			continue

		if(filename != E.resident_file)
			log_config("Found [entry] in [filename] when it should have been in [E.resident_file]! Ignoring.")
			continue

		var/validated = E.ValidateAndSet(value)
		if(!validated)
			log_config("Failed to validate setting \"[value]\" for [entry]")
		else if(E.modified && !E.dupes_allowed)
			log_config("Duplicate setting for [entry] ([value]) detected! Using latest.")

		if(validated)
			E.modified = TRUE

/datum/controller/configuration/can_vv_get(var_name)
	return (var_name != "entries_by_type" || !hiding_entries_by_type) && ..()

/datum/controller/configuration/vv_edit_var(var_name, var_value)
	return !(var_name in list("entries_by_type", "entries")) && ..()

/datum/controller/configuration/stat_entry()
	if(!statclick)
		statclick = new/obj/effect/statclick/debug(null, "Edit", src)
	stat("[name]:", statclick)

/datum/controller/configuration/proc/Get(entry_type)
	var/datum/config_entry/E = entry_type
	var/entry_is_abstract = initial(E.abstract_type) == entry_type
	if(entry_is_abstract)
		CRASH("Tried to retrieve an abstract config_entry: [entry_type]")
	E = entries_by_type[entry_type]
	if(!E)
		CRASH("Missing config entry for [entry_type]!")
	return E.value

/datum/controller/configuration/proc/Set(entry_type, new_val)
	var/datum/config_entry/E = entry_type
	var/entry_is_abstract = initial(E.abstract_type) == entry_type
	if(entry_is_abstract)
		CRASH("Tried to retrieve an abstract config_entry: [entry_type]")
	E = entries_by_type[entry_type]
	if(!E)
		CRASH("Missing config entry for [entry_type]!")
	return E.ValidateAndSet(new_val)
