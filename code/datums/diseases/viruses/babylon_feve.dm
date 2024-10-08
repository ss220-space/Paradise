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
	var/list/datum/language/stored_languages = list()

/datum/disease/virus/babylonian_fever/stage_act()
	if(!..())
		return FALSE

	switch(stage)
		if(2, 3)
			if(prob(stage))
				affected_mob.adjustBrainLoss(0.5)
			if(prob(stage))
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
					"Двести... двадцать..."
					)
				)

	// Store languages on first stage activation
	if(stage == 1 && !stored_languages.len && affected_mob.languages)
		stored_languages = affected_mob.languages.Copy()
	else
		if(affected_mob.languages)
			stored_languages += affected_mob.languages.Copy()

	// Remove existing languages
	affected_mob.languages.Cut()

	return TRUE

/datum/disease/virus/babylonian_fever/has_cure()
	if(..())
		// Restore previously known languages
		if(stored_languages.len)
			affected_mob.languages = stored_languages.Copy()
			stored_languages.Cut() // Clear the stored languages

		return TRUE

