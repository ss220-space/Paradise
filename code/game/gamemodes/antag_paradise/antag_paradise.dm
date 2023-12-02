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
	var/list/protected_jobs_AI = list("Civilian","Chief Engineer","Station Engineer","Trainee Engineer","Life Support Specialist","Mechanic","Chief Medical Officer","Medical Doctor","Intern","Coroner","Chemist","Geneticist","Virologist","Psychiatrist","Paramedic","Research Director","Scientist","Student Scientist","Roboticist","Head of Personnel","Chaplain","Bartender","Chef","Botanist","Quartermaster","Cargo Technician","Shaft Miner","Clown","Mime","Janitor","Librarian","Barber","Explorer")	// Basically all jobs, except AI.
	var/secondary_protected_species = list("Machine")
	var/vampire_restricted_jobs = list("Chaplain")
	var/list/datum/mind/pre_traitors = list()
	var/list/datum/mind/pre_thieves = list()
	var/list/datum/mind/pre_changelings = list()
	var/list/datum/mind/pre_vampires = list()
	var/list/datum/mind/traitor_vampires = list()
	var/list/datum/mind/traitor_changelings = list()
	var/list/antag_required_players = list(
		ROLE_TRAITOR = 10,
		ROLE_THIEF = 10,
		ROLE_VAMPIRE = 15,
		ROLE_CHANGELING = 15,
	)
	var/list/special_antag_required_players = list(
		ROLE_HIJACKER = 30,
		ROLE_MALF_AI = 30,
		ROLE_NINJA = 30,
		ROLE_NONE = 0,
	)
	var/list/antag_amount = list(
		ROLE_TRAITOR = 0,
		ROLE_THIEF = 0,
		ROLE_VAMPIRE = 0,
		ROLE_CHANGELING = 0,
	)

	/// Chosen antag type.
	var/special_antag_type
	/// Chosen special antag if any.
	var/datum/mind/special_antag


/datum/game_mode/antag_paradise/announce()
	to_chat(world, "<b>The current game mode is - Antag Paradise</b>")
	to_chat(world, "<b>Traitors, thieves, vampires and changelings, oh my! Stay safe as these forces work to bring down the station.</b>")


/datum/game_mode/antag_paradise/pre_setup()
	. = FALSE

	calculate_antags()

	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		restricted_jobs += protected_jobs

	switch(special_antag_type)
		if(ROLE_HIJACKER)
			special_antag = safepick(get_players_for_role(ROLE_TRAITOR))
			if(special_antag)
				special_antag.restricted_roles = restricted_jobs
				special_antag.special_role = SPECIAL_ROLE_TRAITOR
			else
				special_antag_type = null

		if(ROLE_MALF_AI)
			special_antag = safepick(get_players_for_role(ROLE_MALF_AI))
			if(special_antag)
				special_antag.restricted_roles = (restricted_jobs|protected_jobs|protected_jobs_AI)
				special_antag.restricted_roles -= "AI"
				special_antag.special_role = SPECIAL_ROLE_TRAITOR
				SSjobs.new_malf = special_antag.current
			else
				special_antag_type = null

		if(ROLE_NINJA)
			if(length(GLOB.ninjastart))
				special_antag = safepick(get_players_for_role(ROLE_NINJA))
				if(special_antag)
					special_antag.current.loc = pick(GLOB.ninjastart)
					special_antag.assigned_role = SPECIAL_ROLE_SPACE_NINJA // assigned role and special role must be the same so they aren't chosen for other jobs.
					special_antag.special_role = SPECIAL_ROLE_SPACE_NINJA
					special_antag.offstation_role = TRUE // ninja can't be targeted as a victim for some pity traitors
				else
					special_antag_type = null
			else
				log_and_message_admins("No positions are found to spawn space ninja antag. Report this to coders.")
				special_antag_type = null

	if(antag_amount[ROLE_VAMPIRE])
		var/list/datum/mind/possible_vampires = get_players_for_role(ROLE_VAMPIRE)
		while(length(possible_vampires) && length(pre_vampires) < antag_amount[ROLE_VAMPIRE])
			var/datum/mind/vampire = pick_n_take(possible_vampires)
			if(vampire.current.client.prefs.species in secondary_protected_species)
				continue
			if(vampire.special_role)
				continue
			pre_vampires += vampire
			vampire.special_role = SPECIAL_ROLE_VAMPIRE
			vampire.restricted_roles = (restricted_jobs|vampire_restricted_jobs)

	if(antag_amount[ROLE_CHANGELING])
		var/list/datum/mind/possible_changelings = get_players_for_role(ROLE_CHANGELING)
		while(length(possible_changelings) && length(pre_changelings) < antag_amount[ROLE_CHANGELING])
			var/datum/mind/changeling = pick_n_take(possible_changelings)
			if(changeling.current.client.prefs.species in secondary_protected_species)
				continue
			if(changeling.special_role)
				continue
			pre_changelings += changeling
			changeling.special_role = SPECIAL_ROLE_CHANGELING
			changeling.restricted_roles = restricted_jobs

	if(antag_amount[ROLE_TRAITOR])
		var/list/datum/mind/possible_traitors = get_players_for_role(ROLE_TRAITOR)
		while(length(possible_traitors) && length(pre_traitors) < antag_amount[ROLE_TRAITOR])
			var/datum/mind/traitor = pick_n_take(possible_traitors)
			if(traitor.special_role)
				continue
			pre_traitors += traitor
			traitor.special_role = SPECIAL_ROLE_TRAITOR
			traitor.restricted_roles = restricted_jobs

	if(antag_amount[ROLE_THIEF])
		var/list/datum/mind/possible_thieves = get_players_for_role(ROLE_THIEF, list("Vox" = 4))
		while(length(possible_thieves) && length(pre_thieves) < antag_amount[ROLE_THIEF])
			var/datum/mind/thief = pick_n_take(possible_thieves)
			listclearduplicates(thief, possible_thieves)
			if(thief.special_role)
				continue
			pre_thieves += thief
			thief.special_role = SPECIAL_ROLE_THIEF
			thief.restricted_roles = restricted_jobs

	if(!(length(pre_vampires) + length(pre_changelings) + length(pre_traitors) + length(pre_thieves)) && !special_antag)
		return

	. = TRUE

	var/chance_double_antag = isnull(GLOB.antag_paradise_double_antag_chance) ? CONFIG_GET(number/antag_paradise_double_antag_chance) : GLOB.antag_paradise_double_antag_chance
	if(!chance_double_antag || !length(pre_traitors))
		return

	for(var/T in pre_traitors)
		if(!prob(chance_double_antag))
			continue

		var/datum/mind/traitor = T
		var/list/available_roles = list(ROLE_VAMPIRE, ROLE_CHANGELING)
		while(length(available_roles))
			var/second_role = pick_n_take(available_roles)

			if(second_role == ROLE_VAMPIRE && \
				!jobban_isbanned(traitor.current, second_role) && \
				player_old_enough_antag(traitor.current.client, second_role) && \
				(second_role in traitor.current.client.prefs.be_special) && \
				!(traitor.current.client.prefs.species in secondary_protected_species))

				traitor_vampires += traitor
				traitor.restricted_roles |= vampire_restricted_jobs
				break

			if(second_role == ROLE_CHANGELING && \
				!jobban_isbanned(traitor.current, second_role) && \
				player_old_enough_antag(traitor.current.client, second_role) && \
				(second_role in traitor.current.client.prefs.be_special) && \
				!(traitor.current.client.prefs.species in secondary_protected_species))

				traitor_changelings += traitor
				break


/datum/game_mode/antag_paradise/proc/calculate_antags()
	var/players = num_players()
	var/scale = CONFIG_GET(number/traitor_scaling) ? CONFIG_GET(number/traitor_scaling) : 10
	var/antags_amount = 1 + round(players / scale)

	var/list/special_antags_list = GLOB.antag_paradise_special_weights ? GLOB.antag_paradise_special_weights.Copy() : config_to_roles(CONFIG_GET(keyed_list/antag_paradise_special_weights))
	for(var/antag in special_antag_required_players)
		if(players < special_antag_required_players[antag])
			special_antags_list -= antag

	if(length(special_antags_list))
		special_antag_type = pick_weight_classic(special_antags_list)
		if(special_antag_type && special_antag_type != ROLE_NONE)
			antags_amount--

	var/list/antags_list = GLOB.antag_paradise_weights ? GLOB.antag_paradise_weights.Copy() : config_to_roles(CONFIG_GET(keyed_list/antag_paradise_weights))
	for(var/antag in antag_required_players)
		if(players < antag_required_players[antag])
			antags_list -= antag

	var/modified_weights = FALSE
	for(var/antag in antags_list)
		if(antags_list[antag])
			modified_weights = TRUE

	if(!modified_weights)
		var/mode_type = pick_weight_classic(CONFIG_GET(keyed_list/antag_paradise_mode_subtypes))
		if(mode_type == ANTAG_RANDOM)
			for(var/antag in antags_list)
				antags_list[antag] = rand(1, 100)
		else
			var/list/available_antags = antags_list.Copy()
			var/list/subtype_weights = CONFIG_GET(keyed_list/antag_paradise_subtype_weights)
			while(length(available_antags))
				antags_list[pick_n_take(available_antags)] = subtype_weights[ANTAG_SINGLE]
				if(!length(available_antags) || mode_type == ANTAG_SINGLE)
					break
				antags_list[pick_n_take(available_antags)] = subtype_weights[ANTAG_DOUBLE]
				if(!length(available_antags) || mode_type == ANTAG_DOUBLE)
					break
				antags_list[pick_n_take(available_antags)] = subtype_weights[ANTAG_TRIPPLE]
				break

	for(var/i in 1 to antags_amount)
		antag_amount[pick_weight_classic(antags_list)]++


/datum/game_mode/antag_paradise/post_setup()
	switch(special_antag_type)
		if(ROLE_HIJACKER)
			var/datum/antagonist/traitor/hijacker_datum = new
			hijacker_datum.is_hijacker = TRUE
			addtimer(CALLBACK(special_antag, TYPE_PROC_REF(/datum/mind, add_antag_datum), hijacker_datum), rand(1 SECONDS, 10 SECONDS))

		if(ROLE_MALF_AI)
			if(isAI(special_antag.current))
				addtimer(CALLBACK(special_antag, TYPE_PROC_REF(/datum/mind, add_antag_datum), /datum/antagonist/malf_ai), rand(1 SECONDS, 10 SECONDS))
			else
				log_and_message_admins("[special_antag] was not assigned for AI role. Report this to coders.")

		if(ROLE_NINJA)
			var/datum/antagonist/ninja/ninja_datum = new
			ninja_datum.antag_paradise_mode_chosen = TRUE
			special_antag.add_antag_datum(ninja_datum)

	addtimer(CALLBACK(src, PROC_REF(initiate_minor_antags)), rand(1 SECONDS, 10 SECONDS))
	..()


/datum/game_mode/antag_paradise/proc/initiate_minor_antags()
	for(var/datum/mind/vampire in pre_vampires)
		vampire.add_antag_datum(/datum/antagonist/vampire)
	for(var/datum/mind/changeling in pre_changelings)
		changeling.add_antag_datum(/datum/antagonist/changeling)
	for(var/datum/mind/traitor in pre_traitors)
		traitor.add_antag_datum(/datum/antagonist/traitor)
	for(var/datum/mind/thief in pre_thieves)
		thief.add_antag_datum(/datum/antagonist/thief)

	// traitor double antags
	for(var/datum/mind/vampire in traitor_vampires)
		vampire.add_antag_datum(/datum/antagonist/vampire)
	for(var/datum/mind/changeling in traitor_changelings)
		changeling.add_antag_datum(/datum/antagonist/changeling)


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
			if("nothing")
				new_list += ROLE_NONE
				new_list[ROLE_NONE] = check_list[index]
			else
				new_list += index
				new_list[index] = check_list[index]
	return new_list

