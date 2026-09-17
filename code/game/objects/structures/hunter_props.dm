// Ported from CMSS13 code/game/objects/structures/hunter_props.dm
// Alien hunter (Yautja) ship and ancient temple decoration.

/obj/structure/prop
	abstract_type = /obj/structure/prop

/obj/structure/prop/hunter
	icon = 'icons/obj/structures/hunter/32x32_hunter_props.dmi'
	icon_state = null

/obj/effect/hunter
	icon = 'icons/effects/hunter/32x32-hunter_effects.dmi'
	layer = MID_TURF_LAYER
	plane = FLOOR_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE

// Bridge borders
/obj/effect/hunter/bridge_border
	name = "border"
	icon_state = "bridge_border"

/obj/effect/hunter/bridge_border/corner
	icon_state = "bridge_border_corner"

/obj/effect/hunter/bridge_border/edge
	icon_state = "bridge_border_edge"

/obj/effect/hunter/bridge_border/small_stair_left
	icon_state = "small_stair_left"

/obj/effect/hunter/bridge_border/small_stair_right
	icon_state = "small_stair_right"

/obj/effect/hunter/bridge_border/brown
	icon_state = "bridge_brown_border"

/obj/effect/hunter/bridge_border/brown/edge
	icon_state = "bridge_border_brown_edge"

/obj/effect/hunter/bridge_border/brown/corner
	icon_state = "bridge_border_brown_corner"

/obj/effect/hunter/bridge_border/brown/small_stair_left
	icon_state = "small_stair_brown_left"

/obj/effect/hunter/bridge_border/brown/small_stair_right
	icon_state = "small_stair_brown_right"

/obj/effect/hunter/bridge_border/brown/small_stair
	icon_state = "small_stair"

/obj/effect/hunter/bridge_border/brown/large_stair
	icon_state = "large_stair"

// Ancient temple rubble
/obj/effect/hunter/ancient_temple
	icon_state = "rubble0"

/obj/effect/hunter/ancient_temple/rubble
	icon_state = "rubble0"

/obj/effect/hunter/ancient_temple/rubble/rubble_1
	icon_state = "rubble1"

/obj/effect/hunter/ancient_temple/rubble/rubble_2
	icon_state = "rubble2"

/obj/effect/hunter/ancient_temple/rubble/rubble_3
	icon_state = "rubble3"

/obj/effect/hunter/ancient_temple/rubble/rubble_4
	icon_state = "rubble4"

/obj/effect/hunter/ancient_temple/rubble/rubble_5
	icon_state = "rubble5"

/obj/effect/hunter/ancient_temple/rubble/rubble_6
	icon_state = "rubble6"

/obj/effect/hunter/ancient_temple/rubble/rubble_7
	icon_state = "rubble7"

// Floor decoration borders
/obj/effect/hunter/ancient_temple/deco_border
	icon_state = "deco_border1"
	layer = TURF_LAYER

/obj/effect/hunter/ancient_temple/deco_border/deco_border2
	icon_state = "deco_border2"

/obj/effect/hunter/ancient_temple/deco_border/deco_border3
	icon_state = "deco_border3"

/obj/effect/hunter/ancient_temple/deco_border/deco_border4
	icon_state = "deco_border4"

/obj/effect/hunter/ancient_temple/deco_border/deco_border5
	icon_state = "deco_border5"

/obj/effect/hunter/ancient_temple/deco_border/deco_border6
	icon_state = "deco_border6"

/obj/effect/hunter/ancient_temple/deco_border/deco_border7
	icon_state = "deco_border7"

/obj/effect/hunter/ancient_temple/deco_border/bronze
	icon_state = "bronze_deco_border1"

/obj/effect/hunter/ancient_temple/deco_border/bronze/deco_border2
	icon_state = "bronze_deco_border2"

/obj/effect/hunter/ancient_temple/deco_border/bronze/deco_border3
	icon_state = "bronze_deco_border3"

/obj/effect/hunter/ancient_temple/deco_border/bronze/deco_border4
	icon_state = "bronze_deco_border4"

/obj/effect/hunter/ancient_temple/deco_border/bronze/deco_border5
	icon_state = "bronze_deco_border5"

/obj/effect/hunter/ancient_temple/deco_border/bronze/deco_border6
	icon_state = "bronze_deco_border6"

/obj/effect/hunter/ancient_temple/deco_border/bronze/deco_border7
	icon_state = "bronze_deco_border7"

// Floor tile edges
/obj/effect/hunter/ancient_temple/tile_edge
	icon_state = "floor_edges_1"
	name = "tile edge"
	layer = TURF_LAYER

/obj/effect/hunter/ancient_temple/tile_edge/tile_edge_2
	icon_state = "floor_edges_2"

/obj/effect/hunter/ancient_temple/tile_edge/tile_edge_3
	icon_state = "floor_edges_3"

/obj/effect/hunter/ancient_temple/tile_edge/tile_edge_4
	icon_state = "floor_edges_4"

/obj/effect/hunter/ancient_temple/tile_edge/tile_edge_5
	icon_state = "floor_edges_5"

/obj/effect/hunter/ancient_temple/tile_edge/tile_edge_6
	icon_state = "floor_edges_6"

/obj/effect/hunter/ancient_temple/tile_edge/tile_edge_7
	icon_state = "floor_edges_7"

/obj/effect/hunter/ancient_temple/tile_edge/tile_edge_8
	icon_state = "floor_edges_8"

/obj/effect/hunter/ancient_temple/tile_edge/tile_edge_9
	icon_state = "floor_edges_9"

/obj/effect/hunter/ancient_temple/tile_edge/tile_edge_10
	icon_state = "floor_edges_10"

/obj/effect/hunter/ancient_temple/tile_edge/tile_edge_11
	icon_state = "floor_edges_11"

/obj/effect/hunter/ancient_temple/tile_edge/tile_edge_12
	icon_state = "floor_edges_12"

/obj/effect/hunter/ancient_temple/tile_edge_corner
	icon_state = "floor_corner_1"
	layer = TURF_LAYER

/obj/effect/hunter/ancient_temple/tile_edge_corner/tile_edge_corner_2
	icon_state = "floor_corner_2"

/obj/effect/hunter/ancient_temple/tile_edge_corner/tile_edge_corner_3
	icon_state = "floor_corner_3"

/obj/effect/hunter/ancient_temple/tile_edge_corner/tile_edge_corner_4
	icon_state = "floor_corner_4"

// Catwalk decorations
/obj/structure/prop/hunter/catwalk
	icon = 'icons/turf/hunter/hunter_floors.dmi'
	icon_state = "hunter_catwalk_alpha"
	name = "catwalk"
	layer = LOW_OBJ_LAYER
	desc = null

/obj/structure/prop/hunter/catwalk/hunter_catwalk_alt
	icon_state = "hunter_catwalk_alt_alpha"

/obj/structure/prop/hunter/catwalk/new_alpha
	icon_state = "hunter_catwalk_new_alpha"

/obj/structure/prop/hunter/catwalk/hunter_grille
	icon_state = "hunter_grille_alpha"

/obj/structure/prop/hunter/catwalk/hunter_grate
	icon_state = "hunter_grate_alpha"

/obj/structure/prop/hunter/catwalk/corner
	icon_state = "corner_1"

/obj/structure/prop/hunter/catwalk/corner/one
	icon_state = "corner_2"

/obj/structure/prop/hunter/catwalk/corner/two
	icon_state = "corner_3"

/obj/structure/prop/hunter/catwalk/corner/three
	icon_state = "corner_4"

/obj/structure/prop/hunter/catwalk/corner/four
	icon_state = "corner_5"

/obj/structure/prop/hunter/catwalk/corner/five
	icon_state = "corner_6"

/obj/structure/prop/hunter/catwalk/corner/six
	icon_state = "corner_7"

/obj/structure/prop/hunter/catwalk/corner/seven
	icon_state = "corner_8"

/obj/structure/prop/hunter/catwalk/corner/eight
	icon_state = "corner_9"

// Stairs decoration
/obj/structure/prop/hunter/stairs/border
	name = "stair border"
	icon_state = "border_stairs"
	density = FALSE
	anchored = TRUE

/obj/structure/prop/hunter/stairs/border/rune
	icon_state = "border_stairs_rune"
	light_on = TRUE
	light_color = "#ff0000"
	light_power = 1
	light_range = 1

/obj/structure/prop/hunter/stairs/border/stair_cut
	icon_state = "border_stair_cut"

/obj/structure/prop/hunter/stairs/border/stair_cut/rune
	icon_state = "border_stair_rune_cut"
	light_on = TRUE
	light_color = "#ff0000"
	light_power = 1
	light_range = 1

// Misc props
/obj/structure/prop/hunter/misc/prop_armor
	name = "ancient yautja armor"
	icon_state = "hunter_armor_prop"
	desc = "Древние доспехи. Они выглядят невероятно старыми, но, скорее всего, всё ещё пригодны к использованию — хотя и закреплены на стене и служат исключительно церемониальным украшением."
	anchored = TRUE

/obj/structure/prop/hunter/misc/prop_armor/elder
	icon_state = "hunter_armor_prop_2"

/obj/structure/prop/hunter/misc/prop_armor/elder_alt
	icon_state = "hunter_armor_prop_3"

/obj/structure/prop/hunter/misc/prop_armor/ancient
	icon_state = "hunter_armor_prop_4"

// Glowing runes
/obj/effect/hunter/rune
	name = "rune"
	icon_state = "hunter_rune"
	light_on = TRUE
	light_color = "#ff0000"
	light_power = 1
	light_range = 1

/obj/effect/hunter/rune/corner
	icon_state = "hunter_rune_corner"

/obj/effect/hunter/rune/corner_2
	icon_state = "hunter_rune_corner_2"

/obj/effect/hunter/rune/small_arrow
	icon_state = "small_arrow"

/obj/effect/hunter/rune/stripes_arrow
	icon_state = "stripes_arrow"

// Trophy display rack
/obj/structure/prop/hunter/trophy_display
	name = "improper Yautja Trophy Display Rack"
	desc = "Стенд для демонстрации охотничьих трофеев."
	icon_state = "pred_trophy_vendor_top_left"
	layer = TABLE_LAYER
	density = TRUE
	anchored = TRUE

/obj/structure/prop/hunter/trophy_display/bottom_left
	icon_state = "pred_trophy_vendor_bottom_left"

/obj/structure/prop/hunter/trophy_display/center
	icon_state = "pred_trophy_vendor_center"

/obj/structure/prop/hunter/trophy_display/top_center
	icon_state = "pred_trophy_vendor_top_center"

/obj/structure/prop/hunter/trophy_display/top_right
	icon_state = "pred_trophy_vendor_top_right"

/obj/structure/prop/hunter/trophy_display/bottom_right
	icon_state = "pred_trophy_vendor_bottom_right"

// Ancient temple statues
/obj/structure/prop/hunter/ancient_temple
	icon = 'icons/obj/structures/hunter/ancientstatue.dmi'
	icon_state = "ancient_statue"

/obj/structure/prop/hunter/ancient_temple/giant_statue
	name = "colossal warrior statue"
	desc = "Возвышающееся каменное изваяние неизвестного воина, сжимающего оружие, похожее на копье. Оно выполнено из гладкого темного камня, на котором, казалось бы, не оставило следов течение времени."
	anchored = TRUE
	layer = LARGE_MOB_LAYER
	density = TRUE
	bound_height = 64
	bound_width = 64

/obj/structure/prop/hunter/ancient_temple/giant_statue/base
	name = "colossal statue base"
	desc = "Богато украшенное основание статуи, покрытое искусной резьбой в виде декоративных рун и символов."
	icon = 'icons/obj/structures/hunter/ancientsatuebase.dmi'
	icon_state = "statue_base_big"
	anchored = TRUE
	layer = BELOW_MOB_LAYER
	density = TRUE
	bound_height = 64
	bound_width = 64

/obj/structure/prop/hunter/ancient_temple/giant_statue/base/colorable
	icon_state = "statue_base_big_colorable"

/obj/structure/prop/hunter/ancient_temple/giant_statue/base/small
	icon_state = "statue_base_small"

/obj/structure/prop/hunter/ancient_temple/giant_statue/base/small/colorable
	icon_state = "statue_base_small_colorable"

/obj/structure/prop/hunter/ancient_temple/small_statue
	name = "stone statue"
	desc = "Высокое каменное изваяние неизвестного воина."
	icon = 'icons/obj/structures/hunter/ancientsmallstatue.dmi'
	icon_state = "statue_ancient"
	anchored = TRUE
	layer = LARGE_MOB_LAYER
	density = TRUE

/obj/structure/prop/hunter/ancient_temple/small_statue/grey
	icon_state = "statue_grey"

/obj/structure/prop/hunter/ancient_temple/small_statue/sandstone
	icon_state = "statue_sandstone"

/obj/structure/prop/hunter/ancient_temple/small_statue/base
	name = "stone statue base"
	desc = "Каменное основание статуи, украшенное неизвестными символами и рунами."
	icon_state = "small_statue_base"

/obj/structure/prop/hunter/ancient_temple/small_statue/base/colorable
	icon_state = "small_statue_base_colorable"

/obj/structure/prop/hunter/ancient_temple/fountain_head
	name = "carved stone head"
	desc = "Огромная высеченная из камня голова неизвестного существа."
	icon = 'icons/obj/structures/hunter/32x32_hunter_props.dmi'
	icon_state = "fountain_head_static"
	anchored = TRUE
	density = FALSE

/obj/structure/prop/hunter/ancient_temple/fountain_head/flowing
	desc = "Огромная высеченная из камня голова неведомого существа; из её пасти льется вода."
	icon_state = "fountain_head_flowing"

// Large temple bars

/obj/structure/prop/hunter/ancient_temple/large_bars
	name = "large bars"
	icon = 'icons/obj/structures/hunter/ancientsatuebase.dmi'
	icon_state = "temple_large_bars"
	anchored = TRUE
	layer = LARGE_MOB_LAYER
	density = TRUE
	bound_width = 64
	bound_height = 64
