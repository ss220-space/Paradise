/datum/mind/proc/init_skills(mob/user)
	if(skills_initialized)
		return
	var/list/cached_selected_skills_levels = selected_skills_levels
	for(var/skill_name, skill_datum in GLOB.skills)
		var/datum/skill/skill = skill_datum
		cached_selected_skills_levels[skill.type] = SKILL_LEVEL_BEGINNER
	refresh_skills()
	skills_initialized = WEAKREF(user)

/datum/mind/proc/get_skill_level(skill_type)
	var/level = skills[skill_type]
	if(level == null)
		return SKILL_LEVEL_BASIC
	return level

/datum/mind/proc/set_skill_level(skill_type, level)
	skills[skill_type] = level

/datum/mind/proc/register_skill_signals_for_user(mob/user)
	if(!user)
		return
	if(skills_initialized && skills_initialized != WEAKREF(user))
		unregister_skill_signals_for_user(skills_initialized.resolve())
	if(user != skills_initialized)
		if(!length(skills))
			init_skills(user)
		else
			skills_initialized = WEAKREF(user)
		RegisterSignal(user, COMSIG_GET_SKILL_LEVEL, PROC_REF(get_skill_level_from_signal))
		RegisterSignal(user, COMSIG_SKILL_AVAILABLE, PROC_REF(get_skill_available_from_signal))
		for(var/skill_name, skill_datum in GLOB.skills)
			var/datum/skill/skill = skill_datum
			skill.apply_to_mob(user)

/datum/mind/proc/unregister_skill_signals_for_user(mob/user)
	if(!user)
		return
	UnregisterSignal(user, list(COMSIG_GET_SKILL_LEVEL, COMSIG_SKILL_AVAILABLE))
	for(var/skill_name, skill_datum in GLOB.skills)
		var/datum/skill/skill = skill_datum
		skill.remove_from_mob(user)
	skills_initialized = null

/datum/mind/proc/get_skill_level_from_signal(datum/source, skill_type, list/levels)
	SIGNAL_HANDLER
	levels.Add(get_skill_level(skill_type))

/datum/mind/proc/get_skill_available_from_signal(datum/source, skill_type)
	SIGNAL_HANDLER
	if(get_skill_level(skill_type) == SKILL_LEVEL_UNAVAILABLE)
		return SKILL_NOT_AVAILABLE_RESULT
	return SKILL_AVAILABLE_RESULT

/datum/mind/proc/give_basic_skills()
	for(var/skill_name, skill_datum in GLOB.skills)
		var/datum/skill/skill = skill_datum
		set_skill_level(skill.type, SKILL_LEVEL_BASIC)

/datum/mind/proc/refresh_skills(ref_job = current.job)
	skills = list()

	if(!ishuman(current))
		give_basic_skills()
		return

	var/list/antag_skills = GLOB.antag_skills
	var/datum/job/current_job
	if(ref_job)
		current_job = SSjobs.GetJob(ref_job)
	var/is_antag = HAS_TRAIT(src, TRAIT_HAS_ANTAG_SKILLS)
	var/basic_skill = is_antag? SKILL_LEVEL_BASIC : SKILL_LEVEL_NONE
	var/list/cached_manual_bonuses = active_skill_bonuses
	var/list/cached_neurotrainer_bonuses = active_neurotrainer_bonuses
	var/list/cached_manual_skill_bonuses = manual_skill_bonuses
	var/list/cached_selected_skills_levels = selected_skills_levels
	for(var/skill_name, skill_datum in GLOB.skills)
		var/datum/skill/skill = skill_datum
		var/datum/skill/skill_type = skill.type
		var/antag_skill_level = basic_skill
		if(is_antag)
			antag_skill_level = antag_skills[skill_type] || basic_skill
		var/job_skill = basic_skill
		if(current_job)
			job_skill = current_job.get_skill_level(skill_type, role_alt_title)
		if(job_alt_skills && (skill_type in job_alt_skills))
			job_skill = job_alt_skills[skill_type]
		var/level = max(job_skill, antag_skill_level)
		if(skill_type in cached_selected_skills_levels)
			level += cached_selected_skills_levels[skill_type]
		if(skill_type in cached_manual_bonuses)
			level = min(level + cached_manual_bonuses[skill_type], SKILL_LEVEL_PROFESSIONAL)
		if(skill_type in cached_manual_skill_bonuses)
			level = min(level + cached_manual_skill_bonuses[skill_type], SKILL_LEVEL_PROFESSIONAL)
		if(skill_type in cached_neurotrainer_bonuses)
			level = min(level + cached_neurotrainer_bonuses[skill_type], SKILL_LEVEL_LEGEND)
		if(level == SKILL_LEVEL_UNAVAILABLE)
			skill.remove_from_mob(current)
		set_skill_level(skill_type, level)

/datum/mind/proc/get_skills_for_skills_select(ref_job = current.job)
	var/skills = list()
	var/list/antag_skills = GLOB.antag_skills
	var/datum/job/current_job
	if(ref_job)
		current_job = SSjobs.GetJob(ref_job)
	var/is_antag = HAS_TRAIT(src, TRAIT_HAS_ANTAG_SKILLS)
	var/basic_skill = is_antag? SKILL_LEVEL_BASIC : SKILL_LEVEL_NONE
	var/list/cached_neurotrainer_bonuses = active_neurotrainer_bonuses
	var/list/cached_selected_skills_levels = selected_skills_levels
	for(var/skill_name, skill_datum in GLOB.skills)
		var/datum/skill/skill = skill_datum
		var/datum/skill/skill_type = skill.type
		var/antag_skill_level = basic_skill
		if(is_antag)
			antag_skill_level = antag_skills[skill_type] || basic_skill
		var/job_skill = basic_skill
		if(current_job)
			job_skill = current_job.get_skill_level(skill_type, role_alt_title)
		if(job_alt_skills && (skill_type in job_alt_skills))
			job_skill = job_alt_skills[skill_type]
		var/level = max(job_skill, antag_skill_level)
		if(skill_type in cached_selected_skills_levels)
			level += cached_selected_skills_levels[skill_type]
		if(skill_type in cached_neurotrainer_bonuses)
			level = min(level + cached_neurotrainer_bonuses[skill_type], SKILL_LEVEL_LEGEND)
		skills[skill_type] = level

	return skills


/datum/mind/proc/recalculate_skills(ref_job = current.job)
	selected_skills_levels = list()
	var/datum/job/current_job
	if(ref_job)
		current_job = SSjobs.GetJob(ref_job)
	var/is_antag = HAS_TRAIT(src, TRAIT_HAS_ANTAG_SKILLS)
	refresh_skills(ref_job)
	var/job_free_skill_points = current_job?.base_free_skill_point || BASIC_SKILL_POINTS_COUNT
	free_skill_points = job_free_skill_points + (is_antag? BASIC_ANTAG_SKILL_POINTS_BONUS : 0)

