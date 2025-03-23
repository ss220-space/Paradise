/datum/element/devil_banishment
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY|ELEMENT_BESPOKE
	id_arg_index = 2

	var/linked_timer    

/datum/element/devil_banishment/Attach(datum/target)
    . = ..()
    var/mob/living/carbon/human = target

    if(!istype(human) || !human.mind?.has_antag_datum(/datum/antagonist/devil))
        return ELEMENT_INCOMPATIBLE

    RegisterSignal(human, COMSIG_LIVING_EARLY_DEATH, PROC_REF(pre_death))

/datum/element/devil_banishment/Detach(datum/target)
    . = ..()

    UnregisterSignal(target, COMSIG_LIVING_EARLY_DEATH)

/datum/element/devil_banishment/proc/pre_death(datum/source, gibbed)
    SIGNAL_HANDLER

    if(gibbed || linked_timer)
        return

    var/mob/living/carbon/human = source
    var/datum/antagonist/devil/devil = human?.mind?.has_antag_datum(/datum/antagonist/devil)

    if(!devil?.info)
        return
    
    playsound(get_turf(human), 'sound/magic/vampire_anabiosis.ogg', 50, 0, TRUE)
    linked_timer = addtimer(CALLBACK(src, PROC_REF(try_banishment), human, devil), devil.rank.regen_threshold / 2, TIMER_LOOP | TIMER_STOPPABLE | TIMER_DELETE_ME)

/datum/element/devil_banishment/proc/try_banishment(mob/living/carbon/human, datum/antagonist/devil/devil)
    if(human.health >= human.maxHealth)
        stop_banishment_check()
        return

    if(!devil.info.banish.check_banishment())
        return

    human.dust()

/datum/element/devil_banishment/proc/stop_banishment_check()
    if(!linked_timer)
        return
        
    deltimer(linked_timer)
    linked_timer = null
