/datum/component/overmap_dock_host
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/z_kind = OVERMAP_DOCK_Z_STATION

	var/area_root
	var/allow_custom_landing = TRUE

	var/planet_landing = FALSE
	var/list/obj/overmap/entity/nested

/datum/component/overmap_dock_host/Initialize(z_kind = OVERMAP_DOCK_Z_STATION, area/area_root, allow_custom_landing = TRUE, planet_landing = FALSE)
	if(!istype(parent, /obj/overmap/entity))
		return COMPONENT_INCOMPATIBLE
	src.z_kind = z_kind
	src.area_root = area_root
	src.allow_custom_landing = allow_custom_landing
	src.planet_landing = planet_landing

/datum/component/overmap_dock_host/RegisterWithParent()
	var/obj/overmap/entity/token = parent
	token.dock_host = src
	SSovermap?.dock_hosts |= src

/datum/component/overmap_dock_host/UnregisterFromParent()
	var/obj/overmap/entity/token = parent
	if(token.dock_host == src)
		token.dock_host = null
	SSovermap?.dock_hosts -= src
	nested = null

/datum/component/overmap_dock_host/proc/matches_pad(obj/docking_port/stationary/pad)
	if(!pad || istype(pad, /obj/docking_port/stationary/transit))
		return FALSE
	if(area_root)
		return istype(get_area(pad), area_root)
	switch(z_kind)
		if(OVERMAP_DOCK_Z_STATION)
			return is_station_level(pad.z)
		if(OVERMAP_DOCK_Z_MINING)
			return is_mining_level(pad.z)
		if(OVERMAP_DOCK_Z_RUIN)
			var/obj/overmap/entity/feature/ruin = parent
			return istype(ruin) && ruin.landing_region?.contains_space_turf(get_turf(pad))
	return FALSE

/datum/component/overmap_dock_host/proc/add_nested(obj/overmap/entity/guest)
	if(!nested)
		nested = list()
	nested |= guest

/datum/component/overmap_dock_host/proc/remove_nested(obj/overmap/entity/guest)
	nested -= guest

/datum/component/overmap_dock_host/proc/allows_landing_z(z_level)
	if(!z_level)
		return FALSE
	switch(z_kind)
		if(OVERMAP_DOCK_Z_STATION)
			return is_station_level(z_level)
		if(OVERMAP_DOCK_Z_MINING)
			return is_mining_level(z_level)
		if(OVERMAP_DOCK_Z_SERVICE)
			if(!area_root)
				return FALSE
			for(var/area/place as anything in GLOB.areas)
				if(!istype(place, area_root))
					continue
				var/turf/spot = locate(/turf) in place
				if(spot?.z == z_level)
					return TRUE
			return FALSE
		if(OVERMAP_DOCK_Z_RUIN)
			var/obj/overmap/entity/feature/ruin/ruin = parent
			return istype(ruin) && ruin.landing_region?.space_z == z_level
	return FALSE

/datum/component/overmap_dock_host/proc/pick_landing_z()
	switch(z_kind)
		if(OVERMAP_DOCK_Z_STATION)
			var/list/station_zs = levels_by_trait(STATION_LEVEL)
			if(length(station_zs))
				return pick(station_zs)
		if(OVERMAP_DOCK_Z_MINING)
			var/list/ore_zs = levels_by_trait(ORE_LEVEL)
			if(length(ore_zs))
				return pick(ore_zs)
		if(OVERMAP_DOCK_Z_SERVICE)
			if(!area_root)
				return null
			for(var/area/place as anything in GLOB.areas)
				if(!istype(place, area_root))
					continue
				var/turf/spot = locate(/turf) in place
				if(spot)
					return spot.z
		if(OVERMAP_DOCK_Z_RUIN)
			var/obj/overmap/entity/feature/ruin/ruin = parent
			if(istype(ruin))
				return ruin.landing_region?.space_z
	return null

/obj/overmap/entity/proc/get_dock_host()
	if(docked_to)
		return docked_to
	var/turf/here = get_overmap_turf()
	if(!here)
		return null
	for(var/datum/component/overmap_dock_host/host as anything in SSovermap.dock_hosts)
		if(QDELETED(host) || host.parent == src)
			continue
		var/obj/overmap/entity/token = host.parent
		if(token.get_overmap_turf() == here)
			return token
	for(var/obj/overmap/entity/other in here)
		if(other != src && other.dock_host)
			return other
	return null

/obj/overmap/entity/proc/pad_matches_host(obj/docking_port/stationary/pad, obj/overmap/entity/host)
	if(!pad || !host)
		return FALSE
	if(istype(pad, /obj/docking_port/stationary/transit))
		return FALSE
	SSovermap?.host_for_pad(pad)
	if(pad.overmap_host_uid)
		return pad.overmap_host_uid == host.UID()
	return host.dock_host?.matches_pad(pad)

/obj/overmap/entity/proc/allows_custom_landing(obj/overmap/entity/host)
	if(!host)
		host = get_dock_host()
	return host?.dock_host?.allow_custom_landing
