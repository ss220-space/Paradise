/datum/map_template/ruin
	name = null
	/// For blacklisting purposes, all ruins need an id
	var/id = null
	var/description = "In the middle of a clearing in the rockface, there's a \
		chest filled with gold coins with Spanish engravings. How is there a \
		wooden container filled with 18th century coinage in the middle of a \
		lavawracked hellscape? It is clearly a mystery."

	/// If TRUE these won't be placed automatically (can still be forced or loaded with another ruin)
	var/unpickable = FALSE
	/// Will skip the whole weighting process and just plop this down, ideally you want the ruins of this kind to have no cost.
	var/always_place = FALSE
	/// How often should this ruin appear
	var/placement_weight = 1
	/// Cost in ruin budget placement system
	var/cost = 0
	/// If TRUE, this ruin can be placed multiple times in the same map
	var/allow_duplicates = TRUE
	/// If this ruin is spawned these will not eg list(/datum/map_template/ruin/base_alternate)
	var/list/never_spawn_with = null
	/// Static part of the ruin path eg "_maps\RandomRuins\LavaRuins\"
	var/prefix = null
	/// The dynamic part of the ruin path eg "lavaland_surface_ruinfile.dmm"
	var/suffix = null
	/// Can the ruin be found by the locator
	var/can_found = FALSE

/datum/map_template/ruin/New()
	if(!name && id)
		name = id
	check_specials()
	mappath = prefix + suffix
	..(path = mappath)

/datum/map_template/ruin/proc/check_specials()
	return

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

		log_world("Ruin \"[name]\" placed at ([COORD(central_turf)])")

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
