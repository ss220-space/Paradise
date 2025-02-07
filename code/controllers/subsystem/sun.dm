SUBSYSTEM_DEF(sun)
	name = "Sun"
	wait = 600
	flags = SS_NO_TICK_CHECK
	init_order = INIT_ORDER_SUN
	offline_implications = "Solar panels will no longer rotate. No immediate action is needed."
	cpu_display = SS_CPUDISPLAY_LOW
	ss_id = "sun"
	var/angle
	var/dx
	var/dy
	var/rate
	var/list/solars	= list()
	var/solar_gen_rate = 1500


/datum/controller/subsystem/sun/Initialize()
	RUSTLIB_CALL(sun_subsystem_initialize, src)
	return SS_INIT_SUCCESS


/datum/controller/subsystem/sun/get_stat_details()
	return "P:[length(solars)]"


/datum/controller/subsystem/sun/fire()
	RUSTLIB_CALL(sun_subsystem_fire, src)
