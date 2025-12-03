/// Global list of all skills in game
GLOBAL_LIST_EMPTY(skills)

/*
 * Basic skill datum
 */
/datum/skill
	var/id
	var/category
	var/category_color = "#776f96"
	var/name
	var/desc
	// Signals for subscribe
	var/list/duration_mod_signals = list()
	var/list/quality_mod_signals = list()
	// Default modifiers
	var/speed_modifiers = list(
		SKILL_LEVEL_NONE = 2,
		SKILL_LEVEL_BEGINNER = 1.5,
		SKILL_LEVEL_BASIC = 1,
		SKILL_LEVEL_ADVANCED = 0.75,
		SKILL_LEVEL_PROFESSIONAL = 0.5,
		SKILL_LEVEL_EXPERT = 0.25,
		SKILL_LEVEL_LEGEND = 0.1,
		SKILL_LEVEL_UNAVAILABLE = 1000,
	)
	var/quality_modifiers = list(
		SKILL_LEVEL_NONE = 0.5,
		SKILL_LEVEL_BEGINNER = 0.75,
		SKILL_LEVEL_BASIC = 1,
		SKILL_LEVEL_ADVANCED = 1.25,
		SKILL_LEVEL_PROFESSIONAL = 1.5,
		SKILL_LEVEL_EXPERT = 2,
		SKILL_LEVEL_LEGEND = 3,
		SKILL_LEVEL_UNAVAILABLE = 0.001,
	)

/datum/skill/proc/apply_to_mob(mob/owner)
	for(var/signal as anything in duration_mod_signals)
		RegisterSignal(owner, signal, PROC_REF(get_duration_mod_signal))
	for(var/signal as anything in quality_mod_signals)
		RegisterSignal(owner, signal, PROC_REF(get_quality_mod_signal))

/datum/skill/proc/get_duration_mod_signal(mob/living/user, list/modifiers)
	SIGNAL_HANDLER
	GET_SKILL_LEVEL(user, src.type, level)
	if(!level)
		return
	var/mod = speed_modifiers[level]
	if(mod != null)
		modifiers.Add(mod)

/datum/skill/proc/get_quality_mod_signal(mob/living/user, list/modifiers)
	SIGNAL_HANDLER
	GET_SKILL_LEVEL(user, src.type, level)
	if(!level)
		return
	var/mod = quality_modifiers[level]
	if(mod != null)
		modifiers.Add(mod)

/datum/skill/proc/remove_from_mob(mob/owner)
	UnregisterSignal(owner, duration_mod_signals)
	UnregisterSignal(owner, quality_mod_signals)


// load job defined skills
/datum/job/proc/apply_skills(mob/living/carbon/human/user)
	if(!user.mind)
		return
	var/datum/mind/user_mind = user.mind
	for(var/skill_name in GLOB.skills)
		var/datum/skill/skill = GLOB.skills[skill_name]
		var/level = get_skill_level(skill.type)
		user_mind.set_skill_level(skill.type, level)
		if(level != SKILL_LEVEL_UNAVAILABLE)
			skill.apply_to_mob(user)

// Show skills window from verbs
/mob/verb/view_skills_win()
	set name = "Навыки персонажа"
	set category = STATPANEL_IC
	if(mind)
		GLOB.skills_window.ui_interact(usr)
	else
		to_chat(src, "Произошла неизвестная ошибка, поэтому мы не можем показать вам ваши навыки.")
