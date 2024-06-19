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

/datum/affiliate/proc/is_possible()
	return TRUE

/obj/effect/proc_holder/spell/choose_affiliate
	name = "Choose Affiliate"
	desc = "Choose what affiliate you want to work for."
	gain_desc = "Who was the one hired me?"
	human_req = TRUE
	clothes_req = FALSE
	base_cooldown = 2 SECONDS
	stat_allowed = UNCONSCIOUS
	action_icon_state = "select_class"
	var/list/affiliates_to_choose


/obj/effect/proc_holder/spell/choose_affiliate/create_new_targeting()
	return new /datum/spell_targeting/self

/obj/effect/proc_holder/spell/choose_affiliate/New(affiliates)
	. = ..()
	affiliates_to_choose = affiliates

/obj/effect/proc_holder/spell/choose_affiliate/cast(mob/user)
	ui_interact(user)

/obj/effect/proc_holder/spell/choose_affiliate/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.always_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "Affiliates", name, 900, 800, master_ui, state)
		ui.open()
		ui.set_autoupdate(FALSE)


/obj/effect/proc_holder/spell/choose_affiliate/ui_static_data(mob/user)
	var/list/data = list()
	var/list/affiliates = list()
	for(var/i in 1 to 3)
		var/affiliate_path = affiliates_to_choose[i]
		var/datum/affiliate/affiliate = new affiliate_path
		affiliates += list(list("name" = affiliate.name,
								"desc" = affiliate.desc,
								"path" = affiliate_path,
								"icon" = icon2base64(icon('icons/misc/affiliates.dmi', affiliate.tgui_icon, SOUTH))))
	data["affiliates"] = affiliates
	return data

/obj/effect/proc_holder/spell/choose_affiliate/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	var/datum/antagonist/traitor/traitor = ui.user.mind.has_antag_datum(/datum/antagonist/traitor)
	switch(action)
		if("SelectAffiliate")
			var/path = params["path"]
			traitor.grant_affiliate(path)
			traitor.owner.RemoveSpell(src)
			ui.close()
