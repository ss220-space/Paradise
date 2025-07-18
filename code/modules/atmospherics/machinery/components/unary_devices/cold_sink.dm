/obj/machinery/atmospherics/components/unary/cold_sink
	icon_state = "thermal_plate_cool_map"
	density = TRUE
	use_power = IDLE_POWER_USE

	name = "cold sink"
	desc = "Cools gas when connected to pipe network"

	on = FALSE

	var/current_temperature = T20C
	var/current_heat_capacity = 50000 //totally random

/obj/machinery/atmospherics/components/unary/cold_sink/update_icon_state()
	var/prefix = ""
	if(level == 1 && issimulatedturf(loc))
		prefix = "h"
	icon_state = "[prefix]thermal_plate"

/obj/machinery/atmospherics/components/unary/cold_sink/update_overlays()
	. = ..()
	if(!powered())
		return .
	. += SSair.icon_manager.get_atmos_icon("device", state = "thermal_plate_cool")

/obj/machinery/atmospherics/components/unary/cold_sink/process_atmos()
	..()
	if(!on)
		return FALSE
	var/datum/gas_mixture/air_contents = AIR1
	var/air_heat_capacity = air_contents.heat_capacity()
	var/combined_heat_capacity = current_heat_capacity + air_heat_capacity
	var/old_temperature = air_contents.temperature

	if(combined_heat_capacity > 0)
		var/combined_energy = current_temperature*current_heat_capacity + air_heat_capacity*air_contents.temperature
		air_contents.temperature = combined_energy/combined_heat_capacity

	//todo: have current temperature affected. require power to bring down current temperature again

	if(abs(old_temperature-air_contents.temperature) > 1)
		update_parents()
	return TRUE
