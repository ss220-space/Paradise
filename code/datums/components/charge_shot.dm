/datum/component/charge_shot
	var/charge_started = 0
	var/stage_time = 1 SECONDS
	var/full_time = 2 SECONDS
	var/window_time = 3 SECONDS
	var/first_multiplier = 1 / 3
	var/second_multiplier = 2 / 3
	var/datum/cogbar/charge_cogbar
	var/list/charge_timers

/datum/component/charge_shot/Initialize(...)
	. = ..()
	if(!isgun(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(on_gun_dropped))
	RegisterSignal(parent, COMSIG_QDELETING, PROC_REF(on_gun_deleted))

/datum/component/charge_shot/Destroy()
	charge_started = 0
	stop_charge_feedback()
	if(length(charge_timers))
		for(var/timer_id in charge_timers)
			deltimer(timer_id)
		charge_timers = null
	return ..()

/datum/component/charge_shot/proc/handle_click()
	if(charge_started)
		release_charge()
		return FALSE
	return start_charge()

/datum/component/charge_shot/proc/start_charge()
	var/obj/item/gun/gun = parent
	var/mob/living/user = gun.gun_user
	if(!user)
		return FALSE

	charge_started = world.time
	gun.damage_mod = initial(gun.damage_mod)
	gun.stamina_mod = initial(gun.stamina_mod)
	if(gun.windup_sound)
		playsound(gun.loc, gun.windup_sound, 30, TRUE)
	user.balloon_alert(user, "зарядка...")
	charge_cogbar = new /datum/cogbar(user, 'icons/effects/progressbar.dmi', "busy_danger")

	var/charge_id = charge_started
	charge_timers = list(
		addtimer(CALLBACK(src, PROC_REF(charge_reached_full), charge_id), full_time),
		addtimer(CALLBACK(src, PROC_REF(charge_window_ended), charge_id), full_time + window_time),
	)
	return TRUE

/datum/component/charge_shot/proc/release_charge()
	var/obj/item/gun/gun = parent
	var/multiplier = get_charge_multiplier()
	gun.damage_mod = initial(gun.damage_mod) * multiplier
	gun.stamina_mod = initial(gun.stamina_mod) * multiplier
	charge_started = 0
	stop_charge_feedback()

/datum/component/charge_shot/proc/get_charge_multiplier()
	var/charged_for = world.time - charge_started
	if(charged_for < stage_time)
		return first_multiplier
	if(charged_for < full_time)
		return second_multiplier
	return 1

/datum/component/charge_shot/proc/charge_reached_full(expected_charge_id)
	if(charge_started != expected_charge_id)
		return
	var/obj/item/gun/gun = parent
	var/mob/living/user = gun.gun_user
	if(!user?.is_in_hands(gun))
		cancel_charge()
		return
	user.balloon_alert(user, "заряжено")

/datum/component/charge_shot/proc/charge_window_ended(expected_charge_id)
	if(charge_started != expected_charge_id)
		return
	var/obj/item/gun/gun = parent
	playsound(gun.loc, 'sound/machines/ding.ogg', 30, TRUE)
	cancel_charge()

/datum/component/charge_shot/proc/cancel_charge()
	if(!charge_started)
		return
	charge_started = 0
	var/obj/item/gun/gun = parent
	gun.last_fired = world.time
	stop_charge_feedback()

/datum/component/charge_shot/proc/on_gun_dropped(datum/source, mob/user, slot)
	SIGNAL_HANDLER
	cancel_charge()

/datum/component/charge_shot/proc/on_gun_deleted(datum/source)
	SIGNAL_HANDLER
	charge_started = 0
	stop_charge_feedback()

/datum/component/charge_shot/proc/stop_charge_feedback()
	var/datum/cogbar/indicator = charge_cogbar
	charge_cogbar = null
	indicator?.remove()

/obj/item/gun/energy/do_semiauto_fire()
	var/datum/component/charge_shot/charge = GetComponent(/datum/component/charge_shot)
	if(charge?.handle_click())
		return
	return ..()
