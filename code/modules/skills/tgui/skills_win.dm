// Skills window tgui
GLOBAL_DATUM_INIT(skills_window, /datum/ui_module/skills_win, new)

/datum/ui_module/skills_win
	name = "Skills window"

/datum/ui_module/skills_win/ui_state(mob/user)
	if(isobserver(user))
		return ..()
	return GLOB.not_incapacitated_state

/datum/ui_module/skills_win/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SkillsWin", name)
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/ui_module/skills_win/ui_data(mob/user)
	//create root data
	var/list/data = list()
	//create skills container
	data["username"] = user.real_name
	data["job"] = user.job

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
			skill_data["name"] = skill.name
			GET_SKILL_LEVEL(user, skill.type, skill_level)
			var/skill_level_name = GLOB.skill_level_names["[skill_level]"]
			skill_data["value"] = "[skill_level_name] ([skill_level])"
			var/skill_level_color = GLOB.skill_level_colors["[skill_level]"]
			skill_data["level_color"] = skill_level_color
			skill_data["desc"] = skill.desc
			skills.Add(list(skill_data))

		category["skills"] = skills
		categories.Add(list(category))

	data["categories"] = categories
	return data
