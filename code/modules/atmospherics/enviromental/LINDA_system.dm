/turf/proc/CanAtmosPass(direction)
	var/can_pass = TRUE
	if(blocks_air)
		return FALSE

	//Can't just return if canpass is false here, we need to set superconductivity
	for(var/obj/object in contents) //from our turf to T
		if(isitem(object))
			// Items can't block atmos.
			continue
		if(!object.CanAtmosPass(direction))
			return FALSE

	return can_pass

/atom/movable/proc/CanAtmosPass(direction)
	return TRUE

/atom/movable/proc/get_superconductivity(direction)
	return OPEN_HEAT_TRANSFER_COEFFICIENT

/atom/movable/proc/recalculate_atmos_connectivity()
	for(var/turf/location in locs) // used by double wide doors and other nonexistant multitile structures
		location.recalculate_atmos_connectivity()

/atom/movable/proc/move_update_air(turf/turf)
	if(istype(turf))
		turf.recalculate_atmos_connectivity()
	recalculate_atmos_connectivity()

//returns a list of adjacent turfs that can share air with this one.
//alldir includes adjacent diagonal tiles that can share
//	air with both of the related adjacent cardinal tiles
/turf/proc/GetAtmosAdjacentTurfs(alldir = FALSE)
	if(!issimulatedturf(src))
		return list()

	var/adjacent_turfs = list()
	for(var/direction in GLOB.cardinal)
		var/turf/turf = get_step(src, direction)

		if(!turf)
			continue

		if(!CanAtmosPass(direction))
			continue

		if(!turf.CanAtmosPass(turn(direction, 180)))
			continue

		adjacent_turfs += turf

	if(!alldir)
		return adjacent_turfs

	for(var/turf/turf as anything in RANGE_TURFS(1, src))
		var/direction = get_dir(src, turf)
		if(direction in GLOB.cardinal)
			continue
		// check_direction is the first way we move, from src
		for(var/check_direction in GLOB.cardinal)
			if(!(check_direction & direction))
				// Wrong way.
				continue

			var/turf/intermediate = get_step(src, check_direction)
			if(!(intermediate in adjacent_turfs))
				continue

			// other_direction is the second way we move, from intermediate.
			var/other_direction = direction & ~check_direction

			// We already know we can reach intermediate, so now we just need to check the second step.
			if(!intermediate.CanAtmosPass(other_direction))
				continue
			if(!turf.CanAtmosPass(turn(other_direction, 180)))
				continue

			adjacent_turfs += turf
			break

	return adjacent_turfs

/atom/movable/proc/atmos_spawn_air(flag, amount, temp_amount = null) //because a lot of people loves to copy paste awful code lets just make a easy proc to spawn your plasma fires
	var/turf/simulated/turf = get_turf(src)

	if(!istype(turf))
		return

	turf.atmos_spawn_air(flag, amount, temp_amount)

/turf/simulated/proc/atmos_spawn_air(flag, amount, temp_amount = null)
	if(!flag || !amount || blocks_air)
		return

	var/datum/gas_mixture/gas = new()

	if(!isnull(temp_amount))
		gas.set_temperature(temp_amount)

	if(flag & LINDA_SPAWN_HEAT)
		gas.set_temperature(gas.temperature() + 1000)

	if(flag & LINDA_SPAWN_TOXINS)
		gas.set_toxins(gas.toxins() + amount)

	if(flag & LINDA_SPAWN_OXYGEN)
		gas.set_oxygen(gas.oxygen() + amount)

	if(flag & LINDA_SPAWN_CO2)
		gas.set_carbon_dioxide(gas.carbon_dioxide() + amount)

	if(flag & LINDA_SPAWN_NITROGEN)
		gas.set_nitrogen(gas.nitrogen() + amount)

	if(flag & LINDA_SPAWN_N2O)
		gas.set_sleeping_agent(gas.sleeping_agent() + amount)

	if(flag & LINDA_SPAWN_AGENT_B)
		gas.set_agent_b(gas.agent_b() + amount)

	if(flag & LINDA_SPAWN_AIR)
		gas.set_oxygen(gas.oxygen() + MOLES_O2STANDARD * amount)
		gas.set_nitrogen(gas.nitrogen() + MOLES_N2STANDARD * amount)

	if(flag & LINDA_SPAWN_HYDROGEN)
		gas.set_hydrogen(gas.hydrogen() + amount)

	if(flag & LINDA_SPAWN_WATER_VAPOR)
		gas.set_water_vapor(gas.water_vapor() + amount)

	if(flag & LINDA_SPAWN_TRITIUM)
		gas.set_tritium(gas.tritium() + amount)

	if(flag & LINDA_SPAWN_BZ)
		gas.set_bz(gas.bz() + amount)

	if(flag & LINDA_SPAWN_PLUOXIUM)
		gas.set_pluoxium(gas.pluoxium() + amount)

	if(flag & LINDA_SPAWN_MIASMA)
		gas.set_miasma(gas.miasma() + amount)

	if(flag & LINDA_SPAWN_FREON)
		gas.set_freon(gas.freon() + amount)

	if(flag & LINDA_SPAWN_NITRIUM)
		gas.set_nitrium(gas.nitrium() + amount)

	if(flag & LINDA_SPAWN_HEALIUM)
		gas.set_healium(gas.healium() + amount)

	if(flag & LINDA_SPAWN_PROTO_NITRATE)
		gas.set_proto_nitrate(gas.proto_nitrate() + amount)

	if(flag & LINDA_SPAWN_ZAUKER)
		gas.set_zauker(gas.zauker() + amount)

	if(flag & LINDA_SPAWN_HALON)
		gas.set_halon(gas.halon() + amount)

	if(flag & LINDA_SPAWN_HELIUM)
		gas.set_helium(gas.helium() + amount)

	if(flag & LINDA_SPAWN_ANTINOBLIUM)
		gas.set_antinoblium(gas.antinoblium() + amount)

	if(flag & LINDA_SPAWN_HYPER_NOBLIUM)
		gas.set_hypernoblium(gas.hypernoblium() + amount)

	if(flag & LINDA_SPAWN_TRITIUM)
		gas.set_tritium(gas.tritium() + amount)

	if(flag & LINDA_SPAWN_BZ)
		gas.set_bz(gas.bz() + amount)

	if(flag & LINDA_SPAWN_PLUOXIUM)
		gas.set_pluoxium(gas.pluoxium() + amount)

	if(flag & LINDA_SPAWN_MIASMA)
		gas.set_miasma(gas.miasma() + amount)

	if(flag & LINDA_SPAWN_FREON)
		gas.set_freon(gas.freon() + amount)

	if(flag & LINDA_SPAWN_NITRIUM)
		gas.set_nitrium(gas.nitrium() + amount)

	if(flag & LINDA_SPAWN_HEALIUM)
		gas.set_healium(gas.healium() + amount)

	if(flag & LINDA_SPAWN_PROTO_NITRATE)
		gas.set_proto_nitrate(gas.proto_nitrate() + amount)

	if(flag & LINDA_SPAWN_ZAUKER)
		gas.set_zauker(gas.zauker() + amount)

	if(flag & LINDA_SPAWN_HALON)
		gas.set_halon(gas.halon() + amount)

	if(flag & LINDA_SPAWN_HELIUM)
		gas.set_helium(gas.helium() + amount)

	if(flag & LINDA_SPAWN_ANTINOBLIUM)
		gas.set_antinoblium(gas.antinoblium() + amount)

	if(flag & LINDA_SPAWN_HYPER_NOBLIUM)
		gas.set_hypernoblium(gas.hypernoblium() + amount)

	blind_release_air(gas)
