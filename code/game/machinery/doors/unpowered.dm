/obj/machinery/door/unpowered
	explosion_block = 1
	obj_flags = parent_type::obj_flags|NO_EMAG

/obj/machinery/door/unpowered/Bumped(atom/movable/moving_atom, skip_effects = TRUE)	// different arg
	. = ..()

/obj/machinery/door/unpowered/attackby(obj/item/I, mob/user, params)
	if(locked)
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()
