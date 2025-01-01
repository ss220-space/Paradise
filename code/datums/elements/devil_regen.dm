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

    var/obj/item/organ/internal/brain/brain = human.get_organ_slot(INTERNAL_ORGAN_BRAIN)
    brain?.decoy_brain = TRUE	

/datum/element/devil_regeneration/Detach(datum/target)
    . = ..()

    UnregisterSignal(target, COMSIG_CARBON_LOSE_ORGAN)
    UnregisterSignal(target, COMSIG_LIVING_EARLY_DEATH)

    if(!iscarbon(target))
        return

    var/mob/living/carbon/carbon = target
    var/obj/item/organ/internal/brain/brain = carbon.get_organ_slot(INTERNAL_ORGAN_BRAIN)

    brain?.decoy_brain = FALSE	

/datum/element/devil_regeneration/proc/start_regen_bodypart(datum/source, obj/item/organ/organ)
    SIGNAL_HANDLER

    var/obj/item/organ/external/external = organ
    if(!istype(external))
        return
    
    var/mob/living/carbon/human = source
    var/datum/antagonist/devil/devil = human?.mind?.has_antag_datum(/datum/antagonist/devil)

    if(!devil)
        return

    addtimer(CALLBACK(src, PROC_REF(regen_bodypart), human, external, devil), devil.rank.regen_threshold)

/datum/element/devil_regeneration/proc/regen_bodypart(
    mob/living/carbon/human,
    obj/item/organ/external/external,
    datum/antagonist/devil/devil
    )
    external = new external(human)
    human.heal_overall_damage(devil.rank.regen_amount, devil.rank.regen_amount)

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

    if(ishuman(human))
        var/mob/living/carbon/human/mob = human
        mob.check_and_regenerate_organs()

    playsound(get_turf(human), pick(sounds), 50, 0, TRUE)
    update_status(human)

/datum/element/devil_regeneration/proc/update_status(mob/living/carbon/human)
    human.updatehealth()	
    human.UpdateDamageIcon()
