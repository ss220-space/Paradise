#define NUMBER_OF_CC_QUEST 8
#define NUMBER_OF_CORP_QUEST 4
#define PRINT_COOLDOWN 10 SECONDS

/obj/machinery/computer/supplyquest
	name = "Supply Request Console"
	desc = "Essential for supply requests. Your bread and butter."
	icon_keyboard = "cargo_quest_key"
	icon_screen = "cargo_quest"
	req_access = list(ACCESS_QM)
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

/obj/machinery/computer/supplyquest/Initialize()
	. = ..()

	if(!length(GLOB.centcomm_departaments))
		for(var/typepath in subtypesof(/datum/centcomm_departament))
			var/datum/centcomm_departament/departament = new typepath()
			if(!departament.departament_name)
				continue
			GLOB.centcomm_departaments["[departament.departament_name]"] = departament

	if(!length(GLOB.corporations))
		for(var/typepath in subtypesof(/datum/centcomm_departament/corp))
			var/datum/centcomm_departament/corp/corp = new typepath()
			if(!corp.departament_name)
				continue
			GLOB.corporations["[corp.departament_name]"] = corp

	if(!length(GLOB.plasma_departaments))
		for(var/typepath in subtypesof(/datum/centcomm_departament/plasma))
			var/datum/centcomm_departament/plasma/plasma_dep = new typepath()
			if(!plasma_dep.departament_name)
				continue
			GLOB.plasma_departaments["[plasma_dep.departament_name]"] = plasma_dep

	if(!length(GLOB.quest_storages))
		for(var/I = 1 to NUMBER_OF_CC_QUEST)
			GLOB.quest_storages += new /datum/cargo_quests_storage(customer = "centcomm")
		for(var/I = 1 to NUMBER_OF_CORP_QUEST)
			GLOB.quest_storages += new /datum/cargo_quests_storage(customer = "corporation")
		GLOB.quest_storages += new /datum/cargo_quests_storage(customer = "plasma")




/obj/machinery/computer/supplyquest/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/computer/supplyquest/attack_hand(mob/user)
	if(!allowed(user) && !isobserver(user))
		to_chat(user, span_warning("Access denied."))
		playsound(src, pick('sound/machines/button.ogg', 'sound/machines/button_alternate.ogg', 'sound/machines/button_meloboom.ogg'), 20)
		return TRUE

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
	return data

/obj/machinery/computer/supplyquest/ui_data(mob/user)
	var/list/data = list()
	var/list/quest_storages = list()
	for(var/datum/cargo_quests_storage/quest_storage in GLOB.quest_storages)
		if(for_active_quests && !quest_storage.active)
			continue
		var/timeleft_sec = round((quest_storage.time_start + quest_storage.quest_time - world.time) / 10)
		var/list/quests_items = list()
		for(var/datum/cargo_quest/cargo_quest as anything in quest_storage.current_quests)
			var/image_index = rand(1, length(cargo_quest.interface_icons))
			quests_items.Add(list(list(
				"quest_type_name" = cargo_quest.quest_type_name,
				"desc" = cargo_quest.desc,
				"image" = "[icon2base64(icon(cargo_quest.interface_icons[image_index], cargo_quest.interface_icon_states[image_index], SOUTH, 1))]",
				)))

		quest_storages.Add(list(list(
			"active" = quest_storage.active,
			"reward" = quest_storage.reward * (quest_storage.customer != "corporation" || 10),
			"ref" = quest_storage.UID(),
			"fast_bonus" = !quest_storage.fast_failed,
			"timer" = "[timeleft_sec / 60 % 60]:[add_zero(num2text(timeleft_sec % 60), 2)]",
			"quests_items" = quests_items,
			"customer" = quest_storage.customer,
			"target_departament" = quest_storage.target_departament
			)))

	data["quests"] += quest_storages

	data["points"] = round(SSshuttle.points)
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
			quest.quest_expired(reroll = TRUE)

		if("print_order")
			if(print_delayed)
				return FALSE
			var/datum/cargo_quests_storage/quest = locateUID(params["uid"])
			if(!istype(quest))
				return FALSE
			print_delayed = TRUE
			print_order(quest)
			addtimer(VARSET_CALLBACK(src, print_delayed, FALSE), PRINT_COOLDOWN)

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
	paper.info += "Requestor department: [quest.target_departament]<br>"
	paper.info += "Supply request accepted by: [quest.idname] - [quest.idrank]<br>"
	paper.info += "Order acceptance time: [quest.order_date]  [quest.order_time]<br>"
	paper.info += "<ul> <h3> Order List</h3>"
	for(var/datum/cargo_quest/cargo_quest in quest.current_quests)
		paper.info += "<li>[cargo_quest.desc]</li>"

	paper.info += "</ul><br><span class=\"large-text\"> Initial reward: [quest.customer == "corporation" ? "[quest.reward * 10] credits" : quest.reward]</span><br>"
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
	req_access = list(ACCESS_CARGO)

	var/static/list/not_complete_phrases = list(
		"You couldnt do it? What the hell are you even doing there?",
		"It's a shame, we could've helped each other",
		"Why did you even take this on?",
		"Our department will surely be underpaid for being behind schedule",
		"Listen here, moron, if you mess with our plans again, I'll pay you a visit and disembowel your dog",
		"Observing. The delivery request has been ignored by the station crew. The list of perpetrators was identified. The Department will be notified about this. ",
		"We are sure as shit getting sacked this term. Hey, which one of you can I stay with for a couple of months?",
		"Section 4 first, then revisors, and now you? I need to feed my family, but what do YOU know about such matters.",
		"Hey, boys! Put yourselves together, our work is stalling because of you.",
		"Good work. Mister S will appreciate your efforts.",
		"I'LL MAKE SURE YOU BECOME UNEMPLOYED THE NEXT WEEK YOU BRAINDEAD LUMP OF MEAT",
		"Cheers, dudes, I really didn't want to work today. ",
		"Shit. It seems like we're not getting our delivery today. ",
	)
	var/static/list/good_complete_phrases = list(
		"All set, good work. ",
		"We got everything we ordered, very good. ",
		"Could've thrown in a little souvenir from the station. Eh, Whatever, this will do.",
		"The shipment is safe and sound, glory to the cargo-techs! ",
		"Our boss told us he had received the package. He's content, and so are we.",
		"You're on time, don't worry. Everything's in place, everything's intact. ",
		"Good work, fellows, you helped us out a lot. If you need anything, say you're from Gregg. ",
		"OOOOOOOOOOOOOOOOOOOOOoooooooooooooooooo!! ",
		"The cargo has been received in supreme condition. Wish it was always like that, and not how it usually goes... ",
		"Delivery received, but one of our fools got their finger torn off during unpacking.",
		"Finally, a man at work.",
		"I'll report your helpful work to the higher ups. ",
		"AVE CARGONIA",
		"Gotta work again…",
		"I won't forget this, my dudes. This delivery might even get me a promotion. ",
		"It actually came, it's actually intact. We were getting worried for a moment there.",
		"Hurry up next time, you just barely made it in time. ",
		"Work faster next time, our schedule is tight. ",
		"Where's the damn beer?? Could you not put it in???? ",
		"Well, I ain't getting fired today.",
	)

	var/static/list/fast_complete_phrases = list(
		"DAMN YOU GOOD, MAN",
		"Much respect for the speed, by the way.",
		"You did really good, excellent job, guys. ",
		"CARGONIA AVE",
		"We'll provide a discount on some of our merchandise for your efficiency. ",
		"You are to be rewarded for your urgency. ",
		"In a blink of an eye, that's some skill. ",
		"Hey, catch me later, I'll buy you a beer. ",
		"You guys are MAD, can I work for you? ",
		"I TOLD my guys you weren't going to let us down. ",
		"I'll provide you with a discount for your efforts. ",
		"You can expect some bonuses, you did good. ",
		"You can when you want to. ",
		"By the way, is it true one can hook up with a Skrell on your station? ",
		"I always knew you were not going to disappoint. ",
		"The samples came in right as the tests were about to begin, expect a bonus.",
		"YEEEEEEEEEAAAAAH",
		"On behalf of the department, I thank you for your services." ,
		"Alright, I'll give you a little something for your hard work.",
	)

	var/static/list/content_missing_phrases = list(
		"The package was received, but I'm pretty sure we ordered more than that. Whatever, we can still work with this. ",
		"You were penalized for under-delivery. Pay attention to what you are sending.",
		"This is not enough, unfortunately. I'll have to reduce your pay. ",
		"This won't do, guys, where's the rest of it? Ah screw it, it is what it is. ",
		"There's something missing. Not good." ,
		"STOP GETTING WASTED, WE ARE TRYING TO DO OUR JOBS HERE. ",
		"You were better off not sending the package at all. Well then.. ",
		"Do I really have to report your stupidity? ",
		"I can report you and you'll all get sacked.",
		"My wife's cousin works at the Department, do you want problems, huh? ",
		"The Boss told us we must accept the delivery as is. He also told us you're a bunch of imbeciles. ",
		"The Boss says we can't pay the full price for the delivery, he's gonna cut your payment." ,
		"Not enough, not good. ",
		"This ain't gonna do. We'll take a part of the payment for ourselves. ",
		"Is there anyone capable of doing simple maths in your department? ",
	)

	var/static/list/departure_mismatch_phrases = list(
		"The shipment had to come the roundabout way, but whatever. ",
		"The package went past us and ended up at the navy fleet's party. Oopsie. ",
		"COME ON MAAAAAAAAAAAAAN",
		"Do y'all need to be taught how to use a tagger? ",
		"The delivery came in with a delay, we're reducing your reward. ",
		"We lost a lot of money because of you taking your sweet time. ",
		"Does your station only employ monkeys in cargo? ",
		"No wonder everyone says you're stupid. ",
		"HOW DOES THIS EVEN HAPPEN????? ",
		"Tell us the your address, we'll send a first-grade math book your way. ",
		"Use your tagger to mark your packages, please. ",
		"Penalized, the delivery took too long. ",
		"Well, we didn't need the cargo anymore by the time it came in. ",

	)
	var/static/list/content_mismatch_phrases = list(
		"What the hell did you send us?",
		"Why",
		"I'm pretty sure you have a dumpster somewhere. ",
		"Space is large enough, you can dump your stuff there. Why send it here? ",
		"…",
		"Who's this even for?",
		"I don't know what happened there, but poor Joe lost his arm in result",
		"We're going to write a collective complaint against your crew ",
		"I don't know why we need this here, but this crate is very convenient to play bones on. Cheers. ",
		"Thanks for crate, guys! I've been thinking of getting one for my garage for a long time. How did you know?",
		"Errmm. ",
		"Are you sure this is for us? ",
		"We didn't even order anything",
		"Amount discrepancy, I have to cut a part your pay. ",
		"Hey, guys, You might've counted it wrong.",
		"There is not enough here, where is the rest?",
		"Not the same amount as we ordered.",
		"You're sabotaging our work.",
	)


/obj/machinery/computer/supplyquest/workers/Initialize(mapload)
	. = ..()
	GLOB.cargo_announcers += src

/obj/machinery/computer/supplyquest/workers/Destroy()
	GLOB.cargo_announcers -= src
	..()

/obj/machinery/computer/supplyquest/workers/print_order(datum/cargo_quests_storage/quest)
	. = ..()
	print_animation()

/obj/machinery/computer/supplyquest/workers/proc/print_report(datum/cargo_quests_storage/quest, complete, list/modificators = list(), old_reward)
	if(stat & (NOPOWER|BROKEN))
		return
	var/list/phrases = list("Hello!")
	var/obj/item/paper/paper = new(get_turf(src))

	paper.info = "<div id=\"output\"><center> <h3> Shipment records </h3> </center><br><hr><br>"
	paper.info += "Requestor department: [quest.target_departament]<br>"
	paper.info += "Supply request accepted by: [quest.idname] - [quest.idrank]<br>"
	paper.info += "Time of print: [GLOB.current_date_string]  [station_time_timestamp()]<br>"
	paper.info += "<ul> <h3> Order List</h3>"
	for(var/datum/cargo_quest/cargo_quest in quest.current_quests)
		paper.info += "<li>[cargo_quest.desc]</li>"

	paper.info += "</ul><br><span class=\"large-text\"> Initial reward: [quest.customer == "corporation" ? "[old_reward * 10] credits" : old_reward]</span><br>"
	paper.info += "Fines: <br><i>"
	if(modificators["departure_mismatch"])
		paper.info += "departure mismatch (-20%)<br>"
		phrases += departure_mismatch_phrases.Copy()
	if(modificators["content_mismatch"])
		paper.info += "content mismatch (-30%) x[modificators["content_mismatch"]]<br>"
		phrases += content_mismatch_phrases.Copy()
	if(modificators["content_missing"])
		paper.info += "content missing (-50%) x[modificators["content_missing"]]<br>"
		phrases += content_missing_phrases.Copy()
	if(!complete)
		paper.info += "time expired (-100%)<br>"
		phrases += not_complete_phrases.Copy()
	else if(!length(modificators))
		paper.info += "- none <br>"
	paper.info += "</i><br>Bonus:<br><i>"
	if(modificators["quick_shipment"])
		paper.info += "quick shipment (+40%)<br>"
		phrases += fast_complete_phrases.Copy()
	else
		paper.info += "- none <br>"
		if(complete)
			phrases += good_complete_phrases.Copy()
	paper.info += "</i><br><span class=\"large-text\"> Total reward: [complete ? quest.reward : "0"]</span><br>"
	paper.info += "<hr><br><span class=\"small-text\">[pick(phrases)] </span><br>"
	paper.info += "<br><hr><br><span class=\"small-text\">This paper has been stamped by the [station_name()] </span><br></div>"
	var/obj/item/stamp/navcom/stamp = new()
	paper.stamp(stamp)
	paper.update_icon()
	paper.name = "Shipment records"
	playsound(loc, 'sound/goonstation/machines/printer_thermal.ogg', 50, 1)
	print_animation()

/obj/machinery/computer/supplyquest/workers/proc/print_animation()
	add_overlay(image(icon, icon_state = "print_quest_overlay", layer = overlay_layer))
	addtimer(CALLBACK(src, PROC_REF(update_icon)), 4 SECONDS)

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


#undef NUMBER_OF_CC_QUEST
#undef NUMBER_OF_CORP_QUEST
#undef PRINT_COOLDOWN
