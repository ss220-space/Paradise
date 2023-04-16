/obj/machinery/computer/aiupload
	name = "\improper AI upload console"
	desc = "Used to upload laws to the AI."
	icon_screen = "command"
	icon_keyboard = "med_key"
	circuit = /obj/item/circuitboard/aiupload
	var/authorization_access = ACCESS_AI_UPLOAD
	var/mob/living/silicon/current = null
	var/opened = FALSE
	var/obj/item/aiModule/installed_module = null
	var/obj/item/card/id/id = null
	var/hacked = FALSE

	light_color = LIGHT_COLOR_WHITE
	light_range_on = 2

// What the fuck even is this
/obj/machinery/computer/aiupload/verb/AccessInternals()
	set category = "Object"
	set name = "Access Computer's Internals"
	set src in oview(1)
	if(get_dist(src, usr) > 1 || usr.restrained() || usr.lying || usr.stat || istype(usr, /mob/living/silicon))
		return

	opened = !opened
	if(opened)
		to_chat(usr, "<span class='notice'>The access panel is now open.</span>")
	else
		to_chat(usr, "<span class='notice'>The access panel is now closed.</span>")
	return

/obj/machinery/computer/aiupload/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/aiModule))
		install_module(user, O)
		ui_interact(user)
		return
	if(istype(O, /obj/item/card/id))
		check_id(user, O)
		ui_interact(user)
		return
	return ..()

/obj/machinery/computer/aiupload/attack_hand(mob/user)
	if(src.stat & NOPOWER)
		to_chat(usr, span_notice("The upload computer has no power!"))
		return
	if(src.stat & BROKEN)
		to_chat(usr, span_notice("The upload computer is broken!"))
		return
	ui_interact(user)

/obj/machinery/computer/aiupload/proc/choose_target(mob/user)
	current = select_active_ai(user)
	if(!current)
		atom_say("No active AIs detected.")
		return
	to_chat(usr, span_notice("[current.name] selected for law changes."))

/obj/machinery/computer/aiupload/proc/install_module(mob/user, obj/item/aiModule/new_module)
	if(installed_module)
		if(!user.put_in_active_hand(installed_module))
			installed_module.forceMove(get_turf(src))
		installed_module = null
		hacked = FALSE
	if(!istype(new_module))
		return
	if(!user.drop_item())
		to_chat(usr, span_warning("[new_module] is stuck to your hand!"))
		return
	new_module.forceMove(src)
	installed_module = new_module
	if(istype(installed_module, /obj/item/aiModule/syndicate))
		hacked = TRUE

/obj/machinery/computer/aiupload/proc/check_id(mob/user, obj/item/card/id/new_id)
	if(id)
		if(!user.put_in_active_hand(id))
			id.forceMove(get_turf(src))
		id = null
	if(!istype(new_id))
		return
	if(!hacked)
		if(!(authorization_access in new_id.access))
			to_chat(usr, span_warning("Unauthorized access."))
			return
	if(!user.drop_item())
		to_chat(usr, span_warning("[new_id] is stuck to your hand!"))
		return
	new_id.forceMove(src)
	id = new_id

/obj/machinery/computer/aiupload/proc/upload_module()
	if(!installed_module || !isAI(current) || (hacked ? FALSE : !id))
		return
	var/mob/living/silicon/ai/ai = current
	if(!atoms_share_level(get_turf(ai), src))
		to_chat(usr, span_notice("Unable to establish a connection: You're too far away from the target silicon!"))
		return
	if(ai.on_the_card)
		to_chat(usr, span_notice("Unable to establish a connection: Target silicon is on an inteliCard or undergoing a repair procedure!"))
		return
	if(installed_module.transmitting)
		installed_module.stopUpload(src)
		return
	installed_module.install(src, id?.registered_name)

/obj/machinery/computer/aiupload/power_change()
	. = ..()
	if(!powered())
		if(installed_module?.transmitting)
			installed_module.stopUpload(src, TRUE)

/obj/machinery/computer/aiupload/on_deconstruction()
	. = ..()
	if(installed_module?.transmitting)
		installed_module.stopUpload(src, TRUE)

/obj/machinery/computer/aiupload/obj_break(damage_flag)
	if(installed_module?.transmitting)
		installed_module.stopUpload(src, TRUE)
	. = ..()

/obj/machinery/computer/aiupload/ui_interact(mob/user, ui_key, datum/tgui/ui, force_open, datum/tgui/master_ui, datum/ui_state/state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "UploadPanel", name, 450, 200, master_ui, state)
		ui.open()

/obj/machinery/computer/aiupload/ui_data(mob/user)
	var/list/data = list()
	data["selected_target"] = current?.name
	data["new_law"] = installed_module
	data["id"] = id?.registered_name
	data["transmitting"] = installed_module?.transmitting
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
		if("target_select")
			choose_target(ui.user)
		if("law_select")
			install_module(ui.user, ui.user.get_active_hand())
		if("authorization")
			check_id(ui.user, ui.user.get_active_hand())
		if("change_laws")
			upload_module()

/obj/machinery/computer/aiupload/attack_ghost(mob/dead/observer/user)
	return TRUE

/obj/machinery/computer/aiupload/cyborg
	name = "cyborg upload console"
	desc = "Used to upload laws to Cyborgs."
	icon_screen = "command"
	icon_keyboard = "med_key"
	authorization_access = ACCESS_ROBOTICS
	circuit = /obj/item/circuitboard/borgupload

/obj/machinery/computer/aiupload/cyborg/choose_target(mob/user)
	current = freeborg()
	if(!current)
		to_chat(usr, span_notice("No free cyborgs detected."))
		return
	to_chat(usr, span_notice("[current.name] selected for law changes."))

/obj/machinery/computer/aiupload/cyborg/upload_module()
	if(!installed_module || !isrobot(current) || (hacked ? FALSE : !id))
		return
	if(!atoms_share_level(get_turf(current), src))
		to_chat(usr, span_notice("Unable to establish a connection: You're too far away from the target silicon!"))
		return
	if(installed_module.transmitting)
		installed_module.stopUpload(src)
		return
	installed_module.install(src, id?.registered_name)
