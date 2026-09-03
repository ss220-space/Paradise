/// Fires a random fake projectile at the hallucinating target.
/datum/hallucination/stray_bullet
	random_hallucination_weight = 4
	hallucination_tier = HALLUCINATION_TIER_UNCOMMON

/datum/hallucination/stray_bullet/start()
	var/list/turf/starting_locations = list()

	for(var/turf/floor in view(world.view + 2, hallucinator) - view(world.view + 1, hallucinator))
		if(floor.density)
			continue
		starting_locations += floor

	if(!length(starting_locations))
		for(var/turf/floor in view(world.view + 1, hallucinator) - view(world.view, hallucinator))
			if(floor.density)
				continue
			starting_locations += floor

	if(!length(starting_locations))
		return FALSE

	var/turf/start = pick(starting_locations)
	var/fake_type = pick(subtypesof(/obj/effect/client_image_holder/hallucination/fake_projectile))

	feedback_details += "Type: [fake_type], Source: ([start.x], [start.y], [start.z])"

	var/obj/effect/client_image_holder/hallucination/fake_projectile/fake_projectile = new fake_type(start, hallucinator, src)

	fake_projectile.fire_at(hallucinator)

	QDEL_IN(src, 10 SECONDS) // Should clean up the projectile if it somehow gets stuck.
	return TRUE

/obj/effect/client_image_holder/hallucination/fake_projectile
	name = "пуля"
	image_layer = ABOVE_MOB_LAYER
	var/hal_icon = 'icons/obj/weapons/guns/projectiles.dmi'
	var/hal_icon_state
	var/hal_fire_sound
	var/hal_hitsound
	var/stamina_damage = 0

/obj/effect/client_image_holder/hallucination/fake_projectile/Initialize(mapload, mob/seer, datum/hallucination/parent)
	image_icon = hal_icon
	image_state = hal_icon_state
	return ..(mapload, list(seer), parent)

/obj/effect/client_image_holder/hallucination/fake_projectile/proc/fire_at(mob/living/target)
	if(hal_fire_sound)
		parent.hallucinator.playsound_local(get_turf(src), hal_fire_sound, 60, TRUE)

	var/turf/target_turf = get_turf(target)
	animate(src, pixel_x = (target_turf.x - x) * ICON_SIZE_X, pixel_y = (target_turf.y - y) * ICON_SIZE_Y, time = 0.5 SECONDS, easing = LINEAR_EASING)
	addtimer(CALLBACK(src, PROC_REF(hit_target), target), 0.5 SECONDS)

/obj/effect/client_image_holder/hallucination/fake_projectile/proc/hit_target(mob/living/target)
	if(QDELETED(src) || QDELETED(parent))
		return

	if(hal_hitsound)
		parent.hallucinator.playsound_local(get_turf(target), hal_hitsound, 100, TRUE)

	if(target == parent.hallucinator)
		to_chat(parent.hallucinator, span_userdanger("[target] поражён [src] в грудь!"))
		if(stamina_damage)
			target.adjustStaminaLoss(stamina_damage)
	else if(target in view(parent.hallucinator))
		to_chat(parent.hallucinator, span_danger("[target] поражён [src] в грудь!"))

	qdel(src)

/obj/effect/client_image_holder/hallucination/fake_projectile/bullet
	name = "пулей"
	hal_icon_state = "bullet"
	hal_fire_sound = 'sound/weapons/gunshots/1suppres.ogg'
	hal_hitsound = 'sound/weapons/bullet2.ogg'
	stamina_damage = 50

/obj/effect/client_image_holder/hallucination/fake_projectile/laser
	name = "лазером"
	hal_icon_state = "laser"
	hal_fire_sound = 'sound/weapons/gunshots/1laser10.ogg'
	hal_hitsound = 'sound/weapons/sear.ogg'
	stamina_damage = 30

/obj/effect/client_image_holder/hallucination/fake_projectile/disabler
	name = "дизейблером"
	hal_icon_state = "omnilaser"
	hal_fire_sound = 'sound/weapons/gunshots/1taser.ogg'
	hal_hitsound = 'sound/weapons/tase.ogg'
	stamina_damage = 10

/obj/effect/client_image_holder/hallucination/fake_projectile/ebow
	name = "болтом"
	hal_icon_state = "cbbolt"
	hal_fire_sound = 'sound/weapons/gunshots/1heavysuppres.ogg'
	hal_hitsound = null
	stamina_damage = 100
