#define MAX_THROWING_DIST 512 // 2 z-levels on default width
#define MAX_TICKS_TO_MAKE_UP 3 //how many missed ticks will we attempt to make up for this run.

SUBSYSTEM_DEF(throwing)
	name = "Throwing"
	priority = FIRE_PRIORITY_THROWING
	wait = 1
	flags = SS_NO_INIT|SS_KEEP_TIMING|SS_TICKER
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	offline_implications = "Thrown objects may not react properly. Shuttle call recommended."
	cpu_display = SS_CPUDISPLAY_LOW

	var/list/currentrun
	var/list/processing = list()


/datum/controller/subsystem/throwing/get_stat_details()
	return "P:[length(processing)]"


/datum/controller/subsystem/throwing/fire(resumed = 0)
	if(!resumed)
		src.currentrun = processing.Copy()

	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun

	while(length(currentrun))
		var/atom/movable/AM = currentrun[currentrun.len]
		var/datum/thrownthing/TT = currentrun[AM]
		currentrun.len--
		if(!AM || !TT)
			processing -= AM
			if(MC_TICK_CHECK)
				return
			continue

		TT.tick()

		if(MC_TICK_CHECK)
			return

	currentrun = null


/datum/thrownthing
	var/atom/movable/thrownthing
	var/atom/target
	var/turf/target_turf
	var/init_dir
	var/maxrange
	var/speed
	var/mob/thrower
	var/diagonals_first
	var/dist_travelled = 0
	var/start_time
	var/dist_x
	var/dist_y
	var/dx
	var/dy
	var/force = MOVE_FORCE_DEFAULT
	var/pure_diagonal
	var/diagonal_error
	var/datum/callback/callback
	var/paused = FALSE
	var/delayed_time = 0
	var/last_move = 0
	///When this variable is `FALSE`, non dense mobs will be hit by a thrown item.
	var/dodgeable = TRUE


/datum/thrownthing/proc/tick()
	var/atom/movable/AM = thrownthing
	if(!isturf(AM.loc) || !AM.throwing)
		finalize()
		return

	if(paused)
		delayed_time += world.time - last_move
		return

	if(dist_travelled && hitcheck()) //to catch sneaky things moving on our tile while we slept
		return

	var/atom/step

	last_move = world.time

	//calculate how many tiles to move, making up for any missed ticks.
	var/tilestomove = CEILING(min(((((world.time + world.tick_lag) - start_time + delayed_time) * speed) - (dist_travelled ? dist_travelled : -1)), speed * MAX_TICKS_TO_MAKE_UP) * (world.tick_lag * SSthrowing.wait), 1)
	while(tilestomove-- > 0)
		if(!AM.throwing)	// datum was nullified on finalize, our job is done
			return

		if((dist_travelled >= maxrange || AM.loc == target_turf) && has_gravity(AM, AM.loc))
			if(!hitcheck())
				finalize()
			return

		if(dist_travelled <= max(dist_x, dist_y)) //if we haven't reached the target yet we home in on it, otherwise we use the initial direction
			step = get_step(AM, get_dir(AM, target_turf))
		else
			step = get_step(AM, init_dir)

		if(!pure_diagonal && !diagonals_first) // not a purely diagonal trajectory and we don't want all diagonal moves to be done first
			if (diagonal_error >= 0 && max(dist_x, dist_y) - dist_travelled != 1) //we do a step forward unless we're right before the target
				step = get_step(AM, dx)
			diagonal_error += (diagonal_error < 0) ? dist_x / 2 : -dist_y

		if(!step) // going off the edge of the map makes get_step return null, don't let things go off the edge
			finalize()
			return

		AM.Move(step, get_dir(AM, step))

		dist_travelled++

		if(dist_travelled > MAX_THROWING_DIST)
			finalize()
			return


/datum/thrownthing/proc/finalize(atom/hit_target)
	set waitfor = FALSE

	SSthrowing.processing -= thrownthing
	thrownthing.throwing = null	//done throwing, either because it hit something or it finished moving

	if(hit_target)
		thrownthing.throw_impact(hit_target, src, speed)
	else
		thrownthing.throw_impact(get_turf(thrownthing), src)  // we haven't hit something yet and we still must, let's hit the ground.

	if(thrownthing && isturf(thrownthing.loc))
		thrownthing.newtonian_move(GetOppositeDir(init_dir))

	if(callback)
		callback.Invoke()

	thrownthing?.end_throw()


/datum/thrownthing/proc/hitcheck()
	for(var/thing in get_turf(thrownthing))
		var/atom/movable/AM = thing
		if(AM == thrownthing || AM == thrower)
			continue
		if((AM.density || (isliving(AM) && !dodgeable)) && !(AM.pass_flags & LETPASSTHROW) && !(AM.flags & ON_BORDER))
			finalize(AM)
			return TRUE

