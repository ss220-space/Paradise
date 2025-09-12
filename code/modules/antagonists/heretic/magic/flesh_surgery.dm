/obj/effect/proc_holder/spell/touch/flesh_surgery
	name = "Управление плотью"
	desc = "Заклинание позволяющее касанием собирать или восстанавливать плоть цели. \
			Извлекает органы жертвы без необходимости проводить \
			операцию или потрошить её. При применении к призванным существам \
			или миньонам восстанавливает им здоровье. Также может использоваться для лечения \
			повреждённых органов."
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "mad_touch"
	sound = null

	school = SCHOOL_FORBIDDEN
	human_req = FALSE
	clothes_req = FALSE
	base_cooldown = 20 SECONDS
	invocation = "МН Н'ЖН ТВ Р'К С'РДЦ!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE

	hand_path = /obj/item/melee/touch_attack/flesh_surgery
	//can_cast_on_self = TRUE


/obj/effect/proc_holder/spell/touch/flesh_surgery/valid_target(atom/cast_on)
	return isliving(cast_on) || isorgan(cast_on)


/obj/item/melee/touch_attack/flesh_surgery/afterattack(atom/victim, mob/living/carbon/caster, proximity, params)
	if(!proximity)
		return FALSE

	var/obj/effect/proc_holder/spell/touch/flesh_surgery/spell = attached_spell
	if(isorgan(victim))
		heal_organ(src, victim, caster)
		return

	if(!isliving(victim))
		return FALSE

	var/mob/living/mob_victim = victim
	if(mob_victim.stat != DEAD && HAS_TRAIT(victim, TRAIT_HERETIC_SUMMON))
		heal_heretic_monster(victim, caster)
		return

	return spell.steal_organ_from_mob(src, victim, caster)


/*
/obj/effect/proc_holder/spell/touch/flesh_surgery/register_hand_signals()
	. = ..()
	RegisterSignal(attached_hand, COMSIG_ITEM_REQUESTING_CONTEXT_FOR_TARGET, PROC_REF(add_item_context))
	attached_hand.item_flags |= ITEM_HAS_CONTEXTUAL_SCREENTIPS

/obj/effect/proc_holder/spell/touch/flesh_surgery/unregister_hand_signals()
	. = ..()
	UnregisterSignal(attached_hand, COMSIG_ITEM_REQUESTING_CONTEXT_FOR_TARGET)
*/
/*
/// Signal proc for [COMSIG_ITEM_REQUESTING_CONTEXT_FOR_TARGET] to add some context to the hand.
/obj/effect/proc_holder/spell/touch/flesh_surgery/proc/add_item_context(obj/item/melee/touch_attack/source, list/context, atom/victim, mob/living/user)
	SIGNAL_HANDLER

	. = NONE

	if(isliving(victim))
		var/mob/living/mob_victim = victim

		if(iscarbon(mob_victim))
			context[SCREENTIP_CONTEXT_LMB] = "Extract organ"
			. = CONTEXTUAL_SCREENTIP_SET

		if(HAS_TRAIT(mob_victim, TRAIT_HERETIC_SUMMON))
			context[SCREENTIP_CONTEXT_RMB] = "Heal [ishuman(mob_victim) ? "minion" : "summon"]"
			. = CONTEXTUAL_SCREENTIP_SET

	else if(isorgan(victim))
		context[SCREENTIP_CONTEXT_LMB] = "Heal organ"
		. = CONTEXTUAL_SCREENTIP_SET

	return .
*/

/// If cast on an organ, we'll restore its health and even un-fail it.
/obj/item/melee/touch_attack/flesh_surgery/proc/heal_organ(obj/item/melee/touch_attack/hand, obj/item/organ/to_heal, mob/living/carbon/caster)
	if(to_heal.damage == 0)
		to_heal.balloon_alert(caster, "не нужно лечение!")
		return FALSE

	to_heal.balloon_alert(caster, "исцеление...")
	if(!do_after(caster, 1 SECONDS, to_heal, extra_checks = CALLBACK(src, PROC_REF(heal_checks), hand, to_heal, caster)))
		to_heal.balloon_alert(caster, "прервано!")
		return FALSE

	var/organ_hp_to_heal = to_heal.max_damage * organ_percent_healing
	to_heal.set_organ_damage(max(0 , to_heal.damage - organ_hp_to_heal))
	to_heal.balloon_alert(caster, "орган исцелен")
	playsound(to_heal, 'sound/magic/staff_healing.ogg', 30)
	new /obj/effect/temp_visual/cult/sparks(get_turf(to_heal))
	caster.visible_message(
		span_warning("Рука [caster.declent_ru(GENITIVE)] светится брильянтово красным когда он[genderize_ru(caster.gender, "", "а", "о", "и")] каса[pluralize_ru(caster.gender, "е", "ю")]тся [to_heal.declent_ru(GENITIVE)]!"),
		span_notice("Ваша рука светится брильянтово красным когда вы касаетесь [to_heal.declent_ru(GENITIVE)]!"),
	)

	return TRUE


/// If cast on a heretic monster who's not dead we'll heal it a bit.
/obj/item/melee/touch_attack/flesh_surgery/proc/heal_heretic_monster(mob/living/to_heal, mob/living/carbon/caster)
	to_heal.balloon_alert(caster, "исцеление [ishuman(to_heal) ? "раба" : "призванного существа"]...")
	if(!do_after(caster, 1 SECONDS, to_heal, extra_checks = CALLBACK(src, PROC_REF(heal_checks), src, to_heal, caster)))
		to_heal.balloon_alert(caster, "прервано!")
		return FALSE

	// Keep in mind that, for simplemobs(summons), this will just flat heal the combined value of both brute and burn healing,
	// while for human minions(ghouls), this will heal brute and burn like normal. So be careful adjusting to bigger numbers
	to_heal.balloon_alert(caster, ishuman(to_heal) ? "раб исцелён" : "призванное существо исцелено")
	to_heal.heal_overall_damage(monster_brute_healing, monster_burn_healing)
	playsound(to_heal, 'sound/magic/staff_healing.ogg', 30)
	new /obj/effect/temp_visual/cult/sparks(get_turf(to_heal))
	caster.visible_message(
		span_warning("Рука [caster.declent_ru(GENITIVE)] светится брильянтово красным когда он[genderize_ru(caster.gender, "", "а", "о", "и")] каса[pluralize_ru(caster.gender, "е", "ю")]тся [to_heal.declent_ru(GENITIVE)]!"),
		span_notice("Ваша рука светится брильянтово красным когда вы касаетесь [to_heal.declent_ru(GENITIVE)]!"),
	)
	return TRUE


/// If cast on a carbon, we'll try to steal one of their organs directly from their person.
/obj/effect/proc_holder/spell/touch/flesh_surgery/proc/steal_organ_from_mob(obj/item/melee/touch_attack/hand, mob/living/victim, mob/living/carbon/caster)
	var/mob/living/carbon/carbon_victim = victim
	if(!istype(carbon_victim) || !length(carbon_victim.internal_organs))
		victim.balloon_alert(caster, "нет органов!")
		return FALSE

	if(get_dist(caster, victim) > 1)
		caster.balloon_alert(caster, "слишком далеко!")
		return FALSE

	var/zone_to_check = check_zone(caster.zone_selected)

	var/list/organs_we_can_remove = list()
	for(var/obj/item/organ/organ as anything in carbon_victim.internal_organs)
		// Only show organs which are in our generic zone
		if(organ.parent_organ_zone != zone_to_check)
			continue
		// Also, some organs to exclude. Don't remove vital (brains), don't remove synthetics, and don't remove unremovable
		//if(organ.status & (ORGAN_ROBOT|ORGAN_VITAL|ORGAN_UNREMOVABLE))
		//	continue

		organs_we_can_remove[organ.name] = organ

	if(!length(organs_we_can_remove))
		victim.balloon_alert(caster, "нет органов!")
		return FALSE

	var/chosen_organ = tgui_input_list(caster, "Какой орган вы хотите извлечь?", name, sort_list(organs_we_can_remove))
	if(isnull(chosen_organ))
		return FALSE


	var/obj/item/organ/picked_organ = organs_we_can_remove[chosen_organ]
	if(picked_organ.owner != victim)
		caster.balloon_alert(caster, "орган уже извлечён!")
		return FALSE

	if(!istype(picked_organ) || !extraction_checks(picked_organ, hand, victim, caster))
		return FALSE

	// Don't let people stam crit into steal heart true combo
	var/time_it_takes = carbon_victim.stat == DEAD ? 3 SECONDS : 15 SECONDS

	// Sure you can remove your own organs, fun party trick
	if(carbon_victim == caster)
		var/are_you_sure = tgui_alert(caster, "Вы уверены что хотите извлечь сво[genderize_ru(picked_organ.gender, "й", "ю", "ё", "и")] [picked_organ.declent_ru(ACCUSATIVE)]?", "Вы уверены?", list("Да", "Нет"))
		if(are_you_sure != "Да" || !extraction_checks(picked_organ, hand, victim, caster))
			return FALSE

		time_it_takes = 6 SECONDS
		caster.visible_message(
			span_warning("Рука [caster.declent_ru(GENITIVE)] светится брильянтово красным когда он[genderize_ru(caster.gender, "", "а", "о", "и")] погружа[pluralize_ru(caster.gender, "е", "ю")]т её в своё тело!"),
			span_notice("Ваша рука светится брильянтово красным когда вы погружаете её в своё тело!"),
		)

	else
		caster.visible_message(
			span_warning("Рука [caster.declent_ru(GENITIVE)] светится брильянтово красным когда он[genderize_ru(caster.gender, "", "а", "о", "и")] погружа[pluralize_ru(caster.gender, "е", "ю")]т её в тело [carbon_victim.declent_ru(ACCUSATIVE)]!"),
			span_notice("Ваша рука светится брильянтово красным когда вы погружаете её в тело [carbon_victim.declent_ru(ACCUSATIVE)]!"),
		)

	carbon_victim.balloon_alert(caster, "извлечение [picked_organ.declent_ru(GENITIVE)]...")
	playsound(victim, 'sound/weapons/slice.ogg', 50, TRUE)
	carbon_victim.add_atom_colour(COLOR_DARK_RED, TEMPORARY_COLOUR_PRIORITY)
	if(!do_after(caster, time_it_takes, carbon_victim, extra_checks = CALLBACK(src, PROC_REF(extraction_checks), picked_organ, hand, victim, caster)))
		carbon_victim.balloon_alert(caster, "прервано!")
		carbon_victim.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, COLOR_DARK_RED)
		return FALSE

	// Visible message done before Remove()
	// Mainly so it gets across if you're taking the eyes of someone who's conscious
	if(carbon_victim == caster)
		caster.visible_message(
			span_bolddanger("[caster.declent_ru(NOMINATIVE)] извлека[pluralize_ru(caster.gender, "ет", "ют")] [picked_organ.declent_ru(ACCUSATIVE)] из своего тела!"),
			span_bolddanger("Вы извлекаете [picked_organ.declent_ru(ACCUSATIVE)] из своего тела!"),
		)

	else
		carbon_victim.visible_message(
			span_bolddanger("[caster.declent_ru(NOMINATIVE)] извлека[pluralize_ru(caster.gender, "ет", "ют")] [picked_organ.declent_ru(ACCUSATIVE)] из тела [carbon_victim.declent_ru(GENITIVE)]!"),
			span_bolddanger("Вы извлекаете [picked_organ.declent_ru(ACCUSATIVE)] из тела [carbon_victim.declent_ru(GENITIVE)]!"),
		)

	var/cant = FALSE
	if(picked_organ.owner != victim)
		caster.balloon_alert(caster, "орган уже извлечён!")
		cant = TRUE
	else
		picked_organ.remove(victim)
		carbon_victim.balloon_alert(caster, "[picked_organ.declent_ru(NOMINATIVE)] ")

	carbon_victim.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, COLOR_DARK_RED)
	if(cant)
		return FALSE

	playsound(victim, 'sound/effects/dismember.ogg', 50, TRUE)
	if(carbon_victim.stat == CONSCIOUS)
		carbon_victim.apply_status_effect(/*/datum/status_effect/speech/slurring/heretic*/ STATUS_EFFECT_CLOCK_CULT_SLUR, 15 SECONDS)
		carbon_victim.emote("scream")

	// We need to wait for the spell to actually finish casting to put the organ in their hands, hence, 1 ms timer.
	addtimer(CALLBACK(caster, TYPE_PROC_REF(/mob, put_in_hands), picked_organ), 0.1 SECONDS)
	return TRUE


/// Extra checks ran while we're extracting an organ to make sure we can continue to do.
/obj/effect/proc_holder/spell/touch/flesh_surgery/proc/extraction_checks(obj/item/organ/picked_organ, obj/item/melee/touch_attack/hand, mob/living/carbon/victim, mob/living/carbon/caster)
	if(QDELETED(src) || QDELETED(hand) || QDELETED(picked_organ) || QDELETED(victim))
		return FALSE

	return TRUE


/// Extra checks ran while we're healing something (organ, mob).
/obj/item/melee/touch_attack/flesh_surgery/proc/heal_checks(obj/item/melee/touch_attack/hand, atom/healing, mob/living/carbon/caster)
	if(QDELETED(src) || QDELETED(hand) || QDELETED(healing))
		return FALSE

	return TRUE


/obj/item/melee/touch_attack/flesh_surgery
	name = "рука покрытая плотью"
	desc = "Лечить не так приятно, как убивать." // TF2
	icon = 'icons/obj/weapons/hand.dmi'
	icon_state = "disintegrate"
	item_state = "disintegrate"

	/// If used on an organ, how much percent of the organ's HP do we restore
	var/organ_percent_healing = 0.5
	/// If used on a heretic mob, how much brute do we heal
	var/monster_brute_healing = 10
	/// If used on a heretic mob, how much burn do we heal
	var/monster_burn_healing = 5


/obj/item/melee/touch_attack/flesh_surgery/get_ru_names()
	return list(
		NOMINATIVE = "рука покрытая плотью",
		GENITIVE = "руки покрытой плотью",
		DATIVE = "руке покрытой плотью",
		ACCUSATIVE = "руку покрытую плотью",
		INSTRUMENTAL = "рукой покрытой плотью",
		PREPOSITIONAL = "руке покрытой плотью",
	)
