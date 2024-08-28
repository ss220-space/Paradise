/mob/living/carbon/register_init_signals()
	. = ..()

	RegisterSignal(src, list(SIGNAL_ADDTRAIT(TRAIT_NO_SCAN), SIGNAL_REMOVETRAIT(TRAIT_NO_SCAN)), PROC_REF(on_no_scan))


/// Called when [TRAIT_NO_SCAN] is gained or lost
/mob/living/carbon/proc/on_no_scan(datum/source)
	SIGNAL_HANDLER

	var/obj/item/organ/internal/brain/brain = get_int_organ(/obj/item/organ/internal/brain)
	if(!brain)
		return

	if(HAS_TRAIT(src, TRAIT_NO_SCAN))
		ADD_TRAIT(brain, TRAIT_NO_SCAN, DNA_TRAIT)
	else
		REMOVE_TRAIT(brain, TRAIT_NO_SCAN, DNA_TRAIT)


