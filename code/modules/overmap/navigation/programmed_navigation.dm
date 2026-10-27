/datum/overmap_programmed_mission/proc/resume_after_relay()
	phase = OVERMAP_PROG_FLY
	navigation_step = 0
	navigation_dock_prepared = FALSE
	navigation_beacons = null
	try_fly()

/datum/overmap_programmed_mission/proc/prepare_navigation()
	var/obj/docking_port/stationary/pad = SSshuttle.getDock(dock_id, warn = FALSE)
	var/obj/overmap/entity/host = resolved_dest_host()
	if(!pad || !host || host.sector != vessel.sector)
		return FALSE
	SSovermap.ensure_host_space(host)
	if(QDELETED(src) || QDELETED(vessel))
		return FALSE
	vessel.apply_programmed_collar(dock_id)
	vessel.selected_dock_id = dock_id
	if(!vessel.docking_approach)
		if(host.shuttle)
			for(var/list/collar as anything in host.hull_collars)
				if(collar[1] != get_turf(pad.dock_airlock))
					continue
				vessel.docking_approach = vessel.dock_candidate(collar, host)
				break
		else
			var/datum/overmap_docking_approach/approach = new(vessel)
			approach.pad = pad
			approach.space = host.physical_space
			if(SSovermap.station_docking_zone?.accepts_pad(pad))
				approach.space = null
				approach.target_x = SSovermap.station_docking_zone.get_world_x()
				approach.target_y = SSovermap.station_docking_zone.get_world_y()
			if(!approach.space)
				if(isnull(approach.target_x))
					approach.target_x = host.get_world_x()
					approach.target_y = host.get_world_y()
			var/list/origin = vessel.shuttle.overmap_origin()
			approach.target_facing = vessel.shuttle.overmap_dir_rotation(origin[2], vessel.shuttle.overmap_dest_dir(pad, origin[2]))
	if(!vessel.docking_approach)
		return FALSE
	if(!vessel.docking_approach.update_target())
		return FALSE
	if(!navigation_beacons)
		navigation_beacons = list()
		if(!SSovermap.station_docking_zone?.accepts_pad(pad))
			for(var/obj/effect/landmark/overmap_navigation_beacon/beacon as anything in GLOB.overmap_navigation_beacons)
				if(beacon.dock_id == dock_id && beacon.z == pad.z && (beacon.dir in GLOB.cardinal))
					navigation_beacons += beacon
		sortTim(navigation_beacons, GLOBAL_PROC_REF(cmp_overmap_navigation_beacon))
		if(!length(navigation_beacons))
			navigation_step = max(navigation_step, 1)
	navigation_dock_prepared = TRUE
	return TRUE

/datum/overmap_programmed_mission/proc/continue_navigation()
	if(!navigation_dock_prepared && !prepare_navigation())
		return
	var/obj/overmap/entity/host = resolved_dest_host()
	var/datum/overmap_docking_approach/approach = vessel.docking_approach
	if(!approach || !host)
		navigation_dock_prepared = FALSE
		return
	if(!approach.update_target())
		navigation_dock_prepared = FALSE
		return
	var/world_x
	var/world_y
	var/heading
	if(navigation_step <= length(navigation_beacons) && length(navigation_beacons))
		var/obj/effect/landmark/overmap_navigation_beacon/beacon = navigation_beacons[max(navigation_step, 1)]
		if(QDELETED(beacon))
			vessel.flight.stop_blocked_navigation()
			return
		var/list/point = beacon.world_point(host)
		if(!point)
			return
		heading = dir2angle(beacon.dir) + (host.shuttle ? host.get_facing() : 0)
		world_x = point[1]
		world_y = point[2]
		if(!navigation_step)
			var/lead = max(beacon.lead_distance, vessel.hull_radius * 2 + 4)
			world_x -= sin(heading) * lead
			world_y -= cos(heading) * lead
	else
		world_x = approach.target_x
		world_y = approach.target_y
		heading = approach.target_facing
		if(navigation_step <= length(navigation_beacons) + 1)
			var/obj/docking_port/stationary/pad = approach.pad
			var/outward = approach.target ? approach.target[3] + (approach.host ? host.get_facing() : 0) : dir2angle(pad.dir)
			var/lead = max(vessel.hull_radius * 3 + 8, 20)
			world_x += sin(outward) * lead
			world_y += cos(outward) * lead
			var/list/extent = approach.space?.navigation_box()
			if(QDELETED(src) || QDELETED(vessel) || vessel.docking_approach != approach)
				return
			if(extent)
				var/margin = vessel.hull_radius + 4
				if(sin(outward) > 0.5)
					world_x = max(world_x, extent[3] + margin)
				else if(sin(outward) < -0.5)
					world_x = min(world_x, extent[1] - margin)
				if(cos(outward) > 0.5)
					world_y = max(world_y, extent[4] + margin)
				else if(cos(outward) < -0.5)
					world_y = min(world_y, extent[2] - margin)
	vessel.flight.navigate_world(world_x, world_y, heading, host)

/datum/overmap_programmed_mission/proc/navigation_arrived()
	if(phase != OVERMAP_PROG_FLY)
		return
	if(departure_pending)
		departure_step++
		if(!continue_departure())
			try_fly()
		return
	if(needs_hyperrelay())
		on_overmap_arrived()
		return
	if(navigation_step >= length(navigation_beacons) + 2)
		phase = OVERMAP_PROG_DOCK
		try_dock()
		return
	navigation_step++
	if(length(navigation_beacons) && navigation_step == length(navigation_beacons) + 1)
		navigation_step++
	continue_navigation()

/datum/overmap_programmed_mission/proc/dock_from_navigation()
	if(vessel.status == OVERMAP_STATUS_DOCKED && vessel.shuttle?.getDockedId() == dock_id)
		var/datum/overmap_programmed_profile/profile = vessel.programmed_profile()
		profile?.announce_arrive(dock_id)
		qdel(src)
		return
	var/obj/overmap/entity/host = resolved_dest_host()
	if((vessel.docked_ship && vessel.docked_ship == host) || (host && host.docked_ship == vessel))
		qdel(src)
		return
	if(vessel.docking_approach?.aligning || world.time < next_dock_try || vessel.shuttle?.transfer_busy)
		return
	if(!vessel.docking_approach && !prepare_navigation())
		fail_dock("Док не найден.")
		return
	if(!vessel.docking_approach.available())
		fail_dock("Док занят или заход перекрыт.")
		return
	var/result = vessel.docking_approach.start_alignment()
	if(result == TRUE)
		return
	phase = OVERMAP_PROG_FLY
	navigation_step = length(navigation_beacons) + 2
	continue_navigation()

/datum/overmap_programmed_mission/proc/continue_departure()
	if(!departure_beacons)
		departure_beacons = list()
		var/obj/docking_port/stationary/pad = SSshuttle.getDock(departure_dock_id, warn = FALSE)
		departure_host = pad ? SSovermap.host_for_pad(pad, vessel.shuttle) : null
		if(departure_host?.project_terrain && !departure_host.dock_host?.planet_landing && !SSovermap.station_docking_zone?.accepts_pad(pad))
			SSovermap.ensure_host_space(departure_host)
			for(var/obj/effect/landmark/overmap_navigation_beacon/beacon as anything in GLOB.overmap_navigation_beacons)
				if(beacon.dock_id == departure_dock_id && beacon.z == pad.z && (beacon.dir in GLOB.cardinal))
					departure_beacons += beacon
			sortTim(departure_beacons, GLOBAL_PROC_REF(cmp_overmap_navigation_beacon))
	if(!length(departure_beacons) || QDELETED(departure_host) || departure_host.sector != vessel.sector || departure_step > length(departure_beacons) + 1)
		departure_pending = FALSE
		return FALSE
	var/index = max(1, length(departure_beacons) - departure_step + 1)
	var/obj/effect/landmark/overmap_navigation_beacon/beacon = departure_beacons[index]
	if(QDELETED(beacon))
		departure_pending = FALSE
		return FALSE
	var/list/point = beacon.world_point(departure_host)
	if(!point)
		departure_pending = FALSE
		return FALSE
	var/heading = dir2angle(beacon.dir) + (departure_host.shuttle ? departure_host.get_facing() : 0)
	if(departure_step > length(departure_beacons))
		var/lead = max(beacon.lead_distance, vessel.hull_radius * 2 + 4)
		point[1] -= sin(heading) * lead
		point[2] -= cos(heading) * lead
	vessel.flight.navigate_world(point[1], point[2], heading, departure_host)
	return TRUE
