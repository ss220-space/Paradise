/atom/movable
	layer = OBJ_LAYER
	appearance_flags = TILE_BOUND|PIXEL_SCALE
	glide_size = 8 // Default, adjusted when mobs move based on their movement delays
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
	var/mob/pulledby = null
	var/atom/movable/pulling
	var/throwforce = 0
	var/canmove = TRUE
	var/pull_push_speed_modifier = 1

	///The last time we pushed off something
	///This is a hack to get around dumb him him me scenarios
	var/last_pushoff

	/// If false makes [CanPass][/atom/proc/CanPass] call [CanPassThrough][/atom/movable/proc/CanPassThrough] on this type instead of using default behaviour
	var/generic_canpass = TRUE

	var/inertia_dir = NONE
	var/atom/inertia_last_loc
	var/inertia_moving = FALSE
	var/inertia_next_move = 0
	var/inertia_move_delay = 5

	///Used for the calculate_adjacencies proc for icon smoothing.
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

	var/buckle_offset = 0	// will be removed later

	/**
	  * In case you have multiple types, you automatically use the most useful one.
	  * IE: Skating on ice, flippers on water, flying over chasm/space, etc.
	  * I reccomend you use the movetype_handler system and not modify this directly, especially for living mobs.
	  */
	var/movement_type = GROUND

	/// NONE:0 not doing a diagonal move. FIRST_DIAG_STEP:1 and SECOND_DIAG_STEP:2 doing the first/second step of the diagonal move.
	var/moving_diagonally = NONE
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


/atom/movable/Initialize(mapload)
	. = ..()
	switch(blocks_emissive)
		if(EMISSIVE_BLOCK_GENERIC)
			var/static/mutable_appearance/emissive_blocker/blocker = new
			blocker.icon = icon
			blocker.icon_state = icon_state
			blocker.dir = dir
			blocker.alpha = alpha
			blocker.appearance_flags |= appearance_flags
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

	switch(light_system)
		if(MOVABLE_LIGHT)
			AddComponent(/datum/component/overlay_lighting)
		if(MOVABLE_LIGHT_DIRECTIONAL)
			AddComponent(/datum/component/overlay_lighting, is_directional = TRUE)


/atom/movable/Destroy()
	unbuckle_all_mobs(force = TRUE)
	QDEL_NULL(em_block)

	. = ..()
	if(loc)
		loc.handle_atom_del(src)
	for(var/atom/movable/AM in contents)
		qdel(AM)
	LAZYCLEARLIST(client_mobs_in_contents)
	move_to_null_space()
	if(pulledby)
		pulledby.stop_pulling()
	if(orbiting)
		stop_orbit()


/atom/movable/get_emissive_block()
	switch(blocks_emissive)
		if(EMISSIVE_BLOCK_GENERIC)
			return fast_emissive_blocker(src)
		if(EMISSIVE_BLOCK_UNIQUE)
			if(!em_block && !QDELETED(src))
				render_target = ref(src)
				em_block = new(null, src)
			return em_block


//Returns an atom's power cell, if it has one. Overload for individual items.
/atom/movable/proc/get_cell()
	return

//Handles special effects on teleporting. Overload for some items if you want to do so.
/atom/movable/proc/on_teleported()
	return


/atom/movable/proc/start_pulling(atom/movable/AM, force = pull_force, show_message = FALSE)
	var/mob/mob_target = AM
	if(ismob(mob_target) && mob_target.buckled)
		AM = mob_target.buckled

	if(QDELETED(AM) || QDELETED(src))
		return FALSE
	if(!(AM.can_be_pulled(src, force, show_message)))
		return FALSE

	if(pulling)
		if(AM == pulling && src == AM.pulledby)	// are we trying to pull something we are already pulling?
			return FALSE
		stop_pulling() // Clear yourself from targets `pulledby`.

	var/atom/movable/previous_puller = null
	if(AM.pulledby)
		previous_puller = AM.pulledby
		previous_puller.stop_pulling() // an object can't be pulled by two mobs at once.

	pulling = AM
	AM.pulledby = src

	mob_target = ismob(AM) ? AM : (AM.buckled_mobs && length(AM.buckled_mobs)) ? AM.buckled_mobs[1] : null
	if(mob_target)
		if(previous_puller)
			add_attack_logs(AM, previous_puller, "pulled from", ATKLOG_ALMOSTALL)
			if(show_message)
				mob_target.visible_message(
					span_danger("[src] перехватил[genderize_ru(gender,"","а","о","и")] [mob_target] у [previous_puller]."),
					span_danger("[src] перехватил[genderize_ru(gender,"","а","о","и")] Вас у [previous_puller]!"),
				)
		else
			add_attack_logs(src, mob_target, "pulls", ATKLOG_ALMOSTALL)
			if(show_message)
				mob_target.visible_message(
					span_warning("[src] схватил[genderize_ru(gender,"","а","о","и")] [mob_target]!"),
					span_warning("[src] схватил[genderize_ru(gender,"","а","о","и")] Вас!"),
				)
		mob_target.LAssailant = iscarbon(src) ? src : null

	return TRUE


/atom/movable/proc/stop_pulling()
	if(!pulling)
		return

	pulling.pulledby = null
	var/mob/living/ex_pulled = pulling
	pulling = null
	if(isliving(ex_pulled))
		var/mob/living/L = ex_pulled
		L.update_canmove()// mob gets up if it was lyng down in a chokehold


/**
 * Checks if the pulling and pulledby should be stopped because they're out of reach.
 * If z_allowed is TRUE, the z level of the pulling will be ignored.This is to allow things to be dragged up and down stairs.
 */
/atom/movable/proc/check_pulling(only_pulling = FALSE, z_allowed = FALSE)
	if(pulling)
		if(get_dist(src, pulling) > 1 || (z != pulling.z && !z_allowed))
			stop_pulling()
		else if(!isturf(loc))
			stop_pulling()
		else if(pulling && !isturf(pulling.loc) && pulling.loc != loc) //to be removed once all code that changes an object's loc uses forceMove().
			log_debug("[src]'s pull on [pulling] wasn't broken despite [pulling] being in [pulling.loc]. Pull stopped manually.")
			stop_pulling()
		else if(pulling.anchored || pulling.move_resist > move_force)
			stop_pulling()
	if(!only_pulling && pulledby && moving_diagonally != FIRST_DIAG_STEP && (get_dist(src, pulledby) > 1 || z != pulledby.z)) //separated from our puller and not in the middle of a diagonal move.
		pulledby.stop_pulling()

/atom/movable/proc/can_be_pulled(atom/movable/user, force, show_message = FALSE)
	if(src == user || !isturf(loc))
		return FALSE
	if(anchored || move_resist == INFINITY)
		if(show_message)
			to_chat(user, span_warning("Похоже, [src.name] прикрепл[genderize_ru(src.gender,"ён","ена","ено","ены")] к полу!"))
		return FALSE
	if(throwing)
		return FALSE
	if(force < (move_resist * MOVE_FORCE_PULL_RATIO))
		if(show_message)
			to_chat(user, span_warning("[src.name] слишком тяжелый!"))
		return FALSE
	return TRUE

// Used in shuttle movement and AI eye stuff.
// Primarily used to notify objects being moved by a shuttle/bluespace fuckup.
/atom/movable/proc/setLoc(var/T, var/teleported=0)
	loc = T

/**
 * meant for movement with zero side effects. only use for objects that are supposed to move "invisibly" (like camera mobs or ghosts)
 * if you want something to move onto a tile with a beartrap or recycler or tripmine or mouse without that object knowing about it at all, use this
 * most of the time you want forceMove()
 */
/atom/movable/proc/abstract_move(atom/new_loc)
	var/atom/old_loc = loc
	var/direction = get_dir(old_loc, new_loc)
	loc = new_loc
	Moved(old_loc, direction, TRUE)


/atom/movable/Move(atom/newloc, direct = NONE, movetime)
	if(!loc || !newloc)
		return FALSE

	var/atom/oldloc = loc

	if(loc != newloc)
		SEND_SIGNAL(src, COMSIG_MOVABLE_PRE_MOVE, oldloc)
		if(movetime > 0)
			glide_for(movetime)

		if(!(direct & (direct - 1))) //Cardinal move
			. = ..(newloc, direct) // don't pass up movetime

		else //Diagonal move, split it into cardinal moves
			moving_diagonally = FIRST_DIAG_STEP
			var/first_step_dir
			// The `&& moving_diagonally` checks are so that a forceMove taking
			// place due to a Crossed, Bumped, etc. call will interrupt
			// the second half of the diagonal movement, or the second attempt
			// at a first half if the cardinal Move() fails because we hit something.
			if(direct & NORTH)
				if(direct & EAST)
					if(Move(get_step(src,  NORTH),  NORTH) && moving_diagonally)
						first_step_dir = NORTH
						moving_diagonally = SECOND_DIAG_STEP
						. = Move(get_step(src,  EAST),  EAST)
					else if(moving_diagonally && Move(get_step(src,  EAST),  EAST))
						first_step_dir = EAST
						moving_diagonally = SECOND_DIAG_STEP
						. = Move(get_step(src,  NORTH),  NORTH)

				else if(direct & WEST)
					if(Move(get_step(src,  NORTH),  NORTH) && moving_diagonally)
						first_step_dir = NORTH
						moving_diagonally = SECOND_DIAG_STEP
						. = Move(get_step(src,  WEST),  WEST)
					else if(moving_diagonally && Move(get_step(src,  WEST),  WEST))
						first_step_dir = WEST
						moving_diagonally = SECOND_DIAG_STEP
						. = Move(get_step(src,  NORTH),  NORTH)

			else if(direct & SOUTH)
				if(direct & EAST)
					if(Move(get_step(src,  SOUTH),  SOUTH) && moving_diagonally)
						first_step_dir = SOUTH
						moving_diagonally = SECOND_DIAG_STEP
						. = Move(get_step(src,  EAST),  EAST)
					else if(moving_diagonally && Move(get_step(src,  EAST),  EAST))
						first_step_dir = EAST
						moving_diagonally = SECOND_DIAG_STEP
						. = Move(get_step(src,  SOUTH),  SOUTH)

				else if(direct & WEST)
					if(Move(get_step(src,  SOUTH),  SOUTH) && moving_diagonally)
						first_step_dir = SOUTH
						moving_diagonally = SECOND_DIAG_STEP
						. = Move(get_step(src,  WEST),  WEST)
					else if(moving_diagonally && Move(get_step(src,  WEST),  WEST))
						first_step_dir = WEST
						moving_diagonally = SECOND_DIAG_STEP
						. = Move(get_step(src,  SOUTH),  SOUTH)

			if(moving_diagonally == SECOND_DIAG_STEP)
				if(!.)
					setDir(first_step_dir)
				else if(!inertia_moving)
					inertia_next_move = world.time + inertia_move_delay
					newtonian_move(direct)
			moving_diagonally = NONE
			return

	if(!loc || (loc == oldloc && oldloc != newloc))
		last_move = 0
		set_currently_z_moving(FALSE, TRUE)
		return

	if(.)
		Moved(oldloc, direct, FALSE)

	last_move = direct
	move_speed = world.time - l_move_time
	l_move_time = world.time

	if(. && has_buckled_mobs() && !handle_buckled_mob_movement(loc, direct, movetime)) //movement failed due to buckled mob
		. = FALSE

	if(currently_z_moving)
		if(. && loc == newloc)
			var/turf/pitfall = get_turf(src)
			pitfall.zFall(src, falling_from_move = TRUE)
		else
			set_currently_z_moving(FALSE, TRUE)

// Called after a successful Move(). By this point, we've already moved
/atom/movable/proc/Moved(atom/OldLoc, Dir, Forced = FALSE)

	if(!inertia_moving)
		inertia_next_move = world.time + inertia_move_delay
		newtonian_move(Dir)
	if(length(client_mobs_in_contents))
		update_parallax_contents()

	SEND_SIGNAL(src, COMSIG_MOVABLE_MOVED, OldLoc, Dir, Forced)

	for (var/datum/light_source/light as anything in light_sources) // Cycle through the light sources on this atom and tell them to update.
		light.source_atom.update_light()
	return TRUE

// Change glide size for the duration of one movement
/atom/movable/proc/glide_for(movetime)
	if(movetime)
		glide_size = world.icon_size/max(DS2TICKS(movetime), 1)
//		spawn(movetime)
//			glide_size = initial(glide_size)
//	else
//		glide_size = initial(glide_size)

// Previously known as HasEntered()
// This is automatically called when something enters your square
/atom/movable/Crossed(atom/movable/AM, oldloc)
	SEND_SIGNAL(src, COMSIG_MOVABLE_CROSSED, AM)
	SEND_SIGNAL(AM, COMSIG_CROSSED_MOVABLE, src)

/atom/movable/Uncrossed(atom/movable/AM)
	SEND_SIGNAL(src, COMSIG_MOVABLE_UNCROSSED, AM)

/atom/movable/Bump(atom/A, yes) //the "yes" arg is to differentiate our Bump proc from byond's, without it every Bump() call would become a double Bump().
	if(A && yes)
		SEND_SIGNAL(src, COMSIG_MOVABLE_BUMP, A)
		if(throwing)
			throwing.finalize(A)
			. = TRUE
			if(QDELETED(A))
				return
		A.Bumped(src)

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

	var/atom/oldloc = loc
	var/is_multi_tile = bound_width > world.icon_size || bound_height > world.icon_size

	if(destination)
		///zMove already handles whether a pull from another movable should be broken.
		if(pulledby && !currently_z_moving)
			pulledby.stop_pulling()

		var/same_loc = oldloc == destination
		var/area/old_area = get_area(oldloc)
		var/area/destarea = get_area(destination)
		var/movement_dir = get_dir(src, destination)

		moving_diagonally = NONE

		loc = destination

		if(!same_loc)
			if(is_multi_tile && isturf(destination))
				var/list/new_locs = block(
					destination,
					locate(
						min(world.maxx, destination.x + ROUND_UP(bound_width / 32)),
						min(world.maxy, destination.y + ROUND_UP(bound_height / 32)),
						destination.z
					)
				)
				if(old_area && old_area != destarea)
					old_area.Exited(src, movement_dir)
				for(var/atom/left_loc as anything in locs - new_locs)
					left_loc.Exited(src, destination)

				for(var/atom/entering_loc as anything in new_locs - locs)
					entering_loc.Entered(src, oldloc)

				if(old_area && old_area != destarea)
					destarea.Entered(src, movement_dir)
			else
				if(oldloc)
					oldloc.Exited(src, destination)
					if(old_area && old_area != destarea)
						old_area.Exited(src, movement_dir)
				destination.Entered(src, oldloc)
				if(destarea && old_area != destarea)
					destarea.Entered(src, old_area)
				for(var/atom/movable/movable in (destination.contents - src))
					movable.Crossed(src, oldloc)

			var/turf/oldturf = get_turf(oldloc)
			var/turf/destturf = get_turf(destination)
			if(oldturf && destturf && oldturf.z != destturf.z)
				onTransitZ(oldturf.z, destturf.z)

		. = TRUE

	//If no destination, move the atom into nullspace (don't do this unless you know what you're doing)
	else
		. = TRUE

		if(oldloc)
			loc = null
			var/area/old_area = get_area(oldloc)
			if(is_multi_tile && isturf(oldloc))
				for(var/atom/old_loc as anything in locs)
					old_loc.Exited(src, NONE)
			else
				oldloc.Exited(src, NONE)

			if(old_area)
				old_area.Exited(src, NONE)

	Moved(oldloc, NONE, TRUE)


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
		return
	for(var/mob/living/buckled as anything in buckled_mobs)
		if(buckled.pulling)
			. |= buckled.pulling
	if(pulling)
		. |= pulling

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
	if(z_move_flags & ZMOVE_FALL_CHECKS && (throwing || (movement_type & MOVETYPES_NOT_TOUCHING_GROUND) || !has_gravity(start)))
		return FALSE
	if(z_move_flags & ZMOVE_CAN_FLY_CHECKS && (movement_type & MOVETYPES_NOT_TOUCHING_GROUND) && has_gravity(start))
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

/atom/movable/proc/onTransitZ(old_z,new_z)
	for(var/item in src) // Notify contents of Z-transition. This can be overridden if we know the items contents do not care.
		var/atom/movable/AM = item
		AM.onTransitZ(old_z,new_z)
	SEND_SIGNAL(src, COMSIG_MOVABLE_Z_CHANGED)



/**
 * Called whenever an object moves and by mobs when they attempt to move themselves through space
 * And when an object or action applies a force on src, see [newtonian_move][/atom/movable/proc/newtonian_move]
 *
 * Return FALSE to have src start/keep drifting in a no-grav area and TRUE to stop/not start drifting
 *
 * Mobs should return TRUE if they should be able to move of their own volition, see [/client/proc/Move]
 *
 * Arguments:
 * * movement_dir - NONE when stopping or any dir when trying to move
 */
/atom/movable/proc/Process_Spacemove(movement_dir = NONE)
	if(has_gravity())
		return TRUE

	if(pulledby && pulledby.pulledby != src)
		return TRUE

	if(throwing)
		return TRUE

	if(!isturf(loc))
		return TRUE

	if(locate(/obj/structure/lattice) in range(1, get_turf(src))) //Not realistic but makes pushing things in space easier
		return TRUE

	return FALSE


/// Only moves the object if it's under no gravity
/atom/movable/proc/newtonian_move(direction)
	if(!isturf(loc) || Process_Spacemove(NONE))
		inertia_dir = NONE
		return FALSE

	inertia_dir = direction
	if(!direction)
		return TRUE

	inertia_last_loc = loc
	SSspacedrift.processing[src] = src
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

	if(pulledby)
		pulledby.stop_pulling()

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

	if(pulledby)
		pulledby.stop_pulling()

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

/atom/movable/overlay/New()
	. = ..()
	verbs.Cut()
	return

/atom/movable/overlay/attackby(a, b, c)
	if(master)
		return master.attackby(a, b, c)

/atom/movable/overlay/attack_hand(a, b, c)
	if(master)
		return master.attack_hand(a, b, c)

/atom/movable/proc/handle_buckled_mob_movement(newloc,direct,movetime)
	for(var/m in buckled_mobs)
		var/mob/living/buckled_mob = m
		buckled_mob.glide_size = glide_size
		if(!buckled_mob.Move(newloc, direct, movetime))
			forceMove(buckled_mob.loc)
			last_move = buckled_mob.last_move
			inertia_dir = last_move
			buckled_mob.inertia_dir = last_move
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


/atom/movable/proc/get_spacemove_backup(moving_direction)
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
	if(visual_effect_icon)
		attack_image = image('icons/effects/effects.dmi', attacked_atom, visual_effect_icon, attacked_atom.layer + 0.1)
	else if(used_item)
		attack_image = image(icon = used_item, loc = attacked_atom, layer = attacked_atom.layer + 0.1)
		attack_image.plane = GAME_PLANE

		// Scale the icon.
		attack_image.transform *= 0.4
		// The icon should not rotate.
		attack_image.appearance_flags = APPEARANCE_UI

		// Set the direction of the icon animation.
		var/direction = get_dir(src, attacked_atom)
		if(direction & NORTH)
			attack_image.pixel_y = -16
		else if(direction & SOUTH)
			attack_image.pixel_y = 16

		if(direction & EAST)
			attack_image.pixel_x = -16
		else if(direction & WEST)
			attack_image.pixel_x = 16

		if(!direction) // Attacked self?!
			attack_image.pixel_y = 12
			attack_image.pixel_x = 5 * (prob(50) ? 1 : -1)

	if(!attack_image)
		return

	// Who can see the attack?
	var/list/viewing = list()
	for(var/mob/viewer in viewers(attacked_atom))
		if(viewer.client && (viewer.client.prefs.toggles2 & PREFTOGGLE_2_ITEMATTACK))
			viewing |= viewer.client

	flick_overlay(attack_image, viewing, 0.7 SECONDS)
	var/matrix/initial_transform = matrix(transform)
	var/image_color = "#ffffff"
	if(ismob(src) && ismob(attacked_atom) && !used_item)
		var/mob/attacker = src
		image_color = attacker.a_intent == INTENT_HARM ? "#ff0000" : "#ffffff"

	// And animate the attack!
	animate(attack_image, alpha = 175, transform = initial_transform.Scale(0.75), pixel_x = 0, pixel_y = 0, time = 0.3 SECONDS, color = image_color)
	animate(time = 0.1 SECONDS)
	animate(alpha = 0, time = 0.3 SECONDS, easing = (CIRCULAR_EASING|EASE_OUT))


/atom/movable/proc/portal_destroyed(obj/effect/portal/P)
	return

/atom/movable/proc/decompile_act(obj/item/matter_decompiler/C, mob/user) // For drones to decompile mobs and objs. See drone for an example.
	return FALSE

/atom/movable/proc/get_pull_push_speed_modifier(current_delay)
	return pull_push_speed_modifier


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

