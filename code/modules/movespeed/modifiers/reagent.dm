/datum/movespeed_modifier/reagent
	movetypes = GROUND
	blacklisted_movetypes = (FLYING|FLOATING)
	conflicts_with = MOVE_CONFLICT_GOTTAGOFAST


/datum/movespeed_modifier/reagent/methamphetamine
	multiplicative_slowdown = -1


/datum/movespeed_modifier/reagent/ultra_lube
	multiplicative_slowdown = -1


/datum/movespeed_modifier/reagent/combat_lube
	multiplicative_slowdown = -1


/datum/movespeed_modifier/reagent/stimulative_agent
	multiplicative_slowdown = -1


/datum/movespeed_modifier/reagent/nuka_cola
	conflicts_with = MOVE_CONFLICT_GOTTAGONOTSOFAST
	multiplicative_slowdown = -0.5

