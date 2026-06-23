/datum/mind/proc/init_skills(mob/user)
	for(var/skill_name in GLOB.skills)
		var/datum/skill/skill = GLOB.skills[skill_name]
		set_skill_level(skill.type, DEFAULT_SKILL_LEVEL)

/datum/mind/proc/get_skill_level(skill_type)
	var/level = skills[skill_type]
	if(level == null)
		return SKILL_LEVEL_UNAVAILABLE
	return level

/datum/mind/proc/set_skill_level(skill_type, level)
	skills[skill_type] = level

/datum/mind/proc/register_skill_signals_for_user(mob/user)
	if(skills_initialized)
		unregister_skill_signals_for_user(skills_initialized)
	skills_initialized = user
	RegisterSignal(user, COMSIG_GET_SKILL_LEVEL, PROC_REF(get_skill_level_from_signal))
	RegisterSignal(user, COMSIG_SKILL_AVAILABLE, PROC_REF(get_skill_available_from_signal))
	for(var/skill_name in GLOB.skills)
		var/datum/skill/skill = GLOB.skills[skill_name]
		skill.apply_to_mob(user)

/datum/mind/proc/unregister_skill_signals_for_user(mob/user)
	UnregisterSignal(user, list(COMSIG_GET_SKILL_LEVEL, COMSIG_SKILL_AVAILABLE))
	for(var/skill_name in GLOB.skills)
		var/datum/skill/skill = GLOB.skills[skill_name]
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
