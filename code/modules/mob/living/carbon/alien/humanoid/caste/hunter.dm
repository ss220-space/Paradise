/mob/living/carbon/alien/humanoid/hunter
	name = "alien hunter"
	caste = "h"
	maxHealth = 280
	health = 280
	devour_time = 2 SECONDS
	icon = 'icons/mob/xeno/hunter.dmi'
	icon_state = "hunter"
	caste_icon_prefix = "hunter"
	caste_movement_delay = -0.8
	gib_icon_state = "hunter_gib"
	gib_remains_icon_state = "hunter_corpse"
	rotate_on_lying = FALSE
	role_text = "Вы — Охотник. Ваша основная задача — добыча носителей для заражения их грудоломами."
	pixel_x = -8

/mob/living/carbon/alien/humanoid/hunter/Initialize(mapload)
	. = ..()

	if(name == "alien hunter")
		name = text("alien hunter ([rand(1, 1000)])")
	real_name = name

/mob/living/carbon/alien/humanoid/hunter/get_caste_organs()
	. = ..()
	. += /obj/item/organ/internal/xenos/plasmavessel/hunter
