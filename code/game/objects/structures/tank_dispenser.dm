#define MAX_TANK_STORAGE	10

/obj/structure/dispenser
	name = "tank storage unit"
	desc = "A simple yet bulky storage device for gas tanks. Has room for up to ten oxygen tanks, and ten plasma tanks."
	icon = 'icons/obj/objects.dmi'
	icon_state = "dispenser"
	density = TRUE
	anchored = TRUE
	pass_flags_self = LETPASSTHROW
	var/starting_oxygen_tanks = MAX_TANK_STORAGE // The starting amount of oxygen tanks the dispenser gets when it's spawned
	var/starting_plasma_tanks = MAX_TANK_STORAGE // Starting amount of plasma tanks
	var/list/stored_oxygen_tanks = list() // List of currently stored oxygen tanks
	var/list/stored_plasma_tanks = list() // And plasma tanks

/obj/structure/dispenser/oxygen
	starting_plasma_tanks = 0

/obj/structure/dispenser/plasma
	starting_oxygen_tanks = 0

/obj/structure/dispenser/Initialize(mapload)
	. = ..()
	initialize_tanks()
	update_icon(UPDATE_OVERLAYS)

/obj/structure/dispenser/Destroy()
	QDEL_LIST(stored_plasma_tanks)
	QDEL_LIST(stored_oxygen_tanks)
	return ..()

/obj/structure/dispenser/proc/initialize_tanks()
	for(var/I in 1 to starting_plasma_tanks)
		var/obj/item/tank/internals/plasma/P = new(src)
		stored_plasma_tanks.Add(P)

	for(var/I in 1 to starting_oxygen_tanks)
		var/obj/item/tank/internals/oxygen/O = new(src)
		stored_oxygen_tanks.Add(O)


/obj/structure/dispenser/update_overlays()
	. = ..()
	var/oxy_tank_amount = LAZYLEN(stored_oxygen_tanks)
	switch(oxy_tank_amount)
		if(1 to 3)
			. += "oxygen-[oxy_tank_amount]"
		if(4 to INFINITY)
			. += "oxygen-4"

	var/pla_tank_amount = LAZYLEN(stored_plasma_tanks)
	switch(pla_tank_amount)
		if(1 to 4)
			. += "plasma-[pla_tank_amount]"
		if(5 to INFINITY)
			. += "plasma-5"


/obj/structure/dispenser/attack_hand(mob/user)
	if(..())
		return 1
	ui_interact(user)

/obj/structure/dispenser/attack_ghost(mob/user)
	ui_interact(user)

/obj/structure/dispenser/attack_robot(mob/user)
	if(Adjacent(user))
		ui_interact(user)

/obj/structure/dispenser/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TankDispenser", name)
		ui.open()

/obj/structure/dispenser/ui_data(user)
	var/list/data = list()
	data["o_tanks"] = LAZYLEN(stored_oxygen_tanks)
	data["p_tanks"] = LAZYLEN(stored_plasma_tanks)
	return data

/obj/structure/dispenser/ui_act(action, list/params)
	if(..())
		return

	switch(action)
		if("oxygen")
			try_remove_tank(usr, stored_oxygen_tanks)

		if("plasma")
			try_remove_tank(usr, stored_plasma_tanks)

	add_fingerprint(usr)
	return TRUE


/obj/structure/dispenser/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
	set_anchored(!anchored)
	to_chat(user, span_notice("[anchored ? "You wrench [src] into place." : "You lean down and unwrench [src]."]"))


/obj/structure/dispenser/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	var/static/list/allowed_to_store = typecacheof(list(
		/obj/item/tank/internals/oxygen,
		/obj/item/tank/internals/air,
		/obj/item/tank/internals/anesthetic,
		/obj/item/tank/internals/plasma,
	))
	if(is_type_in_typecache(I, allowed_to_store))
		if(try_insert_tank(user, istype(I, /obj/item/tank/internals/plasma) ? stored_plasma_tanks : stored_oxygen_tanks, I))
			return ATTACK_CHAIN_BLOCKED_ALL
		return ATTACK_CHAIN_PROCEED

	return ..()


/// Called when the user clicks on the oxygen or plasma tank UI buttons, and tries to withdraw a tank.
/obj/structure/dispenser/proc/try_remove_tank(mob/living/user, list/tank_list)
	if(!LAZYLEN(tank_list))
		return // There are no tanks left to withdraw.

	var/obj/item/tank/internals/tank = tank_list[1]
	tank_list.Remove(tank)

	tank.forceMove_turf()
	user.put_in_hands(tank, ignore_anim = FALSE)

	to_chat(user, span_notice("You have taken [tank] out of [src]."))
	update_icon(UPDATE_OVERLAYS)


/// Called when the user clicks on the dispenser with a tank. Tries to insert the tank into the dispenser, and updates the UI if successful.
/obj/structure/dispenser/proc/try_insert_tank(mob/living/user, list/tank_list, obj/item/tank/tank)
	add_fingerprint(user)
	if(LAZYLEN(tank_list) >= MAX_TANK_STORAGE)
		to_chat(user, span_warning("The [name] is full."))
		return FALSE

	if(!user.drop_transfer_item_to_loc(tank, src)) // Antidrop check
		return FALSE

	. = TRUE
	tank_list += tank
	update_icon(UPDATE_OVERLAYS)
	to_chat(user, span_notice("You have put [tank] into [src]."))
	SStgui.update_uis(src)


/obj/structure/tank_dispenser/deconstruct(disassembled = TRUE)
	if(!(obj_flags & NODECONSTRUCT))
		for(var/X in src)
			var/obj/item/I = X
			I.forceMove(loc)
		new /obj/item/stack/sheet/metal(loc, 2)
	qdel(src)

#undef MAX_TANK_STORAGE
