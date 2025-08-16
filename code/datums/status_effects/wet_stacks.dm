/datum/status_effect/stacking/wet
	id = "wet_stacks"
	on_remove_on_mob_delete = TRUE
	tick_interval = 2 SECONDS
	stack_decay = 0.1
	/// Holder of wet effect particles
	var/obj/effect/abstract/particle_holder/wet_effect

/datum/status_effect/stacking/wet/Destroy()
	if(wet_effect)
		QDEL_NULL(wet_effect)
	. = ..()

/datum/status_effect/stacking/wet/proc/update_wet()
	if(stacks > 0)
		if(wet_effect)
			return
		wet_effect = new(owner, /particles/droplets)
	else
		qdel(wet_effect)
		wet_effect = null

/datum/status_effect/stacking/wet/proc/combine_wet_and_fire()
	var/buf_stacks = stacks
	stacks = clamp(buf_stacks - owner.fire_stacks, 0, 20)
	owner.fire_stacks = clamp(owner.fire_stacks - buf_stacks, 0, 20)

/datum/status_effect/stacking/wet/proc/WetMob()
	if(!HAS_TRAIT(owner, TRAIT_WET_IMMUNITY) && stacks > 0)
		owner.AddComponent(/datum/component/slippery, 5 SECONDS)
		update_wet()
		SEND_SIGNAL(owner, COMSIG_LIVING_WET)
		return TRUE
	return FALSE


/datum/status_effect/stacking/wet/add_stacks(stacks_added) //Adjusting the amount of fire_stacks we have on person
	if(HAS_TRAIT(owner, TRAIT_WET_IMMUNITY))
		return
	SEND_SIGNAL(owner, COMSIG_MOB_ADJUST_WET)
	stacks = clamp(stacks + stacks_added, -20, 20)
	if(owner.fire_stacks)
		combine_wet_and_fire()
	if(stacks <= 0)
		DryMob()
	else
		WetMob()


/datum/status_effect/stacking/wet/proc/DryMob()
	var/slippery = owner.GetComponent(/datum/component/slippery)
	if(slippery)
		qdel(slippery)
	stacks = 0
	update_wet()

/datum/status_effect/stacking/wet/stack_decay_effect()
	. = ..()
	if(stacks <= 0)
		DryMob()
		qdel(src)
		return FALSE
	SEND_SIGNAL(owner, COMSIG_LIVING_WET_TICK)
	return TRUE
