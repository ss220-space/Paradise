/datum/action/changeling/chameleon_skin
	name = "Кожа-Хамелеон"
	desc = "Пигментация нашей кожи стремительно изменяется, чтобы сливаться с окружением. Требует 10 химикатов."
	helptext = "Позволяет становиться невидимым. Можно использовать в низшей форме."
	button_icon_state = "chameleon_skin"
	power_type = CHANGELING_PURCHASABLE_POWER
	dna_cost = 1

/datum/action/changeling/chameleon_skin/sting_action(mob/living/carbon/user)
	if(!user.has_status_effect(STATUS_EFFECT_CHAMELEON))
		user.apply_status_effect(STATUS_EFFECT_CHAMELEON)
	else
		user.remove_status_effect(STATUS_EFFECT_CHAMELEON)

	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return TRUE

/datum/action/changeling/chameleon_skin/Remove(mob/living/user)
	user.remove_status_effect(STATUS_EFFECT_CHAMELEON)
	..()
