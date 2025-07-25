/obj/effect/proc_holder/spell/pointed/projectile/star_blast
	name = "Звездный Взрыв"
	desc = "Это заклинание запускает в цель диск с космической энергией, распространяющий космические поля."
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "star_blast"

	sound = 'sound/magic/cosmic_energy.ogg'
	school = SCHOOL_FORBIDDEN
	clothes_req = FALSE
	base_cooldown = 20 SECONDS

	invocation = "ЗВ'ЗДН'Й ВЗР'В!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE

	active_msg = "Вы готовы применить звездный взрыв!"
	deactive_msg = "Вы прекращаете концентрировать космическую энергию в своих руках... на время."
	cast_range = 12
	projectile_type = /obj/projectile/magic/star_ball


/obj/projectile/magic/star_ball
	name = "звёздный диск"
	ru_names = list(
		NOMINATIVE = "звёздный диск",
		GENITIVE = "звёздного диска",
		DATIVE = "звёздному диску",
		ACCUSATIVE = "звёздный диск",
		INSTRUMENTAL = "звёздным диском",
		PREPOSITIONAL = "звёзднои диске",
	)
	gender = MALE
	icon_state = "star_ball"
	damage = 20
	damage_type = BURN
	speed = 0.2
	range = 100
	knockdown = 4 SECONDS
	/// Effect for when the ball hits something
	var/obj/effect/explosion_effect = /obj/effect/temp_visual/cosmic_explosion
	/// The range at which people will get marked with a star mark.
	var/star_mark_range = 3


/obj/projectile/magic/star_ball/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/effect_trail, /obj/effect/forcefield/cosmic_field/fast)


/obj/projectile/magic/star_ball/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	var/mob/living/cast_on = firer
	for(var/mob/living/nearby_mob in range(star_mark_range, target))
		if(cast_on == nearby_mob || cast_on.buckled == nearby_mob)
			continue

		nearby_mob.apply_status_effect(/datum/status_effect/star_mark, cast_on)


/obj/projectile/magic/star_ball/Destroy()
	playsound(get_turf(src), 'sound/magic/cosmic_energy.ogg', 50, FALSE)
	for(var/turf/cast_turf as anything in get_turfs())
		new /obj/effect/forcefield/cosmic_field(cast_turf)
		
	return ..()


/obj/projectile/magic/star_ball/proc/get_turfs()
	return list(get_turf(src), pick(get_step(src, NORTH), get_step(src, SOUTH)), pick(get_step(src, EAST), get_step(src, WEST)))
