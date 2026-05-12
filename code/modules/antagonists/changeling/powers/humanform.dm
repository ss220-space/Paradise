/datum/action/changeling/humanform
	name = "Гуманоидная форма"
	desc = "Мы трансформируемся в гуманоида."
	button_icon_state = "human_form"
	req_dna = 1

/datum/action/changeling/humanform/sting_action(mob/living/carbon/human/user)
	if(HAS_TRAIT(user, TRAIT_NO_TRANSFORM))
		return FALSE

	var/datum/dna/chosen_dna = cling.select_dna("Какое ДНК использовать?: ", "Выбор ДНК")
	if(!chosen_dna || !user)
		return FALSE

	// Notify players about transform.
	user.visible_message(span_warning("[user] трансформируется в гуманоида!"))
	user.force_gene_block(GLOB.monkeyblock, FALSE)

	if(istype(user))
		user.set_species(chosen_dna.species.type, keep_missing_bodyparts = TRUE)

	user.dna = chosen_dna.Clone()
	user.real_name = chosen_dna.real_name
	user.check_genes(MUTCHK_FORCED)
	user.flavor_text = ""
	user.dna.UpdateSE()
	user.dna.UpdateUI()
	user.sync_organ_dna(TRUE)
	user.UpdateAppearance()

	cling.acquired_powers -= src
	Remove(user)
	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return TRUE
