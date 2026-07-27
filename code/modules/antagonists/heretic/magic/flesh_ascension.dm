/obj/effect/proc_holder/spell/shapeshift/shed_human_form
	name = "Сброс Старой Оболочки"
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
	base_cooldown = 10 SECONDS

	shapeshift_type = /mob/living/simple_animal/hostile/heretic_summon/armsy
	possible_shapes = list(/mob/living/simple_animal/hostile/heretic_summon/armsy)

	/// The length of our new wormy when we shed.
	var/segment_length = 10
	/// The radius around us that we cause brain damage / sanity damage to.
	var/scare_radius = 9


/obj/effect/proc_holder/spell/shapeshift/shed_human_form/cast(list/targets, mob/user = usr)
	for(var/mob/living/caster in targets)
		if(istype(caster, /mob/living/simple_animal/hostile/heretic_summon/armsy))
			Restore(caster)
		else
			Shapeshift(caster)


/obj/effect/proc_holder/spell/shapeshift/shed_human_form/Shapeshift(mob/living/caster)
	for(var/mob/living/carbon/human/nearby_human in view(scare_radius, caster))
		if(IS_HERETIC_OR_MONSTER(nearby_human) || nearby_human == caster)
			continue

		if(!prob(25))
			continue

		nearby_human.adjustBrainLoss(50)
		nearby_human.Hallucinate(300 SECONDS)

	. = ..()

	var/mob/living/worm = caster.loc
	if(istype(worm) && worm.mind)
		for(var/obj/effect/proc_holder/spell/spell as anything in worm.mind.spell_list)
			if(spell == src || !spell.action)
				continue
			spell.action.Remove(worm)

		src.action?.Grant(worm)

		ADD_TRAIT(worm, TRAIT_HERETIC_AURA_HIDDEN, HERETIC_TRAIT)

		worm.update_action_buttons(reload_screen = TRUE)


/obj/effect/proc_holder/spell/shapeshift/shed_human_form/Restore(mob/living/simple_animal/hostile/heretic_summon/armsy/shape)
	var/mob/living/trapped_caster
	if(istype(shape))
		segment_length = shape.get_length() - 1 // Don't count the head

		if(!(shape in current_shapes))
			current_shapes |= shape
		for(var/mob/living/trapped in shape)
			if(HAS_TRAIT_FROM(trapped, TRAIT_GODMODE, UNIQUE_TRAIT_SOURCE(src)))
				current_casters |= trapped
				trapped_caster = trapped
				break

	. = ..() // base transfers the mind back to the human and gibs the worm

	if(!QDELETED(trapped_caster) && trapped_caster.mind)
		var/datum/antagonist/heretic/our_heretic = GET_HERETIC(trapped_caster)
		our_heretic?.resync_knowledge_spells(trapped_caster)
		for(var/obj/effect/proc_holder/spell/spell as anything in trapped_caster.mind.spell_list)
			spell.action?.Grant(trapped_caster)
		trapped_caster.update_action_buttons(reload_screen = TRUE)


/obj/effect/proc_holder/spell/shapeshift/shed_human_form/create_shapeshift_mob(atom/loc)
	return new shapeshift_type(loc, TRUE, segment_length)
