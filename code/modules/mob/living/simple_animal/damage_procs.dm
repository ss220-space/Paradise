
/mob/living/simple_animal/proc/adjustHealth(amount, updating_health = TRUE)
	if(status_flags & GODMODE)
		return FALSE
	var/oldbruteloss = bruteloss
	bruteloss = clamp(bruteloss + amount, 0, maxHealth)
	if(oldbruteloss == bruteloss)
		updating_health = FALSE
		. = STATUS_UPDATE_NONE
	else
		. = STATUS_UPDATE_HEALTH
	if(updating_health)
		updatehealth()
	if(!ckey && !stat && AIStatus == AI_IDLE)//Not unconscious
		toggle_ai(AI_ON)

/mob/living/simple_animal/adjustBruteLoss(amount, updating_health = TRUE)
	if(damage_coeff[BRUTE])
		return adjustHealth(amount * (damage_coeff[BRUTE] + get_vampire_bonus(BRUTE)), updating_health)

/mob/living/simple_animal/adjustFireLoss(amount, updating_health)
	if(damage_coeff[BURN])
		return adjustHealth(amount * (damage_coeff[BURN] + get_vampire_bonus(BURN)), updating_health)

/mob/living/simple_animal/adjustOxyLoss(amount, updating_health)
	if(damage_coeff[OXY])
		return adjustHealth(amount * (damage_coeff[OXY] + get_vampire_bonus(OXY)), updating_health)

/mob/living/simple_animal/adjustToxLoss(amount, updating_health)
	if(damage_coeff[TOX])
		return adjustHealth(amount * (damage_coeff[TOX] + get_vampire_bonus(TOX)), updating_health)

/mob/living/simple_animal/adjustCloneLoss(amount, updating_health)
	if(damage_coeff[CLONE])
		return adjustHealth(amount * (damage_coeff[CLONE] + get_vampire_bonus(CLONE)), updating_health)

/mob/living/simple_animal/adjustStaminaLoss(amount, updating_health)
	if(damage_coeff[STAMINA])
		return ..(amount * (damage_coeff[STAMINA] + get_vampire_bonus(STAMINA)), updating_health)
