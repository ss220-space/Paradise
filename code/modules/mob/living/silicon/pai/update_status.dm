/mob/living/silicon/pai/update_stat(reason = "none given", should_log = FALSE)
	if(HAS_TRAIT(src, TRAIT_GODMODE))
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


/mob/living/silicon/pai/on_knockedout_trait_loss(datum/source)
	. = ..()
	set_stat(CONSCIOUS)
	update_stat()

