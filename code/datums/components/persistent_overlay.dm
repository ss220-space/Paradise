/datum/component/persistent_overlay
	var/image/persistent_overlay
	var/atom/target


/datum/component/persistent_overlay/Initialize(persistent_overlay, target, timer)
	src.persistent_overlay = persistent_overlay
	src.target = target
	if(timer)
		addtimer(CALLBACK(src, PROC_REF(remove_persistent_overlay)), timer)
	if(target)
		RegisterSignal(target, COMSIG_PARENT_QDELETING, PROC_REF(remove_persistent_overlay))
	RegisterSignal(parent, COMSIG_PARENT_QDELETING, PROC_REF(remove_persistent_overlay))
	add_persistent_overlay()


/datum/component/persistent_overlay/Destroy()
	persistent_overlay = null
	target = null
	return ..()


/datum/component/persistent_overlay/proc/remove_persistent_overlay(datum/source)
	var/atom/movable/our_target = target ? target : parent
	our_target.cut_overlay(persistent_overlay)
	qdel(src)


/datum/component/persistent_overlay/proc/add_persistent_overlay(datum/source)
	var/atom/movable/our_target = target ? target : parent
	our_target.add_overlay(persistent_overlay)

