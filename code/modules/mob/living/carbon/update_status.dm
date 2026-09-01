/mob/living/carbon/update_stat(reason = "none given", should_log = FALSE)
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		return ..()
	if(stat != DEAD)
		if(health <= HEALTH_THRESHOLD_DEAD && check_death_method())
			death()
			return
		if(HAS_TRAIT(src, TRAIT_KNOCKEDOUT) || (check_death_method() && getOxyLoss() > 50) || (health <= HEALTH_THRESHOLD_CRIT && check_death_method() && !dna?.species.ignore_critical_condition))
			set_stat(UNCONSCIOUS)
		else
			set_stat(CONSCIOUS)
	return ..()
