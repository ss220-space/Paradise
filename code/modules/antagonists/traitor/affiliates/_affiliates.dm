/datum/affiliate
	/// Affiliate name(OMG)
	var/name
	/// Description for tgui, better to have plus and minus
	var/affil_info = list()
	/// Description for tgui, if you get hijack role
	var/hij_desc
	/// Type of hijack objective
	var/hij_obj = /datum/objective/hijack
	/// Icon for tgui 256X256
	var/tgui_icon = "1"
	/// Cats, which this affeliate does not have.
	var/cats_to_exclude
	/// Special objectives, use lists with weight to roll them. Ex. list(kill = 10, steal = 90), and just a objectives for 100% giving them.
	var/list/objectives
	/// Bad thing that I can`t delete, used as tool to give traitor his affeliate. If you dont doing refactor, you dont neew this one.
	var/obj/item/uplink/hidden/uplink
	/// Reward for killing enemy agents.
	var/reward_for_enemys = 10
	/// TRUE if it can take bonus objectives
	var/can_take_bonus_objectives = TRUE

/// If your affiliate need special effects, it is place for them
/datum/affiliate/proc/finalize_affiliate(datum/mind/owner)
	return

/datum/affiliate/proc/give_objectives(datum/mind/mind)
	var/datum/antagonist/traitor/traitor = mind?.has_antag_datum(/datum/antagonist/traitor)
	if(!traitor)
		return

	var/hijacker_antag = (GLOB.master_mode == "antag-paradise" || GLOB.secret_force_mode == "antag-paradise") ? traitor.is_hijacker : prob(10)

	if(!SSticker.mode.exchange_blue) 	//Set up an exchange if there are enough traitors
		if(SSticker.mode.exchange_red)
			SSticker.mode.exchange_blue = mind
			traitor.assign_exchange_role(SSticker.mode.exchange_blue)

	if(hijacker_antag && !mind.has_big_obj())
		traitor.add_objective(hij_obj)
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

/datum/affiliate/proc/get_weight(mob/living/carbon/human/H)
	return 3

/datum/affiliate/proc/remove_innate_effects(mob/living/mob_override)
	mob_override.RemoveSpell(/obj/effect/proc_holder/spell/choose_affiliate)

/datum/affiliate/proc/give_bonus_objectives(datum/mind/mind)
	if (!can_take_bonus_objectives)
		return

	var/datum/antagonist/traitor/traitor = mind?.has_antag_datum(/datum/antagonist/traitor)

	var/obj1 = pick(/datum/objective/maroon, /datum/objective/steal)
	traitor.add_objective(obj1)
	var/obj2 = pick(/datum/objective/maroon, /datum/objective/steal)
	traitor.add_objective(obj2)

/obj/effect/proc_holder/spell/choose_affiliate
	name = "Choose Affiliate"
	desc = "Выберите, на какого подрядчика вы хотите работать."
	gain_desc = "Кто меня нанял?"
	human_req = TRUE
	clothes_req = FALSE
	base_cooldown = 2 SECONDS
	stat_allowed = UNCONSCIOUS
	action_icon_state = "select_affiliate"
	var/list/affiliates_to_choose


/obj/effect/proc_holder/spell/choose_affiliate/create_new_targeting()
	return new /datum/spell_targeting/self

/obj/effect/proc_holder/spell/choose_affiliate/New(affiliates)
	. = ..()
	affiliates_to_choose = affiliates

/obj/effect/proc_holder/spell/choose_affiliate/cast(mob/user)
	ui_interact(user)

/obj/effect/proc_holder/spell/choose_affiliate/ui_state(mob/user)
	return GLOB.always_state

/obj/effect/proc_holder/spell/choose_affiliate/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, user, ui)
	if(!ui)
		ui = new(user, src, "Affiliates")
		ui.open()

/obj/effect/proc_holder/spell/choose_affiliate/ui_data(mob/user)
	var/list/data = list()
	var/list/affiliates = list()
	for(var/i in 1 to 3)
		var/affiliate_path = affiliates_to_choose[i]
		var/datum/affiliate/affiliate = new affiliate_path
		affiliates += list(list("name" = affiliate.name,
								"desc" = affiliate.affil_info,
								"path" = affiliate_path,
								"icon" = icon2base64(icon('icons/misc/affiliates.dmi', affiliate.tgui_icon, SOUTH))))

	data["affiliates"] = affiliates
	return data

/datum/antagonist/traitor/proc/give_affiliate(datum/mind/mind, path)
	grant_affiliate(path)
	if (istype(affiliate, /datum/affiliate/gorlex))
		if (20 MINUTES - SSticker.round_start_time > 0)
			to_chat(mind.current, span_info("Аплинк будет активирован через 20 минут от начала смены.\n\
			Спасибо что выбрали Gorlex Maraduers.\n\
			Слава синдикату!"))
			sleep(20 MINUTES - SSticker.round_start_time)

	var/datum/antagonist/traitor/traitor = mind.has_antag_datum(/datum/antagonist/traitor)
	if (!traitor)
		return
	give_uplink()
	affiliate.give_objectives(mind)
	show_objectives(mind)
	hidden_uplink.affiliate = affiliate
	affiliate.uplink = hidden_uplink
	affiliate.finalize_affiliate(mind)
	hidden_uplink.can_bonus_objectives = affiliate.can_take_bonus_objectives
	announce_uplink_info()

/obj/effect/proc_holder/spell/choose_affiliate/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	var/datum/antagonist/traitor/traitor = ui.user.mind.has_antag_datum(/datum/antagonist/traitor)
	if (traitor.affiliate)
		return

	switch(action)
		if("SelectAffiliate")
			var/path = params["path"]
			ui.close()
			ui.user.mind.RemoveSpell(src)
			traitor.give_affiliate(ui.user.mind, path)

/datum/affiliate/proc/add_discount_item(I, cost_part)
	var/datum/uplink_item/new_item = new I
	new_item.cost = round(new_item.cost * (cost_part))
	new_item.name += " ([round((1-(cost_part))*100)]% скидка!)"
	new_item.category = "Скидки"
	uplink.uplink_items.Add(new_item)
