/datum/spell_handler/vampire
	var/required_blood
	/// If the blood cost should be handled by this handler. Or if the spell will handle it itself
	var/deduct_blood_on_cast = TRUE

/datum/spell_handler/vampire/can_cast(mob/user, charge_check, show_message, obj/effect/proc_holder/spell/spell)
	var/datum/vampire/vampire = user.mind.vampire

	if(!vampire)
		return FALSE

	var/fullpower = vampire.get_ability(/datum/vampire_passive/full)

	if(user.stat >= DEAD) // TODO check if needed
		if(show_message)
			to_chat(user, "<span class='warning'>Но вы же мертвы!</span>")
		return FALSE

	if(!fullpower) // above 100 nullification vampire powers are useless
		if(show_message)
			to_chat(user, "<span class='warning'>Что-то блокирует ваши силы!</span>")
		return FALSE
	if(vampire.bloodusable < required_blood)
		if(show_message)
			to_chat(user, "<span class='warning'>Для этого вам потребуется не менее [required_blood] единиц крови!</span>")
		return FALSE
	//chapel check
	if(istype(get_area(user), /area/chapel) && !fullpower)
		if(show_message)
			to_chat(user, "<span class='warning'>Ваши силы не действуют на этой святой земле.</span>")
		return FALSE
	return TRUE

/datum/spell_handler/vampire/spend_spell_cost(mob/user, obj/effect/proc_holder/spell/spell)
	if(!required_blood || !deduct_blood_on_cast) //don't take the blood yet if this is false!
		return

	var/datum/vampire/vampire = user.mind.vampire

	vampire.bloodusable -= calculate_blood_cost(vampire)

/datum/spell_handler/vampire/proc/calculate_blood_cost(datum/vampire/vampire)
	var/blood_cost_modifier = 1 + vampire.nullified / 100
	var/blood_cost = round(required_blood * blood_cost_modifier)
	return blood_cost

/datum/spell_handler/vampire/after_cast(list/targets, mob/user, obj/effect/proc_holder/spell/spell)
	if(!required_blood)
		return
	var/datum/vampire/vampire = user.mind.vampire
	to_chat(user, "<span class='notice'><b>У вас осталось [vampire.bloodusable] единиц крови.</b></span>")
	SSblackbox.record_feedback("tally", "vampire_powers_used", 1, "[spell]") // Only log abilities which require blood
