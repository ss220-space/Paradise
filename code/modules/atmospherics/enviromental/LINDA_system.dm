/turf/proc/CanAtmosPass(turf/T, vertical = FALSE)
	if(!istype(T))
		return FALSE
	var/direction = vertical ? get_dir_multiz(src, T) : get_dir(src, T)//if not UP and DOWN, get_dir_multiz returns get_dir
	var/can_pass = TRUE
	if(vertical && !(zAirOut(direction, T) && T.zAirIn(direction, src)))
		can_pass = FALSE
	if(blocks_air || T.blocks_air)
		can_pass = FALSE
	//If we're just checking with ourselves no sense asking objects on the turf
	if(T == src)
		return can_pass

	//Can't just return if canpass is false here, we need to set superconductivity
	for(var/obj/O in contents) //from our turf to T
		if(O.CanAtmosPass(T, vertical))
			continue
		can_pass = FALSE
		if(O.BlockSuperconductivity()) 	//the direction and open/closed are already checked on CanAtmosPass() so there are no arguments
			atmos_supeconductivity |= direction
			T.atmos_supeconductivity |= reverse_direction(direction)
			return FALSE				//no need to keep going, we got all we asked

	for(var/obj/O in T.contents) //from T turf to ours
		if(O.CanAtmosPass(src, vertical))
			continue
		can_pass = FALSE
		if(O.BlockSuperconductivity())
			atmos_supeconductivity |= direction
			T.atmos_supeconductivity |= reverse_direction(direction)
			return FALSE

	atmos_supeconductivity &= ~direction
	T.atmos_supeconductivity &= ~reverse_direction(direction)

	return can_pass

/atom/movable/proc/CanAtmosPass()
	return TRUE

/atom/movable/proc/BlockSuperconductivity() // objects that block air and don't let superconductivity act. Only firelocks atm.
	return FALSE

/turf/proc/CalculateAdjacentTurfs()
	atmos_adjacent_turfs_amount = 0
	for(var/direction in GLOB.cardinals_multiz)
		var/turf/turf_target
		if(direction & (UP|DOWN))
			turf_target = (direction & UP) ? GET_TURF_ABOVE(src) : GET_TURF_BELOW(src)
		else
			turf_target = get_step(src, direction)
		if(!istype(turf_target))
			continue
		var/counterdir = get_dir_multiz(turf_target, src)
		var/vertical = (direction & (UP | DOWN))
		if(CanAtmosPass(turf_target, vertical))
			atmos_adjacent_turfs_amount += 1
			atmos_adjacent_turfs |= direction
			if(!(turf_target.atmos_adjacent_turfs & counterdir))
				turf_target.atmos_adjacent_turfs_amount += 1
			turf_target.atmos_adjacent_turfs |= counterdir
		else
			atmos_adjacent_turfs &= ~direction
			if(turf_target.atmos_adjacent_turfs & counterdir)
				turf_target.atmos_adjacent_turfs_amount -= 1
			turf_target.atmos_adjacent_turfs &= ~counterdir

//returns a list of adjacent turfs that can share air with this one.
//alldir includes adjacent diagonal tiles that can share
//	air with both of the related adjacent cardinal tiles
/turf/proc/GetAtmosAdjacentTurfs(alldir = FALSE)
	if(!issimulatedturf(src))
		return list()

	var/adjacent_turfs = list()
	var/turf/simulated/curloc = src
	for(var/direction in GLOB.cardinals_multiz)
		if(!(curloc.atmos_adjacent_turfs & direction))
			continue

		var/turf/simulated/S = get_step_multiz(curloc, direction)
		if(istype(S))
			adjacent_turfs += S
	if(!alldir)
		return adjacent_turfs

	for(var/direction in GLOB.diagonals_multiz)
		var/matchingDirections = 0
		var/turf/simulated/S = get_step_multiz(curloc, direction)

		for(var/checkDirection in GLOB.cardinals_multiz)
			if(!(S?.atmos_adjacent_turfs & checkDirection))
				continue
			var/turf/simulated/checkTurf = get_step(S, checkDirection)

			if(checkTurf in adjacent_turfs)
				matchingDirections++

			if(matchingDirections >= 2)
				adjacent_turfs += S
				break

	return adjacent_turfs

/atom/movable/proc/air_update_turf(command = FALSE)
	if(!istype(loc,/turf) && command)
		return
	for(var/turf/T in locs) // used by double wide doors and other nonexistant multitile structures
		T.air_update_turf(command)

/turf/proc/air_update_turf(command = FALSE)
	if(command)
		CalculateAdjacentTurfs()
	if(SSair)
		SSair.add_to_active(src, command)

/atom/movable/proc/move_update_air(var/turf/T)
    if(istype(T,/turf))
        T.air_update_turf(1)
    air_update_turf(1)



/atom/movable/proc/atmos_spawn_air(text, amount) //because a lot of people loves to copy paste awful code lets just make a easy proc to spawn your plasma fires
	var/turf/simulated/T = get_turf(src)
	if(!istype(T))
		return
	T.atmos_spawn_air(text, amount)

/turf/simulated/proc/atmos_spawn_air(flag, amount)
	if(!text || !amount || !air)
		return

	var/datum/gas_mixture/G = new

	if(flag & LINDA_SPAWN_20C)
		G.temperature = T20C

	if(flag & LINDA_SPAWN_HEAT)
		G.temperature += 1000

	if(flag & LINDA_SPAWN_TOXINS)
		G.toxins += amount

	if(flag & LINDA_SPAWN_OXYGEN)
		G.oxygen += amount

	if(flag & LINDA_SPAWN_CO2)
		G.carbon_dioxide += amount

	if(flag & LINDA_SPAWN_NITROGEN)
		G.nitrogen += amount

	if(flag & LINDA_SPAWN_N2O)
		G.sleeping_agent += amount

	if(flag & LINDA_SPAWN_AGENT_B)
		G.agent_b += amount

	if(flag & LINDA_SPAWN_AIR)
		G.oxygen += MOLES_O2STANDARD * amount
		G.nitrogen += MOLES_N2STANDARD * amount

	air.merge(G)
	SSair.add_to_active(src, FALSE)
