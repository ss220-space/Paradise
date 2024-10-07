/datum/antagonist/wishgranter
	name = "Wishgranter Avatar"
	special_role = "Avatar of the Wish Granter"


/datum/antagonist/wishgranter/give_objectives()
	add_objective(/datum/objective/hijack)


/datum/antagonist/wishgranter/on_gain()
	. = ..()
	if(!.)
		return

	give_powers()


/datum/antagonist/wishgranter/greet()
	. = ..()
	. += span_notice("Your inhibitions are swept away, the bonds of loyalty broken, you are free to murder as you please!")


/datum/antagonist/wishgranter/proc/give_powers()
	var/mob/living/carbon/human/H = owner.current
	if(!istype(H))
		return
	H.ignore_gene_stability = TRUE
	H.force_gene_block(GLOB.hulkblock, TRUE)
	H.force_gene_block(GLOB.xrayblock, TRUE)
	H.force_gene_block(GLOB.farvisionblock, TRUE)
	H.force_gene_block(GLOB.fireblock, TRUE)
	H.force_gene_block(GLOB.coldblock, TRUE)
	H.force_gene_block(GLOB.teleblock, TRUE)
	H.force_gene_block(GLOB.increaserunblock, TRUE)
	H.force_gene_block(GLOB.breathlessblock, TRUE)
	H.force_gene_block(GLOB.regenerateblock, TRUE)
	H.force_gene_block(GLOB.shockimmunityblock, TRUE)
	H.force_gene_block(GLOB.smallsizeblock, TRUE)
	H.force_gene_block(GLOB.soberblock, TRUE)
	H.force_gene_block(GLOB.psyresistblock, TRUE)
	H.force_gene_block(GLOB.shadowblock, TRUE)
	H.force_gene_block(GLOB.cryoblock, TRUE)
	H.force_gene_block(GLOB.eatblock, TRUE)
	H.force_gene_block(GLOB.jumpblock, TRUE)
	H.force_gene_block(GLOB.immolateblock, TRUE)
	ADD_TRAIT(H, TRAIT_LASEREYES, WISHGRANTER_TRAIT)
	H.update_mutations()

