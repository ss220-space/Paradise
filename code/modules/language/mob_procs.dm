// Can we speak this language, as opposed to just understanding it?
/mob/proc/can_speak_language(datum/language/speaking)
	return universal_speak || (speaking == GLOB.all_languages[LANGUAGE_NOISE]) || LAZYIN(languages, speaking)

//TBD
/mob/proc/check_lang_data()
	. = ""

	for(var/datum/language/L in languages)
		if(!(L.flags & NONGLOBAL))
			. += "<b>[L.name] (:[L.key])</b><br/>[L.desc]<br><br>"

/mob/living/check_lang_data()
	. = ""

	if(default_language)
		. += "Текущий язык по умолчанию: [default_language] - <a href='byond://?src=[UID()];default_lang=reset'>Сброс</a><br><br>"

	for(var/datum/language/L in languages)
		if(!(L.flags & NONGLOBAL))
			if(L == default_language)
				. += "<b>[L.name] (:[L.key])</b> - default - <a href='byond://?src=[UID()];default_lang=reset'>Сброс</a><br>[L.desc]<br><br>"
			else
				. += "<b>[L.name] (:[L.key])</b> - <a href=\"byond://?src=[UID()];default_lang=[L.name]\">По умолчанию</a><br>[L.desc]<br><br>"

/mob/verb/check_languages()
	set name = "Меню языков"
	set category = STATPANEL_IC
	set src = usr

	var/datum/browser/popup = new(src, "checklanguage", "Меню языков", 420, 470)
	popup.set_content(check_lang_data())
	popup.open()

/mob/living/Topic(href, href_list)
	. = ..()
	if(.)
		return TRUE
	if(href_list["default_lang"])
		if(href_list["default_lang"] == "reset")
			set_default_language(null)
		else
			var/datum/language/L = GLOB.all_languages[href_list["default_lang"]]
			if(L)
				set_default_language(L)
		check_languages()
		return TRUE

// Language handling.
/mob/proc/add_language(language_name)
	var/result_flags = SEND_SIGNAL(src, COMSIG_LANG_PRE_ACT, language_name)
	if(SEND_SIGNAL(src, COMSIG_MOB_LANGUAGE_ADD, language_name, result_flags) & DISEASE_MOB_LANGUAGE_PROCESSED)
		return TRUE

	var/datum/language/new_language = GLOB.all_languages[language_name]
	if(new_language in languages)
		return FALSE

	if(!istype(new_language))
		new_language = GLOB.all_languages[convert_lang_key_to_name(language_name)]
		if(!istype(new_language))
			return FALSE

	. = !LAZYIN(languages, new_language)
	if(.)
		LAZYADD(languages, new_language)

/mob/proc/remove_language(language_name)
	var/result_flags = SEND_SIGNAL(src, COMSIG_LANG_PRE_ACT, language_name)
	if(SEND_SIGNAL(src, COMSIG_MOB_LANGUAGE_REMOVE, language_name, result_flags) & DISEASE_MOB_LANGUAGE_PROCESSED)
		return TRUE

	var/datum/language/rem_language = GLOB.all_languages[language_name]
	if(!istype(rem_language))
		rem_language = GLOB.all_languages[convert_lang_key_to_name(language_name)]
		if(!istype(rem_language))
			return FALSE

	. = LAZYIN(languages, rem_language)
	if(.)
		LAZYREMOVE(languages, rem_language)

/mob/living/remove_language(language_name)
	var/datum/language/rem_language = GLOB.all_languages[language_name]
	if(!istype(rem_language))
		rem_language = GLOB.all_languages[convert_lang_key_to_name(language_name)]
		if(!istype(rem_language))
			return FALSE

	if(default_language == rem_language)
		default_language = null

	return ..()

/mob/proc/grant_all_babel_languages()
	for(var/la in GLOB.all_languages)
		var/datum/language/new_language = GLOB.all_languages[la]
		if(new_language.flags & NOBABEL)
			continue
		LAZYOR(languages, new_language)

/mob/proc/grant_all_languages()
	for(var/la in GLOB.all_languages)
		add_language(la)

/proc/convert_lang_key_to_name(language_key)
	var/static/list/language_keys_and_names = list()
	if(!length(language_keys_and_names))
		for(var/language_name in GLOB.all_languages)
			var/datum/language/language = GLOB.all_languages[language_name]
			language_keys_and_names[language.key] = language_name
	return language_keys_and_names[language_key]

/proc/get_language_prefix(language_name)
	var/datum/language/language = GLOB.all_languages[language_name]
	if(language)
		. = ":[language.key] "
	else
		. = "Non-existent key"
		CRASH("[language_name] language does not exist.")

