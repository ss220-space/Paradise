/obj/item/radio/electropack
	name = "electropack"
	desc = "Dance my monkeys! DANCE!!!"
	icon_state = "electropack0"
	item_state = "electropack"
	frequency = AIRLOCK_FREQ
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_HUGE
	materials = list(MAT_METAL=10000, MAT_GLASS=2500)
	var/code = 2
	var/intensivity = TRUE

/obj/item/radio/electropack/attack_hand(mob/user)
	if(src == user.back)
		to_chat(user, span_notice("You need help taking this off!"))
		return FALSE
	. = ..()

/obj/item/radio/electropack/Destroy()
	if(istype(loc, /obj/item/assembly/shock_kit))
		var/obj/item/assembly/shock_kit/S = loc
		if(S.part1 == src)
			S.part1 = null
		else if(S.part2 == src)
			S.part2 = null
		master = null
	return ..()


/obj/item/radio/electropack/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/clothing/head/helmet))
		add_fingerprint(user)
		if(!b_stat)
			to_chat(user, span_notice("[src] is not ready to be attached!"))
			return ATTACK_CHAIN_PROCEED
		var/obj/item/assembly/shock_kit/shock_kit = new(drop_location())
		if((loc == user && !user.can_unEquip(src)) || !user.drop_transfer_item_to_loc(I, shock_kit))
			qdel(shock_kit)
			return ATTACK_CHAIN_PROCEED
		if(loc == user)
			user.transfer_item_to_loc(src, shock_kit, silent = TRUE)
		else
			forceMove(shock_kit)
		shock_kit.icon = 'icons/obj/assemblies.dmi'
		shock_kit.add_fingerprint(user)

		I.master = shock_kit
		shock_kit.part1 = I

		master = shock_kit
		shock_kit.part2 = src

		user.put_in_hands(shock_kit, ignore_anim = FALSE)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/item/radio/electropack/receive_signal(datum/signal/signal)
	if(!signal || signal.encryption != code)
		return

	if(isliving(loc) && on)
		var/mob/living/M = loc
		if(isturf(M.loc) && M.last_move && intensivity)
			step(M, M.last_move)
			intensivity = FALSE
			addtimer(CALLBACK(src, PROC_REF(intensify)), 5 SECONDS)
		to_chat(M, span_userdanger("You feel a sharp shock!"))
		do_sparks(3, TRUE, M)

		M.Weaken(10 SECONDS)

	if(master)
		master.receive_signal()
	return

/obj/item/radio/electropack/proc/intensify()
	intensivity = TRUE

/obj/item/radio/electropack/ui_state(mob/user)
	return GLOB.inventory_state

/obj/item/radio/electropack/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Electropack", name)
		ui.open()

/obj/item/radio/electropack/ui_data(mob/user)
	var/list/data = list()
	data["power"] = on
	data["frequency"] = frequency
	data["code"] = code
	data["minFrequency"] = PUBLIC_LOW_FREQ
	data["maxFrequency"] = PUBLIC_HIGH_FREQ
	return data

/obj/item/radio/electropack/ui_act(action, params)
	if(isnull(..()))	// We still can use item if parent returns FALSE.
		return
	. = TRUE
	switch(action)
		if("power")
			on = !on
		if("freq")
			var/value = params["freq"]
			if(value)
				frequency = sanitize_frequency(text2num(value) * 10)
				set_frequency(frequency)
			else
				. = FALSE
		if("code")
			var/value = text2num(params["code"])
			if(value)
				value = round(value)
				code = clamp(value, 1, 100)
			else
				. = FALSE
		if("reset")
			if(params["reset"] == "freq")
				frequency = initial(frequency)
			else if(params["reset"] == "code")
				code = initial(code)
			else
				. = FALSE
	if(.)
		add_fingerprint(usr)
