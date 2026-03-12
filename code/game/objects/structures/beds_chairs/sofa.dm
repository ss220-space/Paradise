/obj/structure/chair/sofa
	name = "sofa"
	icon_state = "leather_sofa_middle"
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
	icon_state = "leather_sofa_left"

/obj/structure/chair/sofa/right
	icon_state = "leather_sofa_right"

/obj/structure/chair/sofa/corner
	icon_state = "leather_sofa_corner"

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

/obj/structure/chair/sofa/bench
	name = "bench"
	desc = "Perfectly designed to be comfortable to sit on, and hellish to sleep on."
	icon_state = "bench_middle"
	greyscale_config = /datum/greyscale_config/bench_middle
	greyscale_colors = "#af7d28"
	comfort = 0.1

/obj/structure/chair/sofa/bench/left
	icon_state = "bench_left"
	greyscale_config = /datum/greyscale_config/bench_left

/obj/structure/chair/sofa/bench/right
	icon_state = "bench_right"
	greyscale_config = /datum/greyscale_config/bench_right

/obj/structure/chair/sofa/bench/corner
	icon_state = "bench_corner"
	greyscale_config = /datum/greyscale_config/bench_corner

/obj/structure/chair/sofa/bench/solo
	icon_state = "bench_solo"
	greyscale_config = /datum/greyscale_config/bench_solo

// Red one (for Security)
/obj/structure/chair/sofa/bench/security_red
	greyscale_colors = COLOR_SECURITY_RED

/obj/structure/chair/sofa/bench/security_red/left
	icon_state = "bench_left"
	greyscale_config = /datum/greyscale_config/bench_left

/obj/structure/chair/sofa/bench/security_red/right
	icon_state = "bench_right"
	greyscale_config = /datum/greyscale_config/bench_right

/obj/structure/chair/sofa/bench/security_red/corner
	icon_state = "bench_corner"
	greyscale_config = /datum/greyscale_config/bench_corner

/obj/structure/chair/sofa/bench/security_red/solo
	icon_state = "bench_solo"
	greyscale_config = /datum/greyscale_config/bench_solo

// Blue one (for Medbay)
/obj/structure/chair/sofa/bench/medical_blue
	greyscale_colors = COLOR_MEDICAL_BLUE

/obj/structure/chair/sofa/bench/medical_blue/left
	icon_state = "bench_left"
	greyscale_config = /datum/greyscale_config/bench_left

/obj/structure/chair/sofa/bench/medical_blue/right
	icon_state = "bench_right"
	greyscale_config = /datum/greyscale_config/bench_right

/obj/structure/chair/sofa/bench/medical_blue/corner
	icon_state = "bench_corner"
	greyscale_config = /datum/greyscale_config/bench_corner

/obj/structure/chair/sofa/bench/medical_blue/solo
	icon_state = "bench_solo"
	greyscale_config = /datum/greyscale_config/bench_solo

// Pink one (for Science)
/obj/structure/chair/sofa/bench/science_pink
	greyscale_colors = COLOR_SCIENCE_PINK

/obj/structure/chair/sofa/bench/science_pink/left
	icon_state = "bench_left"
	greyscale_config = /datum/greyscale_config/bench_left

/obj/structure/chair/sofa/bench/science_pink/right
	icon_state = "bench_right"
	greyscale_config = /datum/greyscale_config/bench_right

/obj/structure/chair/sofa/bench/science_pink/corner
	icon_state = "bench_corner"
	greyscale_config = /datum/greyscale_config/bench_corner

/obj/structure/chair/sofa/bench/science_pink/solo
	icon_state = "bench_solo"
	greyscale_config = /datum/greyscale_config/bench_solo
