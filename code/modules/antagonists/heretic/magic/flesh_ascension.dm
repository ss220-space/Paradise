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
	// TG 1:1: the shed/return toggle shares a single 10s cooldown (master220's shapeshift base is 20s).
	base_cooldown = 10 SECONDS

	//convert_damage = FALSE // Functionally meaningless on Armsy, we track how many segments it had instead
	// Only one possible form, so fix it up-front (TG auto-picks for a single shape) — no pointless
	// one-option "choose your form" popup, and the button is a clean become-worm / return-to-human toggle.
	shapeshift_type = /mob/living/simple_animal/hostile/heretic_summon/armsy
	possible_shapes = list(/mob/living/simple_animal/hostile/heretic_summon/armsy)

	/// The length of our new wormy when we shed.
	var/segment_length = 10
	/// The radius around us that we cause brain damage / sanity damage to.
	var/scare_radius = 9


// Robust toggle (TG 1:1): the base spell decides shed-vs-return via `M in current_shapes`, which can
// desync — if it ever thinks the worm isn't a tracked shape it tries to Shapeshift again and the godmode
// "already shapeshifted" guard silently eats the cast, so the button looks dead and you're stuck as the
// worm. Decide off the actual body type instead: a Lord of Night always shrinks back, anything else sheds.
/obj/effect/proc_holder/spell/shapeshift/shed_human_form/cast(list/targets, mob/user = usr)
	for(var/mob/living/caster in targets)
		if(istype(caster, /mob/living/simple_animal/hostile/heretic_summon/armsy))
			Restore(caster)
		else
			Shapeshift(caster)


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

		// Hide the heretic's visible eldritch aura while we're the worm — apply_innate_effects() re-drew it
		// on the new body during the mind transfer above. The trait makes should_show_aura() return FALSE,
		// and the SIGNAL_ADDTRAIT hook refreshes the worm's overlays to clear it now. It returns on its own
		// when we Restore: the worm is gibbed and apply_innate_effects() redraws the aura on the human.
		ADD_TRAIT(worm, TRAIT_HERETIC_AURA_HIDDEN, HERETIC_TRAIT)


/obj/effect/proc_holder/spell/shapeshift/shed_human_form/Restore(mob/living/simple_animal/hostile/heretic_summon/armsy/shape)
	if(istype(shape))
		segment_length = shape.get_length() - 1 // Don't count the head

		// Belt-and-suspenders: base Restore() bails unless the shape is in current_shapes and the trapped
		// caster is in current_casters. If those lists ever desynced we'd be unable to shrink back, so
		// rebuild them from the worm itself (the caster is the mob inside carrying our godmode trait).
		if(!(shape in current_shapes))
			current_shapes |= shape
		for(var/mob/living/trapped in shape)
			if(HAS_TRAIT_FROM(trapped, TRAIT_GODMODE, UNIQUE_TRAIT_SOURCE(src)))
				current_casters |= trapped
				break

	return ..()


/obj/effect/proc_holder/spell/shapeshift/shed_human_form/create_shapeshift_mob(atom/loc)
	return new shapeshift_type(loc, TRUE, segment_length)
