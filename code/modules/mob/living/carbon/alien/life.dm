/mob/living/carbon/alien/Life(seconds, times_fired)
	. = ..()
	if(. && can_evolve && evolution_points < max_evolution_points)
		var/points_to_add = 1
		if(locate(/obj/structure/alien/weeds) in loc)
			points_to_add *= 2
		if(body_position == LYING_DOWN)
			points_to_add *= 2
		evolution_points = min(evolution_points + points_to_add, max_evolution_points)


/mob/living/carbon/alien/check_breath(datum/gas_mixture/breath)
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		return

	if(!breath || (breath.total_moles() == 0))
		//Aliens breathe in vaccuum
		return FALSE

	var/toxins_used = 0
	var/tox_detect_threshold = 0.02
	var/breath_pressure = (breath.total_moles() * R_IDEAL_GAS_EQUATION * breath.temperature) / BREATH_VOLUME

	//Partial pressure of the toxins in our breath
	var/Toxins_pp = (breath.toxins / breath.total_moles()) * breath_pressure

	if(Toxins_pp > tox_detect_threshold) // Detect toxins in air
		adjust_alien_plasma(breath.toxins*250)
		throw_alert("alien_tox", /atom/movable/screen/alert/alien_tox)

		toxins_used = breath.toxins

	else
		clear_alert("alien_tox")

	//Breathe in toxins and out oxygen
	breath.toxins -= toxins_used
	breath.oxygen += toxins_used

	//BREATH TEMPERATURE
	handle_breath_temperature(breath)


/mob/living/carbon/alien/handle_status_effects()
	..()
	//natural reduction of movement delay due to stun.
	if(move_delay_add > 0)
		move_delay_add = max(0, move_delay_add - rand(1, 2))
		if(move_delay_add > 0)
			add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/alien_stun_delay, multiplicative_slowdown = move_delay_add)
		else
			remove_movespeed_modifier(/datum/movespeed_modifier/alien_stun_delay)


/mob/living/carbon/alien/handle_fire()//Aliens on fire code
	. = ..()
	if(!.) //if the mob isn't on fire anymore
		return
	adjust_bodytemperature(BODYTEMP_HEATING_MAX) //If you're on fire, you heat up!

/mob/living/carbon/alien/handle_stomach(times_fired)
	for(var/thing in stomach_contents)
		var/mob/living/M = thing
		if(M.loc != src)
			LAZYREMOVE(stomach_contents, M)
			continue
		if(stat != DEAD)
			M.SetWeakened(4 SECONDS)
			M.SetEyeBlind(4 SECONDS)
			M.adjustBruteLoss(1.5)
