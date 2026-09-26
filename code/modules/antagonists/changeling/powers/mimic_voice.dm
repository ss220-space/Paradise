#define CLING_MIMICVOICE_PICKVOICE "Выбрать голос"
#define CLING_MIMICVOICE_WRITEVOICE "Создать голос"
#define CLING_MIMICVOICE_CANCEL "Отмена"

/datum/action/changeling/mimicvoice
	name = "Подражание голоса"
	desc = "Мы изменяем голосовые связки, чтобы звучать, как пожелаем."
	helptext = "Напишите имя тела, которому хотите подражать."
	button_icon_state = "mimic_voice"
	power_type = CHANGELING_PURCHASABLE_POWER
	dna_cost = 1
	req_human = TRUE

/datum/action/changeling/mimicvoice/sting_action(mob/user)
	if(cling.mimicking)
		cling.mimicking = ""
		cling.tts_mimicking = ""
		user.balloon_alert(user, "говорим нашим голосом")
		return FALSE

	var/mimic_voice
	var/mimic_voice_tts
	var/mimic_option = tgui_alert(user, "Чей голос мы хотим повторить?", "Подражание голоса", list(CLING_MIMICVOICE_PICKVOICE, CLING_MIMICVOICE_WRITEVOICE, CLING_MIMICVOICE_CANCEL))

	switch(mimic_option)
		if(CLING_MIMICVOICE_PICKVOICE)
			var/mob/living/carbon/human/human = tgui_input_list(user, "Чей голос мы хотим повторить?", "Подражание голоса", GLOB.human_list)
			mimic_voice = human.real_name
			mimic_voice_tts = human.dna.tts_seed_dna

		if(CLING_MIMICVOICE_WRITEVOICE)
			mimic_voice = reject_bad_name(tgui_input_text(user, "Какое имя будет использоваться?", "Подражание голоса", max_length = MAX_NAME_LEN), TRUE)
			if(!mimic_voice)
				user.balloon_alert(user, "голос не подошёл")
				return FALSE

			mimic_voice_tts = user.select_voice(user, override = TRUE)

		if(CLING_MIMICVOICE_CANCEL)
			return FALSE

	cling.mimicking = mimic_voice
	cling.tts_mimicking = mimic_voice_tts
	user.balloon_alert(user, "говорим голосом [mimic_voice]")
	to_chat(user, span_notice("Нажмите на способность ещё раз, чтобы вернуть свой голос."))

	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return TRUE

#undef CLING_MIMICVOICE_PICKVOICE
#undef CLING_MIMICVOICE_WRITEVOICE
#undef CLING_MIMICVOICE_CANCEL
