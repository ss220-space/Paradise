/obj/item/twohanded/rcl
	name = "rapid cable layer (RCL)"
	desc = "A device used to rapidly deploy cables. It has screws on the side which can be removed to slide off the cables."
	icon = 'icons/obj/tools.dmi'
	icon_state = "rcl-0"
	item_state = "rcl-0"
	force = 5 //Plastic is soft
	throwforce = 5
	throw_speed = 1
	throw_range = 7
	w_class = WEIGHT_CLASS_NORMAL
	origin_tech = "engineering=4;materials=2"
	var/max_amount = 90
	var/active = 0
	var/obj/structure/cable/last = null
	var/obj/item/stack/cable_coil/loaded = null


/obj/item/twohanded/rcl/attackby(obj/item/I, mob/user, params)
	if(iscoil(I))
		add_fingerprint(user)
		var/obj/item/stack/cable_coil/coil = I
		if(!loaded)
			if(!user.drop_transfer_item_to_loc(coil, src))
				return ..()
			loaded = coil
			loaded.max_amount = max_amount //We store a lot.
			update_icon(UPDATE_ICON_STATE)
			to_chat(user, span_notice("You add the cables to the [src]. It now contains [loaded.amount]."))
			return ATTACK_CHAIN_BLOCKED_ALL
		if(loaded.amount >= max_amount)
			to_chat(user, span_warning("The [name]'s cable storage is full."))
			return ATTACK_CHAIN_PROCEED
		to_chat(user, span_notice("You load some cable into [src]."))
		var/amount = min(loaded.amount + coil.amount, max_amount)
		coil.use(amount - loaded.amount)
		loaded.amount = amount
		update_icon(UPDATE_ICON_STATE)
		to_chat(user, span_notice("You add the cables to the [src]. It now contains [loaded.amount]."))
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()


/obj/item/twohanded/rcl/screwdriver_act(mob/user, obj/item/I)
	if(!loaded)
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	to_chat(user, "<span class='notice'>You loosen the securing screws on the side, allowing you to lower the guiding edge and retrieve the wires.</span>")
	while(loaded.amount > 30) //There are only two kinds of situations: "nodiff" (60,90), or "diff" (31-59, 61-89)
		var/diff = loaded.amount % 30
		if(diff)
			loaded.use(diff)
			new /obj/item/stack/cable_coil(user.loc, diff)
		else
			loaded.use(30)
			new /obj/item/stack/cable_coil(user.loc, 30)
	loaded.max_amount = initial(loaded.max_amount)
	loaded.forceMove(user.loc)
	user.put_in_hands(loaded)
	loaded = null
	update_icon(UPDATE_ICON_STATE)

/obj/item/twohanded/rcl/examine(mob/user)
	. = ..()
	if(loaded)
		. += "<span class='notice'>It contains [loaded.amount]/[max_amount] cables.</span>"

/obj/item/twohanded/rcl/Destroy()
	QDEL_NULL(loaded)
	last = null
	active = 0
	return ..()


/obj/item/twohanded/rcl/update_icon_state()
	if(!loaded)
		icon_state = "rcl-0"
		item_state = "rcl-0"
		return
	switch(loaded.amount)
		if(61 to INFINITY)
			icon_state = "rcl-30"
			item_state = "rcl"
		if(31 to 60)
			icon_state = "rcl-20"
			item_state = "rcl"
		if(1 to 30)
			icon_state = "rcl-10"
			item_state = "rcl"
		else
			icon_state = "rcl-0"
			item_state = "rcl-0"


/obj/item/twohanded/rcl/proc/is_empty(mob/user, loud = 1)
	update_icon(UPDATE_ICON_STATE)
	if(!loaded || !loaded.amount)
		if(loud)
			to_chat(user, "<span class='notice'>The last of the cables unreel from [src].</span>")
		if(loaded)
			qdel(loaded)
			loaded = null
		user.mode()
		active = wielded
		return 1
	return 0

/obj/item/twohanded/rcl/equipped(mob/user, slot, initial)
	. = ..()
	RegisterSignal(user, COMSIG_MOB_CLIENT_MOVED, PROC_REF(on_mob_move), override = TRUE)

/obj/item/twohanded/rcl/dropped(mob/user, slot, silent = FALSE)
	. = ..()
	active = 0
	last = null
	UnregisterSignal(user, COMSIG_MOB_CLIENT_MOVED)

/obj/item/twohanded/rcl/attack_self(mob/user)
	..()
	active = wielded
	if(!active)
		last = null
	else if(!last)
		for(var/obj/structure/cable/C in get_turf(user))
			if(C.d1 == 0 || C.d2 == 0)
				last = C
				break

/obj/item/twohanded/rcl/on_mob_move(mob/user, dir)
	if(active)
		trigger(user)

/obj/item/twohanded/rcl/proc/trigger(mob/user)
	if(is_empty(user, 0))
		to_chat(user, "<span class='warning'>\The [src] is empty!</span>")
		return
	if(last)
		if(get_dist(last, user) == 1) //hacky, but it works
			var/turf/T = get_turf(user)
			if(!T || !T.can_lay_cable())
				last = null
				return
			if(get_dir(last, user) == last.d2)
				//Did we just walk backwards? Well, that's the one direction we CAN'T complete a stub.
				last = null
				return
			loaded.cable_join(last, user)
			if(is_empty(user))
				return //If we've run out, display message and exit
		else
			last = null
	last = loaded.place_turf(get_turf(loc), user, turn(user.dir, 180))
	is_empty(user) //If we've run out, display message

/obj/item/twohanded/rcl/pre_loaded/New() //Comes preloaded with cable, for testing stuff
	..()
	loaded = new()
	loaded.max_amount = max_amount
	loaded.amount = max_amount
	update_icon(UPDATE_ICON_STATE)
