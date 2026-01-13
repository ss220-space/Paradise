/*
What are the archived variables for?
	Calculations are done using the archived variables with the results merged into the regular variables.
	This prevents race conditions that arise based on the order of tile processing.
*/

#define SPECIFIC_HEAT_TOXIN 200
#define SPECIFIC_HEAT_AIR 20
#define SPECIFIC_HEAT_CDO 30
#define SPECIFIC_HEAT_N2O 40
#define SPECIFIC_HEAT_AGENT_B 300
#define SPECIFIC_HEAT_HYDROGEN 15
#define SPECIFIC_HEAT_WATER_VAPOR 33

#define HEAT_CAPACITY_CALCULATION(oxygen, carbon_dioxide, nitrogen, toxins, sleeping_agent, agent_b, hydrogen, water_vapor, innate_heat_capacity) \
	(carbon_dioxide * SPECIFIC_HEAT_CDO + \
	(oxygen + nitrogen) * SPECIFIC_HEAT_AIR + \
	toxins * SPECIFIC_HEAT_TOXIN + \
	sleeping_agent * SPECIFIC_HEAT_N2O + \
	agent_b * SPECIFIC_HEAT_AGENT_B + \
	hydrogen * SPECIFIC_HEAT_HYDROGEN + \
	water_vapor * SPECIFIC_HEAT_WATER_VAPOR + \
	innate_heat_capacity)

#define MINIMUM_HEAT_CAPACITY 0.0003
#define MINIMUM_MOLE_COUNT 0.01
#define QUANTIZE(variable) (round(variable, 0.0001))

/datum/gas_mixture
	/// The volume this gas mixture fills.
	var/volume = CELL_VOLUME
	/// Heat capacity intrinsic to the container of this gas mixture.
	var/innate_heat_capacity = 0
	/// How much fuel this gas mixture burnt last reaction.
	var/fuel_burnt = 0

	// Private fields. Use the matching procs to get and set them.
	// e.g. GM.oxygen(), GM.set_oxygen()
	var/private_oxygen = 0
	var/private_carbon_dioxide = 0
	var/private_nitrogen = 0
	var/private_toxins = 0
	var/private_sleeping_agent = 0
	var/private_agent_b = 0
	var/private_hydrogen = 0
	var/private_water_vapor = 0
	var/private_temperature = 0 //in Kelvin

	// Archived versions of the private fields.
	// Only gas_mixture should use these.
	var/private_oxygen_archived = 0
	var/private_carbon_dioxide_archived = 0
	var/private_nitrogen_archived = 0
	var/private_toxins_archived = 0
	var/private_sleeping_agent_archived = 0
	var/private_agent_b_archived = 0
	var/private_hydrogen_archived = 0
	var/private_water_vapor_archived = 0
	var/private_temperature_archived = 0

	var/private_hotspot_temperature = 0
	var/private_hotspot_volume = 0
	var/private_fuel_burnt = 0

	/// Is this mixture currently synchronized with MILLA? Always true for non-bound mixtures.
	var/synchronized = TRUE

/// Marks this gas mixture as changed from MILLA. Does nothing on non-bound mixtures.
/datum/gas_mixture/proc/set_dirty()
	return

/datum/gas_mixture/proc/oxygen()
	return private_oxygen

/datum/gas_mixture/proc/set_oxygen(value)
	if(isnan(value) || !isnum(value))
		CRASH("Bad value: [value]")
	var/clamped = clamp(value, 0, 1e10)
	if(value != clamped)
		stack_trace("Out-of-bounds value [value] clamped to [clamped].")
	private_oxygen = clamped

/datum/gas_mixture/proc/carbon_dioxide()
	return private_carbon_dioxide

/datum/gas_mixture/proc/set_carbon_dioxide(value)
	if(isnan(value) || !isnum(value))
		CRASH("Bad value: [value]")
	var/clamped = clamp(value, 0, 1e10)
	if(value != clamped)
		stack_trace("Out-of-bounds value [value] clamped to [clamped].")
	private_carbon_dioxide = clamped

/datum/gas_mixture/proc/nitrogen()
	return private_nitrogen

/datum/gas_mixture/proc/set_nitrogen(value)
	if(isnan(value) || !isnum(value))
		CRASH("Bad value: [value]")
	var/clamped = clamp(value, 0, 1e10)
	if(value != clamped)
		stack_trace("Out-of-bounds value [value] clamped to [clamped].")
	private_nitrogen = clamped

/datum/gas_mixture/proc/toxins()
	return private_toxins

/datum/gas_mixture/proc/set_toxins(value)
	if(isnan(value) || !isnum(value))
		CRASH("Bad value: [value]")
	var/clamped = clamp(value, 0, 1e10)
	if(value != clamped)
		stack_trace("Out-of-bounds value [value] clamped to [clamped].")
	private_toxins = clamped

/datum/gas_mixture/proc/sleeping_agent()
	return private_sleeping_agent

/datum/gas_mixture/proc/set_sleeping_agent(value)
	if(isnan(value) || !isnum(value))
		CRASH("Bad value: [value]")
	var/clamped = clamp(value, 0, 1e10)
	if(value != clamped)
		stack_trace("Out-of-bounds value [value] clamped to [clamped].")
	private_sleeping_agent = clamped

/datum/gas_mixture/proc/agent_b()
	return private_agent_b

/datum/gas_mixture/proc/set_agent_b(value)
	if(isnan(value) || !isnum(value))
		CRASH("Bad value: [value]")
	var/clamped = clamp(value, 0, 1e10)
	if(value != clamped)
		stack_trace("Out-of-bounds value [value] clamped to [clamped].")
	private_agent_b = clamped

/datum/gas_mixture/proc/hydrogen()
	return private_hydrogen

/datum/gas_mixture/proc/set_hydrogen(value)
	if(isnan(value) || !isnum(value))
		CRASH("Bad value: [value]")
	var/clamped = clamp(value, 0, 1e10)
	if(value != clamped)
		stack_trace("Out-of-bounds value [value] clamped to [clamped].")
	private_hydrogen = clamped

/datum/gas_mixture/proc/water_vapor()
	return private_water_vapor

/datum/gas_mixture/proc/set_water_vapor(value)
	if(isnan(value) || !isnum(value))
		CRASH("Bad value: [value]")
	var/clamped = clamp(value, 0, 1e10)
	if(value != clamped)
		stack_trace("Out-of-bounds value [value] clamped to [clamped].")
	private_water_vapor = clamped

/datum/gas_mixture/proc/temperature()
	return private_temperature

/datum/gas_mixture/proc/set_temperature(value)
	if(isnan(value) || !isnum(value))
		CRASH("Bad value: [value]")
	var/clamped = clamp(value, 0, 1e10)
	if(value != clamped)
		stack_trace("Out-of-bounds value [value] clamped to [clamped].")
	private_temperature = clamped

/datum/gas_mixture/proc/hotspot_temperature()
	return private_hotspot_temperature

/datum/gas_mixture/proc/hotspot_volume()
	return private_hotspot_volume

/datum/gas_mixture/proc/fuel_burnt()
	return private_fuel_burnt

/// PV=nRT - related procedures
/datum/gas_mixture/proc/heat_capacity()
	return HEAT_CAPACITY_CALCULATION(private_oxygen, private_carbon_dioxide, private_nitrogen, private_toxins, private_sleeping_agent, private_agent_b, private_hydrogen, private_water_vapor, innate_heat_capacity)

/datum/gas_mixture/proc/heat_capacity_archived()
	return HEAT_CAPACITY_CALCULATION(private_oxygen_archived, private_carbon_dioxide_archived, private_nitrogen_archived, private_toxins_archived, private_sleeping_agent_archived, private_agent_b_archived, private_hydrogen_archived, private_water_vapor_archived, innate_heat_capacity)

/// Calculate moles
/datum/gas_mixture/proc/total_moles()
	return private_oxygen + private_carbon_dioxide + private_nitrogen + private_toxins + private_sleeping_agent + private_agent_b + private_hydrogen + private_water_vapor

/datum/gas_mixture/proc/total_trace_moles()
	var/moles = private_agent_b
	return moles

/datum/gas_mixture/proc/return_pressure()
	if(volume > 0)
		return total_moles() * R_IDEAL_GAS_EQUATION * private_temperature / volume
	return 0

/datum/gas_mixture/proc/return_volume()
	return max(0, volume)

/datum/gas_mixture/proc/thermal_energy()
	return private_temperature * heat_capacity()


/datum/gas_mixture/proc/return_visuals(z)
	var/list/result = list()
	if(private_toxins > MOLES_PLASMA_VISIBLE)
		result += GLOB.plmaster["[GET_Z_PLANE_OFFSET(z)]"]

	if(private_sleeping_agent > 1)
		result += GLOB.slmaster["[GET_Z_PLANE_OFFSET(z)]"]

	if(private_water_vapor > MOLES_WATER_VAPOR_VISIBLE)
		result += GLOB.wvmaster["[GET_Z_PLANE_OFFSET(z)]"]
	return result

//Procedures used for very specific events

/datum/gas_mixture/proc/react(atom/dump_location)
	var/reacting = FALSE //set to TRUE if a notable reaction occured (used by pipe_network)
	if((private_agent_b > MINIMUM_MOLE_COUNT) && private_temperature > AGENT_B_CONVERSION_MIN_TEMP)
		if(private_toxins > MINIMUM_HEAT_CAPACITY && private_carbon_dioxide > MINIMUM_HEAT_CAPACITY)
			var/reaction_rate = min(private_carbon_dioxide * 0.75, private_toxins * 0.25, private_agent_b * 0.05)
			var/old_heat_capacity = heat_capacity()
			var/energy_released = reaction_rate * AGENT_B_CONVERSION_ENERGY_RELEASED
			private_carbon_dioxide -= reaction_rate
			private_oxygen += reaction_rate
			private_agent_b -= reaction_rate * 0.05
			var/new_heat_capacity = heat_capacity()
			if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
				private_temperature = (private_temperature * old_heat_capacity + energy_released) / new_heat_capacity
			reacting = TRUE
	if((private_sleeping_agent > MINIMUM_MOLE_COUNT) && private_temperature > N2O_DECOMPOSITION_MIN_ENERGY)
		var/energy_released = 0
		var/old_heat_capacity = heat_capacity()
		var/burned_fuel = 0
		burned_fuel = min((1 - (N2O_DECOMPOSITION_COEFFICIENT_A  / ((private_temperature + N2O_DECOMPOSITION_COEFFICIENT_C) ** 2))) * private_sleeping_agent, private_sleeping_agent)
		private_sleeping_agent -= burned_fuel
		if(burned_fuel)
			energy_released += (N2O_DECOMPOSITION_ENERGY_RELEASED * burned_fuel)
			private_oxygen += burned_fuel * 0.5
			private_nitrogen += burned_fuel
			var/new_heat_capacity = heat_capacity()
			if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
				private_temperature = (private_temperature * old_heat_capacity + energy_released) / new_heat_capacity
			reacting = TRUE
	fuel_burnt = 0
	//Handle plasma burning
	if((private_toxins > MINIMUM_MOLE_COUNT) && (private_oxygen > MINIMUM_MOLE_COUNT) && private_temperature > FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
		var/energy_released = 0
		var/old_heat_capacity = heat_capacity()
		var/plasma_burn_rate = 0
		var/private_oxygen_burn_rate = 0
		//more plasma released at higher temperatures
		var/private_temperature_scale = 0
		if(private_temperature > PLASMA_UPPER_TEMPERATURE)
			private_temperature_scale = 1
		else
			private_temperature_scale = (private_temperature - PLASMA_MINIMUM_BURN_TEMPERATURE) / (PLASMA_UPPER_TEMPERATURE - PLASMA_MINIMUM_BURN_TEMPERATURE)
		if(private_temperature_scale > 0)
			private_oxygen_burn_rate = OXYGEN_BURN_RATE_BASE - private_temperature_scale
			if(private_oxygen > private_toxins * PLASMA_OXYGEN_FULLBURN)
				plasma_burn_rate = (private_toxins * private_temperature_scale) / PLASMA_BURN_RATE_DELTA
			else
				plasma_burn_rate = (private_temperature_scale * (private_oxygen / PLASMA_OXYGEN_FULLBURN)) / PLASMA_BURN_RATE_DELTA
			if(plasma_burn_rate > MINIMUM_HEAT_CAPACITY)
				plasma_burn_rate = min(plasma_burn_rate, private_toxins, private_oxygen / private_oxygen_burn_rate) //Ensures matter is conserved properly
				private_toxins = QUANTIZE(private_toxins - plasma_burn_rate)
				private_oxygen = QUANTIZE(private_oxygen - (plasma_burn_rate * private_oxygen_burn_rate))
				private_carbon_dioxide += plasma_burn_rate
				energy_released += FIRE_PLASMA_ENERGY_RELEASED * (plasma_burn_rate)
				fuel_burnt += (plasma_burn_rate) * (1 + private_oxygen_burn_rate)
		if(energy_released > 0)
			var/new_heat_capacity = heat_capacity()
			if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
				private_temperature = (private_temperature * old_heat_capacity + energy_released) / new_heat_capacity
		if(fuel_burnt)
			reacting = TRUE

		// handles hydrogen burning
	if((private_hydrogen >= 0) && (private_oxygen >= 0) && private_temperature > HYDROGEN_MIN_IGNITE_TEMP)
		// Calculate the reaction rate based on temperature and pressure
		var/reaction_rate = (private_temperature / (private_temperature + 2000)) * (return_pressure() / (return_pressure() + 100))
		// Burn a portion of our hydrogen equal to reaction_rate, but no more than we have or have oxygen for.
		var/burned_hydrogen = min(reaction_rate * private_hydrogen, private_hydrogen, private_oxygen * 2)
		var/burned_oxygen = min(burned_hydrogen / 2, private_oxygen)
		var/produced_water_vapor = (burned_hydrogen / H2_NEEDED_FOR_H2O)


		var/old_heat_capacity = heat_capacity()

		// Burn gasses
		private_hydrogen -= burned_hydrogen
		private_oxygen -= burned_oxygen
		private_water_vapor += produced_water_vapor

		// Calculate gained energy
		var/energy_released = HYDROGEN_BURN_ENERGY * burned_hydrogen
		// Calculate post-burn heat capacity
		var/new_heat_capacity = heat_capacity()
		// Calculate new temperature
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			private_temperature = (private_temperature * old_heat_capacity + energy_released) / new_heat_capacity

		if(fuel_burnt)
			reacting = TRUE

	set_dirty()
	return reacting

/datum/gas_mixture/proc/archive()
	private_oxygen_archived = private_oxygen
	private_carbon_dioxide_archived = private_carbon_dioxide
	private_nitrogen_archived =  private_nitrogen
	private_toxins_archived = private_toxins
	private_sleeping_agent_archived = private_sleeping_agent
	private_agent_b_archived = private_agent_b
	private_hydrogen_archived = private_hydrogen
	private_water_vapor_archived = private_water_vapor

	private_temperature_archived = private_temperature

	return TRUE

/datum/gas_mixture/proc/merge(datum/gas_mixture/giver)
	if(!giver)
		return 0

	if(abs(private_temperature - giver.private_temperature) > MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER)
		var/self_heat_capacity = heat_capacity()
		var/giver_heat_capacity = giver.heat_capacity()
		var/combined_heat_capacity = giver_heat_capacity + self_heat_capacity
		if(combined_heat_capacity != 0)
			private_temperature = (giver.private_temperature * giver_heat_capacity + private_temperature * self_heat_capacity) / combined_heat_capacity

	private_oxygen += giver.private_oxygen
	private_carbon_dioxide += giver.private_carbon_dioxide
	private_nitrogen += giver.private_nitrogen
	private_toxins += giver.private_toxins
	private_sleeping_agent += giver.private_sleeping_agent
	private_agent_b += giver.private_agent_b
	private_hydrogen += giver.private_hydrogen
	private_water_vapor += giver.private_water_vapor

	set_dirty()

	return TRUE

/// Only removes the gas if we have more than the amount
/datum/gas_mixture/proc/boolean_remove(amount)
	if(amount > total_moles())
		return FALSE
	return remove(amount)

/datum/gas_mixture/proc/remove(amount)

	var/sum = total_moles()
	amount = min(amount, sum) //Can not take more air than tile has!
	if(amount <= 0)
		return null

	var/datum/gas_mixture/removed = new

	removed.private_oxygen = QUANTIZE((private_oxygen / sum) * amount)
	removed.private_nitrogen = QUANTIZE((private_nitrogen/  sum) * amount)
	removed.private_carbon_dioxide = QUANTIZE((private_carbon_dioxide / sum) * amount)
	removed.private_toxins = QUANTIZE((private_toxins / sum) * amount)
	removed.private_sleeping_agent = QUANTIZE((private_sleeping_agent / sum) * amount)
	removed.private_agent_b = QUANTIZE((private_agent_b / sum) * amount)
	removed.private_hydrogen = QUANTIZE((private_hydrogen / sum) * amount)
	removed.private_water_vapor = QUANTIZE((private_water_vapor / sum) * amount)

	private_oxygen = max(private_oxygen - removed.private_oxygen, 0)
	private_nitrogen = max(private_nitrogen - removed.private_nitrogen, 0)
	private_carbon_dioxide = max(private_carbon_dioxide - removed.private_carbon_dioxide, 0)
	private_toxins = max(private_toxins - removed.private_toxins, 0)
	private_sleeping_agent = max(private_sleeping_agent - removed.private_sleeping_agent, 0)
	private_agent_b = max(private_agent_b - removed.private_agent_b, 0)
	private_hydrogen = max(private_hydrogen - removed.private_hydrogen, 0)
	private_water_vapor = max(private_water_vapor - removed.private_water_vapor, 0)

	removed.private_temperature = private_temperature

	set_dirty()

	return removed

/datum/gas_mixture/proc/remove_ratio(ratio)

	if(ratio <= 0)
		return null

	ratio = min(ratio, 1)

	var/datum/gas_mixture/removed = new

	removed.private_oxygen = QUANTIZE(private_oxygen * ratio)
	removed.private_nitrogen = QUANTIZE(private_nitrogen * ratio)
	removed.private_carbon_dioxide = QUANTIZE(private_carbon_dioxide * ratio)
	removed.private_toxins = QUANTIZE(private_toxins * ratio)
	removed.private_sleeping_agent = QUANTIZE(private_sleeping_agent * ratio)
	removed.private_agent_b = QUANTIZE(private_agent_b * ratio)
	removed.private_hydrogen = QUANTIZE(private_hydrogen * ratio)
	removed.private_water_vapor = QUANTIZE(private_water_vapor * ratio)

	private_oxygen = max(private_oxygen - removed.private_oxygen, 0)
	private_nitrogen = max(private_nitrogen - removed.private_nitrogen, 0)
	private_carbon_dioxide = max(private_carbon_dioxide - removed.private_carbon_dioxide, 0)
	private_toxins = max(private_toxins - removed.private_toxins, 0)
	private_sleeping_agent = max(private_sleeping_agent - removed.private_sleeping_agent, 0)
	private_agent_b = max(private_agent_b - removed.private_agent_b, 0)
	private_hydrogen = max(private_hydrogen - removed.private_hydrogen, 0)
	private_water_vapor = max(private_water_vapor - removed.private_water_vapor, 0)

	removed.private_temperature = private_temperature
	set_dirty()

	return removed

/datum/gas_mixture/proc/copy_from(datum/gas_mixture/sample)
	private_oxygen = sample.private_oxygen
	private_carbon_dioxide = sample.private_carbon_dioxide
	private_nitrogen = sample.private_nitrogen
	private_toxins = sample.private_toxins
	private_sleeping_agent = sample.private_sleeping_agent
	private_agent_b = sample.private_agent_b
	private_hydrogen = sample.private_hydrogen
	private_water_vapor = sample.private_water_vapor

	private_temperature = sample.private_temperature
	set_dirty()

	return TRUE

//Takes the amount of the gas you want to PP as an argument
//So I don't have to do some hacky switches/defines/magic strings

//eg:
//Tox_PP = get_partial_pressure(gas_mixture.toxins)
//O2_PP = get_partial_pressure(gas_mixture.oxygen)

//Does handle trace gases!

/datum/gas_mixture/proc/get_breath_partial_pressure(gas_pressure)
	return (gas_pressure * R_IDEAL_GAS_EQUATION * private_temperature) / BREATH_VOLUME

//Reverse of the above
/datum/gas_mixture/proc/get_true_breath_pressure(partial_pressure)
	return (partial_pressure * BREATH_VOLUME) / (R_IDEAL_GAS_EQUATION * private_temperature)

/datum/gas_mixture/proc/copy_from_milla(list/milla)
	private_oxygen = milla[MILLA_INDEX_OXYGEN]
	private_carbon_dioxide = milla[MILLA_INDEX_CARBON_DIOXIDE]
	private_nitrogen = milla[MILLA_INDEX_NITROGEN]
	private_toxins = milla[MILLA_INDEX_TOXINS]
	private_sleeping_agent = milla[MILLA_INDEX_SLEEPING_AGENT]
	private_agent_b = milla[MILLA_INDEX_AGENT_B]
	private_hydrogen = milla[MILLA_INDEX_HYDROGEN]
	private_water_vapor = milla[MILLA_INDEX_WATER_VAPOR]
	innate_heat_capacity = milla[MILLA_INDEX_INNATE_HEAT_CAPACITY]
	private_temperature = milla[MILLA_INDEX_TEMPERATURE]
	private_hotspot_temperature = milla[MILLA_INDEX_HOTSPOT_TEMPERATURE]
	private_hotspot_volume = milla[MILLA_INDEX_HOTSPOT_VOLUME]
	private_fuel_burnt = milla[MILLA_INDEX_FUEL_BURNT]

/proc/share_many_airs(list/mixtures, atom/root)
	var/total_volume = 0
	var/total_oxygen = 0
	var/total_nitrogen = 0
	var/total_toxins = 0
	var/total_carbon_dioxide = 0
	var/total_sleeping_agent = 0
	var/total_agent_b = 0
	var/total_hydrogen = 0
	var/total_water_vapor = 0
	var/must_share = FALSE

	// Collect all the cheap data and check if there's a significant temperature difference.
	var/temperature = null
	for(var/datum/gas_mixture/G in mixtures)
		if(QDELETED(G))
			continue
		total_volume += G.volume

		if(isnull(temperature))
			temperature = G.private_temperature
		else if(abs(temperature - G.private_temperature) >= 1)
			must_share = TRUE
		total_oxygen += G.private_oxygen
		total_nitrogen += G.private_nitrogen
		total_toxins += G.private_toxins
		total_carbon_dioxide += G.private_carbon_dioxide
		total_sleeping_agent += G.private_sleeping_agent
		total_agent_b += G.private_agent_b
		total_hydrogen += G.private_hydrogen
		total_water_vapor += G.private_water_vapor

	if(total_volume == 0)
		return

	if(total_volume < 0 || isnan(total_volume) || !isnum(total_volume) || total_oxygen < 0 || isnan(total_oxygen) || !isnum(total_oxygen) || total_nitrogen < 0 || isnan(total_nitrogen) || !isnum(total_nitrogen) || total_toxins < 0 || isnan(total_toxins) || !isnum(total_toxins) || total_carbon_dioxide < 0 || isnan(total_carbon_dioxide) || !isnum(total_carbon_dioxide) || total_sleeping_agent < 0 || isnan(total_sleeping_agent) || !isnum(total_sleeping_agent) || total_agent_b < 0 || isnan(total_agent_b) || !isnum(total_agent_b) || total_hydrogen < 0 || isnan(total_hydrogen) || !isnum(total_hydrogen) || total_water_vapor < 0 || isnan(total_water_vapor) || !isnum(total_water_vapor))
		CRASH("A pipenet with [length(mixtures)] connected airs is corrupt and cannot flow safely. Pipenet root is [root] at ([root.x], [root.y], [root.z]).")

	// If we don't have a significant temperature difference, check for a significant gas amount difference.
	if(!must_share)
		for(var/datum/gas_mixture/G in mixtures)
			if(QDELETED(G))
				continue
			if(abs(G.private_oxygen - total_oxygen * G.volume / total_volume) > 0.1)
				must_share = TRUE
				break
			if(abs(G.private_nitrogen - total_nitrogen * G.volume / total_volume) > 0.1)
				must_share = TRUE
				break
			if(abs(G.private_toxins - total_toxins * G.volume / total_volume) > 0.1)
				must_share = TRUE
				break
			if(abs(G.private_carbon_dioxide - total_carbon_dioxide * G.volume / total_volume) > 0.1)
				must_share = TRUE
				break
			if(abs(G.private_sleeping_agent - total_sleeping_agent * G.volume / total_volume) > 0.1)
				must_share = TRUE
				break
			if(abs(G.private_agent_b - total_agent_b * G.volume / total_volume) > 0.1)
				must_share = TRUE
				break
			if(abs(G.private_hydrogen - total_hydrogen * G.volume / total_volume) > 0.1)
				must_share = TRUE
				break
			if(abs(G.private_water_vapor - total_water_vapor * G.volume / total_volume) > 0.1)
				must_share = TRUE
				break
	if(!must_share)
		// Nothing significant, don't do any more work.
		return
	// Collect the more expensive data.
	var/total_thermal_energy = 0
	var/total_heat_capacity = 0
	for(var/datum/gas_mixture/G in mixtures)
		if(QDELETED(G))
			continue
		var/heat_capacity = G.heat_capacity()
		total_heat_capacity += heat_capacity
		total_thermal_energy += G.private_temperature * heat_capacity
	// Calculate shared temperature.
	temperature = TCMB
	if(total_heat_capacity > 0)
		temperature = total_thermal_energy/total_heat_capacity

	if(temperature <= 0 || isnan(temperature) || !isnum(temperature))
		CRASH("A pipenet with [length(mixtures)] connected airs is corrupt and cannot flow safely. Pipenet root is [root] at ([root.x], [root.y], [root.z]).")

	// Update individual gas_mixtures by volume ratio.
	for(var/datum/gas_mixture/G in mixtures)
		if(QDELETED(G))
			continue
		G.private_oxygen = total_oxygen * G.volume / total_volume
		G.private_nitrogen = total_nitrogen * G.volume / total_volume
		G.private_toxins = total_toxins * G.volume / total_volume
		G.private_carbon_dioxide = total_carbon_dioxide * G.volume / total_volume
		G.private_sleeping_agent = total_sleeping_agent * G.volume / total_volume
		G.private_agent_b = total_agent_b * G.volume / total_volume
		G.private_hydrogen = total_hydrogen * G.volume / total_volume
		G.private_water_vapor = total_water_vapor * G.volume / total_volume
		G.private_temperature = temperature
		// In theory, we should G.set_dirty() here, but that's only useful for bound mixtures, and these can't be.

/datum/gas_mixture/proc/hotspot_expose(temperature, volume)
	return

#undef SPECIFIC_HEAT_TOXIN
#undef SPECIFIC_HEAT_AIR
#undef SPECIFIC_HEAT_CDO
#undef SPECIFIC_HEAT_N2O
#undef SPECIFIC_HEAT_AGENT_B
#undef SPECIFIC_HEAT_HYDROGEN
#undef SPECIFIC_HEAT_WATER_VAPOR
#undef HEAT_CAPACITY_CALCULATION
#undef MINIMUM_HEAT_CAPACITY
#undef MINIMUM_MOLE_COUNT
#undef QUANTIZE


/datum/gas_mixture/bound_to_turf
	synchronized = FALSE
	var/dirty = FALSE
	var/lastread = 0
	var/turf/bound_turf = null
	var/datum/gas_mixture/readonly/readonly = null

/datum/gas_mixture/bound_to_turf/Destroy()
	bound_turf = null
	return ..()

/datum/gas_mixture/bound_to_turf/set_dirty()
	dirty = TRUE

	if(!isnull(readonly))
		readonly.private_oxygen = private_oxygen
		readonly.private_carbon_dioxide = private_carbon_dioxide
		readonly.private_nitrogen = private_nitrogen
		readonly.private_toxins = private_toxins
		readonly.private_sleeping_agent = private_sleeping_agent
		readonly.private_agent_b = private_agent_b
		readonly.private_hydrogen = private_hydrogen
		readonly.private_water_vapor = private_water_vapor
		readonly.private_temperature = private_temperature
		readonly.private_hotspot_temperature = private_hotspot_temperature
		readonly.private_hotspot_volume = private_hotspot_volume
		readonly.private_fuel_burnt = private_fuel_burnt

	if(istype(bound_turf, /turf/simulated))
		var/turf/simulated/S = bound_turf
		S.update_visuals()
	ASSERT(SSair.is_in_milla_safe_code())

/datum/gas_mixture/bound_to_turf/set_oxygen(value)
	private_oxygen = value
	set_dirty()

/datum/gas_mixture/bound_to_turf/set_carbon_dioxide(value)
	private_carbon_dioxide = value
	set_dirty()

/datum/gas_mixture/bound_to_turf/set_nitrogen(value)
	private_nitrogen = value
	set_dirty()

/datum/gas_mixture/bound_to_turf/set_toxins(value)
	private_toxins = value
	set_dirty()

/datum/gas_mixture/bound_to_turf/set_sleeping_agent(value)
	private_sleeping_agent = value
	set_dirty()

/datum/gas_mixture/bound_to_turf/set_agent_b(value)
	private_agent_b = value
	set_dirty()

/datum/gas_mixture/bound_to_turf/set_hydrogen(value)
	private_hydrogen = value
	set_dirty()

/datum/gas_mixture/bound_to_turf/set_water_vapor(value)
	private_water_vapor = value
	set_dirty()

/datum/gas_mixture/bound_to_turf/set_temperature(value)
	private_temperature = value
	set_dirty()

/datum/gas_mixture/bound_to_turf/hotspot_expose(temperature, volume)
	if(temperature > private_temperature)
		set_dirty()
		private_hotspot_temperature = max(private_hotspot_temperature, temperature)
		private_hotspot_volume = max(private_hotspot_volume, (volume / CELL_VOLUME))

/datum/gas_mixture/bound_to_turf/proc/private_unsafe_write()
	set_tile_atmos(
		bound_turf,
		oxygen = private_oxygen,
		carbon_dioxide = private_carbon_dioxide,
		nitrogen = private_nitrogen,
		toxins = private_toxins,
		sleeping_agent = private_sleeping_agent,
		agent_b = private_agent_b,
		hydrogen = private_hydrogen,
		water_vapor = private_water_vapor,
		temperature = private_temperature
	)

/datum/gas_mixture/bound_to_turf/proc/get_readonly()
	if(isnull(readonly))
		readonly = new(src)
	return readonly

/// A gas mixture that should not be modified after creation.
/datum/gas_mixture/readonly

/datum/gas_mixture/readonly/New(datum/gas_mixture/parent)
	private_oxygen = parent.private_oxygen
	private_carbon_dioxide = parent.private_carbon_dioxide
	private_nitrogen = parent.private_nitrogen
	private_toxins = parent.private_toxins
	private_sleeping_agent = parent.private_sleeping_agent
	private_agent_b = parent.private_agent_b
	private_hydrogen = parent.private_hydrogen
	private_water_vapor = parent.private_water_vapor

	private_temperature = parent.private_temperature

	private_hotspot_temperature = parent.private_hotspot_temperature
	private_hotspot_volume = parent.private_hotspot_volume
	private_fuel_burnt = parent.private_fuel_burnt

/datum/gas_mixture/readonly/set_dirty()
	CRASH("Attempted to modify a readonly gas_mixture.")

/datum/gas_mixture/readonly/set_oxygen(value)
	CRASH("Attempted to modify a readonly gas_mixture.")

/datum/gas_mixture/readonly/set_carbon_dioxide(value)
	CRASH("Attempted to modify a readonly gas_mixture.")

/datum/gas_mixture/readonly/set_nitrogen(value)
	CRASH("Attempted to modify a readonly gas_mixture.")

/datum/gas_mixture/readonly/set_toxins(value)
	CRASH("Attempted to modify a readonly gas_mixture.")

/datum/gas_mixture/readonly/set_sleeping_agent(value)
	CRASH("Attempted to modify a readonly gas_mixture.")

/datum/gas_mixture/readonly/set_agent_b(value)
	CRASH("Attempted to modify a readonly gas_mixture.")

/datum/gas_mixture/readonly/set_hydrogen(value)
	CRASH("Attempted to modify a readonly gas_mixture.")

/datum/gas_mixture/readonly/set_water_vapor(value)
	CRASH("Attempted to modify a readonly gas_mixture.")

/datum/gas_mixture/readonly/set_temperature(value)
	CRASH("Attempted to modify a readonly gas_mixture.")
