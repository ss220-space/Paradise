/obj/effect/proc_holder/spell/shapeshift/eldritch/ascension
	name = "Высший Полиморфизм"
	desc = "Заклинание, позволяющее вам принять облик другого сверхъестественного \
			существа, приобретая его способности. Вы можете изменить свой выбор в \
			любой момент, и если ваша форма умрёт, вы не умрёте."
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "lock_ascension"
	possible_shapes = list(
		/mob/living/simple_animal/hostile/heretic_summon/ash_spirit,
		/mob/living/simple_animal/hostile/heretic_summon/raw_prophet/ascended,
		/mob/living/simple_animal/hostile/heretic_summon/rust_walker,
		/mob/living/simple_animal/hostile/heretic_summon/stalker,
	)


/obj/effect/proc_holder/spell/shapeshift/eldritch/ascension/cast(list/targets, mob/user = usr)
	for(var/mob/living/caster in targets)
		if(caster in current_shapes)
			Restore(caster)
			continue

		if(!shapeshift_type)
			shapeshift_type = pick_eldritch_form(caster)
			if(!shapeshift_type) // menu was closed without a pick - refund the cooldown perform() already started
				revert_cast(caster)
				return

		Shapeshift(caster)


/// Builds a radial menu of possible_shapes, keyed by name, each slice showing that monster's on-map sprite.
/obj/effect/proc_holder/spell/shapeshift/eldritch/ascension/proc/pick_eldritch_form(mob/living/caster)
	var/list/shape_names_to_types = list()
	var/list/shape_names_to_image = list()
	for(var/mob/living/path as anything in possible_shapes)
		var/shape_name = initial(path.name)
		shape_names_to_types[shape_name] = path
		shape_names_to_image[shape_name] = image(icon = initial(path.icon), icon_state = initial(path.icon_state))

	var/picked = show_radial_menu(
		caster,
		caster,
		shape_names_to_image,
		radius = 38,
		custom_check = CALLBACK(src, PROC_REF(check_menu), caster),
	)
	if(!picked)
		return null
	return shape_names_to_types[picked]


/// Radial keep-open check: bail if the caster can no longer act.
/obj/effect/proc_holder/spell/shapeshift/eldritch/ascension/proc/check_menu(mob/living/caster)
	if(QDELETED(caster))
		return FALSE
	return !caster.incapacitated()


/obj/effect/proc_holder/spell/shapeshift/eldritch/ascension/Shapeshift(mob/living/caster)
	. = ..()
	if(!.)
		return

	var/mob/living/simple_animal/monster = .

	if(monster.mind)
		for(var/obj/effect/proc_holder/spell/spell as anything in monster.mind.spell_list)
			if(spell == src || !spell.action)
				continue
			spell.action.Remove(monster)
		src.action?.Grant(monster)

	playsound(caster, 'sound/magic/demon_consume.ogg', 50, TRUE)
	monster.AddComponent(/datum/component/seethrough_mob) // adds the (kept) "Видеть сквозь себя" toggle
	monster.maxHealth *= 1.5
	monster.health = monster.maxHealth
	monster.melee_damage_lower = max((monster.melee_damage_lower * 2), 40)
	monster.melee_damage_upper = monster.melee_damage_upper / 2
	monster.transform *= 1.5
	monster.AddElement(/datum/element/wall_tearer)

	monster.update_action_buttons(reload_screen = TRUE)


/obj/effect/proc_holder/spell/shapeshift/eldritch/ascension/Restore(mob/living/shape)
	var/mob/living/trapped_caster
	if(!(shape in current_shapes))
		current_shapes |= shape
	for(var/mob/living/trapped in shape)
		if(HAS_TRAIT_FROM(trapped, TRAIT_GODMODE, UNIQUE_TRAIT_SOURCE(src)))
			current_casters |= trapped
			trapped_caster = trapped
			break

	. = ..()
	shapeshift_type = null

	if(!QDELETED(trapped_caster) && trapped_caster.mind)
		trapped_caster.mind.RemoveSpell(/obj/effect/proc_holder/spell/toggle_seethrough)
		var/datum/antagonist/heretic/our_heretic = GET_HERETIC(trapped_caster)
		our_heretic?.resync_knowledge_spells(trapped_caster)
		for(var/obj/effect/proc_holder/spell/spell as anything in trapped_caster.mind.spell_list)
			spell.action?.Grant(trapped_caster)
		trapped_caster.update_action_buttons(reload_screen = TRUE)
