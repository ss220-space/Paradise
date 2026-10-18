#define DRONE_SPRITE_OFFSET "drone_sprite_offset"

/mob/living/carbon/alien/humanoid/drone
	name = "alien drone"
	caste = "d"
	maxHealth = 180
	health = 180
	icon = 'icons/mob/xeno/drone.dmi'
	icon_state = "drone_walk"
	caste_icon_prefix = "drone"
	gib_icon_state = "drone_gib"
	gib_remains_icon_state = "drone_corpse"
	time_to_open_doors = 0.2 SECONDS
	ventcrawler_trait = null
	can_evolve = TRUE
	role_text = "Вы — Рабочий. Ваша основная задача — помощь Королеве в обустройстве гнезда. Если в улье её всё ещё нет, вам необходимо как можно быстрее в неё эволюционировать."
	var/sterile = FALSE

/mob/living/carbon/alien/humanoid/drone/Initialize(mapload)
	. = ..()
	if(name == "alien drone")
		name = "alien drone ([rand(1, 1000)])"
	real_name = name

	AddSpell(new /datum/action/cooldown/spell/pointed/break_vent)
	if(!sterile && !istype(src, /mob/living/carbon/alien/humanoid/drone/resin_drone))
		AddSpell(new /datum/action/cooldown/spell/evolve/drone)

	update_drone_offsets()

/mob/living/carbon/alien/humanoid/drone/get_caste_organs()
	. = ..()
	. += list(
		/obj/item/organ/internal/xenos/plasmavessel/drone,
		/obj/item/organ/internal/xenos/acidgland,
		/obj/item/organ/internal/xenos/resinspinner,
	)

/mob/living/carbon/alien/humanoid/drone/setDir(newdir)
	. = ..()
	update_drone_offsets()

/mob/living/carbon/alien/humanoid/drone/on_lying_down(new_lying_angle)
	. = ..()
	update_drone_offsets()

/mob/living/carbon/alien/humanoid/drone/on_standing_up()
	. = ..()
	update_drone_offsets()

/**
 * Recomputes the sprite pixel offset for the 48x48 icon.
 *
 * The sprite sits at -16 by default (NORTH/SOUTH facing and lying down) and shifts to +16 when the hunter faces WEST.
 */
/mob/living/carbon/alien/humanoid/drone/proc/update_drone_offsets()
	var/x_offset = -16
	if(body_position != LYING_DOWN && dir == WEST)
		x_offset = 0
	add_offsets(DRONE_SPRITE_OFFSET, x_add = x_offset, animate = FALSE)

/mob/living/carbon/alien/humanoid/drone/no_queen
	sterile = TRUE

/mob/living/carbon/alien/humanoid/drone/resin_drone
	name = "alien resin drone"
	caste = "d"
	maxHealth = 180
	health = 180
	icon = 'icons/mob/xeno/drone.dmi'
	icon_state = "resin_drone_walk"
	caste_icon_prefix = "resin_drone"
	gib_icon_state = "drone_gib"
	gib_remains_icon_state = "drone_corpse"
	time_to_open_doors = 0.2 SECONDS
	ventcrawler_trait = null
	can_evolve = FALSE
	role_text = "Вы — Улучшенный Рабочий. Вы можете строить усиленные смоляные стены, которые прочнее обычных. Вы больше не можете эволюционировать в Королеву."

/mob/living/carbon/alien/humanoid/drone/resin_drone/Initialize(mapload)
	. = ..()
	if(name == "alien resin drone")
		name = "alien resin drone ([rand(1, 1000)])"
	real_name = name

	AddSpell(new /datum/action/cooldown/spell/pointed/break_vent)

/mob/living/carbon/alien/humanoid/drone/resin_drone/get_caste_organs()
	. = ..()
	. += list(
		/obj/item/organ/internal/xenos/plasmavessel/drone/resin_drone,
	)

#undef DRONE_SPRITE_OFFSET
