/** A simple rudimentary gasmix to information list converter. Can be used for UIs.
 * Args:
 * * gasmix: [/datum/gas_mixture]
 * * name: String used to name the list, optional.
 * Returns: A list parsed_gasmixes with the following structure:
 * - parsed_gasmixes   	Value: Assoc List     Desc: The thing we return
 * -- Key: name        	Value: String         Desc: Gasmix Name
 * -- Key: temperature 	Value: Number         Desc: Temperature in kelvins
 * -- Key: volume      	Value: Number         Desc: Volume in liters
 * -- Key: pressure    	Value: Number         Desc: Pressure in kPa
 * -- Key: oxygen			Value: Number		  Desc: Amount of mols of O2
 * -- Key: carbon_dioxide	Value: Number		  Desc: Amount of mols of CO2
 * -- Key: nitrogen			Value: Number		  Desc: Amount of mols of N2
 * -- Key: toxins			Value: Number		  Desc: Amount of mols of plasma
 * -- Key: sleeping_agent	Value: Number		  Desc: Amount of mols of N2O
 * -- Key: agent_b			Value: Number		  Desc: Amount of mols of agent B
 * -- Key: total_moles		Value: Number		  Desc: Total amount of mols in the mixture
 * Returned list should always be filled with keys even if value are nulls.
 */

//TODO: Port gas_mixture_parser from TG
/proc/gas_mixture_parser(datum/gas_mixture/gasmix, name)
	. = list(
		TLV_O2 = null,
		TLV_CO2 = null,
		TLV_N2 = null,
		TLV_PL = null,
		TLV_N2O = null,
		TLV_AGENT_B = null,
		TLV_H2 = null,
		TLV_H2O = null,
		"name" = format_text(name),
		"total_moles" = null,
		TLV_TEMPERATURE = null,
		"volume" = null,
		TLV_PRESSURE = null,
		"heat_capacity" = null,
		"thermal_energy" = null,
	)
	if(!gasmix)
		return
	.[TLV_O2] = gasmix.oxygen()
	.[TLV_CO2] = gasmix.carbon_dioxide()
	.[TLV_N2] = gasmix.nitrogen()
	.[TLV_PL] = gasmix.toxins()
	.[TLV_N2O] = gasmix.sleeping_agent()
	.[TLV_AGENT_B] = gasmix.agent_b()
	.[TLV_H2] = gasmix.hydrogen()
	.[TLV_H2O] = gasmix.water_vapor()
	.["total_moles"] = gasmix.total_moles()
	.[TLV_TEMPERATURE] = gasmix.temperature()
	.["volume"] = gasmix.volume
	.[TLV_PRESSURE] = gasmix.return_pressure()
	.["heat_capacity"] = display_joules(gasmix.heat_capacity())
	.["thermal_energy"] = display_joules(gasmix.thermal_energy())
