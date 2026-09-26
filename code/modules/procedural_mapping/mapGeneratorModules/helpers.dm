//Helper Modules

// Helper to repressurize the area in case it was run in space
/datum/mapGeneratorModule/bottomLayer/repressurize
	spawnableAtoms = list()
	spawnableTurfs = list()

/datum/mapGeneratorModule/bottomLayer/repressurize/generate()
	if(!mother)
		return
	var/list/map = mother.map
	for(var/turf/simulated/T in map)
		var/datum/gas_mixture/air = T.get_initial_air()
		T.blind_set_air(air)

//Only places atoms/turfs on area borders
/datum/mapGeneratorModule/border
	clusterCheckFlags = CLUSTER_CHECK_NONE

/datum/mapGeneratorModule/border/generate()
	if(!mother)
		return
	var/list/map = mother.map
	for(var/turf/T in map)
		if(is_border(T))
			place(T)

/datum/mapGeneratorModule/border/proc/is_border(turf/T)
	for(var/direction in list(SOUTH,EAST,WEST,NORTH))
		if(get_step(T,direction) in mother.map)
			continue
		return 1
	return 0

/datum/mapGeneratorModule/bottomLayer/massdelete
	spawnableAtoms = list()
	spawnableTurfs = list()

/datum/mapGeneratorModule/bottomLayer/massdelete/generate()
	if(!mother)
		return
	for(var/V in mother.map)
		var/turf/T = V
		T.empty()
