///The base color of light space emits
GLOBAL_VAR_INIT(base_starlight_color, default_starlight_color())
///The color of light space is currently emitting
GLOBAL_VAR_INIT(starlight_color, default_starlight_color())
/proc/default_starlight_color()
	var/turf/space/read_from = /turf/space
	return initial(read_from.light_color)

///The range of the light space is displaying
GLOBAL_VAR_INIT(starlight_range, default_starlight_range())
/proc/default_starlight_range()
	var/turf/space/read_from = /turf/space
	return initial(read_from.light_range)

///The power of the light space is throwin out
GLOBAL_VAR_INIT(starlight_power, default_starlight_power())
/proc/default_starlight_power()
	var/turf/space/read_from = /turf/space
	return initial(read_from.light_power)

/proc/set_base_starlight(star_color = null, range = null, power = null)
	GLOB.base_starlight_color = star_color
	set_starlight(star_color, range, power)

/proc/set_starlight(star_color = null, range = null, power = null)
	if(isnull(star_color))
		star_color = GLOB.starlight_color
	var/old_star_color = GLOB.starlight_color
	GLOB.starlight_color = star_color
	// set light color on all lit turfs
	for(var/turf/space/spess as anything in GLOB.starlight)
		spess.set_light(l_range = range, l_power = power, l_color = star_color)

	if(star_color == old_star_color)
		return

	// Update the base overlays
	for(var/obj/light as anything in GLOB.starlight_objects)
		light.color = star_color
	// Send some signals that'll update everything that uses the color
	SEND_GLOBAL_SIGNAL(COMSIG_STARLIGHT_COLOR_CHANGED, old_star_color, star_color)

GLOBAL_LIST_EMPTY(starlight)

/turf/space
	icon = 'icons/turf/space.dmi'
	icon_state = MAP_SWITCH("space", "space_map")
	name = "space"

	temperature = TCMB
	thermal_conductivity = OPEN_HEAT_TRANSFER_COEFFICIENT
	heat_capacity = HEAT_CAPACITY_VACUUM
	atmos_mode = ATMOS_MODE_SPACE

	flags = NO_SCREENTIPS

	plane = PLANE_SPACE
	layer = SPACE_LAYER

	light_range = 2
	light_color = COLOR_STARLIGHT
	light_height = LIGHTING_HEIGHT_SPACE
	light_on = FALSE
	space_lit = TRUE

	intact = FALSE
	underfloor_accessibility = UNDERFLOOR_INTERACTABLE
	// We do NOT want atmos adjacent turfs
	init_air = FALSE

	footstep = null
	barefootstep = null
	clawfootstep = null
	heavyfootstep = null
	force_no_gravity = TRUE

	transparent_floor = TURF_FULLTRANSPARENT

	var/destination_z
	var/destination_x
	var/destination_y

	//when this be added to vis_contents of something it be associated with something on clicking,
	//important for visualisation of turf in openspace and interraction with openspace that show you turf.

/turf/space/basic
	icon_state = MAP_SWITCH("space", "space_basic_map")

// Do not convert to Initialize!
/turf/space/basic/New()
	SHOULD_CALL_PARENT(FALSE)
	//This is used to optimize the map loader
	return

/turf/space/black
	icon_state = MAP_SWITCH("space", "black")

/turf/space/BeforeChange()
	..()
	var/datum/space_level/space_level = GLOB.space_manager.get_zlev(z)
	space_level.remove_from_transit(src)
	//if(light_sources) // Turn off starlight, if present
	//	set_light_on(FALSE)

/turf/space/AfterChange(flags = NONE, oldType)
	..()
	var/datum/space_level/space_level = GLOB.space_manager.get_zlev(z)
	space_level.add_to_transit(src)
	space_level.apply_transition(src)

/// Updates starlight. Called when we're unsure of a turf's starlight state
/// Returns TRUE if we succeed, FALSE otherwise
/turf/space/proc/update_starlight()
	for(var/t in RANGE_TURFS(1, src)) //RANGE_TURFS is in code\__HELPERS\game.dm
		// I've got a lot of cordons near spaceturfs, be good kids
		if(isspaceturf(t) || iscordon(t))
			//let's NOT update this that much pls
			continue
		enable_starlight()
		return TRUE
	GLOB.starlight -= src
	set_light(l_on = FALSE)
	return FALSE

/// Turns on the stars, if they aren't already
/turf/space/proc/enable_starlight()
	if(!light_on)
		set_light(l_on = TRUE, l_range = GLOB.starlight_range, l_power = GLOB.starlight_power, l_color = GLOB.starlight_color)
		GLOB.starlight += src

/turf/space/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(ATTACK_CHAIN_CANCEL_CHECK(.))
		return .

	if(istype(I, /obj/item/stack/rods))
		build_with_rods(I, user)
		return .|ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/stack/tile/plasteel))
		var/obj/item/stack/tile/plasteel/plasteel = I
		var/obj/structure/lattice/lattice = locate() in src
		if(!lattice)
			to_chat(user, span_warning("The plating is going to need some support! Place metal rods first."))
			return .
		if(!plasteel.use(1))
			to_chat(user, span_warning("You need one floor tile to build a floor!"))
			return .
		qdel(lattice)
		playsound(src, 'sound/weapons/genhit.ogg', 50, TRUE)
		to_chat(user, span_notice("You build a floor."))
		ChangeTurf(/turf/simulated/floor/plating)
		return .|ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/stack/rods/fireproof))
		var/obj/item/stack/rods/fireproof/rods = I
		if(locate(/obj/structure/lattice/catwalk/fireproof, src))
			to_chat(user, span_warning("Здесь уже есть мостик!"))
			return .
		var/obj/structure/lattice/fireproof/lattice = locate() in src
		if(!lattice)
			if(!rods.use(1))
				to_chat(user, span_warning("Вам нужен один огнеупорный стержень для постройки решётки!"))
				return .
			to_chat(user, span_notice("Вы установили прочную решётку."))
			playsound(src, 'sound/weapons/genhit.ogg', 50, TRUE)
			new /obj/structure/lattice/fireproof(src)
			return .|ATTACK_CHAIN_SUCCESS
		if(!rods.use(2))
			to_chat(user, span_warning("Вам нужно два огнеупорных стержня для постройки мостика!"))
			return .
		qdel(lattice)
		playsound(src, 'sound/weapons/genhit.ogg', 50, TRUE)
		to_chat(user, span_notice("Вы установили огнеупорный мостик."))
		new /obj/structure/lattice/catwalk/fireproof(src)
		return .|ATTACK_CHAIN_SUCCESS

/turf/space/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(!arrived || !(src in arrived.locs))
		return .

	if(destination_z && destination_x && destination_y)
		destination_z = check_taipan_availability(arrived, destination_z)
		arrived.zMove(null, locate(destination_x, destination_y, destination_z), ZMOVE_ALLOW_BUCKLED)

		var/atom/movable/current_pull = arrived.pulling
		while(current_pull)
			var/turf/target_turf = get_step(current_pull.pulledby.loc, REVERSE_DIR(current_pull.pulledby.dir)) || current_pull.pulledby.loc
			current_pull.zMove(null, target_turf, ZMOVE_ALLOW_BUCKLED)
			if(current_pull.pulling == arrived) // pulling each other doesn't help but makes a loop
				break
			current_pull = current_pull.pulling

/turf/space/proc/check_taipan_availability(atom/movable/arrived, destination_z)
	if(!is_taipan(destination_z))
		return destination_z
	var/arrived_is_mob = isliving(arrived)
	var/mob/living/arrived_mob = arrived
	if(arrived_is_mob && (arrived_mob.mind in GLOB.taipan_players_active))
		to_chat(arrived_mob, span_notice("Вы вернулись в ваш родной скрытый от чужих глаз сектор..."))
		return destination_z
	// if we are not from taipan's crew, then we cannot get there until there is enought players on Taipan
	if(length(GLOB.taipan_players_active) < TAIPAN_PLAYER_LIMIT)
		var/datum/space_level/taipan_zlvl
		var/datum/space_level/direct
		for(var/list_parser in GLOB.space_manager.z_list)
			var/datum/space_level/lvl = GLOB.space_manager.z_list[list_parser]
			if(TAIPAN in lvl.flags)
				taipan_zlvl = lvl
		if(!arrived.dir)
			arrived.dir = SOUTH
		switch(arrived.dir)
			if(NORTH)
				direct = taipan_zlvl.get_connection(Z_LEVEL_NORTH)
			if(SOUTH)
				direct = taipan_zlvl.get_connection(Z_LEVEL_SOUTH)
			if(EAST)
				direct = taipan_zlvl.get_connection(Z_LEVEL_EAST)
			if(WEST)
				direct = taipan_zlvl.get_connection(Z_LEVEL_WEST)
		destination_z = direct?.zpos
		// if we are still going to get to taipan after all the checks... Then get random available z_lvl instead
		if(!destination_z || is_taipan(destination_z))
			destination_z = pick(get_all_linked_levels_zpos())
		return destination_z
	if(arrived_is_mob)
		to_chat(arrived_mob, span_warning("Вы попадаете в загадочный сектор полный астероидов... Тут стоит быть осторожнее..."))
	return destination_z

/turf/space/singularity_act()
	return

/turf/space/can_have_cabling()
	if(locate(/obj/structure/lattice/catwalk, src))
		return TRUE
	return FALSE

/turf/space/proc/set_transition_north(dest_z)
	destination_x = x
	destination_y = TRANSITION_BORDER_SOUTH + 1
	destination_z = dest_z

/turf/space/proc/set_transition_south(dest_z)
	destination_x = x
	destination_y = TRANSITION_BORDER_NORTH - 1
	destination_z = dest_z

/turf/space/proc/set_transition_east(dest_z)
	destination_x = TRANSITION_BORDER_WEST + 1
	destination_y = y
	destination_z = dest_z

/turf/space/proc/set_transition_west(dest_z)
	destination_x = TRANSITION_BORDER_EAST - 1
	destination_y = y
	destination_z = dest_z

/turf/space/proc/remove_transitions()
	destination_z = initial(destination_z)

/turf/space/attack_ghost(mob/dead/observer/user)
	if(destination_z)
		var/turf/T = locate(destination_x, destination_y, destination_z)
		user.forceMove(T)

/turf/space/acid_act(acidpwr, acid_volume)
	return 0

/turf/space/rcd_construct_act(mob/user, obj/item/rcd/our_rcd, rcd_mode)
	. = ..()
	if(rcd_mode != RCD_MODE_TURF)
		return RCD_NO_ACT
	if(our_rcd.useResource(RCD_COST_FLOOR, user))
		to_chat(user, "Печать пола...")
		playsound(get_turf(our_rcd), our_rcd.usesound, 50, TRUE)
		add_attack_logs(user, src, "Constructed floor with RCD")
		ChangeTurf(our_rcd.floor_type)
		return RCD_ACT_SUCCESSFULL
	to_chat(user, span_warning("ОШИБКА! Недостаточно материи для печати пола!"))
	playsound(get_turf(our_rcd), 'sound/machines/click.ogg', 50, TRUE)
	return RCD_ACT_FAILED

/turf/space/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	generate_space_underlay(underlay_appearance, asking_turf)
	return TRUE

// the space turf SHOULD be on first z level. meaning we have invisible floor but only for movable atoms.
/turf/space/zPassIn(direction)
	if(direction != DOWN)
		return FALSE
	for(var/obj/on_us in contents)
		if(on_us.obj_flags & BLOCK_Z_IN_DOWN)
			return FALSE
	return TRUE

//direction is direction of travel of an atom
/turf/space/zPassOut(direction)
	if(direction != UP)
		return FALSE
	for(var/obj/on_us in contents)
		if(on_us.obj_flags & BLOCK_Z_OUT_UP)
			return FALSE
	return TRUE

/turf/space/zAirIn()
	return TRUE

/turf/space/zAirOut()
	return TRUE
