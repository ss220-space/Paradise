/datum/element/waddling


/datum/element/waddling/Attach(datum/target)
	. = ..()
	if(!ismovable(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(Waddle))


/datum/element/waddling/Detach(datum/source, force)
	. = ..()
	UnregisterSignal(source, COMSIG_MOVABLE_MOVED)


/datum/element/waddling/proc/Waddle(atom/movable/target, atom/oldloc, direction, forced, list/old_locs, momentum_change)
	SIGNAL_HANDLER

	if(forced || CHECK_MOVE_LOOP_FLAGS(target, MOVEMENT_LOOP_OUTSIDE_CONTROL))
		return

	if(isliving(target))
		var/mob/living/living_target = target
		if(living_target.incapacitated() || living_target.body_position == LYING_DOWN)
			return

	waddling_animation(target)


/datum/element/waddling/proc/waddling_animation(atom/movable/target)
	var/prev_pixel_z = target.pixel_z
	animate(target, pixel_z = target.pixel_z + 4, time = 0)
	var/prev_transform = target.transform
	animate(pixel_z = prev_pixel_z, transform = turn(target.transform, pick(-12, 0, 12)), time = 0.2 SECONDS)
	animate(transform = prev_transform, time = 0)

