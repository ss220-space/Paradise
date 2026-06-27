/obj/effect/proc_holder/spell/shapeshift/shed_human_form
	name = "Сброс старой оболочки"
	desc = "Сбросьте свою хрупкую оболочку, станьте единым с руками, стань единым с Императором. \
			Вызывает серьёзные повреждения мозга и потерю рассудка у находящихся рядом смертных."
	action_background_icon = 'icons/mob/actions/backgrounds.dmi'
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "worm_ascend"

	school = SCHOOL_FORBIDDEN
	invocation = "ДА РАСКРОЕТСЯ РЕАЛЬНОСТЬ!"
	spell_requirements = NONE

	//convert_damage = FALSE // Functionally meaningless on Armsy, we track how many segments it had instead
	// Only one possible form, so fix it up-front (TG auto-picks for a single shape) — no pointless
	// one-option "choose your form" popup, and the button is a clean become-worm / return-to-human toggle.
	shapeshift_type = /mob/living/simple_animal/hostile/heretic_summon/armsy
	possible_shapes = list(/mob/living/simple_animal/hostile/heretic_summon/armsy)

	/// The length of our new wormy when we shed.
	var/segment_length = 10
	/// The radius around us that we cause brain damage / sanity damage to.
	var/scare_radius = 9


/obj/effect/proc_holder/spell/shapeshift/shed_human_form/Shapeshift(mob/living/caster)
	// When we transform into the worm, everyone nearby gets freaked out
	for(var/mob/living/carbon/human/nearby_human in view(scare_radius, caster))
		if(IS_HERETIC_OR_MONSTER(nearby_human) || nearby_human == caster)
			continue

		// 25% chance to cause a trauma
		if(!prob(25))
			continue

		//var/datum/brain_trauma/trauma = pick(subtypesof(BRAIN_TRAUMA_MILD) + subtypesof(BRAIN_TRAUMA_SEVERE))
		//nearby_human.gain_trauma(trauma, TRAUMA_RESILIENCE_LOBOTOMY)
		nearby_human.adjustBrainLoss(50)
		nearby_human.Hallucinate(300 SECONDS)

	. = ..()

	// TG 1:1: while shed into the worm, the ONLY ability is "return to your old form". master220's
	// mind.transfer_to (called by the base Shapeshift) re-grants EVERY heretic spell to the new body,
	// which would litter the worm with useless human-only spell buttons. Strip them off the worm — they
	// stay on the mind and are re-granted automatically (transfer_mindbound_actions) when we Restore.
	var/mob/living/worm = caster.loc
	if(istype(worm) && worm.mind)
		for(var/obj/effect/proc_holder/spell/spell as anything in worm.mind.spell_list)
			if(spell == src || !spell.action)
				continue
			spell.action.Remove(worm)


/obj/effect/proc_holder/spell/shapeshift/shed_human_form/Restore(mob/living/simple_animal/hostile/heretic_summon/armsy/caster)
	if(istype(caster))
		segment_length = caster.get_length() - 1 // Don't count the head

	return ..()


/obj/effect/proc_holder/spell/shapeshift/shed_human_form/create_shapeshift_mob(atom/loc)
	return new shapeshift_type(loc, TRUE, segment_length)
