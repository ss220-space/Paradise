/datum/overmap_admin_panel/proc/ai_fleet_data()
	. = list()
	var/datum/overmap_ai_controller/controller = SSovermap?.ai_controller
	var/list/fleets = list()
	for(var/datum/overmap_ship_ai/brain as anything in controller?.ships)
		if(QDELETED(brain) || QDELETED(brain.owner) || !brain.owner.sector)
			continue
		var/key = controller.group_key(brain)
		var/list/entry = fleets[key]
		if(!entry)
			var/datum/overmap_sector/sector = brain.owner.sector
			entry = list("id" = key, "name" = brain.group, "faction" = brain.faction, "enemies" = controller.enemies_for(brain), "sector" = sector.name, "sector_id" = sector.id, "size" = sector.size, "min" = OVERMAP_EDGE + 1, "max" = sector.size - OVERMAP_EDGE, "count" = 0, "alive" = 0, "order" = controller.orders[key]?["kind"] || "auto")
			fleets[key] = entry
			. += list(entry)
		entry["count"]++
		if(!brain.owner.ai_destroyed)
			entry["alive"]++

/datum/overmap_admin_panel/proc/ai_order_targets()
	. = list()
	var/datum/overmap_ai_controller/controller = SSovermap?.ai_controller
	var/list/sectors = list()
	for(var/datum/overmap_ship_ai/brain as anything in controller?.ships)
		if(!QDELETED(brain.owner) && brain.owner.sector)
			sectors[brain.owner.sector] = TRUE
	for(var/obj/overmap/entity/ship as anything in SSovermap?.vessels)
		if(QDELETED(ship) || !sectors[ship.sector] || !isturf(ship.loc) || ship.ship_ai?.owner.ai_destroyed || !(ship.overmap_kind in list(OVERMAP_KIND_SHUTTLE, OVERMAP_KIND_POD, OVERMAP_KIND_STATION)))
			continue
		. += list(list("id" = ship.UID(), "name" = ship.get_overmap_display_name(), "sector_id" = ship.sector.id, "fleet" = ship.ship_ai ? controller.group_key(ship.ship_ai) : null))

/datum/overmap_admin_panel/proc/ai_order_number(value, minimum, maximum)
	if(!isnum(value) || !(value >= minimum && value <= maximum))
		throw EXCEPTION("Координаты и размеры должны быть в пределах сектора.")
	return value

/datum/overmap_admin_panel/proc/issue_ai_order(list/params, mob/user)
	var/datum/overmap_ai_controller/controller = SSovermap.ai_controller
	var/list/members = list()
	var/datum/overmap_sector/sector
	var/spacing = 12
	for(var/datum/overmap_ship_ai/brain as anything in controller?.ships)
		if(QDELETED(brain) || QDELETED(brain.owner) || brain.owner.ai_destroyed || controller.group_key(brain) != params["fleet"])
			continue
		members += brain
		sector = brain.owner.sector
		spacing = max(spacing, brain.owner.hull_radius * 2 + 12)
	if(!length(members) || !sector)
		throw EXCEPTION("Выберите соединение с живыми кораблями.")
	var/kind = params["command"]
	if(!(kind in list("move", "attack", "patrol", "suppress", "auto", "hold")))
		throw EXCEPTION("Неизвестный приказ.")
	var/list/order = list("kind" = kind, "sector" = sector, "spacing" = spacing)
	var/span = OVERMAP_TILE_SPAN * sector.tile_travel
	if(kind in list("move", "patrol", "suppress"))
		var/list/points = params["points"]
		if(!islist(points) || !length(points) || length(points) > 16 || (kind != "patrol" && length(points) != 1))
			throw EXCEPTION("Укажите одну точку назначения или от 1 до 16 точек патруля.")
		order["points"] = list()
		for(var/list/point as anything in points)
			if(!islist(point))
				throw EXCEPTION("Неверная точка маршрута.")
			var/x = ai_order_number(point["x"], OVERMAP_EDGE + 1, sector.size - OVERMAP_EDGE)
			var/y = ai_order_number(point["y"], OVERMAP_EDGE + 1, sector.size - OVERMAP_EDGE)
			order["points"] += list(list((sector.origin_x + x - 1) * span, (sector.origin_y + y - 1) * span))
		if(kind == "suppress")
			var/list/center = order["points"][1]
			var/half = ai_order_number(params["size"], 5, 500) / 2
			if(center[1] - half < (sector.playable_min_x() - 0.5) * span || center[1] + half > (sector.playable_max_x() + 0.5) * span || center[2] - half < (sector.playable_min_y() - 0.5) * span || center[2] + half > (sector.playable_max_y() + 0.5) * span)
				throw EXCEPTION("Квадрат подавления должен целиком находиться внутри сектора.")
			order["x"] = center[1]
			order["y"] = center[2]
			order["half"] = half
	if(kind == "attack")
		var/obj/overmap/entity/target = locateUID(params["target"])
		if(!istype(target) || QDELETED(target) || target.sector != sector || !isturf(target.loc) || target.ship_ai?.owner.ai_destroyed || !(target.overmap_kind in list(OVERMAP_KIND_SHUTTLE, OVERMAP_KIND_POD, OVERMAP_KIND_STATION)))
			throw EXCEPTION("Выберите действующую цель в секторе соединения.")
		if(target.ship_ai && controller.group_key(target.ship_ai) == params["fleet"])
			throw EXCEPTION("Нельзя назначить целью корабль этого же соединения.")
		order["target"] = target.UID()
		order["x"] = target.get_world_x()
		order["y"] = target.get_world_y()
	if(kind == "auto")
		controller.orders -= params["fleet"]
		order = null
	else
		controller.orders[params["fleet"]] = order
	var/index = 0
	for(var/datum/overmap_ship_ai/brain as anything in members)
		brain.set_enabled(kind != "hold")
		brain.order = order
		brain.order_index = 1
		brain.order_slot = index++
		brain.goal_x = null
		if(kind == "attack")
			brain.last_x = order["x"]
			brain.last_y = order["y"]
			brain.last_vx = 0
			brain.last_vy = 0
	controller.index_until = 0
	ai_feedback = "Приказ передан [length(members)] кораблям соединения."
	log_admin("[key_name(user)] ordered AI fleet [params["fleet"]] to [kind]: [json_encode(params)].")

/datum/overmap_ship_ai/proc/is_fleet_member(obj/overmap/entity/ship)
	return ship?.ship_ai && controller.group_key(ship.ship_ai) == controller.group_key(src)

/datum/overmap_ship_ai/proc/is_ordered_target(obj/overmap/entity/ship)
	return order?["kind"] == "attack" && order["target"] == ship?.UID()

/datum/overmap_ship_ai/proc/order_destination(list/point)
	var/ring = FLOOR((order_slot + 1) / 2, 1)
	var/offset = ring * order["spacing"] * (order_slot % 2 ? 1 : -1)
	var/list/limits = world_limits()
	return list(clamp(point[1] + offset, limits[1], limits[3]), clamp(point[2], limits[2], limits[4]))

/datum/overmap_ship_ai/proc/execute_order()
	switch(order["kind"])
		if("attack")
			if(!target)
				state = "order_complete"
				wanted_x = 0
				wanted_y = 0
				return TRUE
			if(target_visible)
				return FALSE
			state = "search"
			steer_to(last_x, last_y, navigation_speed())
		if("move", "patrol")
			if(order["kind"] == "patrol" && target_visible)
				return FALSE
			var/list/points = order["points"]
			var/list/point = order_destination(points[order_index])
			var/distance = sqrt((point[1] - owner.get_world_x()) ** 2 + (point[2] - owner.get_world_y()) ** 2)
			state = order["kind"] == "move" && distance < 8 ? "order_complete" : order["kind"] == "move" ? "move" : "patrol_order"
			steer_to(point[1], point[2], navigation_speed())
			if(distance < 8 && order["kind"] == "patrol")
				order_index = order_index % length(points) + 1
			if(target_visible)
				aim_and_fire()
		if("suppress")
			state = "suppress"
			var/angle = delta_to_angle(home_x - order["x"], home_y - order["y"]) + (order_slot % 5 - 2) * 12
			var/distance = min(profile.fire_range * 0.7, max(profile.distance, order["half"] * 1.5 + owner.hull_radius + 20))
			var/list/point = overmap_ai_standoff_point(order["x"], order["y"], angle, distance, world_limits())
			steer_to(point[1], point[2], navigation_speed())
			if(has_weapons())
				aim_and_fire()
		if("hold")
			state = "stopped"
			wanted_x = 0
			wanted_y = 0
	if(wanted_x || wanted_y)
		if(order["kind"] != "suppress" && !target_visible)
			wanted_facing = delta_to_angle(wanted_x, wanted_y)
	return TRUE

/datum/overmap_ship_ai/proc/suppression_aim(datum/component/ship_weapon/mount)
	if(!order || order["kind"] != "suppress" || order["sector"] != owner.sector || !has_weapons())
		return null
	for(var/attempt in 1 to 12)
		var/x = order["x"] + rand(-1000, 1000) / 1000 * order["half"]
		var/y = order["y"] + rand(-1000, 1000) / 1000 * order["half"]
		if((x - owner.get_world_x()) ** 2 + (y - owner.get_world_y()) ** 2 > profile.fire_range ** 2)
			continue
		var/list/aim = aim_at_point(mount, x, y)
		if(aim && mount.can_aim(owner, aim[1], aim[2]) && clear_shot(mount, aim))
			return aim
	return null
