GLOBAL_LIST_INIT(exports_list, init_Exports())

/// Called when the global exports_list is empty, and sets it up.
/proc/init_Exports()
	var/list/exports = list()
	for(var/datum/export/subtype as anything in valid_subtypesof(/datum/export))
		exports += new subtype
	return exports
