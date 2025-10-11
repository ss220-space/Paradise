/datum/spell_cooldown/charges
	/// The max number of charges a spell can have.
	var/max_charges = 2
	/// The number of charges we currently have.
	var/current_charges = 0
	/// The cooldown between uses of charges.
	var/charge_duration = 1 SECONDS
	/// The time at which a spell charge can be used.
	var/charge_time


/datum/spell_cooldown/charges/cooldown_init(obj/effect/proc_holder/spell/new_spell)
	. = ..()
	if(starts_off_cooldown)
		current_charges = max_charges


/datum/spell_cooldown/charges/get_cooldown_alpha()
	if(current_charges == 0 || charge_time > world.time)
		return 220 - 140 * get_availability_percentage()
	return 60


/datum/spell_cooldown/charges/should_draw_cooldown()
	return recharge_time > world.time || current_charges < max_charges


/datum/spell_cooldown/charges/is_on_cooldown()
	return !current_charges || charge_time >= world.time


/datum/spell_cooldown/charges/should_end_cooldown()
	if(recharge_time > world.time)
		return FALSE
	current_charges++
	spell_parent.action.UpdateButtonIcon()
	if(current_charges < max_charges) // we have more recharges to go
		recharge_time = world.time + recharge_duration
		return FALSE
	return TRUE


/**
 * Use this to change cooldown stats of the spell
 *
 * Arguments:
 * * recharge_reduction - Amount of cooldown duration reduction in seconds
 * * delay_reduction - Amount of delay duration reduction between spell uses in seconds
 * * new_max_charges - New amount of spell max charges
 */
/datum/spell_cooldown/charges/change_cooldowns(recharge_reduction, delay_reduction, new_max_charges)
	..()
	if(delay_reduction)
		charge_duration = clamp(charge_duration - (charge_duration * delay_reduction), 0, initial(charge_duration))
	if(new_max_charges)
		handle_max_charges_changed(max_charges, new_max_charges)
		max_charges = max(new_max_charges, 1)
	spell_parent.action.UpdateButtonIcon()


/datum/spell_cooldown/charges/start_recharge(recharge_override = 0)
	current_charges--
	if(current_charges)
		charge_time = world.time + charge_duration
	..()


/datum/spell_cooldown/charges/get_recharge_time()
	if(recharge_time > world.time)
		return recharge_time
	return ..()


/datum/spell_cooldown/charges/revert_cast()
	..()
	charge_time = world.time


/datum/spell_cooldown/charges/cooldown_info()
	var/charge_string = charge_duration != 0 ? round(min(1, (charge_duration - (charge_time - world.time)) / charge_duration), 0.01) * 100 : 100 // need this for possible 0 charge duration
	var/recharge_string = recharge_duration != 0 ? round(min(1, (recharge_duration - (recharge_time - world.time)) / recharge_duration), 0.01) * 100 : 100
	return "[charge_string != 100 ? "[charge_string]%\n" : ""][recharge_string != 100 ? "[recharge_string]%\n" : ""][current_charges != max_charges ? "[current_charges]/[max_charges]" : ""]"


/datum/spell_cooldown/charges/get_availability_percentage()
	if(max_charges == current_charges)
		return TRUE

	if(charge_time > world.time)
		return min(1, (charge_duration - (charge_time - world.time)) / charge_duration)
	return min(1, (recharge_duration - (recharge_time - world.time)) / recharge_duration) //parent proc without the on cooldown check


/datum/spell_cooldown/charges/proc/handle_max_charges_changed(old_max_charges, new_max_charges)
	// We cut current charges so they don't exceed max charges: (3/3 -> 3/2) will be (3/3 -> 2/2)
	if(current_charges > new_max_charges)
		current_charges = new_max_charges

	// No charges were on cooldown, so we simply add new charges
	if(recharge_time < world.time)
		if(old_max_charges < new_max_charges)
			current_charges = new_max_charges
		return

	// Charge was on cooldown and new max is lower than old. This is bad: (3/4 + recharging -> 2/2 + recharging -> 3/2)
	if(current_charges && (old_max_charges > new_max_charges))
		current_charges--
		START_PROCESSING(SSfastprocess, src)

