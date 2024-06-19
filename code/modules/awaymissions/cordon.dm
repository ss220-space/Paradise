/// Turf type that appears to be a world border, completely impassable and non-interactable to all physical (alive) entities.
/turf/cordon
	name = "cordon"
	icon = 'icons/turf/walls.dmi'
	icon_state = "cordon"
	invisibility = INVISIBILITY_ABSTRACT
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	explosion_block = INFINITY
	explosion_vertical_block = INFINITY
	opacity = TRUE
	density = TRUE
	blocks_air = TRUE
	init_air = FALSE
	turf_flags = NOJAUNT
	baseturf = /turf/cordon

/turf/cordon/acid_act()
	return FALSE

/turf/cordon/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay)
	return

/turf/cordon/singularity_act()
	return

/turf/cordon/bullet_act()
	return

/turf/cordon/Adjacent(atom/neighbor, atom/target, atom/movable/mover)
	return

/turf/cordon/Bumped(atom/movable/bumped_atom)
	. = ..()

	dump_in_space(bumped_atom)

/// Area used in conjuction with the cordon turf to create a fully functioning world border.
/area/misc/cordon
	name = "CORDON"
	icon_state = "cordon"
	static_lighting = FALSE
	base_lighting_alpha = 255
	area_flags = UNIQUE_AREA
	requires_power = FALSE

/area/misc/cordon/Entered(atom/movable/arrived, area/old_area)
	. = ..()
	for(var/mob/living/enterer as anything in arrived.get_all_contents_type(/mob/living))
		to_chat(enterer, span_userdanger("This was a bad idea..."))
		enterer.dust(TRUE, FALSE, TRUE)
