/obj/item/radio/electropack
	name = "electropack"
	desc = "Dance my monkeys! DANCE!!!"
	icon_state = "electropack0"
	item_state = "electropack"
	frequency = AIRLOCK_FREQ
	flags = CONDUCT
	slot_flags = SLOT_BACK
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

/obj/item/radio/electropack/attackby(obj/item/W, mob/user, params)
	..()
	if(istype(W, /obj/item/clothing/head/helmet))
		if(!b_stat)
			to_chat(user, span_notice("[src] is not ready to be attached!"))
			return
		var/obj/item/assembly/shock_kit/A = new /obj/item/assembly/shock_kit(drop_location())
		A.icon = 'icons/obj/assemblies.dmi'

		if(!user.drop_transfer_item_to_loc(W, A))
			to_chat(user, span_notice("\the [W] is stuck to your hand, you cannot attach it to \the [src]!"))
			return
		W.master = A
		A.part1 = W

		user.drop_transfer_item_to_loc(src, A)
		master = A
		A.part2 = src

		user.put_in_hands(A, ignore_anim = FALSE)
		A.add_fingerprint(user)
		if(flags & NODROP)
			A.flags |= NODROP

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

/obj/item/radio/electropack/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = TRUE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.inventory_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "Electropack", name, 360, 150, master_ui, state)
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
