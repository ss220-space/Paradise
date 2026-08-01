/obj/effect/turf_decal/tile
	name = "tile decal"
	icon_state = "tile_corner"
	layer = TURF_PLATING_DECAL_LAYER
	alpha = 110

/// Automatically generates all subtypes for a decal with the given path.
#define TILE_DECAL_SUBTYPE_HELPER(path)\
##path/opposingcorners {\
	icon_state = "tile_opposing_corners";\
}\
##path/half {\
	icon_state = "tile_half";\
}\
##path/half/contrasted {\
	icon_state = "tile_half_contrasted";\
}\
##path/anticorner {\
	icon_state = "tile_anticorner";\
}\
##path/anticorner/contrasted {\
	icon_state = "tile_anticorner_contrasted";\
}\
##path/fourcorners {\
	icon_state = "tile_fourcorners";\
}\
##path/full {\
	icon_state = "tile_full";\
}\
##path/diagonal_centre {\
	icon_state = "diagonal_centre";\
}\
##path/diagonal_edge {\
	icon_state = "diagonal_edge";\
}\
##path/tram {\
	icon_state = "tile_tram";\
}

/// Blue tiles
/obj/effect/turf_decal/tile/blue
	name = "blue tile decal"
	color = "#52B4E9"

TILE_DECAL_SUBTYPE_HELPER(/obj/effect/turf_decal/tile/blue)

/// Dark blue tiles
/obj/effect/turf_decal/tile/dark_blue
	name = "dark blue tile decal"
	color = "#486091"

TILE_DECAL_SUBTYPE_HELPER(/obj/effect/turf_decal/tile/dark_blue)

/// Green tiles
/obj/effect/turf_decal/tile/green
	name = "green tile decal"
	color = "#9FED58"

TILE_DECAL_SUBTYPE_HELPER(/obj/effect/turf_decal/tile/green)

/// Dark green tiles

/obj/effect/turf_decal/tile/dark_green
	name = "dark green tile decal"
	color = "#439C1E"

TILE_DECAL_SUBTYPE_HELPER(/obj/effect/turf_decal/tile/dark_green)

/// Yellow tiles

/obj/effect/turf_decal/tile/yellow
	name = "yellow tile decal"
	color = "#EFB341"

TILE_DECAL_SUBTYPE_HELPER(/obj/effect/turf_decal/tile/yellow)

/// Red tiles

/obj/effect/turf_decal/tile/red
	name = "red tile decal"
	color = "#DE3A3A"

TILE_DECAL_SUBTYPE_HELPER(/obj/effect/turf_decal/tile/red)

/// Dark red tiles

/obj/effect/turf_decal/tile/dark_red
	name = "dark red tile decal"
	color = "#B11111"

TILE_DECAL_SUBTYPE_HELPER(/obj/effect/turf_decal/tile/dark_red)

/// Bar tiles

/obj/effect/turf_decal/tile/bar
	name = "bar tile decal"
	color = "#791500"
	alpha = 130

TILE_DECAL_SUBTYPE_HELPER(/obj/effect/turf_decal/tile/bar)

/// Purple tiles

/obj/effect/turf_decal/tile/purple
	name = "purple tile decal"
	color = "#D381C9"

TILE_DECAL_SUBTYPE_HELPER(/obj/effect/turf_decal/tile/purple)

/// Brown tiles

/obj/effect/turf_decal/tile/brown
	name = "brown tile decal"
	color = "#A46106"

TILE_DECAL_SUBTYPE_HELPER(/obj/effect/turf_decal/tile/brown)

/// Neutral tiles

/obj/effect/turf_decal/tile/neutral
	name = "neutral tile decal"
	color = "#D4D4D4"
	alpha = 50

TILE_DECAL_SUBTYPE_HELPER(/obj/effect/turf_decal/tile/neutral)

/// Dark tiles

/obj/effect/turf_decal/tile/dark
	name = "dark tile decal"
	color = "#0e0f0f"

TILE_DECAL_SUBTYPE_HELPER(/obj/effect/turf_decal/tile/dark)


#undef TILE_DECAL_SUBTYPE_HELPER
