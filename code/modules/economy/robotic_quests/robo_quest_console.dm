// Level of mecha building success
#define NO_SUCCESS 0
#define CORRECT_MECHA 1
#define SOME_CORRECT_MODULES 2
#define ALL_CORRECT_MODULES 3
// Choosen mecha defines
#define WORKING_CLASS	1
#define MEDICAL_CLASS	2
#define COMBAT_CLASS	3
#define RANDOM_CLASS	4
/// TGUI helper define for shop items good placing
#define CATS_BY_STAGE list("number" = list("first", "second", "third"), \
						   "first" = list("working", "medical", "security"), \
						   "second" = list("working_medical", "medical_security"), \
						   "third" = list("working_medical_security"))


///////////////////////
// roboquest console //
///////////////////////

/obj/machinery/computer/roboquest
	name = "Robotics Request Console"
	desc = "Console used for receiving requests for construction of exosuits."
	icon_screen = "robo_ntos_roboquest"
	icon_keyboard = "rd_key"
	light_color = LIGHT_COLOR_FADEDPURPLE
	/// Print order for quests
	var/print_delayed = FALSE
	/// Current interface theme
	var/style = "ntos_roboquest"
	/// Can we send mecha?
	var/canSend = FALSE
	/// Is there mecha and pad for check?
	var/canCheck = FALSE
	/// Timer to clear checkMessage
	var/check_timer
	/// Message after check
	var/checkMessage = ""
	/// Level of success of last mecha check
	var/success
	/// Point balance
	var/points = list("working" = 0, "medical" = 0, "security" = 0, "robo" = 0)
	req_access = list(ACCESS_ROBOTICS)
	circuit = /obj/item/circuitboard/roboquest
	var/obj/item/card/id/currentID
	/// This console pad
	var/obj/machinery/roboquest_pad/pad
	var/list/shop_items = list()

/obj/machinery/computer/roboquest/Initialize(mapload)
	..()
	generate_roboshop()
	if(mapload)
		var/mapping_pad = locate(/obj/machinery/roboquest_pad) in get_area(src)
		if(mapping_pad)
			pad = mapping_pad
			pad.console = src
			canCheck = TRUE

/obj/machinery/computer/roboquest/New()
	generate_roboshop()
	. = ..()

/obj/machinery/computer/roboquest/Destroy()
	for(var/obj/item/I in contents)
		I.forceMove(get_turf(src))
	if(pad)
		pad.console=null
		pad = null
	currentID = null
	. = ..()


/obj/machinery/computer/roboquest/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(I, /obj/item/card/id))
		add_fingerprint(user)
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		if(currentID)
			currentID.forceMove(drop_location())
			user.put_in_hands(currentID, ignore_anim = FALSE)
		currentID = I
		SStgui.try_update_ui(user, src)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/machinery/computer/roboquest/multitool_act(mob/living/user, obj/item/I)
	if(!istype(I, /obj/item/multitool))
		return FALSE
	. = TRUE
	var/obj/item/multitool/multitool = I
	if(!istype(multitool.buffer, /obj/machinery/roboquest_pad))
		add_fingerprint(user)
		to_chat(user, span_warning("The [multitool.name]'s buffer has no valid information."))
		return .
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
	pad = multitool.buffer
	if(pad.console && pad.console != src)
		pad.console.pad = null
	pad.console = src
	canCheck = TRUE
	multitool.buffer = null
	to_chat(user, span_notice("You have uploaded the data from [multitool]'s buffer."))


/obj/machinery/computer/roboquest/emag_act(mob/user)
	if(!emagged)
		emagged = TRUE
		playsound(src, "sparks", 100, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)


/obj/machinery/computer/roboquest/proc/check_pad()
	var/obj/mecha/M
	var/needed_mech = currentID.robo_bounty.choosen_mech
	var/list/needed_modules = currentID.robo_bounty.choosen_modules
	var/amount = 0
	if(locate(/obj/mecha) in get_turf(pad))
		M = (locate(/obj/mecha) in get_turf(pad))
		if(M.type == needed_mech)
			for(var/i in (needed_modules))
				for(var/obj/item/mecha_parts/mecha_equipment/weapon in M.equipment)
					if(i == weapon.type)
						amount++
			if(amount == currentID.robo_bounty.modules_amount)
				success = ALL_CORRECT_MODULES
				canSend = TRUE
				return	amount
			if(amount == 0)
				success = CORRECT_MECHA
				canSend = TRUE
				return amount
			success = SOME_CORRECT_MODULES
			canSend = TRUE
			return	amount
	success = NO_SUCCESS
	canSend = FALSE

/obj/machinery/computer/roboquest/proc/generate_roboshop()
	var/list/newshop = list()
	for(var/path in subtypesof(/datum/roboshop_item))
		var/datum/roboshop_item/item = new path
		var/category
		for(var/cat in item.cost)
			if(item.cost[cat])
				if(category)
					category += "_[cat]"
				else
					category = cat
		var/newitem = list("name" = item.name, "desc" = item.desc, "cost" = item.cost, "icon" = path2assetID(path), "path" = path, "emagOnly" = item.emag_only)
		newshop[category] += list(newitem)
	shop_items = newshop

/obj/machinery/computer/roboquest/proc/clear_checkMessage()
	checkMessage = ""

/obj/machinery/computer/roboquest/proc/on_quest_complete()
	return // чето будет наверно

/obj/machinery/computer/roboquest/attack_hand(mob/user)
	if(..())
		return TRUE
	ui_interact(user)

/obj/machinery/computer/roboquest/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RoboQuest", name)
		ui.open()

/obj/machinery/computer/roboquest/ui_data(mob/user)
	var/list/data = list()
	if(istype(currentID))
		data["hasID"] = TRUE
		data["name"] = currentID.registered_name
		if(currentID.robo_bounty)
			data["questInfo"] = currentID.robo_bounty.questinfo
			data["hasTask"] = TRUE
		else
			data["questInfo"] = "None"
			data["hasTask"] = FALSE
	else
		data["hasID"] = FALSE
		data["name"] = FALSE
		data["questInfo"] = FALSE
		data["hasTask"] = FALSE
	data["points"] = points
	data["canCheck"] = canCheck
	data["canSend"] = canSend
	data["checkMessage"] = checkMessage
	data["style"] = style
	data["cooldown"] = currentID?.bounty_penalty ? time2text((currentID.bounty_penalty-world.time), "mm:ss") : FALSE
	return data

/obj/machinery/computer/roboquest/ui_static_data(mob/user)
	var/list/data = list()
	data["cats"] = CATS_BY_STAGE
	data["shopItems"] = shop_items
	return data

/obj/machinery/computer/roboquest/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/roboquest),
		get_asset_datum(/datum/asset/spritesheet/roboquest_large)
	)

/obj/machinery/computer/roboquest/ui_act(action, list/params, datum/tgui/ui)
	if(..())
		return

	switch(action)
		if("RemoveID")
			currentID.forceMove(get_turf(src))
			currentID = null
			SStgui.update_uis(src)
		if("GetTask")
			var/list/mecha_types = list("Working Mech" = WORKING_CLASS, "Medical Mech" = MEDICAL_CLASS, "Combat Mech" = COMBAT_CLASS, "Random Mech" = RANDOM_CLASS)
			var/mecha_type = tgui_input_list(usr, "Select event type.", "Select", mecha_types)
			if(!mecha_type || !currentID || currentID.robo_bounty)
				return
			pick_mecha(mecha_types[mecha_type])
		if("RemoveTask")
			currentID.robo_bounty = null
			addtimer(CALLBACK(src, PROC_REF(cooldown_end), currentID), 5 MINUTES)
			currentID.bounty_penalty = world.time + 5 MINUTES
		if("Check")
			if(!pad)
				checkMessage = "Привязанный пад не обнаружен"
			else
				var/amount = check_pad()
				switch(success)
					if(NO_SUCCESS)
						checkMessage = "Мех отсутствует или не соответствует заказу"
					if(CORRECT_MECHA)
						checkMessage = "Мех соответствует заказу, но не имеет заказанных модулей. Награда Будет сильно урезана"
					if(SOME_CORRECT_MODULES)
						checkMessage = "Мех соответствует заказу, но имеет лишь [amount]/[currentID.robo_bounty.modules_amount] модулей. Награда будет слегка урезана."
					if(ALL_CORRECT_MODULES)
						checkMessage = "Мех и модули полностью соответствуют заказу. Награда будет максимальной."
			check_timer = null
			check_timer = addtimer(CALLBACK(src, PROC_REF(clear_checkMessage)), 15 SECONDS)
		if("SendMech")
			check_pad()
			if(canSend)
				// copypast of rcs
				var/list/L = list() // List of avaliable telepads
				var/list/areaindex = list() // Telepad area location
				var/atom/quantum
				for(var/obj/machinery/telepad_cargo/R in GLOB.machines)
					if(R.stage)
						continue
					var/turf/T = get_turf(R)
					var/locname = T.loc.name // The name of the turf area. (e.g. Cargo Bay, Experimentation Lab)

					if(areaindex[locname]) // If there's another telepad with the same area, increment the value so as to not override (e.g. Cargo Bay 2)
						locname = "[locname] ([++areaindex[locname]])"
					else // Else, 1
						areaindex[locname] = 1
					L[locname] = T
				if(params["type"] != "only_packing")
					var/select = tgui_input_list(ui.user, "Please select a telepad.", "RCS", L)
					if(!select)
						return
					if(select == "**Unknown**") // Randomise the teleport location
						return
					else // Else choose the value of the selection
						quantum = L[select]
				flick("sqpad-beam", pad)
				pad.teleport(quantum, currentID.robo_bounty, src, (3-success))
				checkMessage = "Вы отправили меха с оценкой успеха [success] из трех"
				check_timer = null
				check_timer = addtimer(CALLBACK(src, PROC_REF(clear_checkMessage)), 15 SECONDS)
		if("ChangeStyle")
			switch(style)
				if("ntos_roboquest")
					style = "ntos_roboblue"
				if("ntos_roboblue")
					style = "ntos_terminal"
				if("ntos_terminal")
					if(emagged)
						style = "syndicate" //gagaga
					else
						style = "ntos_roboquest"
				if("syndicate")
					style = "ntos_roboquest"
			icon_screen = "robo_[style]"
			SStgui.update_uis(src)
			update_icon()
		if("buyItem")
			var/r_path = text2path(params["item"])
			var/datum/roboshop_item/r_item = new r_path
			for(var/cat in r_item.cost)
				if(points[cat] < r_item.cost[cat])
					to_chat(ui.user, span_warning("There are not enough points."))
					return
			for(var/cat in r_item.cost)
				points[cat] -= r_item.cost[cat]
			new r_item.path(get_turf(src))
			qdel(r_item)
		if("printOrder")
			if(print_delayed)
				return FALSE
			var/datum/roboquest/quest = currentID?.robo_bounty
			if(!istype(quest))
				return FALSE
			print_delayed = TRUE
			print_task(quest)
			addtimer(VARSET_CALLBACK(src, print_delayed, FALSE), 10 SECONDS)

/obj/machinery/computer/roboquest/proc/print_task(datum/roboquest/quest)
	playsound(loc, 'sound/goonstation/machines/printer_thermal.ogg', 50, 1)
	var/obj/item/paper/paper = new(get_turf(src))
	paper.header = "<p><img style='display: block; margin-left: auto; margin-right: auto;' src='ntlogo.png' width='220' height='135' /></p><hr noshade size='4'>"
	paper.info = "<center> <h2> Mecha request form </h2> </center>"
	paper.info += "<ul> <h3> Mecha info:</h3>"
	paper.info += "<li> Mecha type: [quest.name]</li><br>"
	paper.info += "<li> Report: [quest.desc]</li><br>"
	paper.info += "<h3>Requested modules:</h3>"
	for(var/i in quest.questinfo["modules"])
		paper.info += "<li> [i["name"]]</li><br>"
	paper.info += "<br><b> Initial reward:</b> [quest.maximum_cash] credits"
	paper.info += "<p><b>Mecha request accepted by:</b> [currentID.registered_name] - [currentID.rank] at [station_time_timestamp()].</p></ul>"
	paper.info += "<hr><center><small><i>The request has been approved and certified by NAS Trurl.</i></small></center>"
	var/obj/item/stamp/centcom/stamp = new()
	paper.stamp(stamp)
	paper.update_icon()
	paper.name = "NT-CC-RND-[rand(10, 51)] \"Mecha request form\" "

/obj/machinery/computer/roboquest/proc/cooldown_end(obj/item/card/id/penaltycard)
	penaltycard.bounty_penalty = null

/obj/machinery/computer/roboquest/proc/pick_mecha(mecha_type)
	currentID.robo_bounty = new /datum/roboquest(mecha_type)
	currentID.robo_bounty.id = currentID


///////////////////
// roboquest pad //
///////////////////

/obj/machinery/roboquest_pad
	name = "Robotics Request Quantum Pad"
	desc = "A bluespace quantum-linked telepad linked to a orbital long-range matter transmitter."
	icon = 'icons/obj/telescience.dmi'
	icon_state = "sqpad-idle"
	idle_power_usage = 500
	/// Current pad`s console
	var/obj/machinery/computer/roboquest/console

/obj/machinery/roboquest_pad/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/roboquest_pad(null)
	component_parts += new /obj/item/stack/ore/bluespace_crystal/artificial(null)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	RefreshParts()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_EXITED = PROC_REF(on_exited),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/machinery/roboquest_pad/Destroy()
	if(console)
		console.canSend = FALSE
		console.pad = null
		console = null
	. = ..()

/obj/machinery/roboquest_pad/crowbar_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	default_deconstruction_crowbar(user, I)

/obj/machinery/roboquest_pad/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	default_deconstruction_screwdriver(user, "pad-idle-o", "qpad-idle", I)

/obj/machinery/roboquest_pad/proc/teleport(atom/destination, datum/roboquest/quest, obj/machinery/computer/roboquest/console, var/penalty)
	do_sparks(5, 1, get_turf(src))
	var/obj/mecha/M = (locate(/obj/mecha) in get_turf(src))
	if(istype(M))
		var/obj/structure/closet/critter/mecha/box = new(get_turf(src), quest, console, penalty)
		M.forceMove(box)
		if(destination)
			do_teleport(box, destination)
		console.canSend = FALSE

/obj/machinery/roboquest_pad/proc/on_exited(datum/source, atom/movable/departed, atom/newLoc)
	SIGNAL_HANDLER

	if(ismecha(departed) && console)
		console.canSend = FALSE

/obj/machinery/roboquest_pad/multitool_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(!I.multitool_check_buffer(user))
		return
	var/obj/item/multitool/M = I
	M.set_multitool_buffer(user, src)

///////////////
// mecha box //
///////////////

/obj/structure/closet/critter/mecha
	name = "mecha box"
	icon_state = "mecha_box"
	desc = "Special crate for transporting mechas. Compressed by bluespace. Will be discarded by openning."
	req_access = list(ACCESS_ROBOTICS)
	/// RoboQuest, that is mecha for
	var/datum/roboquest/quest
	/// Console for add points
	var/obj/machinery/computer/roboquest/console
	/// Penalty, given by console check
	var/penalty = 0

/obj/structure/closet/critter/mecha/New(loc, datum/roboquest/quest, obj/machinery/computer/roboquest/console, penalty)
	. = ..()
	src.quest = quest
	src.console = console
	src.penalty = penalty

/obj/structure/closet/critter/mecha/toggle(mob/user)
	if(!allowed(user))
		to_chat(user, span_notice("You don`t have required access."))
		playsound(src, pick('sound/machines/button.ogg', 'sound/machines/button_alternate.ogg', 'sound/machines/button_meloboom.ogg'), 20)
		return FALSE
	var/response = alert(user, "This crate has been packed with bluespace compression, opening will destroy container. Are you sure you want to open it?","Bluespace Compression Warning", "Yes", "No")
	if(response == "No" || !Adjacent(user))
		return FALSE
	. = ..()

/obj/structure/closet/critter/mecha/after_open(mob/living/user, force)
	qdel(src)

#undef NO_SUCCESS
#undef CORRECT_MECHA
#undef SOME_CORRECT_MODULES
#undef ALL_CORRECT_MODULES
#undef WORKING_CLASS
#undef MEDICAL_CLASS
#undef COMBAT_CLASS
#undef RANDOM_CLASS
#undef CATS_BY_STAGE
