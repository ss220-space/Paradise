/mob/living/silicon/ai/update_stat(reason = "none given")
	if(status_flags & GODMODE)
		return ..(reason)
	if(stat != DEAD)
		if(health <= HEALTH_THRESHOLD_DEAD && check_death_method())
			death()
			return
		else if(stat == UNCONSCIOUS)
			WakeUp()
	diag_hud_set_status()

/mob/living/silicon/ai/has_vision(information_only = FALSE)
	return ..() && !lacks_power()
