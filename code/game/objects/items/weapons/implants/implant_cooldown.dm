/datum/implant_cooldown
	/// The world.time the implant will be available again.
	var/recharge_time = 0
	/// The amount of time that must pass before a implant can be used again.
	var/recharge_duration = 10 SECONDS // default implant cooldown.
	/// Does it start off cooldown?
	var/starts_off_cooldown = TRUE
	/// Holds a ref to the implant.
	var/obj/item/implant/implant_parent

/datum/implant_cooldown/Destroy()
	implant_parent = null
	return ..()

/datum/implant_cooldown/proc/cooldown_init(obj/item/implant/new_implant)
	implant_parent = new_implant
	if(!starts_off_cooldown)
		start_recharge()

/datum/implant_cooldown/proc/should_draw_cooldown()
	return is_on_cooldown()

/datum/implant_cooldown/proc/get_cooldown_alpha()
	return 220 - 140 * get_availability_percentage()

/datum/implant_cooldown/proc/is_on_cooldown()
	return recharge_time > world.time

/datum/implant_cooldown/proc/should_end_cooldown()
	return !is_on_cooldown()

/datum/implant_cooldown/proc/end_recharge()
	return

/datum/implant_cooldown/process()
	implant_parent.action.UpdateButtonIcon()
	if(should_end_cooldown())
		end_recharge()
		return PROCESS_KILL

/*
 * used to track how long is left on the implant cooldown
 * finds them time left, before we can cast (recharge_time - world.time)
 * then subtracts that from the total time.
 * then divides it by the total time.
*/
/datum/implant_cooldown/proc/get_availability_percentage()
	if(!is_on_cooldown()) // if off cooldown, we don't bother with the maths
		return TRUE

	return min(1, (recharge_duration - (recharge_time - world.time)) / recharge_duration)

/datum/implant_cooldown/proc/get_recharge_time()
	return world.time + recharge_duration

/datum/implant_cooldown/proc/start_recharge(recharge_duration_override = 0)
	if(recharge_duration_override)
		recharge_time = world.time + recharge_duration_override
	else
		recharge_time = get_recharge_time()
		START_PROCESSING(SSfastprocess, src)

/datum/implant_cooldown/proc/cooldown_info()
	var/dat = round(get_availability_percentage(), 0.01) * 100
	return dat != 100 ? "[dat]%" : null

/datum/implant_cooldown/charges
	/// The max number of charges a implant can have.
	var/max_charges = 2
	/// The number of charges we currently have.
	var/current_charges = 0
	/// The cooldown between uses of charges.
	var/charge_duration = 1 SECONDS
	/// The time at which a implant charge can be used.
	var/charge_time

/datum/implant_cooldown/charges/cooldown_init(obj/item/implant/new_implant)
	. = ..()
	if(starts_off_cooldown)
		current_charges = max_charges

/datum/implant_cooldown/charges/get_cooldown_alpha()
	if(current_charges == 0 || charge_time > world.time)
		return 220 - 140 * get_availability_percentage()
	return 60

/datum/implant_cooldown/charges/should_draw_cooldown()
	return recharge_time > world.time || current_charges < max_charges

/datum/implant_cooldown/charges/is_on_cooldown()
	return !current_charges || charge_time >= world.time

/datum/implant_cooldown/charges/should_end_cooldown()
	if(recharge_time > world.time)
		return FALSE
	current_charges++
	implant_parent.imp_in.balloon_alert(implant_parent.imp_in, ("+1 заряд"))
	if(current_charges < max_charges) // we have more recharges to go
		recharge_time = world.time + recharge_duration
		return FALSE
	return TRUE

/datum/implant_cooldown/charges/start_recharge(recharge_override = 0)
	current_charges--
	if(current_charges)
		charge_time = world.time + charge_duration
		implant_parent.action.UpdateButtonIcon()
	..()

/datum/implant_cooldown/charges/get_recharge_time()
	if(recharge_time > world.time)
		return recharge_time
	return ..()

/datum/implant_cooldown/charges/get_availability_percentage()
	if(max_charges == current_charges)
		return TRUE

	if(charge_time > world.time)
		return min(1, (charge_duration - (charge_time - world.time)) / charge_duration)
	return min(1, (recharge_duration - (recharge_time - world.time)) / recharge_duration) //parent proc without the on cooldown check

/datum/implant_cooldown/charges/cooldown_info()
	var/charge_string = charge_duration != 0 ? round(min(1, (charge_duration - (charge_time - world.time)) / charge_duration), 0.01) * 100 : 100 // need this for possible 0 charge duration
	var/recharge_string = recharge_duration != 0 ? round(min(1, (recharge_duration - (recharge_time - world.time)) / recharge_duration), 0.01) * 100 : 100
	return "[charge_string != 100 ? "[charge_string]%\n" : ""][recharge_string != 100 ? "[recharge_string]%\n" : ""][current_charges != max_charges ? "[current_charges]/[max_charges]" : ""]"

