var/list/hardcoded_gases = list(GAS_O2, GAS_N2, GAS_CO2, GAS_PL) //the main four gases, which were at one time hardcoded

/proc/meta_gas_list()
	var/list/meta_list = list()

	for(var/gas_path in subtypesof(/datum/gas))
		var/list/gas_info = new(4)
		var/datum/gas/g = gas_path
		gas_info[1] = initial(g.specific_heat)
		gas_info[2] = initial(g.name)
		gas_info[3] = new /obj/effect/overlay/gas(initial(g.gas_overlay))
		gas_info[4] = initial(g.moles_visible)

		meta_list[initial(g.id)] = gas_info
	. = meta_list

/*||||||||||||||/----------\||||||||||||||*\
||||||||||||||||[GAS DATUMS]||||||||||||||||
||||||||||||||||\__________/||||||||||||||||
||||These should never be instantiated, ||||
||||except once in meta_gas_list(). This||||
||||particular instance is deleted after||||
||||accessing one var, which cannot be  ||||
||||accessed by abusing initial().      ||||
||||They exist only to make it easier   ||||
||||to add a new gas. They are accessed ||||
||||only by meta_gas_list().            ||||
\*||||||||||||||||||||||||||||||||||||||||*/

/datum/gas
	var/id = ""
	var/specific_heat = 0
	var/name = ""
	var/gas_overlay = "" //icon_state in icons/effects/tile_effects.dmi
	var/moles_visible = null

/datum/gas/oxygen
	id = GAS_O2
	specific_heat = 20
	name = "Oxygen"

/datum/gas/nitrogen
	id = GAS_N2
	specific_heat = 20
	name = "Nitrogen"

/datum/gas/carbon_dioxide //what the fuck is this?
	id = GAS_CO2
	specific_heat = 30
	name = "Carbon Dioxide"

/datum/gas/plasma
	id = GAS_PL
	specific_heat = 200
	name = "Plasma"
	gas_overlay = "plasma"
	moles_visible = MOLES_PLASMA_VISIBLE

/datum/gas/nitrous_oxide
	id = GAS_N2O
	specific_heat = 40
	name = "Nitrous Oxide"
	gas_overlay = "nitrous_oxide"
	moles_visible = 1

/datum/gas/oxygen_agent_b
	id = GAS_AGENT_B
	specific_heat = 300
	name = "Oxygen Agent B"

/datum/gas/volatile_fuel
	id = GAS_V_FUEL
	specific_heat = 30
	name = "Volatile Fuel"


/obj/effect/overlay/gas
	icon = 'icons/effects/tile_effects.dmi'
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE  // should only appear in vis_contents, but to be safe
	layer = FLY_LAYER
	plane = ABOVE_GAME_PLANE
	appearance_flags = TILE_BOUND
	vis_flags = NONE

/obj/effect/overlay/gas/New(state)
	. = ..()
	icon_state = state
