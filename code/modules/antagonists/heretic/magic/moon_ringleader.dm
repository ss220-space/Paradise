/datum/action/innate/aoe/moon_ringleader
	name = "Ringleaders Rise"
	desc = "Big AoE spell that deals brain damage and causes hallucinations to everyone in the AoE. \
			The worse their sanity, the stronger this spell becomes. \
			If their sanity is low enough, they even snap and go insane, and the spell then further halves their sanity."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "moon_ringleader"
	sound = 'sound/effects/moon_parade.ogg'

	school = SCHOOL_FORBIDDEN
	base_cooldown = 1 MINUTES
	antimagic_flags = MAGIC_RESISTANCE|MAGIC_RESISTANCE_MIND
	invocation = "R'S 'E!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE

	aoe_radius = 5
	/// Effect for when the spell triggers
	var/obj/effect/moon_effect = /obj/effect/temp_visual/moon_ringleader

/datum/action/innate/aoe/moon_ringleader/cast(mob/living/caster)
	new moon_effect(get_turf(caster))
	return ..()

/datum/action/innate/aoe/moon_ringleader/get_things_to_cast_on(atom/center, radius_override)
	var/list/stuff = list()
	var/list/o_range = orange(center, radius_override || aoe_radius) - list(owner, center)
	for(var/mob/living/carbon/nearby_mob in o_range)
		if(nearby_mob.stat == DEAD)
			continue

		if(IS_HERETIC_OR_MONSTER(nearby_mob))
			continue

		if(nearby_mob.can_block_magic(antimagic_flags))
			continue

		stuff += nearby_mob

	return stuff

/datum/action/innate/aoe/moon_ringleader/cast_on_thing_in_aoe(mob/living/carbon/victim, mob/living/caster)
	victim.adjustOrganLoss(INTERNAL_ORGAN_BRAIN, 100 - victim_sanity, 160)
	for(var/i in 1 to round((120 - victim_sanity) / 10))
		victim.cause_hallucination(get_random_valid_hallucination_subtype(/datum/hallucination/body), name)


/obj/effect/temp_visual/moon_ringleader
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "ring_leader_effect"
	alpha = 180
	duration = 6

/obj/effect/temp_visual/moon_ringleader/ringleader/Initialize(mapload)
	. = ..()
	transform = transform.Scale(10)
