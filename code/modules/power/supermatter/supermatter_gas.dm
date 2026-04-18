/proc/init_sm_gas()
	var/list/gas_list = list()
	for(var/sm_gas_type in subtypesof(/datum/sm_gas))
		var/datum/sm_gas/sm_gas = new sm_gas_type
		gas_list[sm_gas.gas_id] = sm_gas
	return gas_list

/// Return a list info of the SM gases.
/// Can only run after init_sm_gas
/proc/sm_gas_data()
	var/list/data = list()
	for(var/gas_id, gas_behavior in GLOB.sm_gas_behavior)
		var/datum/sm_gas/sm_gas = gas_behavior
		var/list/singular_gas_data = list()
		singular_gas_data["desc"] = sm_gas.desc

		// Positive is true if more of the amount is a good thing.
		var/list/numeric_data = list()
		if(sm_gas.power_transmission)
			var/list/si_derived_data = siunit_isolated(sm_gas.power_transmission * BASE_POWER_TRANSMISSION_RATE, "W/MeV", 2)
			numeric_data += list(list(
				"name" = "Power Transmission Bonus",
				"amount" = si_derived_data["coefficient"],
				"unit" = si_derived_data["unit"],
				"positive" = TRUE,
			))
		if(sm_gas.heat_modifier)
			numeric_data += list(list(
				"name" = "Waste Multiplier",
				"amount" = 100 * sm_gas.heat_modifier,
				"unit" = "%",
				"positive" = FALSE,
			))
		if(sm_gas.heat_resistance)
			numeric_data += list(list(
				"name" = "Heat Resistance",
				"amount" = 100 * sm_gas.heat_resistance,
				"unit" = "%",
				"positive" = TRUE,
			))
		if(sm_gas.heat_power_generation)
			var/list/si_derived_data = siunit_isolated(sm_gas.heat_power_generation * GAS_HEAT_POWER_SCALING_COEFFICIENT MEGA SECONDS / SSair.wait, "eV/K/s", 2)
			numeric_data += list(list(
				"name" = "Heat Power Gain",
				"amount" = si_derived_data["coefficient"],
				"unit" = si_derived_data["unit"],
				"positive" = TRUE,
			))
		if(sm_gas.powerloss_inhibition)
			numeric_data += list(list(
				"name" = "Power Decay Negation",
				"amount" = 100 * sm_gas.powerloss_inhibition,
				"unit" = "%",
				"positive" = TRUE,
			))
		singular_gas_data["numeric_data"] = numeric_data
		data[gas_id] = singular_gas_data
	return data

/// Assoc of sm_gas_behavior[/datum/gas (path)] = datum/sm_gas (instance)
GLOBAL_LIST_INIT(sm_gas_behavior, init_sm_gas())

/// Contains effects of gases when absorbed by the sm.
/// If the gas has no effects you do not need to add another sm_gas subtype,
/// We already guard for nulls in [/obj/machinery/power/supermatter_crystal/proc/calculate_gases]
/datum/sm_gas
	/// Path of the [/datum/gas] involved with this interaction.
	var/gas_id
	/// Influences zap power without interfering with the crystal's own energy. Gets scaled by [BASE_POWER_TRANSMISSION_RATE].
	var/power_transmission = 0
	/// How much more waste heat and gas the SM generates.
	var/heat_modifier = 0
	/// How extra hot the SM can run before taking damage
	var/heat_resistance = 0
	/// Lets the sm generate extra power from heat. Yeah...
	var/heat_power_generation = 0
	/// How much powerloss do we get rid of.
	var/powerloss_inhibition = 0
	/// Give a short description of the gas if needed. If the gas have extra effects describe it here.
	var/desc

/datum/sm_gas/proc/extra_effects(obj/machinery/power/supermatter_crystal/sm)
	return

/datum/sm_gas/oxygen
	gas_id = TLV_O2
	power_transmission = 0.15
	heat_power_generation = 1

/datum/sm_gas/nitrogen
	gas_id = TLV_N2
	heat_modifier = -2.5
	heat_power_generation = -1

/datum/sm_gas/carbon_dioxide
	gas_id = TLV_CO2
	heat_modifier = 1
	heat_power_generation = 1
	powerloss_inhibition = 1
	desc = "When absorbed by the Supermatter and exposed to oxygen, Pluoxium will be generated."

/// Can be on Oxygen or CO2, but better lump it here since CO2 is rarer.
/datum/sm_gas/carbon_dioxide/extra_effects(obj/machinery/power/supermatter_crystal/sm)
	if(!sm.gas_percentage[TLV_CO2] || !sm.gas_percentage[TLV_O2])
		return
	var/co2_pp = sm.absorbed_gasmix.return_pressure() * sm.gas_percentage[TLV_CO2]
	var/co2_ratio = clamp((0.5 * (co2_pp - CO2_CONSUMPTION_PP) / (co2_pp + CO2_PRESSURE_SCALING)), 0, 1)
	var/consumed_co2 = sm.absorbed_gasmix.private_carbon_dioxide * co2_ratio
	consumed_co2 = min(
		consumed_co2,
		sm.absorbed_gasmix.private_carbon_dioxide,
		sm.absorbed_gasmix.private_oxygen
	)
	if(!consumed_co2)
		return
	sm.absorbed_gasmix.private_carbon_dioxide -= consumed_co2
	sm.absorbed_gasmix.private_oxygen -= consumed_co2
	sm.absorbed_gasmix.private_pluoxium += consumed_co2

/datum/sm_gas/plasma
	gas_id = TLV_PL
	heat_modifier = 14
	power_transmission = 0.4
	heat_power_generation = 1

/datum/sm_gas/water_vapor
	gas_id = TLV_H2O
	heat_modifier = 11
	power_transmission = -0.25
	heat_power_generation = 1

/datum/sm_gas/hypernoblium
	gas_id = TLV_HYPERNOBLIUM
	heat_modifier = -14
	power_transmission = 0.3
	heat_power_generation = -1

/datum/sm_gas/nitrous_oxide
	gas_id = TLV_N2O
	heat_resistance = 5

/datum/sm_gas/tritium
	gas_id = TLV_TRITIUM
	heat_modifier = 9
	power_transmission = 3
	heat_power_generation = 1

/datum/sm_gas/bz
	gas_id = TLV_BZ
	heat_modifier = 4
	power_transmission = -0.2
	heat_power_generation = 1
	desc = "Will emit nuclear particles at compositions above 40%"

/// Start to emit radballs at a maximum of 30% chance per tick
/datum/sm_gas/bz/extra_effects(obj/machinery/power/supermatter_crystal/sm)
	if(sm.gas_percentage[TLV_BZ] > 0.4 && prob(30 * sm.gas_percentage[TLV_BZ]))
		sm.fire_nuclear_particle()

/datum/sm_gas/pluoxium
	gas_id = TLV_PLUOXIUM
	heat_modifier = -1.5
	power_transmission = -0.5
	heat_power_generation = -1

/datum/sm_gas/miasma
	gas_id = TLV_MIASMA
	heat_power_generation = 0.5
	desc = "Will be consumed by the Supermatter to generate power."

///Miasma is really just microscopic particulate. It gets consumed like anything else that touches the crystal.
/datum/sm_gas/miasma/extra_effects(obj/machinery/power/supermatter_crystal/sm)
	if(!sm.gas_percentage[TLV_MIASMA])
		return
	var/miasma_pp = sm.absorbed_gasmix.return_pressure() * sm.gas_percentage[TLV_MIASMA]
	var/miasma_ratio = clamp(((miasma_pp - MIASMA_CONSUMPTION_PP) / (miasma_pp + MIASMA_PRESSURE_SCALING)) * (1 + (sm.gas_heat_power_generation * MIASMA_GASMIX_SCALING)), 0, 1)
	var/consumed_miasma = sm.absorbed_gasmix.private_miasma * miasma_ratio
	if(!consumed_miasma)
		return
	sm.absorbed_gasmix.private_miasma -= consumed_miasma
	sm.external_power_trickle += consumed_miasma * MIASMA_POWER_GAIN
	sm.log_activation("miasma absorption")

/datum/sm_gas/freon
	gas_id = TLV_FREON
	heat_modifier = -9
	power_transmission = -3
	heat_power_generation = -1

/datum/sm_gas/hydrogen
	gas_id = TLV_H2
	heat_modifier = 9
	power_transmission = 2.5
	heat_resistance = 1
	heat_power_generation = 1

/datum/sm_gas/healium
	gas_id = TLV_HEALIUM
	heat_modifier = 3
	power_transmission = 0.24
	heat_power_generation = 1

/datum/sm_gas/proto_nitrate
	gas_id = TLV_PROTO_NITRATE
	heat_modifier = -4
	power_transmission = 1.5
	heat_resistance = 4
	heat_power_generation = 1

/datum/sm_gas/zauker
	gas_id = TLV_ZAUKER
	heat_modifier = 7
	power_transmission = 2
	heat_power_generation = 1
	desc = "Will generate electrical zaps."

/datum/sm_gas/zauker/extra_effects(obj/machinery/power/supermatter_crystal/sm)
	if(!prob(sm.gas_percentage[TLV_ZAUKER] * 100))
		return
	playsound(sm.loc, 'sound/weapons/emitter2.ogg', 100, TRUE, extrarange = 10)
	sm.supermatter_zap(
		sm,
		range = 6,
		zap_str = clamp(sm.internal_energy * 1.6 KILO JOULES, 3.2 MEGA JOULES, 16 MEGA JOULES),
		zap_flags = ZAP_MOB_STUN,
		zap_cutoff = sm.zap_cutoff,
		power_level = sm.internal_energy,
		zap_icon = sm.zap_icon
	)

/datum/sm_gas/antinoblium
	gas_id = TLV_ANTINOBLIUM
	heat_modifier = 14
	power_transmission = -0.5
	heat_power_generation = 1
