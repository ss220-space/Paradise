/datum/element/diona_internals

/datum/element/diona_internals/Attach(obj/item/organ/internal/internal)
    . = ..()

	if(!istype(internal))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(internal, COMSIG_ORGAN_REMOVED, PROC_REF(transform_organ))

/datum/element/diona_internals/Detach(datum/target)
    . = ..()

    UnregisterSignal(target, COMSIG_ORGAN_REMOVED)

/datum/element/diona_internals/proc/transform_organ(obj/item/organ/internal/internal, mob/owner)
	SIGNAL_HANDLER

	var/mob/living/simple_animal/diona/nymph = new /mob/living/simple_animal/diona(get_turf(owner))
	nymph.health = round(clamp(1 - organ.damage / organ.min_broken_damage, 0, 1) * nymph.maxHealth)

    INVOKE_ASYNC(src, PROC_REF(handle_brain_removal), internal, nymph)
    qdel(internal)

/datum/element/diona_internals/proc/handle_brain_removal(obj/item/organ/internal/brain/brain, mob/owner)
    if(!istype(brain))
        return

    if(!brain.brainmob)
        return

    mob.random_name = FALSE
	mob.real_name = brain.brainmob.real_name
	mob.name = brain.brainmob.real_name

	var/datum/mind/mind = brain.brainmob.mind

    if(mind) // be careful, don't use '?', you'll get runtimes.
	    mind.transfer_to(nymph)

    

    

    