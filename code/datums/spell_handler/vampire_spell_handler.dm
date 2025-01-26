/datum/spell_handler/vampire
	var/required_blood
	/// If the blood cost should be handled by this handler. Or if the spell will handle it itself
	var/deduct_blood_on_cast = TRUE


/datum/spell_handler/vampire/can_cast(mob/user, charge_check, show_message, obj/effect/proc_holder/spell/spell)
	var/datum/antagonist/vampire/vampire = user?.mind?.has_antag_datum(/datum/antagonist/vampire)

	if(!vampire)
		return FALSE

	if(isvampirecoffin(user.loc))
		if(show_message)
			to_chat(user, span_warning("Вы не можете использовать эту способность, будучи в гробу!"))
		return FALSE

	var/fullpower = vampire.get_ability(/datum/vampire_passive/full)

	if(user.stat >= DEAD) // TODO check if needed
		if(show_message)
			to_chat(user, span_warning("Но вы же мертвы!"))
		return FALSE

	if(((vampire.nullified >= VAMPIRE_COMPLETE_NULLIFICATION) || \
	(vampire.nullification == OLD_NULLIFICATION && vampire.nullified)) && !fullpower) // above 100 nullification vampire powers are useless
		if(show_message)
			to_chat(user, span_warning("Что-то блокирует ваши силы!"))
		return FALSE

	if(vampire.bloodusable < required_blood)
		if(show_message)
			to_chat(user, span_warning("Для этого вам потребуется не менее [required_blood] единиц крови!"))
		return FALSE

	//chapel check
	if(is_type_in_typecache(get_area(user), GLOB.holy_areas) && !fullpower)
		if(show_message)
			to_chat(user, span_warning("Ваши силы не действуют на этой святой земле."))
		return FALSE
	return TRUE


/datum/spell_handler/vampire/spend_spell_cost(mob/user, obj/effect/proc_holder/spell/spell)
	if(!required_blood || !deduct_blood_on_cast) //don't take the blood yet if this is false!
		return

	var/datum/antagonist/vampire/vampire = user?.mind?.has_antag_datum(/datum/antagonist/vampire)

	vampire?.bloodusable -= calculate_blood_cost(vampire)


/datum/spell_handler/vampire/proc/calculate_blood_cost(datum/antagonist/vampire/vampire)
	var/blood_cost_modifier = 1 + ((vampire.nullification == OLD_NULLIFICATION)? 0 : vampire.nullified / 100)
	var/blood_cost = round(required_blood * blood_cost_modifier)
	return clamp(blood_cost, 0, vampire.bloodusable)


/datum/spell_handler/vampire/after_cast(list/targets, mob/user, obj/effect/proc_holder/spell/spell)
	if(!spell.should_recharge_after_cast)
		return
	if(!required_blood)
		return
	var/datum/antagonist/vampire/vampire = user?.mind?.has_antag_datum(/datum/antagonist/vampire)
	if(!vampire)
		return
	to_chat(user, span_boldnotice("У Вас осталось [vampire.bloodusable] единиц крови."))
	SSblackbox.record_feedback("tally", "vampire_powers_used", 1, "[spell]") // Only log abilities which require blood

/datum/spell_handler/vampire/goon/revert_cast(mob/living/carbon/user, obj/effect/proc_holder/spell/spell)
	var/datum/antagonist/vampire/vampire = user?.mind?.has_antag_datum(/datum/antagonist/vampire)
	vampire?.bloodusable += required_blood
