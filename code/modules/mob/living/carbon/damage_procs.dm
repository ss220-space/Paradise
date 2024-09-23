/mob/living/carbon/adjustToxLoss(
    amount = 0,
	updating_health = TRUE,
	blocked = 0,
	forced = FALSE,
	used_weapon = null,
)
	. = ..()
	if(. == STATUS_UPDATE_NONE)
		return .
	
	if(VOMIT_THRESHOLD_REACHED(src))
		apply_status_effect(STATUS_EFFECT_VOMIT)
		
	return .

/mob/living/carbon/setToxLoss(amount, updating_health = TRUE)
	. = ..()
	if(. == STATUS_UPDATE_NONE)
		return .

	if(VOMIT_THRESHOLD_REACHED(src))
		apply_status_effect(STATUS_EFFECT_VOMIT)

	return .
