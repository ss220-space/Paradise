/turf/space
	icon = 'icons/turf/space.dmi'
	name = "\proper space"
	icon_state = "0"

	temperature = TCMB
	thermal_conductivity = OPEN_HEAT_TRANSFER_COEFFICIENT
	heat_capacity = HEAT_CAPACITY_VACUUM

	plane = PLANE_SPACE
	layer = SPACE_LAYER
	light_power = 0.25
	always_lit = TRUE
	intact = FALSE
	// We do NOT want atmos adjacent turfs
	init_air = FALSE

	var/destination_z
	var/destination_x
	var/destination_y
	plane = PLANE_SPACE
	footstep = null
	barefootstep = null
	clawfootstep = null
	heavyfootstep = null
	force_no_gravity = TRUE

	transparent_floor = TURF_FULLTRANSPARENT

	//when this be added to vis_contents of something it be associated with something on clicking,
	//important for visualisation of turf in openspace and interraction with openspace that show you turf.
	vis_flags = VIS_INHERIT_ID

/turf/space/Initialize(mapload)
	SHOULD_CALL_PARENT(FALSE)
	if(!istype(src, /turf/space/transit) && !istype(src, /turf/space/openspace))
		icon_state = SPACE_ICON_STATE

	if(length(vis_contents))
		vis_contents.Cut() //removes inherited overlays

	if(flags & INITIALIZED)
		stack_trace("Warning: [src]([type]) initialized multiple times!")
	flags |= INITIALIZED

	// We make the assumption that the space plane will never be blacklisted, as an optimization
	if(SSmapping.max_plane_offset)
		plane = PLANE_SPACE - (PLANE_RANGE * SSmapping.z_level_to_plane_offset[z])

	var/area/our_area = loc
	if(!our_area.area_has_base_lighting && always_lit) //Only provide your own lighting if the area doesn't for you
		// Intentionally not add_overlay for performance reasons.
		// add_overlay does a bunch of generic stuff, like creating a new list for overlays,
		// queueing compile, cloning appearance, etc etc etc that is not necessary here.
		overlays += GLOB.fullbright_overlays[GET_TURF_PLANE_OFFSET(src) + 1]

	if (light_power && light_range)
		update_light()

	if(opacity)
		directional_opacity = ALL_CARDINALS

	return INITIALIZE_HINT_NORMAL

/turf/space/BeforeChange()
	..()
	var/datum/space_level/S = GLOB.space_manager.get_zlev(z)
	S.remove_from_transit(src)
	if(light_sources) // Turn off starlight, if present
		set_light_on(FALSE)

/turf/space/AfterChange(ignore_air, keep_cabling = FALSE, oldType)
	..()
	var/datum/space_level/S = GLOB.space_manager.get_zlev(z)
	S.add_to_transit(src)
	S.apply_transition(src)

/turf/space/proc/update_starlight()
	if(CONFIG_GET(flag/starlight))
		for(var/t in RANGE_TURFS(1,src)) //RANGE_TURFS is in code\__HELPERS\game.dm
			if(isspaceturf(t))
				//let's NOT update this that much pls
				continue
			set_light(2, l_on = TRUE)
			return
		set_light_on(FALSE)


/turf/space/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(ATTACK_CHAIN_CANCEL_CHECK(.))
		return .

	if(istype(I, /obj/item/stack/rods))
		var/obj/item/stack/rods/rods = I
		if(locate(/obj/structure/lattice/catwalk, src))
			to_chat(user, span_warning("There is already a catwalk here!"))
			return .
		if(locate(/obj/structure/lattice, src))
			if(!rods.use(1))
				to_chat(user, span_warning("You need two rods to build a catwalk!"))
				return .
			to_chat(user, span_notice("You construct a catwalk."))
			playsound(src, 'sound/weapons/genhit.ogg', 50, TRUE)
			new /obj/structure/lattice/catwalk(src)
			return .|ATTACK_CHAIN_SUCCESS
		if(!rods.use(1))
			to_chat(user, span_warning("You need one rod to build a lattice."))
			return .
		to_chat(user, span_notice("Constructing support lattice..."))
		playsound(src, 'sound/weapons/genhit.ogg', 50, TRUE)
		ReplaceWithLattice()
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

	if(istype(I, /obj/item/stack/fireproof_rods))
		var/obj/item/stack/fireproof_rods/rods = I
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
			current_pull = current_pull.pulling


/turf/space/proc/check_taipan_availability(atom/movable/arrived, destination_z)
	if(!is_taipan(destination_z))
		return destination_z
	var/arrived_is_mob = isliving(arrived)
	var/mob/living/arrived_mob = arrived
	if(arrived_is_mob && (arrived_mob.mind in GLOB.taipan_players_active))
		to_chat(arrived_mob, span_info("Вы вернулись в ваш родной скрытый от чужих глаз сектор..."))
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


/turf/space/proc/Sandbox_Spacemove(atom/movable/A as mob|obj)
	var/cur_x
	var/cur_y
	var/next_x
	var/next_y
	var/target_z
	var/list/y_arr

	if(src.x <= 1)
		if(istype(A, /obj/effect/meteor))
			qdel(A)
			return

		var/list/cur_pos = src.get_global_map_pos()
		if(!cur_pos) return
		cur_x = cur_pos["x"]
		cur_y = cur_pos["y"]
		next_x = (--cur_x||GLOB.global_map.len)
		y_arr = GLOB.global_map[next_x]
		target_z = y_arr[cur_y]
/*
		//debug
		to_chat(world, "Src.z = [src.z] in global map X = [cur_x], Y = [cur_y]")
		to_chat(world, "Target Z = [target_z]")
		to_chat(world, "Next X = [next_x]")
		//debug
*/
		if(target_z)
			A.z = target_z
			A.x = world.maxx - 2
			spawn (0)
				if((A && A.loc))
					A.loc.Entered(A)
	else if(src.x >= world.maxx)
		if(istype(A, /obj/effect/meteor))
			qdel(A)
			return

		var/list/cur_pos = src.get_global_map_pos()
		if(!cur_pos) return
		cur_x = cur_pos["x"]
		cur_y = cur_pos["y"]
		next_x = (++cur_x > GLOB.global_map.len ? 1 : cur_x)
		y_arr = GLOB.global_map[next_x]
		target_z = y_arr[cur_y]
/*
		//debug
		to_chat(world, "Src.z = [src.z] in global map X = [cur_x], Y = [cur_y]")
		to_chat(world, "Target Z = [target_z]")
		to_chat(world, "Next X = [next_x]")
		//debug
*/
		if(target_z)
			A.z = target_z
			A.x = 3
			spawn (0)
				if((A && A.loc))
					A.loc.Entered(A)
	else if(src.y <= 1)
		if(istype(A, /obj/effect/meteor))
			qdel(A)
			return
		var/list/cur_pos = src.get_global_map_pos()
		if(!cur_pos) return
		cur_x = cur_pos["x"]
		cur_y = cur_pos["y"]
		y_arr = GLOB.global_map[cur_x]
		next_y = (--cur_y||y_arr.len)
		target_z = y_arr[next_y]
/*
		//debug
		to_chat(world, "Src.z = [src.z] in global map X = [cur_x], Y = [cur_y]")
		to_chat(world, "Next Y = [next_y]")
		to_chat(world, "Target Z = [target_z]")
		//debug
*/
		if(target_z)
			A.z = target_z
			A.y = world.maxy - 2
			spawn (0)
				if((A && A.loc))
					A.loc.Entered(A)

	else if(src.y >= world.maxy)
		if(istype(A, /obj/effect/meteor))
			qdel(A)
			return
		var/list/cur_pos = src.get_global_map_pos()
		if(!cur_pos) return
		cur_x = cur_pos["x"]
		cur_y = cur_pos["y"]
		y_arr = GLOB.global_map[cur_x]
		next_y = (++cur_y > y_arr.len ? 1 : cur_y)
		target_z = y_arr[next_y]
/*
		//debug
		to_chat(world, "Src.z = [src.z] in global map X = [cur_x], Y = [cur_y]")
		to_chat(world, "Next Y = [next_y]")
		to_chat(world, "Target Z = [target_z]")
		//debug
*/
		if(target_z)
			A.z = target_z
			A.y = 3
			spawn (0)
				if((A && A.loc))
					A.loc.Entered(A)
	return

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
	if(our_rcd.useResource(1, user))
		to_chat(user, "Building Floor...")
		playsound(get_turf(our_rcd), our_rcd.usesound, 50, 1)
		add_attack_logs(user, src, "Constructed floor with RCD")
		ChangeTurf(our_rcd.floor_type)
		return RCD_ACT_SUCCESSFULL
	to_chat(user, span_warning("ERROR! Not enough matter in unit to construct this floor!"))
	playsound(get_turf(our_rcd), 'sound/machines/click.ogg', 50, 1)
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
