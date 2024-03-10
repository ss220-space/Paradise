
/mob/living/carbon/human/verb/change_attack(attack as null|anything in dna.species.available_attacks)
	set name = "Change Default Attack"
	set category = "IC"

	if(attack)
		to_chat(src, span_notice("You will now use your [attack] when you want to do harm."))
		dna.species.choosen_attack = attack


