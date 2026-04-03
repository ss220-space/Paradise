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

// TODO: Port gas_mixture_parser from TG
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
		TLV_TRITIUM = null,
		TLV_BZ = null,
		TLV_PLUOXIUM = null,
		TLV_MIASMA = null,
		TLV_FREON = null,
		TLV_NITRIUM = null,
		TLV_HEALIUM = null,
		TLV_PROTO_NITRATE = null,
		TLV_ZAUKER = null,
		TLV_HALON = null,
		TLV_HELIUM = null,
		TLV_ANTINOBLIUM = null,
		TLV_HYPERNOBLIUM = null,
		"name" = format_text(name),
		TLV_TOTAL_MOLES = null,
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
	.[TLV_TRITIUM] = gasmix.tritium()
	.[TLV_BZ] = gasmix.bz()
	.[TLV_PLUOXIUM] = gasmix.pluoxium()
	.[TLV_MIASMA] = gasmix.miasma()
	.[TLV_FREON] = gasmix.freon()
	.[TLV_NITRIUM] = gasmix.nitrium()
	.[TLV_HEALIUM] = gasmix.healium()
	.[TLV_PROTO_NITRATE] = gasmix.proto_nitrate()
	.[TLV_ZAUKER] = gasmix.zauker()
	.[TLV_HALON] = gasmix.halon()
	.[TLV_HELIUM] = gasmix.helium()
	.[TLV_ANTINOBLIUM] = gasmix.antinoblium()
	.[TLV_HYPERNOBLIUM] = gasmix.hypernoblium()
	.[TLV_OTHER] = gasmix.total_trace_moles()
	.[TLV_TOTAL_MOLES] = gasmix.total_moles()
	.[TLV_TEMPERATURE] = gasmix.temperature()
	.["volume"] = gasmix.volume
	.[TLV_PRESSURE] = gasmix.return_pressure()
	.["heat_capacity"] = display_joules(gasmix.heat_capacity())
	.["thermal_energy"] = display_joules(gasmix.thermal_energy())


/proc/gas_mixture_parser_faster(datum/gas_mixture/gasmix)
	. = list(
		TLV_O2 = null,
		TLV_CO2 = null,
		TLV_N2 = null,
		TLV_PL = null,
		TLV_N2O = null,
		TLV_AGENT_B = null,
		TLV_H2 = null,
		TLV_H2O = null,
		TLV_TRITIUM = null,
		TLV_BZ = null,
		TLV_PLUOXIUM = null,
		TLV_MIASMA = null,
		TLV_FREON = null,
		TLV_NITRIUM = null,
		TLV_HEALIUM = null,
		TLV_PROTO_NITRATE = null,
		TLV_ZAUKER = null,
		TLV_HALON = null,
		TLV_HELIUM = null,
		TLV_ANTINOBLIUM = null,
		TLV_HYPERNOBLIUM = null,
		TLV_TOTAL_MOLES = null,
		TLV_TEMPERATURE = null,
		TLV_PRESSURE = null,
	)

	.[TLV_O2] = gasmix.oxygen()
	.[TLV_CO2] = gasmix.carbon_dioxide()
	.[TLV_N2] = gasmix.nitrogen()
	.[TLV_PL] = gasmix.toxins()
	.[TLV_N2O] = gasmix.sleeping_agent()
	.[TLV_AGENT_B] = gasmix.agent_b()
	.[TLV_H2] = gasmix.hydrogen()
	.[TLV_H2O] = gasmix.water_vapor()
	.[TLV_TRITIUM] = gasmix.tritium()
	.[TLV_BZ] = gasmix.bz()
	.[TLV_PLUOXIUM] = gasmix.pluoxium()
	.[TLV_MIASMA] = gasmix.miasma()
	.[TLV_FREON] = gasmix.freon()
	.[TLV_NITRIUM] = gasmix.nitrium()
	.[TLV_HEALIUM] = gasmix.healium()
	.[TLV_PROTO_NITRATE] = gasmix.proto_nitrate()
	.[TLV_ZAUKER] = gasmix.zauker()
	.[TLV_HALON] = gasmix.halon()
	.[TLV_HELIUM] = gasmix.helium()
	.[TLV_ANTINOBLIUM] = gasmix.antinoblium()
	.[TLV_HYPERNOBLIUM] = gasmix.hypernoblium()
	.[TLV_OTHER] = gasmix.total_trace_moles()
	.[TLV_TOTAL_MOLES] = gasmix.total_moles()
	.[TLV_TEMPERATURE] = gasmix.temperature()
	.[TLV_PRESSURE] = gasmix.return_pressure()

/proc/register_id(id_tag, atom/object, list/register_in)
	var/datum/weakref/ref = WEAKREF(object)
	/* use this to debug only
	if(id_tag in register_in)
		if(register_in[id_tag] == ref)
			return
		CRASH("Object of type [object.type] with id ([id_tag]) already exist in register list")
	*/
	register_in[id_tag] = ref
