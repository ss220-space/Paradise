/datum/element/waddling

/datum/element/waddling/Attach(datum/target)
	. = ..()
	if(!ismovable(target))
		return ELEMENT_INCOMPATIBLE
	if(isliving(target))
		RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(LivingWaddle))
	else
		RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(Waddle))

/datum/element/waddling/Detach(datum/source, force)
	. = ..()
	UnregisterSignal(source, COMSIG_MOVABLE_MOVED)

/datum/element/waddling/proc/LivingWaddle(mob/living/target)
	if(target.incapacitated() || target.lying)
		return
	Waddle(target)

/datum/element/waddling/proc/Waddle(atom/movable/target)
	var/prev_pixel_z = target.pixel_z
	animate(target, pixel_z = target.pixel_z + 4, time = 0)
	var/prev_transform = target.transform
	animate(pixel_z = prev_pixel_z, transform = turn(target.transform, pick(-12, 0, 12)), time = 2)
	animate(transform = prev_transform, time = 0)

