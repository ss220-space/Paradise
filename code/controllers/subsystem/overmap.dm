GLOBAL_LIST_EMPTY(ship_engines)
GLOBAL_LIST_EMPTY(helm_computers)
GLOBAL_LIST_EMPTY(engine_consoles)
GLOBAL_LIST_EMPTY(transponders)
GLOBAL_LIST_EMPTY(sensor_computers)
GLOBAL_LIST_EMPTY(sensor_arrays)
GLOBAL_LIST_EMPTY(overmap_request_consoles)
GLOBAL_LIST_EMPTY(navmap_computers)
GLOBAL_LIST_EMPTY(overmap_intercoms)

SUBSYSTEM_DEF(overmap)
	name = "Overmap"
	wait = 10
	ss_flags = SS_KEEP_TIMING
	runlevels = RUNLEVEL_SETUP | RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	dependencies = list(
		/datum/controller/subsystem/mapping,
		/datum/controller/subsystem/atoms,
		/datum/controller/subsystem/shuttle,
	)

	var/list/datum/overmap_sector/sectors = list()
	var/datum/overmap_sector/local_sector
	var/datum/overmap_sector/station_sector
	var/datum/overmap_sector/service_sector
	var/obj/overmap/entity/station_entity
	var/obj/overmap/planet/lavaland_planet
	var/obj/overmap/entity/planet_station/lavaland_entity
	var/list/obj/overmap/entity/service_site/service_sites = list()
	var/list/obj/overmap/entity/service_site/service_sites_by_area = list()
	var/list/obj/overmap/entity/vessels = list()
	var/list/obj/overmap/entity/shuttle_vessels = list()
	var/list/obj/overmap/entity/pod_vessels = list()
	var/list/obj/overmap/feature/hazard/hazards = list()
	var/list/datum/overmap_feature/ruin_sites = list()
	var/list/ruin_space_zs = list()
	var/list/datum/component/overmap_flight/flights = list()
	var/list/datum/component/overmap_dock_host/dock_hosts = list()
	var/list/obj/docking_port/mobile/area_shuttles = list()
	var/area_shuttle_cache_ready = FALSE
	var/last_fire_time = 0
	var/iff_key_centcom
	var/iff_key_syndicate

/proc/generate_overmap_iff_key()
	var/alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
	. = ""
	for(var/i in 1 to OVERMAP_IFF_KEY_LEN)
		var/index = rand(1, length(alphabet))
		. += copytext(alphabet, index, index + 1)

/datum/controller/subsystem/overmap/Initialize()
	iff_key_centcom = generate_overmap_iff_key()
	iff_key_syndicate = generate_overmap_iff_key()
	while(iff_key_syndicate == iff_key_centcom)
		iff_key_syndicate = generate_overmap_iff_key()
	station_sector = new /datum/overmap_sector/station
	local_sector = station_sector
	sectors[station_sector.id] = station_sector
	spawn_lavaland()
	spawn_station()
	spawn_service_sector()
	spawn_hyperrelays()
	register_roundstart_shuttles()
	register_roundstart_pods()
	stamp_pad_hosts()
	relink_hardware()
	ensure_station_transponder()
	station_sector?.populate_roundstart()
	spawn_roundstart_ruin_sites()
	start_programmed_roundstart_routes()
	snap_roundstart_docks()
	seed_shuttle_helm_waypoints()
	last_fire_time = world.time
	return SS_INIT_SUCCESS

/datum/controller/subsystem/overmap/proc/refresh_sector_views(datum/overmap_sector/sector)
	if(!sector)
		return
	for(var/obj/overmap/entity/vessel as anything in vessels)
		if(QDELETED(vessel) || vessel.sector != sector)
			continue
		SEND_SIGNAL(vessel, COMSIG_OVERMAP_DISPLAY_CHANGED)

/datum/controller/subsystem/overmap/fire(resumed)
	var/elapsed = world.time - last_fire_time
	last_fire_time = world.time
	if(elapsed <= 0)
		return
	for(var/obj/overmap/entity/vessel as anything in vessels)
		if(QDELETED(vessel))
			continue
		if(vessel.transponder?.distress)
			vessel.process_transponder_fx()
		vessel.process_sensors()
		vessel.programmed_mission?.process_mission()
	for(var/datum/component/overmap_flight/flight as anything in flights)
		if(QDELETED(flight))
			continue
		flight.process_tick(elapsed)
	for(var/obj/overmap/feature/hazard/hazard as anything in hazards)
		if(QDELETED(hazard))
			continue
		hazard.process_tick(elapsed)

/datum/controller/subsystem/overmap/proc/create_sector(sector_id, sector_name, size, access_flags)
	if(sectors[sector_id])
		return sectors[sector_id]
	var/datum/overmap_sector/sector = new(sector_id, sector_name, size, access_flags)
	sectors[sector_id] = sector
	return sector

/datum/controller/subsystem/overmap/proc/create_typed_sector(sector_type)
	var/datum/overmap_sector/sector = new sector_type
	if(sectors[sector.id])
		qdel(sector)
		return sectors[sector.id]
	sectors[sector.id] = sector
	return sector

/datum/controller/subsystem/overmap/proc/spawn_station()
	if(!local_sector)
		return
	var/turf/spawn_turf
	var/turf/dock = lavaland_entity?.get_overmap_turf()
	if(dock)
		spawn_turf = local_sector.get_turf_near(dock, OVERMAP_STATION_MIN_SEPARATION, OVERMAP_STATION_MAX_SEPARATION, lavaland_planet)
	if(!spawn_turf)
		spawn_turf = local_sector.get_random_open_turf()
	station_entity = new /obj/overmap/entity/station(spawn_turf)
	station_entity.name = station_name()
	station_entity.status = OVERMAP_STATUS_OVERMAP
	local_sector.add_object(station_entity, spawn_turf)
	log_world("Overmap: station token spawned at [spawn_turf.x],[spawn_turf.y] on sector [local_sector.id].")

/datum/controller/subsystem/overmap/proc/lavaland_enabled()
	if(CONFIG_GET(flag/disable_lavaland))
		return FALSE
	if(SSmapping?.map_datum?.disables & DISABLE_LAVALAND)
		return FALSE
	return length(levels_by_trait(ORE_LEVEL)) > 0

/datum/controller/subsystem/overmap/proc/spawn_lavaland()
	if(!local_sector || !lavaland_enabled())
		return
	var/turf/origin = local_sector.get_centered_footprint_origin(OVERMAP_LAVALAND_FOOTPRINT)
	if(!origin)
		log_world("Overmap: failed to place Lavaland at sector center.")
		return
	lavaland_planet = new /obj/overmap/planet/lavaland(origin)
	local_sector.add_object(lavaland_planet, origin)
	var/list/footprint = lavaland_planet.footprint_turfs()
	if(!length(footprint))
		footprint = list(origin)
	var/turf/outpost_turf = pick(footprint)
	lavaland_entity = new /obj/overmap/entity/planet_station/lavaland(outpost_turf)
	lavaland_entity.planet = lavaland_planet
	lavaland_planet.outpost = lavaland_entity
	lavaland_entity.name = "Лаваленд"
	lavaland_entity.movable = FALSE
	lavaland_entity.halted = TRUE
	local_sector.add_object(lavaland_entity, outpost_turf)
	log_world("Overmap: Lavaland centered at [origin.x],[origin.y] 4×4, mining station at [outpost_turf.x],[outpost_turf.y].")

/datum/controller/subsystem/overmap/proc/rebuild_area_shuttle_cache()
	area_shuttles = list()
	for(var/obj/docking_port/mobile/shuttle as anything in SSshuttle.mobile)
		for(var/area/place as anything in shuttle.shuttle_areas)
			area_shuttles[place] = shuttle
	area_shuttle_cache_ready = TRUE

/datum/controller/subsystem/overmap/proc/get_shuttle_at(atom/source)
	var/area/here = get_area(source)
	if(!here)
		return null
	if(!area_shuttle_cache_ready)
		rebuild_area_shuttle_cache()
	return area_shuttles[here]

/datum/controller/subsystem/overmap/proc/overmap_world_ready()
	return !!local_sector

/datum/controller/subsystem/overmap/proc/ensure_shuttle_overmap_placement(obj/overmap/entity/vessel)
	if(QDELETED(vessel) || !overmap_world_ready())
		return
	if(vessel.docked_to && !vessel.sector)
		if(vessel.docked_to.sector)
			vessel.sector = vessel.docked_to.sector
			vessel.docked_to.sector.objects |= vessel
		return
	if(isturf(vessel.loc) && vessel.sector)
		return
	if(vessel.docked_to)
		return
	attach_shuttle_to_resolved_host(vessel)

/datum/controller/subsystem/overmap/proc/get_or_register_shuttle(obj/docking_port/mobile/shuttle)
	if(!shuttle)
		return null
	var/obj/overmap/entity/existing = shuttle_vessels[shuttle]
	if(existing && !QDELETED(existing))
		ensure_shuttle_overmap_placement(existing)
		return existing
	// Request consoles LateInitialize before sectors exist. Creating a token
	// here leaves loc/sector null forever because register_roundstart returns existing.
	if(!overmap_world_ready())
		return null
	var/obj/overmap/entity/shuttle/vessel = new /obj/overmap/entity/shuttle
	vessel.name = shuttle.name || "Shuttle"
	vessel.shuttle = shuttle
	shuttle_vessels[shuttle] = vessel
	vessel.last_dock_id = shuttle.getDockedId()
	vessel.selected_dock_id = vessel.last_dock_id
	area_shuttle_cache_ready = FALSE
	vessel.bind_shuttle_signals()
	vessel.recalculate_mass()
	attach_shuttle_to_resolved_host(vessel)
	vessel.setup_programmed_defaults()
	notify_vessel_registered(vessel)
	return vessel

/datum/controller/subsystem/overmap/proc/register_roundstart_pods()
	for(var/obj/spacepod/craft as anything in GLOB.spacepods_list)
		if(!QDELETED(craft))
			get_or_register_pod(craft)

/datum/controller/subsystem/overmap/proc/get_or_register_pod(obj/spacepod/craft)
	if(!craft)
		return null
	var/obj/overmap/entity/pod/existing = pod_vessels[craft]
	if(existing && !QDELETED(existing))
		return existing
	var/obj/overmap/entity/pod/vessel = new /obj/overmap/entity/pod
	vessel.pod = craft
	vessel.name = craft.name || "spacepod"
	craft.overmap_vessel = vessel
	pod_vessels[craft] = vessel
	craft.ensure_overmap_gear()
	attach_pod_to_host(vessel)
	notify_vessel_registered(vessel)
	return vessel

/datum/controller/subsystem/overmap/proc/resolve_pod_host(obj/spacepod/craft)
	if(!craft)
		return null
	var/obj/docking_port/mobile/shuttle = get_shuttle_at(craft)
	if(shuttle)
		return get_or_register_shuttle(shuttle)
	var/obj/overmap/entity/service_site/site = get_service_site(craft)
	if(site)
		return site
	var/turf/spot = get_turf(craft)
	if(!spot)
		return null
	if(is_station_level(spot.z))
		return station_entity
	if(is_mining_level(spot.z))
		return lavaland_entity
	return null

/datum/controller/subsystem/overmap/proc/attach_pod_to_host(obj/overmap/entity/pod/vessel)
	if(!vessel?.pod)
		return
	if(vessel.overmap_pod?.is_in_own_pocket())
		return
	var/obj/overmap/entity/host = resolve_pod_host(vessel.pod)
	if(!host || host == vessel)
		if(local_sector && !isturf(vessel.loc))
			var/turf/fallback = local_sector.get_random_open_turf()
			local_sector.add_object(vessel, fallback)
			vessel.status = OVERMAP_STATUS_OVERMAP
		return
	vessel.nest_inside(host)
	if(host.sector)
		vessel.sector = host.sector
		host.sector.objects |= vessel

/datum/controller/subsystem/overmap/proc/register_roundstart_shuttles()
	for(var/obj/docking_port/mobile/shuttle as anything in SSshuttle.mobile)
		if(QDELETED(shuttle) || !shuttle.id)
			continue
		get_or_register_shuttle(shuttle)

/datum/controller/subsystem/overmap/proc/get_host_by_key(host_key)
	if(!host_key)
		return null
	switch(host_key)
		if(OVERMAP_HOST_STATION)
			return station_entity
		if(OVERMAP_HOST_LAVALAND)
			return lavaland_entity
	return service_sites[host_key]

/datum/controller/subsystem/overmap/proc/sector_for_turf(turf/spot)
	if(!spot)
		return null
	for(var/sector_id in sectors)
		var/datum/overmap_sector/candidate = sectors[sector_id]
		if(candidate?.contains_turf(spot))
			return candidate
	return null

/datum/controller/subsystem/overmap/proc/host_key_for(obj/overmap/entity/host)
	if(!host)
		return null
	if(host == station_entity)
		return OVERMAP_HOST_STATION
	if(host == lavaland_entity)
		return OVERMAP_HOST_LAVALAND
	var/obj/overmap/entity/service_site/site = host
	if(istype(site))
		return site.site_id
	return null

/datum/controller/subsystem/overmap/proc/stamp_pad_hosts()
	if(!SSshuttle)
		return
	for(var/obj/docking_port/stationary/pad as anything in SSshuttle.stationary)
		host_for_pad(pad)

/datum/controller/subsystem/overmap/proc/host_for_pad(obj/docking_port/stationary/pad, obj/docking_port/mobile/shuttle)
	if(!pad || istype(pad, /obj/docking_port/stationary/transit))
		return null
	if(pad.overmap_host_uid)
		var/obj/overmap/entity/bound = locateUID(pad.overmap_host_uid)
		if(istype(bound))
			return bound
	var/host_key = GLOB.overmap_dock_hosts[pad.id]
	if(!host_key && is_station_level(pad.z))
		host_key = OVERMAP_HOST_STATION
	else if(!host_key && is_mining_level(pad.z))
		host_key = OVERMAP_HOST_LAVALAND
	if(!host_key)
		var/obj/overmap/entity/service_site/site = get_service_site(pad)
		if(site)
			pad.overmap_host_uid = site.UID()
			return site
	if(!host_key && shuttle && is_admin_level(pad.z))
		host_key = GLOB.overmap_shuttle_admin_hosts[shuttle.id]
	var/obj/overmap/entity/host = get_host_by_key(host_key)
	if(host)
		pad.overmap_host_uid = host.UID()
	return host

/datum/controller/subsystem/overmap/proc/resolve_nest_host(obj/docking_port/mobile/shuttle, obj/docking_port/stationary/pad)
	if(!pad)
		pad = shuttle?.get_docked()
	if(pad && !istype(pad, /obj/docking_port/stationary/transit))
		var/obj/overmap/entity/host = host_for_pad(pad, shuttle)
		if(host)
			return host
	var/turf/spot = get_turf(shuttle)
	if(!shuttle || !spot)
		return null
	if(is_admin_level(spot.z))
		return get_host_by_key(GLOB.overmap_shuttle_admin_hosts[shuttle.id])
	if(is_station_level(spot.z))
		return station_entity
	if(is_mining_level(spot.z))
		return lavaland_entity
	return get_service_site(shuttle)

/datum/controller/subsystem/overmap/proc/start_programmed_roundstart_routes()
	for(var/shuttle_id in GLOB.overmap_programmed_profiles)
		var/datum/overmap_programmed_profile/profile = GLOB.overmap_programmed_profiles[shuttle_id]
		if(!profile?.autostart_dock_id)
			continue
		var/obj/docking_port/mobile/shuttle = SSshuttle.getShuttle(shuttle_id)
		if(!shuttle)
			continue
		if(shuttle.getDockedId() == profile.autostart_dock_id)
			continue
		var/obj/overmap/entity/vessel = shuttle_vessels[shuttle]
		if(!vessel?.programmed)
			continue
		if(vessel.start_programmed_route(profile.autostart_dock_id, profile.autostart_skip_windup) == TRUE)
			vessel.programmed_mission?.process_mission()

/datum/controller/subsystem/overmap/proc/attach_shuttle_to_resolved_host(obj/overmap/entity/vessel)
	if(!vessel?.shuttle)
		return
	var/obj/overmap/entity/host = resolve_nest_host(vessel.shuttle)
	if(!host || host == vessel)
		if(local_sector && !vessel.loc)
			var/turf/fallback = local_sector.get_random_open_turf()
			local_sector.add_object(vessel, fallback)
			vessel.status = OVERMAP_STATUS_OVERMAP
		return
	vessel.nest_inside(host)
	if(host.sector)
		vessel.sector = host.sector
		host.sector.objects |= vessel

/datum/controller/subsystem/overmap/proc/spawn_service_sector()
	service_sector = create_typed_sector(/datum/overmap_sector/service)
	if(!service_sector)
		return
	var/list/site_paths = subtypesof(/obj/overmap/entity/service_site)
	shuffle_inplace(site_paths)
	for(var/site_path in site_paths)
		var/obj/overmap/entity/service_site/site_type = site_path
		if(initial(site_type.abstract_type) == site_path)
			continue
		var/turf/spot = service_sector.get_random_open_turf()
		if(!spot)
			log_world("Overmap: no turf for service site [site_path].")
			continue
		var/obj/overmap/entity/service_site/site = new site_path(spot)
		service_sector.add_object(site, spot)
		log_world("Overmap: service site [site.site_id] at [spot.x],[spot.y] on sector [service_sector.id].")

/datum/controller/subsystem/overmap/proc/register_service_site(obj/overmap/entity/service_site/site)
	if(!site?.site_id)
		return
	service_sites[site.site_id] = site
	if(site.area_root)
		service_sites_by_area[site.area_root] = site

/datum/controller/subsystem/overmap/proc/unregister_service_site(obj/overmap/entity/service_site/site)
	if(!site)
		return
	if(service_sites[site.site_id] == site)
		service_sites -= site.site_id
	if(site.area_root && service_sites_by_area[site.area_root] == site)
		service_sites_by_area -= site.area_root

/datum/controller/subsystem/overmap/proc/get_service_site(atom/source)
	var/area/here = isarea(source) ? source : get_area(source)
	if(!here)
		return null
	for(var/area_type in service_sites_by_area)
		if(istype(here, area_type))
			return service_sites_by_area[area_type]
	return null

/datum/controller/subsystem/overmap/proc/resolve_vessel(atom/source)
	var/atom/cursor = source
	while(cursor && !isturf(cursor) && !isarea(cursor))
		if(isspacepod(cursor))
			return get_or_register_pod(cursor)
		cursor = cursor.loc
	var/obj/docking_port/mobile/shuttle = get_shuttle_at(source)
	if(shuttle)
		return get_or_register_shuttle(shuttle)
	var/obj/overmap/entity/service_site/site = get_service_site(source)
	if(site)
		return site
	if(is_station_level(source.z))
		return station_entity
	if(is_mining_level(source.z))
		return lavaland_entity
	return null

/datum/controller/subsystem/overmap/proc/relink_hardware()
	for(var/obj/machinery/ship_engine/engine as anything in GLOB.ship_engines)
		if(!QDELETED(engine) && !engine.vessel)
			engine.link_vessel()
	for(var/obj/machinery/computer/helm/helm as anything in GLOB.helm_computers)
		if(!QDELETED(helm) && !helm.vessel)
			helm.link_vessel()
	for(var/obj/machinery/computer/engines/console as anything in GLOB.engine_consoles)
		if(!QDELETED(console) && !console.vessel)
			console.link_vessel()
	for(var/obj/machinery/transponder/transponder as anything in GLOB.transponders)
		if(!QDELETED(transponder) && !transponder.vessel)
			transponder.link_vessel()
	for(var/obj/machinery/computer/sensors/sensor as anything in GLOB.sensor_computers)
		if(!QDELETED(sensor) && !sensor.vessel)
			sensor.link_vessel()
	for(var/obj/machinery/sensor_array/array as anything in GLOB.sensor_arrays)
		if(!QDELETED(array) && !array.vessel)
			array.link_vessel()
	for(var/obj/machinery/computer/navmap/monitor as anything in GLOB.navmap_computers)
		if(!QDELETED(monitor) && !monitor.vessel)
			monitor.link_vessel()
	for(var/obj/machinery/overmap_intercom/panel as anything in GLOB.overmap_intercoms)
		if(!QDELETED(panel) && !panel.vessel)
			panel.link_vessel()
	for(var/obj/machinery/computer/shuttle/console as anything in GLOB.overmap_request_consoles)
		if(!QDELETED(console))
			console.bind_overmap_notices()

/datum/controller/subsystem/overmap/proc/notify_vessel_registered(obj/overmap/entity/vessel)
	if(!initialized || QDELETED(vessel))
		return
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_OVERMAP_VESSEL_REGISTERED, vessel)
	relink_hardware()

/datum/controller/subsystem/overmap/proc/ensure_station_transponder()
	for(var/obj/machinery/transponder/existing as anything in GLOB.transponders)
		if(istype(existing, /obj/machinery/transponder/station) && !QDELETED(existing))
			return
	for(var/obj/machinery/computer/helm/helm as anything in GLOB.helm_computers)
		if(QDELETED(helm) || istype(helm, /obj/machinery/computer/helm/pod) || isspacepod(helm.loc))
			continue
		if(get_shuttle_at(helm) || !is_station_level(helm.z))
			continue
		new /obj/machinery/transponder/station(get_turf(helm))
		return

/datum/controller/subsystem/overmap/proc/spawn_portal(datum/overmap_sector/from_sector, dest_sector_id, portal_name, required_flags, dest_x, dest_y)
	if(!from_sector)
		from_sector = local_sector
	var/datum/overmap_sector/target = sectors[dest_sector_id]
	if(!target)
		return null
	var/turf/here = from_sector.get_random_open_turf()
	var/obj/overmap/portal/portal = new(here)
	portal.name = portal_name || "warp portal"
	portal.destination_sector = target
	portal.destination_x = dest_x || round(target.size / 2)
	portal.destination_y = dest_y || round(target.size / 2)
	portal.required_vessel_flags = required_flags
	from_sector.add_object(portal, here)
	return portal
