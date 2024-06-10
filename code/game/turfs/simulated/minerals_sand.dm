#define MINERAL_SAND_CHANCE 6

/turf/simulated/mineral/sand
	name = "rock"
	icon = 'icons/turf/mining.dmi'
	icon_state = "sand"
	smooth_icon = 'icons/turf/smoothrocks_sand.dmi'
	baseturf = /turf/simulated/floor/plating/asteroid/sand
	turf_type = /turf/simulated/floor/plating/asteroid/sand
	mineralType = /obj/item/stack/ore/glass/sand

/turf/simulated/mineral/sand/random
	var/mineralSpawnChanceList = list(/turf/simulated/mineral/sand/uranium = 5,
		/turf/simulated/mineral/sand/diamond = 1, /turf/simulated/mineral/sand/gold = 10,
		/turf/simulated/mineral/sand/silver = 12, /turf/simulated/mineral/sand/plasma = 20,
		/turf/simulated/mineral/sand/iron = 40, /turf/simulated/mineral/sand/titanium = 11,
		/turf/simulated/mineral/sand/bscrystal = 1,/turf/simulated/mineral/sand/gem = 1)

/turf/simulated/mineral/sand/random/Initialize(mapload)
	mineralSpawnChanceList = typelist("mineralSpawnChanceList", mineralSpawnChanceList)
	. = ..()
	if (prob(MINERAL_SAND_CHANCE))
		var/path = pickweight(mineralSpawnChanceList)
		var/turf/T = ChangeTurf(path, FALSE, TRUE)

		if(T && ismineralturf(T))
			var/turf/simulated/mineral/M = T
			// M.mineralAmt = 1 // Due to how sandstorm is going to replenish empty areas with newer materials making resource renewable, it's gonna be set to 1
			M.turf_type = turf_type
			M.baseturf = baseturf
			src = M
			M.levelupdate()

/turf/simulated/mineral/sand/iron
	mineralType = /obj/item/stack/ore/iron
	spreadChance = 20
	spread = 1
	scan_state = "rock_iron"

/turf/simulated/mineral/sand/uranium
	mineralType = /obj/item/stack/ore/uranium
	spreadChance = 5
	spread = 1
	scan_state = "rock_uranium"

/turf/simulated/mineral/sand/diamond
	mineralType = /obj/item/stack/ore/diamond
	spreadChance = 0
	spread = 1
	scan_state = "rock_diamond"

/turf/simulated/mineral/sand/gold
	mineralType = /obj/item/stack/ore/gold
	spreadChance = 5
	spread = 1
	scan_state = "rock_gold"

/turf/simulated/mineral/sand/silver
	mineralType = /obj/item/stack/ore/silver
	spreadChance = 5
	spread = 1
	scan_state = "rock_silver"

/turf/simulated/mineral/sand/titanium
	mineralType = /obj/item/stack/ore/titanium
	spreadChance = 5
	spread = 1
	scan_state = "rock_titanium"

/turf/simulated/mineral/sand/plasma
	mineralType = /obj/item/stack/ore/plasma
	spreadChance = 8
	spread = 1
	scan_state = "rock_plasma"

/turf/simulated/mineral/sand/clown
	mineralType = /obj/item/stack/ore/bananium
	mineralAmt = 3
	spreadChance = 0
	spread = 0
	scan_state = "rock_clown"

/turf/simulated/mineral/sand/mime
	mineralType = /obj/item/stack/ore/tranquillite
	mineralAmt = 3
	spreadChance = 0
	spread = 0
	scan_state = "rock_mime"

/turf/simulated/mineral/sand/bscrystal
	mineralType = /obj/item/stack/ore/bluespace_crystal
	mineralAmt = 1
	spreadChance = 0
	spread = 0
	scan_state = "rock_bscrystal"

/turf/simulated/mineral/sand/gem
	mineralType = /obj/item/gem/random
	spread = 0
	mineralAmt = 1
	scan_state = "rock_Gem"

#undef MINERAL_SAND_CHANCE
