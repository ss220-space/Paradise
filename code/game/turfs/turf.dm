/turf
	icon = 'icons/turf/floors.dmi'
	level = 1
	luminosity = 1

	vis_flags = VIS_INHERIT_ID	// Important for interaction with and visualization of openspace.

	var/intact = TRUE
	var/turf/baseturf = /turf/baseturf_bottom
	/// negative for faster, positive for slower
	var/slowdown = 0
	/// It's a check that determines if the turf is transparent to reveal the stuff(pipes, safe, cables and e.t.c.) without looking on intact
	var/transparent_floor = TURF_NONTRANSPARENT

	/// Set if the turf should appear on a different layer while in-game and map editing, otherwise use normal layer.
	var/real_layer = TURF_LAYER
	layer = MAP_EDITOR_TURF_LAYER

	///Properties for open tiles (/floor)
	/// All the gas vars, on the turf, are meant to be utilized for initializing a gas datum and setting its first gas values; the turf vars are never further modified at runtime; it is never directly used for calculations by the atmospherics system.
	var/oxygen = 0
	var/carbon_dioxide = 0
	var/nitrogen = 0
	var/toxins = 0
	var/sleeping_agent = 0
	var/agent_b = 0

	//Properties for airtight tiles (/wall)
	var/thermal_conductivity = 0.05
	var/heat_capacity = 1

	//Properties for both
	var/temperature = T20C

	//If set TRUE, won't init gas_mixture/air and shouldn't interact with atmos.
	var/blocks_air = FALSE
	// If this turf should initialize atmos adjacent turfs or not
	// Optimization, not for setting outside of initialize
	var/init_air = TRUE

	var/datum/pathnode/PNode = null //associated PathNode in the A* algorithm

	flags = 0

	var/changing_turf = FALSE

	var/list/blueprint_data //for the station blueprints, images of objects eg: pipes

	var/footstep = null
	var/barefootstep = null
	var/clawfootstep = null
	var/heavyfootstep = null

	/// Lumcount added by sources other than lighting datum objects, such as the overlay lighting component.
	var/dynamic_lumcount = 0
	/// Which directions does this turf block the vision of, taking into account both the turf's opacity and the movable opacity_sources.
	var/directional_opacity = NONE
	/// Lazylist of movable atoms providing opacity sources.
	var/list/atom/movable/opacity_sources
	/// Bool, whether this turf will always be illuminated no matter what area it is in
	var/always_lit = FALSE
	var/tmp/lighting_corners_initialised = FALSE
	/// Our lighting object.
	var/tmp/atom/movable/lighting_object/lighting_object
	// Lighting Corner datums.
	var/tmp/datum/lighting_corner/lighting_corner_NE
	var/tmp/datum/lighting_corner/lighting_corner_SE
	var/tmp/datum/lighting_corner/lighting_corner_SW
	var/tmp/datum/lighting_corner/lighting_corner_NW

	/// How pathing algorithm will check if this turf is passable by itself (not including content checks). By default it's just density check.
	/// WARNING: Currently to use a density shortcircuiting this does not support dense turfs with special allow through function
	var/pathing_pass_method = TURF_PATHING_PASS_DENSITY

	///whether or not this turf forces movables on it to have no gravity (unless they themselves have forced gravity)
	var/force_no_gravity = FALSE


/turf/Initialize(mapload)
	SHOULD_CALL_PARENT(FALSE)
	if(flags & INITIALIZED)
		stack_trace("Warning: [src]([type]) initialized multiple times!")
	flags |= INITIALIZED

	if(layer == MAP_EDITOR_TURF_LAYER)
		layer = real_layer

	/// We do NOT use the shortcut here, because this is faster
	if(SSmapping.max_plane_offset)
		if(!SSmapping.plane_offset_blacklist["[plane]"])
			plane = plane - (PLANE_RANGE * SSmapping.z_level_to_plane_offset[z])
			var/turf/T = GET_TURF_ABOVE(src)
			if(T)
				T.multiz_turf_new(src, DOWN)
			T = GET_TURF_BELOW(src)
			if(T)
				T.multiz_turf_new(src, UP)

	// by default, vis_contents is inherited from the turf that was here before
	// Checking length(vis_contents) in a proc this hot has huge wins for performance.
	if(length(vis_contents))
		vis_contents.Cut()

	SETUP_SMOOTHING()

	levelupdate()
	if(smooth)
		queue_smooth(src)

	for(var/atom/movable/content as anything in src)
		Entered(content)

	if(always_lit)
		var/mutable_appearance/overlay = GLOB.fullbright_overlays[GET_TURF_PLANE_OFFSET(src) + 1]
		add_overlay(overlay)

	if(light_power && light_range)
		update_light()

	if(opacity)
		directional_opacity = ALL_CARDINALS

	if(istype(loc, /area/space))
		force_no_gravity = TRUE

	return INITIALIZE_HINT_NORMAL

/turf/Destroy(force)
	. = QDEL_HINT_IWILLGC
	if(!changing_turf)
		stack_trace("Incorrect turf deletion")
	changing_turf = FALSE

	var/turf/V = GET_TURF_ABOVE(src)
	V?.multiz_turf_del(src, DOWN)
	V = GET_TURF_BELOW(src)
	V?.multiz_turf_del(src, UP)

	if(force)
		..()
		//this will completely wipe turf state
		var/turf/B = new world.turf(src)
		for(var/A in B.contents)
			qdel(A)
		return
	// Adds the adjacent turfs to the current atmos processing
	for(var/turf/simulated/T in atmos_adjacent_turfs)
		SSair.add_to_active(T)
	SSair.remove_from_active(src)
	QDEL_LIST(blueprint_data)
	flags &= ~INITIALIZED
	..()

	if(length(vis_contents))
		vis_contents.Cut()


/// WARNING WARNING
/// Turfs DO NOT lose their signals when they get replaced, REMEMBER THIS
/// It's possible because turfs are fucked, and if you have one in a list and it's replaced with another one, the list ref points to the new turf
/// We do it because moving signals over was needlessly expensive, and bloated a very commonly used bit of code
/turf/_clear_signal_refs()
	return


/turf/attack_hand(mob/user)
	. = ..()
	if(!.)
		user.Move_Pulled(src)


/turf/attack_robot(mob/user)
	user.Move_Pulled(src)

/turf/ex_act(severity)
	return FALSE

/turf/rpd_act(mob/user, obj/item/rpd/our_rpd) //This is the default turf behaviour for the RPD; override it as required
	if(our_rpd.mode == RPD_ATMOS_MODE)
		our_rpd.create_atmos_pipe(user, src)
	else if(our_rpd.mode == RPD_DISPOSALS_MODE)
		for(var/obj/machinery/door/airlock/A in src)
			if(A.density)
				to_chat(user, span_warning("That type of pipe won't fit under [A]!"))
				return
		our_rpd.create_disposals_pipe(user, src)
	else if(our_rpd.mode == RPD_ROTATE_MODE)
		our_rpd.rotate_all_pipes(user, src)
	else if(our_rpd.mode == RPD_FLIP_MODE)
		our_rpd.flip_all_pipes(user, src)
	else if(our_rpd.mode == RPD_DELETE_MODE)
		our_rpd.delete_all_pipes(user, src)

/turf/bullet_act(obj/item/projectile/Proj)
	if(istype(Proj, /obj/item/projectile/beam/pulse))
		src.ex_act(2)
	..()
	return FALSE

/turf/bullet_act(obj/item/projectile/Proj)
	if(istype(Proj, /obj/item/projectile/bullet/gyro))
		explosion(src, -1, 0, 2, cause = Proj)
	..()
	return FALSE


/turf/Enter(atom/movable/mover)
	// Do not call ..()
	// Byond's default turf/Enter() doesn't have the behaviour we want with Bump()
	// By default byond will call Bump() on the first dense object in contents
	// Here's hoping it doesn't stay like this for years before we finish conversion to step_

	// There's a lot of QDELETED() calls here if someone can figure out how to optimize this
	// but not runtime when something gets deleted by a Bump/CanPass/Cross call

	var/atom/mover_loc = mover.loc
	var/border_dir = get_dir(src, mover)
	var/can_pass_self = CanPass(mover, border_dir)
	var/atom/movable/tompost_bump
	if(can_pass_self)
		var/mover_is_phasing = (mover.movement_type & PHASING)
		for(var/atom/movable/obstacle as anything in contents)
			// Multi tile objects and moving out of other objects.
			if(obstacle == mover || obstacle == mover_loc)
				continue
			if(!obstacle.Cross(mover, border_dir))
				// Deleted from Cross() (CanPass is pure so it cant delete, Cross shouldnt be doing this either though, but it can happen).
				if(QDELETED(mover))
					return FALSE
				if(mover_is_phasing)
					mover.Bump(obstacle)
					// Deleted from Bump().
					if(QDELETED(mover))
						return FALSE
					continue
				else
					var/override = obstacle.tompost_bump_override(mover, border_dir)
					if(isatom(override))
						tompost_bump = override
						break
					// We are using layers to pick what we are bumping, always choosing obstacle with the highest one
					// its sufficient but not ideal method, separate variable is probably a better solution.
					if(!tompost_bump || ((obstacle.layer > tompost_bump.layer || obstacle.flags & ON_BORDER) && !(tompost_bump.flags & ON_BORDER)))
						tompost_bump = obstacle

	// Mover deleted from Cross/CanPass/Bump, do not proceed.
	if(QDELETED(mover))
		return FALSE
	// Even if mover is unstoppable they need to bump us.
	if(!can_pass_self)
		tompost_bump = src
	if(tompost_bump)
		mover.Bump(tompost_bump)
		return (mover.movement_type & PHASING)
	return TRUE


/turf/proc/levelupdate()
	for(var/obj/object in src)
		if(object.level == 1 && (object.flags & INITIALIZED)) // Only do this if the object has initialized
			object.hide(intact)

// override for space turfs, since they should never hide anything
/turf/space/levelupdate()
	for(var/obj/object in src)
		if(object.level == 1 && (object.flags & INITIALIZED))
			object.hide(FALSE)

// Removes all signs of lattice on the pos of the turf -Donkieyo
/turf/proc/RemoveLattice()
	var/obj/structure/lattice/lattice = locate() in src
	if(lattice && (lattice.flags & INITIALIZED))
		qdel(lattice)

/turf/proc/dismantle_wall(devastated = FALSE, explode = FALSE)
	return

/turf/proc/TerraformTurf(path, defer_change = FALSE, keep_icon = TRUE, ignore_air = FALSE)
	return ChangeTurf(path, defer_change, keep_icon, ignore_air)

//Creates a new turf
/turf/proc/ChangeTurf(path, defer_change = FALSE, keep_icon = TRUE, ignore_air = FALSE, copy_existing_baseturf = TRUE)
	switch(path)
		if(null)
			return
		if(/turf/baseturf_bottom)
			path = check_level_trait(z, ZTRAIT_BASETURF) || /turf/space
			if (!ispath(path))
				path = text2path(path)
				if (!ispath(path))
					warning("Z-level [z] has invalid baseturf '[check_level_trait(z, ZTRAIT_BASETURF)]'")
					path = /turf/space
	if(!GLOB.use_preloader && path == type) // Don't no-op if the map loader requires it to be reconstructed
		return src

	set_light_on(FALSE)
	var/old_opacity = opacity
	var/old_always_lit = always_lit
	var/old_lighting_object = lighting_object
	var/old_blueprint_data = blueprint_data
	var/old_directional_opacity = directional_opacity
	var/old_dynamic_lumcount = dynamic_lumcount
	var/old_lighting_corner_NE = lighting_corner_NE
	var/old_lighting_corner_SE = lighting_corner_SE
	var/old_lighting_corner_SW = lighting_corner_SW
	var/old_lighting_corner_NW = lighting_corner_NW
	var/old_type = type

	BeforeChange()

	var/old_baseturf = baseturf

	var/list/post_change_callbacks = list()
	SEND_SIGNAL(src, COMSIG_TURF_CHANGE, path, post_change_callbacks)

	changing_turf = TRUE
	qdel(src)	//Just get the side effects and call Destroy
	//We do this here so anything that doesn't want to persist can clear itself
	var/list/old_comp_lookup = comp_lookup?.Copy()
	var/list/old_signal_procs = signal_procs?.Copy()
	var/turf/W = new path(src)

	// WARNING WARNING
	// Turfs DO NOT lose their signals when they get replaced, REMEMBER THIS
	// It's possible because turfs are fucked, and if you have one in a list and it's replaced with another one, the list ref points to the new turf
	if(old_comp_lookup)
		LAZYOR(W.comp_lookup, old_comp_lookup)
	if(old_signal_procs)
		LAZYOR(W.signal_procs, old_signal_procs)

	for(var/datum/callback/callback as anything in post_change_callbacks)
		callback.InvokeAsync(W)

	if(copy_existing_baseturf)
		W.baseturf = old_baseturf

	if(!defer_change)
		W.AfterChange(ignore_air, oldType = old_type)

	W.blueprint_data = old_blueprint_data

	lighting_corner_NE = old_lighting_corner_NE
	lighting_corner_SE = old_lighting_corner_SE
	lighting_corner_SW = old_lighting_corner_SW
	lighting_corner_NW = old_lighting_corner_NW

	dynamic_lumcount = old_dynamic_lumcount

	if(W.always_lit)
		// We are guarenteed to have these overlays because of how generation works
		var/mutable_appearance/overlay = GLOB.fullbright_overlays[GET_TURF_PLANE_OFFSET(src) + 1]
		W.add_overlay(overlay)
	else if (old_always_lit)
		var/mutable_appearance/overlay = GLOB.fullbright_overlays[GET_TURF_PLANE_OFFSET(src) + 1]
		W.cut_overlay(overlay)

	// we need to refresh gravity for all living mobs to cover possible gravity change
	for(var/mob/living/mob in contents)
		if(HAS_TRAIT(mob, TRAIT_NEGATES_GRAVITY))
			if(!isgroundlessturf(src))
				ADD_TRAIT(mob, TRAIT_IGNORING_GRAVITY, IGNORING_GRAVITY_NEGATION)
			else
				REMOVE_TRAIT(mob, TRAIT_IGNORING_GRAVITY, IGNORING_GRAVITY_NEGATION)
		mob.refresh_gravity()

	if(SSlighting.initialized)
		lighting_object = old_lighting_object

		directional_opacity = old_directional_opacity
		recalculate_directional_opacity()

		if(lighting_object && !lighting_object.needs_update)
			lighting_object.update()

		if(old_always_lit != always_lit)
			if(!always_lit)
				lighting_build_overlay()
			else
				lighting_clear_overlay()

		for(var/turf/space/S in RANGE_TURFS(1, src)) //RANGE_TURFS is in code\__HELPERS\game.dm
			S.update_starlight()

	if(old_opacity != opacity && SSticker)
		GLOB.cameranet.bareMajorChunkChange(src)

	// We will only run this logic if the tile is not on the prime z layer, since we use area overlays to cover that
	if(SSmapping.z_level_to_plane_offset[z])
		var/area/our_area = W.loc
		if(our_area.lighting_effects)
			W.add_overlay(our_area.lighting_effects[SSmapping.z_level_to_plane_offset[z] + 1])
	SSdemo.mark_turf(W)

	return W

/turf/proc/BeforeChange()
	return

/turf/proc/is_safe()
	return FALSE

// I'm including `ignore_air` because BYOND lacks positional-only arguments
/turf/proc/AfterChange(ignore_air = FALSE, keep_cabling = FALSE, oldType = null) //called after a turf has been replaced in ChangeTurf()
	levelupdate()
	CalculateAdjacentTurfs()

	if(SSair && !ignore_air)
		SSair.add_to_active(src)

	//update firedoor adjacency
	var/list/turfs_to_check = get_adjacent_open_turfs(src) | src
	for(var/I in turfs_to_check)
		var/turf/T = I
		for(var/obj/machinery/door/firedoor/FD in T)
			FD.CalculateAffectingAreas()

	if(!keep_cabling && !can_have_cabling())
		for(var/obj/structure/cable/C in contents)
			qdel(C)

/turf/proc/ReplaceWithLattice()
	ChangeTurf(baseturf)
	new /obj/structure/lattice(locate(x, y, z))

/turf/proc/remove_plating(mob/user)
	return

/turf/proc/kill_creatures(mob/U = null)//Will kill people/creatures and damage mechs./N
//Useful to batch-add creatures to the list.
	for(var/mob/living/M in src)
		if(M == U)
			continue//Will not harm U. Since null != M, can be excluded to kill everyone.
		INVOKE_ASYNC(M, TYPE_PROC_REF(/mob, gib))
	for(var/obj/mecha/M in src)//Mecha are not gibbed but are damaged.
		INVOKE_ASYNC(M, TYPE_PROC_REF(/obj/mecha, take_damage), 100, "brute")

/turf/proc/Bless()
	flags |= NOJAUNT

/turf/proc/burn_down()
	return

/////////////////////////////////////////////////////////////////////////
// Navigation procs
// Used for A-star pathfinding
////////////////////////////////////////////////////////////////////////

///////////////////////////
//Cardinal only movements
///////////////////////////

// Returns the surrounding cardinal turfs with open links
// Don't check for ID, doors passable only if open
/turf/proc/CardinalTurfs()
	var/list/L = new()
	var/turf/simulated/T

	for(var/dir in GLOB.cardinal)
		T = get_step(src, dir)
		if(istype(T) && !T.density)
			if(!CanAtmosPass(T, FALSE))
				L.Add(T)
	return L

///////////////////////////
//All directions movements
///////////////////////////

/// Returns the adjacent turfs. Can check for density or cardinal directions only instead of all 8, or just dense turfs entirely. dense_only takes precedence over open_only.
/turf/proc/AdjacentTurfs(open_only = FALSE, cardinal_only = FALSE, dense_only = FALSE)
	var/list/L = list()
	var/turf/T
	var/list/directions = cardinal_only ? GLOB.cardinal : GLOB.alldirs
	for(var/dir in directions)
		T = get_step(src, dir)
		if(!istype(T))
			continue
		if(dense_only && !T.density)
			continue
		if((open_only && T.density) && !dense_only)
			continue
		L.Add(T)
	return L


//////////////////////////////
//Distance procs
//////////////////////////////

//Distance associates with all directions movement
/turf/proc/Distance(turf/T)
	return get_dist(src, T)

//  This Distance proc assumes that only cardinal movement is
//  possible. It results in more efficient (CPU-wise) pathing
//  for bots and anything else that only moves in cardinal dirs.
/turf/proc/Distance_cardinal(turf/T)
	if(!src || !T)
		return 0
	return abs(src.x - T.x) + abs(src.y - T.y)

////////////////////////////////////////////////////

/turf/acid_act(acidpwr, acid_volume)
	. = TRUE
	var/acid_type = /obj/effect/acid
	if(acidpwr >= 200) //alien acid power
		acid_type = /obj/effect/acid/alien
	var/has_acid_effect = FALSE
	for(var/obj/O in src)
		if(intact && O.level == 1) //hidden under the floor
			continue
		if(istype(O, acid_type))
			var/obj/effect/acid/A = O
			A.acid_level = min(A.level + acid_volume * acidpwr, 12000)//capping acid level to limit power of the acid
			has_acid_effect = 1
			continue
		O.acid_act(acidpwr, acid_volume)
	if(!has_acid_effect)
		new acid_type(src, acidpwr, acid_volume)

/turf/proc/acid_melt()
	return


/turf/handle_fall(mob/living/carbon/faller)
	if(has_gravity(src))
		playsound(src, "bodyfall", 50, TRUE)
	faller.drop_from_hands()


/turf/singularity_act()
	if(intact)
		for(var/obj/O in contents) //this is for deleting things like wires contained in the turf
			if(O.level != 1)
				continue
			if(O.invisibility == INVISIBILITY_MAXIMUM || O.invisibility == INVISIBILITY_ABSTRACT)
				O.singularity_act()
	ChangeTurf(baseturf)
	return 2


/turf/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(ATTACK_CHAIN_CANCEL_CHECK(.) || !can_lay_cable())
		return .

	if(iscoil(I))
		add_fingerprint(user)
		var/obj/item/stack/cable_coil/coil = I
		for(var/obj/structure/cable/local_cable in src)
			if(local_cable.d1 == 0 || local_cable.d2 == 0)
				local_cable.attackby(coil, user, params)
				. |= (ATTACK_CHAIN_BLOCKED_ALL)
				return .
		coil.place_turf(src, user)
		. |= (ATTACK_CHAIN_BLOCKED_ALL)
		return .

	if(istype(I, /obj/item/twohanded/rcl))
		add_fingerprint(user)
		var/obj/item/twohanded/rcl/rcl = I
		if(!rcl.loaded)
			to_chat(user, span_warning("The [rcl.name] has no cable!"))
			return .
		for(var/obj/structure/cable/local_cable in src)
			if(local_cable.d1 == 0 || local_cable.d2 == 0)
				local_cable.attackby(rcl, user, params)
				. |= (ATTACK_CHAIN_BLOCKED_ALL)
				return .
		rcl.loaded.place_turf(src, user)
		rcl.is_empty(user)
		. |= (ATTACK_CHAIN_BLOCKED_ALL)
		return .


/turf/proc/can_have_cabling()
	return TRUE


/turf/proc/can_lay_cable()
	return can_have_cabling() && !intact && transparent_floor != TURF_TRANSPARENT


/turf/proc/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	underlay_appearance.icon = icon
	underlay_appearance.icon_state = icon_state
	underlay_appearance.dir = adjacency_dir
	return TRUE

/turf/proc/add_blueprints(atom/movable/AM)
	var/image/I = new
	I.appearance = AM.appearance
	SET_PLANE(I, GAME_PLANE, src)
	I.layer = GHOST_LAYER + AM.layer
	I.appearance_flags = RESET_COLOR|RESET_ALPHA|RESET_TRANSFORM
	I.loc = src
	I.setDir(AM.dir)
	I.alpha = 128
	LAZYADD(blueprint_data, I)

/turf/proc/add_blueprints_preround(atom/movable/AM)
	if(!SSticker || SSticker.current_state != GAME_STATE_PLAYING)
		add_blueprints(AM)

/turf/proc/empty(turf_type = /turf/space)
	// Remove all atoms except observers, landmarks, docking ports, and (un)`simulated` atoms (lighting overlays)
	var/turf/T0 = src
	for(var/X in T0.GetAllContents())
		var/atom/A = X
		if(!A.simulated)
			continue
		if(istype(A, /mob/dead))
			continue
		if(istype(A, /obj/effect/landmark))
			continue
		if(istype(A, /obj/docking_port))
			continue
		qdel(A, force = TRUE)

	T0.ChangeTurf(turf_type)

	SSair.remove_from_active(T0)
	T0.CalculateAdjacentTurfs()
	SSair.add_to_active(T0, TRUE)

/turf/AllowDrop()
	return TRUE

//The zpass procs exist to be overriden, not directly called
//use can_z_pass for that
///If we'd allow anything to travel into us
/turf/proc/zPassIn(direction)
	return FALSE

///If we'd allow anything to travel out of us
/turf/proc/zPassOut(direction)
	return FALSE

//direction is direction of travel of air
/turf/proc/zAirIn(direction, turf/source)
	return FALSE

//direction is direction of travel of air
/turf/proc/zAirOut(direction, turf/source)
	return FALSE

/turf/proc/multiz_turf_del(turf/T, dir)
	SEND_SIGNAL(src, COMSIG_TURF_MULTIZ_DEL, T, dir)

/turf/proc/multiz_turf_new(turf/T, dir)
	SEND_SIGNAL(src, COMSIG_TURF_MULTIZ_NEW, T, dir)

///Called each time the target falls down a z level possibly making their trajectory come to a halt. see __DEFINES/movement.dm.
/turf/proc/zImpact(atom/movable/falling, levels = 1, turf/prev_turf, flags = NONE)
	var/list/falling_movables = falling.get_z_move_affected()
	var/list/falling_mov_names
	for(var/atom/movable/falling_mov as anything in falling_movables)
		falling_mov_names += falling_mov.name
	for(var/i in contents)
		var/atom/thing = i
		flags |= thing.intercept_zImpact(falling_movables, levels)
		if(flags & FALL_STOP_INTERCEPTING)
			break
	if(prev_turf && !(flags & FALL_NO_MESSAGE))
		for(var/mov_name in falling_mov_names)
			prev_turf.visible_message(span_danger("[mov_name] falls through [prev_turf]!"))
	if(!(flags & FALL_INTERCEPTED) && zFall(falling, levels + 1)) // Can we fall down? If so return false
		return FALSE
	for(var/atom/movable/falling_mov as anything in falling_movables)
		if(!(flags & FALL_RETAIN_PULL))
			falling_mov.stop_pulling()
		if(!(flags & FALL_INTERCEPTED))
			falling_mov.onZImpact(src, levels)
		if(falling_mov.pulledby && (falling_mov.z != falling_mov.pulledby.z || get_dist(falling_mov, falling_mov.pulledby) > 1))
			falling_mov.pulledby.stop_pulling()
	return TRUE

/// Precipitates a movable (plus whatever buckled to it) to lower z levels if possible and then calls zImpact()
/turf/proc/zFall(atom/movable/falling, levels = 1, force = FALSE, falling_from_move = FALSE)
	var/turf/target = get_step_multiz(src, DOWN)
	if(!target)
		return FALSE
	var/isliving = isliving(falling)
	if(!isliving && !isobj(falling))
		return FALSE
	var/atom/movable/living_buckled
	if(isliving)
		var/mob/living/falling_living = falling
		//relay this mess to whatever the mob is buckled to.
		if(falling_living.buckled)
			living_buckled = falling
			falling = falling_living.buckled
	if(!falling_from_move && falling.currently_z_moving)
		return FALSE
	if(!force && !falling.can_z_move(DOWN, src, target, ZMOVE_FALL_FLAGS))
		falling.set_currently_z_moving(FALSE, TRUE)
		living_buckled?.set_currently_z_moving(FALSE, TRUE)
		return FALSE

	// So it doesn't trigger other zFall calls. Cleared on zMove.
	falling.set_currently_z_moving(CURRENTLY_Z_FALLING)
	living_buckled?.set_currently_z_moving(CURRENTLY_Z_FALLING)

	falling.zMove(null, target, ZMOVE_CHECK_PULLEDBY)
	target.zImpact(falling, levels, src)
	return TRUE


/**
 * Returns adjacent turfs to this turf that are reachable, in all cardinal directions
 *
 * Arguments:
 * * caller: The movable, if one exists, being used for mobility checks to see what tiles it can reach
 * * access: A list that decides if we can gain access to doors that would otherwise block a turf
 * * simulated_only: Do we only worry about turfs with simulated atmos, most notably things that aren't space?
 * * no_id: When true, doors with public access will count as impassible
*/
/turf/proc/reachableAdjacentTurfs(atom/movable/caller, list/access, simulated_only, no_id = FALSE)
	var/static/space_type_cache = typecacheof(/turf/space)
	. = list()

	var/datum/can_pass_info/pass_info = new(caller, access, no_id)
	for(var/iter_dir in GLOB.cardinal)
		var/turf/turf_to_check = get_step(src, iter_dir)
		if(!turf_to_check || (simulated_only && space_type_cache[turf_to_check.type]))
			continue
		if(turf_to_check.density || LinkBlockedWithAccess(turf_to_check, pass_info))
			continue
		. += turf_to_check


/**
 * Makes an image of up to 20 things on a turf + the turf.
 */
/turf/proc/photograph(limit = 20)
	var/image/I = new()
	I.add_overlay(src)
	for(var/V in contents)
		var/atom/A = V
		if(A.invisibility)
			continue
		I.add_overlay(A)
		if(limit)
			limit--
		else
			return I
	return I


/turf/hit_by_thrown_carbon(mob/living/carbon/human/C, datum/thrownthing/throwingdatum, damage, mob_hurt, self_hurt)
	if(mob_hurt || !density)
		return
	playsound(src, 'sound/weapons/punch1.ogg', 35, TRUE)
	C.visible_message(span_danger("[C] slams into [src]!"),
					span_userdanger("You slam into [src]!"))
	C.take_organ_damage(damage)
	C.Weaken(0.1 SECONDS)


/**
 * Check whether the specified turf is blocked by something dense inside it with respect to a specific atom.
 *
 * Returns `TRUE` if the turf is blocked because the turf itself is dense.
 * Returns `TRUE` if one of the turf's contents is dense and would block a source atom's movement.
 * Returns `FALSE` if the turf is not blocked.
 *
 * Arguments:
 * * exclude_mobs - If `TRUE`, ignores dense mobs on the turf.
 * * source_atom - If this is not null, will check whether any contents on the turf can block this atom specifically. Also ignores itself on the turf. Also if source atom is in turf contents proc will check if it can exit.
 * * ignore_atoms - Check will ignore any atoms in this list. Useful to prevent an atom from blocking itself on the turf.
 * * type_list - are we checking for types of atoms to ignore and not physical atoms
 */
/turf/proc/is_blocked_turf(exclude_mobs = FALSE, atom/source_atom = null, list/ignore_atoms, type_list = FALSE)
	if(density)
		return TRUE

	// Prevents jaunting onto the AI core cheese, AI should always block a turf due to being a dense mob even when unanchored
	if(locate(/mob/living/silicon/ai) in contents)
		return TRUE

	for(var/atom/movable/movable_content as anything in contents)
		// We don't want to block ourselves
		if((movable_content == source_atom))
			continue
		// dont consider ignored atoms or their types
		if(length(ignore_atoms))
			if(!type_list && (movable_content in ignore_atoms))
				continue
			else if(type_list && is_type_in_list(movable_content, ignore_atoms))
				continue

		// If the thing is dense AND we're including mobs or the thing isn't a mob AND if there's a source atom and
		// it cannot pass through the thing on the turf, we consider the turf blocked.
		if(movable_content.density && (!exclude_mobs || !ismob(movable_content)))
			if(source_atom && movable_content.CanPass(source_atom, get_dir(src, source_atom)))
				continue
			return TRUE

	return FALSE


/turf/grab_attack(mob/living/grabber, atom/movable/grabbed_thing)
	. = TRUE
	grabber.Move_Pulled(src)

/// Generates a space underlay for a turf
/// This provides proper lighting support alongside just looking nice
/// Accepts the appearance to make "spaceish", and the turf we're doing this for
/proc/generate_space_underlay(mutable_appearance/underlay_appearance, turf/generate_for)
	underlay_appearance.icon = 'icons/turf/space.dmi'
	underlay_appearance.icon_state = "0"
	SET_PLANE(underlay_appearance, PLANE_SPACE, generate_for)
	if(!generate_for.render_target)
		generate_for.render_target = ref(generate_for)
	var/atom/movable/emissive_blocker/em_block = new(null, generate_for)
	underlay_appearance.overlays += em_block
	// We used it because it's convienient and easy, but it's gotta go now or it'll hang refs
	QDEL_NULL(em_block)
	// We're gonna build a light, and mask it with the base turf's appearance
	// grab a 32x32 square of it
	// I would like to use GLOB.starbright_overlays here
	// But that breaks down for... some? reason. I think receiving a render relay breaks keep_together or something
	// So we're just gonna accept  that this'll break with starlight color changing. hardly matters since this is really only for offset stuff, but I'd love to fix it someday
	var/mutable_appearance/light = new(GLOB.default_lighting_underlays_by_z[generate_for.z])
	light.render_target = ""
	light.appearance_flags |= KEEP_TOGETHER
	// Now apply a copy of the turf, set to multiply
	// This will multiply against our light, so we only light up the bits that aren't "on" the wall
	var/mutable_appearance/mask = new(generate_for.appearance)
	mask.blend_mode = BLEND_MULTIPLY
	mask.render_target = ""
	mask.pixel_x = 0
	mask.pixel_y = 0
	mask.pixel_w = 0
	mask.pixel_z = 0
	mask.transform = null
	mask.underlays = list() // Begone foul lighting overlay
	SET_PLANE(mask, FLOAT_PLANE, generate_for)
	mask.layer = FLOAT_LAYER

	// Bump the opacity to full, will this work?
	mask.color = list(0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,255, 0,0,0,0)
	light.overlays += mask
	underlay_appearance.overlays += light

	// Now, we're going to make a copy of the mask. Instead of using it to multiply against our light
	// We're going to use it to multiply against the turf lighting plane. Going to mask away the turf light
	// And rely on LIGHTING_MASK_LAYER to ensure we mask ONLY that bit
	var/mutable_appearance/turf_mask = new(mask.appearance)
	SET_PLANE(turf_mask, LIGHTING_PLANE, generate_for)
	turf_mask.layer = LIGHTING_LAYER
	/// Any color becomes white. Anything else is black, and it's fully opaque
	/// Ought to work
	turf_mask.color = list(255,255,255,0, 255,255,255,0, 255,255,255,0, 0,0,0,0, 0,0,0,255)
	underlay_appearance.overlays += turf_mask
