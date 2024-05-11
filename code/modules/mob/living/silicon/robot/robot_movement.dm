/mob/living/silicon/robot/Process_Spacemove(movement_dir = NONE)
	if(ionpulse())
		return TRUE
	return ..()


/mob/living/silicon/robot/experience_pressure_difference(pressure_difference, direction)
	if(!HAS_TRAIT(src, TRAIT_NEGATES_GRAVITY))
		return ..()

/mob/living/silicon/robot/get_pull_push_speed_modifier(current_delay)
	if(canmove)
		for(var/obj/item/borg/upgrade/u in upgrades)
			if(istype(u, /obj/item/borg/upgrade/vtec/))
				return pull_push_speed_modifier
	return pull_push_speed_modifier * 1.2
