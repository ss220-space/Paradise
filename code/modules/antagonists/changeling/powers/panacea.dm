/datum/action/changeling/panacea
	name = "Анатомическая панацея"
	desc = "Лечит болезни, генетические мутации, избавляет от паразитов, отрезвляет, очищает от токсинов. Требует 20 химикатов."
	helptext = "Можно использовать будучи без сознания. Можно использовать в низшей форме."
	button_icon_state = "panacea"
	power_type = CHANGELING_PURCHASABLE_POWER
	dna_cost = 1
	chemical_cost = 20
	req_stat = UNCONSCIOUS

/datum/action/changeling/panacea/sting_action(mob/living/user)
	user.balloon_alert(user, "мы очищаем сосуд!")
	var/mob/living/simple_animal/borer/borer = user.has_brain_worms()
	if(borer)
		borer.leave_host()
		if(iscarbon(user))
			var/mob/living/carbon/c_user = user
			c_user.fakevomit()

	if(iscarbon(user))
		var/mob/living/carbon/c_user = user
		c_user.remove_all_parasites(vomit_organs = TRUE)

	user.reagents.add_reagent("mutadone", 2)
	user.apply_status_effect(STATUS_EFFECT_PANACEA)

	for(var/datum/disease/virus in user.diseases)
		if(virus.severity == DISEASE_SEVERITY_POSITIVE)
			continue
		virus.cure()

	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return TRUE

