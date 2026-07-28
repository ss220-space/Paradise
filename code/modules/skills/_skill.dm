/// Global list of all skills in game
GLOBAL_LIST_EMPTY(skills)
GLOBAL_LIST_EMPTY(skill_manual_types)

/*
 * Basic skill datum
 */
/datum/skill
	var/id
	var/category
	var/category_color = "#776f96"
	var/name
	var/desc
	var/list/duration_mod_names = list()
	var/list/quality_mod_names = list()
	// Default modifiers
	var/speed_modifiers = alist(
		SKILL_LEVEL_NONE = 1.5,
		SKILL_LEVEL_BEGINNER = 1.25,
		SKILL_LEVEL_BASIC = 1,
		SKILL_LEVEL_ADVANCED = 0.8,
		SKILL_LEVEL_PROFESSIONAL = 0.7,
		SKILL_LEVEL_EXPERT = 0.6,
		SKILL_LEVEL_LEGEND = 0.5,
		SKILL_LEVEL_UNAVAILABLE = 1000,
	)
	var/quality_modifiers = alist(
		SKILL_LEVEL_NONE = 0.5,
		SKILL_LEVEL_BEGINNER = 0.75,
		SKILL_LEVEL_BASIC = 1,
		SKILL_LEVEL_ADVANCED = 1.25,
		SKILL_LEVEL_PROFESSIONAL = 1.5,
		SKILL_LEVEL_EXPERT = 1.75,
		SKILL_LEVEL_LEGEND = 2,
		SKILL_LEVEL_UNAVAILABLE = 0.001,
	)
	var/alist/skills_mods

/datum/skill/New()
	if(!skills_mods)
		skills_mods = new
	for(var/mod_name in duration_mod_names)
		skills_mods[mod_name] = speed_modifiers
	for(var/mod_name in quality_mod_names)
		skills_mods[mod_name] = quality_modifiers

/datum/skill/proc/apply_to_mob(mob/owner)
	for(var/mod_name in skills_mods)
		RegisterSignal(owner, COMSIG_GET_SKILL_MOD(mod_name), PROC_REF(get_skill_modifier))

/datum/skill/proc/get_skill_modifier(mob/living/user, alist/results, mod_name)
	SIGNAL_HANDLER
	get_modifier(user, results, mod_name)

/datum/skill/proc/get_modifier(mob/living/user, list/results, mod_name)
	SIGNAL_HANDLER
	var/alist/modifiers = skills_mods[mod_name]
	GET_SKILL_LEVEL(user, src.type, level)
	var/mod = modifiers[level]
	if(mod != null)
		results[mod_name] = mod
	else
		log_debug("not found modifier result for user=[user.name] skill=[src.type] modifiers=[modifiers] level=[level]")

/datum/skill/proc/remove_from_mob(mob/owner)
	for(var/mod_name in skills_mods)
		UnregisterSignal(owner, COMSIG_GET_SKILL_MOD(mod_name))

// load job defined skills
/datum/job/proc/apply_skills(mob/living/carbon/human/user)
	var/list/antag_skills = GLOB.antag_skills
	if(!user.mind)
		return
	var/datum/mind/user_mind = user.mind
	for(var/skill_name, skill_datum in GLOB.skills)
		var/datum/skill/skill = skill_datum
		var/level = get_skill_level(skill.type, user.mind.role_alt_title)
		if(user.mind.antag_datums)
			var/antag_skill_level = antag_skills[skill.type]
			if(!antag_skill_level)
				antag_skill_level = SKILL_LEVEL_BASIC
			level = max(level, antag_skill_level)
		user_mind.set_skill_level(skill.type, level)
		if(level == SKILL_LEVEL_UNAVAILABLE)
			skill.remove_from_mob(user)
	user_mind.free_skill_points = base_free_skill_point

// Show skills window from verbs
/mob/verb/view_skills_win()
	set name = "Навыки персонажа"
	set category = VERB_CATEGORY_IC
	if(mind)
		if(mind.free_skill_points > 0 && iscarbon(usr))
			var/datum/ui_module/skills_select_win/tgui = new(usr)
			tgui.show(usr, src)
		else
			GLOB.skills_window.ui_interact(usr)
	else
		to_chat(src, "Произошла неизвестная ошибка, поэтому мы не можем показать вам ваши навыки.")
