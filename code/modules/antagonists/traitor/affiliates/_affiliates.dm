/datum/affiliate
	/// Affiliate name(OMG)
	var/name
	/// Description for tgui, better to have plus and minus
	var/desc
	/// Description for tgui, if you get hijack role
	var/hij_desc
	/// Icon for tgui 256X256
	var/tgui_icon = "1"
	/// Cats, which this affeliate does not have.
	var/cats_to_exclude
	/// Special objectives, use lists with weight to roll them. Ex. list(kill = 10, steal = 90), and just a objectives for 100% giving them.
	var/list/objectives
	/// Bad thing that I can`t delete, used as tool to give traitor his affeliate. If you dont doing refactor, you dont neew this one.
	var/obj/item/uplink/hidden/uplink

/// If your affiliate need special effects, it is place for them
/datum/affiliate/proc/finalize_affiliate(datum/mind/owner)
	//Тут надо будет рольнуть хиджака думаю, хз
	var/datum/antagonist/traitor/traitor = owner.has_antag_datum(/datum/antagonist/traitor)
	traitor.affiliate = src
	give_objectives(owner)
	show_objectives(owner)

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
			uplink.affiliate.finalize_affiliate(traitor)
			uplink.trigger(ui.user)
			qdel(src)

/datum/affiliate/ui_close(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(src != uplink.affiliate)
		return
	uplink.affiliate = null
	qdel(src)
