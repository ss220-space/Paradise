/datum/game_mode
	/// List of of blobs, their offsprings and blobburnouts spawned by them
	var/list/blobs = list("infected"=list(), "offsprings"=list(), "blobernauts"=list())
	/// Count of blob tiles to blob win
	var/blob_win_count = BLOB_BASE_TARGET_POINT
	/// Number of resource produced by the core
	var/blob_point_rate = 3
	/// Number of bursted blob infected
	var/bursted_blobs_count = 0
	/// Total blob submode stage
	var/blob_stage = BLOB_STAGE_NONE
	/// The need to delay the end of the game when the blob wins
	var/delay_blob_end = FALSE
	/// Disables automatic GAMMA code
	var/off_auto_gamma = FALSE
	/// Disables automatic nuke codes
	var/off_auto_nuke_codes = FALSE
	/// Total blobs objective
	var/datum/objective/blob_critical_mass/blob_objective


/datum/game_mode/blob
	name = "blob"
	config_tag = "blob"

	required_players = 30
	required_enemies = 1
	recommended_enemies = 1
	restricted_jobs = BLOB_RESTRICTED_JOBS
	protected_species = BLOB_RESTRICTED_SPECIES

	/// Base count of roundstart blobs
	var/cores_to_spawn = 1
	/// The number of players for which 1 more roundstart blob will be added.
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
		blobs["infected"] += blob
		blob.restricted_roles = restricted_jobs
		add_game_logs("has been selected as a Blob", blob)
		possible_blobs -= blob
	var/list/blob_infected = blobs["infected"]
	if(!blob_infected?.len)
		return FALSE
	blob_win_count += BLOB_TARGET_POINT_PER_CORE * cores_to_spawn
	..()
	return TRUE


/datum/game_mode/blob/post_setup()
	for(var/datum/mind/blob in blobs["infected"])
		var/datum_type = blob.get_blob_infected_type()
		var/datum/antagonist/blob_infected/blob_datum = new datum_type()
		blob_datum.need_new_blob = TRUE
		blob_datum.time_to_burst_hight = TIME_TO_BURST_HIGHT
		blob_datum.time_to_burst_low = TIME_TO_BURST_LOW
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
			if(!player.can_be_blob())
				continue
			var/blob_restricted_jobs = /datum/game_mode/blob::restricted_jobs
			if(length(blob_restricted_jobs) && (player.mind.assigned_role in blob_restricted_jobs))
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
	if(blob_objective && !blob_objective.completed)
		blob_objective.critical_mass = GLOB.blobs.len
		blob_objective.needed_critical_mass = blob_win_count
		blob_objective.set_target()


/datum/game_mode/proc/blob_died()
	if(!GLOB.blob_cores.len && blob_stage >= BLOB_STAGE_FIRST && blob_stage < BLOB_STAGE_STORM)
		addtimer(CALLBACK(src, PROC_REF(report_blob_death), BLOB_DEATH_REPORT_FIRST), TIME_TO_ANNOUNCE_BLOBS_DIE)


/datum/game_mode/proc/get_blobs_minds()
	var/list/blob_list = list()
	for(var/value in blobs["infected"])
		blob_list.Add(value)
	for(var/value in blobs["offsprings"])
		blob_list.Add(value)
	for(var/value in blobs["blobernauts"])
		blob_list.Add(value)
	return blob_list


/datum/game_mode/proc/report_blob_death(report_number)
	switch(report_number)
		if (BLOB_DEATH_REPORT_FIRST)
			send_intercept(BLOB_THIRD_REPORT)
		if (BLOB_DEATH_REPORT_SECOND)
			SSshuttle?.stop_lockdown()
		if (BLOB_DEATH_REPORT_THIRD)
			if(!off_auto_gamma && GLOB.security_level == SEC_LEVEL_GAMMA)
				set_security_level(SEC_LEVEL_RED)
		if (BLOB_DEATH_REPORT_FOURTH)
			blob_stage = BLOB_STAGE_ZERO
			SSvote.start_vote(new /datum/vote/crew_transfer)
			return
		else
			return
	addtimer(CALLBACK(src, PROC_REF(report_blob_death), report_number + 1), TIME_TO_SWITCH_CODE)


/datum/game_mode/proc/make_blobs(count, need_new_blob = FALSE)
	var/list/candidates = get_blob_candidates()
	var/mob/living/carbon/human/blob = null
	count = min(count, candidates.len)
	for(var/i = 0, i < count, i++)
		blob = pick(candidates)
		var/datum_type = blob.mind.get_blob_infected_type()
		var/datum/antagonist/blob_infected/blob_datum = new datum_type()
		blob_datum.need_new_blob = need_new_blob
		blob.mind.add_antag_datum(blob_datum)
		candidates -= blob
	return count


/datum/game_mode/proc/make_blobized_mouses(count)
	var/list/candidates = SSghost_spawns.poll_candidates("Вы хотите сыграть за мышь, зараженную Блобом?", ROLE_BLOB, TRUE, source = /mob/living/simple_animal/mouse/blobinfected)

	if(!length(candidates))
		return FALSE

	var/list/vents = get_valid_vent_spawns(exclude_mobs_nearby = TRUE, exclude_visible_by_mobs = TRUE)
	if(!length(vents))
		return FALSE

	for(var/i in 1 to count)
		if (length(candidates))
			var/obj/vent = pick(vents)
			var/mob/living/simple_animal/mouse/B = new(vent.loc)
			var/mob/M = pick(candidates)
			candidates.Remove(M)
			B.key = M.key
			var/datum_type = B.mind.get_blob_infected_type()
			var/datum/antagonist/blob_infected/blob_datum = new datum_type()
			blob_datum.time_to_burst_hight = TIME_TO_BURST_MOUSE_HIGHT
			blob_datum.time_to_burst_low = TIME_TO_BURST_MOUSE_LOW
			B.mind.add_antag_datum(blob_datum)
			to_chat(B, span_userdanger("Теперь вы мышь, заражённая спорами Блоба. Найдите какое-нибудь укромное место до того, как вы взорветесь и станете Блобом! Вы можете перемещаться по вентиляции, нажав Alt+ЛКМ на вентиляционном отверстии."))
			log_game("[B.key] has become blob infested mouse.")
			notify_ghosts("Заражённая мышь появилась в [get_area(B)].", source = B, action = NOTIFY_FOLLOW)
	return TRUE


/datum/game_mode/proc/process_blob_stages()
	if(!GLOB.blob_cores.len)
		return
	if(blob_stage == BLOB_STAGE_NONE)
		blob_stage = BLOB_STAGE_ZERO
	if(blob_stage == BLOB_STAGE_ZERO && GLOB.blobs.len >= min(FIRST_STAGE_COEF * blob_win_count, FIRST_STAGE_THRESHOLD))
		blob_stage = BLOB_STAGE_FIRST
		send_intercept(BLOB_FIRST_REPORT)
		SSshuttle?.emergency?.cancel()
		SSshuttle?.lockdown_escape()

	if(blob_stage == BLOB_STAGE_FIRST && GLOB.blobs.len >= min(SECOND_STAGE_COEF * blob_win_count, SECOND_STAGE_THRESHOLD))
		blob_stage = BLOB_STAGE_SECOND
		GLOB.event_announcement.Announce("Подтверждена вспышка биологической угрозы пятого уровня на борту [station_name()]. Весь персонал обязан локализовать угрозу.",
										 "ВНИМАНИЕ: БИОЛОГИЧЕСКАЯ УГРОЗА.", 'sound/AI/outbreak5.ogg')
		if(!off_auto_gamma)
			addtimer(CALLBACK(GLOBAL_PROC, /proc/set_security_level, SEC_LEVEL_GAMMA), TIME_TO_SWITCH_CODE)

	if(blob_stage == BLOB_STAGE_SECOND && GLOB.blobs.len >= THIRD_STAGE_COEF * blob_win_count)
		blob_stage = BLOB_STAGE_THIRD
		send_intercept(BLOB_SECOND_REPORT)

	if(GLOB.blobs.len >= blob_win_count && blob_stage < BLOB_STAGE_STORM)
		if(SSweather)
			blob_stage = BLOB_STAGE_STORM
			SSweather.run_weather(/datum/weather/blob_storm)

	addtimer(CALLBACK(src, PROC_REF(process_blob_stages)), STAGES_CALLBACK_TIME)


/datum/game_mode/proc/show_warning(message)
	for(var/datum/mind/blob in blobs["infected"])
		if(blob.current.stat != DEAD)
			to_chat(blob.current, "<span class='warning'>[message]</span>")


/datum/game_mode/proc/burst_blobs()
	for(var/datum/mind/blob in get_blobs_minds())
		var/datum/antagonist/blob_infected/blob_datum = blob.has_antag_datum(/datum/antagonist/blob_infected)
		blob_datum.burst_blob()
