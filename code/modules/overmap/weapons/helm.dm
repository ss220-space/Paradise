/obj/overmap/entity/proc/ship_weapons()
	if(overmap_pod)
		var/obj/item/spacepod_equipment/weaponry/module = overmap_pod.pod()?.equipment_system?.weapon_system
		return module ? list(module) : list()
	if(world.time < ship_weapons_until && ship_weapons_cache)
		return ship_weapons_cache
	ship_weapons_until = world.time + (2 SECONDS)
	ship_weapons_cache = list()
	for(var/datum/component/ship_weapon/weapon as anything in GLOB.overmap_weapons)
		if(weapon.host() == src)
			ship_weapons_cache += weapon.parent
	return ship_weapons_cache

/obj/machinery/computer/helm/proc/weapon_data()
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
		. += list(list("id" = id, "name" = gun.name, "selected" = (id in selected_weapons), "auto" = data["automatic"], "turret" = istype(gun, /obj/machinery/porta_turret), "cooldown" = max(0, cooldown - world.time) / (1 SECONDS), "arc" = data["arc"], "heading" = data["heading"] - angle, "x" = point[1], "y" = point[2]))
	selected_weapons &= available

/obj/machinery/computer/helm/proc/weapon_action(action, list/params, mob/user)
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

/obj/machinery/computer/helm/proc/fire_weapons(x, y, mob/user)
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
