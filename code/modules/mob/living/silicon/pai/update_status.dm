/mob/living/silicon/pai/update_stat(reason = "none given", should_log = FALSE)
	if(status_flags & GODMODE)
		return ..()
	if(stat != DEAD)
		if(health <= 0)
			death()
			return

		if(HAS_TRAIT(src, TRAIT_KNOCKEDOUT))
			set_stat(UNCONSCIOUS)
		else
			set_stat(CONSCIOUS)

	return ..()

