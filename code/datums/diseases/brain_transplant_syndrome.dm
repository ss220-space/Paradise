/// Duration of brain transplant desease
#define BRAIN_TRANSPLANT_SYNDROME_DURATION (10 MINUTES)
/// Duration of initial effects
#define BTS_INITIAL_EFFECTS_DURATION (1 MINUTES)
/// Brain transplant syndrome light effect chance
#define BTS_LIGHT_EFFECT_PROBE 15
/// Brain transplant syndrome medium effect chance
#define BTS_MEDIUM_EFFECT_PROBE 5
/// Brain transplant syndrome heavy effect chance
#define BTS_HEAVY_EFFECT_PROBE 2.5

/** Brain transplantation syndrome
  * - organs failure chance
  * - periodically paralyse whole body
  * - periodically oxy damage
  */
/datum/disease/brain_transplant_syndrome
	name = "Синдром отторжения головного мозга"
	agent = "Иммунная система организма"
	desc = "Дезориентация, удушье, паралич и отказ органов."
	stage_prob = 10
	cure_text = "Нейроматин (иммунодепрессант)"
	var/required_reagent = "neuromatin"
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
		start_time = world.time
		initial_effect()
	if(stage >= 2)
		light_effect()
	if(stage >= 3)
		medium_effect()
	if(stage >= 4)
		heavy_effect()

/datum/disease/brain_transplant_syndrome/proc/initial_effect()
	affected_mob.Knockdown(BTS_INITIAL_EFFECTS_DURATION)
	affected_mob.EyeBlind(BTS_INITIAL_EFFECTS_DURATION)
	affected_mob.Deaf(BTS_INITIAL_EFFECTS_DURATION)
	affected_mob.Stuttering(BTS_INITIAL_EFFECTS_DURATION)

/datum/disease/brain_transplant_syndrome/proc/light_effect()
	if(!prob(BTS_LIGHT_EFFECT_PROBE))
		return
	affected_mob.emote("gasp")
	to_chat(affected_mob, span_userdanger("Вы чувствуете, что вам не хватает воздуха!"))
	affected_mob.apply_damage(10, OXY, spread_damage = TRUE, forced = TRUE)
	affected_mob.adjustBrainLoss(2.5, FALSE)

/datum/disease/brain_transplant_syndrome/proc/medium_effect()
	if(!prob(BTS_MEDIUM_EFFECT_PROBE))
		return
	to_chat(affected_mob, span_userdanger("Вы чувствуете сильное головокружение!"))
	affected_mob.Knockdown(3 SECONDS)
	affected_mob.Confused(15 SECONDS)

/datum/disease/brain_transplant_syndrome/proc/heavy_effect()
	if(!prob(BTS_HEAVY_EFFECT_PROBE))
		return
	if(affected_mob.reagents?.has_reagent(required_reagent))
		to_chat(affected_mob, span_userdanger("Вы чувствуете недомогание!"))
		if(iscarbon(affected_mob))
			var/mob/living/carbon/affected_carbon = affected_mob
			affected_carbon.vomit()
		affected_mob.Confused(15 SECONDS)
		return
	necrotize_organ_effect()

/datum/disease/brain_transplant_syndrome/proc/necrotize_organ_effect()
	to_chat(affected_mob, span_userdanger("Вы чувствуете острую боль внутри!"))
	affected_mob.emote("scream")
	affected_mob.Knockdown(10 SECONDS)
	affected_mob.Jitter(15 SECONDS)
	if(!ishuman(affected_mob))
		return
	var/mob/living/carbon/human/human = affected_mob
	var/list/obj/item/organ/internal/organs = list()
	for(var/obj/item/organ/internal/organ in human.internal_organs)
		if(organ.status & (ORGAN_ROBOT|ORGAN_DEAD))
			continue
		if(organ.slot == INTERNAL_ORGAN_BRAIN || organ.slot == INTERNAL_ORGAN_HEART)
			continue//do not necrotize brain and heart
		organs += organ
	if(!length(organs))
		return
	var/obj/item/organ/internal/select_organ = pick(organs)
	select_organ.necrotize()

/datum/disease/brain_transplant_syndrome/has_cure()
	var/time_delta = world.time - start_time
	return time_delta > BRAIN_TRANSPLANT_SYNDROME_DURATION

#undef BRAIN_TRANSPLANT_SYNDROME_DURATION
#undef BTS_INITIAL_EFFECTS_DURATION
#undef BTS_LIGHT_EFFECT_PROBE
#undef BTS_MEDIUM_EFFECT_PROBE
#undef BTS_HEAVY_EFFECT_PROBE
