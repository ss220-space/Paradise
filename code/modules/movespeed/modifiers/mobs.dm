/datum/movespeed_modifier/config_walk_run
	multiplicative_slowdown = 1
	id = MOVESPEED_ID_MOB_WALK_RUN
	flags = IGNORE_NOSLOW


/datum/movespeed_modifier/config_walk_run/proc/sync()


/datum/movespeed_modifier/config_walk_run/walk/sync()
	var/mod = CONFIG_GET(number/movedelay/walk_delay)
	multiplicative_slowdown = isnum(mod)? mod : initial(multiplicative_slowdown)


/datum/movespeed_modifier/config_walk_run/run/sync()
	var/mod = CONFIG_GET(number/movedelay/run_delay)
	multiplicative_slowdown = isnum(mod) ? mod : initial(multiplicative_slowdown)


/datum/movespeed_modifier/mob_config_speedmod
	variable = TRUE
	flags = IGNORE_NOSLOW


/datum/movespeed_modifier/turf_slowdown
	movetypes = GROUND
	blacklisted_movetypes = (FLYING|FLOATING)
	variable = TRUE


/datum/movespeed_modifier/obesity
	multiplicative_slowdown = 1.5
	blacklisted_movetypes = (FLOATING|FLYING)


/datum/movespeed_modifier/obesity_flying
	multiplicative_slowdown = 0.5
	movetypes = FLYING


/datum/movespeed_modifier/hunger
	variable = TRUE
	blacklisted_movetypes = (FLOATING|FLYING)


/datum/movespeed_modifier/cold
	blacklisted_movetypes = FLOATING
	variable = TRUE


/datum/movespeed_modifier/equipment_speedmod
	variable = TRUE
	blacklisted_movetypes = FLOATING


/datum/movespeed_modifier/species_speedmod
	variable = TRUE
	flags = IGNORE_NOSLOW


/datum/movespeed_modifier/simplemob_varspeed
	variable = TRUE
	flags = IGNORE_NOSLOW


/datum/movespeed_modifier/damage_slowdown
	blacklisted_movetypes = (FLOATING|FLYING)
	variable = TRUE


/datum/movespeed_modifier/damage_slowdown_flying
	movetypes = FLYING
	variable = TRUE


/datum/movespeed_modifier/limbless
	variable = TRUE
	movetypes = GROUND
	blacklisted_movetypes = (FLOATING|FLYING)
	//flags = IGNORE_NOSLOW


/datum/movespeed_modifier/fractures
	variable = TRUE
	movetypes = GROUND
	blacklisted_movetypes = (FLOATING|FLYING)


/datum/movespeed_modifier/forced_look
	multiplicative_slowdown = 3
	flags = IGNORE_NOSLOW


/datum/movespeed_modifier/alien_speed
	variable = TRUE
	flags = IGNORE_NOSLOW


/datum/movespeed_modifier/alien_stun_delay
	variable = TRUE


/datum/movespeed_modifier/destroyer_mobility
	multiplicative_slowdown = -2
	movetypes = GROUND
	blacklisted_movetypes = (FLOATING|FLYING)


/datum/movespeed_modifier/robot_vtec_upgrade
	multiplicative_slowdown = -1
	movetypes = GROUND
	blacklisted_movetypes = (FLYING|FLOATING)


/datum/movespeed_modifier/robot_jetpack_upgrade
	multiplicative_slowdown = -1
	movetypes = (FLYING|FLOATING)


/datum/movespeed_modifier/slime_health_mod
	variable = TRUE
	movetypes = GROUND
	blacklisted_movetypes = (FLYING|FLOATING)


/datum/movespeed_modifier/slime_temp_mod
	variable = TRUE
	movetypes = GROUND
	blacklisted_movetypes = (FLYING|FLOATING)


/datum/movespeed_modifier/slime_morphine_mod
	multiplicative_slowdown = 2
	movetypes = GROUND
	blacklisted_movetypes = (FLYING|FLOATING)


/datum/movespeed_modifier/slime_frostoil_mod
	multiplicative_slowdown = 5
	movetypes = GROUND
	blacklisted_movetypes = (FLYING|FLOATING)


/datum/movespeed_modifier/vampire_cloak
	conflicts_with = MOVE_CONFLICT_GOTTAGONOTSOFAST
	multiplicative_slowdown = -0.5
	movetypes = GROUND
	blacklisted_movetypes = (FLYING|FLOATING)


/datum/movespeed_modifier/slaughter_boost
	multiplicative_slowdown = -1
	movetypes = GROUND
	blacklisted_movetypes = (FLYING|FLOATING)


/datum/movespeed_modifier/imp_boost
	multiplicative_slowdown = -1
	movetypes = GROUND
	blacklisted_movetypes = (FLYING|FLOATING)


/datum/movespeed_modifier/dragon_rage
	multiplicative_slowdown = -0.5


/datum/movespeed_modifier/dragon_depression
	multiplicative_slowdown = 5


/datum/movespeed_modifier/gravity
	blacklisted_movetypes = FLOATING
	variable = TRUE
	flags = IGNORE_NOSLOW


/datum/movespeed_modifier/carbon_crawling
	multiplicative_slowdown = 5
	flags = IGNORE_NOSLOW


/datum/movespeed_modifier/mouse_jetpack
	multiplicative_slowdown = -0.5
	movetypes = (FLYING|FLOATING)


/datum/movespeed_modifier/grab_slowdown
	id = MOVESPEED_ID_MOB_GRAB_STATE
	blacklisted_movetypes = FLOATING


/datum/movespeed_modifier/grab_slowdown/aggressive
	multiplicative_slowdown = 3


/datum/movespeed_modifier/grab_slowdown/neck
	multiplicative_slowdown = 6


/datum/movespeed_modifier/grab_slowdown/kill
	multiplicative_slowdown = 9


/datum/movespeed_modifier/bulky_drag
	variable = TRUE
	blacklisted_movetypes = FLOATING


/datum/movespeed_modifier/bulky_push
	variable = TRUE
	blacklisted_movetypes = FLOATING

/datum/movespeed_modifier/borer_leg_focus
	multiplicative_slowdown = -0.25
	movetypes = GROUND
	blacklisted_movetypes = (FLYING|FLOATING)

/datum/movespeed_modifier/borer_leg_focus/lesser
	multiplicative_slowdown = -0.125

/*
/datum/movespeed_modifier/carbon_softcrit
	multiplicative_slowdown = SOFTCRIT_ADD_SLOWDOWN
	flags = IGNORE_NOSLOW

*/

