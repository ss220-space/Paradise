/datum/action/changeling/chameleon_skin
	name = "Кожа-Хамелеон"
	desc = "Пигментация нашей кожи стремительно изменяется, чтобы сливаться с окружением. Дестабилизирует 10 генома."
	helptext = "Позволяет становиться невидимым, если не двигаться пару секунд. Можно включать и выключать."
	button_icon_state = "chameleon_skin"
	power_type = CHANGELING_PURCHASABLE_POWER
	dna_cost = 1
	genetic_damage = 10
	req_human = TRUE

/datum/action/changeling/chameleon_skin/sting_action(mob/user)
	var/mob/living/carbon/human/h_owner = user
	if(!istype(h_owner))	// SHOULD always be human, because req_human = TRUE, but better safe than sorry
		return FALSE

	h_owner.force_gene_block(GLOB.chameleonblock, !h_owner.dna.GetSEState(GLOB.chameleonblock))
	user.balloon_alert(user, "[!h_owner.dna.GetSEState(GLOB.chameleonblock) ? "кожа снова видна" : "кожа становится прозрачной"]")

	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return TRUE

/datum/action/changeling/chameleon_skin/Remove(mob/user)
	var/mob/living/carbon/c_owner = user
	if(!QDELETED(c_owner) && c_owner.dna?.GetSEState(GLOB.chameleonblock))
		c_owner.force_gene_block(GLOB.chameleonblock, FALSE)
	..()
