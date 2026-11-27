// PLANETOID GROUND TURFS

// === PARENT ===
/turf/simulated/floor/planetoid
	name = "ground dirt"
	desc = "Поверхность планеты."
	icon = 'icons/turf/ground_map.dmi'
	icon_state = "desert"
	atmos_mode = ATMOS_MODE_EXPOSED_TO_ENVIRONMENT
	atmos_environment = ENVIRONMENT_PLANETOID
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_SAND
	underfloor_accessibility = UNDERFLOOR_INTERACTABLE
	baseturf = /turf/simulated/floor/planetoid
	intact = FALSE

/turf/simulated/floor/planetoid/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON, PROC_REF(on_underfloor_atom_inited))

/// Sand and grass conceal underground structures.
/turf/simulated/floor/planetoid/levelupdate()
	for(var/obj/object in src)
		if(object.level == 1 && (object.flags & INITIALIZED))
			underfloor_cover(object)

/turf/simulated/floor/planetoid/proc/underfloor_cover(obj/object)
	if(!istype(object, /obj/machinery/atmospherics/pipe) && !istype(object, /obj/structure/disposalpipe) && !istype(object, /obj/structure/cable))
		return
	SET_PLANE_IMPLICIT(object, FLOOR_PLANE)
	object.invisibility = INVISIBILITY_MAXIMUM

/turf/simulated/floor/planetoid/proc/on_underfloor_atom_inited(datum/source, atom/movable/arrived)
	SIGNAL_HANDLER
	underfloor_cover(arrived)

/turf/simulated/floor/planetoid/ex_act(severity, target)
	return

/turf/simulated/floor/planetoid/fire_act(exposed_temperature, exposed_volume)
	return

/turf/simulated/floor/planetoid/remove_plating()
	return

/turf/simulated/floor/planetoid/crowbar_act(mob/user, obj/item/I)
	return

/turf/simulated/floor/planetoid/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/stack/rods))
		build_with_rods(tool, user)
		var/obj/structure/lattice/built_lattice = locate() in src
		if(built_lattice)
			built_lattice.layer = MID_TURF_LAYER
		return ITEM_INTERACT_SUCCESS

	if(istype(tool, /obj/item/stack/tile))
		var/obj/structure/lattice/lattice = locate() in src
		if(!lattice)
			to_chat(user, span_warning("Грунту потребуется опора! Сначала установите металлические стержни."))
			return ITEM_INTERACT_BLOCKING
		var/obj/item/stack/tile/tile = tool
		if(!tile.turf_type)
			return ITEM_INTERACT_BLOCKING
		if(!tile.use(1))
			to_chat(user, span_warning("Для постройки пола нужна одна напольная плитка!"))
			return ITEM_INTERACT_BLOCKING
		qdel(lattice)
		playsound(src, 'sound/weapons/genhit.ogg', 50, TRUE)
		if(istype(tile, /obj/item/stack/tile/plasteel))
			ChangeTurf(/turf/simulated/floor/plating, keep_icon = FALSE)
		else
			ChangeTurf(tile.turf_type, keep_icon = FALSE)
		return ITEM_INTERACT_SUCCESS

	return NONE


/turf/simulated/floor/planetoid/ReplaceWithLattice()
	new /obj/structure/lattice(src)

/turf/simulated/floor/planetoid/make_plating(make_floor_tile, mob/user)
	return

/turf/simulated/floor/planetoid/singularity_pull(atom/singularity, current_size)
	return

/turf/simulated/floor/planetoid/narsie_act()
	return

/turf/simulated/floor/planetoid/ratvar_act(convert_mecha = FALSE)
	return

// MARK: DESERT
/turf/simulated/floor/planetoid/desert
	name = "desert"
	baseturf = /turf/simulated/floor/planetoid/desert
	var/obj/item/stack/dig_result = /obj/item/stack/ore/glass
	var/dug

/turf/simulated/floor/planetoid/desert/get_ru_names()
	return alist(
		NOMINATIVE = "песок",
		GENITIVE = "песка",
		DATIVE = "песку",
		ACCUSATIVE = "песок",
		INSTRUMENTAL = "песком",
		PREPOSITIONAL = "песке",
	)

/turf/simulated/floor/planetoid/desert/Initialize(mapload)
	. = ..()
	icon_state = "desert[rand(0, 3)]"

/turf/simulated/floor/planetoid/desert/desert

/turf/simulated/floor/planetoid/desert/desert0
	icon_state = "desert0"

/turf/simulated/floor/planetoid/desert/desert1
	icon_state = "desert1"

/turf/simulated/floor/planetoid/desert/desert2
	icon_state = "desert2"

/turf/simulated/floor/planetoid/desert/desert3
	icon_state = "desert3"

/turf/simulated/floor/planetoid/desert/dark
	icon_state = "desert5"

/turf/simulated/floor/planetoid/desert/dark/desert1

/turf/simulated/floor/planetoid/desert/dark/desert2
	icon_state = "desert6"

/turf/simulated/floor/planetoid/desert/dark/desert3
	icon_state = "desert7"

/turf/simulated/floor/planetoid/desert/desert_dug
	icon_state = "desert_dug"
	dug = TRUE

// DESERT - BEACH EDGE
/turf/simulated/floor/planetoid/desert/beachedge
	icon_state = "beach"
	baseturf = /turf/simulated/floor/planetoid/desert/beachedge

/turf/simulated/floor/planetoid/desert/beachedge/Initialize(mapload)
	. = ..()
	icon_state ="beach"

MAPPING_DIRECTIONAL_HELPERS(/turf/simulated/floor/planetoid/desert/beachedge, 0, 0)

// DESERT - BEACH CORNER
/turf/simulated/floor/planetoid/desert/beachcorner
	icon_state = "beachcorner"
	baseturf = /turf/simulated/floor/planetoid/desert/beachcorner

/turf/simulated/floor/planetoid/desert/beachcorner/Initialize(mapload)
	. = ..()
	icon_state ="beachcorner"

MAPPING_DIRECTIONAL_HELPERS(/turf/simulated/floor/planetoid/desert/beachcorner, 0, 0)

/turf/simulated/floor/planetoid/desert/beachcorner2
	icon_state = "beachcorner2"
	baseturf = /turf/simulated/floor/planetoid/desert/beachcorner2

/turf/simulated/floor/planetoid/desert/beachcorner2/Initialize(mapload)
	. = ..()
	icon_state ="beachcorner2"

MAPPING_DIRECTIONAL_HELPERS(/turf/simulated/floor/planetoid/desert/beachcorner2, 0, 0)

/turf/simulated/floor/planetoid/desert/update_icon_state()
	if(dug)
		icon_state = "desert_dug"
	else
		icon_state =  initial(icon_state)

/turf/simulated/floor/planetoid/desert/proc/can_dig(mob/user)
	if(!dug)
		return TRUE
	if(user)
		to_chat(user, span_notice("Похоже, здесь уже копали."))

/turf/simulated/floor/planetoid/desert/proc/get_dug()
	new dig_result(src, 5)
	dug = TRUE
	update_icon(UPDATE_ICON_STATE)

/turf/simulated/floor/planetoid/desert/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(ATTACK_CHAIN_CANCEL_CHECK(.))
		return .

	if(istype(I, /obj/item/shovel) || I.tool_behaviour == TOOL_MINING)
		if(!can_dig(user))
			return .
		I.play_tool_sound()
		to_chat(user, span_notice("Вы начинаете копать..."))
		if(!do_after(user, 4 SECONDS * I.toolspeed, src, category = DA_CAT_TOOL) || !istype(src, /turf/simulated/floor/planetoid/desert) || !can_dig(user))
			return .
		I.play_tool_sound()
		to_chat(user, span_notice("Вы выкопали яму."))
		if(user.a_intent == INTENT_DISARM)
			new /obj/structure/pit(src)
			dug = TRUE
		else
			get_dug()
		return .|ATTACK_CHAIN_SUCCESS

// MARK: DIRT
/turf/simulated/floor/planetoid/dirt
	name = "dirt"
	icon_state = "dirt"
	baseturf = /turf/simulated/floor/planetoid/dirt

// MARK: GRASS
/turf/simulated/floor/planetoid/grass
	name = "grass"
	icon_state = "grass1"
	baseturf = /turf/simulated/floor/planetoid/grass
	footstep = FOOTSTEP_GRASS
	barefootstep = FOOTSTEP_GRASS
	clawfootstep = FOOTSTEP_GRASS
	heavyfootstep = FOOTSTEP_GRASS

/turf/simulated/floor/planetoid/grass/get_ru_names()
	return alist(
		NOMINATIVE = "трава",
		GENITIVE = "травы",
		DATIVE = "траве",
		ACCUSATIVE = "трава",
		INSTRUMENTAL = "травой",
		PREPOSITIONAL = "траве",
	)

/turf/simulated/floor/planetoid/grass/grass1

/turf/simulated/floor/planetoid/grass/grass2
	icon_state = "grass2"

/turf/simulated/floor/planetoid/grass/grass3
	icon_state = "grass3"

/turf/simulated/floor/planetoid/grass/sandsingle
	icon_state = "grassdirt_single"

// MARK: DGRASS
/turf/simulated/floor/planetoid/grass/dgrass
	icon_state = "dgrass0"
	baseturf = /turf/simulated/floor/planetoid/grass/dgrass

/turf/simulated/floor/planetoid/grass/dgrass/Initialize(mapload)
	. = ..()
	if(rand(0, 15) == 0) // occasional texture variation
		icon_state = "dgrass[rand(0, 4)]"

/turf/simulated/floor/planetoid/grass/dgrass/dgrass0

/turf/simulated/floor/planetoid/grass/dgrass/dgrass1
	icon_state = "dgrass1"

/turf/simulated/floor/planetoid/grass/dgrass/dgrass2
	icon_state = "dgrass2"

/turf/simulated/floor/planetoid/grass/dgrass/dgrass3
	icon_state = "dgrass3"

/turf/simulated/floor/planetoid/grass/dgrass/dgrass4
	icon_state = "dgrass4"

// MARK: FULL GRASS
/turf/simulated/floor/planetoid/grass/fullgrass
	icon_state = "fullgrass0"
	baseturf = /turf/simulated/floor/planetoid/grass/fullgrass

/turf/simulated/floor/planetoid/grass/fullgrass/Initialize(mapload)
	. = ..()
	if(rand(0, 15) == 0) // occasional texture variation
		icon_state = "fullgrass[rand(0, 4)]"

/turf/simulated/floor/planetoid/grass/fullgrass/fullgrass0

/turf/simulated/floor/planetoid/grass/fullgrass/fullgrass1
	icon_state = "fullgrass1"

/turf/simulated/floor/planetoid/grass/fullgrass/fullgrass2
	icon_state = "fullgrass2"

/turf/simulated/floor/planetoid/grass/fullgrass/fullgrass3
	icon_state = "fullgrass3"

/turf/simulated/floor/planetoid/grass/fullgrass/fullgrass4
	icon_state = "fullgrass4"

// GRASS - SAND EDGE
/turf/simulated/floor/planetoid/grass/sandedge
	icon_state = "grassdirt_edge"
	baseturf = /turf/simulated/floor/planetoid/grass/sandedge

MAPPING_DIRECTIONAL_HELPERS(/turf/simulated/floor/planetoid/grass/sandedge, 0, 0)

// GRASS - SAND CORNER
/turf/simulated/floor/planetoid/grass/sandcorner
	icon_state = "grassdirt_corner"
	baseturf = /turf/simulated/floor/planetoid/grass/sandcorner

MAPPING_DIRECTIONAL_HELPERS(/turf/simulated/floor/planetoid/grass/sandcorner, 0, 0)

/turf/simulated/floor/planetoid/grass/sandcorner2
	icon_state = "grassdirt_corner2"
	baseturf = /turf/simulated/floor/planetoid/grass/sandcorner2

MAPPING_DIRECTIONAL_HELPERS(/turf/simulated/floor/planetoid/grass/sandcorner2, 0, 0)

// GRASS - DIRT EDGE
/turf/simulated/floor/planetoid/grass/dirtedge
	icon_state = "grassdirt2_edge"
	baseturf = /turf/simulated/floor/planetoid/grass/dirtedge

MAPPING_DIRECTIONAL_HELPERS(/turf/simulated/floor/planetoid/grass/dirtedge, 0, 0)

// GRASS - DIRT CORNER
/turf/simulated/floor/planetoid/grass/dirtcorner
	icon_state = "grassdirt2_corner"
	baseturf = /turf/simulated/floor/planetoid/grass/dirtcorner

MAPPING_DIRECTIONAL_HELPERS(/turf/simulated/floor/planetoid/grass/dirtcorner, 0, 0)

/turf/simulated/floor/planetoid/grass/dirtcorner2
	icon_state = "grassdirt2_corner2"
	baseturf = /turf/simulated/floor/planetoid/grass/dirtcorner2

MAPPING_DIRECTIONAL_HELPERS(/turf/simulated/floor/planetoid/grass/dirtcorner2, 0, 0)

// GRASS - BEACH EDGE
/turf/simulated/floor/planetoid/grass/beachedge
	icon_state = "grassbeach"
	baseturf = /turf/simulated/floor/planetoid/grass/beachedge

MAPPING_DIRECTIONAL_HELPERS(/turf/simulated/floor/planetoid/grass/beachedge, 0, 0)

// GRASS - BEACH CORNER
/turf/simulated/floor/planetoid/grass/beachcorner
	icon_state = "gbcorner"
	baseturf = /turf/simulated/floor/planetoid/grass/beachcorner

MAPPING_DIRECTIONAL_HELPERS(/turf/simulated/floor/planetoid/grass/beachcorner, 0, 0)

// MARK: GRASS SCORCHED
/turf/simulated/floor/planetoid/grass/scorched1
	icon_state = "grass1_scorched1"
	baseturf = /turf/simulated/floor/planetoid/grass/scorched1

/turf/simulated/floor/planetoid/grass/scorched1/scorched_alt
	icon_state = "grass2_scorched1"

/turf/simulated/floor/planetoid/grass/scorched1/single
	icon_state = "grassdirt_single_scorched1"

// GRASS SCORCHED - SAND EDGE
/turf/simulated/floor/planetoid/grass/scorched1/sandedge
	icon_state = "grassdirt_edge_scorched1"
	baseturf = /turf/simulated/floor/planetoid/grass/scorched1/sandedge

MAPPING_DIRECTIONAL_HELPERS(/turf/simulated/floor/planetoid/grass/scorched1/sandedge, 0, 0)

// GRASS SCORCHED - SAND CORNER
/turf/simulated/floor/planetoid/grass/scorched1/sandcorner
	icon_state = "grassdirt_corner_scorched1"
	baseturf = /turf/simulated/floor/planetoid/grass/scorched1/sandcorner

MAPPING_DIRECTIONAL_HELPERS(/turf/simulated/floor/planetoid/grass/scorched1/sandcorner, 0, 0)

/turf/simulated/floor/planetoid/grass/scorched1/sandcorner2
	icon_state = "grassdirt_corner2_scorched1"
	baseturf = /turf/simulated/floor/planetoid/grass/scorched1/sandcorner2

MAPPING_DIRECTIONAL_HELPERS(/turf/simulated/floor/planetoid/grass/scorched1/sandcorner2, 0, 0)

// GRASS SCORCHED - BEACH EDGE
/turf/simulated/floor/planetoid/grass/scorched1/beachedge
	icon_state = "grassbeach_scorched1"
	baseturf = /turf/simulated/floor/planetoid/grass/scorched1/beachedge

MAPPING_DIRECTIONAL_HELPERS(/turf/simulated/floor/planetoid/grass/scorched1/beachedge, 0, 0)

// GRASS SCORCHED - BEACH CORNER
/turf/simulated/floor/planetoid/grass/scorched1/beachcorner
	icon_state = "gbcorner_scorched1"
	baseturf = /turf/simulated/floor/planetoid/grass/scorched1/beachcorner

MAPPING_DIRECTIONAL_HELPERS(/turf/simulated/floor/planetoid/grass/scorched1/beachcorner, 0, 0)

// MARK: GRASS SCORCHED2
/turf/simulated/floor/planetoid/grass/scorched2
	icon_state = "grass1_scorched2"
	baseturf = /turf/simulated/floor/planetoid/grass/scorched2

/turf/simulated/floor/planetoid/grass/scorched2/scorched_alt
	icon_state = "grass2_scorched2"

/turf/simulated/floor/planetoid/grass/scorched2/single
	icon_state = "grassdirt_single_scorched2"

// GRASS SCORCHED2 - SAND EDGE
/turf/simulated/floor/planetoid/grass/scorched2/sandedge
	icon_state = "grassdirt_edge_scorched2"
	baseturf = /turf/simulated/floor/planetoid/grass/scorched2/sandedge

MAPPING_DIRECTIONAL_HELPERS(/turf/simulated/floor/planetoid/grass/scorched2/sandedge, 0, 0)

// GRASS SCORCHED2 - SAND CORNER
/turf/simulated/floor/planetoid/grass/scorched2/sandcorner
	icon_state = "grassdirt_corner_scorched2"
	baseturf = /turf/simulated/floor/planetoid/grass/scorched2/sandcorner

MAPPING_DIRECTIONAL_HELPERS(/turf/simulated/floor/planetoid/grass/scorched2/sandcorner, 0, 0)

/turf/simulated/floor/planetoid/grass/scorched2/sandcorner2
	icon_state = "grassdirt_corner2_scorched2"
	baseturf = /turf/simulated/floor/planetoid/grass/scorched2/sandcorner2

MAPPING_DIRECTIONAL_HELPERS(/turf/simulated/floor/planetoid/grass/scorched2/sandcorner2, 0, 0)

// GRASS SCORCHED2 - BEACH EDGE
/turf/simulated/floor/planetoid/grass/scorched2/beachedge
	icon_state = "grassbeach_scorched2"
	baseturf = /turf/simulated/floor/planetoid/grass/scorched2/beachedge

MAPPING_DIRECTIONAL_HELPERS(/turf/simulated/floor/planetoid/grass/scorched2/beachedge, 0, 0)

// GRASS SCORCHED2 - BEACH CORNER
/turf/simulated/floor/planetoid/grass/scorched2/beachcorner
	icon_state = "gbcorner_scorched2"
	baseturf = /turf/simulated/floor/planetoid/grass/scorched2/beachcorner

MAPPING_DIRECTIONAL_HELPERS(/turf/simulated/floor/planetoid/grass/scorched2/beachcorner, 0, 0)

// MARK: GRASS SCORCHED3
/turf/simulated/floor/planetoid/grass/scorched3
	icon_state = "grass1_scorched3"
	baseturf = /turf/simulated/floor/planetoid/grass/scorched3

/turf/simulated/floor/planetoid/grass/scorched3/scorched_alt
	icon_state = "grass2_scorched3"

/turf/simulated/floor/planetoid/grass/scorched3/single
	icon_state = "grassdirt_single_scorched3"

// GRASS SCORCHED3 - SAND EDGE
/turf/simulated/floor/planetoid/grass/scorched3/sandedge
	icon_state = "grassdirt_edge_scorched3"
	baseturf = /turf/simulated/floor/planetoid/grass/scorched3/sandedge

MAPPING_DIRECTIONAL_HELPERS(/turf/simulated/floor/planetoid/grass/scorched3/sandedge, 0, 0)

// GRASS SCORCHED3 - SAND CORNER
/turf/simulated/floor/planetoid/grass/scorched3/sandcorner
	icon_state = "grassdirt_corner_scorched3"
	baseturf = /turf/simulated/floor/planetoid/grass/scorched3/sandcorner

MAPPING_DIRECTIONAL_HELPERS(/turf/simulated/floor/planetoid/grass/scorched3/sandcorner, 0, 0)

/turf/simulated/floor/planetoid/grass/scorched3/sandcorner2
	icon_state = "grassdirt_corner2_scorched3"
	baseturf = /turf/simulated/floor/planetoid/grass/scorched3/sandcorner2

MAPPING_DIRECTIONAL_HELPERS(/turf/simulated/floor/planetoid/grass/scorched3/sandcorner2, 0, 0)

// GRASS SCORCHED3 - BEACH EDGE
/turf/simulated/floor/planetoid/grass/scorched3/beachedge
	icon_state = "grassbeach_scorched3"
	baseturf = /turf/simulated/floor/planetoid/grass/scorched3/beachedge

MAPPING_DIRECTIONAL_HELPERS(/turf/simulated/floor/planetoid/grass/scorched3/beachedge, 0, 0)

// GRASS SCORCHED3 - BEACH CORNER
/turf/simulated/floor/planetoid/grass/scorched3/beachcorner
	icon_state = "gbcorner_scorched3"
	baseturf = /turf/simulated/floor/planetoid/grass/scorched3/beachcorner

MAPPING_DIRECTIONAL_HELPERS(/turf/simulated/floor/planetoid/grass/scorched3/beachcorner, 0, 0)

// MARK: Water
/turf/simulated/floor/water/planetoid
	icon = 'icons/turf/ground_map.dmi'
	icon_state = "seashallow"
