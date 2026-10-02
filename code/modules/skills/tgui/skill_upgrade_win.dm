/datum/ui_module/skills_upgrade_win
	name = "Навыки персонажа"
	/// Unlimited actions
	var/admin_interact
	/// Target user
	var/mob/target_user
	COOLDOWN_DECLARE(skill_click_cooldown)


/datum/ui_module/skills_upgrade_win/ui_state(mob/user)
	if(isobserver(user))
		return ..()
	if(!target_user.mind || !target_user.dna || !target_user.dna.species)
		return ..()
	return GLOB.not_incapacitated_state

/datum/ui_module/skills_upgrade_win/proc/show(mob/user, mob/target, admin_interact = FALSE)
	src.admin_interact = admin_interact
	target_user = target
	ui_interact(user)

/datum/ui_module/skills_upgrade_win/ui_interact(mob/user, datum/tgui/ui = null)
	if(target_user.mind.actual_free_skill_points == ACTUAL_FREE_SKILL_POINTS_NOT_SET)
		target_user.mind.actual_free_skill_points = target_user.mind.free_skill_points + target_user.dna.species.bonus_skill_free_points

	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SkillUpgradeWin", "Навыки персонажа " + target_user.real_name)
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/ui_module/skills_upgrade_win/ui_data(mob/user)
	//create root data
	var/list/data = list()
	//create user data
	var/list/user_data = list()
	user_data["username"] = target_user.real_name
	user_data["job"] = target_user.job
	user_data["admin"] = admin_interact
	user_data["points"] = target_user.mind.actual_free_skill_points
	data["user"] = user_data

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
		var/list/datum/skill/category_skills = categories_map[category_name]
		if(!length(category_skills))
			continue
		category["id"] = category_name
		category["name"] = category_name
		category["color"] = category_skills[1].category_color

		var/list/current_mob_skills = target_user?.mind?.get_skills_for_skills_select()
		var/list/skills = list()
		for(var/datum/skill/skill as anything in category_skills)
			var/list/skill_data = list()
			skill_data["id"] = skill.type
			skill_data["name"] = skill.name
			var/skill_level = current_mob_skills[skill.type]
			var/actual_skill_level = skill_level
			var/skill_level_name = GLOB.skill_level_names[actual_skill_level]
			skill_data["level"] = "[skill_level_name] ([actual_skill_level])"
			var/skill_level_color = GLOB.skill_level_colors[actual_skill_level]
			skill_data["level_color"] = skill_level_color
			skill_data["desc"] = skill.desc
			// TODO vakons skills_upgrade: purchase data here
			skills.Add(list(skill_data))

		category["skills"] = skills
		categories.Add(list(category))

	data["categories"] = categories

	return data
