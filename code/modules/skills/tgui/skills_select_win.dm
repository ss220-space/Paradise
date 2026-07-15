// Skills window tgui
GLOBAL_DATUM_INIT(skills_select_window, /datum/ui_module/skills_select_win, new)

/datum/ui_module/skills_select_win
	name = "Распределение свободных очков навыков"

/datum/ui_module/skills_select_win/ui_state(mob/user)
	if(isobserver(user))
		return ..()
	if(!user.mind)
		return ..()
	return GLOB.not_incapacitated_state

/datum/ui_module/skills_select_win/ui_interact(mob/user, datum/tgui/ui = null)
	// prepare temp variable for store skill points
	if(!user.mind.selected_skills)
		user.mind.selected_skills = list()
		reset_skill_points(user)

	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SkillsSelectWin", name)
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/ui_module/skills_select_win/ui_data(mob/user)
	//create root data
	var/list/data = list()
	//create skills container
	data["username"] = user.real_name
	data["job"] = user.job
	var/used_points = collect_used_skill_points(user)
	var/total_points = user.mind.free_skill_points
	var/free_points = total_points - used_points
	data["total_point"] = total_points
	data["free_points"] = free_points

	//create intermediate data format
	var/list/list/datum/skill/categories_map = list()
	for(var/skill_name in GLOB.skills)
		var/datum/skill/skill = GLOB.skills[skill_name]
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
			GET_SKILL_LEVEL(user, skill.type, skill_level)
			var/skill_used_points = user.mind.selected_skills[skill.type]
			var/actual_skill_level = skill_level + skill_used_points
			var/skill_level_name = GLOB.skill_level_names[actual_skill_level]
			skill_data["value"] = "[skill_level_name] ([actual_skill_level])"
			var/skill_level_color = GLOB.skill_level_colors[actual_skill_level]
			skill_data["level_color"] = skill_level_color
			skill_data["desc"] = skill.desc
			skill_data["can_increase"] = skill_used_points < 2 && actual_skill_level < SKILL_LEVEL_LEGEND && skill_level != SKILL_LEVEL_UNAVAILABLE && free_points > 0
			skill_data["can_decrease"] = skill_used_points > 0
			skills.Add(list(skill_data))

		category["skills"] = skills
		categories.Add(list(category))

	data["categories"] = categories
	return data


/datum/ui_module/skills_select_win/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = TRUE
	var/mob/user = ui.user
	switch(action)
		if("increase")
			var/skill = text2path(params["skill"])
			add_skill_level(user, skill, 1)

		if("decrease")
			var/skill = text2path(params["skill"])
			add_skill_level(user, skill, -1)

		if("save")
			save_skills(user)
			ui.close()
			return FALSE

		if("reset")
			reset_skill_points(user)

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
	user.mind.selected_skills[skill] += delta

/datum/ui_module/skills_select_win/proc/save_skills(mob/user)
	var/total_used_points = collect_used_skill_points(user)
	if(total_used_points < user.mind.free_skill_points)
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
