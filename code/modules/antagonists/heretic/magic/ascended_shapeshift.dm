// Given to ascended knock heretics, is a form of shapeshift that can turn into all 4 common heretic summons, and is not limited to 1 selection.
/obj/effect/proc_holder/spell/shapeshift/eldritch/ascension
	name = "Высший полиморфизм"
	desc = "Заклинание, позволяющее вам принять облик другого сверхъестественного \
			существа, приобретая его способности. Вы можете изменить свой выбор в \
			любой момент, и если ваша форма умрёт, вы не умрёте."
	//convert_damage = FALSE
	//die_with_shapeshifted_form = FALSE
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "lock_ascension"
	possible_shapes = list(
		/mob/living/simple_animal/hostile/heretic_summon/ash_spirit,
		/mob/living/simple_animal/hostile/heretic_summon/raw_prophet/ascended,
		/mob/living/simple_animal/hostile/heretic_summon/rust_walker,
		/mob/living/simple_animal/hostile/heretic_summon/stalker,
	)


// TG presents the four forms in a radial menu showing each monster's sprite (its before_cast()), instead of
// master220's base shapeshift text dropdown (tgui_input_list). We override cast() to replicate that flow 1:1:
// revert if already shifted, otherwise pop the radial and shift into the picked form.
/obj/effect/proc_holder/spell/shapeshift/eldritch/ascension/cast(list/targets, mob/user = usr)
	for(var/mob/living/caster in targets)
		// Already one of the forms -> revert (TG do_unshapeshift). The previous Restore cleared shapeshift_type,
		// so we never re-prompt for a form when reverting.
		if(caster in current_shapes)
			Restore(caster)
			continue

		if(!shapeshift_type)
			shapeshift_type = pick_eldritch_form(caster)
			if(!shapeshift_type) // menu was closed without a pick - refund the cooldown perform() already started
				revert_cast(caster)
				return

		Shapeshift(caster)


/// Builds a radial menu of possible_shapes - keyed by name, each slice showing that monster's on-map sprite -
/// mirroring TG's /datum/action/cooldown/spell/shapeshift before_cast() radial selection.
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


/// Radial keep-open check (TG's check_menu): bail if the caster can no longer act.
/obj/effect/proc_holder/spell/shapeshift/eldritch/ascension/proc/check_menu(mob/living/caster)
	if(QDELETED(caster))
		return FALSE
	return !caster.incapacitated()


/obj/effect/proc_holder/spell/shapeshift/eldritch/ascension/Shapeshift(mob/living/caster)
	. = ..()
	if(!.)
		return

	var/mob/living/simple_animal/monster = .

	// TG 1:1 (same as the flesh worm): mind.transfer_to re-granted EVERY heretic spell to the monster,
	// littering it with useless human-only spell buttons. Strip them off the form FIRST - they stay on the
	// mind and come back on Restore. Done before the seethrough hookup below so that toggle (a real FORM
	// ability TG keeps) is granted afterwards and survives. The monster keeps its own innate combat abilities
	// (mob_spell_list, untouched) + this ascension toggle (skipped below) so it can shift again / revert.
	if(monster.mind)
		for(var/obj/effect/proc_holder/spell/spell as anything in monster.mind.spell_list)
			if(spell == src || !spell.action)
				continue
			spell.action.Remove(monster)
		// Insurance: guarantee the revert toggle is on the form (the only way back to human shape).
		src.action?.Grant(monster)

	//buff our forms so this ascension ability isnt shit
	playsound(caster, 'sound/magic/demon_consume.ogg', 50, TRUE)
	monster.AddComponent(/datum/component/seethrough_mob) // adds the (kept) "Видеть сквозь себя" toggle
	monster.maxHealth *= 1.5
	monster.health = monster.maxHealth
	monster.melee_damage_lower = max((monster.melee_damage_lower * 2), 40)
	monster.melee_damage_upper = monster.melee_damage_upper / 2
	monster.transform *= 1.5
	monster.AddElement(/datum/element/wall_tearer)

	// Same client-timing reason as Restore: make sure the form's buttons (revert + seethrough + innate) draw.
	monster.update_action_buttons(reload_screen = TRUE)


/obj/effect/proc_holder/spell/shapeshift/eldritch/ascension/Restore(mob/living/shape)
	// Hold onto the human trapped inside the form so we can re-arm their spell buttons after the base transfer
	// pulls them back out - mirroring the flesh worm fix. Without this the heretic returns to human form with
	// NO spell buttons (transfer_mindbound_actions is supposed to re-grant them but doesn't reliably here).
	var/mob/living/trapped_caster
	// Belt-and-suspenders: base Restore() bails unless the shape is in current_shapes and the trapped caster is
	// in current_casters. If those lists desynced we'd lose the mind transfer back AND every ability, which is
	// exactly the "return from the ash spirit eats all my spells" report. Rebuild them from the form itself.
	if(!(shape in current_shapes))
		current_shapes |= shape
	for(var/mob/living/trapped in shape)
		if(HAS_TRAIT_FROM(trapped, TRAIT_GODMODE, UNIQUE_TRAIT_SOURCE(src)))
			current_casters |= trapped
			trapped_caster = trapped
			break

	. = ..()
	shapeshift_type = null //pick another loser

	if(!QDELETED(trapped_caster) && trapped_caster.mind)
		// The seethrough_mob component AddSpell'd its toggle onto the shared mind; it's a form-only ability
		// (and would otherwise duplicate every shift), so drop it from the human on the way back.
		trapped_caster.mind.RemoveSpell(/obj/effect/proc_holder/spell/toggle_seethrough)
		// Re-add any knowledge spell that went missing (a duplicate/dead-action spell pruned during the
		// transfer would otherwise be gone for good - this is why returning from a form bled Lock abilities).
		var/datum/antagonist/heretic/our_heretic = trapped_caster.mind.has_antag_datum(/datum/antagonist/heretic)
		our_heretic?.resync_knowledge_spells(trapped_caster)
		for(var/obj/effect/proc_holder/spell/spell as anything in trapped_caster.mind.spell_list)
			spell.action?.Grant(trapped_caster)
		// CRUCIAL: mind.transfer_to() grants the spell actions BEFORE possess_by_player() re-attaches the
		// client, so GiveAction() had no client.screen to draw onto and the buttons silently never appeared
		// (only some abilities came back). A full rebuild re-shows every granted action now the client is back.
		trapped_caster.update_action_buttons(reload_screen = TRUE)
