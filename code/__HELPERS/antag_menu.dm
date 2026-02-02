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
		if(istype(get_area(antag_mind.current), /area/security/permabrig))
			temp_list["status"] += "(ПЕРМА)"
		// temp_list["ckey"] = antag_mind.current.client?.ckey
	temp_list["ckey"] = ckey(antag_mind.key)
	temp_list["is_hijacker"] = istype((locate(/datum/objective/hijack) in antag_mind.get_all_objectives()), /datum/objective/hijack)
	cached_data["antagonists"][uid] = temp_list

/**
 * Processes a list of antagonists and prepares their data
 *
 * Iterates through a list of antagonist minds and calls prepare_antag_data for each one.
 * Used to batch process multiple antagonists of the same type.
 *
 * Arguments:
 * * antags - List of antagonist minds to process
 * * cached_data - The main cache data structure to update
 * * antag_name - The type name of the antagonist role
 * * antagonist_cache - Cache of antagonist data indexed by mind UID
 */
/proc/prepare_antag_list(list/antags, list/cached_data, antag_name, list/antagonist_cache)
	for(var/antag in antags)
		prepare_antag_data(antag, cached_data, antag_name, antagonist_cache)

/**
 * Collects data for all non-datum based antagonist types
 *
 * Processes various antagonist lists from the game mode and prepares their data
 * for caching. Covers most standard antagonist types in the game.
 *
 * Arguments:
 * * cached_data - The main cache data structure to update
 * * antagonist_cache - Cache of antagonist data indexed by mind UID
 */
/proc/prepare_nodatum_antags(list/cached_data, list/antagonist_cache)
	var/datum/game_mode/mode = SSticker.mode
	prepare_antag_list(mode.clockwork_cult, cached_data, "Культист Ратвара", antagonist_cache)
	prepare_antag_list(mode.cult, cached_data, "Культист [SSticker.cultdat.entity_name]", antagonist_cache)
	prepare_antag_list(mode.abductors, cached_data, "Абдуктор", antagonist_cache)
	prepare_antag_list(mode.abductees, cached_data, "Жертва абдукторов", antagonist_cache)
	prepare_antag_list(mode.head_revolutionaries, cached_data, "Глава революции", antagonist_cache)
	prepare_antag_list(mode.revolutionaries, cached_data, "Революционер", antagonist_cache)
	prepare_antag_list(mode.wizards, cached_data, "Маг", antagonist_cache)
	prepare_antag_list(mode.apprentices, cached_data, "Ученик мага", antagonist_cache)
	prepare_antag_list(mode.space_ninjas, cached_data, "Клан Паука", antagonist_cache)
	prepare_antag_list(mode.shadows, cached_data, "Тень", antagonist_cache)
	prepare_antag_list(mode.shadowling_thralls, cached_data, "Раб теней", antagonist_cache)
	prepare_antag_list(mode.raiders, cached_data, "Вокс рейдер", antagonist_cache)
	prepare_antag_list(mode.superheroes, cached_data, "Супергерой", antagonist_cache)
	prepare_antag_list(mode.supervillains, cached_data, "Суперзлодей", antagonist_cache)
	prepare_antag_list(mode.greyshirts, cached_data, "Грейтайд", antagonist_cache)
	prepare_antag_list(mode.demons, cached_data, "Демон", antagonist_cache)
	prepare_antag_list(mode.eventmiscs, cached_data, "Ивентроль", antagonist_cache)
	prepare_antag_list(mode.traders, cached_data, "Торговец", antagonist_cache)
	prepare_antag_list(mode.morphs, cached_data, "Морф", antagonist_cache)
	prepare_antag_list(mode.swarmers, cached_data, "Свармер", antagonist_cache)
	prepare_antag_list(mode.guardians, cached_data, "Голопаразит", antagonist_cache)
	prepare_antag_list(mode.revenants, cached_data, "Ревенант", antagonist_cache)
	prepare_antag_list(mode.headslugs, cached_data, "Личинка генокрада", antagonist_cache)
	prepare_antag_list(mode.deathsquad, cached_data, "Боец Отряда Смерти", antagonist_cache)
	prepare_antag_list(mode.honksquad, cached_data, "Член Хонксквада", antagonist_cache)
	prepare_antag_list(mode.sst, cached_data, "Боец SST", antagonist_cache)
	prepare_antag_list(mode.sit, cached_data, "Агент SIT", antagonist_cache)
