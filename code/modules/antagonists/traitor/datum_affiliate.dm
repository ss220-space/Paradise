/datum/affiliate
	var/name
	var/desc
	var/key
	var/tgui_icon = "1"
	var/cats_to_exclude
	var/list/objectives
	var/obj/item/uplink/hidden/uplink

/datum/affiliate/cybersun
	name = "Cybersun Industries"
	desc = "Вы - очередная игрушка в руках CyberSun Industries. По принуждению или \n\
			из-за обещаний материальных благ вы согласились выполнить некоторые задания для неё. \n\
			Как вам стоит работать: Нет особых предпочтений. \n\
			Особые условия: Словно насмешка над вами, вам предоставлена скидка на продукции вашего Нанимателя;\n\
			Вам доступен специальный модуль улучшения, что предоставляет киборгу НТ модули Киберсана. \n\
			Стандартные цели: Кража высокотехнологичной продукции НТ (ИИ, боевые мехи, иные важные предметы),\n\
			устранение, кража технологий"
	key = "cybersun"
	cats_to_exclude = CATEGORY_DANGEROUS
	objectives = list(list(/datum/objective/steal = 50, /datum/objective/steal/ai = 50),
						/datum/objective/mecha_hijack,
						/datum/objective/download_data,
						/datum/objective/maroon,
						/datum/objective/escape,
						)

/datum/affiliate/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.always_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "Affiliates", name, 900, 800, master_ui, state)
		ui.open()

/datum/affiliate/ui_static_data(mob/user)
	var/list/data = list()
	var/list/affiliates = list()
	for(var/i in 1 to 3)
		var/affiliate_path = pick(subtypesof(/datum/affiliate))
		var/datum/affiliate/affiliate = new affiliate_path
		affiliates += list(list("name" = affiliate.name,
								"desc" = affiliate.desc,
								"path" = affiliate_path,
								"icon" = icon2base64(icon('icons/misc/affiliates.dmi', affiliate.tgui_icon, SOUTH))))

	data["affiliates"] = affiliates

	return data

/datum/affiliate/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	var/datum/mind/traitor = ui.user.mind
	switch(action)
		if("SelectAffiliate")
			var/path = params["path"]
			var/datum/affiliate/newaffiliate = new path
			uplink.affiliate = newaffiliate
			ui.close()
			uplink.affiliate.give_objectives(traitor)
			show_objectives(traitor)
			uplink.trigger(ui.user)
			qdel(src)

/datum/affiliate/proc/give_objectives(datum/mind/mind)
	var/datum/antagonist/traitor/traitor = mind?.has_antag_datum(/datum/antagonist/traitor)
	if(!traitor)
		return
	for(var/objective in objectives)
		var/datum/objective/new_objective
		if(islist(objective))
			var/list/roll_objective = objective
			var/path_objective = pickweight(roll_objective)
			new_objective = new path_objective
		else
			new_objective = new objective
		traitor.add_objective(new_objective)
