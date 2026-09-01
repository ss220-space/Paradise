/mob/living/carbon/proc/IsStamcrited()
	return HAS_TRAIT_FROM(src, TRAIT_INCAPACITATED, STAMINA_TRAIT)

/mob/living/carbon/proc/enter_stamcrit()
	if(IsStamcrited()) //Already in stamcrit
		return
	apply_status_effect(/datum/status_effect/incapacitating/stamcrit)

