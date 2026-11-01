GLOBAL_LIST_EMPTY(overmap_weapons)

/datum/component/ship_weapon
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/arc = 180
	var/mount_dir
	var/automatic = TRUE
	var/next_fire = 0
	var/damage_scale = 1
	var/penetration_chance = 0
	var/muzzle_distance = 0.8

/datum/component/ship_weapon/Initialize(arc = 180, automatic = TRUE, mount_dir, muzzle_distance = 0.8, damage_scale = 1, penetration_chance = 0)
	if(!ismachinery(parent) && !istype(parent, /obj/item/spacepod_equipment/weaponry))
		return COMPONENT_INCOMPATIBLE
	var/obj/gun = parent
	src.arc = arc
	src.automatic = automatic
	src.mount_dir = isnull(mount_dir) ? gun.dir : mount_dir
	src.muzzle_distance = muzzle_distance
	src.damage_scale = damage_scale
	src.penetration_chance = penetration_chance
	GLOB.overmap_weapons += src

/datum/component/ship_weapon/RegisterWithParent()
	RegisterSignal(parent, COMSIG_OVERMAP_WEAPON_QUERY, PROC_REF(on_query))
	RegisterSignal(parent, COMSIG_OVERMAP_WEAPON_FIRE, PROC_REF(on_fire))
	RegisterSignal(parent, COMSIG_OVERMAP_WEAPON_CAN_AIM, PROC_REF(on_can_aim))
	RegisterSignal(parent, COMSIG_OVERMAP_WEAPON_ROTATED, PROC_REF(on_rotated))
	RegisterSignal(parent, COMSIG_OVERMAP_WEAPON_AUTOMATIC, PROC_REF(on_automatic))
	if(istype(parent, /obj/machinery/porta_turret))
		RegisterSignal(parent, COMSIG_OVERMAP_WEAPON_PROCESS, PROC_REF(on_process))

/datum/component/ship_weapon/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_OVERMAP_WEAPON_QUERY, COMSIG_OVERMAP_WEAPON_FIRE, COMSIG_OVERMAP_WEAPON_CAN_AIM, COMSIG_OVERMAP_WEAPON_ROTATED, COMSIG_OVERMAP_WEAPON_AUTOMATIC, COMSIG_OVERMAP_WEAPON_PROCESS))

/datum/component/ship_weapon/proc/on_query(datum/source, obj/overmap/entity/vessel, list/data)
	SIGNAL_HANDLER
	if(QDELETED(vessel) || host() != vessel)
		return FALSE
	data["position"] = world_position(vessel)
	data["heading"] = heading(vessel)
	data["arc"] = arc
	data["automatic"] = automatic
	data["cooldown"] = vessel.overmap_pod ? vessel.overmap_pod.pod()?.next_firetime : next_fire
	return TRUE

/datum/component/ship_weapon/proc/on_fire(datum/source, obj/overmap/entity/vessel, x, y, mob/user)
	SIGNAL_HANDLER
	return fire_at(vessel, x, y, TRUE, user)

/datum/component/ship_weapon/proc/on_can_aim(datum/source, obj/overmap/entity/vessel, x, y)
	SIGNAL_HANDLER
	return !QDELETED(vessel) && host() == vessel && can_aim(vessel, x, y)

/datum/component/ship_weapon/proc/on_rotated(datum/source, rotation, direction)
	SIGNAL_HANDLER
	mount_dir = isnull(direction) ? angle2dir(dir2angle(mount_dir) + rotation) : direction

/datum/component/ship_weapon/proc/on_automatic(datum/source, obj/overmap/entity/vessel)
	SIGNAL_HANDLER
	if(host() == vessel && istype(parent, /obj/machinery/porta_turret))
		automatic = !automatic

/datum/component/ship_weapon/proc/on_process()
	SIGNAL_HANDLER
	return process_turret()

/datum/component/ship_weapon/Destroy()
	GLOB.overmap_weapons -= src
	return ..()

/datum/component/ship_weapon/proc/host()
	if(istype(parent, /obj/item/spacepod_equipment/weaponry))
		var/obj/item/spacepod_equipment/weaponry/module = parent
		var/obj/spacepod/craft = module.my_atom
		if(!QDELETED(craft) && craft.equipment_system?.weapon_system == module)
			return craft.overmap_vessel
		return null
	var/obj/machinery/gun = parent
	if(gun.virtual_weapon_owner)
		return QDELETED(gun.virtual_weapon_owner) ? null : gun.virtual_weapon_owner
	var/obj/overmap/entity/vessel = SSovermap.resolve_vessel(parent)
	return vessel?.shuttle ? vessel : null

/datum/component/ship_weapon/proc/world_position(obj/overmap/entity/vessel)
	if(istype(parent, /obj/item/spacepod_equipment/weaponry))
		return vessel.radar_world_origin()
	var/obj/machinery/gun = parent
	if(gun.virtual_weapon_owner == vessel)
		return vessel.hull_to_world(gun.virtual_weapon_x, gun.virtual_weapon_y)
	var/turf/spot = get_turf(parent)
	if(!spot || !vessel)
		return null
	if(vessel.free_flight_view)
		return vessel.hull_to_world(spot.x, spot.y)
	var/datum/owner = SSovermap.frame_owner(spot)
	return owner ? SSovermap.frame_to_world(owner, spot) : null

/datum/component/ship_weapon/proc/heading(obj/overmap/entity/vessel)
	if(vessel.overmap_pod)
		if(vessel.free_flight_view)
			return vessel.get_facing()
		var/obj/spacepod/craft = vessel.overmap_pod.pod()
		var/obj/overmap/entity/owner = SSovermap.frame_owner(get_turf(craft))
		return dir2angle(craft.dir) + (istype(owner) ? owner.get_facing() : 0)
	return dir2angle(mount_dir) + (vessel.free_flight_view ? vessel.get_facing() : 0)

/datum/component/ship_weapon/proc/can_aim(obj/overmap/entity/vessel, x, y)
	if(QDELETED(vessel))
		return FALSE
	var/list/point = world_position(vessel)
	return point && abs(closer_angle_difference(heading(vessel), delta_to_angle(x - point[1], y - point[2]))) <= arc / 2

/datum/component/ship_weapon/proc/fire_at(obj/overmap/entity/vessel, x, y, manual = TRUE, mob/user, mob/living/target)
	if(istype(parent, /obj/item/spacepod_equipment/weaponry))
		var/obj/item/spacepod_equipment/weaponry/module = parent
		if(host() != vessel || !can_aim(vessel, x, y))
			return FALSE
		return module.fire_weapons(user, x, y)
	var/obj/machinery/gun = parent
	if(QDELETED(gun) || QDELETED(vessel) || host() != vessel || !vessel.sector || vessel.is_jumping() || world.time < next_fire || !gun.anchored || (gun.stat & BROKEN) || !can_aim(vessel, x, y))
		return FALSE
	var/obj/machinery/porta_turret/turret = gun
	if(istype(turret))
		if(turret.disabled || !turret.enabled || turret.health <= 0)
			return FALSE
		if(turret.has_cover && !turret.raised)
			turret.popUp()
			return FALSE
		next_fire = world.time + (manual ? (1 SECONDS) : turret.shot_delay)
		turret.last_fired = world.time
	else
		next_fire = world.time + (2 SECONDS)
	return fire_projectile_burst(CALLBACK(src, PROC_REF(shoot), vessel, x, y, user, target, manual), istype(turret) ? turret.rapid : 1, istype(turret) ? turret.rapid_fire_delay : 0)

/datum/component/ship_weapon/proc/shoot(obj/overmap/entity/vessel, x, y, mob/user, mob/living/target, manual = TRUE)
	var/obj/machinery/gun = parent
	if(QDELETED(gun) || QDELETED(vessel) || host() != vessel || (gun.stat & BROKEN) || vessel.is_jumping() || !can_aim(vessel, x, y))
		return FALSE
	if(target)
		var/list/aim = target_position(vessel, target)
		if(!automatic || !aim)
			return FALSE
		x = aim[1]
		y = aim[2]
	var/list/point = world_position(vessel)
	var/obj/projectile/shot
	var/obj/machinery/porta_turret/turret = gun
	if(istype(turret))
		if(!turret.enabled || turret.disabled || turret.health <= 0)
			return FALSE
		var/atom/movable/created = turret.create_projectile(null)
		if(!isprojectile(created))
			qdel(created)
			return FALSE
		shot = created
	else
		shot = new /obj/projectile/bullet/ship_artillery(null)
		playsound(gun, 'sound/machines/bsa_fire.ogg', 65, TRUE)
	shot.hitscan = FALSE
	shot.configure_ship_shot(user, gun, damage_scale, penetration_chance)
	shot.starting = get_turf(gun)
	shot.current = get_turf(gun)
	var/angle = delta_to_angle(x - point[1], y - point[2])
	point[1] += sin(angle) * muzzle_distance
	point[2] += cos(angle) * muzzle_distance
	if(!SSovermap.launch_sector_projectile(shot, vessel.sector, point[1], point[2], angle, vessel, manual))
		qdel(shot)
		return FALSE
	if(user)
		log_attack("[key_name(user)] fired [gun] from [vessel.get_overmap_display_name()] at overmap [vessel.sector.id] ([round(x, 0.1)], [round(y, 0.1)]).")
	return TRUE

/datum/controller/subsystem/overmap/proc/ship_weapon_targets(datum/overmap_sector/sector)
	if(world.time >= weapon_targets_until)
		weapon_targets = list()
		weapon_targets_until = world.time + OVERMAP_SLOW_TICK
		for(var/mob/living/target as anything in GLOB.alive_mob_list)
			var/turf/spot = get_turf(target)
			var/datum/owner = frame_owner(spot)
			if(!owner)
				continue
			var/datum/overmap_sector/where = frame_sector(owner)
			if(!where)
				continue
			var/list/point = frame_to_world(owner, spot)
			var/list/entries = weapon_targets[where.id]
			if(!entries)
				entries = list()
				weapon_targets[where.id] = entries
			entries += list(list(target, point[1], point[2]))
	return weapon_targets[sector.id]

/datum/component/ship_weapon/proc/process_turret()
	var/obj/overmap/entity/vessel = host()
	if(!vessel || !vessel.sector)
		return FALSE
	var/obj/machinery/porta_turret/turret = parent
	if(!automatic || !turret.enabled || turret.disabled || (turret.stat & BROKEN) || world.time < next_fire)
		return TRUE
	var/list/point = world_position(vessel)
	if(!point)
		return TRUE
	var/mob/living/best
	var/best_distance = turret.scan_range ** 2
	for(var/list/entry as anything in SSovermap.ship_weapon_targets(vessel.sector))
		var/mob/living/target = entry[1]
		var/list/aim = target_position(vessel, target)
		if(!aim)
			continue
		var/distance = (aim[1] - point[1]) ** 2 + (aim[2] - point[2]) ** 2
		if(distance <= best_distance)
			best = target
			best_distance = distance
	if(best)
		var/list/aim = target_position(vessel, best)
		if(aim)
			fire_at(vessel, aim[1], aim[2], FALSE, null, best)
	return TRUE

/obj/machinery/porta_turret/shuttleRotate(rotation, params)
	. = ..()
	SEND_SIGNAL(src, COMSIG_OVERMAP_WEAPON_ROTATED, rotation)

/obj/machinery/bsa/portable/shuttleRotate(rotation, params)
	. = ..()
	SEND_SIGNAL(src, COMSIG_OVERMAP_WEAPON_ROTATED, rotation)

/obj/machinery/bsa/portable
	name = "portable bluespace artillery"
	desc = "Корабельное блюспейс-орудие с узким сектором обстрела. Управляется через Helm."
	icon_state = "emitter_center"
	use_power = NO_POWER_USE
	max_integrity = 300

/obj/machinery/bsa/portable/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/ship_weapon, arc = 30, automatic = FALSE)

/obj/machinery/bsa/portable/wrench_act(mob/living/user, obj/item/tool)
	. = TRUE
	default_unfasten_wrench(user, tool)

/obj/machinery/bsa/portable/screwdriver_act(mob/living/user, obj/item/tool)
	if(anchored)
		to_chat(user, span_warning("Сначала открепите орудие гаечным ключом."))
		return TRUE
	if(tool.use_tool(src, user, volume = tool.tool_volume))
		setDir(turn(dir, 90))
		SEND_SIGNAL(src, COMSIG_OVERMAP_WEAPON_ROTATED, 0, dir)
	return TRUE

/obj/machinery/porta_turret/syndicate/ship
	name = "ship defence turret"
	rapid = 2
	ship_damage_scale = 0.5
	ship_penetration_chance = 50
