#define IMPLANT_WARN_COOLDOWN (30 SECONDS)

/obj/machinery/computer/prisoner
	name = "labor camp points manager"
	icon = 'icons/obj/machines/computer.dmi'
	icon_keyboard = "security_key"
	icon_screen = "explosive"
	req_access = list(ACCESS_ARMORY)
	circuit = /obj/item/circuitboard/prisoner
	light_color = LIGHT_COLOR_DARKRED
	/// FALSE - No Access Denied, TRUE - Access allowed
	var/authenticated = FALSE
	var/inserted_id_uid


/obj/machinery/computer/prisoner/Initialize(mapload)
	. = ..()
	GLOB.prisoncomputer_list += src


/obj/machinery/computer/prisoner/Destroy()
	GLOB.prisoncomputer_list -= src
	return ..()


/obj/machinery/computer/prisoner/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	var/datum/ui_login/state = ui_login_get()
	if(state.logged_in)
		var/obj/item/card/id/prisoner/id_card = I
		if(istype(id_card))
			if(!user.drop_transfer_item_to_loc(id_card, src))
				return ..()
			inserted_id_uid = id_card.UID()
			return ATTACK_CHAIN_BLOCKED_ALL

	if(ui_login_attackby(I, user))
		add_fingerprint(user)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/machinery/computer/prisoner/attack_ai(mob/user)
	ui_interact(user)


/obj/machinery/computer/prisoner/attack_hand(mob/user)
	if(..())
		return TRUE
	add_fingerprint(user)
	ui_interact(user)


/obj/machinery/computer/prisoner/proc/check_implant(obj/item/implant/checked_imp)
	var/turf/implant_location = get_turf(checked_imp)
	if(!implant_location || implant_location.z != z)
		return FALSE
	if(!checked_imp.implanted)
		return FALSE
	return TRUE


/obj/machinery/computer/prisoner/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PrisonerImplantManager", name)
		ui.open()


/obj/machinery/computer/prisoner/ui_data(mob/user)
	var/list/data = list()
	ui_login_data(data, user)
	var/obj/item/card/id/prisoner/inserted_id = locateUID(inserted_id_uid)
	data["prisonerInfo"] = list(
		"name" = inserted_id?.name,
		"points" = inserted_id?.mining_points,
		"goal" = inserted_id?.goal,
	)

	data["chemicalInfo"] = list()
	for(var/obj/item/implant/chem/chem_imp in GLOB.tracked_implants)
		if(!check_implant(chem_imp))
			continue
		var/list/implant_info = list(
			"name" = chem_imp.imp_in.name,
			"volume" = chem_imp.reagents.total_volume,
			"uid" = chem_imp.UID(),
		)
		data["chemicalInfo"] += list(implant_info)

	data["trackingInfo"] = list()
	for(var/obj/item/implant/tracking/track_imp in GLOB.tracked_implants)
		if(!check_implant(track_imp))
			continue
		var/mob/living/carbon/carrier = track_imp.imp_in
		var/loc_display = "Unknown"
		var/health_display = "OK"
		var/total_loss = (carrier.maxHealth - carrier.health)
		if(carrier.stat == DEAD)
			health_display = "DEAD"
		else if(total_loss)
			health_display = "HURT ([total_loss])"
		var/turf/implant_location = get_turf(track_imp)
		if(!isspaceturf(implant_location))
			loc_display = "[get_area(implant_location)]"

		var/list/implant_info = list(
			"subject" = carrier.name,
			"location" = loc_display,
			"health" = health_display,
			"uid" = track_imp.UID()
		)
		data["trackingInfo"] += list(implant_info)

	data["modal"] = ui_modal_data(src)

	return data


/obj/machinery/computer/prisoner/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	add_fingerprint(ui.user)

	if(ui_act_modal(action, params, ui))
		return
	if(ui_login_act(action, params))
		return

	var/mob/living/user = ui.user
	var/obj/item/card/id/prisoner/inserted_id = locateUID(inserted_id_uid)
	switch(action)
		if("id_card")
			if(inserted_id)
				inserted_id.forceMove_turf()
				ui.user.put_in_hands(inserted_id, ignore_anim = FALSE)
				inserted_id_uid = null
				return
			var/obj/item/card/id/prisoner/card = user.get_active_hand()
			if(istype(card) && user.drop_transfer_item_to_loc(card, src))
				inserted_id_uid = card.UID()
			else
				to_chat(user, span_warning("No valid ID."))

		if("inject")
			var/obj/item/implant/chem/implant = locateUID(params["uid"])
			if(!implant)
				return
			implant.activate(text2num(params["amount"]))

		if("reset_points")
			if(inserted_id)
				inserted_id.mining_points = 0


/obj/machinery/computer/prisoner/proc/ui_act_modal(action, list/params, datum/tgui/ui)
	if(!ui_login_get().logged_in)
		return
	. = TRUE
	var/id = params["id"]
	var/mob/living/user = ui.user
	var/list/arguments = istext(params["arguments"]) ? json_decode(params["arguments"]) : params["arguments"]

	switch(ui_modal_act(src, action, params))
		if(UI_MODAL_OPEN)
			switch(id)
				if("warn")
					ui_modal_input(src, id, "Please enter your message:", null, arguments = list(
						"uid" = arguments["uid"],
					))
				if("set_points")
					ui_modal_input(src, id, "Please enter the new point goal:", null, arguments)

		if(UI_MODAL_ANSWER)
			var/answer = params["answer"]
			switch(id)
				if("warn")
					var/obj/item/implant/tracking/implant = locateUID(arguments["uid"])
					if(!implant)
						return

					if(implant.warn_cooldown >= world.time)
						to_chat(user, span_warning("The warning system for that bio-chip is still cooling down."))
						return

					implant.warn_cooldown = world.time + IMPLANT_WARN_COOLDOWN
					if(implant.imp_in)
						var/mob/living/carbon/implantee = implant.imp_in
						var/warning = copytext_char(sanitize(answer), 1, MAX_MESSAGE_LEN)
						to_chat(implantee, "[span_boldnotice("Your skull vibrates violently as a loud announcement is broadcasted to you: ")][span_userdanger("'[warning]'")]")

				if("set_points")
					if(isnull(text2num(answer)))
						return
					var/obj/item/card/id/prisoner/inserted_id = locateUID(inserted_id_uid)
					inserted_id?.goal = max(text2num(answer), 0)

	return FALSE


#undef IMPLANT_WARN_COOLDOWN

