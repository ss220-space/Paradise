/obj/structure/decor/platform/ancient_temple
	name = "stone platform"
	desc = "Каменная платформа, служащая основанием для возвышающегося участка; по-видимому, она украшена резными декоративными символами."
	icon = 'icons/obj/structures/platforms.dmi'
	icon_state = "ancient_platform"

/obj/structure/decor/platform/ancient_temple/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/climbable)

/obj/structure/decor/platform/ancient_temple/north
	dir = NORTH

/obj/structure/decor/platform/ancient_temple/east
	dir = EAST

/obj/structure/decor/platform/ancient_temple/west
	dir = WEST

/obj/structure/decor/platform/ancient_temple/alt
	icon_state = "ancient_platform_alt"

/obj/structure/decor/platform/ancient_temple/alt/north
	dir = NORTH

/obj/structure/decor/platform/ancient_temple/alt/east
	dir = EAST

/obj/structure/decor/platform/ancient_temple/alt/west
	dir = WEST

// Corner
/obj/structure/decor/platform/ancient_temple/corner
	icon_state = "ancient_platform_deco"

/obj/structure/decor/platform/ancient_temple/corner/north
	dir = NORTH

/obj/structure/decor/platform/ancient_temple/corner/east
	dir = EAST

/obj/structure/decor/platform/ancient_temple/corner/west
	dir = WEST

/obj/structure/decor/platform/ancient_temple/corner/alt
	icon_state = "ancient_platform_alt_deco"

/obj/structure/decor/platform/ancient_temple/corner/alt/north
	dir = NORTH

/obj/structure/decor/platform/ancient_temple/corner/alt/east
	dir = EAST

/obj/structure/decor/platform/ancient_temple/corner/alt/west
	dir = WEST

// Stair
/obj/structure/decor/platform/ancient_temple/stair_cut/ancient_temple_left
	icon_state = "ancient_platform_stair_left"

/obj/structure/decor/platform/ancient_temple/stair_cut/ancient_temple_right
	icon_state = "ancient_platform_stair_right"

/obj/structure/decor/platform/ancient_temple/stair_cut/ancient_temple_alt_left
	icon_state = "ancient_platform_stair_alt_left"

/obj/structure/decor/platform/ancient_temple/stair_cut/ancient_temple_alt_right
	icon_state = "ancient_platform_stair_alt_right"
