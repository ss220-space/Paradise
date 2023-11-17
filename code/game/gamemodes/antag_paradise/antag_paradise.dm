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
	var/thief_prefered_species = list("Vox")
	var/thief_prefered_species_mod = 4
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
		ROLE_TRAITOR = 30,	// hijacker
		ROLE_MALF_AI = 30,
		ROLE_NINJA = 30,
	)
	var/list/antag_amount = list(
		ROLE_TRAITOR = 0,
		ROLE_THIEF = 0,
		ROLE_VAMPIRE = 0,
		ROLE_CHANGELING = 0,
	)

	/// Weight ratio for antags. Higher the weight higher the chance to roll this antag. This values will be modified by config or by admins.
	var/list/antag_weights = list(
		ROLE_TRAITOR = 0,
		ROLE_THIEF = 0,
		ROLE_VAMPIRE = 0,
		ROLE_CHANGELING = 0,
	)

	/// Default chance for traitor to get another antag role, available in prefs.
	var/chance_double_antag = 10

	/// Chosen antag type.
	var/special_antag_type
	/// Chosen special antag if any.
	var/datum/mind/special_antag


/datum/game_mode/antag_paradise/announce()
	to_chat(world, "<b>The current game mode is - Antag Paradise</b>")
	to_chat(world, "<b>Traitors, thieves, vampires and changelings, oh my! Stay safe as these forces work to bring down the station.</b>")


/datum/game_mode/antag_paradise/can_start()
	if(!..())
		return FALSE

	// we need to setup ninja before all the jobs assignment
	// but we can start even if ninja wasn't rolled
	. = TRUE

	calculate_antags()

	if(special_antag_type != ROLE_NINJA)
		return

	if(!length(GLOB.ninjastart))
		log_and_message_admins("No positions are found to spawn space ninja antag. Report this to coders.")
		special_antag_type = null	// its a shame :(
		return

	special_antag = safepick(get_players_for_role(ROLE_NINJA))
	if(!special_antag)
		return

	special_antag.assigned_role = ROLE_NINJA // so they aren't chosen for other jobs.
	special_antag.special_role = SPECIAL_ROLE_SPACE_NINJA
	special_antag.offstation_role = TRUE // ninja can't be targeted as a victim for some pity traitors
	special_antag.set_original_mob(special_antag.current)


/datum/game_mode/antag_paradise/pre_setup()
	. = FALSE

	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		restricted_jobs += protected_jobs

	switch(special_antag_type)
		if(ROLE_TRAITOR)	// hijacker
			special_antag = safepick(get_players_for_role(ROLE_TRAITOR))
			if(special_antag)
				special_antag.restricted_roles = restricted_jobs
			else
				special_antag_type = null

		if(ROLE_MALF_AI)
			special_antag = safepick(get_players_for_role(ROLE_MALF_AI))
			if(special_antag)
				special_antag.restricted_roles = (restricted_jobs|protected_jobs_AI)
				special_antag.restricted_roles -= "AI"
				SSjobs.new_malf = special_antag.current
			else
				special_antag_type = null

		if(ROLE_NINJA)
			special_antag.current.loc = pick(GLOB.ninjastart)

	if(antag_amount[ROLE_VAMPIRE])
		var/list/datum/mind/possible_vampires = get_players_for_role(ROLE_VAMPIRE)
		while(length(possible_vampires) && length(pre_vampires) <= antag_amount[ROLE_VAMPIRE])
			var/datum/mind/vampire = pick_n_take(possible_vampires)
			if(vampire.current.client.prefs.species in secondary_protected_species)
				continue
			if(vampire == special_antag)
				continue
			pre_vampires += vampire
			vampire.special_role = SPECIAL_ROLE_VAMPIRE
			vampire.restricted_roles = (restricted_jobs|vampire_restricted_jobs)

	if(antag_amount[ROLE_CHANGELING])
		var/list/datum/mind/possible_changelings = get_players_for_role(ROLE_CHANGELING)
		while(length(possible_changelings) && length(pre_changelings) <= antag_amount[ROLE_CHANGELING])
			var/datum/mind/changeling = pick_n_take(possible_changelings)
			if(changeling.current.client.prefs.species in secondary_protected_species)
				continue
			if(changeling.special_role || changeling == special_antag)
				continue
			pre_changelings += changeling
			changeling.special_role = SPECIAL_ROLE_CHANGELING
			changeling.restricted_roles = restricted_jobs

	if(antag_amount[ROLE_TRAITOR])
		var/list/datum/mind/possible_traitors = get_players_for_role(ROLE_TRAITOR)
		while(length(possible_traitors) && length(pre_traitors) <= antag_amount[ROLE_TRAITOR])
			var/datum/mind/traitor = pick_n_take(possible_traitors)
			if(traitor.special_role || traitor == special_antag)
				continue
			pre_traitors += traitor
			traitor.special_role = SPECIAL_ROLE_TRAITOR
			traitor.restricted_roles = restricted_jobs

	if(antag_amount[ROLE_THIEF])
		var/list/datum/mind/possible_thieves = get_players_for_role(ROLE_THIEF)
		if(length(possible_thieves))
			var/list/thief_list = list()
			for(var/datum/mind/thief in possible_thieves)
				thief_list += thief
				if(thief.current.client.prefs.species in thief_prefered_species)
					for(var/i in 1 to thief_prefered_species_mod)
						thief_list += thief

			while(length(thief_list) && length(pre_thieves) <= antag_amount[ROLE_THIEF])
				var/datum/mind/thief = pick_n_take(thief_list)
				listclearduplicates(thief, thief_list)
				if(thief.special_role || thief == special_antag)
					continue
				pre_thieves += thief
				thief.special_role = SPECIAL_ROLE_THIEF
				thief.restricted_roles = restricted_jobs

	if(!(length(pre_vampires) + length(pre_changelings) + length(pre_traitors) + length(pre_thieves)) && !special_antag)
		return

	. = TRUE

	if(!chance_double_antag || !length(pre_traitors))
		return

	var/list/pre_traitors_copy = pre_traitors.Copy()
	while(length(pre_traitors_copy))
		if(!prob(chance_double_antag))
			continue

		var/datum/mind/traitor = pick_n_take(pre_traitors_copy)
		var/list/available_roles = list(ROLE_VAMPIRE, ROLE_CHANGELING)
		while(length(available_roles))
			var/second_role = pick_n_take(available_roles)

			if(second_role == ROLE_VAMPIRE && \
				!jobban_isbanned(traitor.current, get_roletext(second_role)) && \
				player_old_enough_antag(traitor.current.client, second_role) && \
				(second_role in traitor.current.client.prefs.be_special) && \
				!(traitor.current.client.prefs.species in secondary_protected_species))

				traitor_vampires += traitor
				traitor.restricted_roles |= vampire_restricted_jobs
				break

			if(second_role == ROLE_CHANGELING && \
				!jobban_isbanned(traitor.current, get_roletext(second_role)) && \
				player_old_enough_antag(traitor.current.client, second_role) && \
				(second_role in traitor.current.client.prefs.be_special) && \
				!(traitor.current.client.prefs.species in secondary_protected_species))

				traitor_changelings += traitor
				break


/datum/game_mode/antag_paradise/proc/calculate_antags()
	var/players = num_players()
	var/scale = CONFIG_GET(number/traitor_scaling) ? CONFIG_GET(number/traitor_scaling) : 10
	var/antags_amount = 1 + round(players / scale)

	chance_double_antag = isnull(GLOB.antag_paradise_double_antag_chance) ? chance_double_antag : GLOB.antag_paradise_double_antag_chance

	var/list/available_special_antags = list()
	for(var/antag in special_antag_required_players)
		if(players < special_antag_required_players[antag])
			continue
		available_special_antags += antag

	special_antag_type = pick_weight_classic(GLOB.antag_paradise_special_weights)
	if(special_antag_type in available_special_antags)
		antags_amount--
	else
		special_antag_type = null

	var/list/available_antags = list()
	for(var/antag in antag_required_players)
		if(players < antag_required_players[antag])
			continue
		available_antags += antag

	var/modifed_weights = FALSE
	for(var/antag in antag_weights)
		if(!(antag in available_antags))
			continue
		antag_weights[antag] = GLOB.antag_paradise_weights[antag]
		if(GLOB.antag_paradise_weights[antag] > 0)
			modifed_weights = TRUE

	if(!modifed_weights)
		var/mode_type = pick_weight_classic(CONFIG_GET(keyed_list/antag_paradise_mode_subtypes))
		var/list/subtype_weights = CONFIG_GET(keyed_list/antag_paradise_subtype_weights)
		if(mode_type == ANTAG_RANDOM)
			for(var/antag in antag_weights)
				if(!(antag in available_antags))
					continue
				var/random = rand(-subtype_weights[ANTAG_RANDOM], subtype_weights[ANTAG_RANDOM])
				antag_weights[antag] = random < 0 ? 0 : random
		else
			while(length(available_antags))
				antag_weights[pick_n_take(available_antags)] = subtype_weights[ANTAG_SINGLE]
				if(!length(available_antags) || mode_type == ANTAG_SINGLE)
					break
				antag_weights[pick_n_take(available_antags)] = subtype_weights[ANTAG_DOUBLE]
				if(!length(available_antags) || mode_type == ANTAG_DOUBLE)
					break
				antag_weights[pick_n_take(available_antags)] = subtype_weights[ANTAG_TRIPPLE]
				break

	for(var/i in 1 to antags_amount)
		antag_amount[pick_weight_classic(antag_weights)]++


/datum/game_mode/antag_paradise/post_setup()
	switch(special_antag_type)
		if(ROLE_TRAITOR)	// hijacker
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

