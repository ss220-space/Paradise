/obj/structure/light_fake
	name = "light fixture"
	desc = "A lighting fixture."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "tube1"
	anchored = TRUE
	layer = ABOVE_ALL_MOB_LAYER
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | FREEZE_PROOF | ACID_PROOF | UNACIDABLE
	light_range = 8

/obj/structure/light_fake/small
	desc = "A small lighting fixture."
	icon_state = "bulb1"
	light_color = "#a0a080"
	light_range = 4

/obj/structure/light_fake/floor
	name = "floor light"
	desc = "A small lighting fixture."
	icon_state = "floor1"
	light_color = "#a0a080"
	light_range = 4

/obj/structure/light_fake/spot
	name = "spotlight"
	light_range = 12
	light_power = 4

/obj/structure/light_fake/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			playsound(loc, 'sound/effects/glasshit.ogg', 90, TRUE)
		if(BURN)
			playsound(loc, 'sound/items/welder.ogg', 100, TRUE)
