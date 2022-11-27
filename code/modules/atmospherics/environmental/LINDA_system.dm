/atom
	///Check if atmos can pass in this atom (ATMOS_PASS_YES, ATMOS_PASS_NO, ATMOS_PASS_DENSITY, ATMOS_PASS_PROC)
	var/can_atmos_pass = ATMOS_PASS_YES

/atom/proc/CanAtmosPass(turf/target_turf, vertical = FALSE)
	switch (can_atmos_pass)
		if (ATMOS_PASS_PROC)
			return ATMOS_PASS_YES
		if (ATMOS_PASS_DENSITY)
			return !density
		else
			return can_atmos_pass

/turf
	can_atmos_pass = ATMOS_PASS_NO


/turf/proc/CanAtmosPass(turf/target_turf)
	if(!istype(target_turf))
		return FALSE
	var/direction = get_dir(src, target_turf)
	var/opposite_direction = reverse_direction(direction)
	var/can_pass = TRUE
	if(blocks_air || target_turf.blocks_air)
		can_pass = FALSE
	//This path is a bit weird, if we're just checking with ourselves no sense asking objects on the turf
	if (target_turf == src)
		return can_pass

	for(var/obj/checked_object in contents + target_turf.contents)
		var/turf/other = (checked_object.loc == src ? target_turf : src)
		if(CANATMOSPASS(checked_object, other))
			continue
		can_pass = FALSE
		if(checked_object.BlockSuperconductivity())	//the direction and open/closed are already checked on CanAtmosPass() so there are no arguments
			atmos_supeconductivity |= direction
			target_turf.atmos_supeconductivity |= opposite_direction
			return FALSE //no need to keep going, we got all we asked

	atmos_supeconductivity &= ~direction
	target_turf.atmos_supeconductivity &= ~opposite_direction

	return !can_pass

/atom/movable/proc/CanAtmosPass()
	return TRUE

/atom/movable/proc/BlockSuperconductivity() // objects that block air and don't let superconductivity act. Only firelocks atm.
	return FALSE

/turf/proc/CalculateAdjacentTurfs()
	LAZYINITLIST(src.atmos_adjacent_turfs)
	var/list/atmos_adjacent_turfs = src.atmos_adjacent_turfs
	for(var/direction in GLOB.cardinals)
		var/turf/current_turf = get_step(src, direction)
		if(!current_turf)
			continue
		if( !(blocks_air || current_turf.blocks_air) && CANATMOSPASS(src, src) && CANATMOSPASS(current_turf, src) )
			LAZYINITLIST(current_turf.atmos_adjacent_turfs)
			atmos_adjacent_turfs[current_turf] = TRUE
			current_turf.atmos_adjacent_turfs[src] = TRUE
		else
			atmos_adjacent_turfs -= current_turf
			if (current_turf.atmos_adjacent_turfs)
				current_turf.atmos_adjacent_turfs -= src
			UNSETEMPTY(current_turf.atmos_adjacent_turfs)
	UNSETEMPTY(atmos_adjacent_turfs)
	src.atmos_adjacent_turfs = atmos_adjacent_turfs

//returns a list of adjacent turfs that can share air with this one.
//alldir includes adjacent diagonal tiles that can share
//	air with both of the related adjacent cardinal tiles
/turf/proc/GetAtmosAdjacentTurfs(alldir = FALSE)
	if(!istype(src, /turf/simulated))
		return list()

	var/adjacent_turfs
	if(atmos_adjacent_turfs)
		adjacent_turfs = atmos_adjacent_turfs.Copy()
	else
		adjacent_turfs = list()

	if (!alldir)
		return adjacent_turfs

	var/turf/simulated/curloc = src
	for(var/direction in GLOB.cardinal)
		if(!(curloc.atmos_adjacent_turfs & direction))
			continue

		var/turf/simulated/S = get_step(curloc, direction)
		if(istype(S))
			adjacent_turfs += S
	if(!alldir)
		return adjacent_turfs

	for (var/direction in GLOB.diagonals)
		var/matchingDirections = 0
		var/turf/simulated/S = get_step(curloc, direction)

		for (var/checkDirection in GLOB.cardinals)
			var/turf/checkTurf = get_step(S, checkDirection)
			if(!S.atmos_adjacent_turfs || !S.atmos_adjacent_turfs[checkTurf])
				continue

			if(adjacent_turfs[checkTurf])
				matchingDirections++

			if(matchingDirections >= 2)
				adjacent_turfs += S
				break

	return adjacent_turfs

/atom/proc/air_update_turf(update = FALSE, remove = FALSE)
	var/turf/local_turf = get_turf(loc)
	if(!local_turf)
		return
	local_turf.air_update_turf(update, remove)

/**
 * A helper proc for dealing with atmos changes
 *
 * Ok so this thing is pretty much used as a catch all for all the situations someone might wanna change something
 * About a turfs atmos. It's real clunky, and someone needs to clean it up, but not today.
 * Arguments:
 * * update - Has the state of the structures in the world changed? If so, update our adjacent atmos turf list, if not, don't.
 * * remove - Are you removing an active turf (Read wall), or adding one
*/
/turf/air_update_turf(update = FALSE, remove = FALSE)
	if(update)
		CalculateAdjacentTurfs()

	if(remove)
		SSair.remove_from_active(src)
	else
		SSair.add_to_active(src)

/atom/movable/proc/move_update_air(turf/target_turf)
	if(isturf(target_turf))
		target_turf.air_update_turf(TRUE, FALSE) //You're empty now
	air_update_turf(TRUE, TRUE) //You aren't

/atom/proc/atmos_spawn_air(text) //because a lot of people loves to copy paste awful code lets just make an easy proc to spawn your plasma fires
	var/turf/simulated/local_turf = get_turf(src)
	if(!istype(local_turf))
		return
	local_turf.atmos_spawn_air(text)

/turf/simulated/proc/atmos_spawn_air(text)
	if(!text || !air)
		return

	var/datum/gas_mixture/turf_mixture = SSair.parse_gas_string(text, /datum/gas_mixture/turf)

	air.merge(turf_mixture)
	archive()
	SSair.add_to_active(src)
