/datum/movespeed_modifier/status_effect
	movetypes = GROUND
	blacklisted_movetypes = (FLYING|FLOATING)


/datum/movespeed_modifier/status_effect/slowed
	variable = TRUE


/datum/movespeed_modifier/status_effect/drowsiness
	variable = TRUE


/datum/movespeed_modifier/status_effect/strained_muscles
	conflicts_with = MOVE_CONFLICT_GOTTAGOFAST
	multiplicative_slowdown = -1


/datum/movespeed_modifier/status_effect/blood_rush
	conflicts_with = MOVE_CONFLICT_GOTTAGOFAST
	multiplicative_slowdown = -1

