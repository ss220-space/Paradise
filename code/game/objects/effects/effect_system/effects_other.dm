/////////////////////////////////////////////
//////// Attach a trail to any object, that spawns when it moves (like for the jetpack)
/// just pass in the object to attach it to in set_up
/// Then do start() to start it and stop() to stop it, obviously
/// and don't call start() in a loop that will be repeated otherwise it'll get spammed!
/////////////////////////////////////////////

/datum/effect_system/trail_follow
	var/turf/oldposition
	var/active = FALSE
	var/allow_overlap = FALSE
	var/auto_process = TRUE
	var/qdel_in_time = 1 SECONDS
	var/fadetype = "ion_fade"
	var/fade = TRUE
	var/nograv_required = FALSE


/datum/effect_system/trail_follow/set_up(atom/atom)
	attach(atom)
	oldposition = get_turf(atom)


/datum/effect_system/trail_follow/Destroy()
	oldposition = null
	stop()
	return ..()


/datum/effect_system/trail_follow/proc/stop()
	oldposition = null
	STOP_PROCESSING(SSfastprocess, src)
	active = FALSE
	return TRUE


/datum/effect_system/trail_follow/start()
	oldposition = get_turf(holder)
	if(!check_conditions())
		return FALSE
	if(auto_process)
		START_PROCESSING(SSfastprocess, src)
	active = TRUE
	return TRUE


/datum/effect_system/trail_follow/process()
	generate_effect()


/datum/effect_system/trail_follow/generate_effect()
	if(!check_conditions())
		return stop()
	if(oldposition && !(oldposition == get_turf(holder)) && (!oldposition.has_gravity() || !nograv_required))
		var/obj/effect/new_effect = new effect_type(oldposition)
		set_dir(new_effect)
		if(fade && fadetype)
			flick(fadetype, new_effect)
			new_effect.icon_state = ""
		if(qdel_in_time)
			QDEL_IN(new_effect, qdel_in_time)
	oldposition = get_turf(holder)


/datum/effect_system/trail_follow/proc/set_dir(obj/effect/particle_effect/ion_trails/trails)
	trails.setDir(holder.dir)


/datum/effect_system/trail_follow/proc/check_conditions()
	if(!get_turf(holder))
		return FALSE
	return TRUE


/datum/effect_system/trail_follow/ion
	effect_type = /obj/effect/particle_effect/ion_trails
	nograv_required = TRUE
	qdel_in_time = 2 SECONDS


/datum/effect_system/trail_follow/ion/grav_allowed
	nograv_required = FALSE


/datum/effect_system/trail_follow/spacepod
	effect_type = /obj/effect/particle_effect/ion_trails
	nograv_required = TRUE
	qdel_in_time = 2 SECONDS


/datum/effect_system/trail_follow/spacepod/set_dir(obj/effect/particle_effect/ion_trails/trails1, obj/effect/particle_effect/ion_trails/trails2)
	trails1.setDir(holder.dir)
	trails2.setDir(holder.dir)


/datum/effect_system/trail_follow/spacepod/generate_effect()
	if(!check_conditions())
		return stop()
	if(oldposition && !(oldposition == get_turf(holder)) && (!oldposition.has_gravity() || !nograv_required))
		// spacepod loc is always southwest corner of 4x4 space
		var/turf/our_turf = holder.loc
		var/loc1
		var/loc2
		switch(holder.dir)
			if(NORTH)
				loc1 = get_step(our_turf, SOUTH)
				loc2 = get_step(loc1, EAST)
			if(SOUTH) // More difficult, offset to the north!
				loc1 = get_step(get_step(our_turf, NORTH), NORTH)
				loc2 = get_step(loc1, EAST)
			if(EAST) // Just one to the north should suffice
				loc1 = get_step(our_turf , WEST)
				loc2 = get_step(loc1, NORTH)
			if(WEST) // One to the east and north from there
				loc1 = get_step(get_step(our_turf, EAST), EAST)
				loc2 = get_step(loc1, NORTH)
		var/obj/effect/effect1 = new effect_type(loc1)
		var/obj/effect/effect2 = new effect_type(loc2)
		set_dir(effect1, effect2)
		if(fade && fadetype)
			flick(fadetype, effect1)
			flick(fadetype, effect2)
			effect1.icon_state = ""
			effect2.icon_state = ""
		if(qdel_in_time)
			QDEL_IN(effect1, qdel_in_time)
			QDEL_IN(effect2, qdel_in_time)
	oldposition = get_turf(holder)


/obj/effect/particle_effect/ion_trails
	name = "ion trails"
	icon_state = "ion_trails"


/obj/effect/particle_effect/ion_trails/flight
	icon_state = "ion_trails_flight"


//Reagent-based explosion effect
/datum/effect_system/reagents_explosion
	var/amount 						// TNT equivalent
	var/flashing = 0			// does explosion creates flash effect?
	var/flashing_factor = 0		// factor of how powerful the flash effect relatively to the explosion

/datum/effect_system/reagents_explosion/set_up(amt, loca, flash = 0, flash_fact = 0)
	amount = amt
	if(isturf(loca))
		location = loca
	else
		location = get_turf(loca)

	flashing = flash
	flashing_factor = flash_fact


/datum/effect_system/reagents_explosion/start()
	if(amount <= 2)
		do_sparks(2, 1, location)

		for(var/mob/M in viewers(5, location))
			to_chat(M, "<span class='warning'>The solution violently explodes.</span>")
		for(var/mob/living/L in viewers(1, location))
			if(prob(50 * amount))
				to_chat(L, "<span class='warning'>The explosion pushes you.</span>")
				goonchem_vortex_weak(location, 0, amount)
		return
	else
		var/devastation = -1
		var/heavy = -1
		var/light = -1
		var/flash = -1

		// Clamp all values to MAX_EXPLOSION_RANGE
		if(round(amount/12) > 0)
			devastation = min (GLOB.max_ex_devastation_range, devastation + round(amount/12))

		if(round(amount/6) > 0)
			heavy = min (GLOB.max_ex_heavy_range, heavy + round(amount/6))

		if(round(amount/3) > 0)
			light = min (GLOB.max_ex_light_range, light + round(amount/3))

		if(flashing && flashing_factor)
			flash += (round(amount/4) * flashing_factor)

		for(var/mob/M in viewers(8, location))
			to_chat(M, "<span class='warning'>The solution violently explodes.</span>")

		explosion(location, devastation, heavy, light, flash, cause = "Reagent Explosion")

/datum/effect_system/reagents_explosion/proc/holder_damage(atom/holder)
	if(holder)
		var/dmglevel = 4

		if(round(amount/8) > 0)
			dmglevel = 1
		else if(round(amount/4) > 0)
			dmglevel = 2
		else if(round(amount/2) > 0)
			dmglevel = 3

		if(dmglevel<4)
			holder.ex_act(dmglevel)
