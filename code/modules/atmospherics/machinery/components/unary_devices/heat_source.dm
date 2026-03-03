/obj/machinery/atmospherics/unary/heat_reservoir
	icon = 'icons/obj/pipes_and_stuff/atmospherics/cold_sink.dmi'
	icon_state = "old_intact_off"
	density = TRUE

	name = "heat reservoir"
	desc = "Heats gas when connected to pipe network"

	var/current_temperature = T20C
	var/current_heat_capacity = 50000 //totally random

/obj/machinery/atmospherics/unary/heat_reservoir/update_icon_state()
	..()

	if(node)
		icon_state = "old_intact_[on ? ("on") : ("off")]"
	else
		icon_state = "old_exposed"
		on = FALSE

/obj/machinery/atmospherics/unary/heat_reservoir/process_atmos(seconds)
	if(!on)
		return FALSE

	var/air_heat_capacity = air_contents.heat_capacity()
	var/combined_heat_capacity = current_heat_capacity + air_heat_capacity
	var/old_temperature = air_contents.temperature()

	if(combined_heat_capacity > 0)
		var/combined_energy = current_temperature * current_heat_capacity + air_heat_capacity * air_contents.temperature()
		air_contents.set_temperature(combined_energy / combined_heat_capacity)

	//todo: have current temperature affected. require power to bring up current temperature again

	if(abs(old_temperature - air_contents.temperature()) > 1)
		parent.update = TRUE

	return TRUE
