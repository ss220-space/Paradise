/datum/config_entry/flag/bones_can_break
	default = TRUE

/datum/config_entry/flag/revival_cloning
	default = TRUE

/datum/config_entry/number/revival_brain_life
	default = -1
	integer = FALSE
	min_val = -1

/datum/config_entry/number/revival_pod_plants
	default = 1

/datum/config_entry/flag/auto_toggle_ooc_during_round

/datum/config_entry/number/shuttle_refuel_delay
	default = 12000
	integer = FALSE
	min_val = 0


/datum/config_entry/keyed_list/multiplicative_movespeed
	key_mode = KEY_MODE_TYPE
	value_mode = VALUE_MODE_NUM


/datum/config_entry/keyed_list/multiplicative_movespeed/ValidateAndSet()
	. = ..()
	if(.)
		update_config_movespeed_type_lookup(update_mobs = TRUE)


/datum/config_entry/keyed_list/multiplicative_movespeed/vv_edit_var(var_name, var_value)
	. = ..()
	if(. && (var_name == NAMEOF(src, config_entry_value)))
		update_config_movespeed_type_lookup(update_mobs = TRUE)


/datum/config_entry/number/movedelay //Used for modifying movement speed for mobs.
	abstract_type = /datum/config_entry/number/movedelay


/datum/config_entry/number/movedelay/ValidateAndSet()
	. = ..()
	if(.)
		update_mob_config_movespeeds()


/datum/config_entry/number/movedelay/vv_edit_var(var_name, var_value)
	. = ..()
	if(. && (var_name == NAMEOF(src, config_entry_value)))
		update_mob_config_movespeeds()


/datum/config_entry/number/movedelay/run_delay
	integer = FALSE


/datum/config_entry/number/movedelay/run_delay/ValidateAndSet()
	. = ..()
	var/datum/movespeed_modifier/config_walk_run/M = get_cached_movespeed_modifier(/datum/movespeed_modifier/config_walk_run/run)
	M.sync()


/datum/config_entry/number/movedelay/walk_delay
	integer = FALSE


/datum/config_entry/number/movedelay/walk_delay/ValidateAndSet()
	. = ..()
	var/datum/movespeed_modifier/config_walk_run/M = get_cached_movespeed_modifier(/datum/movespeed_modifier/config_walk_run/walk)
	M.sync()


/datum/config_entry/flag/allow_ai // allow ai job
	default = TRUE

/datum/config_entry/flag/reactionary_explosions //If we use reactionary explosions, explosions that react to walls and doors

/datum/config_entry/flag/allow_random_events // Enables random events mid-round when set

/datum/config_entry/number/traitor_objectives_amount
	default = 2
	min_val = 0

/datum/config_entry/flag/humans_need_surnames

/datum/config_entry/number/bombcap
	default = 14
	min_val = 4

/datum/config_entry/number/bombcap/ValidateAndSet(str_val)
	. = ..()
	if(.)
		GLOB.max_ex_devastation_range = round(config_entry_value / 4)
		GLOB.max_ex_heavy_range = round(config_entry_value / 2)
		GLOB.max_ex_light_range = config_entry_value
		GLOB.max_ex_flash_range = config_entry_value
		GLOB.max_ex_flame_range = config_entry_value

/datum/config_entry/number/cubemonkey_cap
	default = 20
	min_val = 0
