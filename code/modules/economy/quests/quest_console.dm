
#define PRINT_COOLDOWN 10 SECONDS

/// The name of the strings file containing the data that will be used to fill in the notes in the order
#define QUEST_NOTES_STRINGS "quest_workers.json"

/obj/machinery/computer/supplyquest
	name = "Supply Request Console"
	desc = "Essential for supply requests. Your bread and butter."
	icon_keyboard = "cargo_quest_key"
	icon_screen = "cargo_quest"
	req_access = list(ACCESS_CARGO)
	circuit = /obj/item/circuitboard/supplyquest
	/// If TRUE you can see only active quests
	var/for_active_quests = FALSE
	/// Parent object this console is assigned to. Used for QM tablet
	var/atom/movable/parent
	/// Prevent print spam
	var/print_delayed
	/// Permission to order a high-tech disk
	var/static/hightech_recovery = FALSE

/obj/machinery/computer/supplyquest/ui_host()
	return parent ? parent : src

/obj/machinery/computer/supplyquest/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/computer/supplyquest/attack_hand(mob/user)
	add_fingerprint(user)
	ui_interact(user)
	return

/obj/machinery/computer/supplyquest/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "QuestConsole", name, 1000, 820, master_ui, state)
		ui.open()

#define BASE_HIGHTECH_COST 40000

/obj/machinery/computer/supplyquest/ui_static_data(mob/user)
	var/list/data = list()
	var/list/techs = list()
	var/seventh_lvl_techs
	for(var/tech_id in SSshuttle.techLevels)
		techs += list(list(
			"tech_name" = CallTechName(tech_id),
			"tech_level" = SSshuttle.techLevels[tech_id]
		))
		if(SSshuttle.techLevels[tech_id] >= 7)
			seventh_lvl_techs++

	data["techs"] = techs
	if(seventh_lvl_techs > 8)
		data["have_high_techs"] = TRUE
		var/list/purchased_techs = list()
		for(var/tt in (subtypesof(/datum/tech) - /datum/tech/abductor - /datum/tech/syndicate))
			var/datum/tech/tech = tt
			purchased_techs += list(list(
				"tech_name" = initial(tech.name),
				"cost" = BASE_HIGHTECH_COST * initial(tech.rare),
				"tech_id" = initial(tech.id)
			))
		data["purchased_techs"] = purchased_techs
	var/datum/money_account/cargo_money_account = GLOB.department_accounts["Cargo"]
	data["cargo_money"] = cargo_money_account.money
	data["points"] = round(SSshuttle.points)
	return data

/obj/machinery/computer/supplyquest/ui_data(mob/user)
	var/list/data = list()
	var/list/quest_storages = list()
	for(var/datum/cargo_quests_storage/quest_storage as anything in SScargo_quests.quest_storages)
		if(for_active_quests && !quest_storage.active)
			continue
		var/timeleft_sec = round((quest_storage.time_start + quest_storage.quest_time - world.time) / 10)
		var/list/quests_items = list()
		for(var/datum/cargo_quest/cargo_quest as anything in quest_storage.current_quests)
			quests_items.Add(list(list(
				"quest_type_name" = cargo_quest.quest_type_name,
				"desc" = cargo_quest.desc.Join(""),
				"image" = "[cargo_quest.interface_images[rand(1, length(cargo_quest.interface_images))]]",
				)))

		quest_storages.Add(list(list(
			"active" = quest_storage.active,
			"reward" = quest_storage.reward,
			"ref" = quest_storage.UID(),
			"fast_bonus" = !quest_storage.fast_failed,
			"timer" = "[timeleft_sec / 60 % 60]:[add_zero(num2text(timeleft_sec % 60), 2)]",
			"quests_items" = quests_items,
			"customer" = quest_storage.customer.group_name,
			"target_departament" = quest_storage.customer.departament_name
			)))

	data["quests"] += quest_storages
	data["moving"] = SSshuttle.supply.mode != SHUTTLE_IDLE
	data["at_station"] = SSshuttle.supply.getDockedId() == "supply_home"
	data["timeleft"] = SSshuttle.supply.timeLeft(600)
	return data

/obj/machinery/computer/supplyquest/ui_act(action, list/params)
	if(..())
		return
	var/mob/user = usr
	if(!allowed(user) && !user.can_admin_interact())
		to_chat(user, span_warning("Access denied."))
		playsound(src, pick('sound/machines/button.ogg', 'sound/machines/button_alternate.ogg', 'sound/machines/button_meloboom.ogg'), 20)
		return

	if(!SSshuttle)
		stack_trace("The SSshuttle controller datum is missing somehow.")
		return

	. = TRUE
	add_fingerprint(user)

	switch(action)
		if("activate")
			var/datum/cargo_quests_storage/quest = locateUID(params["uid"])
			if(!istype(quest))
				return
			quest.active = TRUE
			quest.after_activated()
			if(ishuman(user))
				var/mob/living/carbon/human/H = user
				quest.idname = H.get_authentification_name()
				quest.idrank = H.get_assignment()
			else if(issilicon(user))
				quest.idname = user.real_name
				quest.idrank = isAI(user) ? "AI" : "Robot"
			quest.order_date = GLOB.current_date_string
			quest.order_time = station_time_timestamp()
			print_order(quest)

		if("denied")
			var/datum/cargo_quests_storage/quest = locateUID(params["uid"])
			if(!istype(quest))
				return
			if(!quest.can_reroll)
				to_chat(user, span_warning("This quest can not be rerolled."))
				return
			SScargo_quests.remove_quest(params["uid"], reroll = TRUE)

		if("print_order")
			if(print_delayed)
				return FALSE
			var/datum/cargo_quests_storage/quest = locateUID(params["uid"])
			if(!istype(quest))
				return FALSE
			print_delayed = TRUE
			print_order(quest)
			addtimer(VARSET_CALLBACK(src, print_delayed, FALSE), PRINT_COOLDOWN)

		if("add_time")
			var/datum/cargo_quests_storage/quest = locateUID(params["uid"])
			if(!istype(quest))
				return FALSE
			if(quest.time_add_count > 4)
				to_chat(user, span_warning("You've done that too many times already."))
				playsound(src, pick('sound/machines/button.ogg', 'sound/machines/button_alternate.ogg', 'sound/machines/button_meloboom.ogg'), 20)
				return FALSE
			quest.add_time()

		if("buy_tech")
			if(hightech_recovery)
				to_chat(user, span_warning("The Centcom institutes are not ready to provide you with this technology yet."))
				playsound(src, pick('sound/machines/button.ogg', 'sound/machines/button_alternate.ogg', 'sound/machines/button_meloboom.ogg'), 20)
				return FALSE
			var/datum/money_account/cargo_money_account = GLOB.department_accounts["Cargo"]
			var/attempt_pin = input("Enter pin code", "Centcomm transaction") as num
			if(..() || !attempt_account_access(cargo_money_account.account_number, attempt_pin, 2))
				to_chat(user, span_warning("Unable to access account: incorrect credentials."))
				playsound(src, pick('sound/machines/button.ogg', 'sound/machines/button_alternate.ogg', 'sound/machines/button_meloboom.ogg'), 20)
				return FALSE
			if(cargo_money_account.charge(transaction_amount = text2num(params["cost"]), transaction_purpose = "Buy High-Tech disk", terminal_name = "Biesel TCD Terminal #[rand(111,333)]", dest_name = "Nanotrasen Institute"))
				hightech_recovery = TRUE
				addtimer(VARSET_CALLBACK(src, hightech_recovery, FALSE), 30 MINUTES)
				order_techdisk(params["tech_name"], user)

/obj/machinery/computer/supplyquest/proc/order_techdisk(tech_name, mob/user)
	var/idname = "*None Provided*"
	var/idrank = "*None Provided*"

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		idname = H.get_authentification_name()
		idrank = H.get_assignment()
	else if(issilicon(user))
		idname = user.real_name
		idrank = isAI(user) ? "AI" : "Robot"

	for(var/path in subtypesof(/datum/supply_packs/misc/htdisk))
		var/datum/supply_packs/misc/htdisk/htcrate = SSshuttle.supply_packs["[path]"]
		if("[tech_name] Disk Crate" != initial(htcrate.name))
			continue
		var/datum/supply_order/order = SSshuttle.generateSupplyOrder(htcrate.UID(), idname, idrank, "Order of High-Tech Disk", 1)
		order?.generateRequisition(loc)
		return

/obj/machinery/computer/supplyquest/proc/print_order(datum/cargo_quests_storage/quest)

	playsound(loc, 'sound/goonstation/machines/printer_thermal.ogg', 50, 1)
	var/obj/item/paper/paper = new(get_turf(src))
	paper.info = "<div id=\"output\"><center> <h3> Supply request form </h3> </center><br><hr><br>"
	paper.info += "Requestor department: [quest.customer.departament_name]<br>"
	paper.info += "Supply request accepted by: [quest.idname] - [quest.idrank]<br>"
	paper.info += "Order acceptance time: [quest.order_date]  [quest.order_time]<br>"
	paper.info += "<ul> <h3> Order List</h3>"
	for(var/datum/cargo_quest/cargo_quest in quest.current_quests)
		paper.info += "<li>[cargo_quest.desc.Join("")]</li>"

	paper.info += "</ul><br><span class=\"large-text\"> Initial reward: [quest.reward]</span><br>"
	paper.info += "<br><hr><br><span class=\"small-text\">This paper has been stamped by the [station_name()] </span><br></div>"
	var/obj/item/stamp/navcom/stamp = new()
	paper.stamp(stamp)
	paper.update_icon()
	paper.name = "Supply request form"




/obj/machinery/computer/supplyquest/workers
	name = "Supply Request Monitor"
	desc = "From this monitor, you can view active requests, and you can take a printed version of the request to make it easier to collect supplies. Oh, and so you don't forget."
	icon_state = "quest_console"
	icon_screen = "quest"
	icon_keyboard = null
	for_active_quests = TRUE
	circuit = /obj/item/circuitboard/questcons
	density = FALSE


/obj/machinery/computer/supplyquest/workers/Initialize(mapload)
	. = ..()
	GLOB.cargo_announcers += src

/obj/machinery/computer/supplyquest/workers/Destroy()
	GLOB.cargo_announcers -= src
	..()

/obj/machinery/computer/supplyquest/workers/print_order(datum/cargo_quests_storage/quest)
	. = ..()
	print_animation()

/obj/machinery/computer/supplyquest/workers/proc/print_report(datum/cargo_quests_storage/quest, complete, list/modificators = list(), new_reward)
	if(stat & (NOPOWER|BROKEN))
		return
	var/list/phrases = list()
	var/obj/item/paper/paper = new(get_turf(src))

	paper.info = "<div id=\"output\"><center> <h3> Shipment records </h3> </center><br><hr><br>"
	paper.info += "Requestor department: [quest.customer.departament_name]<br>"
	paper.info += "Supply request accepted by: [quest.idname] - [quest.idrank]<br>"
	paper.info += "Time of print: [GLOB.current_date_string]  [station_time_timestamp()]<br>"
	paper.info += "<ul> <h3> Order List</h3>"
	for(var/datum/cargo_quest/cargo_quest in quest.current_quests)
		paper.info += "<li>[cargo_quest.desc.Join("")]</li>"

	paper.info += "</ul><br><span class=\"large-text\"> Initial reward: [quest.reward]</span><br>"
	paper.info += "Fines: <br><i>"
	if(modificators["departure_mismatch"])
		paper.info += "departure mismatch (-20%)<br>"
		phrases += pick_list(QUEST_NOTES_STRINGS, "departure_mismatch_phrases")
	if(modificators["content_mismatch"])
		paper.info += "content mismatch (-30%) x[modificators["content_mismatch"]]<br>"
		phrases += pick_list(QUEST_NOTES_STRINGS, "content_mismatch_phrases")
	if(modificators["content_missing"])
		paper.info += "content missing (-[round(modificators["content_missing"] * 100/modificators["quest_len"])]%)<br>"
		phrases += pick_list(QUEST_NOTES_STRINGS, "content_missing_phrases")
	if(!complete)
		paper.info += "time expired (-100%)<br>"
		phrases += pick_list(QUEST_NOTES_STRINGS, "not_complete_phrases")
	else if(quest.time_add_count > 0)
		paper.info += "shipment delay (-[10 * quest.time_add_count]%)<br>"

	else if(!length(modificators))
		paper.info += "- none <br>"
	paper.info += "</i><br>Bonus:<br><i>"
	if(modificators["quick_shipment"])
		paper.info += "quick shipment (+40%)<br>"
		phrases += pick_list(QUEST_NOTES_STRINGS, "fast_complete_phrases")
	else
		paper.info += "- none <br>"
		if(complete && !length(phrases))
			phrases += pick_list(QUEST_NOTES_STRINGS, "good_complete_phrases")
	paper.info += "</i><br><span class=\"large-text\"> Total reward: [complete ? new_reward : "0"]</span><br>"
	if(!modificators["content_missing"] && !modificators["departure_mismatch"] && !modificators["content_mismatch"])
		paper.info += "<hr><br>"
		for(var/sale_category in quest.customer.cargo_sale)
			paper.info += "<span class=\"small-text\">You have received a <b>[quest.customer.cargo_sale[sale_category] * quest.customer.modificator * 100]%</b> discount on <b>[sale_category]</b> category in orders. </span><br>"
	paper.info += "<hr><br><span class=\"small-text\">[pick(phrases)] </span><br>"
	paper.info += "<br><hr><br><span class=\"small-text\">This paper has been stamped by the [station_name()] </span><br></div>"
	var/obj/item/stamp/navcom/stamp = new()
	paper.stamp(stamp)
	paper.update_icon()
	paper.name = "Shipment records"
	playsound(loc, 'sound/goonstation/machines/printer_thermal.ogg', 50, 1)
	print_animation()


/obj/machinery/computer/supplyquest/workers/proc/print_animation()
	flick_overlay_view(image(icon, src, "print_quest_overlay", layer + 0.1), 4 SECONDS)


/obj/item/qm_quest_tablet
	name = "Quartermaster Tablet"
	desc = "A sleek device that helps to manage all the requests. Makes up the symbol of Brave New Cargonia."
	icon = 'icons/obj/device.dmi'
	icon_state	= "qm_tablet"
	w_class		= WEIGHT_CLASS_SMALL
	item_state	= "qm_tablet"
	origin_tech = "programming=5;engineering=3"
	/// Integrated console to serve UI data
	var/obj/machinery/computer/supplyquest/iternal/integrated_console

/obj/machinery/computer/supplyquest/iternal
	name = "invasive quest utility"
	desc = "How did this get here?! Please report this as a bug to github"
	use_power = NO_POWER_USE

/obj/item/qm_quest_tablet/Initialize(mapload)
	. = ..()
	integrated_console = new(src)
	integrated_console.parent = src

/obj/item/qm_quest_tablet/Destroy()
	QDEL_NULL(integrated_console)
	return ..()

/obj/item/qm_quest_tablet/attack_self(mob/user as mob)
	ui_interact(user)

/obj/item/qm_quest_tablet/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.inventory_state)
	integrated_console.ui_interact(user, ui_key, ui, force_open, master_ui, state)


#undef QUEST_NOTES_STRINGS
#undef PRINT_COOLDOWN
