/obj/structure/chair/sofa
	name = "sofa"
	icon_state = "sofamiddle"
	icon = 'icons/obj/chairs_wide.dmi'
	anchored = TRUE
	item_chair = null
	comfort = 0.6
	var/mutable_appearance/armrest
	flip_on_buckled_move = FALSE

/obj/structure/chair/sofa/Initialize(mapload)
	armrest = GetArmrest()
	armrest.layer = ABOVE_MOB_LAYER
	return ..()

/obj/structure/chair/sofa/proc/GetArmrest()
	return mutable_appearance('icons/obj/chairs.dmi', "[icon_state]_armrest")

/obj/structure/chair/sofa/Destroy()
	QDEL_NULL(armrest)
	return ..()

/obj/structure/chair/sofa/post_buckle_mob(mob/living/target)
	. = ..()
	update_armrest()

/obj/structure/chair/sofa/post_unbuckle_mob(mob/living/target)
	. = ..()
	update_armrest()

/obj/structure/chair/sofa/proc/update_armrest()
	if(has_buckled_mobs())
		add_overlay(armrest)
	else
		cut_overlay(armrest)

/obj/structure/chair/sofa/left
	icon_state = "sofaend_left"

/obj/structure/chair/sofa/right
	icon_state = "sofaend_right"

/obj/structure/chair/sofa/corner
	icon_state = "sofacorner"

// MARK: CORP SOFA

/obj/structure/chair/sofa/corp
	desc = "Soft and cushy."
	icon_state = "corp_sofamiddle"

/obj/structure/chair/sofa/corp/left
	icon_state = "corp_sofaend_left"

/obj/structure/chair/sofa/corp/right
	icon_state = "corp_sofaend_right"

/obj/structure/chair/sofa/corp/corner
	icon_state = "corp_sofacorner"

// MARK: Bench

// Base bench types by geometry
/obj/structure/chair/sofa/bench
	name = "bench"
	desc = "Спроектирована таким образом, чтобы на ней было удобно сидеть, но невозможно спать."
	gender = FEMALE
	icon = 'icons/map_icons/objects.dmi'
	icon_state = "/obj/structure/chair/sofa/bench"
	greyscale_config = /datum/greyscale_config/bench_middle
	greyscale_colors = "#a3f38d"
	post_init_icon_state = "bench_middle"
	comfort = 0.1

/obj/structure/chair/sofa/bench/get_ru_names()
	return list(
		NOMINATIVE = "скамья",
		GENITIVE = "скамьи",
		DATIVE = "скамье",
		ACCUSATIVE = "скамью",
		INSTRUMENTAL = "скамьёй",
		PREPOSITIONAL = "скамье"
	)

/obj/structure/chair/sofa/bench/left
	icon_state = "/obj/structure/chair/sofa/bench/left"
	greyscale_config = /datum/greyscale_config/bench_left
	post_init_icon_state = "bench_left"

/obj/structure/chair/sofa/bench/right
	icon_state = "/obj/structure/chair/sofa/bench/right"
	greyscale_config = /datum/greyscale_config/bench_right
	post_init_icon_state = "bench_right"

/obj/structure/chair/sofa/bench/corner
	icon_state = "/obj/structure/chair/sofa/bench/corner"
	greyscale_config = /datum/greyscale_config/bench_corner
	post_init_icon_state = "bench_corner"

/obj/structure/chair/sofa/bench/solo
	icon_state = "/obj/structure/chair/sofa/bench/solo"
	greyscale_config = /datum/greyscale_config/bench_solo
	post_init_icon_state = "bench_solo"

// Color variations for each geometry type

// Middle section color variations
/obj/structure/chair/sofa/bench/security_red
	icon_state = "/obj/structure/chair/sofa/bench/security_red"
	greyscale_colors = COLOR_PINK_RED

/obj/structure/chair/sofa/bench/medical_blue
	icon_state = "/obj/structure/chair/sofa/bench/medical_blue"
	greyscale_colors = COLOR_BRIGHT_BLUE

/obj/structure/chair/sofa/bench/science_pink
	icon_state = "/obj/structure/chair/sofa/bench/science_pink"
	greyscale_colors = COLOR_FADED_PINK

// Left section color variations
/obj/structure/chair/sofa/bench/left/security_red
	icon_state = "/obj/structure/chair/sofa/bench/left/security_red"
	greyscale_colors = COLOR_PINK_RED

/obj/structure/chair/sofa/bench/left/medical_blue
	icon_state = "/obj/structure/chair/sofa/bench/left/medical_blue"
	greyscale_colors = COLOR_BRIGHT_BLUE

/obj/structure/chair/sofa/bench/left/science_pink
	icon_state = "/obj/structure/chair/sofa/bench/left/science_pink"
	greyscale_colors = COLOR_FADED_PINK

// Right section color variations
/obj/structure/chair/sofa/bench/right/security_red
	icon_state = "/obj/structure/chair/sofa/bench/right/security_red"
	greyscale_colors = COLOR_PINK_RED

/obj/structure/chair/sofa/bench/right/medical_blue
	icon_state = "/obj/structure/chair/sofa/bench/right/medical_blue"
	greyscale_colors = COLOR_BRIGHT_BLUE

/obj/structure/chair/sofa/bench/right/science_pink
	icon_state = "/obj/structure/chair/sofa/bench/right/science_pink"
	greyscale_colors = COLOR_FADED_PINK

// Corner section color variations
/obj/structure/chair/sofa/bench/corner/security_red
	icon_state = "/obj/structure/chair/sofa/bench/corner/security_red"
	greyscale_colors = COLOR_PINK_RED

/obj/structure/chair/sofa/bench/corner/medical_blue
	icon_state = "/obj/structure/chair/sofa/bench/corner/medical_blue"
	greyscale_colors = COLOR_BRIGHT_BLUE

/obj/structure/chair/sofa/bench/corner/science_pink
	icon_state = "/obj/structure/chair/sofa/bench/corner/science_pink"
	greyscale_colors = COLOR_FADED_PINK

// Solo section color variations
/obj/structure/chair/sofa/bench/solo/security_red
	icon_state = "/obj/structure/chair/sofa/bench/solo/security_red"
	greyscale_colors = COLOR_PINK_RED

/obj/structure/chair/sofa/bench/solo/medical_blue
	icon_state = "/obj/structure/chair/sofa/bench/solo/medical_blue"
	greyscale_colors = COLOR_BRIGHT_BLUE

/obj/structure/chair/sofa/bench/solo/science_pink
	icon_state = "/obj/structure/chair/sofa/bench/solo/science_pink"
	greyscale_colors = COLOR_FADED_PINK
