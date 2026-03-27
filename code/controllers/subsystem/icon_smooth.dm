SUBSYSTEM_DEF(icon_smooth)
	name = "Icon Smoothing"
	init_order = INIT_ORDER_ICON_SMOOTHING
	wait = 1
	priority = FIRE_PRIORITY_SMOOTHING
	flags = SS_TICKER|SS_HIBERNATE
	offline_implications = "Objects will no longer smooth together properly. No immediate action is needed."
	cpu_display = SS_CPUDISPLAY_LOW
	ss_id = "icon_smooth"
	/**
	 *	Used to track instances of icon smooth halters. Does not apply to roundstart loading, however.
	 *  Always make sure to remove halt source from this list on the end of operation.
	 */
	var/halt_sources = list()
	var/list/smooth_queue = list()
	var/list/deferred = list()

/datum/controller/subsystem/icon_smooth/PreInit()
	. = ..()
	hibernate_checks = list(
		NAMEOF(src, smooth_queue),
		NAMEOF(src, halt_sources),
	)

/datum/controller/subsystem/icon_smooth/fire()
	if(length(halt_sources))
		return

	var/list/smooth_queue_cache = smooth_queue
	while(length(smooth_queue_cache))
		var/atom/smoothing_atom = smooth_queue_cache[length(smooth_queue_cache)]
		smooth_queue_cache.len--
		if(QDELETED(smoothing_atom) || !(smoothing_atom.smooth & SMOOTH_QUEUED))
			continue
		if(smoothing_atom.flags & INITIALIZED)
			smooth_icon(smoothing_atom)
		else
			deferred += smoothing_atom
		if(MC_TICK_CHECK)
			return

	if(!length(smooth_queue_cache))
		if(length(deferred))
			smooth_queue = deferred
			deferred = smooth_queue_cache
		else
			can_fire = FALSE

/datum/controller/subsystem/icon_smooth/Initialize()
	log_startup_progress("Smoothing atoms...")

	var/list/queue = smooth_queue
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
	smooth_queue = list()
	for(var/V in queue)
		var/atom/A = V
		if(!A || A.z <= 2)
			continue
		smooth_icon(A)
		CHECK_TICK

	return SS_INIT_SUCCESS

/datum/controller/subsystem/icon_smooth/proc/add_to_queue(atom/thing)
	if(thing.smooth & SMOOTH_QUEUED)
		return
	thing.smooth |= SMOOTH_QUEUED
	smooth_queue += thing
	if(!can_fire)
		can_fire = TRUE

/datum/controller/subsystem/icon_smooth/proc/remove_from_queues(atom/thing)
	thing.smooth &= ~SMOOTH_QUEUED
	smooth_queue -= thing
	deferred -= thing

/datum/controller/subsystem/icon_smooth/proc/add_halt_source(datum/source)
	halt_sources += source

/datum/controller/subsystem/icon_smooth/proc/remove_halt_source(datum/source)
	halt_sources -= source
