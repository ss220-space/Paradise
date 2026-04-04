/obj/projectile/destabilizer
	name = "destabilizing force"
	icon_state = "pulse1"
	nodamage = TRUE
	damage = 0 //We're just here to mark people. This is still a melee weapon.
	flag = "bomb"
	range = 6
	log_override = TRUE
	var/obj/item/twohanded/kinetic_crusher/hammer_synced

/obj/projectile/destabilizer/get_ru_names()
	return list(
		NOMINATIVE = "дестабилизирующий заряд",
		GENITIVE = "дестабилизирующего заряда",
		DATIVE = "дестабилизирующему заряду",
		ACCUSATIVE = "дестабилизирующий заряд",
		INSTRUMENTAL = "дестабилизирующим зарядом",
		PREPOSITIONAL = "дестабилизирующем заряде",
	)

/obj/projectile/destabilizer/Destroy()
	hammer_synced = null
	return ..()

/obj/projectile/destabilizer/on_hit(atom/target, blocked = FALSE)
	if(isliving(target))
		var/mob/living/L = target
		var/had_effect = (L.has_status_effect(STATUS_EFFECT_CRUSHERMARK)) //used as a boolean
		var/datum/status_effect/crusher_mark/CM = L.apply_status_effect(STATUS_EFFECT_CRUSHERMARK, hammer_synced)
		if(hammer_synced)
			for(var/t in hammer_synced.trophies)
				var/obj/item/crusher_trophy/T = t
				T.on_mark_application(target, CM, had_effect)
	var/target_turf = get_turf(target)
	if(ismineralturf(target_turf))
		var/turf/simulated/mineral/mineral = target_turf
		new /obj/effect/temp_visual/kinetic_blast(mineral)
		mineral.attempt_drill(firer)
	..()

/obj/projectile/destabilizer/mega
	icon_state = "pulse0"
	range = 4 //you know....

/obj/projectile/destabilizer/mega/on_hit(atom/target, blocked = FALSE)
	var/target_turf = get_turf(target)
	if(ismineralturf(target_turf))
		if(istype(target_turf, /turf/simulated/mineral/gibtonite))
			var/turf/simulated/mineral/gibtonite/gib = target
			if(gib.stage == 0)
				gib.defuse()
			var/obj/item/twohanded/required/gibtonite/gibtonite_item = new(gib)
			gibtonite_item.quality = gib.det_time
			gibtonite_item.update_icon(UPDATE_ICON_STATE)
			gib.ChangeTurf(gib.turf_type)
		else
			var/turf/simulated/mineral/M = target_turf
			new /obj/effect/temp_visual/kinetic_blast(M)
			forcedodge = 1
			M.attempt_drill(firer)
	else
		forcedodge = 0
	..()
