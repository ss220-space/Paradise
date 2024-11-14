/datum/movespeed_modifier/admin_varedit
	variable = TRUE


/datum/movespeed_modifier/yellow_orb
	conflicts_with = MOVE_CONFLICT_GOTTAGOFAST
	multiplicative_slowdown = -1
	blacklisted_movetypes = (FLYING|FLOATING)

/datum/movespeed_modifier/high_gravity
	multiplicative_slowdown = 1.5
	blacklisted_movetypes = (FLYING|FLOATING)
