/datum/hallucination/sniper
	random_hallucination_weight = 2
	hallucination_tier = HALLUCINATION_TIER_RARE

/datum/hallucination/sniper/start()
	if(!hallucinator.client || hallucinator.stat != CONSCIOUS)
		return FALSE

	var/turf/center = get_turf(hallucinator)
	var/list/possible_turfs = list()
	for(var/turf/turf in RANGE_EDGE_TURFS(13, center))
		if(!turf.density)
			possible_turfs += turf

	if(!length(possible_turfs))
		return FALSE

	var/turf/shot_loc = pick(possible_turfs)
	feedback_details += "Source: ([shot_loc.x], [shot_loc.y], [shot_loc.z])"

	var/obj/effect/client_image_holder/hallucination/sniper_bullet/bullet = new(shot_loc, hallucinator, src)
	bullet.fire_at(hallucinator)

	QDEL_IN(src, 10 SECONDS)
	return TRUE

/obj/effect/client_image_holder/hallucination/sniper_bullet
	name = "пуля"
	image_layer = ABOVE_MOB_LAYER
	var/hal_icon = 'icons/obj/weapons/guns/projectiles.dmi'
	var/hal_icon_state = "bullet"
	var/hal_fire_sound = 'sound/weapons/gunshots/gunshot_sniper.ogg'
	var/hal_hitsound = 'sound/weapons/bullet2.ogg'
	var/matrix/hal_transform

/obj/effect/client_image_holder/hallucination/sniper_bullet/Initialize(mapload, mob/seer, datum/hallucination/parent)
	image_icon = hal_icon
	image_state = hal_icon_state
	. = ..(mapload, list(seer), parent)

/obj/effect/client_image_holder/hallucination/sniper_bullet/proc/fire_at(mob/living/target)
	if(hal_fire_sound)
		parent.hallucinator.playsound_local(get_turf(src), hal_fire_sound, 50, TRUE)

	var/turf/target_turf = get_turf(target)
	var/angle = get_angle(src, target_turf)

	hal_transform = new
	hal_transform.Turn(angle)
	regenerate_image()
	if(shown_image)
		shown_image.transform = hal_transform

	animate(src, pixel_x = (target_turf.x - x) * ICON_SIZE_X, pixel_y = (target_turf.y - y) * ICON_SIZE_Y, time = 0.75 SECONDS, easing = LINEAR_EASING)
	addtimer(CALLBACK(src, PROC_REF(hit_target), target), 0.75 SECONDS)

/obj/effect/client_image_holder/hallucination/sniper_bullet/proc/hit_target(mob/living/target)
	if(QDELETED(src) || QDELETED(parent) || QDELETED(target))
		return

	if(hal_hitsound)
		parent.hallucinator.playsound_local(get_turf(target), hal_hitsound, 100, TRUE)

	if(target == parent.hallucinator)
		to_chat(parent.hallucinator, span_userdanger("В вас попадает снайперская пуля — прямо в голову!"))
		target.apply_damage(60, STAMINA, BODY_ZONE_HEAD)
		target.Knockdown(2 SECONDS)

		var/blood_color = "#A10808"
		if(ishuman(target))
			var/list/b_data = target.get_blood_data(target.get_blood_id())
			if(b_data && b_data["blood_color"])
				blood_color = b_data["blood_color"]

		new /obj/effect/client_image_holder/hallucination/sniper_bloodsplatter(get_turf(target), target, parent, blood_color)

	qdel(src)

/obj/effect/client_image_holder/hallucination/sniper_bloodsplatter
	name = "кровь"
	image_icon = 'icons/effects/blood.dmi'
	image_state = "mfloor1"
	image_layer = ABOVE_NORMAL_TURF_LAYER
	var/splatter_color = "#A10808"

/obj/effect/client_image_holder/hallucination/sniper_bloodsplatter/Initialize(mapload, mob/seer, datum/hallucination/parent, blood_color)
	if(blood_color)
		src.splatter_color = blood_color
	image_color = src.splatter_color
	image_state = pick("mfloor1", "mfloor2", "mfloor3", "mfloor4", "mfloor5", "mfloor6", "mfloor7")
	. = ..(mapload, list(seer), parent)
	QDEL_IN(src, 10 SECONDS)
