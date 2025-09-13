/** Brain transplantation syndrome
  * - organs failure chance
  * - periodically paralyse whole body
  * - periodically oxy damage
  */
/datum/disease/brain_transplant_syndrome
	name = "Синдром клоновой амнезии"
	agent = "Иммунитет"
	desc = "Дизориентация, удушье, паралич и отказ органов."
	stage_prob = 5
	cure_prob = 8
	cure_text = "Реагент" //TODO special reagent
	cures = list("chicken_soup") //TODO special reagent
	severity = NONTHREAT
	can_immunity = FALSE
	ignore_immunity = TRUE
	visibility_flags = HIDDEN_PANDEMIC
	can_contract_dead = TRUE
	var/initial_effect_apllyed = FALSE
	var/start_time = 0

/datum/disease/brain_transplant_syndrome/stage_act()
	if(!..())
		return FALSE

	if(!initial_effect_apllyed)
		initial_effect_apllyed = TRUE
		affected_mob.Immobilize(60 SECONDS)
		affected_mob.EyeBlind(60 SECONDS)
		affected_mob.Deaf(60 SECONDS)
		affected_mob.Stuttering(60 SECONDS)
		start_time = world.time

	if(stage >= 2 && prob(15))
		affected_mob.emote("choke")
		to_chat(affected_mob, span_danger("Вы чувствуете, что вам не хватает воздуха!"))
		affected_mob.apply_damage(15, OXY, spread_damage = TRUE, forced = TRUE)

	if(stage >= 3 && prob(10))
		to_chat(affected_mob, span_danger("Вы чувствуете сильное головокружение!"))
		affected_mob.Confused(30 SECONDS)

	if(stage >= 4 && prob(5))
		to_chat(affected_mob, span_danger("Вы чувствуете, острую боль внутри!"))
		affected_mob.emote("scream")
		affected_mob.Knockdown(10 SECONDS)
		affected_mob.Jitter(10 SECONDS)
		if(!ishuman(affected_mob))
			return
		var/mob/living/carbon/human/human = affected_mob
		var/list/obj/item/organ/internal/organs = list()
		for(var/obj/item/organ/internal/organ in human.internal_organs)
			if(organ.status & (ORGAN_ROBOT|ORGAN_DEAD))
				continue
			if(istype(organ, /obj/item/organ/internal/brain))
				continue //do not necrotize brain
			organs += organ
		if(!length(organs))
			return
		var/obj/item/organ/internal/select_organ = pick(organs)
		select_organ.necrotize()


/datum/disease/brain_transplant_syndrome/has_cure()
	. = ..()
	if(!.)
		return
	var/time_delta = world.time - start_time
	return time_delta > 20 MINUTES
