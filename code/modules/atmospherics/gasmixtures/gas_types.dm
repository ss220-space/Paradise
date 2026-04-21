GLOBAL_LIST_INIT(gas_meta, meta_gas_list())
/proc/meta_gas_list()
	. = list()
	for(var/gas_path in subtypesof(/datum/gas))
		var/list/gas_info = new(6)
		var/datum/gas/gas = gas_path

		gas_info[META_GAS_ID] = gas.id
		gas_info[META_GAS_NAME] = gas.name
		gas_info[META_GAS_DESC] = gas.desc
		gas_info[META_GAS_PRIMARY_COLOR] = gas.primary_color
		gas_info[META_GAS_SCRUB_FLAG] = gas.scrub_flag
		gas_info[META_GAS_SENSOR_FLAG] = gas.sensor_flag
		.[gas.id] = gas_info


/*||||||||||||||/----------\||||||||||||||*\
||||||||||||||||[GAS DATUMS]||||||||||||||||
||||||||||||||||\__________/||||||||||||||||
|||| These should never be instantiated. ||||
|||| They exist only to make it easier   ||||
|||| to add a new gas. They are accessed ||||
|||| only by meta_gas_list().            ||||
\*||||||||||||||||||||||||||||||||||||||||*/

/datum/gas
	var/id = ""
	var/name = ""
	var/desc
	///RGB code for use when a generic color representing the gas is needed. Colors taken from contants.ts
	var/primary_color
	var/scrub_flag
	var/sensor_flag

/datum/gas/oxygen
	id = TLV_O2
	name = "Oxygen"
	desc = "The gas most life forms need to be able to survive. Also an oxidizer."
	primary_color = "#0000ff"
	scrub_flag = SCRUB_O2
	sensor_flag = SENSOR_COMPOSITION_OXYGEN

/datum/gas/nitrogen
	id = TLV_N2
	name = "Nitrogen"
	desc = "A very common gas that used to pad artificial atmospheres to habitable pressure."
	primary_color = "#ffff00"
	scrub_flag = SCRUB_N2
	sensor_flag = SENSOR_COMPOSITION_NITROGEN

/datum/gas/carbon_dioxide
	id = TLV_CO2
	name = "Carbon Dioxide"
	desc = "A waste product of respiration, also produced by combustion."
	primary_color = COLOR_GRAY
	scrub_flag = SCRUB_CO2
	sensor_flag = SENSOR_COMPOSITION_CO2

/datum/gas/plasma
	id = TLV_PL
	name = "Plasma"
	desc = "A flammable gas with many other curious properties. Its research is one of NT's primary objective."
	primary_color = "#ffc0cb"
	scrub_flag = SCRUB_PL
	sensor_flag = SENSOR_COMPOSITION_TOXINS

/datum/gas/water_vapor
	id = TLV_H2O
	name = "Water Vapor"
	desc = "Water, in gas form. Makes floors slippery and washes items on them."
	primary_color = "#b0c4de"
	scrub_flag = SCRUB_H2O
	sensor_flag = SENSOR_COMPOSITION_H2O

/datum/gas/hypernoblium
	id = TLV_HYPERNOBLIUM
	name = "Hyper-noblium"
	desc = "The most noble gas of them all. High quantities of hyper-noblium actively prevents reactions from occurring."
	primary_color = COLOR_TEAL
	scrub_flag = SCRUB_HYPERNOBLIUM
	sensor_flag = SENSOR_COMPOSITION_HYPERNOBLIUM

/datum/gas/nitrous_oxide
	id = TLV_N2O
	name = "Nitrous Oxide"
	desc = "Causes drowsiness, euphoria, and eventually unconsciousness."
	primary_color = "#ffe4c4"
	scrub_flag = SCRUB_N2O
	sensor_flag = SENSOR_COMPOSITION_N2O

/datum/gas/nitrium
	id = TLV_NITRIUM
	name = "Nitrium"
	desc = "An experimental performance enhancing gas. Nitrium can have amplified effects as more of it gets into your bloodstream."
	primary_color = "#a52a2a"
	scrub_flag = SCRUB_NITRIUM
	sensor_flag = SENSOR_COMPOSITION_NITRIUM

/datum/gas/tritium
	id = TLV_TRITIUM
	name = "Tritium"
	desc = "A highly flammable and radioactive gas."
	primary_color = "#32cd32"
	scrub_flag = SCRUB_TRITIUM
	sensor_flag = SENSOR_COMPOSITION_TRITIUM

/datum/gas/bz
	id = TLV_BZ
	name = "BZ"
	desc = "A powerful hallucinogenic nerve agent able to induce cognitive damage."
	primary_color = "#9370db"
	scrub_flag = SCRUB_BZ
	sensor_flag = SENSOR_COMPOSITION_BZ

/datum/gas/pluoxium
	id = TLV_PLUOXIUM
	name = "Pluoxium"
	desc = "A gas that could supply even more oxygen to the bloodstream when inhaled, without being an oxidizer."
	primary_color = "#7b68ee"
	scrub_flag = SCRUB_PLUOXIUM
	sensor_flag = SENSOR_COMPOSITION_PLUOXIUM

/datum/gas/miasma
	id = TLV_MIASMA
	name = "Miasma"
	desc = "Not necessarily a gas, miasma refers to biological pollutants found in the atmosphere."
	primary_color = COLOR_OLIVE
	scrub_flag = SCRUB_MIASMA
	sensor_flag = SENSOR_COMPOSITION_MIASMA

/datum/gas/freon
	id = TLV_FREON
	name = "Freon"
	desc = "A coolant gas. Mainly used for its endothermic reaction with oxygen."
	primary_color = "#afeeee"
	scrub_flag = SCRUB_FREON
	sensor_flag = SENSOR_COMPOSITION_FREON

/datum/gas/hydrogen
	id = TLV_H2
	name = "Hydrogen"
	desc = "A highly flammable gas."
	primary_color = "#ffffff"
	scrub_flag = SCRUB_H2
	sensor_flag = SENSOR_COMPOSITION_H2

/datum/gas/healium
	id = TLV_HEALIUM
	name = "Healium"
	desc = "Causes deep, regenerative sleep."
	primary_color = "#fa8072"
	scrub_flag = SCRUB_HEALIUM
	sensor_flag = SENSOR_COMPOSITION_HEALIUM

/datum/gas/proto_nitrate
	id = TLV_PROTO_NITRATE
	name = "Proto Nitrate"
	desc = "A very volatile gas that reacts differently with various gases."
	primary_color = "#adff2f"
	scrub_flag = SCRUB_PROTO_NITRATE
	sensor_flag = SENSOR_COMPOSITION_PROTO_NITRATE

/datum/gas/zauker
	id = TLV_ZAUKER
	name = "Zauker"
	desc = "A highly toxic gas, its production is highly regulated on top of being difficult. It also breaks down when in contact with nitrogen."
	primary_color = "#006400"
	scrub_flag = SCRUB_ZAUKER
	sensor_flag = SENSOR_COMPOSITION_ZAUKER

/datum/gas/halon
	id = TLV_HALON
	name = "Halon"
	desc = "A potent fire suppressant. Removes oxygen from high temperature fires and cools down the area."
	primary_color = COLOR_PURPLE
	scrub_flag = SCRUB_HALON
	sensor_flag = SENSOR_COMPOSITION_HALON

/datum/gas/helium
	id = TLV_HELIUM
	name = "Helium"
	desc = "A very inert gas produced by the fusion of hydrogen and its derivatives."
	primary_color = "#f0f8ff"
	scrub_flag = SCRUB_HELIUM
	sensor_flag = SENSOR_COMPOSITION_HELIUM

/datum/gas/antinoblium
	id = TLV_ANTINOBLIUM
	name = "Antinoblium"
	desc = "We still don't know what it does, but it sells for a lot."
	primary_color = COLOR_MAROON
	scrub_flag = SCRUB_ANTINOBLIUM
	sensor_flag = SENSOR_COMPOSITION_ANTINOBLIUM
