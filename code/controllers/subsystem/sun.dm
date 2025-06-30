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
	return "P:[get_solars_length()]"


/datum/controller/subsystem/sun/fire()
	RUSTLIB_CALL(sun_subsystem_fire)

/datum/controller/subsystem/sun/proc/get_angle()
	return RUSTLIB_CALL(get_sun_angle)

/datum/controller/subsystem/sun/proc/add_solar(obj/machinery/power/solar_control/solar)
	return RUSTLIB_CALL(add_solar, solar, solar.get_num_uid())

/datum/controller/subsystem/sun/proc/remove_solar(obj/machinery/power/solar_control/solar)
	return RUSTLIB_CALL(remove_solar, solar.get_num_uid())

/datum/controller/subsystem/sun/proc/get_solars_length()
	return RUSTLIB_CALL(get_solars_length)

/datum/controller/subsystem/sun/proc/get_dy()
	return RUSTLIB_CALL(get_sun_dy)

/datum/controller/subsystem/sun/proc/get_dx()
	return RUSTLIB_CALL(get_sun_dx)
