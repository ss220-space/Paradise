/datum/dynamic_ruleset/latejoin
	repeatable = TRUE
	max_antag_cap = 1
	var/datum/mind/joiner

/datum/dynamic_ruleset/latejoin/Destroy(force)
	joiner = null
	return ..()

/datum/dynamic_ruleset/latejoin/is_valid_candidate(datum/mind/candidate)
	if(ismindshielded(candidate.current))
		return FALSE
	return ..()

/datum/dynamic_ruleset/latejoin/prepare_execution(population_size)
	if(!can_be_selected())
		log_data = "ruleset can no longer be selected"
		return FALSE
	if(!is_valid_candidate(joiner))
		log_data = "[joiner.name] is not a valid candidate"
		return FALSE
	if(jobban_isbanned(joiner.current, ROLE_SYNDICATE) || jobban_isbanned(joiner.current, antag_role))
		log_data = "[joiner.name] is banned from the role"
		return FALSE
	if(!player_old_enough_antag(joiner.current.client, antag_role))
		log_data = "[joiner.name] is not old enough for the role"
		return FALSE
	var/client/joiner_client = joiner.current.client
	if(joiner_client.prefs.skip_antag || !(antag_role in joiner_client.prefs.be_special))
		log_data = "[joiner.name] does not want the role"
		return FALSE

	joiner.special_role = special_role
	selected_minds += joiner
	return TRUE

/datum/dynamic_ruleset/latejoin/traitor
	name = "Traitor"
	config_tag = "latejoin traitor"
	antag_role = ROLE_TRAITOR
	special_role = SPECIAL_ROLE_TRAITOR
	weight = 10
	min_pop = 5

/datum/dynamic_ruleset/latejoin/traitor/assign_role(datum/mind/candidate)
	candidate.add_antag_datum(/datum/antagonist/traitor)

/datum/dynamic_ruleset/latejoin/thief
	name = "Thief"
	config_tag = "latejoin thief"
	antag_role = ROLE_THIEF
	special_role = SPECIAL_ROLE_THIEF
	weight = 8
	min_pop = 5

/datum/dynamic_ruleset/latejoin/thief/assign_role(datum/mind/candidate)
	candidate.add_antag_datum(/datum/antagonist/thief)

/datum/dynamic_ruleset/latejoin/vampire
	name = "Vampire"
	config_tag = "latejoin vampire"
	antag_role = ROLE_VAMPIRE
	special_role = SPECIAL_ROLE_VAMPIRE
	protected_species = SPECIES_BLOCKED_FOR_VAMPIRE
	blacklisted_roles = list(JOB_TITLE_CHAPLAIN)
	weight = 4
	min_pop = 15

/datum/dynamic_ruleset/latejoin/vampire/assign_role(datum/mind/candidate)
	candidate.add_antag_datum(/datum/antagonist/vampire/new_vampire)

/datum/dynamic_ruleset/latejoin/changeling
	name = "Changeling"
	config_tag = "latejoin changeling"
	antag_role = ROLE_CHANGELING
	special_role = SPECIAL_ROLE_CHANGELING
	protected_species = SPECIES_BLOCKED_FOR_CHANGELING
	weight = 4
	min_pop = 15

/datum/dynamic_ruleset/latejoin/changeling/assign_role(datum/mind/candidate)
	candidate.add_antag_datum(/datum/antagonist/changeling)

/datum/dynamic_ruleset/latejoin/heretic
	name = "Heretic"
	config_tag = "latejoin heretic"
	antag_role = ROLE_HERETIC
	special_role = SPECIAL_ROLE_HERETIC
	blacklisted_roles = list(JOB_TITLE_CHAPLAIN)
	weight = 4
	min_pop = 25

/datum/dynamic_ruleset/latejoin/heretic/assign_role(datum/mind/candidate)
	candidate.add_antag_datum(/datum/antagonist/heretic)
