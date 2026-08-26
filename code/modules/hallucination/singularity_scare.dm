/// A fake singularity slowly moves towards the hallucinator, then "eats" them (fake crit + sleep).
/datum/hallucination/singularity_scare
	random_hallucination_weight = 1
	hallucination_tier = HALLUCINATION_TIER_RARE

	/// The fake singularity image.
	var/image/fake_singularity
	/// Where the singularity currently is.
	var/turf/current_turf

/datum/hallucination/singularity_scare/start()
	if(hallucinator.stat != CONSCIOUS)
		return FALSE

	current_turf = get_turf(hallucinator)
	var/screen_border = pick(GLOB.cardinal)
	for(var/i in 0 to 10)
		current_turf = get_step(current_turf, screen_border)

	fake_singularity = image('icons/effects/224x224.dmi', current_turf, "singularity_s7", 6)
	fake_singularity.pixel_x = -96
	fake_singularity.pixel_y = -96
	hallucinator.client?.images |= fake_singularity

	addtimer(CALLBACK(src, PROC_REF(approach_step), 10), 5)
	return TRUE

/// Moves the fake singularity one tile closer to the hallucinator.
/datum/hallucination/singularity_scare/proc/approach_step(iterations)
	if(QDELETED(src) || QDELETED(hallucinator) || QDELETED(fake_singularity))
		return

	if(iterations <= 0)
		qdel(src)
		return

	current_turf = get_step(current_turf, get_dir(current_turf, get_turf(hallucinator)))
	fake_singularity.loc = current_turf

	if(get_dist(current_turf, hallucinator) <= 3)
		hallucinator.hal_screwyhud = SCREWYHUD_CRIT
		hallucinator.SetSleeping(16 SECONDS)
		qdel(src)
		return

	addtimer(CALLBACK(src, PROC_REF(approach_step), iterations - 1), 5)

/datum/hallucination/singularity_scare/Destroy()
	if(!QDELETED(hallucinator))
		hallucinator.hal_screwyhud = SCREWYHUD_NONE
		if(fake_singularity)
			hallucinator.client?.images -= fake_singularity
	fake_singularity = null
	return ..()