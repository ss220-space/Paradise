/obj/overmap/entity/proc/ensure_virtual_engine()
	if(length(engines))
		return
	if(virtual_engine && !QDELETED(virtual_engine))
		return
	virtual_engine = new /obj/machinery/ship_engine/virtual(null)
	register_engine(virtual_engine)

/obj/overmap/entity/proc/snap_physical_redock()
	if(!shuttle)
		return FALSE
	var/obj/docking_port/stationary/pad = shuttle.get_docked()
	if(!pad || istype(pad, /obj/docking_port/stationary/transit))
		return FALSE
	shuttle.unlockPortDoors(pad)
	for(var/obj/machinery/door/airlock/A in GLOB.airlocks)
		if(A.id_tag == pad.id && A.locked)
			A.unlock(TRUE)
	for(var/area/place as anything in shuttle.shuttle_areas)
		for(var/obj/machinery/door/airlock/external/docking/door in place)
			if(door.locked)
				door.unlock(TRUE)
	pad.dock_airlock?.sync_overmap_bolts()
	return TRUE

/datum/controller/subsystem/overmap/proc/snap_roundstart_docks()
	for(var/obj/docking_port/mobile/shuttle as anything in SSshuttle.mobile)
		if(QDELETED(shuttle))
			continue
		var/obj/overmap/entity/vessel = shuttle_vessels[shuttle]
		vessel?.snap_physical_redock()

/datum/controller/subsystem/overmap/proc/seed_shuttle_helm_waypoints()
	for(var/obj/machinery/computer/shuttle/console in GLOB.machines)
		if(QDELETED(console) || !console.shuttleId || !console.possible_destinations)
			continue
		if(console.uses_overmap_programmed_ui())
			continue
		var/obj/overmap/entity/vessel = shuttle_vessels[SSshuttle.getShuttle(console.shuttleId)]
		if(!vessel)
			continue
		for(var/dock_id in params2list(console.possible_destinations))
			vessel.seed_helm_waypoint_from_dock(dock_id)

/obj/overmap/entity/proc/seed_helm_waypoint_from_dock(dock_id)
	if(!dock_id)
		return
	var/obj/docking_port/stationary/pad = SSshuttle.getDock(dock_id)
	if(!pad)
		return
	var/obj/overmap/entity/host = SSovermap?.host_for_pad(pad, shuttle)
	var/turf/spot = host?.get_overmap_turf()
	if(!spot || !host.sector)
		return
	var/mark_x = host.sector.coord_x(spot)
	var/mark_y = host.sector.coord_y(spot)
	var/label = pad.overmap_dock_label || pad.name || dock_id
	for(var/obj/machinery/computer/helm/helm as anything in helms)
		if(QDELETED(helm))
			continue
		if(!helm.preset_waypoints)
			helm.preset_waypoints = list()
		helm.preset_waypoints[label] = list("x" = mark_x, "y" = mark_y)

/obj/docking_port/mobile/proc/overmap_follow_programmed_leg(dock_id)
	if(!SSovermap?.initialized)
		return FALSE
	var/obj/overmap/entity/vessel = SSovermap.shuttle_vessels[src]
	if(!vessel?.programmed)
		return FALSE
	if(getDockedId() == dock_id && vessel.status == OVERMAP_STATUS_DOCKED)
		vessel.snap_physical_redock()
		return TRUE
	if(vessel.programmed_mission)
		if(vessel.programmed_mission.dock_id != dock_id)
			vessel.abort_programmed_mission()
		else if(getDockedId() == dock_id && vessel.status == OVERMAP_STATUS_DOCKED)
			return TRUE
		else
			setTimer(max(20, vessel.estimate_programmed_trip(dock_id, vessel.programmed_mission)))
			return null
	var/result = vessel.start_programmed_route(dock_id, TRUE, TRUE)
	if(result != TRUE)
		return FALSE
	if(getDockedId() == dock_id && vessel.status == OVERMAP_STATUS_DOCKED)
		return TRUE
	setTimer(max(20, vessel.estimate_programmed_trip(dock_id, vessel.programmed_mission)))
	return null

/obj/docking_port/mobile/emergency/proc/overmap_launch_escape_pods()
	for(var/obj/docking_port/mobile/pod/pod as anything in SSshuttle.mobile)
		if(!istype(pod) || !is_station_level(pod.z))
			continue
		if(pod.overmap_follow_programmed_leg("[pod.id]_away") == FALSE)
			pod.enterTransit()
