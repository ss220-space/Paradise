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

/datum/config_entry/number/run_speed
	default = 0
	integer = FALSE

/datum/config_entry/number/walk_speed
	default = 0
	integer = FALSE

/datum/config_entry/number/human_delay
	default = 0
	integer = FALSE

/datum/config_entry/number/robot_delay
	default = 0
	integer = FALSE

/datum/config_entry/number/monkey_delay
	default = 0
	integer = FALSE

/datum/config_entry/number/alien_delay
	default = 0
	integer = FALSE

/datum/config_entry/number/slime_delay
	default = 0
	integer = FALSE

/datum/config_entry/number/animal_delay
	default = 0
	integer = FALSE

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
