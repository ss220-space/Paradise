/datum/game_mode
	var/list/blob_overminds = list()
	var/list/blob_infected = list()
	var/list/blob_offsprings = list()
	var/list/blobernauts = list()
	var/blob_win_count = BLOB_BASE_TARGET_POINT
	var/blob_point_rate = 3
	var/bursted_blobs_count = 0
	var/is_blob_declared = FALSE
	var/is_blob_global_declared = FALSE
	var/is_codes_sent = FALSE
	var/is_blob_process = FALSE
	var/storm_started = FALSE
	var/blob_players_per_core = BLOB_PLAYERS_PER_CORE
	var/datum/objective/blob_critical_mass/blob_objective


/datum/game_mode/blob
	name = "blob"
	config_tag = "blob"

	required_players = 30
	required_enemies = 1
	recommended_enemies = 1
	restricted_jobs = BLOB_RESTRICTED_JOBS
	protected_species = BLOB_RESTRICTED_SPECIES

	var/cores_to_spawn = 1
	var/players_per_core = BLOB_PLAYERS_PER_CORE


/datum/game_mode/blob/pre_setup()

	var/list/possible_blobs = get_players_for_role(ROLE_BLOB)

	// stop setup if no possible traitors
	if(!possible_blobs.len)
		return FALSE

	cores_to_spawn = max(round(num_players() / players_per_core, 1), 1)


	for(var/j = 0, j < cores_to_spawn, j++)
		if(!possible_blobs.len)
			break

		var/datum/mind/blob = pick(possible_blobs)
		blob_infected += blob
		blob.restricted_roles = restricted_jobs
		add_game_logs("has been selected as a Blob", blob)
		possible_blobs -= blob

	if(!blob_infected.len)
		return FALSE
	blob_win_count += BLOB_TARGET_POINT_PER_CORE * cores_to_spawn
	..()
	return TRUE


/datum/game_mode/blob/post_setup()
	for(var/datum/mind/blob in blob_infected)
		var/datum/antagonist/blob_infected/blob_datum = new
		blob_datum.need_new_blob = TRUE
		blob_datum.time_to_burst_h = TIME_TO_BURST_H
		blob_datum.time_to_burst_l = TIME_TO_BURST_L
		blob.add_antag_datum(blob_datum)

	return ..()


/datum/game_mode/blob/announce()
	to_chat(world, "<B>Текущий режим игры - <font color='green'>Блоб</font>!</B>")
	to_chat(world, "<B>Опасный инопланетный организм стремительно распространяется по всей станции!</B>")
	to_chat(world, "Вы должны уничтожить его, сведя к минимуму ущерб, нанесенный станции.")


/datum/game_mode/proc/get_blob_candidates()
	var/list/candidates = list()
	for(var/mob/living/carbon/human/player in GLOB.player_list)
		if(!player.stat && player.mind && !player.mind.special_role)
			if(jobban_isbanned(player, "Syndicate") || jobban_isbanned(player, ROLE_BLOB))
				continue
			if(player.client.prefs?.skip_antag || !(ROLE_BLOB in player.client.prefs.be_special))
				continue
			if(player.can_be_blob)
				continue
			if(length(BLOB_RESTRICTED_JOBS) && (player.mind.assigned_role in BLOB_RESTRICTED_JOBS))
				continue
			var/turf/location = get_turf(player)
			if(!location || !is_station_level(location.z) || isspaceturf(location))
				continue
			candidates += player
	return candidates


/datum/game_mode/proc/get_blob_objective()
	if(!blob_objective)
		blob_objective = new()
		update_blob_objective()
	return blob_objective


/datum/game_mode/proc/update_blob_objective()
	if(blob_objective)
		blob_objective.critical_mass = GLOB.blobs.len
		blob_objective.needed_critical_mass = blob_win_count
		blob_objective.set_target()


/datum/game_mode/proc/blob_died()
	if(!GLOB.blob_cores.len && is_blob_declared)
		addtimer(CALLBACK(src, PROC_REF(report_blob_death), SEC_LEVEL_RED), TIME_TO_ANNOUNCE_BLOBS_DIE)


/datum/game_mode/proc/get_blobs_minds()
	var/list/blob_list = list()
	for(var/value in blob_infected)
		blob_list.Add(value)
	for(var/value in blob_offsprings)
		blob_list.Add(value)
	for(var/value in blobernauts)
		blob_list.Add(value)
	return blob_list


/datum/game_mode/proc/report_blob_death()
	send_intercept(BLOB_THIRD_REPORT)
	is_blob_process = FALSE
	is_blob_declared = FALSE
	if(SSshuttle)
		SSshuttle.stop_lockdown()
	if(is_blob_global_declared && GLOB.security_level == SEC_LEVEL_GAMMA)
		is_blob_global_declared = FALSE
		addtimer(CALLBACK(GLOBAL_PROC, /proc/set_security_level, SEC_LEVEL_RED), TIME_TO_SWITCH_CODE)
	is_codes_sent = FALSE


/datum/game_mode/proc/make_blobs(count, need_new_blob = FALSE)
	var/list/candidates = get_blob_candidates()
	var/mob/living/carbon/human/blob = null
	count = min(count, candidates.len)
	for(var/i = 0, i < count, i++)
		blob = pick(candidates)
		var/datum/antagonist/blob_infected/blob_datum = new
		blob_datum.need_new_blob = need_new_blob
		blob.mind.add_antag_datum(blob_datum)
		candidates -= blob
	return count


/datum/game_mode/proc/process_blob_stages()
	if(!GLOB.blob_cores.len)
		return
	is_blob_process = TRUE
	if(!is_blob_declared && GLOB.blobs.len >= FIRST_STAGE_COEF * blob_win_count)
		is_blob_declared = TRUE
		send_intercept(BLOB_FIRST_REPORT)
		SSshuttle?.lockdown_escape()

	if(!is_blob_global_declared && GLOB.blobs.len >= SECOND_STAGE_COEF * blob_win_count)
		is_blob_global_declared = TRUE
		GLOB.event_announcement.Announce("Подтверждена вспышка биологической угрозы пятого уровня на борту [station_name()]. Весь персонал обязан локализовать угрозу.",
										 "ВНИМАНИЕ: БИОЛОГИЧЕСКАЯ УГРОЗА.", 'sound/AI/outbreak5.ogg')
		addtimer(CALLBACK(GLOBAL_PROC, /proc/set_security_level, SEC_LEVEL_GAMMA), TIME_TO_SWITCH_CODE)

	if(!is_codes_sent && GLOB.blobs.len >= THIRD_STAGE_COEF * blob_win_count)
		is_codes_sent = TRUE
		send_intercept(BLOB_SECOND_REPORT)

	if(GLOB.blobs.len >= blob_win_count && !storm_started)
		if(SSweather)
			storm_started = TRUE
			SSweather.run_weather(/datum/weather/blob_storm)

	addtimer(CALLBACK(src, PROC_REF(process_blob_stages)), STAGES_CALLBACK_TIME)


/datum/game_mode/proc/show_warning(message)
	for(var/datum/mind/blob in blob_infected)
		if(blob.current.stat != DEAD)
			to_chat(blob.current, "<span class='warning'>[message]</span>")


/datum/game_mode/proc/burst_blobs()
	for(var/datum/mind/blob in get_blobs_minds())
		var/datum/antagonist/blob_infected/blob_datum = blob.has_antag_datum(/datum/antagonist/blob_infected)
		blob_datum.burst_blob()
