MOVEMENT_SUBSYSTEM_DEF(cliff_falling)
	name = "Cliff Falling"
	priority = FIRE_PRIORITY_CLIFF_FALLING
	ss_flags = SS_NO_INIT|SS_TICKER
	runlevels = RUNLEVEL_GAME|RUNLEVEL_POSTGAME

	var/list/cliff_grinders = list()

/datum/controller/subsystem/movement/cliff_falling/proc/start_falling(atom/movable/faller, turf/simulated/floor/cliff/cliff)
	cliff_grinders[faller] = GLOB.move_manager.move(
		moving = faller,
		direction = cliff.fall_direction,
		delay = cliff.fall_speed,
		subsystem = src,
		priority = MOVEMENT_ABOVE_SPACE_PRIORITY,
		flags = MOVEMENT_LOOP_OUTSIDE_CONTROL | MOVEMENT_LOOP_NO_DIR_UPDATE,
	)

	RegisterSignal(faller, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))
	RegisterSignal(faller, COMSIG_QDELETING, PROC_REF(clear_references))
	RegisterSignal(faller, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(check_move))

/datum/controller/subsystem/movement/cliff_falling/proc/on_moved(atom/movable/mover, turf/old_loc)
	SIGNAL_HANDLER

	var/turf/simulated/floor/cliff/new_cliff = mover.loc
	if(!iscliffturf(new_cliff))
		var/datum/move_loop/move/falling = cliff_grinders[mover]
		clear_references(mover)
		qdel(falling)
		return

	new_cliff.on_fall(mover)

	if(old_loc.type == new_cliff.type)
		return

	var/datum/move_loop/move/falling = cliff_grinders[mover]
	falling.set_delay(new_cliff.fall_speed)

/datum/controller/subsystem/movement/cliff_falling/proc/clear_references(atom/movable/deletee)
	SIGNAL_HANDLER

	cliff_grinders -= deletee
	UnregisterSignal(deletee, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING, COMSIG_MOVABLE_PRE_MOVE))

/datum/controller/subsystem/movement/cliff_falling/proc/check_move(atom/movable/mover, turf/target)
	SIGNAL_HANDLER

	var/turf/simulated/floor/cliff/cliff_turf = get_turf(mover)
	if(!iscliffturf(cliff_turf))
		clear_references(mover)
		return

	if(!cliff_turf.can_move(mover, target))
		return COMPONENT_MOVABLE_BLOCK_PRE_MOVE
