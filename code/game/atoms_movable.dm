/atom/movable
	layer = OBJ_LAYER
	appearance_flags = TILE_BOUND|PIXEL_SCALE|LONG_GLIDE
	glide_size = DEFAULT_GLIDE_SIZE // Default, adjusted when mobs move based on their movement delays
	var/last_move = null
	var/anchored = FALSE
	var/move_resist = MOVE_RESIST_DEFAULT
	var/move_force = MOVE_FORCE_DEFAULT
	var/pull_force = PULL_FORCE_DEFAULT
	var/move_speed = 10
	var/l_move_time = 1
	var/datum/thrownthing/throwing = null
	var/throw_speed = 2 //How many tiles to move per ds when being thrown. Float values are fully supported
	var/throw_range = 7
	var/no_spin_thrown = FALSE
	var/throwforce = 0

	/// Mob, who currently pulling/grabbing us
	var/mob/living/pulledby
	/// Movable thing we are currently pulling/grabbing
	var/atom/movable/pulling
	/// Our current grab state
	var/grab_state = GRAB_PASSIVE
	/// The strongest grab we can acomplish
	var/max_grab = GRAB_PASSIVE

	/// A list containing arguments for Moved().
	VAR_PRIVATE/tmp/list/active_movement

	/// If false makes [CanPass][/atom/proc/CanPass] call [CanPassThrough][/atom/movable/proc/CanPassThrough] on this type instead of using default behaviour
	var/generic_canpass = TRUE

	/// Holds information about any movement loops currently running/waiting to run on the movable. Lazy, will be null if nothing's going on
	var/datum/movement_packet/move_packet
	/// Are we moving with inertia? Mostly used as an optimization
	var/inertia_moving = FALSE
	/// Delay in deciseconds between inertia based movement
	var/inertia_move_delay = 5
	///The last time we pushed off something
	///This is a hack to get around dumb him him me scenarios
	var/last_pushoff

	/// Used for the calculate_adjacencies proc for icon smoothing.
	var/can_be_unanchored = FALSE

	/// Whether the atom allows mobs to be buckled to it. Can be ignored in [/atom/movable/proc/buckle_mob()] if force = TRUE
	var/can_buckle = FALSE
	/// Bed-like behaviour, forces mob.lying_angle = buckle_lying if not set to [NO_BUCKLE_LYING].
	/// Its an ANGLE, not a BOOLEAN var! 0 means you will always stand up, after being buckled to this atom.
	var/buckle_lying = NO_BUCKLE_LYING
	/// Require people to be handcuffed before being able to buckle. eg: pipes
	var/buckle_requires_restraints = FALSE
	/// The mobs currently buckled to this atom
	var/list/mob/living/buckled_mobs
	/// The maximum number of mob/livings allowed to be buckled to this atom at once
	var/max_buckled_mobs = 1
	/// Whether things buckled to this atom can be pulled while they're buckled
	var/buckle_prevents_pull = FALSE

	/**
	  * In case you have multiple types, you automatically use the most useful one.
	  * IE: Skating on ice, flippers on water, flying over chasm/space, etc.
	  * I reccomend you use the movetype_handler system and not modify this directly, especially for living mobs.
	  */
	var/movement_type = GROUND

	/// NONE:0 not doing a diagonal move. FIRST_DIAG_STEP:1 and SECOND_DIAG_STEP:2 doing the first/second step of the diagonal move.
	var/moving_diagonally = NONE
	/// Attempt to resume grab after moving instead of before.
	var/atom/movable/moving_from_pull

	/// Just another var to avoid infinite recursion with double pulling. Move along.
	var/pulling_glidesize_update = FALSE

	/// Whether this atom should have its dir automatically changed when it moves.
	/// Setting this to FALSE allows for things such as directional windows to retain dir on moving
	/// without snowflake code all of the place.
	var/set_dir_on_move = TRUE

	///contains every client mob corresponding to every client eye in this container. lazily updated by SSparallax and is sparse:
	///only the last container of a client eye has this list assuming no movement since SSparallax's last fire
	var/list/client_mobs_in_contents

	/// Either FALSE, [EMISSIVE_BLOCK_GENERIC], or [EMISSIVE_BLOCK_UNIQUE]
	var/blocks_emissive = FALSE
	///Internal holder for emissive blocker object, do not use directly use blocks_emissive
	var/atom/movable/emissive_blocker/em_block

	///Lazylist to keep track on the sources of illumination.
	var/list/affected_dynamic_lights
	///Highest-intensity light affecting us, which determines our visibility.
	var/affecting_dynamic_lumi = 0

	/// Icon state for thought bubbles. Normally set by mobs.
	var/thought_bubble_image = "thought_bubble"

	///is the mob currently ascending or descending through z levels?
	var/currently_z_moving


/atom/movable/attempt_init(loc, ...)
	var/turf/T = get_turf(src)
	if(T && SSatoms.initialized != INITIALIZATION_INSSATOMS && GLOB.space_manager.is_zlevel_dirty(T.z))
		GLOB.space_manager.postpone_init(T.z, src)
		return
	. = ..()


/atom/movable/Initialize(mapload, ...)
	. = ..()
	switch(blocks_emissive)
		if(EMISSIVE_BLOCK_GENERIC)
			var/static/mutable_appearance/emissive_blocker/blocker = new
			blocker.icon = icon
			blocker.icon_state = icon_state
			blocker.dir = dir
			blocker.alpha = alpha
			blocker.appearance_flags |= appearance_flags
			blocker.plane = GET_NEW_PLANE(EMISSIVE_PLANE, PLANE_TO_OFFSET(plane))
			// Ok so this is really cursed, but I want to set with this blocker cheaply while
			// still allowing it to be removed from the overlays list later.
			// So I'm gonna flatten it, then insert the flattened overlay into overlays AND the managed overlays list, directly.
			// I'm sorry!
			var/mutable_appearance/flat = blocker.appearance
			overlays += flat
			if(managed_overlays)
				if(islist(managed_overlays))
					managed_overlays += flat
				else
					managed_overlays = list(managed_overlays, flat)
			else
				managed_overlays = flat

		if(EMISSIVE_BLOCK_UNIQUE)
			render_target = ref(src)
			em_block = new(null, src)
			overlays += em_block
			if(managed_overlays)
				if(islist(managed_overlays))
					managed_overlays += em_block
				else
					managed_overlays = list(managed_overlays, em_block)
			else
				managed_overlays = em_block

	if(opacity)
		AddElement(/datum/element/light_blocking)

	switch(light_system)
		if(MOVABLE_LIGHT)
			AddComponent(/datum/component/overlay_lighting)
		if(MOVABLE_LIGHT_DIRECTIONAL)
			AddComponent(/datum/component/overlay_lighting, is_directional = TRUE)


/atom/movable/Destroy(force)
	unbuckle_all_mobs(force = TRUE)
	QDEL_NULL(em_block)

	if(opacity)
		RemoveElement(/datum/element/light_blocking)

	invisibility = INVISIBILITY_ABSTRACT

	if(pulledby)
		pulledby.stop_pulling()
	if(pulling)
		stop_pulling()
	if(orbiting)
		stop_orbit()
	if(move_packet)
		if(!QDELETED(move_packet))
			qdel(move_packet)
		move_packet = null

	LAZYNULL(client_mobs_in_contents)

	. = ..()

	if(loc)
		loc.handle_atom_del(src)
	for(var/atom/movable/AM in contents)
		qdel(AM)
	move_to_null_space()


/atom/movable/get_emissive_block()
	switch(blocks_emissive)
		if(EMISSIVE_BLOCK_GENERIC)
			return fast_emissive_blocker(src)
		if(EMISSIVE_BLOCK_UNIQUE)
			if(!em_block && !QDELETED(src))
				render_target = ref(src)
				em_block = new(null, src)
			return em_block


/atom/movable/vv_edit_var(var_name, var_value)
	var/static/list/banned_edits = list(NAMEOF_STATIC(src, step_x) = TRUE, NAMEOF_STATIC(src, step_y) = TRUE, NAMEOF_STATIC(src, step_size) = TRUE, NAMEOF_STATIC(src, bounds) = TRUE)
	var/static/list/careful_edits = list(NAMEOF_STATIC(src, bound_x) = TRUE, NAMEOF_STATIC(src, bound_y) = TRUE, NAMEOF_STATIC(src, bound_width) = TRUE, NAMEOF_STATIC(src, bound_height) = TRUE)
	var/static/list/not_falsey_edits = list(NAMEOF_STATIC(src, bound_width) = TRUE, NAMEOF_STATIC(src, bound_height) = TRUE)
	if(banned_edits[var_name])
		return FALSE //PLEASE no.
	if(careful_edits[var_name] && (var_value % world.icon_size) != 0)
		return FALSE
	if(not_falsey_edits[var_name] && !var_value)
		return FALSE

	switch(var_name)
		if(NAMEOF(src, x))
			var/turf/T = locate(var_value, y, z)
			if(T)
				admin_teleport(T)
				return TRUE
			return FALSE
		if(NAMEOF(src, y))
			var/turf/T = locate(x, var_value, z)
			if(T)
				admin_teleport(T)
				return TRUE
			return FALSE
		if(NAMEOF(src, z))
			var/turf/T = locate(x, y, var_value)
			if(T)
				admin_teleport(T)
				return TRUE
			return FALSE
		if(NAMEOF(src, loc))
			if(isatom(var_value) || isnull(var_value))
				admin_teleport(var_value)
				return TRUE
			return FALSE
		if(NAMEOF(src, anchored))
			set_anchored(var_value)
			. = TRUE
		if(NAMEOF(src, glide_size))
			set_glide_size(var_value)
			. = TRUE

	if(!isnull(.))
		datum_flags |= DF_VAR_EDITED
		return .

	return ..()

/atom/movable/proc/moveToNullspace()
	return doMove(null)

/// Proc to hook user-enacted teleporting behavior and keep logging of the event.
/atom/movable/proc/admin_teleport(atom/new_location)
	if(isnull(new_location))
		log_admin("[key_name(usr)] teleported [key_name(src)] to nullspace")
		move_to_null_space()
	else
		var/turf/location = get_turf(new_location)
		log_admin("[key_name(usr)] teleported [key_name(src)] to [AREACOORD(location)]")
		forceMove(new_location)


//Returns an atom's power cell, if it has one. Overload for individual items.
/atom/movable/proc/get_cell()
	return

//Handles special effects on teleporting. Overload for some items if you want to do so.
/atom/movable/proc/on_teleported()
	return


/atom/movable/proc/start_pulling(atom/movable/pulled_atom, state, force = pull_force, supress_message = FALSE)
	if(QDELETED(pulled_atom))
		return FALSE
	if(!(pulled_atom.can_be_pulled(src, state, force, supress_message)))
		return FALSE

	// If we're pulling something then drop what we're currently pulling and pull this instead.
	if(pulling)
		if(state == 0)
			stop_pulling()
			return FALSE
		// Are we trying to pull something we are already pulling? Then enter grab cycle and end.
		if(pulled_atom == pulling)
			setGrabState(state)
			if(isliving(pulled_atom))
				var/mob/living/pulled_mob = pulled_atom
				pulled_mob.grabbedby(src)
			return TRUE
		stop_pulling()

	if(pulled_atom.pulledby)
		add_attack_logs(pulled_atom, pulled_atom.pulledby, "pulled from", ATKLOG_ALMOSTALL)
		pulled_atom.pulledby.stop_pulling() //an object can't be pulled by two mobs at once.
	pulling = pulled_atom
	pulled_atom.set_pulledby(src)
	SEND_SIGNAL(src, COMSIG_ATOM_START_PULL, pulled_atom, state, force)
	setGrabState(state)
	if(ismob(pulled_atom))
		var/mob/pulled_mob = pulled_atom
		add_attack_logs(src, pulled_mob, "passively grabbed", ATKLOG_ALMOSTALL)
		if(!supress_message)
			pulled_mob.visible_message(
				span_warning("[src] схватил[genderize_ru(gender,"","а","о","и")] [pulled_mob]!"),
				span_warning("[src] схватил[genderize_ru(gender,"","а","о","и")] Вас!"),
			)
		pulled_mob.LAssailant = iscarbon(src) ? src : null
	return TRUE


/atom/movable/proc/stop_pulling()
	if(!pulling)
		return
	pulling.set_pulledby(null)
	setGrabState(GRAB_PASSIVE)
	var/atom/movable/old_pulling = pulling
	pulling = null
	SEND_SIGNAL(old_pulling, COMSIG_ATOM_NO_LONGER_PULLED, src)
	SEND_SIGNAL(src, COMSIG_ATOM_NO_LONGER_PULLING, old_pulling)


///Reports the event of the change in value of the pulledby variable.
/atom/movable/proc/set_pulledby(new_pulledby)
	if(new_pulledby == pulledby)
		return FALSE //null signals there was a change, be sure to return FALSE if none happened here.
	. = pulledby
	pulledby = new_pulledby


/// Moves pulled thing to pull_loc with all the necessary checks.
/atom/movable/proc/Move_Pulled(atom/pull_loc)
	if(!pulling)
		return FALSE
	if(pulling.anchored || pulling.move_resist > move_force || !pulling.Adjacent(src, src, pulling))
		stop_pulling()
		return FALSE
	if(isliving(pulling))
		var/mob/living/pulling_mob = pulling
		if(pulling_mob.buckled && pulling_mob.buckled.buckle_prevents_pull) //if they're buckled to something that disallows pulling, prevent it
			stop_pulling()
			return FALSE
	var/move_dir = get_dir(pulling.loc, pull_loc)
	if(pulling.density && (pull_loc == loc || pull_loc == get_step(src, move_dir)))
		return FALSE
	if(!Process_Spacemove(move_dir))
		return FALSE
	var/turf/pull_turf = get_step(pulling.loc, move_dir)
	if(!pull_turf || pull_turf.density)
		return FALSE
	if(ismob(src))
		var/mob/mob = src
		mob.changeNext_move(CLICK_CD_PULLING)
	return pulling.Move(pull_turf, move_dir, glide_size)


/**
 * Checks if the pulling and pulledby should be stopped because they're out of reach.
 * If z_allowed is TRUE, the z level of the pulling will be ignored.This is to allow things to be dragged up and down stairs.
 */
/atom/movable/proc/check_pulling(only_pulling = FALSE, z_allowed = FALSE)
	if(pulling)
		if(!in_range(src, pulling) || (z != pulling.z && !z_allowed))
			stop_pulling()
		else if(!isturf(loc))
			stop_pulling()
		else if(pulling && !isturf(pulling.loc) && pulling.loc != loc) //to be removed once all code that changes an object's loc uses forceMove().
			log_debug("[src]'s pull on [pulling] wasn't broken despite [pulling] being in [pulling.loc]. Pull stopped manually.")
			stop_pulling()
		else if(pulling.anchored || pulling.move_resist > move_force)
			stop_pulling()
	if(!only_pulling && pulledby && moving_diagonally != FIRST_DIAG_STEP && (!in_range(src, pulledby) || (z != pulledby.z && !z_allowed))) //separated from our puller and not in the middle of a diagonal move.
		pulledby.stop_pulling()


/atom/movable/proc/can_be_pulled(atom/movable/puller, grab_state, force, supress_message)
	if(src == puller || !isturf(loc))
		return FALSE
	if(SEND_SIGNAL(src, COMSIG_ATOM_CAN_BE_PULLED, puller) & COMSIG_ATOM_CANT_PULL)
		return FALSE
	if(anchored)
		if(!supress_message && ismob(puller))
			to_chat(puller, span_warning("Похоже, [name] прикрепл[genderize_ru(src.gender,"ён","ена","ено","ены")] к полу!"))
		return FALSE
	if(throwing || move_resist == INFINITY)
		return FALSE
	if(force < (move_resist * MOVE_FORCE_PULL_RATIO))
		if(!supress_message && ismob(puller))
			to_chat(puller, span_warning("[name] слишком тяжел[genderize_ru(src.gender,"ый","ая","ое","ые")]!"))
		return FALSE
	return TRUE


/**
 * Updates the grab state of the movable
 *
 * This exists to act as a hook for behaviour
 */
/atom/movable/proc/setGrabState(newstate)
	if(newstate == grab_state)
		return
	SEND_SIGNAL(src, COMSIG_MOVABLE_SET_GRAB_STATE, newstate)
	. = grab_state
	grab_state = newstate
	switch(grab_state) // Current state.
		if(GRAB_PASSIVE)
			pulling.remove_traits(list(TRAIT_IMMOBILIZED, TRAIT_HANDS_BLOCKED), CHOKEHOLD_TRAIT)
			if(. >= GRAB_KILL) // Previous state was a kill grab.
				REMOVE_TRAIT(pulling, TRAIT_FLOORED, CHOKEHOLD_TRAIT)
		if(GRAB_AGGRESSIVE)
			if(. >= GRAB_KILL) // Grab got downgraded from kill grab.
				REMOVE_TRAIT(pulling, TRAIT_FLOORED, CHOKEHOLD_TRAIT)
			else if(. <= GRAB_PASSIVE) // Grab got upgraded from a passive one.
				pulling.add_traits(list(TRAIT_IMMOBILIZED, TRAIT_HANDS_BLOCKED), CHOKEHOLD_TRAIT)
		if(GRAB_NECK)
			if(. >= GRAB_KILL) // Grab got downgraded from kill grab.
				REMOVE_TRAIT(pulling, TRAIT_FLOORED, CHOKEHOLD_TRAIT)
		if(GRAB_KILL)
			if(. <= GRAB_KILL)	// Grab got ugraded from neck grab.
				ADD_TRAIT(pulling, TRAIT_FLOORED, CHOKEHOLD_TRAIT)


/// Use this to override topmost bump thing in [/turf/proc/Enter()].
/// Should return an atom to bump.
/atom/movable/proc/tompost_bump_override(atom/movable/mover, border_dir)
	return


// Used in shuttle movement and AI eye stuff.
// Primarily used to notify objects being moved by a shuttle/bluespace fuckup.
/atom/movable/proc/setLoc(turf/destination, force_update = FALSE)
	loc = destination


/atom/movable/proc/set_glide_size(target = DEFAULT_GLIDE_SIZE)
	if(HAS_TRAIT(src, TRAIT_NO_GLIDE))
		glide_size = DEFAULT_GLIDE_SIZE
		return
	SEND_SIGNAL(src, COMSIG_MOVABLE_UPDATE_GLIDE_SIZE, target)
	glide_size = target

	for(var/mob/buckled_mob as anything in buckled_mobs)
		buckled_mob.set_glide_size(target)

	// we update glide size for pulled things like this to make it extra smooth
	if(pulling && !pulling.pulling_glidesize_update && !LAZYIN(buckled_mobs, pulling))
		pulling.pulling_glidesize_update = TRUE
		pulling.set_glide_size(target)
		pulling.pulling_glidesize_update = FALSE

	// corrects glide size for the movable our pullee is buckled onto
	if(ismob(pulling))
		var/mob/mob_pulling = pulling
		if(mob_pulling.buckled && mob_pulling.buckled != src && !mob_pulling.buckled.pulling_glidesize_update)
			mob_pulling.buckled.pulling_glidesize_update = TRUE
			mob_pulling.buckled.set_glide_size(target)
			mob_pulling.buckled.pulling_glidesize_update = FALSE


/**
 * meant for movement with zero side effects. only use for objects that are supposed to move "invisibly" (like camera mobs or ghosts)
 * if you want something to move onto a tile with a beartrap or recycler or tripmine or mouse without that object knowing about it at all, use this
 * most of the time you want forceMove()
 */
/atom/movable/proc/abstract_move(atom/new_loc)
	RESOLVE_ACTIVE_MOVEMENT // This should NEVER happen, but, just in case...
	var/atom/old_loc = loc
	var/direction = get_dir(old_loc, new_loc)
	loc = new_loc
	Moved(old_loc, direction, TRUE, momentum_change = FALSE)


////////////////////////////////////////
// Here's where we rewrite how byond handles movement except slightly different
// To be removed on step_ conversion
// All this work to prevent a second bump
/atom/movable/Move(atom/newloc, direct, glide_size_override = 0, update_dir = TRUE)
	. = FALSE
	if(!newloc || newloc == loc)
		return .

	// A mid-movement... movement... occured, resolve that first.
	RESOLVE_ACTIVE_MOVEMENT

	if(!direct)
		direct = get_dir(src, newloc)

	if(set_dir_on_move && dir != direct && update_dir)
		setDir(direct)

	var/is_multi_tile = is_multi_tile_object(src)

	var/list/old_locs
	if(is_multi_tile && isturf(loc))
		old_locs = locs // locs is a special list, this is effectively the same as .Copy() but with less steps
		for(var/atom/exiting_loc as anything in old_locs)
			if(!exiting_loc.Exit(src, newloc))
				return .
	else
		if(!loc.Exit(src, newloc))
			return .

	var/list/new_locs
	if(is_multi_tile && isturf(newloc))
		new_locs = block(
			newloc.x,
			newloc.y,
			newloc.z,
			min(world.maxx, newloc.x + (CEILING(bound_width / world.icon_size, 1) - 1)),
			min(world.maxy, newloc.y + (CEILING(bound_height / world.icon_size, 1) - 1)),
			newloc.z
		)	// If this is a multi-tile object then we need to predict the new locs and check if they allow our entrance.
		for(var/atom/entering_loc as anything in new_locs)
			if(!entering_loc.Enter(src))
				return .
			if(SEND_SIGNAL(src, COMSIG_MOVABLE_PRE_MOVE, entering_loc) & COMPONENT_MOVABLE_BLOCK_PRE_MOVE)
				return .
	else // Else just try to enter the single destination.
		if(!newloc.Enter(src))
			return .
		if(SEND_SIGNAL(src, COMSIG_MOVABLE_PRE_MOVE, newloc) & COMPONENT_MOVABLE_BLOCK_PRE_MOVE)
			return .

	// Past this is the point of no return
	var/atom/oldloc = loc
	var/area/oldarea = get_area(oldloc)
	var/area/newarea = get_area(newloc)

	SET_ACTIVE_MOVEMENT(oldloc, direct, FALSE, old_locs)
	loc = newloc

	. = TRUE

	if(old_locs) // This condition will only be true if it is a multi-tile object.
		for(var/atom/exited_loc as anything in (old_locs - new_locs))
			exited_loc.Exited(src, newloc)
	else // Else there's just one loc to be exited.
		oldloc.Exited(src, newloc)
	if(oldarea != newarea)
		oldarea.Exited(src, newarea)

	if(new_locs) // Same here, only if multi-tile.
		for(var/atom/entered_loc as anything in (new_locs - old_locs))
			entered_loc.Entered(src, oldloc, old_locs)
	else
		newloc.Entered(src, oldloc, old_locs)
	if(oldarea != newarea)
		newarea.Entered(src, oldarea)

	RESOLVE_ACTIVE_MOVEMENT


/atom/movable/Move(atom/newloc, direct = NONE, glide_size_override = 0, update_dir = TRUE)
	var/atom/movable/pullee = pulling
	var/turf/current_turf = loc
	if(!moving_from_pull)
		check_pulling(z_allowed = TRUE)

	if(!loc || !newloc)
		return FALSE

	var/atom/oldloc = loc

	//Early override for some cases like diagonal movement
	if(glide_size_override && glide_size != glide_size_override)
		set_glide_size(glide_size_override)

	if(loc != newloc)
		if(!ISDIAGONALDIR(direct)) //Cardinal move
			. = ..()
		else //Diagonal move, split it into cardinal moves
			moving_diagonally = FIRST_DIAG_STEP
			var/first_step_dir
			// The `&& moving_diagonally` checks are so that a forceMove taking
			// place due to a Crossed, Bumped, etc. call will interrupt
			// the second half of the diagonal movement, or the second attempt
			// at a first half if the cardinal Move() fails because we hit something.
			if(direct & NORTH)
				if(direct & EAST)
					if(Move(get_step(src, NORTH), NORTH) && moving_diagonally)
						first_step_dir = NORTH
						moving_diagonally = SECOND_DIAG_STEP
						. = Move(get_step(src, EAST), EAST)
					else if(moving_diagonally && Move(get_step(src,  EAST),  EAST))
						first_step_dir = EAST
						moving_diagonally = SECOND_DIAG_STEP
						. = Move(get_step(src, NORTH), NORTH)

				else if(direct & WEST)
					if(Move(get_step(src, NORTH), NORTH) && moving_diagonally)
						first_step_dir = NORTH
						moving_diagonally = SECOND_DIAG_STEP
						. = Move(get_step(src, WEST), WEST)
					else if(moving_diagonally && Move(get_step(src,  WEST),  WEST))
						first_step_dir = WEST
						moving_diagonally = SECOND_DIAG_STEP
						. = Move(get_step(src, NORTH), NORTH)

			else if(direct & SOUTH)
				if(direct & EAST)
					if(Move(get_step(src, SOUTH), SOUTH) && moving_diagonally)
						first_step_dir = SOUTH
						moving_diagonally = SECOND_DIAG_STEP
						. = Move(get_step(src, EAST), EAST)
					else if(moving_diagonally && Move(get_step(src,  EAST),  EAST))
						first_step_dir = EAST
						moving_diagonally = SECOND_DIAG_STEP
						. = Move(get_step(src, SOUTH), SOUTH)

				else if(direct & WEST)
					if(Move(get_step(src, SOUTH), SOUTH) && moving_diagonally)
						first_step_dir = SOUTH
						moving_diagonally = SECOND_DIAG_STEP
						. = Move(get_step(src, WEST), WEST)
					else if(moving_diagonally && Move(get_step(src,  WEST),  WEST))
						first_step_dir = WEST
						moving_diagonally = SECOND_DIAG_STEP
						. = Move(get_step(src, SOUTH), SOUTH)

			if(moving_diagonally == SECOND_DIAG_STEP)
				if(!. && set_dir_on_move && update_dir)
					setDir(first_step_dir)
				else if(!inertia_moving)
					newtonian_move(direct)
				if(client_mobs_in_contents) // We're done moving, update our parallax now
					update_parallax_contents()
			moving_diagonally = NONE
			return .

	if(!loc || (loc == oldloc && oldloc != newloc))
		last_move = NONE
		set_currently_z_moving(FALSE, TRUE)
		return .

	//we were pulling a thing and didn't lose it during our move.
	if(. && pulling && pulling == pullee && pulling != moving_from_pull)
		if(pulling.anchored)
			stop_pulling()
		else
			// Puller and pullee more than one tile away or in diagonal position and whatever the pullee is pulling
			// isn't already moving from a pull as it'll most likely result in an infinite loop a la ouroborus.
			if(!pulling.pulling?.moving_from_pull)
				var/pull_dir = get_dir(pulling, src)
				var/target_turf = grab_state < GRAB_NECK ? current_turf : loc

				// Pulling things down/up stairs. zMove() has flags for check_pulling and stop_pulling calls.
				// You may wonder why we're not just forcemoving the pulling movable and regrabbing it.
				// The answer is simple. forcemoving and regrabbing is ugly and breaks conga lines.
				if(pulling.z != z)
					target_turf = get_step(pulling, get_dir(pulling, current_turf))

				var/range_check = grab_state < GRAB_NECK ? !in_range(src, pulling) : pulling.loc != loc
				if(range_check || target_turf != current_turf || (moving_diagonally != SECOND_DIAG_STEP && ISDIAGONALDIR(pull_dir)))
					pulling.move_from_pull(src, target_turf, glide_size)
			if(pulledby)
				if(pulledby.currently_z_moving)
					check_pulling(z_allowed = TRUE)
				//dont call check_pulling() here at all if there is a pulledby that is not currently z moving
				//because it breaks stair conga lines, for some fucking reason.
				//it's fine because the pull will be checked when this whole proc is called by the mob doing the pulling anyways
			else
				check_pulling()

	// glide_size strangely enough can change mid movement animation and update correctly while the animation is playing
	// This means that if you don't override it late like this, it will just be set back
	// by the movement update that's called when you move turfs.
	if(glide_size_override)
		set_glide_size(glide_size_override)

	last_move = direct
	move_speed = world.time - l_move_time
	l_move_time = world.time

	if(set_dir_on_move && dir != direct && update_dir)
		setDir(direct)

	// movement failed due to buckled mob(s)
	if(. && has_buckled_mobs() && !handle_buckled_mob_movement(loc, direct, glide_size_override))
		. = FALSE

	if(currently_z_moving)
		if(. && loc == newloc)
			var/turf/pitfall = get_turf(src)
			pitfall.zFall(src, falling_from_move = TRUE)
		else
			set_currently_z_moving(FALSE, TRUE)


/// Called when src is being moved to a target turf because another movable (puller) is moving around.
/atom/movable/proc/move_from_pull(atom/movable/puller, turf/target_turf, glide_size_override)
	moving_from_pull = puller
	Move(target_turf, get_dir(src, target_turf))
	moving_from_pull = null


/**
 * Called after a successful Move(). By this point, we've already moved.
 * Arguments:
 * * old_loc is the location prior to the move. Can be null to indicate nullspace.
 * * movement_dir is the direction the movement took place. Can be NONE if it was some sort of teleport.
 * * The forced flag indicates whether this was a forced move, which skips many checks of regular movement.
 * * The old_locs is an optional argument, in case the moved movable was present in multiple locations before the movement.
 * * momentum_change represents whether this movement is due to a "new" force if TRUE or an already "existing" force if FALSE
 **/
/atom/movable/proc/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	SHOULD_CALL_PARENT(TRUE)

	if(!inertia_moving && momentum_change)
		newtonian_move(movement_dir)
	// If we ain't moving diagonally right now, update our parallax
	// We don't do this all the time because diag movements should trigger one call to this, not two
	// Waste of cpu time, and it fucks the animate
	if(!moving_diagonally && client_mobs_in_contents)
		update_parallax_contents()

	SEND_SIGNAL(src, COMSIG_MOVABLE_MOVED, old_loc, movement_dir, forced, old_locs, momentum_change)

	if(old_loc)
		SEND_SIGNAL(old_loc, COMSIG_ATOM_ABSTRACT_EXITED, src, movement_dir)
	if(loc)
		SEND_SIGNAL(loc, COMSIG_ATOM_ABSTRACT_ENTERED, src, old_loc, old_locs)

	var/turf/old_turf = get_turf(old_loc)
	var/turf/new_turf = get_turf(src)

	if(old_turf?.z != new_turf?.z)
		var/same_z_layer = (GET_TURF_PLANE_OFFSET(old_turf) == GET_TURF_PLANE_OFFSET(new_turf))
		on_changed_z_level(old_turf, new_turf, same_z_layer)

	for (var/datum/light_source/light as anything in light_sources) // Cycle through the light sources on this atom and tell them to update.
		light.source_atom.update_light()

	SSdemo.mark_dirty(src)
	return TRUE


/**
 * Make sure you know what you're doing if you call this.
 * You probably want CanPass()
 */
/atom/movable/Cross(atom/movable/crossed_atom, border_dir)
	. = TRUE
	SEND_SIGNAL(src, COMSIG_MOVABLE_CROSS, crossed_atom, border_dir)
	SEND_SIGNAL(crossed_atom, COMSIG_MOVABLE_CROSS_OVER, src, border_dir)
	return CanPass(crossed_atom, border_dir)


/// Default byond proc that is deprecated for us in lieu of signals, do not call
/atom/movable/Crossed()
	SHOULD_NOT_OVERRIDE(TRUE)
	CRASH("atom/movable/Crossed() was called!")


/**
 * `Uncross()` is a default BYOND proc that is called when something is *going*
 * to exit this atom's turf. It is prefered over `Uncrossed` when you want to
 * deny that movement, such as in the case of border objects, objects that allow
 * you to walk through them in any direction except the one they block
 * (think side windows).
 *
 * While being seemingly harmless, most everything doesn't actually want to
 * use this, meaning that we are wasting proc calls for every single atom
 * on a turf, every single time something exits it, when basically nothing
 * cares.
 *
 * If you want to replicate the old `Uncross()` behavior, the most apt
 * replacement is [`/datum/element/connect_loc`] while hooking onto
 * [`COMSIG_ATOM_EXIT`].
 */
/atom/movable/Uncross()
	SHOULD_NOT_OVERRIDE(TRUE)
	CRASH("Uncross() should not be being called, please read the doc-comment for it if you wonder why.")


/**
 * default byond proc that is normally called on everything inside the previous turf
 * a movable was in after moving to its current turf
 * this is wasteful since the vast majority of objects do not use Uncrossed
 * use connect_loc to register to COMSIG_ATOM_EXITED instead
 */
/atom/movable/Uncrossed()
	SHOULD_NOT_OVERRIDE(TRUE)
	CRASH("/atom/movable/Uncrossed() was called!")


/atom/movable/Bump(atom/bumped_atom)
	if(!bumped_atom)
		CRASH("Bump was called with no argument.")
	SEND_SIGNAL(src, COMSIG_MOVABLE_BUMP, bumped_atom)
	. = ..()
	if(!QDELETED(throwing))
		throwing.finalize(bumped_atom)
		. = TRUE
		if(QDELETED(bumped_atom))
			return .
	bumped_atom.Bumped(src)


/// Sets the currently_z_moving variable to a new value. Used to allow some zMovement sources to have precedence over others.
/atom/movable/proc/set_currently_z_moving(new_z_moving_value, forced = FALSE)
	if(forced)
		currently_z_moving = new_z_moving_value
		return TRUE
	var/old_z_moving_value = currently_z_moving
	currently_z_moving = max(currently_z_moving, new_z_moving_value)
	return (currently_z_moving > old_z_moving_value)


/atom/movable/proc/move_to_null_space()
	return doMove(null)


/atom/movable/proc/forceMove(atom/destination)
	. = FALSE
	if(destination)
		. = doMove(destination)
	else
		CRASH("No valid destination passed into forceMove")


/atom/movable/proc/doMove(atom/destination)
	. = FALSE
	RESOLVE_ACTIVE_MOVEMENT

	var/atom/oldloc = loc
	var/is_multi_tile = is_multi_tile_object(src)

	SET_ACTIVE_MOVEMENT(oldloc, NONE, TRUE, null)

	if(destination)
		///zMove already handles whether a pull from another movable should be broken.
		if(pulledby && !currently_z_moving)
			pulledby.stop_pulling()

		var/same_loc = oldloc == destination
		var/area/old_area = get_area(oldloc)
		var/area/destarea = get_area(destination)

		moving_diagonally = NONE

		loc = destination

		if(!same_loc)
			if(is_multi_tile && isturf(destination))
				var/list/new_locs = block(
					destination.x,
					destination.y,
					destination.z,
					min(world.maxx, destination.x + (CEILING(bound_width / world.icon_size, 1) - 1)),
					min(world.maxy, destination.y + (CEILING(bound_height / world.icon_size, 1) - 1)),
					destination.z
				)
				if(old_area && old_area != destarea)
					old_area.Exited(src, destarea)
				for(var/atom/left_loc as anything in (locs - new_locs))
					left_loc.Exited(src, destination)

				for(var/atom/entering_loc as anything in (new_locs - locs))
					entering_loc.Entered(src, oldloc)
				if(old_area && old_area != destarea)
					destarea.Entered(src, old_area)
			else
				if(oldloc)
					oldloc.Exited(src, destination)
					if(old_area && old_area != destarea)
						old_area.Exited(src, destarea)
				destination.Entered(src, oldloc)
				if(destarea && old_area != destarea)
					destarea.Entered(src, old_area)


		. = TRUE

	//If no destination, move the atom into nullspace (don't do this unless you know what you're doing)
	else
		. = TRUE

		if(oldloc)
			loc = null
			var/area/old_area = get_area(oldloc)
			if(is_multi_tile && isturf(oldloc))
				for(var/atom/old_loc as anything in locs)
					old_loc.Exited(src, null)
			else
				oldloc.Exited(src, null)

			if(old_area)
				old_area.Exited(src, null)

	RESOLVE_ACTIVE_MOVEMENT


/atom/movable/proc/onZImpact(turf/impacted_turf, levels, impact_flags = TRUE)
	SHOULD_CALL_PARENT(TRUE)

	if(isliving(src))
		add_attack_logs(src, src, "crashed into [impacted_turf] from [levels] level(s) up.")
	if(!(impact_flags & ZIMPACT_NO_MESSAGE))
		visible_message(span_danger("[src] crashes into [impacted_turf]!"), span_userdanger("You crash into [impacted_turf]!"))
	if(!(impact_flags & ZIMPACT_NO_SPIN))
		INVOKE_ASYNC(src, PROC_REF(SpinAnimation), 5, 2)
	SEND_SIGNAL(src, COMSIG_ATOM_ON_Z_IMPACT, impacted_turf, levels)
	return TRUE

/*
 * The core multi-z movement proc. Used to move a movable through z levels.
 * If target is null, it'll be determined by the can_z_move proc, which can potentially return null if
 * conditions aren't met (see z_move_flags defines in __DEFINES/movement.dm for info) or if dir isn't set.
 * Bear in mind you don't need to set both target and dir when calling this proc, but at least one or two.
 * This will set the currently_z_moving to CURRENTLY_Z_MOVING_GENERIC if unset, and then clear it after
 * Forcemove().
 *
 *
 * Args:
 * * dir: the direction to go, UP or DOWN, only relevant if target is null.
 * * target: The target turf to move the src to. Set by can_z_move() if null.
 * * z_move_flags: bitflags used for various checks in both this proc and can_z_move(). See __DEFINES/movement.dm.
 */
/atom/movable/proc/zMove(dir, turf/target, z_move_flags = ZMOVE_FLIGHT_FLAGS)
	if(!target)
		target = can_z_move(dir, get_turf(src), null, z_move_flags)
		if(!target)
			set_currently_z_moving(FALSE, TRUE)
			return FALSE

	var/list/moving_movs = get_z_move_affected(z_move_flags)

	for(var/atom/movable/movable as anything in moving_movs)
		movable.currently_z_moving = currently_z_moving || CURRENTLY_Z_MOVING_GENERIC
		movable.forceMove(target)
		movable.set_currently_z_moving(FALSE, TRUE)
	// This is run after ALL movables have been moved, so pulls don't get broken unless they are actually out of range.
	if(z_move_flags & ZMOVE_CHECK_PULLS)
		for(var/atom/movable/moved_mov as anything in moving_movs)
			if(z_move_flags & ZMOVE_CHECK_PULLEDBY && moved_mov.pulledby && (moved_mov.z != moved_mov.pulledby.z || get_dist(moved_mov, moved_mov.pulledby) > 1))
				moved_mov.pulledby.stop_pulling()
			if(z_move_flags & ZMOVE_CHECK_PULLING)
				moved_mov.check_pulling(TRUE)
	return TRUE


/// Returns a list of movables that should also be affected when src moves through zlevels, and src.
/atom/movable/proc/get_z_move_affected(z_move_flags)
	. = list(src)
	if(buckled_mobs)
		. |= buckled_mobs
	if(!(z_move_flags & ZMOVE_INCLUDE_PULLED))
		return .
	for(var/mob/living/buckled as anything in buckled_mobs)
		if(buckled.pulling)
			. |= buckled.pulling
	if(pulling)
		. |= pulling
		if(pulling.buckled_mobs)
			. |= pulling.buckled_mobs

		//makes conga lines work with ladders and flying up and down; checks if the guy you are pulling is pulling someone,
		//then uses recursion to run the same function again
		if(pulling.pulling)
			. |= pulling.pulling.get_z_move_affected(z_move_flags)


/**
 * Checks if the destination turf is elegible for z movement from the start turf to a given direction and returns it if so.
 * Args:
 * * direction: the direction to go, UP or DOWN, only relevant if target is null.
 * * start: Each destination has a starting point on the other end. This is it. Most of the times the location of the source.
 * * z_move_flags: bitflags used for various checks. See __DEFINES/movement.dm.
 * * rider: A living mob in control of the movable. Only non-null when a mob is riding a vehicle through z-levels.
 */
/atom/movable/proc/can_z_move(direction, turf/start, turf/destination, z_move_flags = ZMOVE_FLIGHT_FLAGS, mob/living/rider)
	if(!start)
		start = get_turf(src)
		if(!start)
			return FALSE
	if(!direction)
		if(!destination)
			return FALSE
		direction = get_dir_multiz(start, destination)
	if(direction != UP && direction != DOWN)
		return FALSE
	if(!destination)
		destination = get_step_multiz(start, direction)
		if(!destination)
			if(z_move_flags & ZMOVE_FEEDBACK)
				to_chat(rider || src, span_warning("There's nowhere to go in that direction!"))
			return FALSE
	if(z_move_flags & ZMOVE_FALL_CHECKS && (throwing || (movement_type & (FLYING|FLOATING)) || !has_gravity(start)))
		return FALSE
	if(z_move_flags & ZMOVE_CAN_FLY_CHECKS && !(movement_type & (FLYING|FLOATING)) && has_gravity(start))
		if(z_move_flags & ZMOVE_FEEDBACK)
			if(rider)
				to_chat(rider, span_notice("[src] is not capable of flight."))
			else
				to_chat(src, span_notice("You are not Superman."))
		return FALSE
	if((!(z_move_flags & ZMOVE_IGNORE_OBSTACLES) && !(start.zPassOut(direction) && destination.zPassIn(direction))) || (!(z_move_flags & ZMOVE_ALLOW_ANCHORED) && anchored))
		if(z_move_flags & ZMOVE_FEEDBACK)
			to_chat(rider || src, span_warning("You couldn't move there!"))
		return FALSE
	return destination //used by some child types checks and zMove()

/**
 * Called when a movable changes z-levels.
 *
 * Arguments:
 * * old_turf - The previous turf they were on before.
 * * new_turf - The turf they have now entered.
 * * same_z_layer - If their old and new z levels are on the same level of plane offsets or not
 * * notify_contents - Whether or not to notify the movable's contents that their z-level has changed. NOTE, IF YOU SET THIS, YOU NEED TO MANUALLY SET PLANE OF THE CONTENTS LATER
 */
/atom/movable/proc/on_changed_z_level(turf/old_turf, turf/new_turf, same_z_layer, notify_contents = TRUE)
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(src, COMSIG_MOVABLE_Z_CHANGED, old_turf, new_turf, same_z_layer)

	// If our turfs are on different z "layers", recalc our planes
	if(!same_z_layer && !QDELETED(src))
		SET_PLANE(src, PLANE_TO_TRUE(src.plane), new_turf)
		// a TON of overlays use planes, and thus require offsets
		// so we do this. sucks to suck
		update_appearance()

		if(update_on_z)
			// I so much wish this could be somewhere else. alas, no.
			for(var/image/update as anything in update_on_z)
				SET_PLANE(update, PLANE_TO_TRUE(update.plane), new_turf)
		if(update_overlays_on_z)
			// This EVEN more so
			cut_overlay(update_overlays_on_z)
			// This even more so
			for(var/mutable_appearance/update in update_overlays_on_z)
				SET_PLANE(update, PLANE_TO_TRUE(update.plane), new_turf)
			add_overlay(update_overlays_on_z)

	if(!notify_contents)
		return

	for (var/atom/movable/content as anything in src) // Notify contents of Z-transition.
		content.on_changed_z_level(old_turf, new_turf, same_z_layer)



/**
 * Called whenever an object moves and by mobs when they attempt to move themselves through space
 * And when an object or action applies a force on src, see [newtonian_move][/atom/movable/proc/newtonian_move]
 *
 * Return FALSE to have src start/keep drifting in a no-grav area and TRUE to stop/not start drifting
 *
 * Mobs should return `TRUE` if they should be able to move of their own volition, see [/client/proc/Move]
 *
 * Arguments:
 * * movement_dir - NONE when stopping or any dir when trying to move
 * * continuous_move - If this check is coming from something in the context of already drifting
 */
/atom/movable/proc/Process_Spacemove(movement_dir = NONE, continuous_move = FALSE)
	if(has_gravity())
		return TRUE

	if(SEND_SIGNAL(src, COMSIG_MOVABLE_SPACEMOVE, movement_dir, continuous_move) & COMSIG_MOVABLE_STOP_SPACEMOVE)
		return TRUE

	if(pulledby && (pulledby.pulledby != src || moving_from_pull))
		return TRUE

	if(throwing)
		return TRUE

	if(!isturf(loc))
		return TRUE

	if(locate(/obj/structure/lattice) in range(1, get_turf(src))) //Not realistic but makes pushing things in space easier
		return TRUE

	return FALSE


/// Only moves the object if it's under no gravity
/// Accepts the direction to move, if the push should be instant, and an optional parameter to fine tune the start delay
/atom/movable/proc/newtonian_move(direction, instant = FALSE, start_delay = 0)
	if(QDELETED(src) || !isturf(loc) || anchored || Process_Spacemove(direction, continuous_move = TRUE))
		return FALSE

	if(SEND_SIGNAL(src, COMSIG_MOVABLE_NEWTONIAN_MOVE, direction, start_delay) & COMPONENT_MOVABLE_NEWTONIAN_BLOCK)
		return TRUE

	AddComponent(/datum/component/drift, direction, instant, start_delay)

	return TRUE


//called when src is thrown into hit_atom
/atom/movable/proc/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	set waitfor = FALSE
	SEND_SIGNAL(src, COMSIG_MOVABLE_IMPACT, hit_atom, throwingdatum)
	if(!QDELETED(hit_atom))
		return hit_atom.hitby(src, throwingdatum = throwingdatum)


/// called after an items throw is ended.
/atom/movable/proc/end_throw()
	return


/atom/movable/hitby(atom/movable/AM, skipcatch, hitpush = TRUE, blocked, datum/thrownthing/throwingdatum)
	if(!anchored && hitpush && (!throwingdatum || (throwingdatum.force >= (move_resist * MOVE_FORCE_PUSH_RATIO))))
		step(src, AM.dir)
	..()


/atom/movable/proc/throw_at(atom/target, range, speed, mob/thrower, spin = TRUE, diagonals_first = FALSE, datum/callback/callback, force = INFINITY, dodgeable = TRUE)
	if(throwing || !target || HAS_TRAIT(src, TRAIT_NODROP) || speed <= 0)
		return FALSE

	pulledby?.stop_pulling()

	// They are moving! Wouldn't it be cool if we calculated their momentum and added it to the throw?
	if(istype(thrower) && thrower.last_move && thrower.client && thrower.client.move_delay >= world.time + world.tick_lag * 2)
		var/user_momentum = thrower.cached_multiplicative_slowdown
		if(!user_momentum) // no movement_delay, this means they move once per byond tick, let's calculate from that instead
			user_momentum = world.tick_lag

		user_momentum = 1 / user_momentum // convert from ds to the tiles per ds that throw_at uses

		if(get_dir(thrower, target) & last_move)
			user_momentum = user_momentum // basically a noop, but needed
		else if(get_dir(target, thrower) & last_move)
			user_momentum = -user_momentum // we are moving away from the target, lets slowdown the throw accordingly
		else
			user_momentum = 0

		if(user_momentum)
			// first lets add that momentum to range
			range *= (user_momentum / speed) + 1
			//then lets add it to speed
			speed += user_momentum
			if(speed <= 0)
				return //no throw speed, the user was moving too fast.

	var/datum/thrownthing/thrown_thing = new(src, target, get_dir(src, target), range, speed, thrower, diagonals_first, force, callback, istype(thrower) ? thrower.zone_selected : FALSE, dodgeable)

	var/dist_x = abs(target.x - src.x)
	var/dist_y = abs(target.y - src.y)
	var/dx = (target.x > src.x) ? EAST : WEST
	var/dy = (target.y > src.y) ? NORTH : SOUTH

	if(dist_x == dist_y)
		thrown_thing.pure_diagonal = TRUE

	else if(dist_x <= dist_y)
		var/olddist_x = dist_x
		var/olddx = dx
		dist_x = dist_y
		dist_y = olddist_x
		dx = dy
		dy = olddx
	thrown_thing.dist_x = dist_x
	thrown_thing.dist_y = dist_y
	thrown_thing.dx = dx
	thrown_thing.dy = dy
	thrown_thing.diagonal_error = dist_x/2 - dist_y
	thrown_thing.start_time = world.time

	throwing = thrown_thing
	if(spin && !no_spin_thrown)
		SpinAnimation(5, 1)

	SEND_SIGNAL(src, COMSIG_MOVABLE_POST_THROW, thrown_thing, spin)
	SSthrowing.processing[src] = thrown_thing
	thrown_thing.tick()

	return TRUE


//Overlays
/atom/movable/overlay
	var/atom/master = null
	anchored = TRUE
	simulated = FALSE


/atom/movable/overlay/Initialize(mapload, ...)
	. = ..()
	verbs.Cut()


/atom/movable/overlay/attackby(obj/item/I, mob/user, params)
	if(master)
		I.melee_attack_chain(user, master, params)
	return ATTACK_CHAIN_BLOCKED_ALL


/atom/movable/overlay/attack_hand(mob/user)
	if(master)
		return master.attack_hand(user)


/atom/movable/proc/handle_buckled_mob_movement(newloc, direct, glide_size_override)
	for(var/mob/living/buckled_mob as anything in buckled_mobs)
		if(!buckled_mob.Move(newloc, direct, glide_size_override)) //If a mob buckled to us can't make the same move as us
			Move(buckled_mob.loc, direct) //Move back to its location
			last_move = buckled_mob.last_move
			return FALSE
	return TRUE


/atom/movable/proc/force_pushed(atom/movable/pusher, force = MOVE_FORCE_DEFAULT, direction)
	return FALSE

/atom/movable/proc/force_push(atom/movable/AM, force = move_force, direction, silent = FALSE)
	. = AM.force_pushed(src, force, direction)
	if(!silent && .)
		visible_message(span_warning("[src] сильно толка[pluralize_ru(gender,"ет","ют")] [AM]!"), span_warning("Вы сильно толкаете [AM]!"))

/atom/movable/proc/move_crush(atom/movable/AM, force = move_force, direction, silent = FALSE)
	. = AM.move_crushed(src, force, direction)
	if(!silent && .)
		visible_message(span_danger("[src] сокруша[pluralize_ru(gender,"ет","ют")] [AM]!"), span_danger("Вы сокрушили [AM]!"))

/atom/movable/proc/move_crushed(atom/movable/pusher, force = MOVE_FORCE_DEFAULT, direction)
	return FALSE


/atom/movable/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(mover in buckled_mobs)
		return TRUE


/atom/movable/proc/get_spacemove_backup(moving_direction, continuous_move)
	for(var/checked_range in orange(1, get_turf(src)))
		if(isarea(checked_range))
			continue
		if(isturf(checked_range))
			var/turf/turf = checked_range
			if(!turf.density)
				continue
			return turf
		var/atom/movable/checked_atom = checked_range
		if(checked_atom.density || !checked_atom.CanPass(src, get_dir(src, checked_atom)))
			if(checked_atom.last_pushoff == world.time)
				continue
			return checked_atom


/atom/movable/proc/transfer_prints_to(atom/movable/target = null, overwrite = FALSE)
	if(!target)
		return
	if(overwrite)
		target.fingerprints = fingerprints
		target.fingerprintshidden = fingerprintshidden
	else
		target.fingerprints += fingerprints
		target.fingerprintshidden += fingerprintshidden
	target.fingerprintslast = fingerprintslast


/atom/movable/proc/do_attack_animation(atom/attacked_atom, visual_effect_icon, obj/item/used_item, no_effect)
	if(!no_effect && (visual_effect_icon || used_item))
		do_item_attack_animation(attacked_atom, visual_effect_icon, used_item)

	if(attacked_atom == src)
		return //don't do an animation if attacking self

	var/pixel_x_diff = 0
	var/pixel_y_diff = 0
	var/turn_dir = 1

	var/direction = get_dir(src, attacked_atom)
	if(direction & NORTH)
		pixel_y_diff = 8
		turn_dir = prob(50) ? -1 : 1
	else if(direction & SOUTH)
		pixel_y_diff = -8
		turn_dir = prob(50) ? -1 : 1

	if(direction & EAST)
		pixel_x_diff = 8
	else if(direction & WEST)
		pixel_x_diff = -8
		turn_dir = -1

	var/matrix/initial_transform = matrix(transform)
	var/matrix/rotated_transform = transform.Turn(15 * turn_dir)
	animate(src, pixel_x = pixel_x + pixel_x_diff, pixel_y = pixel_y + pixel_y_diff, transform = rotated_transform, time = 0.1 SECONDS, easing = (BACK_EASING|EASE_IN), flags = ANIMATION_PARALLEL)
	animate(pixel_x = pixel_x - pixel_x_diff, pixel_y = pixel_y - pixel_y_diff, transform = initial_transform, time = 0.2 SECONDS, easing = SINE_EASING, flags = ANIMATION_PARALLEL)


/atom/movable/proc/do_item_attack_animation(atom/attacked_atom, visual_effect_icon, obj/item/used_item)
	var/image/attack_image
	// we will register on turf to avoid image changes with attacked_atom transforms
	var/turf/image_loc = get_turf(attacked_atom)
	if(visual_effect_icon)
		attack_image = image('icons/effects/effects.dmi', image_loc, visual_effect_icon, attacked_atom.layer + 0.1)
		if(ismob(src) && ismob(attacked_atom))
			var/mob/attacker = src
			attack_image.color = attacker.a_intent == INTENT_HARM ? "#ff0000" : "#ffffff"
	else if(used_item)
		attack_image = image(icon = used_item, loc = image_loc, layer = attacked_atom.layer + 0.1)
		// Scale the icon.
		attack_image.transform *= 0.4
		// The icon should not rotate.
		attack_image.appearance_flags = APPEARANCE_UI

		// Set the direction of the icon animation.
		var/direction = get_dir(src, attacked_atom)
		if(direction & NORTH)
			attack_image.pixel_y = -12
		else if(direction & SOUTH)
			attack_image.pixel_y = 12

		if(direction & EAST)
			attack_image.pixel_x = -14
		else if(direction & WEST)
			attack_image.pixel_x = 14

		if(!direction) // Attacked self?!
			attack_image.pixel_y = 12
			attack_image.pixel_x = 5 * (prob(50) ? 1 : -1)

	if(!attack_image)
		return

	SET_PLANE(attack_image, attacked_atom.plane, image_loc)

	// Who can see the attack?
	var/list/viewing = list()
	for(var/mob/viewer in viewers(attacked_atom))
		if(viewer.client && (viewer.client.prefs.toggles2 & PREFTOGGLE_2_ITEMATTACK))
			viewing += viewer.client

	flick_overlay(attack_image, viewing, 0.7 SECONDS)
	var/matrix/initial_transform = new(transform)
	// And animate the attack!
	animate(attack_image, alpha = 175, transform = initial_transform.Scale(0.75), pixel_x = 0, pixel_y = 0, pixel_z = 0, time = 0.3 SECONDS)
	animate(time = 0.1 SECONDS)
	animate(alpha = 0, time = 0.3 SECONDS, easing = (CIRCULAR_EASING|EASE_OUT))


/atom/movable/proc/portal_destroyed(obj/effect/portal/P)
	return


/atom/movable/proc/decompile_act(obj/item/matter_decompiler/C, mob/user) // For drones to decompile mobs and objs. See drone for an example.
	return FALSE


/// Returns true or false to allow src to move through the blocker, mover has final say
/atom/movable/proc/CanPassThrough(atom/blocker, movement_dir, blocker_opinion)
	SHOULD_CALL_PARENT(TRUE)
	SHOULD_BE_PURE(TRUE)
	return blocker_opinion


///Sets the anchored var and returns if it was sucessfully changed or not.
/atom/movable/proc/set_anchored(anchorvalue)
	SHOULD_CALL_PARENT(TRUE)
	if(anchored == anchorvalue)
		return
	. = anchored
	anchored = anchorvalue
	if(anchored && pulledby)
		pulledby.stop_pulling()
	SEND_SIGNAL(src, COMSIG_MOVABLE_SET_ANCHORED, anchorvalue)


/atom/movable/set_opacity(new_opacity)
	. = ..()
	if(isnull(.) || !isturf(loc))
		return .
	if(opacity)
		AddElement(/datum/element/light_blocking)
	else
		RemoveElement(/datum/element/light_blocking)



/// Source is devoured by living mob.
/atom/movable/proc/devoured(mob/living/carbon/gourmet)
	if(!can_devour(gourmet))
		return FALSE

	var/mob/living/victim = src	// its just living mobs now, subject to change later

	var/target = isturf(loc) ? src : gourmet

	gourmet.setDir(get_dir(gourmet, src))
	gourmet.visible_message(span_danger("[gourmet.name] пыта[pluralize_ru(gourmet.gender,"ет","ют")]ся поглотить [name]!"))

	if(!do_after(gourmet, get_devour_time(gourmet), target, NONE, extra_checks = CALLBACK(src, PROC_REF(can_devour), gourmet), max_interact_count = 1, cancel_on_max = TRUE, cancel_message = span_notice("Вы прекращаете поглощать [name]!")))
		gourmet.visible_message(span_notice("[gourmet.name] прекраща[pluralize_ru(gourmet.gender,"ет","ют")] поглощать [name]!"))
		return FALSE

	gourmet.visible_message(span_danger("[gourmet.name] поглоща[pluralize_ru(gourmet.gender,"ет","ют")] [name]!"))

	if(victim.mind)
		add_attack_logs(gourmet, src, "Devoured")

	if(!isvampire(gourmet))
		gourmet.adjust_nutrition(2 * victim.health)

	for(var/datum/disease/virus/virus in victim.diseases)
		if(virus.spread_flags > NON_CONTAGIOUS)
			virus.Contract(gourmet)

	for(var/datum/disease/virus/virus in gourmet.diseases)
		if(virus.spread_flags > NON_CONTAGIOUS)
			virus.Contract(victim)

	victim.forceMove(gourmet)
	LAZYADD(gourmet.stomach_contents, victim)
	return TRUE


/// Does all the checking for the [/proc/devoured()] to see if a mob can eat another with the grab.
/atom/movable/proc/can_devour(mob/living/carbon/gourmet)
	if(isalienadult(gourmet))
		var/mob/living/carbon/alien/humanoid/alien = gourmet
		return alien.can_consume(src)
	if(ishuman(gourmet)) //species eating of other mobs
		return is_type_in_list(src, gourmet.dna.species.allowed_consumed_mobs)
	return FALSE


/// Returns the time devourer has to wait before they eat a prey.
/atom/movable/proc/get_devour_time(mob/living/carbon/gourmet)
	if(isalienadult(gourmet))
		var/mob/living/carbon/alien/humanoid/alien = gourmet
		return alien.devour_time
	if(isanimal(src))
		return DEVOUR_TIME_ANIMAL
	return DEVOUR_TIME_DEFAULT

/// called when a mob gets shoved into an items turf. false means the mob will be shoved backwards normally, true means the mob will not be moved by the disarm proc.
/atom/movable/proc/shove_impact(mob/living/target, mob/living/attacker)
	return FALSE


/**
* A wrapper for setDir that should only be able to fail by living mobs.
*
* Called from [/atom/movable/proc/keyLoop], this exists to be overwritten by living mobs with a check to see if we're actually alive enough to change directions
*/
/atom/movable/proc/keybind_face_direction(direction)
	setDir(direction)

