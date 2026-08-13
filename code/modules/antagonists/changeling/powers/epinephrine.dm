/datum/action/changeling/epinephrine
	name = "Выброс адреналина"
	desc = "Мы отращиваем новые мешочки с адреналином. Требует 30 химикатов."
	helptext = "Моментально поднимает на ноги и даёт краткую защиту от оглушения. Можно использовать будучи без сознания. Можно использовать в низшей форме."
	button_icon_state = "adrenaline"
	power_type = CHANGELING_PURCHASABLE_POWER
	dna_cost = 2
	chemical_cost = 30
	req_stat = UNCONSCIOUS

/datum/action/changeling/epinephrine/sting_action(mob/living/user)
	user.apply_status_effect(STATUS_EFFECT_EPINEPHRINE)
	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return TRUE
