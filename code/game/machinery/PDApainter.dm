/obj/machinery/pdapainter
	name = "PDA painter"
	desc = "A PDA painting machine. To use, simply insert your PDA and choose the desired preset paint scheme."
	icon = 'icons/obj/pda.dmi'
	icon_state = "pdapainter"
	base_icon_state = "pdapainter"
	density = TRUE
	anchored = TRUE
	max_integrity = 200
	var/obj/item/pda/storedpda = null
	var/static/list/colorlist
	var/statusLabel
	var/statusLabelCooldownTime = 0
	var/statusLabelCooldownTimeSecondsToAdd = 20 // 20 deciseconds = 2 seconds, 1sec = 0.1 decisecond
	var/allowErasePda = TRUE


/obj/machinery/pdapainter/Initialize(mapload)
	. = ..()

	if(colorlist)
		return

	var/list/available_pdas = typesof(/obj/item/pda) - list(
		/obj/item/pda/silicon,
		/obj/item/pda/silicon/ai,
		/obj/item/pda/silicon/robot,
		/obj/item/pda/silicon/pai,
		/obj/item/pda/heads,
		/obj/item/pda/clear,
		/obj/item/pda/syndicate,
		/obj/item/pda/chameleon,
		/obj/item/pda/chameleon/broken,
	)

	var/new_color_list = list()
	for(var/obj/item/pda/pda as anything in available_pdas)
		// Get Base64 version of an icon for our TGUI needs.
		// Always try to get first frame as it can be animation resulting in all frames in single image.
		// pda-library as an example has 4 frames
		var/base64icon = "[icon2base64(icon(initial(pda.icon), initial(pda.icon_state), frame = 1))]"
		new_color_list[initial(pda.icon_state)] = list(base64icon, initial(pda.desc))

	new_color_list = sortAssoc(new_color_list)
	colorlist = new_color_list


/obj/machinery/pdapainter/Destroy()
	QDEL_NULL(storedpda)
	return ..()


/obj/machinery/pdapainter/update_icon_state()
	if(stat & BROKEN)
		icon_state = "[base_icon_state]-broken"
		return

	if(powered())
		icon_state = base_icon_state
	else
		icon_state = "[base_icon_state]-off"


/obj/machinery/pdapainter/update_overlays()
	. = ..()
	if(stat & BROKEN)
		return
	if(storedpda)
		. += "[base_icon_state]-closed"


/obj/machinery/pdapainter/on_deconstruction()
	if(storedpda)
		storedpda.forceMove(loc)
		storedpda = null

/obj/machinery/pdapainter/ex_act(severity)
	if(storedpda)
		storedpda.ex_act(severity)
	..()

/obj/machinery/pdapainter/handle_atom_del(atom/A)
	if(A == storedpda)
		storedpda = null
		update_icon()


/obj/machinery/pdapainter/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	default_unfasten_wrench(user, I)


/obj/machinery/pdapainter/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(is_pda(I))
		add_fingerprint(user)
		if(storedpda)
			to_chat(user, span_warning("В аппарате уже есть PDA."))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		storedpda = I
		update_icon()
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/machinery/pdapainter/welder_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	default_welder_repair(user, I)

/obj/machinery/pdapainter/deconstruct(disassembled = TRUE)
	if(!(obj_flags & NODECONSTRUCT))
		if(!(stat & BROKEN))
			stat |= BROKEN
			update_icon()

/obj/machinery/pdapainter/attack_hand(mob/user as mob)
	if(..())
		return 1

	// Do not let click buttons if you're ghost unless you're an admin.
	// TODO: To parent class or separate helper method?
	if (isobserver(usr) && !is_admin(usr))
		return FALSE

	ui_interact(user)


/obj/machinery/pdapainter/power_change(forced = FALSE)
	if(!..())
		return
	update_icon()



// TGUI Related.

/obj/machinery/pdapainter/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PDAPainter",  "PDA painting machine")
		ui.open()

/obj/machinery/pdapainter/ui_data(mob/user)
	var/data = list()

	if(storedpda)
		data["hasPDA"] = TRUE
		data["pdaIcon"] = storedpda.base64icon
		data["pdaOwnerName"] = storedpda.owner
		data["pdaJobName"] = storedpda.ownjob
	else
		data["hasPDA"] = FALSE
		data["pdaIcon"] = null
		data["pdaOwnerName"]  = null
		data["pdaJobName"] = null

	if(canUpdateStatusLabel())
		data["statusLabel"] = storedpda ? "OK" : "PDA не найден"
	else
		data["statusLabel"] = statusLabel

	return data

/obj/machinery/pdapainter/ui_static_data(mob/user)
	var/data = list()
	data["pdaTypes"] = colorlist
	data["allowErasePda"] = allowErasePda
	return data

/obj/machinery/pdapainter/ui_act(action, params)
	if(..())
		return

	. = TRUE

	switch(action)
		if("insert_pda")
			insert_pda()
		if("eject_pda")
			eject_pda()
		if("choose_pda")
			if(storedpda)
				storedpda.remove_pda_case()
				var/new_icon = params["selectedPda"]
				storedpda.current_painting = list("icon" = new_icon, "base64" = colorlist[new_icon][1], "desc" = colorlist[new_icon][2])
				storedpda.update_appearance(UPDATE_ICON_STATE|UPDATE_DESC)
				playsound(loc, 'sound/goonstation/machines/printer_thermal.ogg', 15, TRUE)
				statusLabel = "Покраска завершена"
				statusLabelCooldownTime = world.time + statusLabelCooldownTimeSecondsToAdd
		if("erase_pda")
			erase_pda()

	if(.)
		add_fingerprint(usr)

/obj/machinery/pdapainter/proc/insert_pda()
	if(!storedpda) // PDA is NOT in the machine.
		if(ishuman(usr))
			var/obj/item/pda/P = usr.get_active_hand()

			if(istype(P)) // If it is really PDA.
				if(usr.drop_transfer_item_to_loc(P, src))
					storedpda = P
					P.add_fingerprint(usr)
					update_icon()
					SStgui.update_uis(src)
					return TRUE

/obj/machinery/pdapainter/proc/erase_pda()
	if(storedpda) // PDA is in machine.
		if(ishuman(usr))
			if (storedpda.id || storedpda.cartridge)
				to_chat(usr, span_notice("Уберите карту и картридж из PDA."))
				statusLabel = "Уберите карту и картридж"
				statusLabelCooldownTime = world.time + statusLabelCooldownTimeSecondsToAdd
			else
				qdel(storedpda)
				storedpda = new /obj/item/pda(src)
				to_chat(usr, span_notice("Данные на PDA полностью стерты."))
				statusLabel = "PDA очищен"
				statusLabelCooldownTime = world.time + statusLabelCooldownTimeSecondsToAdd

/obj/machinery/pdapainter/proc/eject_pda(var/obj/item/pda/pda = null)
	if(storedpda) // PDA is in machine.
		if(ishuman(usr))
			storedpda.forceMove(get_turf(src))
			if(!usr.get_active_hand() && Adjacent(usr))
				storedpda.forceMove_turf()
				usr.put_in_hands(storedpda, ignore_anim = FALSE)
			storedpda = null
		else
			storedpda.forceMove(get_turf(src))
			storedpda = null
		update_icon()
	SStgui.update_uis(src)
	// SStgui.close_uis(src) // this  can close window on its own, nice

/obj/machinery/pdapainter/proc/canUpdateStatusLabel()
	return (statusLabelCooldownTime < world.time)
