#define HUNTER_SPRITE_OFFSET "hunter_sprite_offset"

/mob/living/carbon/alien/humanoid/hunter
	name = "alien hunter"
	caste = "h"
	maxHealth = 205
	health = 205
	devour_time = 2 SECONDS
	icon = 'icons/mob/xeno/hunter.dmi'
	icon_state = "hunter_walk"
	caste_icon_prefix = "hunter"
	caste_movement_delay = -0.6
	gib_icon_state = "hunter_gib"
	gib_remains_icon_state = "hunter_corpse"
	rotate_on_lying = FALSE
	role_text = "Вы — Охотник. Ваша основная задача — добыча носителей для заражения их грудоломами."

/mob/living/carbon/alien/humanoid/hunter/Initialize(mapload)
	. = ..()

	if(name == "alien hunter")
		name = text("alien hunter ([rand(1, 1000)])")
	real_name = name
	update_hunter_offsets()

/mob/living/carbon/alien/humanoid/hunter/get_caste_organs()
	. = ..()
	. += /obj/item/organ/internal/xenos/plasmavessel/hunter

/mob/living/carbon/alien/humanoid/hunter/setDir(newdir)
	. = ..()
	update_hunter_offsets()

/mob/living/carbon/alien/humanoid/hunter/on_lying_down(new_lying_angle)
	. = ..()
	update_hunter_offsets()

/mob/living/carbon/alien/humanoid/hunter/on_standing_up()
	. = ..()
	update_hunter_offsets()

/**
 * Recomputes the sprite pixel offset for the 48x48 icon.
 *
 * The sprite sits at -8 by default (NORTH/SOUTH facing and lying down) and shifts to +8 when the hunter faces WEST.
 */
/mob/living/carbon/alien/humanoid/hunter/proc/update_hunter_offsets()
	var/x_offset = -8
	if(body_position != LYING_DOWN && dir == WEST)
		x_offset = 0
	add_offsets(HUNTER_SPRITE_OFFSET, x_add = x_offset, animate = FALSE)

#undef HUNTER_SPRITE_OFFSET

