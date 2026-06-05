/datum/action/changeling/strained_muscles
	name = "Напряжение мышц"
	desc = "Мы модифицируем мышцы ног, снижая накопление в них кислоты, что позволяет нам двигаться намного быстрее. Требует 10 химикатов."
	helptext = "Мы способны выдержать 10 секунд без вреда для химического синтеза. Можно использовать в низшей форме."
	button_icon_state = "strained_muscles"
	power_type = CHANGELING_PURCHASABLE_POWER
	dna_cost = 1

/datum/action/changeling/strained_muscles/Remove(mob/living/user)
	user.remove_status_effect(STATUS_EFFECT_SPEEDLEGS)
	..()

/datum/action/changeling/strained_muscles/sting_action(mob/living/carbon/user)
	if(!user.has_status_effect(STATUS_EFFECT_SPEEDLEGS))
		if(user.dna.species.speed_mod < 0)
			user.balloon_alert(user, "не можем быстрее!")
		else
			to_chat(user, span_notice("Наши мышцы укрепляются и напрягаются."))
			user.apply_status_effect(STATUS_EFFECT_SPEEDLEGS)
	else
		user.remove_status_effect(STATUS_EFFECT_SPEEDLEGS)

	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return TRUE
