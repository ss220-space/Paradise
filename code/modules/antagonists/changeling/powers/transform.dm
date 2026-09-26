/datum/action/changeling/transform
	name = "Трансформация"
	desc = "Мы принимаем облик и голос из поглощенных ДНК."
	button_icon_state = "transform"
	power_type = CHANGELING_INNATE_POWER
	req_dna = 1
	req_human = TRUE

/datum/action/changeling/transform/sting_action(mob/living/carbon/human/user)
	var/datum/dna/chosen_dna = cling.select_dna("Выбрать ДНК для жертвы: ", "ДНК для жертвы")

	if(!chosen_dna)
		return FALSE

	transform_dna(user, chosen_dna)
	cling.update_languages()
	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return TRUE

