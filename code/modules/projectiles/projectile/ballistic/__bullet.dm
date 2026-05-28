/obj/projectile/bullet
	name = "bullet"
	gender = FEMALE
	damage = 50
	hitsound = SFX_BULLET
	hitsound_wall = SFX_RICOCHET
	impact_effect_type = /obj/effect/temp_visual/impact_effect
	ricochets_max = 1
	ricochet_chance = 5

/obj/projectile/bullet/get_ru_names()
	return list(
		NOMINATIVE = "пуля",
		GENITIVE = "пули",
		DATIVE = "пуле",
		ACCUSATIVE = "пулю",
		INSTRUMENTAL = "пулей",
		PREPOSITIONAL = "пуле",
	)

/obj/projectile/bullet/on_ricochet(atom/A)
	. = ..()
	damage = damage / 2
	stamina = stamina / 2

/obj/projectile/bullet/on_hit(atom/target, blocked = 0)
	. = ..()
	if(!.)
		return
	if(!ismob(target))
		return
	var/datum/gun_recoil/recoil = GLOB.mob_hit_recoil
	var/shot_angle = get_angle(firer, target)
	var/rand_angle = (rand() - 0.5) * recoil.angle + shot_angle
	recoil_camera(target, recoil.strength, recoil.in_duration, recoil.back_duration, rand_angle)
