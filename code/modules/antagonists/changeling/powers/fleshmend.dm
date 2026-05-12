/datum/action/changeling/fleshmend
	name = "Регенерация плоти"
	desc = "Наша плоть начинает быстро регенерировать. Требует 20 химикатов."
	helptext = "Помогает с порезами, ожогами, удушьем, кровопотерей, но не отращивает конечности. Можно использовать будучи без сознания. Можно использовать в низшей форме."
	button_icon_state = "fleshmend"
	power_type = CHANGELING_PURCHASABLE_POWER
	dna_cost = 2
	chemical_cost = 20
	req_stat = UNCONSCIOUS

/datum/action/changeling/fleshmend/sting_action(mob/living/user)
	user.apply_status_effect(STATUS_EFFECT_FLESHMEND)
	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))

	return TRUE

