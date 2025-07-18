#define RADIATION_CAPACITY 30000 //Radiation isn't particularly effective (TODO BALANCE)
/obj/machinery/atmospherics/components/unary/thermal_plate
//Based off Heat Reservoir and Space Heater
//Transfers heat between a pipe system and environment, based on which has a greater thermal energy concentration
	icon_state = "thermal_plate_idle_map"

	can_unwrench = TRUE

	name = "thermal tansfer plate"
	desc = "Transfers heat to and from an area"


/obj/machinery/atmospherics/components/unary/thermal_plate/update_icon_state()
	var/prefix = ""
	if(level == 1 && issimulatedturf(loc))
		prefix = "h"
	icon_state = "[prefix]thermal_plate"

/obj/machinery/atmospherics/components/unary/thermal_plate/update_overlays()
	. = ..()
	if(!powered())
		return .
	. += SSair.icon_manager.get_atmos_icon("device", state = "thermal_plate_idle")


/obj/machinery/atmospherics/components/unary/thermal_plate/process_atmos()
	..()

	var/datum/gas_mixture/environment = loc.return_air()

	//Get processable air sample and thermal info from environment

	var/transfer_moles = 0.25 * environment.total_moles()
	var/datum/gas_mixture/external_removed = environment.remove(transfer_moles)

	if(!external_removed)
		return radiate()

	if(external_removed.total_moles() < 10)
		return radiate()

	// Get same info from connected gas

	var/datum/gas_mixture/air_contents = AIR1

	var/internal_transfer_moles = 0.25 * air_contents.total_moles()
	var/datum/gas_mixture/internal_removed = air_contents.remove(internal_transfer_moles)

	if(!internal_removed)
		environment.merge(external_removed)
		return TRUE

	var/combined_heat_capacity = internal_removed.heat_capacity() + external_removed.heat_capacity()
	var/combined_energy = internal_removed.temperature * internal_removed.heat_capacity() + external_removed.heat_capacity() * external_removed.temperature

	if(!combined_heat_capacity)
		combined_heat_capacity = 1

	var/final_temperature = combined_energy / combined_heat_capacity

	external_removed.temperature = final_temperature
	environment.merge(external_removed)

	internal_removed.temperature = final_temperature
	air_contents.merge(internal_removed)

	update_parents()
	return TRUE

/obj/machinery/atmospherics/components/unary/thermal_plate/proc/radiate()
	var/datum/gas_mixture/air_contents = AIR1
	var/internal_transfer_moles = 0.25 * air_contents.total_moles()
	var/datum/gas_mixture/internal_removed = air_contents.remove(internal_transfer_moles)

	if(!internal_removed)
		return TRUE

	var/combined_heat_capacity = internal_removed.heat_capacity() + RADIATION_CAPACITY
	var/combined_energy = internal_removed.temperature * internal_removed.heat_capacity() + (RADIATION_CAPACITY * 6.4)

	var/final_temperature = combined_energy / combined_heat_capacity

	internal_removed.temperature = final_temperature
	air_contents.merge(internal_removed)

	update_parents()

	return TRUE
