/datum/spell_handler/devil

/datum/spell_handler/devil/can_cast(mob/living/carbon/user, charge_check, show_message, datum/action/cooldown/spell/spell)
	if(!istype(user))
		return FALSE

	if(!user.mind?.has_antag_datum(/datum/antagonist/devil))
		return FALSE

	return TRUE
