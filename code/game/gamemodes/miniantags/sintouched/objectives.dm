/datum/objective/sintouched
	completed = TRUE
	needs_target = FALSE

/*  NO ERP OBJECTIVE FOR YOU.
/datum/objective/sintouched/lust
	dangerrating = 3 // it's not AS dangerous.

/datum/objective/sintouched/lust/New()
	var/mob/dead/D = pick(dead_mob_list)
	if(prob(50) && D)
		explanation_text = "You know that [D] has perished.... and you think [D] is kinda cute.  Make sure everyone knows how HOT [D]'s lifeless body is."
	else
		explanation_text = "Go get married, then immediately cheat on your new spouse." */

/datum/objective/sintouched/proc/on_apply(mob/living/carbon/human/human) // separated from New for better call
	if(!istype(human))
		return
		
/datum/objective/sintouched/gluttony
	explanation_text = "Food is delicious, so delicious you can't let it be wasted on other people."

/datum/objective/sintouched/gluttony/on_apply(mob/living/carbon/human/human)
	..()
	human.physiology.hunger_mod += 3
	human.dna.species.species_traits |= NO_OBESITY
	human.mutations |= EATER
	
/datum/objective/sintouched/greed
	explanation_text = "You want MORE, more money, more wealth, more riches.  Go get it, but don't hurt people for it."
	
/datum/objective/sintouched/sloth
	explanation_text = "You just get tired randomly.  Go take a nap at a time that would inconvenience other people."
	
/datum/objective/sintouched/sloth/on_apply(mob/living/carbon/human/human)
	..()
	human.add_or_update_variable_actionspeed_modifier(/datum/actionspeed_modifier/species_tool_mod, multiplicative_slowdown = human.dna.species.toolspeedmod + 1)
	human.add_or_update_variable_actionspeed_modifier(/datum/actionspeed_modifier/species_surgery_mod, multiplicative_slowdown = human.dna.species.surgeryspeedmod + 1)
	human.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/species_speedmod, multiplicative_slowdown = human.dna.species.speed_mod - 0.5)
	
/datum/objective/sintouched/wrath
	explanation_text = "What have your coworkers ever done for you? Don't offer to help them in any matter, and refuse if asked."
	
/datum/objective/sintouched/wrath/on_apply(mob/living/carbon/human/human)
	..()
	var/datum/disease/virus/advance/preset/aggression/disease = new
	human.physiology.punch_damage_low += 5
	human.physiology.punch_damage_high += 10
	disease.Contract(human)

/datum/objective/sintouched/envy
	explanation_text = "Why should you be stuck with your rank? Show everyone you can do other jobs too, and don't let anyone stop you, least of all because you have no training."
	
/datum/objective/sintouched/envy/on_apply(mob/living/carbon/human/human)
	..()
	human.set_species(/datum/species/wryn)
	
/datum/objective/sintouched/pride
	explanation_text = "You are the BEST thing on the station.  Make sure everyone knows it."
	
/datum/objective/sintouched/pride/on_apply(mob/living/carbon/human/human)
	..()
	human.physiology.brute_mod = max(0.1, human.physiology.brute_mod - 0.1)
	human.physiology.tox_mod = max(0.1, human.physiology.tox_mod - 0.1)
	human.physiology.stamina_mod = max(0.1, human.physiology.stamina_mod - 0.1)
	human.physiology.oxy_mod = max(0.1, human.physiology.oxy_mod - 0.1)
	human.physiology.burn_mod = max(0.1, human.physiology.burn_mod - 0.1)

/datum/objective/sintouched/acedia
	explanation_text = "Angels, devils, good, evil... who cares?  Just ignore any hellish threats and do your job."
