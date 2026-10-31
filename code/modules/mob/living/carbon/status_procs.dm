/mob/living/carbon/proc/IsStamcrited()
	return HAS_TRAIT_FROM(src, TRAIT_INCAPACITATED, STAMINA_TRAIT)

/mob/living/carbon/received_stamina_damage(current_level, amount_actual, amount)
	. = ..()
	var/stam = getStaminaLoss()
	if(stam > DAMAGE_PRECISION && (max_stamina - stam) <= HEALTH_THRESHOLD_CRIT && stat != DEAD)
		apply_status_effect(/datum/status_effect/incapacitating/stamcrit)
