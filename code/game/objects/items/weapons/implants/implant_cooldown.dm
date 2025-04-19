/datum/implant_cooldown
	/// The world.time the implant will be available again.
	var/recharge_time = 0
	/// The amount of time that must pass before a implant can be used again.
	var/recharge_duration = 10 SECONDS
	/// Active timer id
	var/timer_id
	/// Holds a ref to the implant.
	var/obj/item/implant/implant_parent

/datum/implant_cooldown/Destroy()
	if(timer_id)
		deltimer(timer_id)
	implant_parent = null
	return ..()

/datum/implant_cooldown/proc/cooldown_init(obj/item/implant/new_implant)
	implant_parent = new_implant

/datum/implant_cooldown/proc/start_recharge(recharge_duration_override = 0)
	if(timer_id)
		deltimer(timer_id)

	var/duration = recharge_duration_override || recharge_duration
	recharge_time = world.time + duration
	timer_id = addtimer(CALLBACK(src, PROC_REF(end_recharge)), duration, TIMER_STOPPABLE)

/datum/implant_cooldown/proc/end_recharge()
	timer_id = null
	if(implant_parent?.action)
		implant_parent.action.UpdateButtonIcon()

/datum/implant_cooldown/proc/is_on_cooldown()
	return recharge_time > world.time

/datum/implant_cooldown/proc/should_draw_cooldown()
	return is_on_cooldown()

/datum/implant_cooldown/proc/get_cooldown_alpha()
	return 60

/datum/implant_cooldown/proc/cooldown_info()
	return null

/datum/implant_cooldown/charges
	/// The max number of charges a implant can have.
	var/max_charges = 2
	/// The number of charges we currently have.
	var/current_charges = 0
	/// The cooldown between uses of charges.
	var/charge_duration = 1 SECONDS
	/// The time at which a implant charge can be used.
	var/charge_time
	var/charge_timer_id

/datum/implant_cooldown/charges/Destroy()
	if(charge_timer_id)
		deltimer(charge_timer_id)
	return ..()

/datum/implant_cooldown/charges/cooldown_init(obj/item/implant/new_implant)
	..()
	current_charges = max_charges

/datum/implant_cooldown/charges/start_recharge(recharge_duration_override = 0)
	if(current_charges <= 0)
		return

	current_charges--

	charge_time = world.time + charge_duration
	if(charge_timer_id)
		deltimer(charge_timer_id)
	charge_timer_id = addtimer(CALLBACK(src, PROC_REF(charge_ready)), charge_duration, TIMER_STOPPABLE)

	if(current_charges < max_charges && !timer_id)
		var/duration = recharge_duration_override || recharge_duration
		recharge_time = world.time + duration
		timer_id = addtimer(CALLBACK(src, PROC_REF(end_recharge)), duration, TIMER_STOPPABLE)

/datum/implant_cooldown/charges/proc/charge_ready()
	charge_time = 0
	charge_timer_id = null
	if(implant_parent?.action)
		implant_parent.action.UpdateButtonIcon()

/datum/implant_cooldown/charges/end_recharge()
	current_charges++

	if(implant_parent?.imp_in)
		implant_parent.imp_in.balloon_alert(implant_parent.imp_in, "+1 заряд")

	if(current_charges < max_charges)
		recharge_time = world.time + recharge_duration
		timer_id = addtimer(CALLBACK(src, PROC_REF(end_recharge)), recharge_duration, TIMER_STOPPABLE)
	else
		timer_id = null

	if(implant_parent?.action)
		implant_parent.action.UpdateButtonIcon()

/datum/implant_cooldown/charges/is_on_cooldown()
	return charge_time > world.time

/datum/implant_cooldown/charges/should_draw_cooldown()
	return current_charges < max_charges || charge_time > world.time

/datum/implant_cooldown/charges/get_cooldown_alpha()
	if(current_charges == 0 || charge_time > world.time)
		return 60
	return 255

/datum/implant_cooldown/charges/cooldown_info()
	return "[current_charges]/[max_charges]"
