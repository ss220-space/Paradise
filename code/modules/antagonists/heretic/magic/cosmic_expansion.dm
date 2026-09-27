/datum/action/cooldown/spell/conjure/cosmic_expansion
	name = "Расширение Территории"
	desc = "Это заклинание создаёт вокруг вас область космических полей размером 5x5. \
			Существа, находящиеся на расстоянии до 7 клеток, получат звёздную метку."
	background_icon = 'icons/mob/actions/backgrounds.dmi'
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "cosmic_domain"

	sound = 'sound/magic/cosmic_expansion.ogg'
	school = SCHOOL_FORBIDDEN
	cooldown_time = 15 SECONDS

	invocation = "Б'СК'Н'ЧН П'СТ'Т!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE

	summon_amount = 25
	summon_radius = 2
	summon_type = list(/obj/effect/forcefield/cosmic_field)
	/// The range at which people will get marked with a star mark.
	var/star_mark_range = 7
	/// Effect for when the spell triggers
	var/obj/effect/expansion_effect = /obj/effect/temp_visual/cosmic_domain
	/// If the heretic is ascended or not
	var/ascended = FALSE


/datum/action/cooldown/spell/conjure/cosmic_expansion/cast(atom/cast_on)
	var/mob/living/caster = owner
	if(!caster)
		return
	new expansion_effect(get_turf(caster))
	for(var/mob/living/nearby_mob in range(star_mark_range, caster))
		if(nearby_mob == caster || caster.buckled == nearby_mob || IS_HERETIC_OR_MONSTER(nearby_mob))
			continue
		nearby_mob.apply_status_effect(/datum/status_effect/star_mark, caster)

	if(ascended)
		for(var/turf/cast_turf as anything in get_turfs(get_turf(caster)))
			if(cast_turf.density) // don't bury fields inside walls, same as the main carpet loop above
				continue
			create_cosmic_field(cast_turf, caster)

	return ..()


/datum/action/cooldown/spell/conjure/cosmic_expansion/post_summon(obj/effect/forcefield/cosmic_field/summoned_object, atom/cast_on)
	. = ..()
	if(istype(owner, /mob/living/simple_animal/hostile/heretic_summon/star_gazer))
		summoned_object.slows_projectiles()
		summoned_object.prevents_explosions()
		return

	var/datum/status_effect/heretic_passive/cosmic/cosmic_passive = owner.has_status_effect(/datum/status_effect/heretic_passive/cosmic)
	if(!cosmic_passive)
		return
	if(cosmic_passive.applied_level >= 2)
		summoned_object.prevents_explosions()
	if(cosmic_passive.applied_level >= 3)
		summoned_object.slows_projectiles()


/datum/action/cooldown/spell/conjure/cosmic_expansion/proc/get_turfs(turf/target_turf)
	var/list/target_turfs = list()
	for(var/direction in GLOB.cardinal)
		target_turfs += get_ranged_target_turf(target_turf, direction, 2)
		target_turfs += get_ranged_target_turf(target_turf, direction, 3)

	return target_turfs
