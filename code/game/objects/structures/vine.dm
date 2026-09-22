// An almost space vine, but without mutations.
/obj/structure/vine
	name = "vines"
	desc = "Достаточно прочная старая лиана."
	icon = 'icons/effects/spacevines.dmi'
	icon_state = "Light1"
	anchored = TRUE
	layer = SPACEVINE_LAYER
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	max_integrity = 50
	cares_about_temperature = TRUE

/obj/structure/vine/Initialize(mapload)
	. = ..()
	icon_state = "Light[pick(1,3)]"
	max_integrity = pick(25, 45)

/obj/structure/vine/medium
	icon_state = "Med1"

/obj/structure/vine/medium/Initialize(mapload)
	. = ..()
	icon_state = "Med[pick(1,3)]"
	max_integrity = pick(55, 85)

/obj/structure/vine/heavy
	icon_state = "Hvy1"
	opacity = TRUE
	density = TRUE

/obj/structure/vine/heavy/Initialize(mapload)
	. = ..()
	icon_state = "Hvy[pick(1,3)]"
	max_integrity = pick(90, 150)

/obj/structure/vine/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	playsound(src.loc, 'sound/effects/vegetation_hit.ogg', 25, TRUE)
