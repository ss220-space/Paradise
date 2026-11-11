/proc/cross_frame_with_pull(atom/movable/mover, turf/destination)
	var/atom/movable/pulled = mover.pulling
	var/grip = mover.grab_state
	var/pull_force = mover.pull_force
	mover.forceMove(destination)
	if(QDELETED(pulled) || pulled.anchored || pulled.loc == destination)
		return
	pulled.forceMove(destination)
	INVOKE_ASYNC(mover, TYPE_PROC_REF(/atom/movable, start_pulling), pulled, grip, pull_force, TRUE)

/proc/bump_into_hull(atom/movable/mover, turf/hull_turf)
	var/atom/blocker = hull_turf
	for(var/atom/movable/obstacle in hull_turf)
		if(obstacle.density)
			blocker = obstacle
			break
	mover.Bump(blocker)
