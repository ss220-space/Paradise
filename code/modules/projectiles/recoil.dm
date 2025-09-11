/datum/gun_recoil
	/// Recoil strength in tile size (32 pixels)
	var/strength
	/// Camera move to recoil point duration
	var/in_duration
	/// Camera move back duration
	var/back_duration
	/// Recoil angle randomization value
	var/angle = 45

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

/datum/gun_recoil/mega
	strength = 2
	in_duration = 0.9
	back_duration = 1.8

/// animate recoil for gun
/obj/item/gun/proc/do_recoil(mob/living/user, atom/target)
	if(!recoil || !recoil.strength)
		return
	if(zoomed)
		return // sights and recoil create visual bugs, disable recoil if we in sight mode.
	var/shot_angle = get_angle(target, user)
	var/rand_angle = (rand() - 0.5) * recoil.angle + shot_angle
	recoil_camera(user, recoil.strength, recoil.in_duration, recoil.back_duration, rand_angle)

/proc/recoil_camera(mob/user, strength, duration, backtime_duration, angle)
	if(!user || !user.client)
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
