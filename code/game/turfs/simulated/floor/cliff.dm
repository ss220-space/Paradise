/turf/simulated/floor/cliff
	name = "cliff"
	desc = "Отвесный обрыв. Всё, что переваливается за край, летит вниз, пока обрыв не кончится."
	icon = 'icons/turf/cliff.dmi'
	icon_state = "cliff"
	density = TRUE
	baseturf = /turf/simulated/floor/cliff
	var/can_fall_from_direction = NORTH
	var/fall_direction = SOUTH
	var/valid_move_dirs = SOUTH|WEST|EAST|SOUTHWEST|SOUTHEAST
	var/fall_speed = 0.2 SECONDS
	var/static/list/protected_types = typecacheof(list(/obj/projectile, /obj/effect, /mob/dead))
	var/turf/underlay_tile
	var/underlay_pixel_x = 0
	var/underlay_pixel_y = 0
	var/underlay_plane

/turf/simulated/floor/cliff/get_ru_names()
	return alist(
		NOMINATIVE = "обрыв",
		GENITIVE = "обрыва",
		DATIVE = "обрыву",
		ACCUSATIVE = "обрыв",
		INSTRUMENTAL = "обрывом",
		PREPOSITIONAL = "обрыве",
	)

/turf/simulated/floor/cliff/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_TURF_MOVABLE_THROW_LANDED, PROC_REF(on_throw_landed))

	if(isnull(underlay_tile))
		return

	var/image/underlay = image(icon = initial(underlay_tile.icon), icon_state = initial(underlay_tile.icon_state))
	underlay.pixel_w = underlay_pixel_x
	underlay.pixel_z = underlay_pixel_y
	SET_PLANE(underlay, underlay_plane || plane, src)
	underlays += underlay

/turf/simulated/floor/cliff/Destroy(force)
	UnregisterSignal(src, COMSIG_TURF_MOVABLE_THROW_LANDED)
	return ..()

/turf/simulated/floor/cliff/CanPass(atom/movable/mover, border_dir)
	..()

	if(border_dir & can_fall_from_direction || !can_fall(mover))
		return TRUE

	return FALSE

/turf/simulated/floor/cliff/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	try_fall(arrived)

/turf/simulated/floor/cliff/zImpact(atom/movable/falling, levels, turf/prev_turf, flags)
	return ..(flags = flags | FALL_INTERCEPTED)

/turf/simulated/floor/cliff/try_replace_tile(obj/item/stack/tile/tile, mob/user, params)
	return

/turf/simulated/floor/cliff/proc/on_throw_landed(datum/source, atom/movable/arrived)
	SIGNAL_HANDLER

	try_fall(arrived)

/turf/simulated/floor/cliff/proc/try_fall(atom/movable/arrived)
	if(!can_fall(arrived))
		return

	SScliff_falling.start_falling(arrived, src)
	on_fall(arrived)

/turf/simulated/floor/cliff/proc/can_fall(atom/movable/arrived)
	if(is_type_in_typecache(arrived, protected_types))
		return FALSE

	if(arrived.throwing || HAS_TRAIT(arrived, TRAIT_CLIFF_WALKER) || HAS_TRAIT(arrived, TRAIT_MOVE_FLYING))
		return FALSE

	if(arrived.anchored || (arrived in SScliff_falling.cliff_grinders))
		return FALSE

	if(!iscliffturf(get_step(src, fall_direction)) && !(get_dir(arrived, src) & fall_direction))
		return FALSE

	if(UNLINT(!arrived.has_gravity(src)))
		return FALSE

	return TRUE

/turf/simulated/floor/cliff/proc/on_fall(atom/movable/faller)
	if(!isliving(faller))
		return

	var/mob/living/tumbler = faller
	tumbler.Knockdown(fall_speed)
	tumbler.spin(fall_speed, fall_speed)

/turf/simulated/floor/cliff/proc/can_move(atom/movable/mover, turf/target)
	if(!(valid_move_dirs & get_dir(src, target)))
		return FALSE

	if(!iscliffturf(target) && get_dir(src, target) != fall_direction)
		return FALSE

	return TRUE

/turf/simulated/floor/cliff/snowrock
	name = "icy cliff"
	icon = 'icons/turf/cliff_icerock.dmi'
	icon_state = "icerock_wall-0"
	base_icon_state = "icerock_wall"
	smooth = SMOOTH_BITMASK | SMOOTH_BORDER
	smoothing_groups = SMOOTH_GROUP_FLOOR_CLIFF
	canSmoothWith = SMOOTH_GROUP_FLOOR_CLIFF
	layer = EDGED_TURF_LAYER
	plane = WALL_PLANE
	transform = MAP_SWITCH(TRANSLATE_MATRIX(-4, -4), matrix())
	underlay_pixel_x = 4
	underlay_pixel_y = 4
	underlay_tile = /turf/simulated/floor/plating/asteroid/snow
	underlay_plane = FLOOR_PLANE
	atmos_environment = ENVIRONMENT_COLD
	baseturf = /turf/simulated/floor/cliff/snowrock

/turf/simulated/floor/cliff/snowrock/get_ru_names()
	return alist(
		NOMINATIVE = "ледяной обрыв",
		GENITIVE = "ледяного обрыва",
		DATIVE = "ледяному обрыву",
		ACCUSATIVE = "ледяной обрыв",
		INSTRUMENTAL = "ледяным обрывом",
		PREPOSITIONAL = "ледяном обрыве",
	)
