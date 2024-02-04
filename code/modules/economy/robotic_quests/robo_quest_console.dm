#define NO_SUCCESS 0
#define CORRECT_MECHA 1
#define SOME_CORRECT_MODULES 2
#define ALL_CORRECT_MODULES 3

/obj/machinery/computer/roboquest
	name = "Robotics Request Console"
	desc = "Console used for receiving requests for construction of exosuits."
	icon_screen = "ntos_roboquest"
	icon_keyboard = "rd_key"
	light_color = LIGHT_COLOR_FADEDPURPLE
	var/style = "ntos_roboquest"
	var/canSend = FALSE
	var/canCheck = FALSE
	var/success
	var/checkMessage = ""
	req_access = list(ACCESS_ROBOTICS)
	circuit = /obj/item/circuitboard/roboquest
	var/obj/item/card/id/currentID
	var/obj/machinery/roboquest_pad/pad
	var/difficulty
	var/list/shop_items = list(	list("name" = "fisrt thing", "cost" = 10, "desc" = "Блаблабла"),
								list("name" = "second thing", "cost" = 10, "desc" = "Блаблабла"),
								list("name" = "third thing", "cost" = 10, "desc" = "Блаблабла"),
								list("name" = "foutrh thing", "cost" = 10, "desc" = "Блаблабла"),
								list("name" = "fisrt thing", "cost" = 10, "desc" = "Блаблабла"),
								list("name" = "second thing", "cost" = 10, "desc" = "Блаблабла"),
								list("name" = "third thing", "cost" = 10, "desc" = "Блаблабла"),
								list("name" = "foutrh thing", "cost" = 10, "desc" = "Блаблабла"),
								list("name" = "fisrt thing", "cost" = 10, "desc" = "Блаблабла"),
								list("name" = "second thing", "cost" = 10, "desc" = "Блаблабла"),
								list("name" = "third thing", "cost" = 10, "desc" = "Блаблабла"),
								list("name" = "foutrh thing", "cost" = 10, "desc" = "Блаблабла"),
								list("name" = "fisrt thing", "cost" = 10, "desc" = "Блаблабла"),
								list("name" = "second thing", "cost" = 10, "desc" = "Блаблабла"),
								list("name" = "third thing", "cost" = 10, "desc" = "Блаблабла"),
								list("name" = "foutrh thing", "cost" = 10, "desc" = "Блаблабла"),)

/obj/machinery/computer/roboquest/Initialize(mapload)
	..()
	var/mapping_pad = locate(/obj/machinery/roboquest_pad) in range(2, src)
	if(mapping_pad)
		pad = mapping_pad
		pad.console = src
		canCheck = TRUE

/obj/machinery/computer/roboquest/Destroy()
	for(var/obj/item/I in contents)
		I.forceMove(get_turf(src))
	if(pad)
		pad.console=null
		pad = null
	currentID = null
	. = ..()

/obj/machinery/computer/roboquest/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/card/id))
		currentID = O
		user.drop_item_ground(O)
		O.forceMove(src)
		SStgui.try_update_ui(user, src)
	if(istype(O, /obj/item/multitool))
		var/obj/item/multitool/M = O
		if(M.buffer)
			add_fingerprint(user)
			if(istype(M.buffer, /obj/machinery/roboquest_pad))
				pad = M.buffer
				if(pad.console)
					pad.console.pad = null
				pad.console = src
				canCheck = TRUE
				M.buffer = null

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

/obj/machinery/computer/roboquest/proc/clear_checkMessage()
	checkMessage = ""

/obj/machinery/computer/roboquest/attack_hand(mob/user)
	if(..())
		return TRUE
	ui_interact(user)

/obj/machinery/computer/roboquest/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = TRUE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "RoboQuest", name, 800, 475, master_ui, state)
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
		data["name"] = "None"
		data["questInfo"] = "None"
		data["hasTask"] = FALSE
	data["canCheck"] = canCheck
	data["canSend"] = canSend
	data["checkMessage"] = checkMessage
	data["style"] = style
	data["cooldown"] = currentID?.bounty_penalty ? time2text((currentID.bounty_penalty-world.time), "mm:ss") : FALSE
	return data

/obj/machinery/computer/roboquest/ui_static_data(mob/user)
	var/list/data = list()
	data["shopItems"] = shop_items
	return data

/obj/machinery/computer/roboquest/ui_act(action, list/params)
	switch(action)
		if("RemoveID")
			currentID.forceMove(get_turf(src))
			currentID = null
			SStgui.update_uis(src)
		if("GetTask")
			difficulty = tgui_input_list(usr, "Select event type.", "Select", list("easy", "medium", "hard"))
			if(!difficulty)
				return
			pick_mecha(difficulty)
		if("RemoveTask")
			currentID.robo_bounty = null
			addtimer(CALLBACK(src, PROC_REF(cooldown_end), currentID), 5 MINUTES)
			currentID.bounty_penalty = world.time + 5 MINUTES
		if("Check")
			if(!pad)
				to_chat(usr, "Привязанного пада нет, че ты собрался проверять, дебил")
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
				addtimer(CALLBACK(src, PROC_REF(clear_checkMessage)), 15 SECONDS)
		if("SendMech")
			check_pad()
			flick("sqpad-beam", pad)
			pad.sparks()
			to_chat(usr, "Вы отправили меха с оценкой успеха [success] из трех")
		if("ChangeStyle")
			switch(style)
				if("ntos_roboquest")
					style = "ntos_roboblue"
				if("ntos_roboblue")
					style = "ntos_terminal"
				if("ntos_terminal")
					style = "ntos_roboquest"
			icon_screen = style
			SStgui.update_uis(src)
			update_icon()

/obj/machinery/computer/roboquest/proc/cooldown_end(obj/item/card/id/penaltycard)
	penaltycard.bounty_penalty = null

/obj/machinery/computer/roboquest/proc/pick_mecha()
	currentID.robo_bounty = new /datum/roboquest
/obj/machinery/roboquest_pad
	name = "Robotics Request Quantum Pad"
	desc = "A bluespace quantum-linked telepad linked to a orbital long-range matter transmitter."
	icon = 'icons/obj/telescience.dmi'
	icon_state = "sqpad-idle"
	idle_power_usage = 500
	var/obj/machinery/computer/roboquest/console

/obj/machinery/roboquest_pad/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/roboquest_pad(null)
	component_parts += new /obj/item/stack/ore/bluespace_crystal/artificial(null)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	RefreshParts()

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

/obj/machinery/roboquest_pad/proc/sparks()
	do_sparks(5, 1, get_turf(src))

/obj/machinery/roboquest_pad/New()
	RegisterSignal(src, COMSIG_MOVABLE_UNCROSSED, PROC_REF(ismechgone))
	. = ..()

/obj/machinery/roboquest_pad/proc/ismechgone(datum/source, atom/movable/exiting)
	if(ismecha(exiting) && console)
		console.canSend = FALSE

/obj/machinery/roboquest_pad/multitool_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(!I.multitool_check_buffer(user))
		return
	var/obj/item/multitool/M = I
	M.set_multitool_buffer(user, src)
