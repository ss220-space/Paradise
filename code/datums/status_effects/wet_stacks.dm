/datum/status_effect/wet_stacks
	id = "wet_stacks"
	alert_type = null
	on_remove_on_mob_delete = TRUE
	tick_interval = 2 SECONDS
	/// The "Are we wet?" var
	var/is_wet = 0
	/// Tracks how many stacks of wet we have on, max is usually 20
	var/wet_stacks = 0
	/// Holder of wet effect particles
	var/obj/effect/abstract/particle_holder/wet_effect

/datum/status_effect/wet_stacks/on_creation(mob/living/new_owner, new_stacks, ...)
	. = ..()
	adjust_wet_stacks(new_stacks)

/datum/status_effect/wet_stacks/Destroy()
	if(wet_effect)
		QDEL_NULL(wet_effect)
	. = ..()

/datum/status_effect/wet_stacks/tick(seconds_between_ticks)
	. = ..()
	handle_wet()

/datum/status_effect/wet_stacks/proc/update_wet()
	if(is_wet)
		if(wet_effect)
			return
		wet_effect = new(owner, /particles/droplets)
	else
		qdel(wet_effect)
		wet_effect = null

/datum/status_effect/wet_stacks/proc/combine_wet_and_fire()
	var/buf_stacks = wet_stacks
	wet_stacks = clamp(buf_stacks - owner.fire_stacks, 0, 20)
	owner.fire_stacks = clamp(owner.fire_stacks - buf_stacks, 0, 20)

/datum/status_effect/wet_stacks/proc/WetMob()
	if(!HAS_TRAIT(owner, TRAIT_WET_IMMUNITY) && wet_stacks > 0 && !is_wet )
		is_wet = TRUE
		owner.AddComponent(/datum/component/slippery, 5 SECONDS)
		update_wet()
		SEND_SIGNAL(owner, COMSIG_LIVING_WET)
		return TRUE
	return FALSE


/datum/status_effect/wet_stacks/proc/adjust_wet_stacks(add_wet_stacks) //Adjusting the amount of fire_stacks we have on person
	if(HAS_TRAIT(owner, TRAIT_WET_IMMUNITY))
		return
	SEND_SIGNAL(owner, COMSIG_MOB_ADJUST_WET)
	wet_stacks = clamp(wet_stacks + add_wet_stacks, -20, 20)
	if(owner.fire_stacks)
		combine_wet_and_fire()
	if(is_wet && wet_stacks <= 0)
		DryMob()
	else
		WetMob()


/datum/status_effect/wet_stacks/proc/DryMob()
	if(is_wet)
		qdel(owner.GetComponent(/datum/component/slippery))
		is_wet = FALSE
		wet_stacks = 0
		update_wet()

/datum/status_effect/wet_stacks/proc/handle_wet()
	if(wet_stacks < 0) //If we've doused ourselves in water to avoid wet, dry off slowly
		wet_stacks = min(0, wet_stacks + 1)//So we dry ourselves back to default, nonflammable.
	if(!is_wet)
		return FALSE
	if(wet_stacks > 0)
		wet_stacks -= 0.1 //the wet is slowly consumed
	else
		DryMob()
		qdel(src)
		return FALSE
	SEND_SIGNAL(owner, COMSIG_LIVING_WET_TICK)
	return TRUE
