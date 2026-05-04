/datum/action/changeling/epinephrine
	name = "Выброс адреналина"
	desc = "Мы отращиваем новые мешочки с адреналином. Требует 30 химикатов."
	helptext = "Моментально поднимает на ноги и даёт краткую защиту от оглушения. Можно использовать будучи без сознания, но не рекомендуется использовать больше 2 раз подряд. Можно использовать в низшей форме."
	button_icon_state = "adrenaline"
	power_type = CHANGELING_PURCHASABLE_POWER
	dna_cost = 2
	chemical_cost = 30
	req_stat = UNCONSCIOUS

/datum/action/changeling/epinephrine/sting_action(mob/living/user)

	if(user.body_position == LYING_DOWN)
		user.balloon_alert(user, "мы подскакиваем!")
	else
		user.balloon_alert(user, "адреналин наполняет силой!")

	user.SetSleeping(0)
	user.SetParalysis(0)
	user.SetStunned(0)
	user.SetWeakened(0)
	user.SetKnockdown(0)
	user.setStaminaLoss(0)
	user.set_resting(FALSE, instant = TRUE)
	user.get_up(instant = TRUE)
	user.reagents.add_reagent("synaptizine", 20)
	user.reagents.add_reagent("noradrenaline", 2)

	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return TRUE
