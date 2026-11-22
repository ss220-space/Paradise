/obj/structure/decor/platform/ancient_temple
	name = "stone platform"
	desc = "Каменная платформа, служащая основанием для возвышающегося участка; по-видимому, она украшена резными декоративными символами."
	icon = 'icons/obj/structures/platforms.dmi'
	icon_state = "ancient_platform"

/obj/structure/decor/platform/ancient_temple/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/climbable)

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/decor/platform/ancient_temple, 0, 0)

/obj/structure/decor/platform/ancient_temple/alt
	icon_state = "ancient_platform_alt"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/decor/platform/ancient_temple/alt, 0, 0)

// Corner
/obj/structure/decor/platform/ancient_temple/corner
	icon_state = "ancient_platform_deco"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/decor/platform/ancient_temple/corner, 0, 0)

/obj/structure/decor/platform/ancient_temple/corner/alt
	icon_state = "ancient_platform_alt_deco"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/decor/platform/ancient_temple/corner/alt, 0, 0)

// Stair
/obj/structure/decor/platform/ancient_temple/stair_cut/ancient_temple_left
	icon_state = "ancient_platform_stair_left"

/obj/structure/decor/platform/ancient_temple/stair_cut/ancient_temple_right
	icon_state = "ancient_platform_stair_right"

/obj/structure/decor/platform/ancient_temple/stair_cut/ancient_temple_alt_left
	icon_state = "ancient_platform_stair_alt_left"

/obj/structure/decor/platform/ancient_temple/stair_cut/ancient_temple_alt_right
	icon_state = "ancient_platform_stair_alt_right"
