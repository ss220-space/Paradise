/datum/dynamic_ruleset/midround
	repeatable = TRUE
	var/skip_mindshielded = TRUE

/datum/dynamic_ruleset/midround/proc/collect_candidates()
	return SSticker.mode.get_alive_players_for_role(antag_role, preferred_species, required_job_rank)

/datum/dynamic_ruleset/midround/is_valid_candidate(datum/mind/candidate)
	if(skip_mindshielded && ismindshielded(candidate.current))
		return FALSE
	return ..()

/datum/dynamic_ruleset/midround/prepare_execution(population_size)
	var/list/datum/mind/candidates = trim_candidates(collect_candidates())
	var/list/datum/mind/picked_candidates = list()
	for(var/i in 1 to get_antag_cap(population_size, max_antag_cap || min_antag_cap))
		if(!length(candidates))
			break
		var/datum/mind/candidate = pick(candidates)
		list_clear_duplicates(candidate, candidates)
		picked_candidates += candidate

	var/needed_candidates = get_antag_cap(population_size, min_antag_cap)
	if(length(picked_candidates) < needed_candidates)
		log_data = "not enough candidates, have [length(picked_candidates)] of [needed_candidates]"
		return FALSE

	for(var/datum/mind/candidate as anything in picked_candidates)
		candidate.special_role = special_role
		selected_minds += candidate

	return TRUE

/datum/dynamic_ruleset/midround/traitor
	name = "Traitor"
	config_tag = "midround traitor"
	antag_role = ROLE_TRAITOR
	special_role = SPECIAL_ROLE_TRAITOR
	weight = 10
	min_pop = 5

/datum/dynamic_ruleset/midround/traitor/assign_role(datum/mind/candidate)
	candidate.add_antag_datum(/datum/antagonist/traitor)

/datum/dynamic_ruleset/midround/thief
	name = "Thief"
	config_tag = "midround thief"
	antag_role = ROLE_THIEF
	special_role = SPECIAL_ROLE_THIEF
	preferred_species = list(SPECIES_VOX = 4)
	weight = 8
	min_pop = 5

/datum/dynamic_ruleset/midround/thief/assign_role(datum/mind/candidate)
	candidate.add_antag_datum(/datum/antagonist/thief)

/datum/dynamic_ruleset/midround/vampire
	name = "Vampire"
	config_tag = "midround vampire"
	antag_role = ROLE_VAMPIRE
	special_role = SPECIAL_ROLE_VAMPIRE
	protected_species = SPECIES_BLOCKED_FOR_VAMPIRE
	blacklisted_roles = list(JOB_TITLE_CHAPLAIN)
	weight = 4
	min_pop = 15

/datum/dynamic_ruleset/midround/vampire/assign_role(datum/mind/candidate)
	candidate.add_antag_datum(/datum/antagonist/vampire/new_vampire)

/datum/dynamic_ruleset/midround/changeling
	name = "Changeling"
	config_tag = "midround changeling"
	antag_role = ROLE_CHANGELING
	special_role = SPECIAL_ROLE_CHANGELING
	protected_species = SPECIES_BLOCKED_FOR_CHANGELING
	weight = 4
	min_pop = 15

/datum/dynamic_ruleset/midround/changeling/assign_role(datum/mind/candidate)
	candidate.add_antag_datum(/datum/antagonist/changeling)

/datum/dynamic_ruleset/midround/heretic
	name = "Heretic"
	config_tag = "midround heretic"
	antag_role = ROLE_HERETIC
	special_role = SPECIAL_ROLE_HERETIC
	blacklisted_roles = list(JOB_TITLE_CHAPLAIN)
	weight = 4
	min_pop = 25

/datum/dynamic_ruleset/midround/heretic/assign_role(datum/mind/candidate)
	candidate.add_antag_datum(/datum/antagonist/heretic)

/datum/dynamic_ruleset/midround/malf_ai
	name = "Malfunctioning AI"
	config_tag = "midround malf ai"
	antag_role = ROLE_MALF_AI
	special_role = SPECIAL_ROLE_MALFAI
	ruleset_flags = RULESET_HIGH_IMPACT
	weight = alist(
		DYNAMIC_TIER_LOW = 0,
		DYNAMIC_TIER_LOWMEDIUM = 1,
		DYNAMIC_TIER_MEDIUMHIGH = 3,
		DYNAMIC_TIER_HIGH = 3,
	)
	min_pop = 30
	min_round_time = alist(
		DYNAMIC_TIER_GREEN = 60 MINUTES,
		DYNAMIC_TIER_LOW = 60 MINUTES,
		DYNAMIC_TIER_LOWMEDIUM = 60 MINUTES,
		DYNAMIC_TIER_MEDIUMHIGH = 60 MINUTES,
		DYNAMIC_TIER_HIGH = 30 MINUTES,
	)
	max_antag_cap = 1
	repeatable = FALSE
	skip_mindshielded = FALSE

/datum/dynamic_ruleset/midround/malf_ai/collect_candidates()
	return SSticker.mode.get_alive_AIs_for_role(antag_role)

/datum/dynamic_ruleset/midround/malf_ai/assign_role(datum/mind/candidate)
	candidate.add_antag_datum(/datum/antagonist/malf_ai)

/datum/dynamic_ruleset/midround/blob
	name = "Blobs"
	config_tag = "midround blob"
	antag_role = ROLE_BLOB
	special_role = SPECIAL_ROLE_BLOB
	protected_species = BLOB_RESTRICTED_SPECIES
	ruleset_flags = RULESET_HIGH_IMPACT
	min_pop = 30
	min_round_time = alist(
		DYNAMIC_TIER_GREEN = 60 MINUTES,
		DYNAMIC_TIER_LOW = 60 MINUTES,
		DYNAMIC_TIER_LOWMEDIUM = 60 MINUTES,
		DYNAMIC_TIER_MEDIUMHIGH = 60 MINUTES,
		DYNAMIC_TIER_HIGH = 30 MINUTES,
	)
	max_antag_cap = list("denominator" = BLOB_PLAYERS_PER_CORE, "offset" = 0)
	repeatable = FALSE
	skip_mindshielded = FALSE

/datum/dynamic_ruleset/midround/blob/collect_candidates()
	. = list()
	for(var/mob/living/carbon/human/player as anything in SSticker.mode.get_blob_candidates())
		. += player.mind

/datum/dynamic_ruleset/midround/blob/assign_role(datum/mind/candidate)
	var/datum_type = candidate.get_blob_infected_type()
	var/datum/antagonist/blob_infected/blob_datum = new datum_type()
	blob_datum.need_new_blob = TRUE
	blob_datum.time_to_burst_hight = TIME_TO_BURST_HIGHT
	blob_datum.time_to_burst_low = TIME_TO_BURST_LOW
	candidate.add_antag_datum(blob_datum)
