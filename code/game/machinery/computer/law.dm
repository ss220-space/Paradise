#define NORMAL_UPLOAD_DELAY 20 SECONDS
#define SHORTEN_UPLOAD_DELAY 5 SECONDS

/obj/machinery/computer/aiupload
	name = "\improper AI upload console"
	desc = "Используется для манипуляций с законами ИИ."
	icon_screen = "command"
	icon_keyboard = "med_key"
	circuit = /obj/item/circuitboard/aiupload
	req_access = list(ACCESS_AI_UPLOAD)
	var/mob/living/silicon/current = null
	var/obj/item/ai_module/installed_module = null
	var/obj/item/card/id/id = null
	var/hacked = FALSE

	var/static/list/shorten_delay = list(
		/obj/item/ai_module/purge,
		/obj/item/ai_module/reset
		)
	var/timer_id = null
	var/reg_name = null

	light_color = LIGHT_COLOR_WHITE
	light_range_on = 2


/obj/machinery/computer/aiupload/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(I, /obj/item/ai_module))
		add_fingerprint(user)
		insert_module(user, I)
		ui_interact(user)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(istype(I, /obj/item/card/id))
		add_fingerprint(user)
		check_id(user, I)
		ui_interact(user)
		return
	return ..()

/obj/machinery/computer/aiupload/attack_hand(mob/user)
	if(stat & NOPOWER)
		to_chat(user, span_notice("The upload computer has no power!"))
		return
	if(stat & BROKEN)
		to_chat(user, span_notice("The upload computer is broken!"))
		return
	ui_interact(user)

/obj/machinery/computer/aiupload/attack_ghost(mob/user)
	return TRUE

/obj/machinery/computer/aiupload/proc/choose_silicon(mob/user)
	current = select_active_ai(user)
	if(!current)
		atom_say("No active AIs detected.")
		return
	to_chat(user, span_notice("[current.name] selected for law changes."))

/obj/machinery/computer/aiupload/proc/insert_module(mob/user, obj/item/ai_module/new_module)
	if(installed_module)
		if(!user.put_in_active_hand(installed_module))
			installed_module.forceMove(get_turf(src))
		installed_module = null
		hacked = FALSE
	if(!istype(new_module))
		return
	if(!user.drop_transfer_item_to_loc(new_module, src))
		to_chat(usr, span_warning("[new_module] is stuck to your hand!"))
		return
	installed_module = new_module
	if(istype(installed_module, /obj/item/ai_module/syndicate))
		hacked = TRUE

/obj/machinery/computer/aiupload/proc/check_id(mob/user, obj/item/card/id/new_id)
	if(id)
		if(!user.put_in_active_hand(id))
			id.forceMove(get_turf(src))
		id = null
	if(!istype(new_id))
		return
	if(!hacked)
		if(!check_access(new_id))
			to_chat(user, span_warning("Unauthorized access."))
			return
	if(!user.drop_transfer_item_to_loc(new_id, src))
		to_chat(user, span_warning("[new_id] is stuck to your hand!"))
		return
	id = new_id

// stop upload or start upload
/obj/machinery/computer/aiupload/proc/upload_module(mob/user)
	if(stat & NOPOWER)
		to_chat(user, span_warning("The upload computer has no power!"))
		return
	if(stat & BROKEN)
		to_chat(user, span_warning("The upload computer is broken!"))
		return
	if(!current)
		to_chat(user, span_warning("You haven't selected an AI to transmit laws to!"))
		return

	if(!installed_module || !isAI(current) || (hacked ? FALSE : !id))
		return

	if(timer_id)
		stop_upload()
		return

	var/mob/living/silicon/ai/ai = current
	if(!atoms_share_level(get_turf(ai), src))
		to_chat(user, span_notice("Unable to establish a connection: You're too far away from the target silicon!"))
		return
	if(ai.on_the_card)
		to_chat(user, span_notice("Unable to establish a connection: Target silicon is on an inteliCard or undergoing a repair procedure!"))
		return
	if(ai.stat == DEAD || ai.control_disabled)
		to_chat(user, span_notice("Unable to establish a connection: No signal is being detected from the AI."))
		return
	if(ai.nightvision == 0)
		to_chat(user, span_notice("Unable to establish a connection: Only a faint signal is being detected from the AI, and it is not responding to our requests. It may be low on power."))
		return
	if(!installed_module.check_install(user))
		return

	var/delay = (installed_module in shorten_delay) ? SHORTEN_UPLOAD_DELAY : NORMAL_UPLOAD_DELAY
	to_chat(user, span_notice("Upload process has started. ETA: [delay/10] seconds."))
	timer_id = addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/machinery/computer/aiupload, finish_upload), user), delay, TIMER_STOPPABLE)

/obj/machinery/computer/aiupload/proc/finish_upload(mob/user)
	timer_id = null
	installed_module.transmit_instructions(current, user, reg_name)
	to_chat(current, "These are your laws now:")
	current.show_laws()
	for(var/mob/living/silicon/robot/R in GLOB.mob_list)
		if(R.lawupdate && (R.connected_ai == current))
			to_chat(R, "These are your laws now:")
			R.show_laws()
	atom_say("Upload complete. The laws have been modified.")

/obj/machinery/computer/aiupload/proc/stop_upload(silent = FALSE)
	deltimer(timer_id)
	timer_id = null
	if(!silent)
		atom_say("Upload has been interrupted.")

/obj/machinery/computer/aiupload/power_change()
	. = ..()
	if(!powered())
		if(timer_id)
			stop_upload(TRUE)

/obj/machinery/computer/aiupload/on_deconstruction()
	. = ..()
	if(timer_id)
		stop_upload(TRUE)
	current = null
	installed_module = null
	id = null

/obj/machinery/computer/aiupload/obj_break(damage_flag)
	if(timer_id)
		stop_upload(TRUE)
	. = ..()

/obj/machinery/computer/aiupload/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "UploadPanel", name)
		ui.open()

/obj/machinery/computer/aiupload/ui_data(mob/user)
	var/list/data = list()
	data["selected_target"] = current?.name
	data["new_law"] = installed_module
	data["id"] = id?.registered_name
	data["transmitting"] = timer_id ? TRUE : FALSE
	data["hacked"] = hacked
	return data

/obj/machinery/computer/aiupload/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	if(issilicon(ui.user))
		to_chat(usr, span_danger("Access Denied (silicon detected)"))
		return
	add_fingerprint(usr)
	switch(action)
		if("choose_silicon")
			choose_silicon(ui.user)
		if("insert_module")
			insert_module(ui.user, ui.user.get_active_hand())
		if("authorization")
			check_id(ui.user, ui.user.get_active_hand())
		if("change_laws")
			upload_module(ui.user)

/obj/machinery/computer/aiupload/cyborg
	name = "cyborg upload console"
	desc = "Используется для манипуляций с законами киборгов."
	icon_screen = "command"
	icon_keyboard = "med_key"
	req_access = list(ACCESS_ROBOTICS)
	circuit = /obj/item/circuitboard/borgupload

/obj/machinery/computer/aiupload/cyborg/choose_silicon(mob/user)
	current = freeborg()
	if(!current)
		to_chat(user, span_notice("No free cyborgs detected."))
		return
	to_chat(user, span_notice("[current.name] selected for law changes."))

/obj/machinery/computer/aiupload/cyborg/upload_module(mob/user)
	if(stat & NOPOWER)
		to_chat(user, span_warning("The upload computer has no power!"))
		return
	if(stat & BROKEN)
		to_chat(user, span_warning("The upload computer is broken!"))
		return
	if(!current)
		to_chat(user, span_warning("No borg selected. Please chose a target before proceeding with upload."))
		return
	if(!installed_module || !isrobot(current) || (hacked ? FALSE : !id))
		return

	if(timer_id)
		stop_upload()
		return

	var/mob/living/silicon/robot/robot = current
	if(!atoms_share_level(get_turf(current), src))
		to_chat(user, span_notice("Unable to establish a connection: You're too far away from the target silicon!"))
		return
	if(robot.stat == DEAD || robot.emagged)
		to_chat(user, span_notice("Unable to establish a connection: No signal is being detected from the robot."))
		return
	if(robot.connected_ai)
		to_chat(user, span_notice("Unable to establish a connection: The robot is slaved to an AI."))
		return
	if(!installed_module.check_install(user))
		return

	var/delay = (installed_module in shorten_delay) ? SHORTEN_UPLOAD_DELAY : NORMAL_UPLOAD_DELAY
	to_chat(user, span_notice("Upload process has started. ETA: [delay/10] seconds."))
	reg_name = hacked ? "UNKNOWN" : id.registered_name
	timer_id = addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/machinery/computer/aiupload, finish_upload), user), delay, TIMER_STOPPABLE)

/obj/machinery/computer/aiupload/cyborg/finish_upload(mob/user)
	timer_id = null
	installed_module.transmit_instructions(current, user, reg_name)
	to_chat(current, "These are your laws now:")
	current.show_laws()
	atom_say("Upload complete. The laws have been modified.")

#undef NORMAL_UPLOAD_DELAY
#undef SHORTEN_UPLOAD_DELAY
