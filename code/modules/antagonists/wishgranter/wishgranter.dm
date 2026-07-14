/datum/antagonist/wishgranter
	name = "Wishgranter Avatar"
	special_role = "Avatar of the Wish Granter"
	antag_menu_name = "Аватар исполнителя желаний"

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
	var/mob/living/carbon/human/human = owner.current
	if(!istype(human))
		return
	human.ignore_gene_stability = TRUE
	human.force_gene_block(GLOB.hulkblock, TRUE)
	human.force_gene_block(GLOB.xrayblock, TRUE)
	human.force_gene_block(GLOB.farvisionblock, TRUE)
	human.force_gene_block(GLOB.fireblock, TRUE)
	human.force_gene_block(GLOB.coldblock, TRUE)
	human.force_gene_block(GLOB.teleblock, TRUE)
	human.force_gene_block(GLOB.increaserunblock, TRUE)
	human.force_gene_block(GLOB.breathlessblock, TRUE)
	human.force_gene_block(GLOB.regenerateblock, TRUE)
	human.force_gene_block(GLOB.shockimmunityblock, TRUE)
	human.force_gene_block(GLOB.smallsizeblock, TRUE)
	human.force_gene_block(GLOB.soberblock, TRUE)
	human.force_gene_block(GLOB.psyresistblock, TRUE)
	human.force_gene_block(GLOB.shadowblock, TRUE)
	human.force_gene_block(GLOB.cryoblock, TRUE)
	human.force_gene_block(GLOB.eatblock, TRUE)
	human.force_gene_block(GLOB.jumpblock, TRUE)
	human.force_gene_block(GLOB.immolateblock, TRUE)
	ADD_TRAIT(human, TRAIT_LASEREYES, WISHGRANTER_TRAIT)
	human.update_mutations()

