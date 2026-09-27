/**
 * Prepares antagonist data for caching and display
 *
 * Collects various antagonist status information including name, status, objectives,
 * and stores it in the antagonist cache for later use in round-end reports or admin tools.
 *
 * Arguments:
 * * antag_mind - The mind datum of the antagonist
 * * cached_data - The main cache data structure to update
 * * antag_name - The type name of the antagonist role
 * * antagonist_cache - Cache of antagonist data indexed by mind UID
 */
/proc/prepare_antag_data(datum/mind/antag_mind, list/cached_data, antag_name, list/antagonist_cache)
	var/uid = antag_mind.UID()
	var/list/temp_list = (uid in antagonist_cache)? antagonist_cache[uid] : list()
	temp_list["antag_mind_uid"] = uid
	if(isnull(temp_list["antag_names"]))
		temp_list["antag_names"] = list()
	temp_list["antag_names"] |= antag_name
	temp_list["name"] = ""
	temp_list["status"] = "Нет тела"
	temp_list["name"] = antag_mind.name
	temp_list["body_destroyed"] = TRUE
	if(!QDELETED(antag_mind.current))
		temp_list["body_destroyed"] = FALSE
		temp_list["status"] = ""
		if(antag_mind.current.stat == DEAD)
			temp_list["status"] = "(МЁРТВ)"
		else if(!antag_mind.current.client)
			temp_list["status"] = "(КРС)"
		if(istype(get_area(antag_mind.current), /area/station/security/prison/perma))
			temp_list["status"] += "(ПЕРМА)"
		// temp_list["ckey"] = antag_mind.current.client?.ckey
	temp_list["ckey"] = ckey(antag_mind.key)
	temp_list["is_hijacker"] = HAS_TRAIT(antag_mind, TRAIT_HIJACK)
	cached_data["antagonists"][uid] = temp_list
