/datum/ui_module/achievement_data
	name = "Achievements Panel"

/datum/ui_module/achievement_data/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.admin_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "Achievements", name, 540, 680, master_ui, state)
		ui.autoupdate = TRUE
		ui.open()

/datum/ui_module/achievement_data/ui_data(mob/user)
	var/list/data = list()
	data["categories"] = list("Bosses", "Jobs", "Misc", "Mafia", "Scores")
	data["achievements"] = list()
	data["user_key"] = user.ckey

	//This should be split into static data later
	for(var/achievement_type in SSmedals.awards)
		if(!SSmedals.awards[achievement_type].name) //No name? we a subtype.
			continue
		if(isnull(data[achievement_type])) //We're still loading
			continue
		var/list/this = list(
			"name" = SSmedals.awards[achievement_type].name,
			"desc" = SSmedals.awards[achievement_type].desc,
			"category" = SSmedals.awards[achievement_type].category,
			"icon_class" = icon(SSmedals.awards[achievement_type].icon),
			"value" = data[achievement_type],
			"score" = ispath(achievement_type,/datum/award/score)
			)
		data["achievements"] += list(this)

	return data

/datum/ui_module/achievement_data/ui_static_data(mob/user)
	. = ..()
	.["highscore"] = list()
	for(var/score in SSmedals.scores)
		var/datum/award/score/S = SSmedals.scores[score]
		if(!S.name || !S.track_high_scores || !S.high_scores.len)
			continue
		.["highscore"] += list(list("name" = S.name,"scores" = S.high_scores))

/datum/ui_module/achievement_data/ui_act(action, params)
	if(..())
		return
	. = TRUE

