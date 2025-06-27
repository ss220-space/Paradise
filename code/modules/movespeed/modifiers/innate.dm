/datum/movespeed_modifier/bodypart
	movetypes = (~FLYING)
	variable = TRUE


/datum/movespeed_modifier/dna_vault_speedup
	blacklisted_movetypes = (FLYING|FLOATING)
	multiplicative_slowdown = -1

/datum/movespeed_modifier/increaserun
	blacklisted_movetypes = (FLYING|FLOATING)
	multiplicative_slowdown = -0.5
