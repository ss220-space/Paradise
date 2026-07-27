// Skills window tgui
GLOBAL_DATUM_INIT(skills_select_window, /datum/ui_module/skills_select_win, new)

/datum/ui_module/skills_select_win
	name = "Распределение свободных очков навыков"
	/// Unlimited actions
	var/admin_interact
	/// Target user
	var/mob/target_user

/datum/ui_module/skills_select_win/ui_state(mob/user)
	if(isobserver(user))
		return ..()
	if(!target_user.mind || !target_user.dna || !target_user.dna.species)
		return ..()
	return GLOB.not_incapacitated_state

/datum/ui_module/skills_select_win/proc/show(mob/user, mob/target, admin_interact = FALSE)
	src.admin_interact = admin_interact
	target_user = target
	ui_interact(user)

/datum/ui_module/skills_select_win/ui_interact(mob/user, datum/tgui/ui = null)
	// prepare temp variable for store skill points
	if(!target_user.mind.selected_skills)
		target_user.mind.selected_skills = list()
		reset_skill_points(target_user)

	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SkillsSelectWin", "Распределение навыков персонажа " + target_user.real_name)
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/ui_module/skills_select_win/ui_data(mob/user)
	//create root data
	var/list/data = list()
	//create skills container
	data["username"] = target_user.real_name
	data["job"] = target_user.job
	data["admin"] = admin_interact
	var/used_points = collect_used_skill_points(target_user)
	var/total_points = target_user.mind.free_skill_points + target_user.dna.species.bonus_skill_free_points
	var/free_points = total_points - used_points
	data["total_point"] = total_points
	data["free_points"] = free_points

	//create intermediate data format
	var/list/list/datum/skill/categories_map = list()
	for(var/skill_name, skill_datum in GLOB.skills)
		var/datum/skill/skill = skill_datum
		if(categories_map[skill.category] == null)
			categories_map[skill.category] = list()
		categories_map[skill.category].Add(skill)

	//create categories
	var/list/categories = list()
	for(var/category_name in categories_map)
		var/list/category = list()
		category["name"] = category_name
		var/list/datum/skill/category_skills = categories_map[category_name]
		if(!length(category_skills))
			continue
		category["color"] = category_skills[1].category_color

		var/list/skills = list()
		for(var/datum/skill/skill as anything in category_skills)
			var/list/skill_data = list()
			skill_data["id"] = skill.type
			skill_data["name"] = skill.name
			GET_SKILL_LEVEL(target_user, skill.type, skill_level)
			var/skill_used_points = target_user.mind.selected_skills[skill.type]
			var/max_skill_delta = DEFAULT_FREE_POINTS_USE_LIMIT
			if(skill.type in target_user.dna.species.max_select_skills)
				max_skill_delta = target_user.dna.species.max_select_skills[skill.type]
			var/actual_skill_level = skill_level + skill_used_points
			var/skill_level_name = GLOB.skill_level_names[actual_skill_level]
			skill_data["value"] = "[skill_level_name] ([actual_skill_level])"
			var/skill_level_color = GLOB.skill_level_colors[actual_skill_level]
			skill_data["level_color"] = skill_level_color
			skill_data["desc"] = skill.desc
			if(admin_interact)
				skill_data["can_increase"] = actual_skill_level < SKILL_LEVEL_LEGEND
				skill_data["can_decrease"] = actual_skill_level > 0
			else
				skill_data["can_increase"] = skill_used_points < max_skill_delta && actual_skill_level < SKILL_LEVEL_EXPERT && skill_level != SKILL_LEVEL_UNAVAILABLE && free_points > 0
				skill_data["can_decrease"] = skill_used_points > 0
			skills.Add(list(skill_data))

		category["skills"] = skills
		categories.Add(list(category))

	data["categories"] = categories

	data["can_save"] = admin_interact || free_points != 0
	return data


/datum/ui_module/skills_select_win/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = TRUE
	switch(action)
		if("increase")
			var/skill = text2path(params["skill"])
			add_skill_level(target_user, skill, 1)

		if("decrease")
			var/skill = text2path(params["skill"])
			add_skill_level(target_user, skill, -1)

		if("save")
			save_skills(target_user)
			ui.close()
			return FALSE

		if("reset")
			reset_skill_points(target_user)

		else
			return ..()


/datum/ui_module/skills_select_win/proc/collect_used_skill_points(mob/user)
	if(!user.mind.selected_skills)
		return 0
	var/used_points = 0
	for(var/skill in user.mind.selected_skills)
		used_points += user.mind.selected_skills[skill]
	return used_points

/datum/ui_module/skills_select_win/proc/add_skill_level(mob/user, skill, delta)
	var/used_points = user.mind.selected_skills[skill]
	if(!admin_interact)
		var/max_skill_delta = DEFAULT_FREE_POINTS_USE_LIMIT
		if(skill in user.dna.species.max_select_skills)
			max_skill_delta = user.dna.species.max_select_skills[skill]
		if(used_points + delta > max_skill_delta)
			delta = max_skill_delta - used_points
	if(used_points < 0)
		user.mind.selected_skills[skill] = 0
		return
	GET_SKILL_LEVEL(target_user, skill, skill_level)
	if(skill_level + used_points > SKILL_LEVEL_LEGEND)
		user.mind.selected_skills[skill] = SKILL_LEVEL_LEGEND - skill_level
		return
	user.mind.selected_skills[skill] += delta

/datum/ui_module/skills_select_win/proc/save_skills(mob/user)
	var/total_used_points = collect_used_skill_points(user)
	if(!admin_interact && total_used_points != user.mind.free_skill_points + user.dna.species.bonus_skill_free_points)
		to_chat(user, span_notice("Распределите все очки!"))
		return //TODO использовать tgui окно с вопросом, в случае отказа рандомно распределить свободные очки

	for(var/skill in user.mind.selected_skills)
		var/used_points = user.mind.selected_skills[skill]
		if(used_points <= 0)
			continue
		user.mind.skills[skill] += used_points

	// cleanup
	user.mind.selected_skills = null
	user.mind.free_skill_points = 0

/datum/ui_module/skills_select_win/proc/reset_skill_points(mob/user)
	for(var/skill in user.mind.selected_skills)
		user.mind.selected_skills[skill] = 0
