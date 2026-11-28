/proc/overmap_ai_radius(obj/overmap/entity/ship)
	var/list/region = ship.physical_space?.region
	if(region)
		return max(ship.hull_radius, sqrt((region[3] - region[1]) ** 2 + (region[4] - region[2]) ** 2) / 2)
	return max(1, ship.hull_radius)

/proc/overmap_ai_faction(obj/overmap/entity/ship, deep_scan = FALSE)
	if(!isnull(ship.structure_faction))
		return ship.structure_faction
	if(ship.ship_ai?.faction == "neutral")
		return "neutral"
	if(!deep_scan)
		var/obj/machinery/transponder/beacon = ship.active_transponder()
		if(ship.is_overmap_jammed() || (beacon && (beacon.stat & (NOPOWER|BROKEN))))
			return "unknown"
	var/priority = deep_scan ? "nt" : "syndicate"
	var/secondary = deep_scan ? "syndicate" : "nt"
	var/detected
	for(var/datum/overmap_iff_channel/channel as anything in ship.get_iff_channels())
		if(!deep_scan && !channel.transmit)
			continue
		var/faction = SSovermap.iff_factions[channel.id]
		if(faction == priority)
			return faction
		if(faction == secondary || !detected)
			detected = faction
	return detected || "unknown"
