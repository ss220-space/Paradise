/*
 *	Absorbs /obj/item/secstorage.
 *	Reimplements it only slightly to use existing storage functionality.
 *
 *	Contains:
 *		Secure Briefcase
 *		Wall Safe
 */

// -----------------------------
//         Generic Item
// -----------------------------
/obj/item/storage/secure
	name = "secstorage"
	var/icon_locking = "secureb"
	var/icon_sparking = "securespark"
	var/icon_opened = "secure0"
	var/locked = TRUE
	var/code = ""
	var/l_code = null
	var/l_set = FALSE
	var/l_setshort = FALSE
	var/l_hacking = FALSE
	var/emagged = FALSE
	var/open = FALSE
	w_class = WEIGHT_CLASS_NORMAL
	max_w_class = WEIGHT_CLASS_SMALL
	max_combined_w_class = 14


/obj/item/storage/secure/examine(mob/user)
	. = ..()
	if(in_range(user, src))
		. += "<span class='notice'>The service panel is [open ? "open" : "closed"].</span>"


/obj/item/storage/secure/update_overlays()
	. = ..()
	if(emagged)
		. += icon_locking
	else if(!locked)
		. += icon_opened


/obj/item/storage/secure/populate_contents()
	new /obj/item/paper(src)
	new /obj/item/pen(src)


/obj/item/storage/secure/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 2 SECONDS, volume = I.tool_volume))
		return .
	open = !open
	to_chat(user, span_notice("You [open ? "open" : "close"] the service panel."))


/obj/item/storage/secure/multitool_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!open)
		to_chat(user, span_warning("Open the service panel first."))
		return .
	to_chat(user, span_notice("Now attempting to reset internal memory, please hold..."))
	l_hacking = TRUE
	if(!I.use_tool(src, user, 10 SECONDS, volume = I.tool_volume) || !open)
		l_hacking = FALSE
		return .
	l_hacking = FALSE
	if(!prob(40))
		to_chat(user, span_danger("Unable to reset internal memory."))
		return .
	to_chat(user, span_notice("Internal memory reset. Please give [name] a few seconds to reinitialize..."))
	l_set = FALSE
	l_setshort = TRUE
	addtimer(VARSET_CALLBACK(src, l_setshort, FALSE), 8 SECONDS)


/obj/item/storage/secure/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)	// to allow storing special items
		if(locked)
			add_fingerprint(user)
			to_chat(user, span_warning("It's locked!"))
			return ATTACK_CHAIN_PROCEED
		return ..()

	if(istype(I, /obj/item/melee/energy/blade) && !emagged)
		add_fingerprint(user)
		emag_act(user, I)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(locked)
		add_fingerprint(user)
		to_chat(user, span_warning("It's locked!"))
		return ATTACK_CHAIN_PROCEED

	return ..()


/obj/item/storage/secure/emag_act(mob/user, obj/weapon)
	if(emagged)
		return

	add_attack_logs(user, src, "emagged")
	emagged = TRUE
	locked = FALSE
	playsound(loc, "sparks", 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	flick_overlay_view(image(icon, src, icon_sparking), 1 SECONDS)
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_icon)), 1 SECONDS)

	if(istype(weapon, /obj/item/melee/energy/blade))
		do_sparks(5, 0, loc)
		playsound(loc, 'sound/weapons/blade1.ogg', 50, 1)
		playsound(loc, "sparks", 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		if(user)
			to_chat(user, "You slice through the lock on [src].")
	else if(user)
		to_chat(user, "You short out the lock on [src].")


/obj/item/storage/secure/AltClick(mob/living/user)
	if(!try_to_open(user))
		return FALSE
	return ..()

/obj/item/storage/secure/MouseDrop(atom/over_object, src_location, over_location, src_control, over_control, params)
	if(!try_to_open(usr))
		return FALSE
	return ..()

/obj/item/storage/secure/proc/try_to_open(mob/living/user)
	if(!istype(user) || user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !Adjacent(user))
		return TRUE
	if(locked)
		add_fingerprint(usr)
		to_chat(usr, "<span class='warning'>It's locked!</span>")
		return FALSE
	return TRUE

/obj/item/storage/secure/attack_self(mob/user)
	user.set_machine(src)
	ui_interact(user)

/obj/item/storage/secure/ui_state(mob/user)
	return GLOB.physical_state

/obj/item/storage/secure/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SecureStorage", name)
		ui.open()

/obj/item/storage/secure/ui_data(mob/user)
	var/list/data = list()

	data["emagged"] = emagged
	data["locked"] = locked
	data["l_set"] = l_set
	data["l_setshort"] = l_setshort
	data["current_code"] = (code) ? (isnum(text2num(code))) ? code : "ERROR" : FALSE
	return data


/obj/item/storage/secure/ui_act(action, params)
	if(..())
		return

	if(!usr.IsAdvancedToolUser() && !isobserver(usr))
		to_chat(usr, "<span class='warning'>You are not able to operate [src].</span>")
		return

	. = TRUE
	switch(action)
		if("close")
			locked = TRUE
			code = null
			update_icon(UPDATE_OVERLAYS)
			close(usr)
		if("setnumber")
			switch(params["buttonValue"])
				if("E")
					if(!l_set && (length(code) == 5) && (code != "ERROR"))
						l_code = code
						l_set = TRUE
						to_chat(usr, "<span class = 'notice'>The code was set successfully.</span>")
					else if((code == l_code) && l_set)
						locked = FALSE
						code = null
						update_icon(UPDATE_OVERLAYS)
					else
						code = "ERROR"
				if("R")
					code = null
				else
					code += text("[]", params["buttonValue"])
					if(length(code) > 5 )
						code = "ERROR"

/obj/item/storage/secure/can_be_inserted(obj/item/W, stop_messages = 0)
	if(!locked)
		return ..()
	if(!stop_messages)
		to_chat(usr, "<span class='notice'>[src] is locked!</span>")
	return FALSE

/obj/item/storage/secure/hear_talk(mob/living/M, list/message_pieces)
	return

/obj/item/storage/secure/hear_message(mob/living/M, msg)
	return

// -----------------------------
//        Secure Briefcase
// -----------------------------
/obj/item/storage/secure/briefcase
	name = "secure briefcase"
	desc = "A large briefcase with a digital locking system."
	icon = 'icons/obj/storage.dmi'
	icon_state = "secure"
	item_state = "sec-case"
	flags = CONDUCT
	hitsound = "swing_hit"
	force = 8
	throw_speed = 2
	throw_range = 4
	w_class = WEIGHT_CLASS_BULKY
	max_w_class = WEIGHT_CLASS_NORMAL
	max_combined_w_class = 21
	attack_verb = list("bashed", "battered", "bludgeoned", "thrashed", "whacked")

/obj/item/storage/secure/briefcase/attack_hand(mob/user)
	if((loc == user) && locked)
		to_chat(usr, "<span class='warning'>[src] is locked and cannot be opened!</span>")
	else if((loc == user) && !locked)
		playsound(loc, "rustle", 50, 1, -5)
		user.s_active?.close(user) //Close and re-open
		show_to(user)
	else
		..()
		for(var/mob/M in range(1))
			if(M.s_active == src)
				close(M)
		orient2hud(user)
	add_fingerprint(user)
	return

//Syndie variant of Secure Briefcase. Contains space cash, slightly more robust.
/obj/item/storage/secure/briefcase/syndie
	force = 15

/obj/item/storage/secure/briefcase/syndie/populate_contents()
	for(var/i in 1 to (storage_slots - 2))
		new /obj/item/stack/spacecash/c1000(src)

// -----------------------------
//        Secure Safe
// -----------------------------

/obj/item/storage/secure/safe
	name = "secure safe"
	icon = 'icons/obj/storage.dmi'
	icon_state = "safe"
	icon_opened = "safe0"
	icon_locking = "safeb"
	icon_sparking = "safespark"
	force = 8
	w_class = WEIGHT_CLASS_HUGE
	max_w_class = 8
	anchored = TRUE
	density = FALSE
	cant_hold = list(/obj/item/storage/secure/briefcase)

/obj/item/storage/secure/safe/attack_hand(mob/user)
	return attack_self(user)
