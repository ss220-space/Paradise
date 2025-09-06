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
	// Lets work out an angle for the "sun" to rotate around the station
	angle = rand (0, 360)			// the station position to the sun is randomised at round start
	rate = rand(50, 200) / 100			// 50% - 200% of standard rotation

	if(prob(50))					// same chance to rotate clockwise than counter-clockwise
		rate = -rate

	// Solar consoles need to load after machines init, so this handles that
	for(var/obj/machinery/power/solar_control/control in solars)
		control.setup()

	return SS_INIT_SUCCESS


/datum/controller/subsystem/sun/get_stat_details()
	return "P:[solars.len]"


/datum/controller/subsystem/sun/fire()
	angle = (360 + angle + rate * 6) % 360	 // increase/decrease the angle to the sun, adjusted by the rate

	// now calculate and cache the (dx,dy) increments for line drawing
	var/ang_sin = sin(angle)
	var/ang_cos = cos(angle)

	if(abs(ang_sin) < abs(ang_cos))
		dx = ang_sin / abs(ang_cos)
		dy = ang_cos / abs(ang_cos)
	else
		dx = ang_sin / abs(ang_sin)
		dy = ang_cos / abs(ang_sin)

	// now tell the solar control computers to update their status and linked devices
	for(var/obj/machinery/power/solar_control/control in solars)
		if(!control.powernet)
			solars.Remove(control)
			continue

		control.update()
