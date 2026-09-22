// CMSS13-style directional wall smoothing.

#define CORNER_NONE 0
#define CORNER_COUNTERCLOCKWISE 1
#define CORNER_DIAGONAL 2
#define CORNER_CLOCKWISE 4

/turf/simulated/wall/cm
	name = "wall"
	abstract_type = /turf/simulated/wall/cm
	desc = "A wall."
	icon_state = "blank"
	smooth = NONE
	canSmoothWith = null
	smoothing_groups = null
	/// Sprite prefix: "[walltype]" + "[walltype]0".."[walltype]7"
	var/walltype = null
	/// Corner states of the four tile corners (NW, SE, NE, SW)
	var/list/wall_connections = list("0", "0", "0", "0")
	/// Bitfield of cardinal directions with a blendable neighbour
	var/neighbors_bitfield = NONE
	/// When TRUE the corner overlays are skipped (decorated walls and the like)
	var/special_icon = FALSE
	/// Wall types we merge with
	var/list/blend_turfs = list(/turf/simulated/wall)
	/// Wall types we refuse to merge with
	var/list/noblend_turfs = list()
	/// Objects we merge with
	var/list/blend_objects = list(/obj/machinery/door, /obj/structure/window/full)
	/// Objects we refuse to merge with
	var/list/noblend_objects = list(/obj/structure/window)

/turf/simulated/wall/cm/Initialize(mapload)
	. = ..()
	if(mapload)
		return INITIALIZE_HINT_LATELOAD

	cm_update_connections(FALSE)
	update_icon()

/turf/simulated/wall/cm/LateInitialize()
	. = ..()
	cm_update_connections(FALSE)
	update_icon()

/turf/simulated/wall/cm/AfterChange(flags, oldType)
	. = ..()
	cm_update_connections(FALSE)
	update_icon()

	for(var/direction in GLOB.cardinal)
		var/turf/simulated/wall/cm/neighbour = locate() in get_step(src, direction)
		neighbour?.cm_update_connections(FALSE)
		neighbour?.update_icon()

/turf/simulated/wall/cm/Destroy()
	var/turf/our_turf = get_turf(src)
	. = ..()
	if(!our_turf)
		return

	for(var/direction in GLOB.cardinal)
		var/turf/simulated/wall/cm/neighbour = locate() in get_step(our_turf, direction)
		neighbour?.cm_update_connections(FALSE)
		neighbour?.update_icon()

/turf/simulated/wall/cm/proc/cm_update_connections(propagate = FALSE)
	var/list/wall_dirs = list()
	for(var/direction in GLOB.alldirs)
		var/turf/current = get_step(src, direction)
		if(istype(current, /turf/simulated/wall/cm))
			var/turf/simulated/wall/cm/current_wall = current
			if(cm_can_join_with(current_wall))
				wall_dirs += direction
				if(propagate)
					current_wall.cm_update_connections()
					current_wall.update_icon()
			continue
		if(!(direction in GLOB.cardinal))
			continue
		for(var/obj/thing in current)
			if(cm_can_join_with_object(thing))
				wall_dirs += direction
				break

	for(var/neighbor in wall_dirs)
		neighbors_bitfield |= neighbor

	wall_connections = cm_dirs_to_corner_states(wall_dirs)

/turf/simulated/wall/cm/proc/cm_can_join_with(turf/simulated/wall/cm/target)
	if(target.type == type)
		return TRUE
	if(is_type_in_list(target, noblend_turfs))
		return FALSE
	if(is_type_in_list(target, blend_turfs))
		return TRUE
	return FALSE

/turf/simulated/wall/cm/proc/cm_can_join_with_object(obj/target)
	if(is_type_in_list(target, noblend_objects))
		return FALSE
	if(is_type_in_list(target, blend_objects))
		return TRUE
	return FALSE

/turf/simulated/wall/cm/update_icon_state()
	if(special_icon)
		return
	icon_state = "blank"

/turf/simulated/wall/cm/update_overlays()
	. = ..()
	if(special_icon)
		return
	for(var/i in 1 to 4)
		. += image(icon = icon, icon_state = "[walltype][wall_connections[i]]", dir = 1 << (i - 1))

/proc/cm_dirs_to_corner_states(list/dirs)
	if(!islist(dirs))
		return
	var/list/ret = list(NORTHWEST, SOUTHEAST, NORTHEAST, SOUTHWEST)
	for(var/i in 1 to length(ret))
		var/dir = ret[i]
		. = CORNER_NONE
		if(dir in dirs)
			. |= CORNER_DIAGONAL
		if(turn(dir, 45) in dirs)
			. |= CORNER_COUNTERCLOCKWISE
		if(turn(dir, -45) in dirs)
			. |= CORNER_CLOCKWISE
		ret[i] = "[.]"
	return ret

// ==================== INDESTRUCTIBLE (TURF_HULL) ====================

/turf/simulated/wall/cm/invulnerable
	abstract_type = /turf/simulated/wall/cm/invulnerable
	resistance_flags = INDESTRUCTIBLE

/turf/simulated/wall/cm/invulnerable/take_damage(damage_amount, damage_type = BRUTE, damage_flag = "", sound_effect = TRUE, attack_dir, armour_penetration = 0)
	return

/turf/simulated/wall/cm/invulnerable/dismantle_wall(devastated = FALSE, explode = FALSE)
	return

/turf/simulated/wall/cm/invulnerable/ex_act(severity, target)
	return

/turf/simulated/wall/cm/invulnerable/blob_act(obj/structure/blob/B)
	return

/turf/simulated/wall/cm/invulnerable/attackby(obj/item/I, mob/user, params)
	return ATTACK_CHAIN_BLOCKED_ALL

/turf/simulated/wall/cm/invulnerable/attack_animal(mob/living/M)
	return

/turf/simulated/wall/cm/invulnerable/mech_melee_attack(obj/mecha/mech, obj/item/mecha_parts/mecha_equipment/selected_module = null)
	return

/turf/simulated/wall/cm/invulnerable/attack_hand(mob/user, list/modifiers)
	return

/turf/simulated/wall/cm/invulnerable/welder_act(mob/user, obj/item/I)
	return

/turf/simulated/wall/cm/invulnerable/thermitemelt(mob/user, time)
	return

/turf/simulated/wall/cm/invulnerable/singularity_act()
	return

/turf/simulated/wall/cm/invulnerable/singularity_pull(atom/singularity, current_size)
	return

/turf/simulated/wall/cm/invulnerable/narsie_act()
	return

/turf/simulated/wall/cm/invulnerable/ratvar_act()
	return

/turf/simulated/wall/cm/invulnerable/burn_down()
	return

/turf/simulated/wall/cm/invulnerable/acid_act(acidpwr, acid_volume)
	return

/turf/simulated/wall/cm/invulnerable/rcd_deconstruct_act(mob/user, obj/item/rcd/our_rcd)
	balloon_alert(user, "нельзя деконструировать!")
	return RCD_NO_ACT

// ==================== STRATA (TURF_HULL в CMSS13) ====================
/turf/simulated/wall/cm/invulnerable/strata_ice
	name = "ice columns"
	desc = "An absolutely massive collection of columns made of ice. The longer you stare, the deeper the ice seems to go."
	icon = 'icons/turf/walls/cm/strata_ice.dmi'
	icon_state = "strata_ice"
	walltype = "strata_ice"

/turf/simulated/wall/cm/invulnerable/strata_ice/dirty
	name = "dirty ice columns"
	icon_state = "strata_ice_dirty"
	walltype = "strata_ice_dirty"

/turf/simulated/wall/cm/invulnerable/jungle
	name = "jungle vegetation"
	desc = "Exceptionally dense vegetation that you can't see through."
	icon = 'icons/turf/walls/cm/jungle_veg.dmi'
	icon_state = "jungle_veg"
	walltype = "jungle_veg"

/turf/simulated/wall/cm/invulnerable/forest
	name = "forest vegetation"
	desc = "Exceptionally dense vegetation that you can't see through."
	icon = 'icons/turf/walls/cm/forest_veg.dmi'
	icon_state = "forest_veg"
	walltype = "forest_veg"

/turf/simulated/wall/cm/invulnerable/forest/rock
	name = "rock columns"
	desc = "Exceptionally dense rock formations."
	icon_state = "rock_forest"
	walltype = "rock_forest"

/turf/simulated/wall/cm/invulnerable/forest/rock/dirty
	icon_state = "rock_forest_dirty"
	walltype = "rock_forest_dirty"

// ==================== SANDSTONE TEMPLE (разрушаемая, как в CMSS13) ====================

/turf/simulated/wall/cm/sandstone
	abstract_type = /turf/simulated/wall/cm/sandstone
	name = "sandstone wall"
	desc = "A wall with sandstone plating."
	sheet_type = /obj/item/stack/sheet/mineral/sandstone
	damage_cap = 300 // CMSS13: HEALTH_WALL_REINFORCED

/turf/simulated/wall/cm/sandstone/runed
	name = "sandstone temple wall"
	desc = "A heavy wall of sandstone."
	icon = 'icons/turf/walls/cm/hunter_temple.dmi'
	icon_state = "ancient_stone"
	walltype = "ancient_stone"
	baseturf = /turf/simulated/floor/ancient_temple
	blend_objects = list(/obj/machinery/door, /obj/structure/window/full)
	/// 0..3 — тип декора на прямых участках стены (см. LateInitialize)
	var/decoration_type

/turf/simulated/wall/cm/sandstone/runed/LateInitialize()
	. = ..()
	if(prob(20))
		decoration_type = rand(0, 3)
	update_icon()

/turf/simulated/wall/cm/sandstone/runed/update_icon_state()
	if(decoration_type != null && neighbors_bitfield == (EAST | WEST))
		special_icon = TRUE
		icon_state = "ancient_stone_deco_wall[decoration_type]"
		return
	special_icon = FALSE
	return ..()

/turf/simulated/wall/cm/sandstone/runed/decor
	name = "decorated sandstone temple wall"
	desc = "A heavy wall of sandstone, with elegant carvings and runes inscribed upon its face."
	icon = 'icons/turf/hunter/hunter_temple_deco.dmi'

/turf/simulated/wall/cm/sandstone/runed/decor_2
	icon = 'icons/turf/hunter/hunter_temple_deco_2.dmi'

/turf/simulated/wall/cm/sandstone/runed/decor_3
	icon = 'icons/turf/hunter/hunter_temple_deco_3.dmi'

#undef CORNER_NONE
#undef CORNER_COUNTERCLOCKWISE
#undef CORNER_DIAGONAL
#undef CORNER_CLOCKWISE
