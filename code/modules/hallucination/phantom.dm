/// Causes a random body or item to appear and disappear within the hallucinator's field of vision.
/datum/hallucination/phantom
	abstract_hallucination_parent = /datum/hallucination/phantom
	hallucination_tier = HALLUCINATION_TIER_COMMON
	var/image_file
	var/image_state
	/// The actual image we made and showed show.
	var/image/shown_body
	/// Whether we apply the floating anim to the body
	var/floats = FALSE
	/// The layer this body will be drawn on, in case we want to bypass lighting
	var/layer = BELOW_MOB_LAYER
	/// if TRUE, spawns the body under the hallucinator instead of somewhere in view
	var/spawn_under_hallucinator = FALSE

/datum/hallucination/phantom/start()
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
		floats = TRUE

	shown_body = make_image(picked)

	hallucinator.client?.images |= shown_body
	return queue_cleanup()

/datum/hallucination/phantom/proc/queue_cleanup()
	QDEL_IN(src, rand(3 SECONDS, 5 SECONDS)) //Only seen for a brief moment.
	return TRUE

/datum/hallucination/phantom/Destroy()
	hallucinator.client?.images -= shown_body
	shown_body = null
	return ..()

/// Makes the image of the body to show at the location passed.
/datum/hallucination/phantom/proc/make_image(turf/location)
	var/image/created_image = image(image_file, location, image_state, layer)
	SET_PLANE_EXPLICIT(created_image, GAME_PLANE, location)
	if(floats)
		DO_FLOATING_ANIM(created_image)
	return created_image

/datum/hallucination/phantom/fly
	random_hallucination_weight = 4
	image_file = 'icons/mob/human.dmi'
	image_state = "fly"

/datum/hallucination/phantom/fly/sideways

/datum/hallucination/phantom/fly/sideways/make_image(turf/location)
	var/image/body = ..()
	var/matrix/turn_matrix = matrix()
	turn_matrix.Turn(90)
	body.transform = turn_matrix
	return body

// Absolutely damned
/datum/hallucination/phantom/lizard_woman
	random_hallucination_weight = 1
	image_file = 'icons/mob/human.dmi'
	image_state = "lizard_f_s"

/datum/hallucination/phantom/rat_king
	random_hallucination_weight = 2
	image_file = 'icons/mob/animal.dmi'
	image_state = "regalrat"

/datum/hallucination/phantom/cool_cock
	random_hallucination_weight = 3
	image_file = 'icons/mob/animal.dmi'
	image_state = "cool_cock"

/datum/hallucination/phantom/mouse_ass
	random_hallucination_weight = 2
	image_file = 'icons/mob/animal.dmi'
	image_state = "mouse_gray_idle5"

/datum/hallucination/phantom/blobpod
	random_hallucination_weight = 4
	image_file = 'icons/mob/blob.dmi'
	image_state = "blobpod"

/datum/hallucination/phantom/skeleton
	random_hallucination_weight = 2
	image_file = 'icons/mob/human.dmi'
	image_state = "skeleton_s"

/datum/hallucination/phantom/weird
	image_file = 'icons/mob/mob.dmi'
	random_hallucination_weight = 0.1 // These are very uncommon
	abstract_hallucination_parent = /datum/hallucination/phantom/weird
	hallucination_tier = HALLUCINATION_TIER_RARE

/datum/hallucination/phantom/weird/ghost
	image_state = "ghost"
	floats = TRUE

/datum/hallucination/phantom/weird/ghostking
	image_state = "ghostking"
	floats = TRUE

/datum/hallucination/phantom/weird/honk_demon
	image_state = "honk_demon"

/datum/hallucination/phantom/weird/googly_eyes
	image_state = "googly_eyes"
	floats = TRUE

/datum/hallucination/phantom/weird/god
	image_state = "god"
	floats = TRUE

/datum/hallucination/phantom/weird/sling
	image_state = "shadowling_ascended"

/datum/hallucination/phantom/object
	random_hallucination_weight = 1

/datum/hallucination/phantom/object/syndicate_swat
	image_file = 'icons/obj/clothing/gloves.dmi'
	image_state = "syndicate_swat"

/datum/hallucination/phantom/object/fuel_tank
	image_file = 'icons/obj/medicine/chemical_tanks.dmi'
	image_state = "fuel_tank"

/datum/hallucination/phantom/object/toolbox_green
	image_file = 'icons/obj/storage/boxes.dmi'
	image_state = "toolbox_green_frenzy"

/datum/hallucination/phantom/object/contractor_baton
	image_file = 'icons/obj/weapons/baton.dmi'
	image_state = "contractor_baton_on"

/datum/hallucination/phantom/object/syndicate_grenade
	image_file = 'icons/obj/weapons/grenade.dmi'
	image_state = "syndicate_active"

/datum/hallucination/phantom/object/rsh12
	image_file = 'icons/obj/weapons/projectile.dmi'
	image_state = "rsh-12"

/datum/hallucination/phantom/object/pinonmedium_contractor
	image_file = 'icons/obj/device.dmi'
	image_state = "pinonmedium_contractor"
