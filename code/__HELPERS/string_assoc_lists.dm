GLOBAL_LIST_EMPTY(string_assoc_lists)

/**
 * Caches associative lists with non-numeric stringify-able index keys and stringify-able values (text/typepath -> text/path/number).
 *
 * Arguments:
 * * input_list - The associative list to cache or retrieve from cache
 */
/datum/proc/string_assoc_list(list/input_list)
	var/list/cache_key_components = list()
	for(var/key in input_list)
		cache_key_components += "[key]_[input_list[key]]"
	var/cache_key = cache_key_components.Join("-")

	. = GLOB.string_assoc_lists[cache_key]

	if(.)
		return . // Cached list

	return GLOB.string_assoc_lists[cache_key] = input_list
