//Recoil for mob hit
GLOBAL_DATUM_INIT(mob_hit_recoil, /datum/gun_recoil, GUN_RECOIL_LOW)

/datum/gun_recoil
	/// Recoil strength in tile size (32 pixels)
	var/strength
	/// Camera move to recoil point duration
	var/in_duration
	/// Camera move back duration
	var/back_duration
	/// Recoil angle randomization value
	var/angle = 45
	/// recoil throw dwarf users back
	var/knockback_dwrfs = FALSE

/datum/gun_recoil/minimal
	strength = 0.1
	in_duration = 0.5
	back_duration = 0.8

/datum/gun_recoil/low
	strength = 0.25
	in_duration = 0.6
	back_duration = 1

/datum/gun_recoil/medium
	strength = 0.45
	in_duration = 0.8
	back_duration = 1.2

/datum/gun_recoil/high
	strength = 1
	in_duration = 0.8
	back_duration = 1.5
	knockback_dwrfs = TRUE

/datum/gun_recoil/mega
	strength = 2
	in_duration = 0.9
	back_duration = 1.8
	knockback_dwrfs = TRUE

/// animate recoil for gun
/obj/item/gun/proc/do_recoil(mob/living/user, atom/target)
	if(!recoil || !recoil.strength)
		return
	if(HAS_TRAIT(user, TRAIT_USER_SCOPED))
		return // sights and recoil create visual bugs, disable recoil if we in sight mode.
	if(HAS_TRAIT(user, TRAIT_BADASS))
		return
	if(recoil.knockback_dwrfs && HAS_TRAIT(user, TRAIT_DWARF))
		do_knockback_dworfs(user, target)
		return
	CALCULATE_SKILL_MOD(user, RECOIL_MOD, recoil_modifier)
	var/shot_angle = get_angle(target, user)
	var/rand_angle = (rand() - 0.5) * recoil.angle + shot_angle
	recoil_camera(user, recoil.strength * recoil_modifier, recoil.in_duration * recoil_modifier, recoil.back_duration * recoil_modifier, rand_angle)

/obj/item/gun/proc/do_knockback_dworfs(mob/living/user, atom/target)
	var/knockback_dir = get_dir(target, user)
	if(!knockback_dir)
		knockback_dir = REVERSE_DIR(user.dir)
	var/turf/knockback_turf = get_ranged_target_turf(user, knockback_dir, 2)
	if(!knockback_turf)
		return

	user.visible_message(
		span_danger("[DECLENT_RU_CAP(user, NOMINATIVE)] не удержива[PLUR_ET_UT(user)]ся на ногах от отдачи!"),
		span_userdanger("Мощная отдача отбрасывает вас назад!"),
	)

	if(user.is_in_hands(src))
		user.drop_item_ground(src)
	else if(get_turf(src) != get_turf(user))
		forceMove(get_turf(user)) // force move to ground

	user.throw_at(knockback_turf, 2, 2, spin = TRUE)
	user.Knockdown(1 SECONDS)

/proc/recoil_camera(mob/user, strength, duration, backtime_duration, angle)
	if(!user || !istype(user) || !user.client)
		return
	var/client/sufferer = user.client
	strength *= ICON_SIZE_ALL
	var/oldx = sufferer.pixel_x
	var/oldy = sufferer.pixel_y
	//get pixels to move the camera in an angle
	var/mpx = sin(angle) * strength
	var/mpy = cos(angle) * strength
	animate(sufferer, pixel_x = oldx + mpx, pixel_y = oldy + mpy, time = duration, flags = ANIMATION_RELATIVE)
	animate(pixel_x = oldx, pixel_y = oldy, time = backtime_duration, easing = BACK_EASING)
