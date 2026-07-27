/datum/mind/proc/init_skills(mob/user)
	if(skills_initialized)
		return
	for(var/skill_name, skill_datum in GLOB.skills)
		var/datum/skill/skill = skill_datum
		set_skill_level(skill.type, SKILL_LEVEL_BASIC)

	skills_initialized = user

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
	if(skills_initialized && skills_initialized != user)
		unregister_skill_signals_for_user(skills_initialized)
	if(user != skills_initialized)
		init_skills(user)
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

/datum/mind/proc/apply_antag_skills(ref_job = current.job)
	var/list/antag_skills = GLOB.antag_skills
	var/datum/job/current_job
	if(ref_job)
		current_job = SSjobs.GetJob(ref_job)
	for(var/skill_name, skill_datum in GLOB.skills)
		var/datum/skill/skill = skill_datum
		var/antag_skill_level = antag_skills[skill.type]
		if(!antag_skill_level)
			antag_skill_level = SKILL_LEVEL_BASIC
		var/job_skill = SKILL_LEVEL_BASIC
		if(current_job)
			job_skill = current_job.get_skill_level(skill.type, role_alt_title)
		var/level = max(job_skill, antag_skill_level)
		set_skill_level(skill.type, level)
		free_skill_points = BASIC_ANTAG_SKILL_POINTS_COUNT
