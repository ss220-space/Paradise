GLOBAL_LIST_EMPTY(string_lists)

/**
 * Caches lists with non-numeric stringify-able values (text or typepath).
 *
 * Arguments:
 * * input_list - The list to cache or retrieve from cache
 */
/proc/string_list(list/input_list)
	var/cache_key = input_list.Join("-")

	. = GLOB.string_lists[cache_key]

	if(.)
		return . // Cached list

	return GLOB.string_lists[cache_key] = input_list

