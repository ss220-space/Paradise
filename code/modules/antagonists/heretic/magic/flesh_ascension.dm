/datum/action/cooldown/spell/shapeshift/shed_human_form
	name = "Сброс Старой Оболочки"
	desc = "Сбросьте свою хрупкую оболочку, станьте единым с руками, стань единым с Императором. \
			Вызывает серьёзные повреждения мозга и потерю рассудка у находящихся рядом смертных."
	background_icon = 'icons/mob/actions/backgrounds.dmi'
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "worm_ascend"

	school = SCHOOL_FORBIDDEN
	invocation = "ДА РАСКРОЕТСЯ РЕАЛЬНОСТЬ!"
	spell_requirements = NONE

	shapeshift_type = /mob/living/simple_animal/hostile/heretic_summon/armsy
	possible_shapes = list(/mob/living/simple_animal/hostile/heretic_summon/armsy)

	/// The length of our new wormy when we shed.
	var/segment_length = 10
	/// The radius around us that we cause brain damage / sanity damage to.
	var/scare_radius = 9


/datum/action/cooldown/spell/shapeshift/shed_human_form/do_shapeshift(mob/living/caster)
	for(var/mob/living/carbon/human/nearby_human in view(scare_radius, caster))
		if(IS_HERETIC_OR_MONSTER(nearby_human) || nearby_human == caster)
			continue

		if(!prob(25))
			continue

		nearby_human.adjustBrainLoss(50)
		nearby_human.Hallucinate(300 SECONDS)

	var/mob/living/worm = ..()
	if(QDELETED(worm) || !worm.mind)
		return worm

	for(var/datum/action/cooldown/spell/spell as anything in worm.mind.spell_list)
		if(spell == src)
			continue
		spell.Remove(worm)

	Grant(worm)
	ADD_TRAIT(worm, TRAIT_HERETIC_AURA_HIDDEN, HERETIC_TRAIT)
	worm.update_action_buttons(reload_screen = TRUE)
	return worm


/datum/action/cooldown/spell/shapeshift/shed_human_form/do_unshapeshift(mob/living/caster)
	var/mob/living/simple_animal/hostile/heretic_summon/armsy/shape = caster
	if(istype(shape))
		segment_length = shape.get_length() - 1 // Don't count the head

	var/mob/living/trapped_caster = ..()
	if(QDELETED(trapped_caster) || !trapped_caster.mind)
		return trapped_caster

	var/datum/antagonist/heretic/our_heretic = GET_HERETIC(trapped_caster)
	our_heretic?.resync_knowledge_spells(trapped_caster)
	for(var/datum/action/cooldown/spell/spell as anything in trapped_caster.mind.spell_list)
		spell.Grant(trapped_caster)
	trapped_caster.update_action_buttons(reload_screen = TRUE)
	return trapped_caster


/datum/action/cooldown/spell/shapeshift/shed_human_form/create_shapeshift_mob(atom/loc)
	return new shapeshift_type(loc, TRUE, segment_length)
