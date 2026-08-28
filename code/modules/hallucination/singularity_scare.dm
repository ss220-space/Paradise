/// A fake singularity slowly moves towards the hallucinator, then "eats" them (fake crit + sleep).
/datum/hallucination/singularity_scare
	random_hallucination_weight = 1
	hallucination_tier = HALLUCINATION_TIER_RARE

	/// The fake singularity object.
	var/obj/effect/client_image_holder/hallucination/singularity/fake_singularity

/datum/hallucination/singularity_scare/start()
	if(hallucinator.stat != CONSCIOUS)
		return FALSE

	var/turf/start_turf = get_turf(hallucinator)
	var/screen_border = pick(GLOB.cardinal)
	for(var/i in 0 to 10)
		var/turf/next_turf = get_step(start_turf, screen_border)
		if(!next_turf)
			break
		start_turf = next_turf

	if(!start_turf || start_turf == get_turf(hallucinator))
		for(var/i in 0 to 10)
			var/turf/next_turf = get_step(start_turf, REVERSE_DIR(screen_border))
			if(!next_turf)
				break
			start_turf = next_turf

	if(!start_turf || start_turf == get_turf(hallucinator))
		return FALSE

	fake_singularity = new(start_turf, hallucinator, src)

	GLOB.move_manager.move_to(fake_singularity, hallucinator, 0, 0.5 SECONDS, timeout = 15 SECONDS)

	addtimer(CALLBACK(src, PROC_REF(check_reach)), 4 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(check_reach)), 8 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(check_reach)), 12 SECONDS)
	return TRUE

/// Checks whether the singularity has reached the hallucinator and "eats" them.
/datum/hallucination/singularity_scare/proc/check_reach()
	if(QDELETED(src) || QDELETED(hallucinator) || QDELETED(fake_singularity))
		return

	if(get_dist(get_turf(fake_singularity), hallucinator) <= 3)
		hallucinator.hal_screwyhud = SCREWYHUD_CRIT
		hallucinator.SetSleeping(16 SECONDS)
		qdel(src)

/datum/hallucination/singularity_scare/Destroy()
	if(!QDELETED(hallucinator))
		hallucinator.hal_screwyhud = SCREWYHUD_NONE
	if(fake_singularity)
		GLOB.move_manager.stop_looping(fake_singularity)
		QDEL_NULL(fake_singularity)
	return ..()

/// A movable fake singularity that glides towards the hallucinator.
/obj/effect/client_image_holder/hallucination/singularity
	name = "сингулярность"
	image_icon = 'icons/effects/224x224.dmi'
	image_state = "singularity_s7"
	image_layer = 6
	image_pixel_x = -96
	image_pixel_y = -96
