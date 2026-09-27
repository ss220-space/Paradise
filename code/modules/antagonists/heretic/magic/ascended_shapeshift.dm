/datum/action/cooldown/spell/shapeshift/eldritch/ascension
	name = "Высший Полиморфизм"
	desc = "Заклинание, позволяющее вам принять облик другого сверхъестественного \
			существа, приобретая его способности. Вы можете изменить свой выбор в \
			любой момент, и если ваша форма умрёт, вы не умрёте."
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "lock_ascension"
	possible_shapes = list(
		/mob/living/simple_animal/hostile/heretic_summon/ash_spirit,
		/mob/living/simple_animal/hostile/heretic_summon/raw_prophet/ascended,
		/mob/living/simple_animal/hostile/heretic_summon/rust_walker,
		/mob/living/simple_animal/hostile/heretic_summon/stalker,
	)


/datum/action/cooldown/spell/shapeshift/eldritch/ascension/do_shapeshift(mob/living/caster)
	var/mob/living/simple_animal/monster = ..()
	if(!monster)
		return monster

	if(monster.mind)
		for(var/datum/action/cooldown/spell/spell as anything in monster.mind.spell_list)
			if(spell == src)
				continue
			spell.Remove(monster)
		Grant(monster)

	playsound(caster, 'sound/magic/demon_consume.ogg', 50, TRUE)
	monster.AddComponent(/datum/component/seethrough_mob)
	monster.maxHealth *= 1.5
	monster.health = monster.maxHealth
	monster.melee_damage_lower = max((monster.melee_damage_lower * 2), 40)
	monster.melee_damage_upper = monster.melee_damage_upper / 2
	monster.transform *= 1.5
	monster.AddElement(/datum/element/wall_tearer)

	monster.update_action_buttons(reload_screen = TRUE)
	return monster


/datum/action/cooldown/spell/shapeshift/eldritch/ascension/do_unshapeshift(mob/living/caster)
	var/mob/living/trapped_caster = ..()
	shapeshift_type = null

	if(QDELETED(trapped_caster) || !trapped_caster.mind)
		return trapped_caster

	trapped_caster.mind.RemoveSpell(/datum/action/cooldown/spell/toggle_seethrough)
	var/datum/antagonist/heretic/our_heretic = GET_HERETIC(trapped_caster)
	our_heretic?.resync_knowledge_spells(trapped_caster)
	for(var/datum/action/cooldown/spell/spell as anything in trapped_caster.mind.spell_list)
		spell.Grant(trapped_caster)
	trapped_caster.update_action_buttons(reload_screen = TRUE)
	return trapped_caster
