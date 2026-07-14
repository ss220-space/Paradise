/obj/effect/proc_holder/spell/aoe/conjure/cosmic_expansion
	name = "Расширение Территории"
	desc = "Это заклинание создаёт вокруг вас область космических полей размером 5x5. \
			Существа, находящиеся на расстоянии до 7 клеток, получат звёздную метку."
	action_background_icon = 'icons/mob/actions/backgrounds.dmi'
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "cosmic_domain"

	sound = 'sound/magic/cosmic_expansion.ogg'
	school = SCHOOL_FORBIDDEN
	human_req = FALSE
	clothes_req = FALSE
	base_cooldown = 15 SECONDS

	invocation = "Б'СК'Н'ЧН П'СТ'Т!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE

	summon_amt = 25
	aoe_range = 2
	summon_type = list(/obj/effect/forcefield/cosmic_field)
	/// The range at which people will get marked with a star mark.
	var/star_mark_range = 7
	/// Effect for when the spell triggers
	var/obj/effect/expansion_effect = /obj/effect/temp_visual/cosmic_domain
	/// If the heretic is ascended or not
	var/ascended = FALSE


/obj/effect/proc_holder/spell/aoe/conjure/cosmic_expansion/cast(list/targets, mob/user = usr)
	var/mob/living/caster = action?.owner
	if(!caster)
		return
	new expansion_effect(get_turf(caster))
	for(var/mob/living/nearby_mob in range(star_mark_range, caster))
		if(nearby_mob == caster || caster.buckled == nearby_mob || IS_HERETIC_OR_MONSTER(nearby_mob))
			continue
		nearby_mob.apply_status_effect(/datum/status_effect/star_mark, caster)

	for(var/turf/field_turf in targets)
		if(field_turf.density)
			continue
		create_cosmic_field(field_turf, caster)

	if(ascended)
		for(var/turf/cast_turf as anything in get_turfs(get_turf(caster)))
			if(cast_turf.density) // don't bury fields inside walls, same as the main carpet loop above
				continue
			create_cosmic_field(cast_turf, caster)

	return TRUE


/obj/effect/proc_holder/spell/aoe/conjure/cosmic_expansion/proc/get_turfs(turf/target_turf)
	var/list/target_turfs = list()
	for(var/direction in GLOB.cardinal)
		target_turfs += get_ranged_target_turf(target_turf, direction, 2)
		target_turfs += get_ranged_target_turf(target_turf, direction, 3)

	return target_turfs
