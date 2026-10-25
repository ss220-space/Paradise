/**
 * Will cause an EMP on the given epicenter.
 * This proc can sleep depending on the affected objects. So assume it sleeps!
 *
 * epicenter - The center of the EMP. Can be an atom, as long as the given atom is on a turf (in)directly
 * heavy_range - The max distance from the epicenter where objects will be get heavy EMPed
 * light_range - The max distance from the epicenter where objects will get light EMPed
 * log - Whether or not this action should be logged or not. Will use the cause if provided
 * cause - The cause of the EMP. Used for the logging
 * heavy_emp_chance - Chance of a heavy emp happening, if distance to an atom is equal to heavy range
 */
/proc/empulse(turf/epicenter, heavy_range, light_range, log = FALSE, cause = null, heavy_emp_chance = 50)
	if(!epicenter)
		return

	if(!isturf(epicenter))
		epicenter = get_turf(epicenter)

	if(log)
		message_admins("EMP with size ([heavy_range], [light_range]) in area [epicenter.loc.name] [cause ? "(Cause: [cause])": ""] [ADMIN_VERBOSEJMP(epicenter)]")
		add_game_logs("EMP with size ([heavy_range], [light_range]) in area [epicenter.loc.name] [cause ? "(Cause: [cause])" : ""] [COORD(epicenter)]")

	if(heavy_range > 1)
		if(cause == "cult")
			new /obj/effect/temp_visual/emp/pulse/cult(epicenter)
		else if(cause == "clock")
			new /obj/effect/temp_visual/emp/pulse/clock(epicenter)
		else
			new /obj/effect/temp_visual/emp/pulse(epicenter)

	if(heavy_range > light_range)
		light_range = heavy_range

	var/emp_sound = sound('sound/effects/empulse.ogg')
	for(var/mob/M in range(heavy_range, epicenter))
		SEND_SOUND(M, emp_sound)

	for(var/atom/T in range(light_range, epicenter))
		if(cause == "cult" && iscultist(T))
			continue
		if(cause == "clock" && isclocker(T))
			continue

		var/distance = max(0, get_dist(epicenter, T))
		var/will_affect = FALSE
		if(distance < heavy_range)
			will_affect = T.emp_act(EMP_HEAVY)

		else if(distance == heavy_range)
			if(prob(heavy_emp_chance))
				will_affect = T.emp_act(EMP_HEAVY)
			else
				will_affect = T.emp_act(EMP_LIGHT)

		else if(distance <= light_range)
			will_affect = T.emp_act(EMP_LIGHT)

		if(will_affect)
			if(cause == "cult")
				new /obj/effect/temp_visual/emp/cult(T.loc)
			else if(cause == "clock")
				new /obj/effect/temp_visual/emp/clock(T.loc)
			else
				new /obj/effect/temp_visual/emp(T.loc)

	return TRUE
