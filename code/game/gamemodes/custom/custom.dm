/**
 * This mode was created for the administration; with it you can select a custom number of antagonists of all types per round.
 */
/datum/game_mode/custom
	name = "Custom"
	config_tag = "custom"
	protected_jobs = list(JOB_TITLE_OFFICER, JOB_TITLE_WARDEN, JOB_TITLE_DETECTIVE, JOB_TITLE_HOS, JOB_TITLE_CAPTAIN, JOB_TITLE_BLUESHIELD, JOB_TITLE_REPRESENTATIVE, JOB_TITLE_PILOT, JOB_TITLE_MAGISTRATE, JOB_TITLE_BRIGDOC, JOB_TITLE_CCOFFICER, JOB_TITLE_CCFIELD, JOB_TITLE_CCSPECOPS, JOB_TITLE_CCSUPREME, JOB_TITLE_SYNDICATE_OFFICER, JOB_TITLE_PRISONER, JOB_TITLE_CMO, JOB_TITLE_RD, JOB_TITLE_QUARTERMASTER, JOB_TITLE_HOP, JOB_TITLE_CHIEF_ENGINEER)
	restricted_jobs = list(JOB_TITLE_CYBORG, JOB_TITLE_AI)
	forbidden_antag_jobs = list(ROLE_VAMPIRE = list(JOB_TITLE_CHAPLAIN))
	var/list/protected_jobs_AI = list(JOB_TITLE_CIVILIAN, JOB_TITLE_PRISONER, JOB_TITLE_CHIEF_ENGINEER, JOB_TITLE_ENGINEER, JOB_TITLE_ENGINEER_TRAINEE, JOB_TITLE_ATMOSTECH, JOB_TITLE_SPACEPOD_TECHNICIAN, JOB_TITLE_CMO, JOB_TITLE_DOCTOR, JOB_TITLE_MEDICAL_INTERN, JOB_TITLE_CORONER, JOB_TITLE_CHEMIST, JOB_TITLE_GENETICIST, JOB_TITLE_VIROLOGIST, JOB_TITLE_PSYCHIATRIST, JOB_TITLE_PARAMEDIC, JOB_TITLE_RD, JOB_TITLE_SCIENTIST, JOB_TITLE_SCIENCE_STUDENT, JOB_TITLE_ROBOTICIST, JOB_TITLE_HOP, JOB_TITLE_CHAPLAIN, JOB_TITLE_BARTENDER, JOB_TITLE_CHEF, JOB_TITLE_BOTANIST, JOB_TITLE_QUARTERMASTER, JOB_TITLE_CARGOTECH, JOB_TITLE_MINER, JOB_TITLE_MINING_MEDIC, JOB_TITLE_CLOWN, JOB_TITLE_MIME, JOB_TITLE_JANITOR, JOB_TITLE_LIBRARIAN, JOB_TITLE_EXPLORER)
	var/changeling_protected_species = list(SPECIES_MACNINEPERSON, SPECIES_PLASMAMAN)
	var/vampire_protected_species = list(SPECIES_MACNINEPERSON, SPECIES_PLASMAMAN, SPECIES_SLIMEPERSON)
	var/vampire_restricted_jobs = list(JOB_TITLE_CHAPLAIN)
	var/list/antag_counts = list()
	var/list/pre_antags = list()
	var/list/antag_roles = MAIN_ANTAG_ROLES

/datum/game_mode/custom/announce()
	to_chat(world, "<b>Текущий режим игры — Кастомный</b>")

/datum/game_mode/custom/pre_setup()
	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		restricted_jobs += protected_jobs

	antag_counts = build_antag_counts()
	var/list/antag_possibilities = list()
	for(var/role in antag_counts)
		if(antag_counts[role] > 0)
			antag_possibilities[role] = get_antag_candidates(role)

	return roll_antags(antag_possibilities)

/datum/game_mode/custom/post_setup()
	addtimer(CALLBACK(src, PROC_REF(initiate_antags), TRUE), rand(1 SECONDS, 10 SECONDS))
	..()

/datum/game_mode/custom/proc/build_antag_counts()
	var/list/antag_counts = list()
	for(var/role in antag_roles)
		antag_counts[role] = 0

	if(GLOB.custom_antag_counts)
		for(var/role in antag_roles)
			if(role in GLOB.custom_antag_counts)
				antag_counts[role] = GLOB.custom_antag_counts[role]

	return antag_counts

/datum/game_mode/custom/proc/get_antag_candidates(var/role)
	switch(role)
		if(ROLE_TRAITOR)
			return get_players_for_role(ROLE_TRAITOR)
		if(ROLE_THIEF)
			return get_players_for_role(ROLE_THIEF, list(SPECIES_VOX = 4))
		if(ROLE_VAMPIRE)
			return get_players_for_role(ROLE_VAMPIRE)
		if(ROLE_CHANGELING)
			return get_players_for_role(ROLE_CHANGELING)
		if(ROLE_MALF_AI)
			return get_alive_AIs_for_role(ROLE_MALF_AI)
		if(ROLE_DEVIL)
			return get_players_for_role(ROLE_DEVIL)
		if(ROLE_NINJA)
			return get_players_for_role(ROLE_NINJA)
		if(ROLE_HIJACKER)
			return get_players_for_role(ROLE_TRAITOR)
		else
			return list()

/datum/game_mode/custom/proc/remove_chosen_mind_from_all_lists(datum/mind/antag, list/antag_possibilities)
	for(var/role in antag_possibilities)
		antag_possibilities[role] -= antag

/datum/game_mode/custom/proc/roll_antags(list/antag_possibilities)
	pre_antags = list()
	var/list/counts = antag_counts
	for(var/role in antag_possibilities)
		var/target_count = counts[role]
		if(target_count <= 0)
			continue

		var/list/eligible = list()
		for(var/datum/mind/antag in antag_possibilities[role])
			if(!antag.current || !antag.current.client)
				continue
			if(antag.special_role)
				continue
			if(role == ROLE_CHANGELING)
				var/datum/preferences/prefs = antag.current.client.prefs
				if(prefs && (prefs.species in changeling_protected_species))
					continue
			if(role == ROLE_VAMPIRE)
				var/datum/preferences/prefs = antag.current.client.prefs
				if(prefs && (prefs.species in vampire_protected_species))
					continue
			eligible += antag

		if(!length(eligible))
			log_and_message_admins(span_notice("Custom gamemode could not assign [target_count] [capitalize(role)] because there are no eligible candidates."))
			continue

		var/selected = 0
		var/attempts = min(target_count, length(eligible))
		for(var/i in 1 to attempts)
			var/datum/mind/antag = pick_n_take(eligible)
			if(!antag)
				break

			selected++
			if(role == ROLE_TRAITOR || role == ROLE_HIJACKER)
				antag.special_role = SPECIAL_ROLE_TRAITOR
				antag.restricted_roles = restricted_jobs
			if(role == ROLE_THIEF)
				antag.special_role = SPECIAL_ROLE_THIEF
				antag.restricted_roles = restricted_jobs
			if(role == ROLE_VAMPIRE)
				antag.special_role = SPECIAL_ROLE_VAMPIRE
				antag.restricted_roles = (restricted_jobs|vampire_restricted_jobs)
			if(role == ROLE_CHANGELING)
				antag.special_role = SPECIAL_ROLE_CHANGELING
				antag.restricted_roles = restricted_jobs
			if(role == ROLE_MALF_AI)
				antag.special_role = SPECIAL_ROLE_MALFAI
				antag.restricted_roles = (restricted_jobs|protected_jobs|protected_jobs_AI)
				antag.restricted_roles -= JOB_TITLE_AI
			if(role == ROLE_DEVIL)
				antag.special_role = SPECIAL_ROLE_DEVIL
				antag.restricted_roles = restricted_jobs
			if(role == ROLE_NINJA)
				antag.special_role = SPECIAL_ROLE_SPACE_NINJA
				antag.assigned_role = SPECIAL_ROLE_SPACE_NINJA
				antag.offstation_role = TRUE
				antag.restricted_roles = restricted_jobs

			pre_antags[antag] = role
			remove_chosen_mind_from_all_lists(antag, antag_possibilities)

		if(selected < target_count)
			log_and_message_admins(span_notice("Custom gamemode could not assign [target_count] [capitalize(role)]; only [selected] were available."))

	if(!length(pre_antags))
		return FALSE

	return TRUE

/datum/game_mode/custom/proc/initiate_antags(roundstart = FALSE)
	var/list/antags = pre_antags
	for(var/datum/mind/antag in antags)
		if(!antag.current)
			continue
		switch(antags[antag])
			if(ROLE_HIJACKER)
				var/datum/antagonist/traitor/hijacker_datum = new
				hijacker_datum.is_hijacker = TRUE
				hijacker_datum.contractor_pending = roundstart ? new(antag) : null
				antag.add_antag_datum(hijacker_datum)

			if(ROLE_TRAITOR)
				var/datum/antagonist/traitor/datum = new
				if(roundstart)
					datum.contractor_pending = new(antag)
				antag.add_antag_datum(datum)

			if(ROLE_MALF_AI)
				if(isAI(antag.current))
					var/datum/antagonist/malf_ai/malf_datum = new
					antag.add_antag_datum(malf_datum)
				else
					log_and_message_admins("[antag.name] was not assigned for AI role. Report this to coders.")

			if(ROLE_VAMPIRE)
				antag.add_antag_datum(/datum/antagonist/vampire/new_vampire)
			if(ROLE_CHANGELING)
				antag.add_antag_datum(/datum/antagonist/changeling)
			if(ROLE_THIEF)
				antag.add_antag_datum(/datum/antagonist/thief)
			if(ROLE_DEVIL)
				var/datum/antagonist/devil/devil_datum = new
				antag.add_antag_datum(devil_datum)
			if(ROLE_NINJA)
				if(length(GLOB.ninjastart))
					if(antag.current)
						antag.current.forceMove(pick(GLOB.ninjastart))
					antag.add_antag_datum(/datum/antagonist/ninja)
				else
					log_and_message_admins("No positions are found to spawn space ninja antag. Report this to coders.")
