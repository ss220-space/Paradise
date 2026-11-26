/obj/overmap/entity/service_site
	identity_locked = TRUE
	identity_icon = "station"
	abstract_type = /obj/overmap/entity/service_site
	name = "service site"
	project_terrain = FALSE
	movable = FALSE
	halted = TRUE
	vessel_mass = OVERMAP_MASS_STATION
	overmap_hazard_immune = TRUE
	var/site_id
	var/spawn_sector_id = OVERMAP_SECTOR_ID_SERVICE
	var/area/area_root

/datum/controller/subsystem/overmap/proc/spawn_service_sites()
	for(var/obj/overmap/entity/service_site/site_type as anything in shuffle(valid_subtypesof(/obj/overmap/entity/service_site)))
		var/datum/overmap_sector/sector = configured_map_sector(initial(site_type.spawn_sector_id), service_sector, initial(site_type.name))
		if(!sector.place_guaranteed_spawn(site_type))
			log_world("Overmap: could not place guaranteed [site_type] in [sector.id].")

/obj/overmap/entity/service_site/Initialize(mapload)
	. = ..()
	SSovermap?.register_service_site(src)
	apply_overmap_identity(identity_name || name, identity_color || map_color, identity_icon, identity_distress, identity_broadcasting, identity_iff_ids, identity_locked)

/obj/overmap/entity/service_site/Destroy()
	SSovermap?.unregister_service_site(src)
	return ..()

/obj/overmap/entity/service_site/add_overmap_components()
	AddComponent(/datum/component/overmap_sensors)
	AddComponent(/datum/component/overmap_dock_host, OVERMAP_DOCK_Z_SERVICE, area_root, FALSE)

/obj/overmap/entity/service_site/get_overmap_display_name()
	return identity_name || name

/obj/overmap/entity/proc/service_dock_host()
	RETURN_TYPE(/obj/overmap/entity/service_site)
	if(!sector || !in_free_flight() || atmosphere || relay_capture || docked_ship || length(docked_guests) || docking_approach || shuttle?.transfer_busy || is_programmed_locked())
		return null
	var/turf/here = get_overmap_turf()
	var/obj/overmap/entity/service_site/site = locate() in here
	if(site && get_dock_host() == site)
		return site

/obj/overmap/entity/service_site/proc/dock_options(obj/overmap/entity/vessel)
	var/list/options = list()
	for(var/obj/docking_port/stationary/pad as anything in SSshuttle.stationary)
		if(QDELETED(pad) || pad.hidden || !vessel.pad_matches_host(pad, src))
			continue
		if(vessel.overmap_pod)
			if(!pod_landing_turf(pad))
				continue
		else if(!vessel.overmap_shuttle?.pad_can_use(pad))
			continue
		var/label = pad.overmap_dock_mode == OVERMAP_DOCK_RESERVED ? pad.name : (pad.overmap_dock_label || pad.name)
		options["[label] ([pad.id])"] = pad
	return options

/obj/overmap/entity/service_site/proc/pod_landing_turf(obj/docking_port/stationary/pad)
	if(pad.get_docked())
		return null
	return overmap_pick_pod_beacon_turf(pad, src)

/obj/overmap/entity/service_site/proc/dock_vessel(obj/overmap/entity/vessel, obj/docking_port/stationary/pad)
	if(vessel.service_dock_host() != src || QDELETED(pad) || pad.hidden || !vessel.pad_matches_host(pad, src))
		return "Стыковочный док недоступен."
	if(!OVERMAP_SPEED_STOPPED(vessel.get_speed()))
		return "Сначала остановитесь."
	if(vessel.overmap_pod)
		var/turf/ground = pod_landing_turf(pad)
		if(!ground || !vessel.land_pod_at(ground, src))
			return "Посадочная площадка занята."
		return TRUE
	return vessel.overmap_shuttle.begin_physical_dock(instant = TRUE, pad = pad)

/obj/overmap/entity/service_site/centcom
	name = "Центральное командование"
	site_id = OVERMAP_SITE_CENTCOM
	area_root = /area/centcom/central_command_areas
	map_color = COLOR_COMMAND_BLUE
	identity_color = COLOR_COMMAND_BLUE
	identity_iff_ids = list(OVERMAP_IFF_CENTCOM)

/obj/overmap/entity/service_site/ninja
	name = "Аванпост клана Паука"
	site_id = OVERMAP_SITE_NINJA
	spawn_sector_id = OVERMAP_SECTOR_ID_WILDERNESS_A
	area_root = /area/centcom/ninja
	map_color = COLOR_JADE
	identity_color = COLOR_JADE
	identity_broadcasting = FALSE
	identity_iff_ids = list(OVERMAP_IFF_SYNDICATE)

/obj/overmap/entity/service_site/syndicate
	name = "База синдиката"
	site_id = OVERMAP_SITE_SYNDICATE
	spawn_sector_id = OVERMAP_SECTOR_ID_FOX_FORD
	area_root = /area/centcom/syndicate_base
	map_color = COLOR_RED
	identity_color = COLOR_RED
	identity_broadcasting = FALSE
	identity_iff_ids = list(OVERMAP_IFF_SYNDICATE, OVERMAP_IFF_HIJACK)

/obj/overmap/entity/service_site/trader
	name = "Торговая база"
	site_id = OVERMAP_SITE_TRADER
	spawn_sector_id = OVERMAP_SECTOR_ID_VESPERA
	area_root = /area/centcom/trader_station
	map_color = COLOR_VERY_SOFT_YELLOW
	identity_color = COLOR_VERY_SOFT_YELLOW
	identity_iff_ids = list(OVERMAP_IFF_CENTCOM)

/obj/overmap/entity/service_site/vox
	name = "База воксов-рейдеров"
	site_id = OVERMAP_SITE_VOX
	spawn_sector_id = OVERMAP_SECTOR_ID_FOX_FORD
	area_root = /area/centcom/vox_station
	map_color = COLOR_ETHIOPIA_GREEN
	identity_color = COLOR_ETHIOPIA_GREEN
	identity_broadcasting = FALSE
	identity_iff_ids = list(OVERMAP_IFF_SYNDICATE)
