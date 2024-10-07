/mob/living/carbon/update_stat(reason = "none given", should_log = FALSE)
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		return ..()
	if(stat != DEAD)
		if(health <= HEALTH_THRESHOLD_DEAD && check_death_method())
			death()
			return
		if(HAS_TRAIT(src, TRAIT_KNOCKEDOUT) || (check_death_method() && getOxyLoss() > 50) || (health <= HEALTH_THRESHOLD_CRIT && check_death_method()))
			set_stat(UNCONSCIOUS)
		else
			set_stat(CONSCIOUS)
	return ..()


/mob/living/carbon/update_stamina()
	var/stam = getStaminaLoss()
	if(stam > DAMAGE_PRECISION && (maxHealth - stam) <= HEALTH_THRESHOLD_CRIT)
		if(!stat)
			enter_stamcrit()
	else if(IsStamcrited())
		remove_traits(list(TRAIT_INCAPACITATED, TRAIT_IMMOBILIZED, TRAIT_FLOORED, TRAIT_HANDS_BLOCKED), STAMINA_TRAIT)
	else
		return
	update_stamina_hud()


/mob/living/carbon/can_hear()
	. = ..()
	var/obj/item/organ/internal/ears/ears = get_organ_slot(INTERNAL_ORGAN_EARS)
	if(!ears)
		return FALSE

