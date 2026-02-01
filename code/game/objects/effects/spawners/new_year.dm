/obj/effect/spawner/new_year
	layer = FLY_LAYER
	plane = ABOVE_GAME_PLANE
	icon = 'icons/effects/mapping_new_year.dmi'
	icon_state = null
	/// The type of celebration decoration that this spawner contains
	var/celebration_decorations

/obj/effect/spawner/new_year/Initialize(mapload)
	. = ..()
	if(GLOB.new_year_celebration)
		new celebration_decorations(get_turf(src))

	return INITIALIZE_HINT_QDEL

/obj/effect/spawner/new_year/presents_tree
	name = "new year tree spawner"
	icon_state = "new_year_tree"
	celebration_decorations = /obj/structure/flora/tree/new_year/presents

/obj/effect/spawner/new_year/garland/north
	name = "garland spawner north"
	icon_state = "garland_north"
	celebration_decorations = /obj/structure/decorative_structures/garland/north

/obj/effect/spawner/new_year/garland/east
	name = "garland spawner east"
	icon_state = "garland_east"
	celebration_decorations = /obj/structure/decorative_structures/garland/east

/obj/effect/spawner/new_year/garland/west
	name = "garland spawner west"
	icon_state = "garland_west"
	celebration_decorations = /obj/structure/decorative_structures/garland/west

/obj/effect/spawner/new_year/garland/south
	name = "garland spawner south"
	icon_state = "garland_south"
	celebration_decorations = /obj/structure/decorative_structures/garland

/obj/effect/spawner/new_year/gift
	name = "gift spawner"
	icon_state = "gift"
	celebration_decorations = /obj/item/gift

/obj/effect/spawner/new_year/snow_machine
	name = "snow machine spawner"
	icon_state = "snow_machine"
	celebration_decorations = /obj/machinery/snow_machine
