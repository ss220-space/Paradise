/obj/effect/cursed_floor
	icon = 'icons/effects/revenant.dmi'
	icon_state = "cursed_floor"
	var/lifetime = 30 SECONDS
	var/owner

/obj/effect/cursed_floor/New(loc, mob/living/simple_animal/revenant/rev_owner)
	. = ..()
	if(!isturf(loc))
		qdel(src)
	var/turf/turf_loc = loc
	turf_loc.slowdown = 0.25
	set_light(5, null, LIGHT_COLOR_LAVENDER, l_on = TRUE)
	if(rev_owner)
		owner = rev_owner
	START_PROCESSING(SSprocessing, src)
	QDEL_IN(src, 30 SECONDS)

/obj/effect/cursed_floor/Destroy(force)
	var/turf/turf_loc = loc
	turf_loc.slowdown = 0
	STOP_PROCESSING(SSprocessing, src)
	. = ..()

/obj/effect/cursed_floor/process(seconds_per_tick)
	for(var/mob/living/carbon/human in loc.contents)
		if(prob(7))
			human.apply_status_effect(/datum/status_effect/cursed_flame, 5 SECONDS, owner)
		if(human.getStaminaLoss() < 100)
			human.adjustStaminaLoss(7)
