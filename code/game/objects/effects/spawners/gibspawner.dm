/obj/effect/gibspawner/generic
	gibtypes = list(/obj/effect/decal/cleanable/blood/gibs,/obj/effect/decal/cleanable/blood/gibs,/obj/effect/decal/cleanable/blood/gibs/core)
	gibamounts = list(2,2,1)

/obj/effect/gibspawner/generic/Initialize(mapload, datum/dna/mob_dna)
	gibdirections = list(list(WEST, NORTHWEST, SOUTHWEST, NORTH),list(EAST, NORTHEAST, SOUTHEAST, SOUTH), list())
	return ..()

/obj/effect/gibspawner/human
	gibtypes = list(/obj/effect/decal/cleanable/blood/gibs,/obj/effect/decal/cleanable/blood/gibs/down,/obj/effect/decal/cleanable/blood/gibs,/obj/effect/decal/cleanable/blood/gibs,/obj/effect/decal/cleanable/blood/gibs,/obj/effect/decal/cleanable/blood/gibs,/obj/effect/decal/cleanable/blood/gibs/core)
	gibamounts = list(1,1,1,1,1,1,1)

/obj/effect/gibspawner/human/Initialize(mapload, datum/dna/mob_dna)
	gibdirections = list(list(NORTH, NORTHEAST, NORTHWEST),list(SOUTH, SOUTHEAST, SOUTHWEST),list(WEST, NORTHWEST, SOUTHWEST),list(EAST, NORTHEAST, SOUTHEAST), GLOB.alldirs, GLOB.alldirs, list())
	gibamounts[6] = pick(0,1,2)
	return ..()

/obj/effect/gibspawner/human/gib_dna(obj/effect/decal/cleanable/blood/gibs/gib, datum/dna/mob_dna)
	if(!..()) // Probably admin spawned
		gib.blood_DNA["Non-human DNA"] = "A+"

/obj/effect/gibspawner/xeno
	gibtypes = list(/obj/effect/decal/cleanable/blood/gibs/xeno/up,/obj/effect/decal/cleanable/blood/gibs/xeno/down,/obj/effect/decal/cleanable/blood/gibs/xeno,/obj/effect/decal/cleanable/blood/gibs/xeno,/obj/effect/decal/cleanable/blood/gibs/xeno/body,/obj/effect/decal/cleanable/blood/gibs/xeno/limb,/obj/effect/decal/cleanable/blood/gibs/xeno/core)
	gibamounts = list(1,1,1,1,1,1,1)

/obj/effect/gibspawner/xeno/Initialize(mapload, datum/dna/mob_dna)
	gibdirections = list(list(NORTH, NORTHEAST, NORTHWEST),list(SOUTH, SOUTHEAST, SOUTHWEST),list(WEST, NORTHWEST, SOUTHWEST),list(EAST, NORTHEAST, SOUTHEAST), GLOB.alldirs, GLOB.alldirs, list())
	gibamounts[6] = pick(0,1,2)
	return ..()

/obj/effect/gibspawner/xeno/gib_dna(obj/effect/decal/cleanable/blood/gibs/gib, datum/dna/mob_dna)
	if(!..())
		gib.blood_DNA["UNKNOWN DNA"] = "X*"

/obj/effect/gibspawner/robot
	sparks = 2
	gibtypes = list(/obj/effect/decal/cleanable/blood/gibs/robot/up,/obj/effect/decal/cleanable/blood/gibs/robot/down,/obj/effect/decal/cleanable/blood/gibs/robot,/obj/effect/decal/cleanable/blood/gibs/robot,/obj/effect/decal/cleanable/blood/gibs/robot,/obj/effect/decal/cleanable/blood/gibs/robot/limb)
	gibamounts = list(1,1,1,1,1,1)

/obj/effect/gibspawner/robot/Initialize(mapload, datum/dna/mob_dna)
	gibdirections = list(list(NORTH, NORTHEAST, NORTHWEST),list(SOUTH, SOUTHEAST, SOUTHWEST),list(WEST, NORTHWEST, SOUTHWEST),list(EAST, NORTHEAST, SOUTHEAST), GLOB.alldirs, GLOB.alldirs)
	gibamounts[6] = pick(0,1,2)
	return ..()

/obj/effect/gibspawner/clock
	sparks = 2
	gibtypes = list(/obj/effect/decal/cleanable/blood/gibs/clock,/obj/effect/decal/cleanable/blood/gibs/clock,/obj/effect/decal/cleanable/blood/gibs/clock,/obj/effect/decal/cleanable/blood/gibs/clock,/obj/effect/decal/cleanable/blood/gibs/clock,/obj/effect/decal/cleanable/blood/gibs/clock)
	gibamounts = list(1,1,1,1,1,1)

/obj/effect/gibspawner/clock/Initialize(mapload, datum/dna/mob_dna)
	gibdirections = list(list(NORTH, NORTHEAST, NORTHWEST),list(SOUTH, SOUTHEAST, SOUTHWEST),list(WEST, NORTHWEST, SOUTHWEST),list(EAST, NORTHEAST, SOUTHEAST), GLOB.alldirs, GLOB.alldirs)
	return ..()

/obj/effect/gibspawner/confetti
	gibtypes = list(/obj/effect/decal/cleanable/confetti, /obj/effect/decal/cleanable/confetti)
	gibamounts = list(3, 1) //separated to leave one in place
	sound_to_play = 'sound/effects/confetti_partywhistle.ogg'
	sound_vol = 30
	sound_vary = TRUE

/obj/effect/gibspawner/confetti/Initialize(mapload, datum/dna/mob_dna)
	gibdirections = list(GLOB.alldirs, list()) //3 will go in any direction one will not move
	return ..()

