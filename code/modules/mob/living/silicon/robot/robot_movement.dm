/mob/living/silicon/robot/Process_Spacemove(movement_dir = NONE, continuous_move = FALSE)
	. = ..()
	if(.)
		return TRUE
	if(ionpulse())
		return TRUE
	return FALSE


/mob/living/silicon/robot/experience_pressure_difference(pressure_difference, direction)
	if(!HAS_TRAIT(src, TRAIT_NEGATES_GRAVITY))
		return ..()

/mob/living/silicon/robot/get_pull_push_speed_modifier(current_delay)
	if(mobility_flags & MOBILITY_MOVE)
		for(var/obj/item/borg/upgrade/u in upgrades)
			if(istype(u, /obj/item/borg/upgrade/vtec/))
				return pull_push_speed_modifier
	return pull_push_speed_modifier * 1.2


/mob/living/silicon/robot/on_movement_type_flag_enabled(datum/source, flag, old_movement_type)
	. = ..()
	if(movement_type & (FLYING|FLOATING) && !(old_movement_type & (FLYING|FLOATING)))
		if(locate(/obj/item/borg/upgrade/vtec) in upgrades)
			remove_movespeed_modifier(/datum/movespeed_modifier/robot_vtec_upgrade)
		if(ionpulse_on)
			add_movespeed_modifier(/datum/movespeed_modifier/robot_jetpack_upgrade)


/mob/living/silicon/robot/on_movement_type_flag_disabled(datum/source, flag, old_movement_type)
	. = ..()
	if(old_movement_type & (FLYING|FLOATING) && !(movement_type & (FLYING|FLOATING)))
		if(locate(/obj/item/borg/upgrade/vtec) in upgrades)
			add_movespeed_modifier(/datum/movespeed_modifier/robot_vtec_upgrade)
		if(ionpulse_on)
			remove_movespeed_modifier(/datum/movespeed_modifier/robot_jetpack_upgrade)

