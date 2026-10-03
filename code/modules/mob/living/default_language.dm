GAME_VERB(/mob/living, set_default_language_verb, "Выбрать язык по умолчанию", VERB_CATEGORY_IC)
	var/language = tgui_input_list(src, "Выберете язык по умолчанию", "Язык по умолчанию", get_languages())
	set_default_language(language)

/mob/living/proc/set_default_language(language)
	if(language)
		to_chat(src, span_notice("Теперь вы будете использовать [language], если не укажете язык при разговоре."))
	else
		to_chat(src, span_notice("Теперь вы будете говорить на стандартном языке по умолчанию, если не укажете его при разговоре."))
	default_language = language

/mob/living/proc/get_languages()
	return languages

/mob/living/silicon/get_languages()
	return speech_synthesizer_langs

GAME_VERB(/mob/living, check_default_language, "Узнать язык по умолчанию", VERB_CATEGORY_IC)

	if(default_language)
		to_chat(src, span_notice("В данный момент вы используете [default_language] по умолчанию."))
	else
		to_chat(src, span_notice("Ваш текущий язык по умолчанию соответствует вашему виду или типу существа по умолчанию."))
