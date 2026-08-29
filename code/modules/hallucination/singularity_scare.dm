/// A fake singularity slowly moves towards the hallucinator, then "eats" them (fake crit + sleep).
/datum/hallucination/singularity_scare
	random_hallucination_weight = 1
	hallucination_tier = HALLUCINATION_TIER_RARE

	/// The fake singularity object.
	var/obj/effect/hallucination/simple/singularity/fake_singularity

/datum/hallucination/singularity_scare/start()
	if(hallucinator.stat != CONSCIOUS)
		return FALSE

	var/turf/start = get_turf(hallucinator)
	var/screen_border = pick(GLOB.cardinal)
	for(var/i in 0 to 10)
		var/turf/next = get_step(start, screen_border)
		if(!next)
			break
		start = next

	if(!start || start == get_turf(hallucinator))
		return FALSE

	fake_singularity = new /obj/effect/hallucination/simple/singularity(start, hallucinator)
	move_singularity_towards()
	return TRUE

/// Moves the singularity one tile closer to the hallucinator each call, gliding the image smoothly.
/datum/hallucination/singularity_scare/proc/move_singularity_towards()
	if(QDELETED(src) || QDELETED(fake_singularity) || QDELETED(hallucinator))
		qdel(src)
		return

	fake_singularity.Eat()
	if(get_dist(get_turf(fake_singularity), hallucinator) <= 3)
		wake_and_restore()
		return

	var/turf/next = get_step(get_turf(fake_singularity), get_dir(fake_singularity, hallucinator))
	if(!next)
		wake_and_restore()
		return

	if(fake_singularity.current_image)
		animate(fake_singularity.current_image, pixel_y = fake_singularity.current_image.pixel_y - 32, time = 0.3 SECONDS, easing = LINEAR_EASING)
	fake_singularity.forceMove(next)
	fake_singularity.Show()

	addtimer(CALLBACK(src, PROC_REF(move_singularity_towards)), 0.3 SECONDS)

/// Ends the hallucination and cleans up.
/datum/hallucination/singularity_scare/proc/wake_and_restore()
	if(!QDELETED(hallucinator))
		hallucinator.hal_screwyhud = SCREWYHUD_NONE
	QDEL_NULL(fake_singularity)
	qdel(src)

/datum/hallucination/singularity_scare/Destroy()
	if(!QDELETED(hallucinator))
		hallucinator.hal_screwyhud = SCREWYHUD_NONE
	QDEL_NULL(fake_singularity)
	return ..()

/// A simple movable hallucination object that shows an image to a single client and can be moved by loc.
/obj/effect/hallucination/simple
	var/image_icon
	var/image_state
	var/px = 0
	var/py = 0
	var/col_mod = null
	var/image/current_image = null
	var/image_layer = MOB_LAYER
	var/active = TRUE // qdelery
	/// The target mob who sees the image.
	var/mob/living/carbon/target

/obj/effect/hallucination/simple/New(loc, mob/living/carbon/T)
	..()
	target = T
	current_image = GetImage()
	if(target.client)
		target.client.images |= current_image

/obj/effect/hallucination/simple/Destroy()
	if(target?.client)
		target.client.images.Remove(current_image)
	current_image = null
	active = FALSE
	return ..()

/obj/effect/hallucination/simple/proc/GetImage()
	var/image/I = image(image_icon, src, image_state, image_layer, dir = dir)
	I.pixel_w = px
	I.pixel_z = py
	if(col_mod)
		I.color = col_mod
	return I

/obj/effect/hallucination/simple/proc/Show(update = 1)
	if(active)
		if(target?.client)
			target.client.images.Remove(current_image)
		if(update)
			current_image = GetImage()
		if(target?.client)
			target.client.images |= current_image

/obj/effect/hallucination/simple/Move(atom/newloc, direct = NONE, glide_size_override = 0, update_dir = TRUE)
	. = ..()
	Show()

/// The singularity hallucination - a big spiral that slides towards its target and "eats" them up close.
/obj/effect/hallucination/simple/singularity
	image_icon = 'icons/effects/224x224.dmi'
	image_state = "singularity_s7"
	image_layer = 6
	px = -96
	py = -96

/// If the singularity is close enough, fake-eats the target (fake crit + sleep).
/obj/effect/hallucination/simple/singularity/proc/Eat()
	var/target_dist = get_dist(src, target)
	if(target_dist <= 3) // "Eaten"
		target.hal_screwyhud = SCREWYHUD_CRIT
		target.SetSleeping(4 SECONDS)
