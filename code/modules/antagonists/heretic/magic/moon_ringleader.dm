/obj/effect/proc_holder/spell/aoe/moon_ringleader
	name = "Восстание Главарей"
	desc = "Мощное заклинание, наносящее урон мозгу и вызывающее галлюцинации у всех в зоне \
			действия."
	action_background_icon = 'icons/mob/actions/backgrounds.dmi'
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "moon_ringleader"
	sound = 'sound/effects/moon_parade.ogg'

	school = SCHOOL_FORBIDDEN
	human_req = FALSE
	clothes_req = FALSE
	base_cooldown = 1 MINUTES
	antimagic_flags = MAGIC_RESISTANCE|MAGIC_RESISTANCE_MIND
	invocation = "R'S 'E!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE

	aoe_range = 5
	/// Effect for when the spell triggers
	var/obj/effect/moon_effect = /obj/effect/temp_visual/moon_ringleader


/obj/effect/proc_holder/spell/aoe/moon_ringleader/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/aoe/moon_ringleader/get_things_to_cast_on(atom/center, radius_override)
	var/list/stuff = list()
	var/list/o_range = orange(center, radius_override || aoe_range) - list(action.owner, center)
	for(var/mob/living/carbon/nearby_mob in o_range)
		if(nearby_mob.stat == DEAD)
			continue

		if(IS_HERETIC_OR_MONSTER(nearby_mob))
			continue

		if(nearby_mob.can_block_magic(antimagic_flags))
			continue

		stuff += nearby_mob

	return stuff


/obj/effect/proc_holder/spell/aoe/moon_ringleader/cast(list/targets, mob/user = usr)
	var/turf/epicenter = get_turf(user)
	new moon_effect(epicenter)
	for(var/mob/living/carbon/victim as anything in get_things_to_cast_on(epicenter))
		victim.adjustOrganLoss(INTERNAL_ORGAN_BRAIN, 20, 160)
		victim.Hallucinate(120 SECONDS)
		victim.Confused(20 SECONDS)
		victim.EyeBlurry(20 SECONDS)
		victim.Druggy(20 SECONDS)
		victim.Slur(20 SECONDS)
		to_chat(victim, span_userdanger("ЛУНА СУДИТ ВАС И НАХОДИТ НЕДОСТОЙНЫМ!!!"))
	return ..()


/obj/effect/temp_visual/moon_ringleader
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "ring_leader_effect"
	alpha = 180
	duration = 6


/obj/effect/temp_visual/moon_ringleader/ringleader/Initialize(mapload)
	. = ..()
	transform = transform.Scale(10)
