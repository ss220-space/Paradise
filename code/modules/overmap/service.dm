/obj/overmap/entity/service_site
	abstract_type = /obj/overmap/entity/service_site
	name = "service site"
	icon_state = "ship"
	movable = FALSE
	halted = TRUE
	overmap_kind = OVERMAP_KIND_STATION
	vessel_flags = OVERMAP_VESSEL_STATION
	vessel_mass = OVERMAP_MASS_STATION
	overmap_icon_preset = "station"
	status = OVERMAP_STATUS_OVERMAP
	overmap_hazard_immune = TRUE
	var/site_id
	var/area/area_root
	identity_icon = "station"
	identity_locked = TRUE

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
	area_root = /area/centcom/ninja
	map_color = COLOR_JADE
	identity_color = COLOR_JADE
	identity_broadcasting = FALSE
	identity_iff_ids = list(OVERMAP_IFF_SYNDICATE)

/obj/overmap/entity/service_site/syndicate
	name = "База синдиката"
	site_id = OVERMAP_SITE_SYNDICATE
	area_root = /area/centcom/syndicate_base
	map_color = COLOR_RED
	identity_color = COLOR_RED
	identity_broadcasting = FALSE
	identity_iff_ids = list(OVERMAP_IFF_SYNDICATE, OVERMAP_IFF_HIJACK)

/obj/overmap/entity/service_site/trader
	name = "Торговая база"
	site_id = OVERMAP_SITE_TRADER
	area_root = /area/centcom/trader_station
	map_color = COLOR_VERY_SOFT_YELLOW
	identity_color = COLOR_VERY_SOFT_YELLOW
	identity_iff_ids = list(OVERMAP_IFF_CENTCOM)

/obj/overmap/entity/service_site/vox
	name = "База воксов-рейдеров"
	site_id = OVERMAP_SITE_VOX
	area_root = /area/centcom/vox_station
	map_color = COLOR_ETHIOPIA_GREEN
	identity_color = COLOR_ETHIOPIA_GREEN
	identity_broadcasting = FALSE
	identity_iff_ids = list(OVERMAP_IFF_SYNDICATE)
