/datum/map_template/ruin
	//name = "A Chest of Doubloons"
	name = null
	var/id = null // For blacklisting purposes, all ruins need an id
	var/description = "In the middle of a clearing in the rockface, there's a \
		chest filled with gold coins with Spanish engravings. How is there a \
		wooden container filled with 18th century coinage in the middle of a \
		lavawracked hellscape? It is clearly a mystery."

	var/unpickable = FALSE 	 //If TRUE these won't be placed automatically (can still be forced or loaded with another ruin)
	var/always_place = FALSE //Will skip the whole weighting process and just plop this down, ideally you want the ruins of this kind to have no cost.
	var/placement_weight = 1 //How often should this ruin appear
	var/cost = 0 //Cost in ruin budget placement system
	var/allow_duplicates = TRUE
	var/list/never_spawn_with = null //If this ruin is spawned these will not eg list(/datum/map_template/ruin/base_alternate)

	var/prefix = null
	var/suffix = null

	var/can_found = FALSE //Can the ruin be found by the locator

/datum/map_template/ruin/New()
	if(!name && id)
		name = id

	mappath = prefix + suffix
	..(path = mappath)

/datum/map_template/ruin/proc/try_to_place(z, allowed_areas)
	var/sanity = PLACEMENT_TRIES
	while(sanity > 0)
		sanity--
		var/width_border = TRANSITIONEDGE + SPACERUIN_MAP_EDGE_PAD + round(width / 2)
		var/height_border = TRANSITIONEDGE + SPACERUIN_MAP_EDGE_PAD + round(height / 2)
		var/turf/central_turf = locate(rand(width_border, world.maxx - width_border), rand(height_border, world.maxy - height_border), z)
		var/valid = TRUE

		for(var/turf/check in get_affected_turfs(central_turf,1))
			var/area/new_area = get_area(check)
			if(!(istype(new_area, allowed_areas)) || check.turf_flags & NO_RUINS)
				valid = FALSE
				break

		if(!valid)
			continue

		log_world("Ruin \"[name]\" placed at ([central_turf.x], [central_turf.y], [central_turf.z])")

		for(var/i in get_affected_turfs(central_turf, 1))
			var/turf/T = i
			for(var/obj/structure/spawner/nest in T)
				qdel(nest)
			for(var/mob/living/simple_animal/monster in T)
				qdel(monster)
			for(var/obj/structure/flora/ash/plant in T)
				qdel(plant)

		load(central_turf,centered = TRUE)
		loaded++

		for(var/turf/T in get_affected_turfs(central_turf, 1))
			T.turf_flags |= NO_RUINS

		new /obj/effect/landmark/ruin(central_turf, src)
		return TRUE
	return FALSE
