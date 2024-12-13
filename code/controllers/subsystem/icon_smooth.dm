SUBSYSTEM_DEF(icon_smooth)
	name = "Icon Smoothing"
	init_order = INIT_ORDER_ICON_SMOOTHING
	wait = 1
	priority = FIRE_PRIORITY_SMOOTHING
	flags = SS_TICKER
	offline_implications = "Objects will no longer smooth together properly. No immediate action is needed."
	cpu_display = SS_CPUDISPLAY_LOW
	ss_id = "icon_smooth"
	/**
	 *	Used to track instances of icon smooth halters. Does not apply to roundstart loading, however.
	 *  Always make sure to remove halt source from this list on the end of operation.
	 */
	var/halt_sources = list()
	var/list/smooth_queue = list()


/datum/controller/subsystem/icon_smooth/fire()
	if(length(halt_sources))
		return

	while(smooth_queue.len)
		var/atom/A = smooth_queue[smooth_queue.len]
		smooth_queue.len--
		smooth_icon(A)
		if(MC_TICK_CHECK)
			return
	if(!smooth_queue.len)
		can_fire = 0

/datum/controller/subsystem/icon_smooth/Initialize()
	log_startup_progress("Smoothing atoms...")
	// Smooth EVERYTHING in the world
	for(var/turf/T in world)
		if(T.smooth)
			smooth_icon(T)
		for(var/A in T)
			var/atom/AA = A
			if(AA.smooth)
				smooth_icon(AA)
				CHECK_TICK

	// Incase any new atoms were added to the smoothing queue for whatever reason
	var/queue = smooth_queue
	smooth_queue = list()
	for(var/V in queue)
		var/atom/A = V
		if(!A || A.z <= 2)
			continue
		smooth_icon(A)
		CHECK_TICK

	return SS_INIT_SUCCESS

/datum/controller/subsystem/icon_smooth/proc/add_halt_source(datum/source)
	halt_sources += source

/datum/controller/subsystem/icon_smooth/proc/remove_halt_source(datum/source)
	halt_sources -= source
