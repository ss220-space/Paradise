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

/obj/overmap/entity/service_site/Initialize(mapload)
	. = ..()
	SSovermap?.register_service_site(src)

/obj/overmap/entity/service_site/Destroy()
	SSovermap?.unregister_service_site(src)
	return ..()

/obj/overmap/entity/service_site/add_overmap_components()
	AddComponent(/datum/component/overmap_sensors)
	AddComponent(/datum/component/overmap_dock_host, OVERMAP_DOCK_Z_SERVICE, area_root)

/obj/overmap/entity/service_site/get_overmap_display_name()
	if(transponder)
		return transponder.broadcast_name || name
	return name

/obj/overmap/entity/service_site/proc/setup_faction_beacon(iff_id, global_transmit, token_color)
	color = token_color
	map_color = token_color
	virtual_iff_channels = list(
		new /datum/overmap_iff_channel(OVERMAP_IFF_GLOBAL, overmap_iff_label_for_id(OVERMAP_IFF_GLOBAL), TRUE, TRUE, global_transmit),
		new /datum/overmap_iff_channel(iff_id, overmap_iff_label_for_id(iff_id), TRUE, TRUE, TRUE),
	)

/obj/overmap/entity/service_site/centcom
	name = "Центральное командование"
	site_id = OVERMAP_SITE_CENTCOM
	area_root = /area/centcom/central_command_areas
	map_color = COLOR_COMMAND_BLUE

/obj/overmap/entity/service_site/centcom/Initialize(mapload)
	setup_faction_beacon(OVERMAP_IFF_CENTCOM, TRUE, COLOR_COMMAND_BLUE)
	return ..()

/obj/overmap/entity/service_site/ninja
	name = "Аванпост клана Паука"
	site_id = OVERMAP_SITE_NINJA
	area_root = /area/centcom/ninja
	map_color = "#5c5c5c"

/obj/overmap/entity/service_site/syndicate
	name = "База синдиката"
	site_id = OVERMAP_SITE_SYNDICATE
	area_root = /area/centcom/syndicate_base
	map_color = COLOR_RED

/obj/overmap/entity/service_site/syndicate/Initialize(mapload)
	setup_faction_beacon(OVERMAP_IFF_SYNDICATE, FALSE, COLOR_RED)
	return ..()

/obj/overmap/entity/service_site/trader
	name = "Торговая база"
	site_id = OVERMAP_SITE_TRADER
	area_root = /area/centcom/trader_station
	map_color = "#c4a035"

/obj/overmap/entity/service_site/vox
	name = "База воксов-рейдеров"
	site_id = OVERMAP_SITE_VOX
	area_root = /area/centcom/vox_station
	map_color = "#4a7d4a"
