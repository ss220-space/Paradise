#define GASMINER_POWER_NONE 0
#define GASMINER_POWER_STATIC 1
#define GASMINER_POWER_MOLES 2 //Scaled from here on down.
#define GASMINER_POWER_KPA 3
#define GASMINER_POWER_FULLSCALE 4

/obj/machinery/atmospherics/miner
	name = "gas miner"
	desc = "Gasses mined from the gas giant below (above?) flow out through this massive vent."
	icon = 'icons/obj/pipes_and_stuff/atmospherics/atmos/miners.dmi'
	icon_state = "miner"
	resistance_flags = ACID_PROOF|FIRE_PROOF
	idle_power_usage = 150
	active_power_usage = 2000
	var/spawn_temp = T20C
	/// Moles of gas to spawn per second
	var/spawn_mol = MOLES_CELLSTANDARD
	var/max_ext_mol = INFINITY
	var/max_ext_kpa = 6500
	var/overlay_color = COLOR_WHITE
	var/active = FALSE
	var/power_draw = 0
	var/power_draw_static = 2000
	var/power_draw_dynamic_mol_coeff = 5 //DO NOT USE DYNAMIC SETTINGS UNTIL SOMEONE MAKES A USER INTERFACE/CONTROLLER FOR THIS!
	var/power_draw_dynamic_kpa_coeff = 0.5
	var/broken = FALSE
	var/broken_message = "ERROR"

/obj/machinery/atmospherics/miner/examine(mob/user)
	. = ..()
	if(broken)
		. += {"Its debug output is printing "[broken_message]"."}

/obj/machinery/atmospherics/miner/proc/check_operation()
	if(!active)
		return FALSE

	var/turf/tile = get_turf(src)
	if(!anchored)
		broken_message = span_boldnotice("DEVICE NOT ANCHORED")
		set_broken(TRUE)
		return FALSE

	if(isspaceturf(tile))
		broken_message = span_boldnotice("AIR VENTING TO SPACE")
		set_broken(TRUE)
		return FALSE

	if(!issimulatedturf(tile) || tile.blocks_air)
		broken_message = span_boldnotice("VENT BLOCKED")
		set_broken(TRUE)
		return FALSE

	var/turf/simulated/simulated_tile = tile
	if(simulated_tile.atmos_environment == ENVIRONMENT_LAVALAND)
		broken_message = span_boldwarning("DEVICE NOT ENCLOSED IN A PRESSURIZED ENVIRONMENT")
		set_broken(TRUE)
		return FALSE

	var/datum/gas_mixture/air = simulated_tile.get_readonly_air()
	if(air.return_pressure() > (max_ext_kpa - ((spawn_mol * spawn_temp * R_IDEAL_GAS_EQUATION) / (CELL_VOLUME))))
		broken_message = span_boldwarning("EXTERNAL PRESSURE OVER THRESHOLD")
		set_broken(TRUE)
		return FALSE

	if(air.total_moles() > max_ext_mol)
		broken_message = span_boldwarning("EXTERNAL AIR CONCENTRATION OVER THRESHOLD")
		set_broken(TRUE)
		return FALSE

	if(broken)
		set_broken(FALSE)
		broken_message = ""

	return TRUE

/obj/machinery/atmospherics/miner/proc/set_active(setting)
	if(active != setting)
		active = setting
		update_icon(UPDATE_OVERLAYS)

/obj/machinery/atmospherics/miner/proc/set_broken(setting)
	if(broken != setting)
		broken = setting
		update_icon(UPDATE_OVERLAYS)

/obj/machinery/atmospherics/miner/attack_hand(mob/user)
	. = ..()
	if(.)
		return

	set_active(!active)
	balloon_alert(user, active? "включено": "выключено")

/obj/machinery/atmospherics/miner/wrench_act(mob/living/user, obj/item/I)
	. = default_unfasten_wrench(user, I)

/obj/machinery/atmospherics/miner/proc/update_power()
	if(!active)
		active_power_usage = idle_power_usage

	var/turf/tile = get_turf(src)
	var/datum/gas_mixture/air = tile.get_readonly_air()
	var/pressure = air.return_pressure()
	switch(power_draw)
		if(GASMINER_POWER_NONE)
			update_use_power(ACTIVE_POWER_USE, 0)
		if(GASMINER_POWER_STATIC)
			update_use_power(ACTIVE_POWER_USE, power_draw_static)
		if(GASMINER_POWER_MOLES)
			update_use_power(ACTIVE_POWER_USE, spawn_mol * power_draw_dynamic_mol_coeff)
		if(GASMINER_POWER_KPA)
			update_use_power(ACTIVE_POWER_USE, pressure * power_draw_dynamic_kpa_coeff)
		if(GASMINER_POWER_FULLSCALE)
			update_use_power(ACTIVE_POWER_USE, (spawn_mol * power_draw_dynamic_mol_coeff) + (pressure * power_draw_dynamic_kpa_coeff))

/obj/machinery/atmospherics/miner/proc/do_use_energy(amount)
	var/turf/tile = get_turf(src)
	if(tile && istype(tile))
		var/obj/structure/cable/cable = tile.get_cable_node() //check if we have a node cable on the machine turf, the first found is picked
		if(cable && cable.powernet && (cable.powernet.avail > amount))
			cable.powernet.load += amount
			return TRUE

	if(powered())
		use_power(amount)
		return TRUE

	return FALSE

/obj/machinery/atmospherics/miner/update_overlays()
	. = ..()
	if(broken)
		. += "broken"
		return

	if(!active)
		return

	var/mutable_appearance/on_overlay = mutable_appearance(icon, "on")
	on_overlay.color = overlay_color
	. += on_overlay

/obj/machinery/atmospherics/miner/process(seconds_per_tick)
	if(!active || !powered())
		return

	update_power()
	check_operation()
	if(!broken)
		if(do_use_energy(active_power_usage))
			mine_gas(seconds_per_tick)

/obj/machinery/atmospherics/miner/proc/mine_gas(seconds_per_tick = 2)
	var/turf/simulated/tile = get_turf(src)

	if(!istype(tile) || tile.blocks_air)
		return FALSE

	var/datum/gas_mixture/merger = new
	add_gas_to(merger, spawn_mol * seconds_per_tick)
	merger.set_temperature(spawn_temp)
	tile.blind_release_air(merger)

/obj/machinery/atmospherics/miner/proc/add_gas_to(datum/gas_mixture/merger, count)
	return

/obj/machinery/atmospherics/miner/attack_ai(mob/living/silicon/user)
	if(broken)
		to_chat(user, "[src] seems to be broken. Its debug interface outputs: [broken_message]")
	..()

/obj/machinery/atmospherics/miner/n2o
	name = "N2O Gas Miner"
	overlay_color = COLOR_GAS_MINER_N2O

/obj/machinery/atmospherics/miner/n2o/add_gas_to(datum/gas_mixture/merger, count)
	merger.set_sleeping_agent(count)

/obj/machinery/atmospherics/miner/nitrogen
	name = "N2 Gas Miner"
	overlay_color = COLOR_GAS_MINER_N2

/obj/machinery/atmospherics/miner/nitrogen/add_gas_to(datum/gas_mixture/merger, count)
	merger.set_nitrogen(count)

/obj/machinery/atmospherics/miner/oxygen
	name = "O2 Gas Miner"
	overlay_color = COLOR_GAS_MINER_O2

/obj/machinery/atmospherics/miner/oxygen/add_gas_to(datum/gas_mixture/merger, count)
	merger.set_oxygen(count)

/obj/machinery/atmospherics/miner/plasma
	name = "Plasma Gas Miner"
	overlay_color = COLOR_RED

/obj/machinery/atmospherics/miner/plasma/add_gas_to(datum/gas_mixture/merger, count)
	merger.set_toxins(count)

/obj/machinery/atmospherics/miner/carbon_dioxide
	name = "CO2 Gas Miner"
	overlay_color = COLOR_GAS_MINER_CO2

/obj/machinery/atmospherics/miner/carbon_dioxide/add_gas_to(datum/gas_mixture/merger, count)
	merger.set_carbon_dioxide(count)

/obj/machinery/atmospherics/miner/bz
	name = "BZ Gas Miner"
	overlay_color = COLOR_GAS_MINER_BZ

/obj/machinery/atmospherics/miner/carbon_dioxide/add_gas_to(datum/gas_mixture/merger, count)
	merger.set_bz(count)

/obj/machinery/atmospherics/miner/agent_b
	name = "Agent B Gas Miner"
	overlay_color = COLOR_GAS_MINER_AGENT_B

/obj/machinery/atmospherics/miner/agent_b/add_gas_to(datum/gas_mixture/merger, count)
	merger.set_agent_b(count)

/obj/machinery/atmospherics/miner/freon
	name = "Freon Gas Miner"
	overlay_color = COLOR_GAS_MINER_FREON

/obj/machinery/atmospherics/miner/freon/add_gas_to(datum/gas_mixture/merger, count)
	merger.set_freon(count)

/obj/machinery/atmospherics/miner/halon
	name = "Halon Gas Miner"
	overlay_color = COLOR_GAS_MINER_HALON

/obj/machinery/atmospherics/miner/halon/add_gas_to(datum/gas_mixture/merger, count)
	merger.set_halon(count)

/obj/machinery/atmospherics/miner/healium
	name = "Healium Gas Miner"
	overlay_color = COLOR_GAS_MINER_HEALIUM

/obj/machinery/atmospherics/miner/healium/add_gas_to(datum/gas_mixture/merger, count)
	merger.set_healium(count)

/obj/machinery/atmospherics/miner/hydrogen
	name = "H2 Gas Miner"

/obj/machinery/atmospherics/miner/hydrogen/add_gas_to(datum/gas_mixture/merger, count)
	merger.set_hydrogen(count)

/obj/machinery/atmospherics/miner/hypernoblium
	name = "Hypernoblium Gas Miner"
	overlay_color = COLOR_GAS_MINER_HYPERNOBLIUM

/obj/machinery/atmospherics/miner/hypernoblium/add_gas_to(datum/gas_mixture/merger, count)
	merger.set_hypernoblium(count)

/obj/machinery/atmospherics/miner/miasma
	name = "Miasma Gas Miner"
	overlay_color = COLOR_GAS_MINER_MIASMA

/obj/machinery/atmospherics/miner/miasma/add_gas_to(datum/gas_mixture/merger, count)
	merger.set_miasma(count)

/obj/machinery/atmospherics/miner/nitrium
	name = "Nitrium Gas Miner"
	overlay_color = COLOR_GAS_MINER_NITRIUM

/obj/machinery/atmospherics/miner/nitrium/add_gas_to(datum/gas_mixture/merger, count)
	merger.set_nitrium(count)

/obj/machinery/atmospherics/miner/pluoxium
	name = "Pluoxium Gas Miner"
	overlay_color = COLOR_GAS_MINER_PLUOXIUM

/obj/machinery/atmospherics/miner/pluoxium/add_gas_to(datum/gas_mixture/merger, count)
	merger.set_pluoxium(count)

/obj/machinery/atmospherics/miner/proto_nitrate
	name = "Proto-Nitrate Gas Miner"
	overlay_color = COLOR_GAS_MINER_PROTO_NITRATE

/obj/machinery/atmospherics/miner/proto_nitrate/add_gas_to(datum/gas_mixture/merger, count)
	merger.set_proto_nitrate(count)

/obj/machinery/atmospherics/miner/tritium
	name = "Tritium Gas Miner"
	overlay_color = COLOR_GAS_MINER_TRITIUM

/obj/machinery/atmospherics/miner/tritium/add_gas_to(datum/gas_mixture/merger, count)
	merger.set_tritium(count)

/obj/machinery/atmospherics/miner/zauker
	name = "Zauker Gas Miner"
	overlay_color = COLOR_GAS_MINER_ZAUKER

/obj/machinery/atmospherics/miner/zauker/add_gas_to(datum/gas_mixture/merger, count)
	merger.set_zauker(count)

/obj/machinery/atmospherics/miner/helium
	name = "Helium Gas Miner"
	overlay_color = COLOR_GAS_MINER_HELIUM

/obj/machinery/atmospherics/miner/helium/add_gas_to(datum/gas_mixture/merger, count)
	merger.set_helium(count)

/obj/machinery/atmospherics/miner/antinoblium
	name = "Antinoblium Gas Miner"
	overlay_color = COLOR_GAS_MINER_ANTINOBLIUM

/obj/machinery/atmospherics/miner/antinoblium/add_gas_to(datum/gas_mixture/merger, count)
	merger.set_antinoblium(count)

/obj/machinery/atmospherics/miner/water_vapor
	name = "Water Vapor Gas Miner"
	overlay_color = COLOR_GAS_MINER_WATER_VAPOR

/obj/machinery/atmospherics/miner/water_vapor/add_gas_to(datum/gas_mixture/merger, count)
	merger.set_water_vapor(count)

#undef GASMINER_POWER_NONE
#undef GASMINER_POWER_STATIC
#undef GASMINER_POWER_MOLES
#undef GASMINER_POWER_KPA
#undef GASMINER_POWER_FULLSCALE
