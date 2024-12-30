/datum/disease/virus/babylonian_fever
	name = "Babylonian Fever"
	agent = "Babylon fever agent"
	desc = "If left untreated, the subject will be in a state of disorientation and will forget all the languages he knew."
	max_stages = 3
	spread_flags = AIRBORNE
	visibility_flags = HIDDEN_HUD
	cure_text = "Mannitol & Mitocholide"
	cures = list("mannitol", "mitocholide")
	cure_prob = 30
	permeability_mod = 0.75
	severity = MEDIUM

	// We'll store the languages the mob knew before the fever here
	var/list/datum/language/stored_languages


/datum/disease/virus/babylonian_fever/Contract(mob/living/M, act_type, is_carrier, need_protection_check, zone)
	var/datum/disease/virus/babylonian_fever/disease = ..()

	if(!disease)
		return FALSE

	disease.store_and_remove_languages()

	disease.RegisterSignal(disease.affected_mob, COMSIG_MOB_LANGUAGE_ADD, PROC_REF(store_language))
	disease.RegisterSignal(disease.affected_mob, COMSIG_MOB_LANGUAGE_REMOVE, PROC_REF(remove_language))

	ADD_TRAIT(disease.affected_mob, TRAIT_NO_BABEL, UNIQUE_TRAIT_SOURCE(disease))


/datum/disease/virus/babylonian_fever/stage_act()
	if(!..())
		return FALSE
	switch(stage)
		if(2, 3)
			if(prob(stage))
				affected_mob.adjustBrainLoss(0.5)
				affected_mob.say(pick(
					"Ммм... гхм...",
					"А-а-а... эээ...",
					"Брр... бл... бл...",
					"Гх... гх... гх...",
					"Ааа... ааа... ааа...",
					"Ух... ух... ух...",
					"Хм... хм... хм...",
					"Шш... шш... шш...",
					"Ыы... ыы... ыы...",
					"Оо... оо... оо...",
					"Уээ... Уэээ... УЭЭЭЭ...",
					"Ээ... ээ... ээ...",
					"Ии... ии... ии...",
					"Двести... двадцать..."\
					)
				)

	return TRUE


/datum/disease/virus/babylonian_fever/Destroy()
	if(affected_mob)
		UnregisterSignal(affected_mob, list(
			COMSIG_MOB_LANGUAGE_ADD,
			COMSIG_MOB_LANGUAGE_REMOVE,
		))

		// Restore previously known languages.
		if(LAZYLEN(stored_languages))
			for(var/datum/language/lan as anything in stored_languages)
				affected_mob.add_language(lan.name)

		REMOVE_TRAIT(affected_mob, TRAIT_NO_BABEL, UNIQUE_TRAIT_SOURCE(src))

	LAZYNULL(stored_languages)

	return ..()


/datum/disease/virus/babylonian_fever/proc/store_and_remove_languages()
	if(!LAZYLEN(affected_mob.languages))
		return

	stored_languages = LAZYCOPY(affected_mob.languages)

	for(var/datum/language/lan as anything in affected_mob.languages)
		affected_mob.remove_language(lan.name)


/datum/disease/virus/babylonian_fever/proc/store_language(datum/signal_source, language_name)
	SIGNAL_HANDLER

	var/datum/language/new_language = GLOB.all_languages[language_name]
	LAZYOR(stored_languages, new_language)
	return DISEASE_MOB_LANGUAGE_PROCESSED


/datum/disease/virus/babylonian_fever/proc/remove_language(datum/signal_source, language_name)
	SIGNAL_HANDLER

	var/datum/language/rem_language = GLOB.all_languages[language_name]
	LAZYREMOVE(stored_languages, rem_language)
	return DISEASE_MOB_LANGUAGE_PROCESSED
