/mob/living/carbon/proc/IsStamcrited()
	return HAS_TRAIT_FROM(src, TRAIT_INCAPACITATED, STAMINA_TRAIT)


/mob/living/carbon/proc/enter_stamcrit()
	if(IsStamcrited()) //Already in stamcrit
		return
	if(check_incapacitating_immunity(CANSTAMCRIT))
		return
	SEND_SIGNAL(src, COMSIG_CARBON_ENTER_STAMCRIT)
	to_chat(src, span_warning("Вы слишком истощены, чтобы передвигаться."))
	add_traits(list(TRAIT_INCAPACITATED, TRAIT_IMMOBILIZED, TRAIT_FLOORED, TRAIT_HANDS_BLOCKED), STAMINA_TRAIT)
	if(getStaminaLoss() < 120) // Puts you a little further into the initial stamcrit, makes stamcrit harder to outright counter with chems.
		adjustStaminaLoss(30, FALSE)


////////////////////////////////////////TRAUMAS/////////////////////////////////////////

/mob/living/carbon/proc/get_traumas()
	. = list()
	var/obj/item/organ/internal/brain/brain = get_organ_slot(INTERNAL_ORGAN_BRAIN)
	if(brain)
		. = brain.traumas

/mob/living/carbon/proc/has_trauma_type(brain_trauma_type, resilience)
	var/obj/item/organ/internal/brain/brain = get_organ_slot(INTERNAL_ORGAN_BRAIN)
	if(brain)
		. = brain.has_trauma_type(brain_trauma_type, resilience)

/mob/living/carbon/proc/gain_trauma(datum/brain_trauma/trauma, resilience, ...)
	var/obj/item/organ/internal/brain/brain = get_organ_slot(INTERNAL_ORGAN_BRAIN)
	if(!brain)
		return

	var/list/arguments = list()
	if(args.len > 2)
		arguments = args.Copy(3)

	. = brain.brain_gain_trauma(trauma, resilience, arguments)

/mob/living/carbon/proc/gain_trauma_type(brain_trauma_type = /datum/brain_trauma, resilience)
	var/obj/item/organ/internal/brain/brain = get_organ_slot(INTERNAL_ORGAN_BRAIN)
	if(!brain)
		return

	. = brain.gain_trauma_type(brain_trauma_type, resilience)

/mob/living/carbon/proc/cure_trauma_type(brain_trauma_type = /datum/brain_trauma, resilience)
	var/obj/item/organ/internal/brain/brain = get_organ_slot(INTERNAL_ORGAN_BRAIN)
	if(!brain)
		return

	. = brain.cure_trauma_type(brain_trauma_type, resilience)

/mob/living/carbon/proc/cure_all_traumas(resilience)
	var/obj/item/organ/internal/brain/brain = get_organ_slot(INTERNAL_ORGAN_BRAIN)
	if(!brain)
		return

	. = brain.cure_all_traumas(resilience)
