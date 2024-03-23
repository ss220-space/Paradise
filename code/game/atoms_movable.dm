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

	/// If false makes [CanPass][/atom/proc/CanPass] call [CanPassThrough][/atom/movable/proc/CanPassThrough] on this type instead of using default behaviour
	var/generic_canpass = TRUE

	var/inertia_dir = NONE
	var/atom/inertia_last_loc
	var/inertia_moving = FALSE
	var/inertia_next_move = 0
	var/inertia_move_delay = 5
	/// NONE:0 not doing a diagonal move. FIRST_DIAG_STEP:1 and SECOND_DIAG_STEP:2 doing the first/second step of the diagonal move.
	var/moving_diagonally = NONE
	var/list/client_mobs_in_contents

	/// Either FALSE, [EMISSIVE_BLOCK_GENERIC], or [EMISSIVE_BLOCK_UNIQUE]
	var/blocks_emissive = FALSE
	///Internal holder for emissive blocker object, do not use directly use blocks_emissive
	var/atom/movable/emissive_blocker/em_block
	/// Icon state for thought bubbles. Normally set by mobs.
	var/thought_bubble_image = "thought_bubble"


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


/atom/movable/Destroy()
	unbuckle_all_mobs(force = TRUE)
	QDEL_NULL(em_block)

	. = ..()
	if(loc)
		loc.handle_atom_del(src)
	for(var/atom/movable/AM in contents)
		qdel(AM)
	LAZYCLEARLIST(client_mobs_in_contents)
	forceMove(null)
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
				visible_message(span_danger("[src] перехватил[genderize_ru(gender,"","а","о","и")] [mob_target] у [previous_puller]."))
		else
			add_attack_logs(src, mob_target, "pulls", ATKLOG_ALMOSTALL)
			if(show_message)
				visible_message(span_warning("[src] схватил[genderize_ru(gender,"","а","о","и")] [mob_target]!"))
		mob_target.LAssailant = iscarbon(src) ? src : null

	return TRUE


/atom/movable/proc/stop_pulling()
	if(pulling)
		pulling.pulledby = null
		var/mob/living/ex_pulled = pulling
		pulling = null
		if(isliving(ex_pulled))
			var/mob/living/L = ex_pulled
			L.update_canmove()// mob gets up if it was lyng down in a chokehold

/atom/movable/proc/check_pulling()
	if(pulling)
		var/atom/movable/pullee = pulling
		if(pullee && get_dist(src, pullee) > 1)
			stop_pulling()
			return
		if(!isturf(loc))
			stop_pulling()
			return
		if(pullee && !isturf(pullee.loc) && pullee.loc != loc) //to be removed once all code that changes an object's loc uses forceMove().
			log_debug("[src]'s pull on [pullee] wasn't broken despite [pullee] being in [pullee.loc]. Pull stopped manually.")
			stop_pulling()
			return
		if(pulling.anchored || pulling.move_resist > move_force)
			stop_pulling()
			return
	if(pulledby && moving_diagonally != FIRST_DIAG_STEP && get_dist(src, pulledby) > 1)		//separated from our puller and not in the middle of a diagonal move.
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


/atom/movable/Move(atom/newloc, direct = NONE, movetime)
	if(!loc || !newloc)
		return FALSE

	var/atom/oldloc = loc

	if(loc != newloc)
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
		return

	if(.)
		Moved(oldloc, direct, FALSE)

	last_move = direct
	move_speed = world.time - l_move_time
	l_move_time = world.time

	if(. && has_buckled_mobs() && !handle_buckled_mob_movement(loc, direct, movetime)) //movement failed due to buckled mob
		. = FALSE


// Called after a successful Move(). By this point, we've already moved
/atom/movable/proc/Moved(atom/OldLoc, Dir, Forced = FALSE)

	if(!inertia_moving)
		inertia_next_move = world.time + inertia_move_delay
		newtonian_move(Dir)
	if(length(client_mobs_in_contents))
		update_parallax_contents()

	SEND_SIGNAL(src, COMSIG_MOVABLE_MOVED, OldLoc, Dir, Forced)

	var/datum/light_source/L
	var/thing
	for (thing in light_sources) // Cycle through the light sources on this atom and tell them to update.
		L = thing
		L.source_atom.update_light()
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

/atom/movable/proc/forceMove(atom/destination)
	var/turf/old_loc = loc
	var/area/old_area = get_area(src)
	var/area/new_area = get_area(destination)
	loc = destination
	moving_diagonally = NONE

	if(old_loc)
		old_loc.Exited(src, destination)
		for(var/atom/movable/AM in old_loc)
			AM.Uncrossed(src)

	if(old_area && (new_area != old_area))
		old_area.Exited(src)

	if(destination)
		destination.Entered(src)
		for(var/atom/movable/AM in destination)
			if(AM == src)
				continue
			AM.Crossed(src, old_loc)

		if(new_area && (old_area != new_area))
			new_area.Entered(src)

		var/turf/oldturf = get_turf(old_loc)
		var/turf/destturf = get_turf(destination)
		var/old_z = (oldturf ? oldturf.z : null)
		var/dest_z = (destturf ? destturf.z : null)
		if(old_z != dest_z)
			onTransitZ(old_z, dest_z)

	Moved(old_loc, NONE, TRUE)

	return TRUE


/atom/movable/proc/move_to_null_space()

	var/atom/old_loc = loc
	var/is_multi_tile = bound_width > world.icon_size || bound_height > world.icon_size

	if(old_loc)
		loc = null
		var/area/old_area = get_area(old_loc)
		if(is_multi_tile && isturf(old_loc))
			for(var/atom/old_loc_multi as anything in locs)
				old_loc_multi.Exited(src, NONE)
		else
			old_loc.Exited(src, NONE)

		if(old_area)
			old_area.Exited(src, NONE)

	Moved(old_loc, NONE, TRUE)


/atom/movable/proc/onTransitZ(old_z,new_z)
	for(var/item in src) // Notify contents of Z-transition. This can be overridden if we know the items contents do not care.
		var/atom/movable/AM = item
		AM.onTransitZ(old_z,new_z)
	SEND_SIGNAL(src, COMSIG_MOVABLE_Z_CHANGED)

/mob/living/forceMove(atom/destination)
	if(buckled)
		addtimer(CALLBACK(src, PROC_REF(check_buckled)), 1, TIMER_UNIQUE)
	if(has_buckled_mobs())
		for(var/m in buckled_mobs)
			var/mob/living/buckled_mob = m
			addtimer(CALLBACK(buckled_mob, PROC_REF(check_buckled)), 1, TIMER_UNIQUE)
	if(pulling)
		addtimer(CALLBACK(src, PROC_REF(check_pull)), 1, TIMER_UNIQUE)
	. = ..()
	if(client)
		reset_perspective(destination)
	update_canmove() //if the mob was asleep inside a container and then got forceMoved out we need to make them fall.

//Called whenever an object moves and by mobs when they attempt to move themselves through space
//And when an object or action applies a force on src, see newtonian_move() below
//Return FALSE to have src start/keep drifting in a no-grav area and TRUE to stop/not start drifting
//Mobs should return TRUE if they should be able to move of their own volition, see client/Move() in mob_movement.dm
//movement_dir == 0 when stopping or any dir when trying to move
/atom/movable/proc/Process_Spacemove(movement_dir = 0)
	if(has_gravity(src))
		return TRUE

	if(pulledby && !pulledby.pulling)
		return TRUE

	if(throwing)
		return TRUE

	if(locate(/obj/structure/lattice) in range(1, get_turf(src))) //Not realistic but makes pushing things in space easier
		return TRUE

	return FALSE

/atom/movable/proc/newtonian_move(direction) //Only moves the object if it's under no gravity
	if(!loc || Process_Spacemove(0))
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
	if(!target || (flags & NODROP) || speed <= 0)
		return FALSE

	if(pulledby)
		pulledby.stop_pulling()

	// They are moving! Wouldn't it be cool if we calculated their momentum and added it to the throw?
	if(istype(thrower) && thrower.last_move && thrower.client && thrower.client.move_delay >= world.time + world.tick_lag * 2)
		var/user_momentum = thrower.movement_delay()
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

	var/datum/thrownthing/thrown_thing = new(src, target, get_dir(src, target), range, speed, thrower, diagonals_first, force, callback, thrower?.zone_selected, dodgeable)

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
			//if(checked_atom.last_pushoff == world.time)
			//	continue
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

/atom/movable/proc/do_attack_animation(atom/A, visual_effect_icon, obj/item/used_item, no_effect)
	if(!no_effect && (visual_effect_icon || used_item))
		do_item_attack_animation(A, visual_effect_icon, used_item)

	if(A == src)
		return //don't do an animation if attacking self
	var/pixel_x_diff = 0
	var/pixel_y_diff = 0

	var/direction = get_dir(src, A)
	if(direction & NORTH)
		pixel_y_diff = 8
	else if(direction & SOUTH)
		pixel_y_diff = -8

	if(direction & EAST)
		pixel_x_diff = 8
	else if(direction & WEST)
		pixel_x_diff = -8

	animate(src, pixel_x = pixel_x + pixel_x_diff, pixel_y = pixel_y + pixel_y_diff, time = 2)
	animate(pixel_x = pixel_x - pixel_x_diff, pixel_y = pixel_y - pixel_y_diff, time = 2)

/atom/movable/proc/do_item_attack_animation(atom/A, visual_effect_icon, obj/item/used_item)
	var/image/I
	if(visual_effect_icon)
		I = image('icons/effects/effects.dmi', A, visual_effect_icon, A.layer + 0.1)
	else if(used_item)
		I = image(icon = used_item, loc = A, layer = A.layer + 0.1)
		I.plane = GAME_PLANE

		// Scale the icon.
		I.transform *= 0.75
		// The icon should not rotate.
		I.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA

		// Set the direction of the icon animation.
		var/direction = get_dir(src, A)
		if(direction & NORTH)
			I.pixel_y = -16
		else if(direction & SOUTH)
			I.pixel_y = 16

		if(direction & EAST)
			I.pixel_x = -16
		else if(direction & WEST)
			I.pixel_x = 16

		if(!direction) // Attacked self?!
			I.pixel_z = 16

	if(!I)
		return

	// Who can see the attack?
	var/list/viewing = list()
	for(var/mob/M in viewers(A))
		if(M.client && M.client.prefs.toggles2 & PREFTOGGLE_2_ITEMATTACK)
			viewing |= M.client

	flick_overlay(I, viewing, 5) // 5 ticks/half a second

	// And animate the attack!
	var/t_color = "#ffffff"
	if(ismob(src) &&  ismob(A) && (!used_item))
		var/mob/M = src
		t_color = M.a_intent == INTENT_HARM ? "#ff0000" : "#ffffff"
	animate(I, alpha = 175, pixel_x = 0, pixel_y = 0, pixel_z = 0, time = 3, color = t_color)

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

