/datum/dynamic_ruleset
	var/name = "Ruleset"
	var/config_tag
	var/antag_role
	var/special_role
	var/required_job_rank
	var/ruleset_flags = NONE
	var/weight = 0
	var/min_pop = 0
	var/min_round_time = 0
	var/min_antag_cap = 1
	var/max_antag_cap
	var/repeatable = FALSE
	var/repeatable_weight_decrease = 2
	var/list/blacklisted_roles = list()
	var/always_protect_roles = FALSE
	var/list/protected_species
	var/list/preferred_species
	var/list/datum/mind/selected_minds = list()
	var/list/cached_blacklisted_roles
	var/log_data

/datum/dynamic_ruleset/New()
	var/list/weight_overrides = CONFIG_GET(keyed_list/dynamic_ruleset_weights)
	if(config_tag in weight_overrides)
		weight = weight_overrides[config_tag]
	var/list/min_pop_overrides = CONFIG_GET(keyed_list/dynamic_ruleset_min_pop)
	if(config_tag in min_pop_overrides)
		min_pop = min_pop_overrides[config_tag]

/datum/dynamic_ruleset/Destroy(force)
	selected_minds = null
	return ..()

/datum/dynamic_ruleset/proc/can_be_selected()
	return TRUE

/datum/dynamic_ruleset/proc/get_tier_value(value, tier)
	if(!isalist(value))
		return value
	var/alist/tiered_values = value
	if(isnum(tiered_values[tier]))
		return tiered_values[tier]
	for(var/higher_tier in tier to DYNAMIC_TIER_HIGH)
		if(isnum(tiered_values[higher_tier]))
			return tiered_values[higher_tier]
	for(var/lower_tier in tier to DYNAMIC_TIER_GREEN step -1)
		if(isnum(tiered_values[lower_tier]))
			return tiered_values[lower_tier]
	return 0

/datum/dynamic_ruleset/proc/get_weight(population_size, tier)
	if(!can_be_selected())
		return 0
	if(get_tier_value(min_pop, tier) > population_size)
		return 0
	if(ROUND_TIME < get_tier_value(min_round_time, tier))
		return 0
	return get_tier_value(weight, tier)

/datum/dynamic_ruleset/proc/get_antag_cap(population_size, antag_cap)
	if(isnum(antag_cap))
		return antag_cap
	return ceil(population_size / antag_cap["denominator"]) + antag_cap["offset"]

/datum/dynamic_ruleset/proc/get_blacklisted_roles()
	if(cached_blacklisted_roles)
		return cached_blacklisted_roles

	cached_blacklisted_roles = SSticker.mode.get_restricted_roles() | blacklisted_roles
	if(always_protect_roles)
		for(var/datum/job/job as anything in SSjobs.occupations)
			if(job.job_flags & JOB_ANTAG_PROTECTED)
				cached_blacklisted_roles |= job.title
	return cached_blacklisted_roles

/datum/dynamic_ruleset/proc/is_valid_candidate(datum/mind/candidate)
	SHOULD_CALL_PARENT(TRUE)
	if(candidate.special_role || candidate.offstation_role)
		return FALSE
	if(length(protected_species) && (candidate.current.client?.prefs.species in protected_species))
		return FALSE
	if(candidate.assigned_role in get_blacklisted_roles())
		return FALSE
	return TRUE

/datum/dynamic_ruleset/proc/trim_candidates(list/datum/mind/candidates)
	. = list()
	for(var/datum/mind/candidate as anything in candidates)
		if(!is_valid_candidate(candidate))
			continue
		. += candidate

/datum/dynamic_ruleset/proc/prepare_execution(population_size)
	if(!can_be_selected())
		log_data = "ruleset can no longer be selected"
		return FALSE

	var/list/datum/mind/candidates = trim_candidates(SSticker.mode.get_players_for_role(antag_role, preferred_species, required_job_rank))
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

	var/list/restricted_roles = get_blacklisted_roles()
	for(var/datum/mind/candidate as anything in picked_candidates)
		candidate.special_role = special_role
		candidate.restricted_roles = restricted_roles.Copy()
		prepare_for_role(candidate)
		selected_minds += candidate

	return TRUE

/datum/dynamic_ruleset/proc/prepare_for_role(datum/mind/candidate)
	return

/datum/dynamic_ruleset/proc/execute()
	var/list/execute_args = create_execute_args()
	for(var/datum/mind/candidate as anything in selected_minds)
		assign_role(arglist(list(candidate) + execute_args))

/datum/dynamic_ruleset/proc/create_execute_args()
	return list()

/datum/dynamic_ruleset/proc/assign_role(datum/mind/candidate)
	CRASH("Ruleset [type] does not implement assign_role()")
