/////////////////////////////////////////////
//// SMOKE SYSTEMS
// direct can be optionally added when set_up, to make the smoke always travel in one direction
// in case you wanted a vent to always smoke north for example
/////////////////////////////////////////////

/obj/effect/particle_effect/smoke
	name = "smoke"
	icon_state = "smoke"
	icon = 'icons/effects/96x96.dmi'
	pixel_x = -32
	pixel_y = -32
	opacity = TRUE
	anchored = FALSE
	var/steps = 0
	var/lifetime = 5
	var/direction


/obj/effect/particle_effect/smoke/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)
	lifetime += rand(-1,1)
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)


/obj/effect/particle_effect/smoke/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()


/obj/effect/particle_effect/smoke/proc/fade_out(frames = 16)
	if(alpha == 0) //Handle already transparent case
		return
	if(frames == 0)
		frames = 1 //We will just assume that by 0 frames, the coder meant "during one frame".
	var/step = alpha / frames
	for(var/i = 0, i < frames, i++)
		alpha -= step
		if(alpha < 160)
			set_opacity(FALSE)
		stoplag()


/obj/effect/particle_effect/smoke/proc/kill_smoke()
	STOP_PROCESSING(SSobj, src)
	INVOKE_ASYNC(src, PROC_REF(fade_out))
	QDEL_IN(src, 10)


/obj/effect/particle_effect/smoke/process()
	lifetime--
	if(lifetime < 1)
		kill_smoke()
		return 0
	if(steps >= 1)
		step(src,direction)
		steps--
	return 1


/obj/effect/particle_effect/smoke/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	smoke_mob(arrived)


/obj/effect/particle_effect/smoke/proc/smoke_mob(mob/living/carbon/victim)
	if(!istype(victim))
		return FALSE
	if(lifetime < 1)
		return FALSE
	if(!victim.can_breathe_gas())
		return FALSE
	if(victim.smoke_delay)
		return FALSE
	victim.smoke_delay++
	addtimer(CALLBACK(src, PROC_REF(remove_smoke_delay), victim), 1 SECONDS)
	return TRUE


/obj/effect/particle_effect/smoke/proc/remove_smoke_delay(mob/living/carbon/victim)
	victim?.smoke_delay = 0


/datum/effect_system/smoke_spread
	effect_type = /obj/effect/particle_effect/smoke
	var/direction
	var/color
	var/custom_lifetime

/datum/effect_system/smoke_spread/set_up(n = 5, c = 0, loca, direct)
	if(n > 20)
		n = 20
	number = n
	cardinals = c
	if(isturf(loca))
		location = loca
	else
		location = get_turf(loca)
	if(direct)
		direction = direct

/datum/effect_system/smoke_spread/start()
	for(var/i=0, i<number, i++)
		if(holder)
			location = get_turf(holder)
		var/obj/effect/particle_effect/smoke/S = new effect_type(location)
		if(custom_lifetime)
			S.lifetime = rand(custom_lifetime-3, custom_lifetime)
		if(color)
			S.color = color
		if(!direction)
			if(cardinals)
				S.direction = pick(GLOB.cardinal)
			else
				S.direction = pick(GLOB.alldirs)
		else
			S.direction = direction
		S.steps = pick(0,1,1,1,2,2,2,3)
		S.process()

/////////////////////////////////////////////
// Bad smoke
/////////////////////////////////////////////

/obj/effect/particle_effect/smoke/bad
	lifetime = 8

/obj/effect/particle_effect/smoke/bad/process()
	if(..())
		for(var/mob/living/carbon/M in range(1,src))
			smoke_mob(M)


/obj/effect/particle_effect/smoke/bad/smoke_mob(mob/living/carbon/victim)
	. = ..()
	if(!.)
		return .
	victim.drop_from_active_hand()
	victim.adjustOxyLoss(1)
	INVOKE_ASYNC(victim, TYPE_PROC_REF(/mob, emote), "cough")


/obj/effect/particle_effect/smoke/bad/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(istype(mover, /obj/item/projectile/beam))
		var/obj/item/projectile/beam/beam = mover
		beam.damage = (beam.damage / 2)


/datum/effect_system/smoke_spread/bad
	effect_type = /obj/effect/particle_effect/smoke/bad

/////////////////////////////////////////////
// Nanofrost smoke
/////////////////////////////////////////////

/obj/effect/particle_effect/smoke/freezing
	name = "nanofrost smoke"
	color = "#B2FFFF"
	opacity = FALSE

/datum/effect_system/smoke_spread/freezing
	effect_type = /obj/effect/particle_effect/smoke/freezing
	var/blast = 0

/datum/effect_system/smoke_spread/freezing/proc/Chilled(atom/A)
	if(issimulatedturf(A))
		var/turf/simulated/T = A
		if(!T.blocks_air)
			var/datum/milla_safe/smoke_spread_chill/milla = new()
			milla.invoke_async(src, T)
		for(var/obj/machinery/atmospherics/unary/vent_pump/V in T)
			if(!isnull(V.welded) && !V.welded) //must be an unwelded vent pump.
				V.welded = TRUE
				V.update_icon()
				V.visible_message("<span class='danger'>[V] was frozen shut!</span>")
		for(var/obj/machinery/atmospherics/unary/vent_scrubber/U in T)
			if(!isnull(U.welded) && !U.welded) //must be an unwelded vent scrubber.
				U.welded = TRUE
				U.update_icon()
				U.visible_message("<span class='danger'>[U] was frozen shut!</span>")
		for(var/mob/living/L in T)
			L.ExtinguishMob()
		for(var/obj/item/Item in T)
			Item.extinguish()

/datum/milla_safe/smoke_spread_chill

/datum/milla_safe/smoke_spread_chill/on_run(datum/effect_system/smoke_spread/smoke, turf/T)
	var/datum/gas_mixture/env = get_turf_air(T)
	if(get_dist(T, smoke) < 2) // Otherwise we'll get silliness like people using Nanofrost to kill people through walls with cold air
		env.set_temperature(2)
	for(var/obj/effect/hotspot/H in T)
		qdel(H)
		if(env.toxins())
			env.set_nitrogen(env.nitrogen() + env.toxins())
			env.set_toxins(0)

/datum/effect_system/smoke_spread/freezing/set_up(amount = 5, only_cardinals = FALSE, source, desired_direction, datum/reagents/chemicals, blasting = FALSE)
	..()
	blast = blasting

/datum/effect_system/smoke_spread/freezing/start()
	if(blast)
		for(var/turf/T in RANGE_TURFS(2, location))
			Chilled(T)
	..()

/////////////////////////////////////////////
// Sleep smoke
/////////////////////////////////////////////

/obj/effect/particle_effect/smoke/sleeping
	color = "#9C3636"
	lifetime = 10

/obj/effect/particle_effect/smoke/sleeping/process()
	if(..())
		for(var/mob/living/carbon/M in range(1,src))
			smoke_mob(M)


/obj/effect/particle_effect/smoke/sleeping/smoke_mob(mob/living/carbon/victim)
	. = ..()
	if(!.)
		return .
	victim.drop_from_active_hand()
	victim.Sleeping(20 SECONDS)
	INVOKE_ASYNC(victim, TYPE_PROC_REF(/mob, emote), "cough")


/datum/effect_system/smoke_spread/sleeping
	effect_type = /obj/effect/particle_effect/smoke/sleeping
