/obj/machinery/door/unpowered
	explosion_block = 1


/obj/machinery/door/unpowered/Bumped(atom/movable/moving_atom, skip_effects = TRUE)	// different arg
	. = ..()


/obj/machinery/door/unpowered/attackby(obj/item/I, mob/user, params)
	if(locked)
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()


/obj/machinery/door/unpowered/emag_act()
	return
