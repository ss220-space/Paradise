// Atmos types used for planetary airs
/datum/atmosphere/lavaland
	id = ENVIRONMENT_LAVALAND

	base_gases = list(
		ATMOSPHERE_OXYGEN = 9,
		ATMOSPHERE_NITROGEN = 18,
	)
	normal_gases = list(
		ATMOSPHERE_OXYGEN = 10,
		ATMOSPHERE_NITROGEN = 10,
		ATMOSPHERE_CARBON_DIOXIDE = 10,
	)
	restricted_gases = list(
		ATMOSPHERE_TOXINS = 0.1,
		ATMOSPHERE_BZ = 1.2,
		ATMOSPHERE_MIASMA = 1.2,
		ATMOSPHERE_WATER_VAPOR = 0.1,
	)
	restricted_chance = 30


	minimum_temp = LAVALAND_TEMPERATURE
	maximum_temp = LAVALAND_MAX_TEMPERATURE

	minimum_pressure = HAZARD_LOW_PRESSURE + 10
	maximum_pressure = LAVALAND_EQUIPMENT_EFFECT_PRESSURE - 1

/datum/atmosphere/cold
	id = ENVIRONMENT_COLD

	base_gases = list(
		ATMOSPHERE_OXYGEN = 5,
		ATMOSPHERE_NITROGEN = 10,
	)
	normal_gases = list(
		ATMOSPHERE_OXYGEN = 10,
		ATMOSPHERE_NITROGEN = 10,
		ATMOSPHERE_CARBON_DIOXIDE = 10,
	)
	restricted_gases = list(
		ATMOSPHERE_TOXINS = 0.1,
		ATMOSPHERE_WATER_VAPOR = 0.1,
		ATMOSPHERE_MIASMA = 1.2,
	)
	restricted_chance = 20

	minimum_temp = ICEBOX_MIN_TEMPERATURE
	maximum_temp = ICEBOX_MIN_TEMPERATURE

	minimum_pressure = HAZARD_LOW_PRESSURE + 10
	maximum_pressure = LAVALAND_EQUIPMENT_EFFECT_PRESSURE - 1

/datum/atmosphere/temperate
	id = ENVIRONMENT_TEMPERATE

	base_gases = list(
		ATMOSPHERE_OXYGEN = MOLES_O2STANDARD,
		ATMOSPHERE_NITROGEN = MOLES_N2STANDARD,
	)
	normal_gases = list()
	restricted_gases = list()
	restricted_chance = 0

	minimum_temp = T20C
	maximum_temp = T20C

	minimum_pressure = ONE_ATMOSPHERE
	maximum_pressure = ONE_ATMOSPHERE
