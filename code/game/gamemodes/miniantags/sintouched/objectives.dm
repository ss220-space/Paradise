/datum/objective/sintouched
	completed = TRUE
	needs_target = FALSE
	var/mob/living/carbon/human/user

/*  NO ERP OBJECTIVE FOR YOU.
/datum/objective/sintouched/lust
	dangerrating = 3 // it's not AS dangerous.

/datum/objective/sintouched/lust/New()
	var/mob/dead/D = pick(dead_mob_list)
	if(prob(50) && D)
		explanation_text = "You know that [D] has perished.... and you think [D] is kinda cute.  Make sure everyone knows how HOT [D]'s lifeless body is."
	else
		explanation_text = "Go get married, then immediately cheat on your new spouse." */

/datum/objective/sintouched/proc/on_apply()
	return

/datum/objective/sintouched/New(mob/living/carbon/human/human)
	..()
	user = human // Currently not to mind
	on_apply()
	
/datum/objective/sintouched/Destroy(force)
	user = null
	return ..()

/datum/objective/sintouched/gluttony
	explanation_text = "Еда очень вкусная, настолько вкусная, что вы не можете позволить еде попасть к другим людям, ведь она и была создана лишь для вас."

/datum/objective/sintouched/gluttony/on_apply()
	user.physiology.hunger_mod *= 3
	LAZYADD(user.dna.species.inherent_traits, TRAIT_NO_FAT)
	user.force_gene_block(GLOB.eatblock, TRUE)

/datum/objective/sintouched/gluttony/Destroy(force)
	user.physiology.hunger_mod /= 3
	LAZYREMOVE(user.dna.species.inherent_traits, TRAIT_NO_FAT)
	user.force_gene_block(GLOB.eatblock)
	return ..()
	
/datum/objective/sintouched/greed
	explanation_text = "Вы хотите БОЛЬШЕ, больше денег, больше богатства, больше богатств. Заполучи их, но не вреди людям ради этого."
	
/datum/objective/sintouched/sloth
	explanation_text = "Вы периодически устаёте. Идите и вздремните в то время, когда это будет неудобно другим людям."
	
/datum/objective/sintouched/sloth/on_apply()
	user.add_or_update_variable_actionspeed_modifier(/datum/actionspeed_modifier/species_tool_mod, multiplicative_slowdown = user.dna.species.toolspeedmod + 1)
	user.add_or_update_variable_actionspeed_modifier(/datum/actionspeed_modifier/species_surgery_mod, multiplicative_slowdown = user.dna.species.surgeryspeedmod + 1)
	user.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/species_speedmod, multiplicative_slowdown = user.dna.species.speed_mod - 0.5)

/datum/objective/sintouched/sloth/Destroy(force)
	user.add_or_update_variable_actionspeed_modifier(/datum/actionspeed_modifier/species_tool_mod, multiplicative_slowdown = user.dna.species.toolspeedmod)
	user.add_or_update_variable_actionspeed_modifier(/datum/actionspeed_modifier/species_surgery_mod, multiplicative_slowdown = user.dna.species.surgeryspeedmod)
	user.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/species_speedmod, multiplicative_slowdown = user.dna.species.speed_mod)
	return ..()
	
/datum/objective/sintouched/wrath
	explanation_text = "Что ваши коллеги когда-либо делали для вас? Не предлагайте им помощь ни в каких делах и отказывайте, если попросят."
	
/datum/objective/sintouched/wrath/on_apply()
	var/datum/disease/virus/advance/preset/aggression/disease = new
	user.physiology.punch_damage_low += 5
	user.physiology.punch_damage_high += 10
	disease.Contract(user)

/datum/objective/sintouched/wrath/Destroy(force)
	user.physiology.punch_damage_low -= 5
	user.physiology.punch_damage_high -= 10
	return ..()

/datum/objective/sintouched/envy
	explanation_text = "Почему вы должны зацикливаться на своем звании? Покажите всем, что вы можете выполнять и другую работу, и не позволяйте никому остановить вас, прежде всего потому, что у вас нет требуемой квалификации."
	
/datum/objective/sintouched/envy/on_apply()
	user.set_species(/datum/species/wryn)
	
/datum/objective/sintouched/pride
	explanation_text = "Вы - лучшее, что есть на станции. Убедитесь, что все это знают."
	
/datum/objective/sintouched/pride/on_apply()
	user.physiology.brute_mod *= 0.9
	user.physiology.tox_mod *= 0.9
	user.physiology.stamina_mod *= 0.9
	user.physiology.oxy_mod *= 0.9
	user.physiology.burn_mod *= 0.9

/datum/objective/sintouched/pride/Destroy(force)
	user.physiology.brute_mod /= 0.9
	user.physiology.tox_mod /=  0.9
	user.physiology.stamina_mod /= 0.9
	user.physiology.oxy_mod /= 0.9
	user.physiology.burn_mod /= 0.9
	return ..()

/datum/objective/sintouched/acedia
	explanation_text = "Ангелы, дьяволы, добро, зло... кого это вообще беспокоит? Игнорируйте все адские угрозы и просто занимайтесь своей работой."
