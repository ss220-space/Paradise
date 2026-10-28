/// Fake grenade hallucination: a grenade is thrown near the target from offscreen.
/datum/hallucination/fake_grenade
	random_hallucination_weight = 2
	hallucination_tier = HALLUCINATION_TIER_RARE
	var/list/grenade_type = list(
		/obj/item/grenade/chem_grenade,
		/obj/item/grenade/clusterbuster,
		/obj/item/grenade/spawnergrenade,
		/obj/item/grenade/empgrenade,
		/obj/item/grenade/flashbang,
		/obj/item/grenade/chem_grenade/large,
		/obj/item/grenade/syndieminibomb,
		/obj/item/grenade/chem_grenade/cryo,
		/obj/item/grenade/chem_grenade/pyro
	)
	var/turf/grenade_turf
	var/obj/effect/client_image_holder/hallucination/fake_grenade/grenade_effect
	var/duration

/datum/hallucination/fake_grenade/start()
	if(!hallucinator.client || hallucinator.stat != CONSCIOUS)
		return FALSE

	var/grenade_path = pick(grenade_type)
	var/obj/item/grenade/grenade = grenade_path
	duration = grenade::det_time

	var/direction = pick(GLOB.alldirs)
	grenade_turf = get_step(get_turf(hallucinator), direction)
	if(!grenade_turf)
		return FALSE

	feedback_details += "Type: [grenade_path], Landing: ([grenade_turf.x], [grenade_turf.y], [grenade_turf.z])"

	grenade_effect = new /obj/effect/client_image_holder/hallucination/fake_grenade(grenade_turf, hallucinator, src, grenade_path, direction, 9)

	addtimer(CALLBACK(src, PROC_REF(run_ending)), duration)
	return TRUE

/datum/hallucination/fake_grenade/Destroy()
	QDEL_NULL(grenade_effect)
	grenade_turf = null
	return ..()

/datum/hallucination/fake_grenade/proc/run_ending()
	if(QDELETED(src) || QDELETED(hallucinator))
		qdel(src)
		return

	ending_effect()
	qdel(src)

/datum/hallucination/fake_grenade/proc/ending_effect()
	if(QDELETED(hallucinator) || !grenade_turf)
		QDEL_NULL(grenade_effect)
		return FALSE

	var/distance = get_dist(hallucinator, grenade_turf)
	QDEL_NULL(grenade_effect)
	return distance <= 4

/datum/hallucination/fake_grenade/flashbang
	grenade_type = list(/obj/item/grenade/flashbang)
	random_hallucination_weight = 1

/datum/hallucination/fake_grenade/flashbang/run_ending()
	if(QDELETED(src) || QDELETED(hallucinator))
		qdel(src)
		return

	if(!ending_effect())
		qdel(src)
		return

	hallucinator.playsound_local(grenade_turf, 'sound/effects/bang.ogg', 60, TRUE)
	hallucinator.show_message(span_warning("BANG"), 2)
	var/weaken_time = 6 SECONDS
	if(hallucinator.flash_eyes(visual = TRUE))
		weaken_time /= 2
	hallucinator.Weaken(weaken_time)

	if(hallucinator.check_ear_prot())
		qdel(src)
		return

	to_chat(hallucinator, span_warning(pick(
		"В ушах звенит!",
		"В ушах сильно звенит!",
		"Вы ничего не слышите!",
	)))

	if(prob(20))
		hallucinator.Deaf(2 SECONDS)

	qdel(src)

/obj/effect/client_image_holder/hallucination/fake_grenade
	name = "граната"
	var/direction
	var/distance = 9

/obj/effect/client_image_holder/hallucination/fake_grenade/Initialize(mapload, list/mobs_which_see_us, datum/hallucination/parent, grenade_path, direction, distance)
	src.direction = direction
	if(!isnull(distance))
		src.distance = distance

	var/obj/item/grenade/grenade = grenade_path
	image_icon = grenade::icon
	image_state = "[grenade::icon_state]_active"
	image_layer = grenade::layer

	. = ..(mapload, mobs_which_see_us, parent)

	switch(src.direction)
		if(NORTH)
			pixel_y = 32 * src.distance
		if(NORTHEAST)
			pixel_x = 32 * src.distance
			pixel_y = 32 * src.distance
		if(EAST)
			pixel_x = 32 * src.distance
		if(SOUTHEAST)
			pixel_x = 32 * src.distance
			pixel_y = -32 * src.distance
		if(SOUTH)
			pixel_y = -32 * src.distance
		if(SOUTHWEST)
			pixel_x = -32 * src.distance
			pixel_y = -32 * src.distance
		if(WEST)
			pixel_x = -32 * src.distance
		if(NORTHWEST)
			pixel_x = -32 * src.distance
			pixel_y = 32 * src.distance

	if(parent?.hallucinator)
		parent.hallucinator.playsound_local(get_turf(src), 'sound/weapons/armbomb.ogg', 75, TRUE)

	animate(src, 9, pixel_x = 0, pixel_y = 0, flags = ANIMATION_PARALLEL)
	animate(shown_image, transform = matrix(120, MATRIX_ROTATE), time = 3, flags = ANIMATION_PARALLEL)
	animate(shown_image, transform = matrix(240, MATRIX_ROTATE), time = 3)
	animate(shown_image, transform = matrix(360, MATRIX_ROTATE), time = 3)
