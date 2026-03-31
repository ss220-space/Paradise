/datum/atmosphere
	var/env_id
	var/id

	var/list/base_gases // A list of gases to always have
	var/list/normal_gases // A list of allowed gases:base_amount
	var/list/restricted_gases // A list of allowed gases like normal_gases but each can only be selected a maximum of one time
	var/restricted_chance = 10 // Chance per iteration to take from restricted gases

	var/minimum_pressure
	var/maximum_pressure

	var/minimum_temp
	var/maximum_temp

/datum/atmosphere/New()
	generate_env()

/proc/calculate_pressure(list/template)
	var/total_moles = 0
	for(var/key, value in template)
		if(key == ATMOSPHERE_TEMPERATURE)
			continue
		total_moles += value
	return total_moles * R_IDEAL_GAS_EQUATION * template[ATMOSPHERE_TEMPERATURE] / CELL_VOLUME

/datum/atmosphere/proc/generate_env()

	var/list/spicy_gas = restricted_gases.Copy()
	var/target_pressure = rand(minimum_pressure, maximum_pressure)
	var/pressure_scalar = target_pressure / maximum_pressure
	var/list/gas_template = list(
		ATMOSPHERE_OXYGEN = 0,
		ATMOSPHERE_CARBON_DIOXIDE = 0,
		ATMOSPHERE_NITROGEN = 0,
		ATMOSPHERE_TOXINS = 0,
		ATMOSPHERE_SLEEPING_AGENT = 0,
		ATMOSPHERE_AGENT_B = 0,
		ATMOSPHERE_HYDROGEN = 0,
		ATMOSPHERE_WATER_VAPOR = 0,
		ATMOSPHERE_TRITIUM = 0,
		ATMOSPHERE_BZ = 0,
		ATMOSPHERE_PLUOXIUM = 0,
		ATMOSPHERE_MIASMA = 0,
		ATMOSPHERE_FREON = 0,
		ATMOSPHERE_NITRIUM = 0,
		ATMOSPHERE_HEALIUM = 0,
		ATMOSPHERE_PROTO_NITRATE = 0,
		ATMOSPHERE_ZAUKER = 0,
		ATMOSPHERE_HALON = 0,
		ATMOSPHERE_HELIUM = 0,
		ATMOSPHERE_ANTINOBLIUM = 0,
		ATMOSPHERE_HYPERNOBLIUM = 0,
		ATMOSPHERE_TEMPERATURE = 0,
	)
	/*
	if(HAS_TRAIT(SSstation, STATION_TRAIT_UNNATURAL_ATMOSPHERE))
		restricted_chance = restricted_chance + 40
	*/
	// First let's set up the gasmix and base gases for this template
	// We make the string from a gasmix in this proc because gases need to calculate their pressure
	gas_template[ATMOSPHERE_TEMPERATURE] = rand(minimum_temp, maximum_temp)
	for(var/i in base_gases)
		gas_template[i] = base_gases[i]

	// Now let the random choices begin
	var/gastype
	var/amount

	if(length(spicy_gas) || length(normal_gases))
		while(calculate_pressure(gas_template) < target_pressure)
			if(!prob(restricted_chance) || !length(spicy_gas))
				gastype = pick(normal_gases)
				amount = normal_gases[gastype]
			else
				gastype = pick(spicy_gas)
				amount = spicy_gas[gastype]
				spicy_gas -= gastype //You can only pick each restricted gas once

			amount *= rand(50, 200) / 100 // Randomly modifes the amount from half to double the base for some variety
			amount *= pressure_scalar // If we pick a really small target pressure we want roughly the same mix but less of it all
			amount = CEILING(amount, 0.1)

			gas_template[gastype] += amount

	// Ensure that minimum_pressure is actually a hard lower limit
	target_pressure = clamp(target_pressure, minimum_pressure + (gas_template[gastype] * 0.1), maximum_pressure)

	// That last one put us over the limit, remove some of it
	if(gastype)
		while(calculate_pressure(gas_template) > target_pressure)
			gas_template[gastype] -= gas_template[gastype] * 0.1
		gas_template[gastype] = FLOOR(gas_template[gastype], 0.1)

	env_id = create_environment(arglist(gas_template))
