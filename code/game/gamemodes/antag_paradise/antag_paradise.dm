/**
 * This is a game mode which has a chance to spawn any minor antagonist.
 */
/datum/game_mode/antag_paradise
	name = "Antag Paradise"
	config_tag = "antag-paradise"
	protected_jobs = list("Security Officer", "Security Cadet", "Warden", "Detective", "Head of Security", "Captain", "Blueshield", "Nanotrasen Representative", "Security Pod Pilot", "Magistrate", "Brig Physician", "Internal Affairs Agent", "Nanotrasen Navy Officer", "Nanotrasen Navy Field Officer", "Special Operations Officer", "Supreme Commander", "Syndicate Officer")
	restricted_jobs = list("Cyborg", "AI")
	required_players = 10
	required_enemies = 1
	forbidden_antag_jobs = list(ROLE_VAMPIRE = list("Chaplain"))
	var/list/protected_jobs_AI = list("Civilian","Chief Engineer","Station Engineer","Trainee Engineer","Life Support Specialist","Mechanic","Chief Medical Officer","Medical Doctor","Intern","Coroner","Chemist","Geneticist","Virologist","Psychiatrist","Paramedic","Research Director","Scientist","Student Scientist","Roboticist","Head of Personnel","Chaplain","Bartender","Chef","Botanist","Quartermaster","Cargo Technician","Shaft Miner","Clown","Mime","Janitor","Librarian","Barber","Explorer")	// Basically all jobs, except AI.
	var/secondary_protected_species = list(SPECIES_MACNINEPERSON)
	var/vampire_restricted_jobs = list("Chaplain")
	/// Chosen antags if any. Key - mind, value - antag type
	var/list/datum/mind/pre_antags = list()
	var/list/datum/mind/pre_double_antags = list()

	var/antag_making_cooldown = 5 MINUTES
	var/next_antag_making_time = 0

	var/list/antag_required_players = list(
		ROLE_TRAITOR = 10,
		ROLE_THIEF = 10,
		ROLE_VAMPIRE = 15,
		ROLE_CHANGELING = 15,
		ROLE_HIJACKER = 40,
		ROLE_MALF_AI = 40,
		ROLE_NINJA = 40,
	)
	/// Antag weights for main antags
	var/list/antags_weights
	/// Chosen speciaal antag type.
	var/special_antag_type = ROLE_NONE


/datum/game_mode/antag_paradise/announce()
	to_chat(world, "<b>The current game mode is - Antag Paradise</b>")
	to_chat(world, "<b>Traitors, thieves, vampires and changelings, oh my! Stay safe as these forces work to bring down the station.</b>")

/datum/game_mode/antag_paradise/process()
	if(SSshuttle.emergency.mode >= SHUTTLE_ESCAPE)
		return PROCESS_KILL

	if(world.time < next_antag_making_time)
		return FALSE

	next_antag_making_time = world.time + antag_making_cooldown
	var/list/antag_possibilities = list()
	antag_possibilities[ROLE_VAMPIRE] = get_alive_players_for_role(ROLE_VAMPIRE)
	antag_possibilities[ROLE_CHANGELING] = get_alive_players_for_role(ROLE_CHANGELING)
	antag_possibilities[ROLE_TRAITOR] =	get_alive_players_for_role(ROLE_TRAITOR)
	antag_possibilities[ROLE_THIEF] = get_alive_players_for_role(ROLE_THIEF, list(SPECIES_VOX = 4))
	roll_antagonists(antag_possibilities)
	initiate_antags()


/datum/game_mode/antag_paradise/proc/roll_antagonists(list/antag_possibilities, roundstart = FALSE)
	pre_antags = list()
	pre_double_antags = list()

	var/players = roundstart ? num_players() : num_station_players()
	var/scale = CONFIG_GET(number/traitor_scaling) ? CONFIG_GET(number/traitor_scaling) : 10
	var/antags_amount
	var/special_antag_amount

	antags_amount = 1 + round(players / scale)
	//Special antag spawning not on roundstart is currently disabled for testing purposes.
	special_antag_amount = roundstart ? 1 + round(players / 50) : 0

	antags_amount = antags_amount - length(GLOB.antagonists)
	if(antags_amount <= 0)
		return

	if(special_antag_type == ROLE_NINJA && !roundstart)
		special_antag_type = pick(ROLE_HIJACKER, ROLE_THIEF, ROLE_MALF_AI)

	switch(special_antag_type)
		if(ROLE_HIJACKER)
			for(var/i in 1 to special_antag_amount)
				var/datum/mind/special_antag = pick_n_take(antag_possibilities[ROLE_TRAITOR])
				if(special_antag)
					special_antag.restricted_roles = restricted_jobs
					special_antag.special_role = SPECIAL_ROLE_TRAITOR
					pre_antags[special_antag] = ROLE_HIJACKER
					antags_amount--

		if(ROLE_THIEF)
			for(var/i in 1 to special_antag_amount)
				var/datum/mind/special_antag = pick_n_take(antag_possibilities[ROLE_THIEF])
				if(special_antag)
					listclearduplicates(special_antag, antag_possibilities[ROLE_THIEF])
					special_antag.special_role = SPECIAL_ROLE_THIEF
					special_antag.restricted_roles = restricted_jobs
					pre_antags[special_antag] = ROLE_THIEF
					//antags_amount--

		if(ROLE_MALF_AI)
			if(special_antag_amount)
				var/datum/mind/special_antag = roundstart ? safepick(get_players_for_role(ROLE_MALF_AI)) : safepick(get_alive_players_for_role(ROLE_MALF_AI))
				if(special_antag)
					special_antag.restricted_roles = (restricted_jobs|protected_jobs|protected_jobs_AI)
					special_antag.restricted_roles -= "AI"
					special_antag.special_role = SPECIAL_ROLE_TRAITOR
					SSjobs.new_malf = special_antag.current
					pre_antags[special_antag] = ROLE_MALF_AI
					antags_amount--

		if(ROLE_NINJA)
			if(length(GLOB.ninjastart))
				var/datum/mind/special_antag = safepick(get_players_for_role(ROLE_NINJA))
				if(special_antag)
					special_antag.current.loc = pick(GLOB.ninjastart)
					special_antag.assigned_role = SPECIAL_ROLE_SPACE_NINJA // assigned role and special role must be the same so they aren't chosen for other jobs.
					special_antag.special_role = SPECIAL_ROLE_SPACE_NINJA
					special_antag.offstation_role = TRUE // ninja can't be targeted as a victim for some pity traitors
					pre_antags[special_antag] = ROLE_NINJA
					antags_amount--
			else
				log_and_message_admins("No positions are found to spawn space ninja antag. Report this to coders.")

	if(antags_amount)
		for(var/i in 1 to antags_amount)
			var/antag_type = pick_weight_classic(antags_weights)
			switch(antag_type)
				if(ROLE_VAMPIRE)
					var/datum/mind/vampire = pick_n_take(antag_possibilities[ROLE_VAMPIRE])
					if(!vampire)
						continue
					if(vampire.current.client.prefs.species in secondary_protected_species)
						continue
					if(vampire.special_role)
						continue
					vampire.special_role = SPECIAL_ROLE_VAMPIRE
					vampire.restricted_roles = (restricted_jobs|vampire_restricted_jobs)
					pre_antags[vampire] = ROLE_VAMPIRE
				if(ROLE_CHANGELING)
					var/datum/mind/changeling = pick_n_take(antag_possibilities[ROLE_CHANGELING])
					if(!changeling)
						continue
					if(changeling.current.client.prefs.species in secondary_protected_species)
						continue
					if(changeling.special_role)
						continue
					changeling.special_role = SPECIAL_ROLE_CHANGELING
					changeling.restricted_roles = restricted_jobs
					pre_antags[changeling] = ROLE_CHANGELING
				if(ROLE_TRAITOR)
					var/datum/mind/traitor = pick_n_take(antag_possibilities[ROLE_TRAITOR])
					if(!traitor)
						continue
					if(traitor.special_role)
						continue
					traitor.special_role = SPECIAL_ROLE_TRAITOR
					traitor.restricted_roles = restricted_jobs
					pre_antags[traitor] = ROLE_TRAITOR
				if(ROLE_THIEF)
					var/datum/mind/thief = pick_n_take(antag_possibilities[ROLE_THIEF])
					if(!thief)
						continue
					listclearduplicates(thief, antag_possibilities[ROLE_THIEF])
					if(thief.special_role)
						continue
					thief.special_role = SPECIAL_ROLE_THIEF
					thief.restricted_roles = restricted_jobs
					pre_antags[thief] = ROLE_THIEF

	if(!length(pre_antags))
		return FALSE

	. = TRUE

	var/chance_double_antag = isnull(GLOB.antag_paradise_double_antag_chance) ? CONFIG_GET(number/antag_paradise_double_antag_chance) : GLOB.antag_paradise_double_antag_chance
	if(!chance_double_antag)
		return

	for(var/datum/mind/antag as anything in pre_antags)
		if(antag.special_role != SPECIAL_ROLE_TRAITOR || !prob(chance_double_antag))
			continue

		var/list/available_roles = list(ROLE_VAMPIRE, ROLE_CHANGELING)
		while(length(available_roles))
			var/second_role = pick_n_take(available_roles)

			if(second_role == ROLE_VAMPIRE && \
				!jobban_isbanned(antag.current, second_role) && \
				player_old_enough_antag(antag.current.client, second_role) && \
				!(antag.current.client.prefs.species in secondary_protected_species))

				antag.restricted_roles |= vampire_restricted_jobs
				pre_double_antags[antag] = ROLE_VAMPIRE
				break

			if(second_role == ROLE_CHANGELING && \
				!jobban_isbanned(antag.current, second_role) && \
				player_old_enough_antag(antag.current.client, second_role) && \
				!(antag.current.client.prefs.species in secondary_protected_species))

				pre_double_antags[antag] = ROLE_CHANGELING
				break

/datum/game_mode/antag_paradise/pre_setup()
	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		restricted_jobs += protected_jobs

	var/list/antag_possibilities = list()
	antag_possibilities[ROLE_VAMPIRE] = get_players_for_role(ROLE_VAMPIRE)
	antag_possibilities[ROLE_CHANGELING] = get_players_for_role(ROLE_CHANGELING)
	antag_possibilities[ROLE_TRAITOR] =	get_players_for_role(ROLE_TRAITOR)
	antag_possibilities[ROLE_THIEF] = get_players_for_role(ROLE_THIEF, list(SPECIES_VOX = 4))

	calculate_antags()

	return roll_antagonists(antag_possibilities, TRUE)

/datum/game_mode/antag_paradise/proc/calculate_antags()
	var/players = num_players()
	var/list/special_antags_list
	if(GLOB.antag_paradise_special_weights)
		special_antags_list = GLOB.antag_paradise_special_weights
	else
		special_antags_list = config_to_roles(CONFIG_GET(keyed_list/antag_paradise_special_antags_weights))
		for(var/antag in special_antags_list)
			if(players < antag_required_players[antag])
				special_antags_list -= antag

	if(length(special_antags_list))
		special_antag_type = pick_weight_classic(special_antags_list)

	if(GLOB.antag_paradise_weights)
		antags_weights = GLOB.antag_paradise_weights
		return

	antags_weights = list()

	var/list/antag_weight_config = CONFIG_GET(keyed_list/antag_paradise_main_antags)
	antag_weight_config = antag_weight_config.Copy()

	for(var/antag in antag_weight_config)
		if(players < antag_required_players[antag])
			antag_weight_config -= antag

	if(!length(antag_weight_config))
		return

	var/mode_type = pick_weight_classic(CONFIG_GET(keyed_list/antag_paradise_mode_subtypes))
	if(mode_type == ANTAG_RANDOM)
		for(var/antag in antag_weight_config)
			antags_weights[antag] = rand(1, 100)
		return

	var/list/subtype_weights = CONFIG_GET(keyed_list/antag_paradise_subtype_weights)
	antags_weights[pick_weight_n_take(antag_weight_config)] = subtype_weights[ANTAG_SINGLE]
	if(!length(antag_weight_config) || mode_type == ANTAG_SINGLE)
		return
	antags_weights[pick_weight_n_take(antag_weight_config)] = subtype_weights[ANTAG_DOUBLE]
	if(!length(antag_weight_config) || mode_type == ANTAG_DOUBLE)
		return
	antags_weights[pick_weight_n_take(antag_weight_config)] = subtype_weights[ANTAG_TRIPPLE]


/datum/game_mode/antag_paradise/post_setup()
	for(var/datum/mind/antag as anything in pre_antags)
		if(pre_antags[antag] == ROLE_NINJA)
			var/datum/antagonist/ninja/ninja_datum = new
			ninja_datum.antag_paradise_mode_chosen = TRUE
			antag.add_antag_datum(ninja_datum)

	addtimer(CALLBACK(src, PROC_REF(initiate_antags)), rand(1 SECONDS, 10 SECONDS))
	next_antag_making_time = world.time + antag_making_cooldown
	..()


/datum/game_mode/antag_paradise/proc/initiate_antags()
	for(var/datum/mind/antag as anything in pre_antags)
		switch(pre_antags[antag])
			if(ROLE_HIJACKER)
				var/datum/antagonist/traitor/hijacker_datum = new
				hijacker_datum.is_hijacker = TRUE
				antag.add_antag_datum(hijacker_datum)

			if(ROLE_MALF_AI)
				if(isAI(antag.current))
					antag.add_antag_datum(/datum/antagonist/malf_ai)
				else
					log_and_message_admins("[antag] was not assigned for AI role. Report this to coders.")

			if(ROLE_VAMPIRE)
				antag.add_antag_datum(/datum/antagonist/vampire)
			if(ROLE_CHANGELING)
				antag.add_antag_datum(/datum/antagonist/changeling)
			if(ROLE_TRAITOR)
				antag.add_antag_datum(/datum/antagonist/traitor)
			if(ROLE_THIEF)
				antag.add_antag_datum(/datum/antagonist/thief)

	for(var/datum/mind/antag as anything in pre_double_antags)
		switch(pre_antags[antag])
			if(ROLE_VAMPIRE)
				antag.add_antag_datum(/datum/antagonist/vampire)
			if(ROLE_CHANGELING)
				antag.add_antag_datum(/datum/antagonist/changeling)


/proc/config_to_roles(list/check_list)
	var/list/new_list = list()
	for(var/index in check_list)
		switch(index)
			if("hijacker")
				new_list += ROLE_HIJACKER
				new_list[ROLE_HIJACKER] = check_list[index]
			if("malfai")
				new_list += ROLE_MALF_AI
				new_list[ROLE_MALF_AI] = check_list[index]
			if("ninja")
				new_list += ROLE_NINJA
				new_list[ROLE_NINJA] = check_list[index]
			if("thief")
				new_list += ROLE_THIEF
				new_list[ROLE_THIEF] = check_list[index]
			if("nothing")
				new_list += ROLE_NONE
				new_list[ROLE_NONE] = check_list[index]
			else
				new_list += index
				new_list[index] = check_list[index]
	return new_list

