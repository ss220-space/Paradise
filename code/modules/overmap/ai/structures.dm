/obj/overmap/entity/proc/supports_stationary_ai()
	return !shuttle && !overmap_pod && !istype(src, /obj/overmap/entity/virtual_structure/ai) && (!movable || (overmap_kind in list(OVERMAP_KIND_STATION, OVERMAP_KIND_RUIN)))

/obj/overmap/entity/proc/set_stationary_ai(enabled)
	if(!supports_stationary_ai())
		return FALSE
	QDEL_NULL(ship_ai)
	stationary_ai = !!enabled
	if(!stationary_ai)
		return TRUE
	if(isnull(structure_faction))
		var/affiliation = overmap_ai_faction(src)
		structure_faction = affiliation == "unknown" ? "neutral" : affiliation
	short_sensors_on = TRUE
	speed[1] = 0
	speed[2] = 0
	if(flight)
		flight.release_pilot()
		flight.stop_burn()
		flight.autopilot = FALSE
		flight.clear_navigation()
		flight.angular_velocity = 0
	if(!sensor_pack)
		AddComponent(/datum/component/overmap_sensors)
	SSovermap.ensure_host_space(src)?.ensure_region()
	if(!SSovermap.ai_controller)
		SSovermap.ai_controller = new
	ship_ai = new /datum/overmap_ship_ai/stationary(src, SSovermap.ai_controller, "support", structure_faction, "structure-[UID()]")
	return TRUE

/obj/overmap/entity/proc/is_ai_destroyed()
	if(!shuttle)
		return FALSE
	for(var/obj/machinery/computer/ship_console/console as anything in helms)
		if(QDELETED(console) || (console.stat & BROKEN) || console.vessel != src || istype(console, /obj/machinery/computer/helm/admin))
			continue
		if(shuttle.overmap_is_hull_turf(get_turf(console)))
			return FALSE
	for(var/obj/machinery/computer/sensors/console as anything in sensors)
		if(!QDELETED(console) && !(console.stat & BROKEN) && console.vessel == src && shuttle.overmap_is_hull_turf(get_turf(console)))
			return FALSE
	return TRUE

/obj/overmap/entity/proc/ai_sensor_intact()
	return TRUE

/obj/overmap/entity/proc/ai_drive_intact()
	return FALSE

/obj/overmap/entity/proc/ai_weapons()
	return ship_weapons()

/obj/overmap/entity/virtual_structure/ai_weapons()
	return virtual_weapons

/obj/overmap/entity/virtual_structure/ai/is_ai_destroyed()
	return ai_destroyed

/obj/overmap/entity/virtual_structure/ai/ai_sensor_intact()
	return ai_sensor_cell && ai_sensor_cell[4] > 0

/obj/overmap/entity/virtual_structure/ai/ai_drive_intact()
	return drive_intact()

/obj/overmap/entity/process_movement(elapsed)
	if(stationary_ai)
		return
	return ..()
