/mob/living/carbon/proc/IsStamcrited()
	return HAS_TRAIT_FROM(src, TRAIT_IMMOBILIZED, STAMINA_TRAIT)


/mob/living/carbon/proc/enter_stamcrit()
	if(IsStamcrited()) //Already in stamcrit
		return
	if(!(status_flags & CANWEAKEN))
		return
	if(absorb_status_effect(0, status_effect = WEAKEN)) //continuous effect, so we don't want it to increment the stuns absorbed.
		return
	to_chat(src, span_notice("You're too exhausted to keep going..."))
	add_traits(list(TRAIT_IMMOBILIZED, TRAIT_FLOORED, TRAIT_HANDS_BLOCKED), STAMINA_TRAIT)
	if(getStaminaLoss() < 120) // Puts you a little further into the initial stamcrit, makes stamcrit harder to outright counter with chems.
		adjustStaminaLoss(30, FALSE)
