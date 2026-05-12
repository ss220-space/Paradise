/datum/action/changeling/lesserform
	name = "Низшая форма"
	desc = "Мы трансформируемся в низшую форму."
	helptext = "Мы уменьшаемся в размерах, что освободит нас от наручников, всей одежды и позволит лазить по вентиляции."
	button_icon_state = "lesser_form"
	power_type = CHANGELING_PURCHASABLE_POWER
	dna_cost = 1
	req_human = TRUE

/datum/action/changeling/lesserform/sting_action(mob/living/carbon/human/user)
	if(!istype(user))
		return FALSE

	if(HAS_TRAIT(user, TRAIT_NO_TRANSFORM))
		return FALSE

	if(user.has_brain_worms())
		user.balloon_alert(user, "в разуме паразит")
		return FALSE

	if(!user.dna.species.primitive_form)
		user.balloon_alert(user, "неподходящая форма")
		return FALSE

	user.visible_message(span_warning("[user] трансформируется в низшую форму!"))
	remove_changeling_mutations(user)
	user.force_gene_block(GLOB.monkeyblock, TRUE)

	cling.give_power(new /datum/action/changeling/humanform)

	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return TRUE

