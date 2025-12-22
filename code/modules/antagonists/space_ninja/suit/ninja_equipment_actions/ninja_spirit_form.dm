/datum/action/item_action/advanced/ninja/ninja_spirit_form
	name = "Toggle Spirit Form"
	desc = "Переключает мощную экспериментальную технологию, которая трансформирует вас в более нестабильную форму. \
	Позволяет проходить почти сквозь всё, но требует значительного увеличения потребления энергии. \
	Все ограничивающие эффекты, такие как наручники, упадут с вас! \
	Помните, этот модуль всё ещё прототип и не сделает вас неуязвимым! Пассивно увеличивает потребление энергии костюма."
	check_flags = AB_CHECK_LYING|AB_CHECK_CONSCIOUS
	charge_type = ADV_ACTION_TYPE_TOGGLE_RECHARGE
	charge_max = 25 SECONDS
	button_icon_state = "ninja_spirit_form"
	button_icon = 'icons/mob/actions/actions_ninja.dmi'
	background_icon_state = "background_green"
	action_initialisation_text = "Spirit Form Prototype Module"

/**
 * Proc called to toggle spirit form.
 *
 * Proc called to toggle whether or not the ninja is in spirit form.
 * If cancelling, calls a separate proc in case something else needs to quickly cancel spirit form.
 */
/obj/item/clothing/suit/space/space_ninja/proc/toggle_spirit_form()
	var/mob/living/carbon/human/ninja = affecting
	if(!ninja)
		return
	if(!is_teleport_allowed(z))
		to_chat(ninja, span_warning("Это место каким-то образом принудительно стабилизирует ваше тело! Вы не можете использовать тут \"Духовную форму\"!"))
		return
	if(spirited)
		cancel_spirit_form()
	else
		if(cell.charge <= 0)
			balloon_alert(ninja, "недостаточно энергии!")
			return
		if(ninja.pulling && ninja.grab_state > GRAB_PASSIVE)
			ninja.stop_pulling()
		spirited = !spirited
		animate(ninja, color ="#00ff00", time = 6)
		if(!stealth)
			animate(ninja, alpha = NINJA_ALPHA_SPIRIT_FORM, time = 6) //Трогаем альфу — только если мы не в стелсе
			ninja.alpha_set(standartize_alpha(NINJA_ALPHA_SPIRIT_FORM), ALPHA_SOURCE_NINJA)
			ninja.visible_message(span_warning("[ninja.name] выглядит нестабильно!"), span_notice("Теперь вы можете пройти почти через все.")) //Если мы не в стелсе, пишем текст того, что видят другие
		else
			to_chat(ninja, span_notice("Теперь вы можете пройти почти через все."))	// Если же невидимы — пишем только себе
		ninja.pass_flags |= PASSEVERYTHING
		drop_restraints()
		for(var/datum/action/item_action/advanced/ninja/ninja_spirit_form/ninja_action in actions)
			ninja_action.use_action()
			ninja_action.action_ready = TRUE
			ninja_action.toggle_button_on_off()
			break

/**
 * Proc called to cancel spirit form.
 *
 * Called to cancel the spirit form effect if it is ongoing.
 * Does nothing otherwise.
 * Arguments:
 * * Returns false if either the ninja no longer exists or is already visible, returns true if we successfully made the ninja visible.
 */
/obj/item/clothing/suit/space/space_ninja/proc/cancel_spirit_form()
	var/mob/living/carbon/human/ninja = affecting
	if(!ninja)
		return FALSE
	if(spirited)
		spirited = !spirited
		animate(ninja, color = null, time = 6)
		if(!stealth)	//Не стоит трогать альфу, когда мы уже невидимы
			animate(ninja, alpha = NINJA_ALPHA_NORMAL, time = 6)
			ninja.alpha_set(standartize_alpha(NINJA_ALPHA_NORMAL), ALPHA_SOURCE_NINJA)
			ninja.visible_message(span_warning("[ninja.name] становится стабильным!"), span_notice("Вы теряете способность проходить сквозь материальные объекты...")) //Если мы не в стелсе, пишем текст того, что видят другие
		else
			to_chat(ninja, span_notice("Вы теряете способность проходить сквозь материальные объекты...")) // Если же невидимы — пишем только себе
		ninja.pass_flags = 0	//Отнимать этот флаг - "PASS_EVERYTHING" по нормальному он не хочет, значит сделаем полный сброс.
		for(var/datum/action/item_action/advanced/ninja/ninja_spirit_form/ninja_action in actions)
			ninja_action.action_ready = FALSE
			ninja_action.toggle_button_on_off()
		return TRUE
	return FALSE

/obj/item/clothing/suit/space/space_ninja/proc/drop_restraints()
	var/mob/living/carbon/human/ninja = affecting
	var/obj/restraint
	if(ninja.handcuffed)
		restraint = ninja.get_item_by_slot(ITEM_SLOT_HANDCUFFED)
		restraint.visible_message(span_warning("[restraint] падают сквозь руки [ninja] после того как он становится нестабильным!"))
	if(ninja.legcuffed)
		restraint = ninja.get_item_by_slot(ITEM_SLOT_LEGCUFFED)
		restraint.visible_message(span_warning("[restraint] падают сквозь руки [ninja] после того как он становится нестабильным!"))
	ninja.uncuff()
	if(istype(ninja.loc, /obj/structure/closet))
		var/obj/structure/closet/restraint_closet = ninja.loc
		if(!istype(restraint_closet))
			return FALSE
		ninja.forceMove(get_turf(restraint_closet))
		ninja.visible_message(span_warning("[ninja] проходит сквозь [restraint_closet] после того как он становится нестабильным!"))
