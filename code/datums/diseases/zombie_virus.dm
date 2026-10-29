/datum/disease/virus/zombie
	name = "Некротизирующая чума"
	desc = "Этот вирус заражает гуманоидов и сводит их с ума голодом по плоти, наделяя при этом регенеративными способностями."
	max_stages = 7
	spread_flags = BLOOD|BITES
	cure_text = "Противовирусные сыворотки от чумы"
	cures = list()
	agent = ""
	infectable_mobtypes = list(/mob/living/carbon/human)
	severity = DISEASE_SEVERITY_BIOHAZARD
	can_progress_in_dead = TRUE
	carrier = TRUE
	virus_heal_resistant = TRUE
	stage_prob = 100 // It isn't actually 100%, but is instead based on a timer
	cure_prob = 80
	/// How far this particular virus is in being cured (0-4)
	var/cure_stage = 0
	/// Cooldown until the virus can advance to the next stage
	COOLDOWN_DECLARE(stage_timer)
	/// What disease are we passing along to datum/antagonist/zombie
	var/plague_disease
	/// Activate the immediate zombie rot loop
	var/instant_zombie

/datum/disease/virus/zombie/New(chosen_plague, plague_zomb)
	if(!plague_zomb)
		return
	plague_disease = chosen_plague
	instant_zombie = TRUE

/datum/disease/virus/zombie/stage_act()
	if(stage == 8)
		// adminbus for immediate zombie
		var/mob/living/carbon/human/human = affected_mob
		if(!istype(human))
			return FALSE
		for(var/obj/item/organ/limb as anything in human.bodyparts)
			if(!(limb.status & ORGAN_DEAD) && !limb.is_robotic())
				limb.necrotize(TRUE, TRUE)
			if(!HAS_TRAIT(limb, TRAIT_I_WANT_BRAINS_ORGAN))
				ADD_TRAIT(limb, TRAIT_I_WANT_BRAINS_ORGAN, ZOMBIE_TRAIT)

	if(!..())
		return FALSE

	if(HAS_TRAIT(affected_mob, TRAIT_I_WANT_BRAINS))
		SSticker.mode.zombie_infected -= affected_mob
		if(affected_mob.reagents.has_reagent(/datum/reagent/zombie_cure/fourth))
			return
		handle_rot()
		stage = 7
		return FALSE

	SSticker.mode.zombie_infected |= affected_mob
	switch(stage)
		if(1) // cured by lvl 1 cure
			if(prob(4))
				to_chat(affected_mob, span_warning("[pick("Кожа на голове чешется.", "Кожа кажется шелушащейся.")]"))
			else if(prob(5))
				to_chat(affected_mob, span_warning("У вас чешется [pick("спина", "рука", "нога", "локоть", "голова")]."))

		if(2)
			if(prob(2))
				to_chat(affected_mob, span_danger("По задней стенке горла стекает слизь."))
			else if(prob(5))
				to_chat(affected_mob, span_warning("[pick("Вы чувствуете голод.", "Вам хочется чего-нибудь съесть.")]"))

		if(3) // cured by lvl 2 cure
			if(prob(2))
				affected_mob.emote("sneeze")
			else if(prob(2))
				affected_mob.emote("cough")
			else if(prob(5))
				to_chat(affected_mob, span_warning("<i>[pick("Так хочется есть...", "Вы бы убили кого-нибудь за кусок еды...", "Голодные судороги схватывают вас...")]</i>"))
			if(prob(5))
				affected_mob.adjustToxLoss(1)

		if(4) // shows up on medhuds
			if(prob(2))
				affected_mob.emote("stare")
			else if(prob(2))
				affected_mob.emote("drool")
			else if(prob(5))
				to_chat(affected_mob, span_danger("Вы чувствуете, как выступает холодный пот."))
			if(prob(25))
				affected_mob.adjustToxLoss(1)

		if(5, 6)  // 5 is cured by lvl 3 cure. 6+ needs lvl 4 cure
			var/turf/location = get_turf(affected_mob)
			if(location.get_lumcount() >= 0.5)
				if(prob(5))
					to_chat(affected_mob, span_danger("Эти огни кажутся яркими. Жжётся."))
				if(prob(25))
					affected_mob.adjustFireLoss(2)
			if(prob(2))
				affected_mob.emote("drool")
			if(stage == 6 && !affected_mob.reagents.has_reagent(/datum/reagent/zombie_cure/third)) // cure 3 can delay it, but not cure it
				if(prob(10))
					to_chat(affected_mob, span_danger(span_zombie("Вы чувствуете, как ваша плоть гниёт.")))
				if(prob(10) || affected_mob.stat != DEAD)
					handle_rot()
		if(7)
			if(!handle_rot())
				stage = 6
				return

/datum/disease/virus/zombie/try_increase_stage()
	if(!stage_timer)
		COOLDOWN_START(src, stage_timer, 1 MINUTES) // for the first infection
	if(affected_mob.stat != DEAD || !prob(30)) // when the body is dead, it always has a 30% chance to advance regardless
		if(!COOLDOWN_FINISHED(src, stage_timer))
			return
	COOLDOWN_START(src, stage_timer, 1 MINUTES)
	..()


/datum/disease/virus/zombie/proc/handle_rot()
	var/mob/living/carbon/human/human = affected_mob
	if(!istype(human))
		return FALSE
	if(!HAS_TRAIT(affected_mob, TRAIT_I_WANT_BRAINS))
		affected_mob.AddComponent(/datum/component/zombie_regen)
		ADD_TRAIT(affected_mob, TRAIT_I_WANT_BRAINS, ZOMBIE_TRAIT)
		affected_mob.AddElement(/datum/element/braineater)
		affected_mob.med_hud_set_health()
		affected_mob.med_hud_set_status()
		affected_mob.update_hands_HUD()
		human.update_body()
		var/obj/item/organ/internal/zombietumor/tumor = new
		tumor.insert(affected_mob)
		affected_mob.drop_item_ground()

	if(affected_mob.mind && !affected_mob.mind.has_antag_datum(/datum/antagonist/zombie))
		if(HAS_TRAIT(affected_mob, TRAIT_PLAGUE_ZOMBIE))
			var/datum/antagonist/zombie/plague = new /datum/antagonist/zombie(plague_disease)
			plague.silent = TRUE //to prevent the second box from appearing
			plague.wiki_page_name = null
			affected_mob.mind.add_antag_datum(plague)
		else
			affected_mob.mind.add_antag_datum(/datum/antagonist/zombie)

	for(var/obj/item/organ/limb as anything in human.bodyparts)
		if(!(limb.status & ORGAN_DEAD) && !limb.vital && !limb.is_robotic())
			limb.necrotize()
		if(!HAS_TRAIT(limb, TRAIT_I_WANT_BRAINS_ORGAN))
			ADD_TRAIT(limb, TRAIT_I_WANT_BRAINS_ORGAN, ZOMBIE_TRAIT)
			return FALSE

	for(var/obj/item/organ/limb as anything in human.bodyparts)
		if(!(limb.status & ORGAN_DEAD) && !limb.is_robotic())
			limb.necrotize(FALSE, TRUE)
		if(!HAS_TRAIT(limb, TRAIT_I_WANT_BRAINS_ORGAN))
			ADD_TRAIT(limb, TRAIT_I_WANT_BRAINS_ORGAN, ZOMBIE_TRAIT)
			return FALSE

	return TRUE


/datum/disease/virus/zombie/try_reduce_stage()
	if(prob(cure_prob))
		stage = max(stage - 1, 0)

	if(stage <= 0)
		cure()
		return FALSE
	return TRUE

/datum/disease/virus/zombie/proc/update_cure_stage()
	for(var/datum/reagent/zombie_cure/reag in affected_mob.reagents?.reagent_list)
		cure_stage = max(cure_stage, reag.cure_level)
	if(cure_stage)
		var/stages = list("Stabilized", "Weakened", "Faltering", "Suppressed")
		name = "[stages[cure_stage]] [initial(name)]"

/datum/disease/virus/zombie/has_cure()
	update_cure_stage()
	var/required_reagent = (stage + 1) / 2 // stage 1 can be cured by cure 1, stage 3 with 2, stage 5 with 3, stage 7 with 4
	return cure_stage >= required_reagent

/datum/disease/virus/zombie/cure(id, need_immunity)
	var/obj/item/zombie_claw/claws = affected_mob.get_active_hand()
	if(claws)
		claws.attack_self()
	affected_mob.mind?.remove_antag_datum(/datum/antagonist/zombie)
	REMOVE_TRAIT(affected_mob, TRAIT_I_WANT_BRAINS, ZOMBIE_TRAIT)
	affected_mob.RemoveElement(/datum/element/braineater)
	var/mob/living/carbon/human/human = affected_mob
	for(var/obj/item/organ/limb as anything in human.bodyparts)
		if(HAS_TRAIT(limb, TRAIT_I_WANT_BRAINS_ORGAN))
			REMOVE_TRAIT(limb, TRAIT_I_WANT_BRAINS_ORGAN, ZOMBIE_TRAIT)
		if(limb.status & ORGAN_DEAD && !limb.is_robotic())
			limb.unnecrotize()
	for(var/obj/item/organ/internal/zombietumor/tumor in human.internal_organs)
		tumor.remove()
	human.update_body()
	qdel(affected_mob.GetComponent(/datum/component/zombie_regen))
	affected_mob.med_hud_set_health()
	affected_mob.med_hud_set_status()
	return ..()

/datum/disease/virus/zombie/wizard
	spread_flags = NON_CONTAGIOUS
	ignore_immunity = TRUE
	cure_text = "Антимагия"
	show_in_records = FALSE

// this should not be curable. Prevents things like rez wands from un-zombifying your zombs.
/datum/disease/virus/zombie/wizard/cure(id, need_immunity)
	return
