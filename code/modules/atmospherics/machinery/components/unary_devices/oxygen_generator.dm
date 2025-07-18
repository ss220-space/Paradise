/obj/machinery/atmospherics/components/unary/oxygen_generator
	icon = 'icons/obj/pipes_and_stuff/atmospherics/oxygen_generator.dmi'
	icon_state = "intact_off"
	density = TRUE

	name = "oxygen generator"
	desc = ""

	dir = SOUTH
	initialize_directions = SOUTH

	on = FALSE

	var/oxygen_content = 10

/obj/machinery/atmospherics/components/unary/oxygen_generator/update_icon_state()
	if(NODE1)
		icon_state = "o2gen_intact"
	else
		icon_state = "o2gen_exposed"
		on = FALSE

/obj/machinery/atmospherics/components/unary/oxygen_generator/update_overlays()
	. = ..()
	if(!on)
		return .
	. += SSair.icon_manager.get_atmos_icon("device", state = "o2gen_on")

/obj/machinery/atmospherics/components/unary/oxygen_generator/New()
	..()
	var/datum/gas_mixture/air_contents = AIR1
	air_contents.volume = 50
	AIR1 = air_contents

/obj/machinery/atmospherics/components/unary/oxygen_generator/process_atmos()
	..()
	if(!on)
		return FALSE

	var/datum/gas_mixture/air_contents = AIR1

	var/total_moles = air_contents.total_moles()

	if(total_moles < oxygen_content)
		var/current_heat_capacity = air_contents.heat_capacity()

		var/added_oxygen = oxygen_content - total_moles

		air_contents.temperature = (current_heat_capacity*air_contents.temperature + 20 * added_oxygen * T0C) / (current_heat_capacity + 20 * added_oxygen)
		air_contents.gases[GAS_O2][MOLES] += added_oxygen

		update_parents()

	return TRUE
