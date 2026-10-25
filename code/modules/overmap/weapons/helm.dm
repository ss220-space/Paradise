/obj/overmap/entity
	var/list/ship_weapons_cache
	var/ship_weapons_until = 0

/obj/overmap/entity/proc/ship_weapons()
	if(overmap_pod)
		var/obj/item/spacepod_equipment/weaponry/module = overmap_pod.pod()?.equipment_system?.weapon_system
		var/datum/component/ship_weapon/weapon = module?.GetComponent(/datum/component/ship_weapon)
		return weapon ? list(weapon) : list()
	if(world.time < ship_weapons_until && ship_weapons_cache)
		return ship_weapons_cache
	ship_weapons_until = world.time + (2 SECONDS)
	ship_weapons_cache = list()
	for(var/datum/component/ship_weapon/weapon as anything in GLOB.overmap_weapons)
		if(weapon.host() == src)
			ship_weapons_cache += weapon
	return ship_weapons_cache

/obj/machinery/computer/helm
	var/list/selected_weapons = list()

/obj/machinery/computer/helm/proc/weapon_data()
	. = list()
	var/list/available = list()
	for(var/datum/component/ship_weapon/weapon as anything in vessel.ship_weapons())
		if(QDELETED(weapon) || weapon.host() != vessel)
			continue
		var/obj/gun = weapon.parent
		var/id = gun.UID()
		var/cooldown = vessel.overmap_pod ? vessel.overmap_pod.pod().next_firetime : weapon.next_fire
		available += id
		var/list/point = weapon.world_position(vessel)
		var/list/origin = vessel.radar_world_origin()
		var/angle = vessel.free_flight_view ? vessel.get_facing() : 0
		var/dx = point ? point[1] - origin[1] : 0
		var/dy = point ? point[2] - origin[2] : 0
		point = list(dx * cos(angle) - dy * sin(angle), dx * sin(angle) + dy * cos(angle))
		. += list(list("id" = id, "name" = gun.name, "selected" = (id in selected_weapons), "auto" = weapon.automatic, "turret" = istype(gun, /obj/machinery/porta_turret), "cooldown" = max(0, cooldown - world.time) / (1 SECONDS), "arc" = weapon.arc, "heading" = weapon.heading(vessel) - angle, "x" = point[1], "y" = point[2]))
	selected_weapons &= available

/obj/machinery/computer/helm/proc/weapon_action(action, list/params, mob/user)
	var/obj/gun = locateUID(params["id"])
	var/datum/component/ship_weapon/weapon = gun?.GetComponent(/datum/component/ship_weapon)
	if(!weapon || weapon.host() != vessel)
		return
	if(action == "select_weapon")
		if(gun.UID() in selected_weapons)
			selected_weapons -= gun.UID()
		else
			selected_weapons |= gun.UID()
	else if(istype(gun, /obj/machinery/porta_turret))
		weapon.automatic = !weapon.automatic

/obj/machinery/computer/helm/proc/fire_weapons(x, y, mob/user)
	if(!length(selected_weapons) || !isnum(x) || !isnum(y) || !(abs(x) < 1000000000) || !(abs(y) < 1000000000))
		return FALSE
	for(var/id in selected_weapons.Copy())
		var/obj/gun = locateUID(id)
		var/datum/component/ship_weapon/weapon = gun?.GetComponent(/datum/component/ship_weapon)
		if(!weapon || weapon.host() != vessel)
			selected_weapons -= id
			continue
		weapon.fire_at(vessel, x, y, TRUE, user)
	return TRUE
