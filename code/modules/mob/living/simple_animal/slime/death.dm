/mob/living/simple_animal/slime/death(gibbed)
	if(stat == DEAD)
		return

	if(buckled)
		Feedstop(silent = TRUE) //releases ourselves from the mob we fed on.

	if(!gibbed && age_state.age != SLIME_BABY && nutrition >= get_hunger_nutrition())
		force_split(FALSE)
		return

	return ..(gibbed)

/mob/living/simple_animal/slime/gib()
	death(TRUE)
	qdel(src)
