/datum/status_effect/stacking/wet_stacks
	id = "wet_stacks"
	on_remove_on_mob_delete = TRUE
	tick_interval = 2 SECONDS
	stack_decay = 0.1
	/// Tracks how many stacks of wet we have on, max is usually 20
	var/wet_stacks = 0
	/// Holder of wet effect particles
	var/obj/effect/abstract/particle_holder/wet_effect

/datum/status_effect/stacking/wet_stacks/Destroy()
	if(wet_effect)
		QDEL_NULL(wet_effect)
	. = ..()

/datum/status_effect/stacking/wet_stacks/proc/update_wet()
	if(wet_stacks > 0)
		if(wet_effect)
			return
		wet_effect = new(owner, /particles/droplets)
	else
		qdel(wet_effect)
		wet_effect = null

/datum/status_effect/stacking/wet_stacks/proc/combine_wet_and_fire()
	var/buf_stacks = wet_stacks
	wet_stacks = clamp(buf_stacks - owner.fire_stacks, 0, 20)
	owner.fire_stacks = clamp(owner.fire_stacks - buf_stacks, 0, 20)

/datum/status_effect/stacking/wet_stacks/proc/WetMob()
	if(!HAS_TRAIT(owner, TRAIT_WET_IMMUNITY) && wet_stacks > 0)
		owner.AddComponent(/datum/component/slippery, 5 SECONDS)
		update_wet()
		SEND_SIGNAL(owner, COMSIG_LIVING_WET)
		return TRUE
	return FALSE


/datum/status_effect/stacking/wet_stacks/add_stacks(stacks_added) //Adjusting the amount of fire_stacks we have on person
	if(HAS_TRAIT(owner, TRAIT_WET_IMMUNITY))
		return
	SEND_SIGNAL(owner, COMSIG_MOB_ADJUST_WET)
	wet_stacks = clamp(wet_stacks + stacks_added, -20, 20)
	if(owner.fire_stacks)
		combine_wet_and_fire()
	if(wet_stacks <= 0)
		DryMob()
	else
		WetMob()


/datum/status_effect/stacking/wet_stacks/proc/DryMob()
	if(wet_stacks > 0)
		qdel(owner.GetComponent(/datum/component/slippery))
		wet_stacks = 0
		update_wet()

/datum/status_effect/stacking/wet_stacks/stack_decay_effect()
	. = ..()
	if(wet_stacks <= 0)
		DryMob()
		qdel(src)
		return FALSE
	SEND_SIGNAL(owner, COMSIG_LIVING_WET_TICK)
	return TRUE
