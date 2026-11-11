/datum/overmap_ai_controller
	var/list/ships = list()
	var/list/orders = list()
	var/list/fleet_enemies = list()
	var/list/buckets = list()
	var/list/contacts = list()
	var/list/fleet_contacts = list()
	var/list/fleet_life = list()
	var/list/medium_cover = list()
	var/index_until = 0
	var/next_slot = 0
	var/next_fleet = 0
	var/cursor = 1
	var/pending_spawns = 0
	var/max_ships = 32

/datum/overmap_ai_controller/Destroy()
	clear_index()
	for(var/datum/overmap_ship_ai/brain as anything in ships)
		qdel(brain)
	ships = null
	orders = null
	fleet_enemies = null
	return ..()

/datum/overmap_ai_controller/proc/clear_index()
	for(var/obj/overmap/entity/ship as anything in contacts)
		UnregisterSignal(ship, COMSIG_QDELETING)
	contacts = list()
	fleet_contacts = list()
	fleet_life = list()
	buckets = list()
	medium_cover = list()

/datum/overmap_ai_controller/proc/on_ship_deleted(obj/overmap/entity/ship)
	SIGNAL_HANDLER
	var/list/entry = contacts[ship]
	contacts -= ship
	fleet_contacts = list()
	fleet_life = list()
	for(var/key, value in buckets)
		var/list/bucket = value
		bucket -= list(entry)
	for(var/datum/overmap_ship_ai/brain as anything in ships)
		if(brain.target == ship)
			brain.target = null
			brain.target_visible = FALSE
	UnregisterSignal(ship, COMSIG_QDELETING)
	index_until = 0

/datum/overmap_ai_controller/proc/group_key(datum/overmap_ship_ai/brain)
	return "[brain.owner.sector?.id]/[brain.faction]/[brain.group]"

/datum/overmap_ai_controller/proc/enemies_for(datum/overmap_ship_ai/brain)
	var/list/enemies = fleet_enemies[group_key(brain)]
	return isnull(enemies) ? GLOB.overmap_ai_default_enemies[brain.faction] : enemies

/datum/overmap_ai_controller/proc/rebuild_index()
	var/list/previous = contacts
	buckets = list()
	contacts = list()
	medium_cover = list()
	index_until = world.time + (0.5 SECONDS)
	for(var/obj/overmap/entity/ship as anything in SSovermap.vessels)
		if(QDELETED(ship) || !ship.sector || !isturf(ship.loc) || ship.is_jumping() || ship.docked_to || ship.docked_ship)
			continue
		if(!ship.hull_radius && !ship.physical_space)
			continue
		var/x = ship.get_world_x()
		var/y = ship.get_world_y()
		var/radius = overmap_ai_radius(ship)
		var/targetable = ship.overmap_kind in list(OVERMAP_KIND_SHUTTLE, OVERMAP_KIND_STATION, OVERMAP_KIND_POD)
		if(istype(ship, /obj/overmap/entity/virtual_structure) && !ship.movable)
			targetable = FALSE
		var/list/entry = list("ship" = ship, "x" = x, "y" = y, "radius" = radius, "targetable" = targetable)
		contacts[ship] = entry
		if(!(ship in previous))
			RegisterSignal(ship, COMSIG_QDELETING, PROC_REF(on_ship_deleted))
		for(var/ix in FLOOR((x - radius) / 128, 1) to FLOOR((x + radius) / 128, 1))
			for(var/iy in FLOOR((y - radius) / 128, 1) to FLOOR((y + radius) / 128, 1))
				var/key = "[ship.sector.id]/[ix],[iy]"
				var/list/bucket = buckets[key]
				if(!bucket)
					bucket = list()
					buckets[key] = bucket
				bucket += list(entry)
	for(var/obj/overmap/entity/ship as anything in previous)
		if(!(ship in contacts))
			UnregisterSignal(ship, COMSIG_QDELETING)
	var/list/active_groups = list()
	for(var/datum/overmap_ship_ai/brain as anything in ships)
		if(!QDELETED(brain) && !QDELETED(brain.owner))
			active_groups[group_key(brain)] = TRUE
		if(!QDELETED(brain) && !QDELETED(brain.owner) && brain.role == "medium" && !brain.owner.ai_destroyed && brain.owner.sector)
			var/key = group_key(brain)
			medium_cover[key] = (medium_cover[key] || 0) + 1

	for(var/key in fleet_enemies)
		if(!active_groups[key])
			fleet_enemies -= key

	rebuild_fleet_sensors()

/datum/overmap_ai_controller/proc/nearby(datum/overmap_sector/sector, x, y, reach)
	. = list()
	if(!sector)
		return
	var/min_x = FLOOR((x - reach) / 128, 1)
	var/max_x = FLOOR((x + reach) / 128, 1)
	var/min_y = FLOOR((y - reach) / 128, 1)
	var/max_y = FLOOR((y + reach) / 128, 1)
	if((max_x - min_x + 1) * (max_y - min_y + 1) > length(contacts))
		for(var/obj/overmap/entity/ship, record in contacts)
			var/list/entry = record
			if(ship.sector == sector && abs(entry["x"] - x) <= reach + entry["radius"] && abs(entry["y"] - y) <= reach + entry["radius"])
				. += list(entry)
		return
	for(var/ix in min_x to max_x)
		for(var/iy in min_y to max_y)
			var/list/bucket = buckets["[sector.id]/[ix],[iy]"]
			for(var/list/entry as anything in bucket)
				. |= list(entry)

/datum/overmap_ai_controller/proc/process_tick()
	if(!length(ships))
		if(length(contacts))
			clear_index()
		orders.Cut()
		fleet_enemies.Cut()
		return
	if(world.time >= index_until)
		rebuild_index()
	var/budget_start = world.tick_usage
	var/remaining = length(ships)
	while(remaining-- > 0 && length(ships))
		if(cursor > length(ships))
			cursor = 1
		var/datum/overmap_ship_ai/brain = ships[cursor++]
		if(!QDELETED(brain) && brain.enabled && world.time >= brain.next_think)
			brain.next_think = world.time + (brain.target || brain.order ? 4 + brain.slot % 3 : 15 + brain.slot % 6)
			brain.think()
		if(world.tick_usage - budget_start > 5)
			break

/datum/overmap_ship_ai
	var/obj/overmap/entity/virtual_structure/ai/owner
	var/datum/overmap_ai_controller/controller
	var/datum/overmap_ai_profile/profile
	var/role
	var/faction
	var/group
	var/slot
	var/enabled = TRUE
	var/state = "patrol"
	var/next_think = 0
	var/obj/overmap/entity/target
	var/target_visible = FALSE
	var/last_seen = 0
	var/last_x = 0
	var/last_y = 0
	var/last_vx = 0
	var/last_vy = 0
	var/home_x
	var/home_y
	var/datum/overmap_sector/home_sector
	var/patrol_radius = 100
	var/patrol_step = 0
	var/goal_x
	var/goal_y
	var/wanted_x = 0
	var/wanted_y = 0
	var/wanted_facing = 0
	var/list/weapons = list()
	var/list/order
	var/order_index = 1
	var/order_slot = 0

/datum/overmap_ship_ai/New(obj/overmap/entity/virtual_structure/ai/ship, datum/overmap_ai_controller/manager, class_id, affiliation, squad)
	owner = ship
	owner.ship_ai = src
	controller = manager
	role = class_id
	profile = GLOB.overmap_ai_profiles[role]
	faction = affiliation
	group = squad
	slot = controller.next_slot++
	home_sector = owner.sector
	home_x = owner.get_world_x()
	home_y = owner.get_world_y()
	wanted_facing = owner.get_facing()
	next_think = world.time + slot % 5
	for(var/obj/machinery/gun as anything in owner.virtual_weapons)
		var/datum/component/ship_weapon/mount = gun.GetComponent(/datum/component/ship_weapon)
		if(mount)
			weapons += mount
	owner.identity_broadcasting = faction != "rogue"
	owner.identity_iff_ids = faction == "syndicate" ? list(OVERMAP_IFF_SYNDICATE) : faction == "nt" ? list(OVERMAP_IFF_CENTCOM) : list()
	owner.map_color = faction == "syndicate" ? "#e77575" : faction == "nt" ? "#78bded" : "#bca2e5"
	owner.identity_color = owner.map_color
	owner.identity_name = owner.name
	owner.rebuild_identity_iff()
	owner.update_overmap_visibility()
	RegisterSignal(owner, COMSIG_OVERMAP_MANUAL_CONTROL, PROC_REF(on_manual_control))
	controller.ships += src
	order = controller.orders[controller.group_key(src)]
	order_slot = 0
	for(var/datum/overmap_ship_ai/member as anything in controller.ships)
		if(member != src && controller.group_key(member) == controller.group_key(src) && !member.owner.ai_destroyed)
			order_slot++
	if(order)
		order["spacing"] = max(order["spacing"], owner.hull_radius * 2 + 12)
		if(order["kind"] == "attack")
			last_x = order["x"]
			last_y = order["y"]
		if(order["kind"] == "hold")
			set_enabled(FALSE)
	controller.index_until = 0

/datum/overmap_ship_ai/Destroy()
	controller?.ships -= src
	if(!QDELETED(controller))
		controller.index_until = 0
	if(owner)
		UnregisterSignal(owner, COMSIG_OVERMAP_MANUAL_CONTROL)
		if(owner.ship_ai == src)
			owner.ship_ai = null
	owner = null
	target = null
	home_sector = null
	profile = null
	order = null
	weapons = null
	controller = null
	return ..()

/datum/overmap_ship_ai/proc/on_manual_control()
	SIGNAL_HANDLER
	enabled = FALSE
	target = null
	state = "stopped"

/datum/overmap_ship_ai/proc/set_enabled(value)
	enabled = !!value && !owner.ai_destroyed
	if(enabled)
		owner.flight.release_pilot()
	target = null
	target_visible = FALSE
	wanted_x = 0
	wanted_y = 0
	owner.flight.autopilot = FALSE
	owner.flight.clear_navigation()
	owner.flight.held_brake = !enabled
	owner.flight.engines_state = !owner.ai_destroyed
	owner.halted = FALSE
	state = owner.ai_destroyed ? "destroyed" : enabled ? "patrol" : "stopped"
	next_think = 0

/datum/overmap_ship_ai/proc/weapon_operational(datum/component/ship_weapon/mount)
	if(QDELETED(mount) || QDELETED(mount.parent))
		return FALSE
	var/obj/machinery/gun = mount.parent
	if((gun.stat & BROKEN) || !gun.anchored || world.time < gun.ship_emp_until)
		return FALSE
	var/obj/machinery/porta_turret/turret = gun
	return !istype(turret) || (turret.enabled && !turret.disabled && turret.health > 0)

/datum/overmap_ship_ai/proc/combat_ready()
	return !QDELETED(owner) && !owner.ai_destroyed && owner.sector && owner.drive_intact() && has_weapons()

/datum/overmap_ship_ai/proc/has_weapons()
	for(var/datum/component/ship_weapon/mount as anything in weapons)
		if(weapon_operational(mount))
			return TRUE
	return FALSE

/datum/overmap_ship_ai/proc/hostile(affiliation)
	return affiliation in controller.enemies_for(src)

/datum/overmap_ship_ai/proc/can_see(list/entry)
	return !!controller.contact_for(src, entry?["ship"])

/datum/overmap_ship_ai/proc/sees_directly(list/entry)
	var/obj/overmap/entity/ship = entry?["ship"]
	if(QDELETED(ship) || ship == owner || ship.sector != owner.sector || !isturf(ship.loc) || ship.hidden_from_sensors || ship.hidden_from_contacts || ship.is_jumping() || !sensors_online())
		return FALSE
	if(ship.ship_ai?.owner.ai_destroyed)
		return FALSE
	return (ship.get_world_x() - owner.get_world_x()) ** 2 + (ship.get_world_y() - owner.get_world_y()) ** 2 <= (detection_range() + entry["radius"]) ** 2

/datum/overmap_ship_ai/proc/acquire_target()
	target_visible = FALSE
	if(order?["kind"] == "attack")
		target = locateUID(order["target"])
		var/list/assigned = controller.contacts[target]
		if(QDELETED(target) || target.sector != owner.sector || target.ship_ai?.owner.ai_destroyed)
			target = null
			return
		if(!can_see(assigned))
			return
		target_visible = TRUE
		last_x = target.get_world_x()
		last_y = target.get_world_y()
		last_vx = target.speed[1] * OVERMAP_TILE_SPAN * (1 SECONDS)
		last_vy = target.speed[2] * OVERMAP_TILE_SPAN * (1 SECONDS)
		last_seen = world.time
		return
	var/obj/overmap/entity/chosen = choose_target()
	if(chosen)
		target = chosen
		target_visible = TRUE
	if(target_visible)
		last_x = target.get_world_x()
		last_y = target.get_world_y()
		last_vx = target.speed[1] * OVERMAP_TILE_SPAN * (1 SECONDS)
		last_vy = target.speed[2] * OVERMAP_TILE_SPAN * (1 SECONDS)
		last_seen = world.time
	else if(QDELETED(target) || target.sector != owner.sector || (controller.contacts[target] && !hostile(perceived_faction(target))) || world.time - last_seen > (8 SECONDS))
		target = null

/datum/overmap_ship_ai/proc/flight_control(elapsed)
	owner.flight.match_navigation_velocity(wanted_x / (1 SECONDS), wanted_y / (1 SECONDS), elapsed)
	return wanted_facing + owner.flight.main_axis_angle()
