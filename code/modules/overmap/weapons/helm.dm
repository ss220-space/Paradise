/obj/overmap/entity/proc/ship_weapons()
	if(overmap_pod)
		var/obj/item/spacepod_equipment/weaponry/module = overmap_pod.pod()?.equipment_system?.weapon_system
		return module ? list(module) : list()
	return SSovermap.weapons_for_vessel(src)

/datum/controller/subsystem/overmap/proc/weapons_for_vessel(obj/overmap/entity/vessel)
	if(world.time >= weapon_index_until)
		weapons_by_vessel = list()
		weapon_index_until = world.time + (2 SECONDS)
		for(var/obj/gun as anything in GLOB.overmap_weapons)
			var/list/data = list()
			SEND_SIGNAL(gun, COMSIG_OVERMAP_WEAPON_HOST, data)
			var/obj/overmap/entity/host = data["host"]
			if(QDELETED(host))
				continue
			var/list/weapons = weapons_by_vessel[host]
			if(!weapons)
				weapons = list()
				weapons_by_vessel[host] = weapons
			weapons += gun
	return weapons_by_vessel[vessel]

/obj/machinery/computer/ship_console/proc/weapon_data()
	. = list()
	var/list/available = list()
	for(var/obj/gun as anything in vessel.ship_weapons())
		var/list/data = list()
		if(QDELETED(gun) || !SEND_SIGNAL(gun, COMSIG_OVERMAP_WEAPON_QUERY, vessel, data))
			continue
		var/id = gun.UID()
		var/cooldown = data["cooldown"]
		available += id
		var/list/point = data["position"]
		var/list/origin = vessel.radar_world_origin()
		var/angle = vessel.free_flight_view ? vessel.get_facing() : 0
		var/dx = point ? point[1] - origin[1] : 0
		var/dy = point ? point[2] - origin[2] : 0
		point = list(dx * cos(angle) - dy * sin(angle), dx * sin(angle) + dy * cos(angle))
		. += list(list("id" = id, "name" = gun.name, "selected" = (id in selected_weapons), "auto" = data["automatic"], "turret" = istype(gun, /obj/machinery/porta_turret), "cooldown" = max(0, cooldown - world.time) / (1 SECONDS), "cooldown_total" = data["cooldown_total"], "arc" = data["arc"], "heading" = data["heading"] - angle, "x" = point[1], "y" = point[2]))
	selected_weapons &= available

/obj/machinery/computer/ship_console/proc/weapon_action(action, list/params, mob/user)
	var/obj/gun = locateUID(params["id"])
	var/list/data = list()
	if(QDELETED(gun) || !SEND_SIGNAL(gun, COMSIG_OVERMAP_WEAPON_QUERY, vessel, data))
		return
	if(action == "select_weapon")
		if(gun.UID() in selected_weapons)
			selected_weapons -= gun.UID()
		else
			selected_weapons |= gun.UID()
	else if(action == "weapon_auto")
		SEND_SIGNAL(gun, COMSIG_OVERMAP_WEAPON_AUTOMATIC, vessel)

/obj/machinery/computer/ship_console/proc/fire_weapons(x, y, mob/user)
	if(!length(selected_weapons) || !isnum(x) || !isnum(y) || !(abs(x) < 1000000000) || !(abs(y) < 1000000000))
		return FALSE
	for(var/id in selected_weapons)
		var/obj/gun = locateUID(id)
		var/list/data = list()
		if(QDELETED(gun) || !SEND_SIGNAL(gun, COMSIG_OVERMAP_WEAPON_QUERY, vessel, data))
			selected_weapons -= id
			continue
		SEND_SIGNAL(gun, COMSIG_OVERMAP_WEAPON_FIRE, vessel, x, y, user)
	return TRUE

/obj/machinery/computer/ship_console/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return TRUE
	if(!vessel)
		link_vessel()
	if(!vessel)
		return TRUE
	switch(action)
		if("select_weapon", "weapon_auto")
			weapon_action(action, params, ui.user)
			return TRUE
		if("helm_radar_reach")
			var/reach = clamp(round(text2num(params["reach"])), 32, OVERMAP_RADAR_TERRAIN_MAX)
			if(radar_reach == reach)
				return FALSE
			radar_reach = reach
			return TRUE
		if("relink")
			link_vessel()
			return TRUE
		if("radar_point", "set_dest")
			if(!length(selected_weapons))
				return FALSE
			var/target_x = text2num(params["x"])
			var/target_y = text2num(params["y"])
			if(action == "set_dest")
				var/obj/overmap/target = locateUID(params["id"])
				if(!target || !vessel.sector || target.sector != vessel.sector)
					return TRUE
				var/obj/overmap/entity/entity = target
				target_x = istype(entity) ? entity.get_world_x() : target.x * OVERMAP_TILE_SPAN * vessel.sector.tile_travel
				target_y = istype(entity) ? entity.get_world_y() : target.y * OVERMAP_TILE_SPAN * vessel.sector.tile_travel
			fire_weapons(target_x, target_y, ui.user)
			return TRUE
	return FALSE
