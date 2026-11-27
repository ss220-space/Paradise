/obj/structure/laz_sign
	name = "sign Lazarus"
	desc = "Потрёпанная временем металлическая вывеска, указывающая на посадочную зону шаттла. Опоры проржавели."
	icon = 'icons/obj/structures/laz_sign.dmi'
	icon_state = "laz_sign"
	density = TRUE
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE
	bound_width = 64
	var/lightmask_overlay = "laz_sign_lightmask"

/obj/structure/laz_sign/blood
	desc = "Потрёпанная временем металлическая вывеска, указывающая на посадочную зону шаттла. Залита кровью."
	icon_state = "laz_sign_b"
	lightmask_overlay = "laz_sign_b_lightmask"
