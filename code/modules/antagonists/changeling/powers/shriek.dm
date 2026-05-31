/datum/action/changeling/resonant_shriek
	name = "Резонансный крик"
	desc = "Наши легкие и голосовые связки смещаются, позволяя нам на короткое время издавать звук, который оглушает и сбивает с толку. Требует 30 химикатов."
	helptext = "Издает высокочастотный звук, который сбивает с толку гуманоидов, оглушает синтетиков и гасит ближайший свет. Можно использовать в низшей форме."
	button_icon_state = "resonant_shriek"
	power_type = CHANGELING_PURCHASABLE_POWER
	dna_cost = 1
	chemical_cost = 30

/datum/action/changeling/resonant_shriek/sting_action(mob/user)
	for(var/mob/living/l_target in get_hearers_in_view(7, user))
		SEND_SOUND(l_target, sound('sound/effects/clingscream.ogg'))
		if(iscarbon(l_target))
			if(ishuman(l_target) && !ischangeling(l_target))
				var/mob/living/carbon/human/h_target = l_target
				if(h_target.check_ear_prot() >= HEARING_PROTECTION_TOTAL)
					continue

				h_target.Deaf(60 SECONDS)
				l_target.AdjustConfused(40 SECONDS)
				l_target.Jitter(100 SECONDS)

		if(issilicon(l_target))
			SEND_SOUND(l_target, sound('sound/weapons/flash.ogg'))
			l_target.Weaken(rand(10 SECONDS, 20 SECONDS))

	for(var/obj/machinery/light/lamp in range(7, user))
		lamp.on = TRUE
		lamp.break_light_tube()

	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return TRUE

/datum/action/changeling/dissonant_shriek
	name = "Диссонирующий крик"
	desc = "Наши легкие и голосовые связки смещаются, позволяя нам на короткое время издавать звук, который вызывает ЭМИ. Требует 30 химикатов."
	helptext = "Можно использовать в низшей форме."
	button_icon_state = "dissonant_shriek"
	power_type = CHANGELING_PURCHASABLE_POWER
	dna_cost = 1
	chemical_cost = 30

/datum/action/changeling/dissonant_shriek/sting_action(mob/user)
	for(var/obj/machinery/light/lamp in range(7, user))
		lamp.on = TRUE
		lamp.break_light_tube()
	empulse(get_turf(user), 2, 4, TRUE, "Changeling Shriek")
	return TRUE
