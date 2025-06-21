/datum/element/devil_regeneration
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY|ELEMENT_BESPOKE
	id_arg_index = 2

	var/linked_timer
	var/list/sounds = list('sound/magic/demon_consume.ogg', 'sound/effects/attackblob.ogg')

/datum/element/devil_regeneration/Attach(datum/target)
	. = ..()
	var/mob/living/carbon/human = target

	if(!istype(human) || !human.mind?.has_antag_datum(/datum/antagonist/devil))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(human, COMSIG_CARBON_LOSE_ORGAN, PROC_REF(start_regen_bodypart))
	RegisterSignal(human, COMSIG_LIVING_EARLY_DEATH, PROC_REF(pre_death))
	RegisterSignal(human, COMSIG_LIVING_STATUS_SLEEP, PROC_REF(on_sleep))

	ADD_TRAIT(human, TRAIT_DECOY_BRAIN, DEVIL_TRAIT)
	human.grant_actions_by_list(list(/datum/action/innate/remove_hand))

/datum/element/devil_regeneration/Detach(datum/target)
	. = ..()

	UnregisterSignal(target, COMSIG_CARBON_LOSE_ORGAN)
	UnregisterSignal(target, COMSIG_LIVING_EARLY_DEATH)
	UnregisterSignal(target, COMSIG_LIVING_STATUS_SLEEP)

	if(!iscarbon(target))
		return

	var/mob/living/carbon/carbon = target
	REMOVE_TRAIT(carbon, TRAIT_DECOY_BRAIN, DEVIL_TRAIT)
	var/datum/action/action = locate(/datum/action/innate/remove_hand) in carbon.actions
	if(!action)
		return
	action.Remove(carbon)

/datum/element/devil_regeneration/proc/on_sleep(datum/source, amount)
	return COMPONENT_NO_EFFECT

/datum/element/devil_regeneration/proc/start_regen_bodypart(datum/source, obj/item/organ/organ)
	SIGNAL_HANDLER

	var/obj/item/organ/external/external = organ
	if(!istype(external))
		return

	var/mob/living/carbon/human = source
	var/datum/antagonist/devil/devil = human?.mind?.has_antag_datum(/datum/antagonist/devil)

	if(!devil)
		return

	addtimer(CALLBACK(src, PROC_REF(regen_bodypart), human, external.type, devil), devil.rank.regen_threshold)

/datum/element/devil_regeneration/proc/regen_bodypart(
	mob/living/carbon/human,
	obj/item/organ/external/external,
	datum/antagonist/devil/devil
	)
	external = new external(human, ORGAN_MANIPULATION_DEFAULT)
	human.heal_overall_damage(devil.rank.regen_amount, devil.rank.regen_amount)
	human.CureBlind()
	human.AdjustEyeBlind(-devil.rank.regen_amount)
	playsound(get_turf(human), pick(sounds), 50, 0, TRUE)
	update_status(human)

/datum/element/devil_regeneration/proc/pre_death(datum/source, gibbed)
	SIGNAL_HANDLER

	if(gibbed || linked_timer)
		return

	var/mob/living/carbon/human = source
	var/datum/antagonist/devil/devil = human?.mind?.has_antag_datum(/datum/antagonist/devil)

	if(!devil)
		return

	to_chat(human, span_revenbignotice("Сверхъестественные силы предотвращают вашу смерть."))
	playsound(get_turf(human), 'sound/magic/vampire_anabiosis.ogg', 50, 0, TRUE)

	linked_timer = addtimer(CALLBACK(src, PROC_REF(apply_regeneration), human, devil), devil.rank.regen_threshold, TIMER_LOOP | TIMER_STOPPABLE | TIMER_DELETE_ME)

/datum/element/devil_regeneration/proc/on_revive()
	if(!linked_timer)
		return

	deltimer(linked_timer)
	linked_timer = null

/datum/element/devil_regeneration/proc/apply_regeneration(mob/living/carbon/human, datum/antagonist/devil/devil)

	if(QDELETED(human))
		on_revive()
		return

	if(human.health >= human.maxHealth)
		on_revive()

	human.setOxyLoss(0)
	human.heal_damages(
		devil.rank.regen_amount,
		devil.rank.regen_amount,
		devil.rank.regen_amount,
		devil.rank.regen_amount,
		devil.rank.regen_amount,
		devil.rank.regen_amount,
		devil.rank.regen_amount,
		devil.rank.regen_amount,
		devil.rank.regen_amount,
		TRUE,
		TRUE
	)

	apply_status_effects(human, devil)
	apply_cure(human, devil)
	var/obj/item/implant/exile = locate(/obj/item/implant) in human.contents

	if(exile)
		qdel(exile)

	for(var/obj/item/organ/internal/organ as anything in human.internal_organs)
		organ.unnecrotize()
		organ.heal_internal_damage(devil.rank.regen_amount, robo_repair = organ.is_robotic())

	for(var/datum/reagent/reagent as anything in human.reagents.reagent_list)
		if(reagent.devil_regen_ignored)
			continue
		human.reagents.remove_reagent(reagent, min(reagent.volume, devil.rank.regen_amount))

	if(ishuman(human))
		var/mob/living/carbon/human/mob = human
		mob.check_and_regenerate_organs()
		mob.set_heartattack(FALSE)
		mob.restore_blood()
		mob.decaylevel = 0
		mob.remove_all_embedded_objects()
		mob.remove_all_parasites()
		for(var/datum/dna/gene/gene as anything in GLOB.dna_genes)
			if(LAZYIN(mob.dna.default_blocks, gene.block))
				continue
			mob.force_gene_block(gene.block, FALSE)

		mob.dna.struc_enzymes = mob.dna.struc_enzymes_original
		for(var/obj/item/organ/external/organ as anything in mob.bodyparts)
			organ.stop_internal_bleeding()
			organ.mend_fracture()



	playsound(get_turf(human), pick(sounds), 50, 0, TRUE)
	update_status(human)

/datum/element/devil_regeneration/proc/apply_cure(mob/living/carbon/human, datum/antagonist/devil/devil)
	human.CureAllDiseases(FALSE)
	human.surgeries.Cut()
	human.set_bodytemperature(human.dna ? human.dna.species.body_temperature : BODYTEMP_NORMAL)
	human.radiation = 0
	human.CureBlind()
	human.CureNearsighted()
	human.CureMute()
	human.CureDeaf()
	human.CureTourettes()
	human.CureEpilepsy()
	human.CureCoughing()
	human.CureNervous()

/datum/element/devil_regeneration/proc/apply_status_effects(mob/living/carbon/human, datum/antagonist/devil/devil)
	human.AdjustSleeping(-devil.rank.regen_amount)
	human.AdjustDisgust(-devil.rank.regen_amount)
	human.AdjustParalysis(-devil.rank.regen_amount, ignore_canparalyze = TRUE)
	human.AdjustStunned(-devil.rank.regen_amount, ignore_canstun = TRUE)
	human.AdjustWeakened(-devil.rank.regen_amount, ignore_canweaken = TRUE)
	human.AdjustSlowedDuration(-devil.rank.regen_amount)
	human.AdjustImmobilized(-devil.rank.regen_amount)
	human.AdjustLoseBreath(-devil.rank.regen_amount)
	human.AdjustDizzy(-devil.rank.regen_amount)
	human.AdjustJitter(-devil.rank.regen_amount)
	human.AdjustStuttering(-devil.rank.regen_amount)
	human.AdjustConfused(-devil.rank.regen_amount)
	human.AdjustDrowsy(-devil.rank.regen_amount)
	human.AdjustDruggy(-devil.rank.regen_amount)
	human.AdjustHallucinate(-devil.rank.regen_amount)
	human.AdjustEyeBlind(-devil.rank.regen_amount)
	human.AdjustEyeBlurry(-devil.rank.regen_amount)
	human.AdjustDeaf(-devil.rank.regen_amount)

/datum/element/devil_regeneration/proc/update_status(mob/living/carbon/human)
	human.updatehealth()
	human.UpdateDamageIcon()
	human.regenerate_icons()
	if(ishuman(human))
		var/mob/living/carbon/human/mob = human
		mob.update_eyes()
		mob.update_dna()


/datum/action/innate/remove_hand
	name = "Оторвать себе руку"
	check_flags = AB_CHECK_CONSCIOUS
	icon_icon = 'icons/mob/human_races/r_human.dmi'
	button_icon_state = "l_arm"


/datum/action/innate/remove_hand/Grant(mob/user)
	if(!ishuman(user))
		return
	. = ..()

/datum/action/innate/remove_hand/Remove(mob/user)
	if(!ishuman(user))
		return
	. = ..()


/datum/action/innate/remove_hand/IsAvailable()
	. = ..()
	if(!ishuman(owner))
		return FALSE

/datum/action/innate/remove_hand/Activate()
	var/mob/living/carbon/human/human = owner
	var/obj/item/organ/external/hand = locate(/obj/item/organ/external/hand) in human.bodyparts
	if(!hand)
		return
	hand.droplimb()
	human.balloon_alert(human, "рука оторвана")
	human.emote_scream()

