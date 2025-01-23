/datum/mapGeneratorModule/bottomLayer/cultFloor
	spawnableTurfs = list(/turf/simulated/floor/engine/cult = 100)

/datum/mapGeneratorModule/border/cultWalls
	spawnableTurfs = list(/turf/simulated/wall/cult = 100)


/datum/mapGeneratorModule/bottomLayer/clockFloor
	spawnableTurfs = list(/turf/simulated/floor/clockwork = 100)

/datum/mapGeneratorModule/border/clockWalls
	spawnableTurfs = list(/turf/simulated/wall/clockwork = 100)


/datum/mapGenerator/cult //walls and floor only
		modules = list(/datum/mapGeneratorModule/bottomLayer/cultFloor, \
		/datum/mapGeneratorModule/border/cultWalls, \
		/datum/mapGeneratorModule/bottomLayer/repressurize)

/datum/mapGenerator/clock //walls and floor only
		modules = list(/datum/mapGeneratorModule/bottomLayer/clockFloor, \
		/datum/mapGeneratorModule/border/clockWalls, \
		/datum/mapGeneratorModule/bottomLayer/repressurize)

/datum/mapGenerator/cult/floor //floors only
		modules = list(/datum/mapGeneratorModule/bottomLayer/cultFloor, \
		/datum/mapGeneratorModule/bottomLayer/repressurize)

/datum/mapGenerator/clock/floor //floor only
		modules = list(/datum/mapGeneratorModule/bottomLayer/clockFloor, \
		/datum/mapGeneratorModule/bottomLayer/repressurize)
