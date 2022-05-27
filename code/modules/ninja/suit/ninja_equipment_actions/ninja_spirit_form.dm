/datum/action/item_action/ninja_spirit_form
	check_flags = AB_CHECK_CONSCIOUS
	name = "Toggle Spirit Form"
	desc = "Toggles a powerfull experimental technology that transforms the user into a more unstable form. \
	Which allows passing almost through anything, at the cost of a big passive increase to energy consumption. \
	Also all restraining effects like handcuffs will drop off from you! \
	Remember that this module is still a prototipe and won't make you invincible! Passively encrease suit energy consumption."
	use_itemicon = FALSE
	icon_icon = 'icons/mob/actions/actions_ninja.dmi'
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
		to_chat(ninja, span_warning("This place forcibly stabilizes your body somehow! You can't use \"Spirit Form\" there!"))
		return
	if(spirited)
		cancel_spirit_form()
	else
		if(cell.charge <= 0)
			to_chat(ninja, span_warning("You don't have enough power to enable spirit form!"))
			return
		spirited = !spirited
		animate(ninja, color ="#00ff00", time = 6)
		if(!stealth)
			animate(ninja, alpha = 64, time = 6) //Трогаем альфу - только если мы не в стелсе
			ninja.visible_message(span_warning("[ninja.name] looks very unstable and strange!"), span_notice("You now can pass almost through everything.")) //Если мы не в стелсе, пишем текст того, что видят другие
		else
			to_chat(ninja, span_notice("You now can pass almost through everything."))	// Если же невидимы - пишем только себе
		ninja.pass_flags |= PASS_COMPLETELY_EVERYTHING
		drop_restraints()
// Я оставлю код компонента тут, но не считаю что игромеханом форма духа должна отключаться в бою. За неё итак платится огромная цена в энергии.
//		ninja.AddComponent(/datum/component/ninja_states_breaker, src)
		for(var/datum/action/item_action/ninja_spirit_form/ninja_action in actions)
			toggle_ninja_action_active(ninja_action, TRUE)

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
			animate(ninja, alpha = 255, time = 6)
		ninja.pass_flags = 0 	//Отнимать этот флаг - "PASS_COMPLETELY_EVERYTHING" по нормальному он не хочет, значит сделаем полный сброс.
		ninja.visible_message(span_warning("[ninja.name] becomes stable again!"), span_notice("You lose your ability to pass the corporeal..."))
//		qdel(ninja.GetComponent(/datum/component/ninja_states_breaker))
		for(var/datum/action/item_action/ninja_spirit_form/ninja_action in actions)
			toggle_ninja_action_active(ninja_action, FALSE)
		return TRUE
	return FALSE


/obj/item/clothing/suit/space/space_ninja/proc/drop_restraints()
	var/mob/living/carbon/human/ninja = affecting
	var/obj/restraint
	if(ninja.handcuffed)
		restraint = ninja.get_item_by_slot(slot_handcuffed)
		restraint.visible_message("<span class='warning'>[restraint] falls from the [ninja] when he becomes unstable!</span>")
		ninja.uncuff()
	if(ninja.legcuffed)
		restraint = ninja.get_item_by_slot(slot_legcuffed)
		restraint.visible_message("<span class='warning'>[restraint] falls from the [ninja] when he becomes unstable!</span>")
		ninja.uncuff()
	if(istype(ninja.loc, /obj/structure/closet))
		var/obj/structure/closet/restraint_closet = ninja.loc
		if(!istype(restraint_closet))
			return FALSE
		ninja.forceMove(get_turf(restraint_closet))
		ninja.visible_message("<span class='warning'>[ninja] goes right through the [restraint_closet] after he becomes unstable!</span>")
