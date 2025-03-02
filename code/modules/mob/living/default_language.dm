/mob/living
	var/datum/language/default_language

/mob/living/verb/set_default_language(language as null|anything in languages)
	set name = "Выбрать язык по умолчанию"
	set category = "IC"

	if(language)
		to_chat(src, span_notice("Теперь вы будете использовать [language], если не укажете язык при разговоре."))
	else
		to_chat(src, span_notice("Теперь вы будете говорить на стандартном языке по умолчанию, если не укажете его при разговоре."))
	default_language = language

// Silicons can't neccessarily speak everything in their languages list
/mob/living/silicon/set_default_language(language as null|anything in speech_synthesizer_langs)
	..()

/mob/living/verb/check_default_language()
	set name = "Узнать язык по умолчанию"
	set category = "IC"

	if(default_language)
		to_chat(src, span_notice("В данный момент вы используете [default_language] по умолчанию."))
	else
		to_chat(src, span_notice("Ваш текущий язык по умолчанию соответствует вашему виду или типу существа по умолчанию."))
