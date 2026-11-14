SUBSYSTEM_DEF(overmap_visuals)
	name = "Overmap Visuals"
	wait = OVERMAP_FLIGHT_TICK
	priority = FIRE_PRIORITY_DEFAULT / 2
	ss_flags = SS_KEEP_TIMING
	runlevels = RUNLEVEL_SETUP | RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	dependencies = list(/datum/controller/subsystem/overmap)
	var/list/pending = list()
	var/list/currentrun = list()
	var/list/last_updates = list()

/datum/controller/subsystem/overmap_visuals/Initialize()
	return SS_INIT_SUCCESS

/datum/controller/subsystem/overmap_visuals/Destroy()
	pending = null
	currentrun = null
	last_updates = null
	return ..()

/datum/controller/subsystem/overmap_visuals/get_metrics()
	. = ..()
	.["custom"] = list("pending" = length(pending), "current" = length(currentrun))

/datum/controller/subsystem/overmap_visuals/proc/queue_update(datum/owner)
	if(!(owner in currentrun))
		pending[owner] = TRUE

/datum/controller/subsystem/overmap_visuals/proc/remove(datum/owner)
	pending -= owner
	currentrun -= owner
	last_updates -= owner

/datum/controller/subsystem/overmap_visuals/get_stat_details()
	return "Pending:[length(pending)]|Current:[length(currentrun)]"

/datum/controller/subsystem/overmap_visuals/fire(resumed)
	if(!resumed)
		currentrun = pending
		pending = list()
	while(length(currentrun))
		var/datum/owner = currentrun[1]
		currentrun -= owner
		if(!QDELETED(owner))
			var/elapsed = isnull(last_updates[owner]) ? OVERMAP_FLIGHT_TICK : max(1, world.time - last_updates[owner])
			last_updates[owner] = world.time
			if(istype(owner, /obj/overmap/entity))
				var/obj/overmap/entity/vessel = owner
				vessel.update_flight_visuals(elapsed)
			else if(istype(owner, /datum/overmap_bubble))
				var/datum/overmap_bubble/bubble = owner
				bubble.update_flight_visuals(elapsed)
		else
			last_updates -= owner
		if(MC_TICK_CHECK)
			return
	SSovermap.update_proxy_huds()
