/mob/living/carbon/alien/larva/Life(seconds, times_fired)
	var/old_evo_points = evolution_points
	. = ..()
	if(. && old_evo_points != evolution_points)
		update_icons()


/mob/living/carbon/alien/larva/update_stat(reason = "none given", should_log = FALSE)
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		return ..()
	if(stat != DEAD)
		if(health <= -maxHealth || !get_int_organ(/obj/item/organ/internal/brain))
			death()
			return

		if(HAS_TRAIT(src, TRAIT_KNOCKEDOUT) || getOxyLoss() > 50 || (health <= HEALTH_THRESHOLD_CRIT && check_death_method()))
			set_stat(UNCONSCIOUS)
		else
			set_stat(CONSCIOUS)

	return ..()
