/// Causes a random body to appear and disappear within the hallucinator's field of vision.
/datum/hallucination/body
	abstract_hallucination_parent = /datum/hallucination/body
	hallucination_tier = HALLUCINATION_TIER_COMMON
	/// The file to make the body image from.
	var/body_image_file
	/// The icon state to make the body image form.
	var/body_image_state
	/// The actual image we made and showed show.
	var/image/shown_body
	/// Whether we apply the floating anim to the body
	var/body_floats = FALSE
	/// The layer this body will be drawn on, in case we want to bypass lighting
	var/body_layer = BELOW_MOB_LAYER
	/// if TRUE, spawns the body under the hallucinator instead of somewhere in view
	var/spawn_under_hallucinator = FALSE

/datum/hallucination/body/start()
	// This hallucination is purely visual, so we don't need to bother for clientless mobs
	if(!hallucinator.client || hallucinator.stat != CONSCIOUS)
		return FALSE

	var/list/possible_points = list()
	if(spawn_under_hallucinator)
		possible_points += get_turf(hallucinator)
	else
		for(var/turf/simulated/floor/open_turf in view(hallucinator))
			if(open_turf.is_blocked_turf())
				continue
			possible_points += open_turf

	if(!length(possible_points))
		return FALSE

	var/turf/picked = pick(possible_points)
	if(isspaceturf(picked) || !picked.has_gravity())
		body_floats = TRUE

	shown_body = make_body_image(picked)

	hallucinator.client?.images |= shown_body
	return queue_cleanup()

/datum/hallucination/body/proc/queue_cleanup()
	QDEL_IN(src, rand(3 SECONDS, 5 SECONDS)) //Only seen for a brief moment.
	return TRUE

/datum/hallucination/body/Destroy()
	hallucinator.client?.images -= shown_body
	shown_body = null
	return ..()

/// Makes the image of the body to show at the location passed.
/datum/hallucination/body/proc/make_body_image(turf/location)
	var/image/created_image = image(body_image_file, location, body_image_state, body_layer)
	SET_PLANE_EXPLICIT(created_image, GAME_PLANE, location)
	if(body_floats)
		DO_FLOATING_ANIM(created_image)
	return created_image

/datum/hallucination/body/husk
	random_hallucination_weight = 8
	body_image_file = 'icons/mob/human.dmi'
	body_image_state = "husk_s"

/datum/hallucination/body/husk/sideways
	random_hallucination_weight = 4

/datum/hallucination/body/husk/sideways/make_body_image(turf/location)
	var/image/body = ..()
	var/matrix/turn_matrix = matrix()
	turn_matrix.Turn(90)
	body.transform = turn_matrix
	return body

// Absolutely damned
/datum/hallucination/body/lizard_woman
	random_hallucination_weight = 1
	body_image_file = 'icons/mob/human.dmi'
	body_image_state = "lizard_f_s"

/datum/hallucination/body/skeleton
	random_hallucination_weight = 3
	body_image_file = 'icons/mob/human.dmi'
	body_image_state = "skeleton_s"

/datum/hallucination/body/weird
	random_hallucination_weight = 0.1 // These are very uncommon
	abstract_hallucination_parent = /datum/hallucination/body/weird
	hallucination_tier = HALLUCINATION_TIER_RARE

/datum/hallucination/body/weird/ghost
	body_image_file = 'icons/mob/mob.dmi'
	body_image_state = "ghost"
	body_floats = TRUE

/datum/hallucination/body/weird/ghostking
	body_image_file = 'icons/mob/mob.dmi'
	body_image_state = "ghostking"
	body_floats = TRUE

/datum/hallucination/body/weird/alien
	body_image_file = 'icons/mob/alien.dmi'
	body_image_state = "aliend_pounce"

/datum/hallucination/body/weird/honk_demon
	body_image_file = 'icons/mob/mob.dmi'
	body_image_state = "honk_demon"

/datum/hallucination/body/weird/googly_eyes
	body_image_file = 'icons/mob/mob.dmi'
	body_image_state = "googly_eyes"
	body_floats = TRUE

/datum/hallucination/body/weird/god
	body_image_file = 'icons/mob/mob.dmi'
	body_image_state = "god"
	body_floats = TRUE

/datum/hallucination/body/weird/sling
	body_image_file = 'icons/mob/mob.dmi'
	body_image_state = "shadowling_ascended"

/datum/hallucination/body/weird/freezer
	random_hallucination_weight = 0.3 // Slightly more common since it's cool (heh)
	body_image_file = 'icons/effects/effects.dmi'
	body_image_state = "the_freezer"
	body_layer = ABOVE_ALL_MOB_LAYER
	spawn_under_hallucinator = TRUE
	hallucination_tier = HALLUCINATION_TIER_VERYSPECIAL

/datum/hallucination/body/weird/freezer/make_body_image(turf/location)
	var/image/body = ..()
	body.pixel_w = pick(rand(-208,-48), rand(48, 208))
	body.pixel_z = pick(rand(-208,-48), rand(48, 208))
	body.alpha = 245
	SET_PLANE_EXPLICIT(body, ABOVE_HUD_PLANE, location)
	return body

/datum/hallucination/body/weird/freezer/queue_cleanup()
	QDEL_IN(src, 12 SECONDS) //The freezer stays on screen while you're frozen
	addtimer(CALLBACK(src, PROC_REF(freeze_player)), 1 SECONDS) // You barely have a moment to react before you're frozen
	addtimer(CALLBACK(src, PROC_REF(freeze_intimidate)), 11.8 SECONDS)
	hallucinator.cause_hallucination(/datum/hallucination/fake_sound/weird/radio_static, "freezer hallucination")
	return TRUE

/datum/hallucination/body/weird/freezer/proc/freeze_player()
	if(QDELETED(src))
		return
	hallucinator.cause_hallucination(/datum/hallucination/ice, "freezer hallucination", duration = 11 SECONDS, play_freeze_sound = FALSE)

/datum/hallucination/body/weird/freezer/proc/freeze_intimidate()
	if(QDELETED(src))
		return
	// Spook 'em before we delete
	shown_body.pixel_w = (shown_body.pixel_w / 2)
	shown_body.pixel_z = (shown_body.pixel_z / 2)
