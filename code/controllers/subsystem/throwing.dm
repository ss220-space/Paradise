/// 2 z-levels on default width
#define MAX_THROWING_DIST 512
///How many missed ticks will we attempt to make up for this run.
#define MAX_TICKS_TO_MAKE_UP 3

SUBSYSTEM_DEF(throwing)
	name = "Throwing"
	priority = FIRE_PRIORITY_THROWING
	wait = 1
	flags = SS_NO_INIT|SS_KEEP_TIMING|SS_TICKER
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	offline_implications = "Thrown objects may not react properly. Shuttle call recommended."
	cpu_display = SS_CPUDISPLAY_LOW
	ss_id = "throwing"

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
		if(QDELETED(AM) || QDELETED(TT))
			processing -= AM
			if(MC_TICK_CHECK)
				return
			continue

		TT.tick()

		if(MC_TICK_CHECK)
			return

	currentrun = null


/datum/thrownthing
	///Defines the atom that has been thrown (Objects and Mobs, mostly.)
	var/atom/movable/thrownthing
	///Original intended target of the throw.
	var/atom/initial_target
	///The turf that the target was on, if it's not a turf itself.
	var/turf/target_turf
	///The turf that we were thrown from.
	var/turf/starting_turf
	///If the target happens to be a carbon and that carbon has a body zone aimed at, this is carried on here.
	var/target_zone
	///The initial direction of the thrower of the thrownthing for building the trajectory of the throw.
	var/init_dir
	///The maximum number of turfs that the thrownthing will travel to reach it's target.
	var/maxrange
	///Turfs to travel per tick
	var/speed
	///If a mob is the one who has thrown the object, then it's moved here. This can be null and must be null checked before trying to use it.
	var/mob/thrower
	///A variable that helps in describing objects thrown at an angle, if it should be moved diagonally first or last.
	var/diagonals_first
	///Set to TRUE if the throw is exclusively diagonal (45 Degree angle throws for example)
	var/pure_diagonal
	///Tracks how far a thrownthing has traveled mid-throw for the purposes of maxrange
	var/dist_travelled = 0
	///The start_time obtained via world.time for the purposes of tiles moved/tick.
	var/start_time
	///Distance to travel in the X axis/direction.
	var/dist_x
	///Distance to travel in the y axis/direction.
	var/dist_y
	///The HORIZONTAL direction we're traveling (EAST or WEST)
	var/dx
	///The VERTICAL direction we're traveling (NORTH or SOUTH)
	var/dy
	///The movement force provided to a given object in transit. More info on these in move_force.dm
	var/force = MOVE_FORCE_DEFAULT
	///How many tiles that need to be moved in order to travel to the target.
	var/diagonal_error
	///If a thrown thing has a callback, it can be invoked here within thrownthing.
	var/datum/callback/callback
	///Mainly exists for things that would freeze a thrown object in place, like a timestop'd tile. Or a Tractor Beam.
	var/paused = FALSE
	///How long an object has been paused for, to be added to the travel time.
	var/delayed_time = 0
	///The last world.time value stored when the thrownthing was moving.
	var/last_move = 0
	///When this variable is `FALSE`, non dense mobs will be hit by a thrown thing.
	var/dodgeable = TRUE


/datum/thrownthing/New(thrownthing, target, init_dir, maxrange, speed, thrower, diagonals_first, force, callback, target_zone, dodgeable)
	. = ..()
	src.thrownthing = thrownthing
	RegisterSignal(thrownthing, COMSIG_PARENT_QDELETING, PROC_REF(on_thrownthing_qdel))
	src.starting_turf = get_turf(thrownthing)
	src.target_turf = get_turf(target)
	if(target_turf != target)
		src.initial_target = target
	src.init_dir = init_dir
	src.maxrange = maxrange
	src.speed = speed
	if(thrower)
		src.thrower = thrower
	src.diagonals_first = diagonals_first
	src.force = force
	src.callback = callback
	src.target_zone = target_zone
	src.dodgeable = dodgeable


/datum/thrownthing/Destroy()
	SSthrowing.processing -= thrownthing
	SSthrowing.currentrun -= thrownthing
	thrownthing.throwing = null
	thrownthing = null
	thrower = null
	initial_target = null
	callback = null
	starting_turf = null
	target_turf = null
	return ..()


///Defines the datum behavior on the thrownthing's qdeletion event.
/datum/thrownthing/proc/on_thrownthing_qdel(atom/movable/source, force)
	SIGNAL_HANDLER

	qdel(src)


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

	if(!thrownthing)	//done throwing, either because it hit something or it finished moving
		return

	thrownthing.throwing = null

	if(hit_target)
		thrownthing.throw_impact(hit_target, src, speed)
	else
		thrownthing.throw_impact(get_turf(thrownthing), src)  // we haven't hit something yet and we still must, let's hit the ground.

	if(QDELETED(thrownthing))
		return

	if(callback)
		callback.Invoke()
		if(QDELETED(thrownthing))
			return

	SEND_SIGNAL(thrownthing, COMSIG_MOVABLE_THROW_LANDED, src)
	thrownthing.end_throw()
	if(QDELETED(thrownthing))
		return

	if(isturf(thrownthing.loc))
		thrownthing.newtonian_move(REVERSE_DIR(init_dir))

	qdel(src)


/datum/thrownthing/proc/hitcheck()
	for(var/atom/movable/obstacle as anything in get_turf(thrownthing))
		if(obstacle == thrownthing || (obstacle == thrower && !ismob(thrownthing)))
			continue
		if(ismob(obstacle) && (thrownthing.pass_flags & PASSMOB))
			continue
		if(obstacle.pass_flags_self & LETPASSTHROW)
			continue
		if(obstacle == initial_target || (((obstacle.density && !(obstacle.flags & ON_BORDER)) || (isliving(obstacle) && !dodgeable)) && !(obstacle in thrownthing.buckled_mobs)))
			finalize(obstacle)
			return TRUE


#undef MAX_THROWING_DIST
#undef MAX_TICKS_TO_MAKE_UP

