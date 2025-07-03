SUBSYSTEM_DEF(sun)
	name = "Sun"
	wait = 600
	flags = SS_NO_TICK_CHECK
	init_order = INIT_ORDER_SUN
	offline_implications = "Solar panels will no longer rotate. No immediate action is needed."
	cpu_display = SS_CPUDISPLAY_LOW
	ss_id = "sun"
	var/solar_gen_rate = 1500


/datum/controller/subsystem/sun/Initialize()
	RUSTLIB_CALL(sun_subsystem_initialize)
	return SS_INIT_SUCCESS


/datum/controller/subsystem/sun/get_stat_details()
	return "P:[ATTACHED_SOLAR_CONTROLS_LEN]"


/datum/controller/subsystem/sun/fire()
	return FIRE_SUN_SUBSYSTEM

/datum/controller/subsystem/sun/proc/get_angle()
	return GET_SUN_ANGLE

/datum/controller/subsystem/sun/proc/add_solar(obj/machinery/power/solar_control/solar)
	return TICK_SOLAR_CONTROL(solar)

/datum/controller/subsystem/sun/proc/remove_solar(obj/machinery/power/solar_control/solar)
	return UNTICK_SOLAR_CONTROL(solar)

/datum/controller/subsystem/sun/proc/get_solars_length()
	return ATTACHED_SOLAR_CONTROLS_LEN

/datum/controller/subsystem/sun/proc/get_dy()
	return GET_SUN_DY

/datum/controller/subsystem/sun/proc/get_dx()
	return GET_SUN_DX
