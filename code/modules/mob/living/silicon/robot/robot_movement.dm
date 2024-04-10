/mob/living/silicon/robot/Process_Spacemove(var/movement_dir = 0)
	if(ionpulse())
		return 1
	if(..())
		return 1
	return 0


/mob/living/silicon/robot/mob_negates_gravity()
	return magpulse


/mob/living/silicon/robot/experience_pressure_difference(pressure_difference, direction)
	if(!magpulse)
		return ..()

/mob/living/silicon/robot/get_pull_push_speed_modifier(current_delay)
	if(canmove)
		for(var/obj/item/borg/upgrade/u in upgrades)
			if(istype(u, /obj/item/borg/upgrade/vtec/))
				return pull_push_speed_modifier
	return pull_push_speed_modifier * 1.2
