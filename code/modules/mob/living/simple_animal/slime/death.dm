/mob/living/simple_animal/slime/death(gibbed)
	if(stat == DEAD)
		return

	if(buckled)
		Feedstop(stop_message = FALSE) //releases ourselves from the mob we fed on.

	if(!gibbed)
		if(age_state.age != SLIME_BABY)
			if (nutrition >= age_state.hunger_nutrition)
				force_split(FALSE)
				return

	stat = DEAD //Temporarily set to dead for icon updates
	regenerate_icons()
	stat = CONSCIOUS

	return ..(gibbed)

/mob/living/simple_animal/slime/gib()
	death(TRUE)
	qdel(src)
