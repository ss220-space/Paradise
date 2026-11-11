/datum/component/ship_weapon
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/arc = 180
	var/mount_dir
	var/automatic = TRUE
	var/cooldown_duration = 0
	var/next_fire = 0
	var/burst_remaining = 0
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
	data["cooldown_total"] = cooldown_duration / (1 SECONDS)
	var/obj/machinery/gun = parent
	data["cooldown"] = vessel.overmap_pod ? vessel.overmap_pod.pod()?.next_firetime : max(next_fire, gun.ship_emp_until, burst_remaining ? world.time + burst_remaining * max(world.tick_lag, gun.ship_burst_delay) : 0)
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
	return vessel

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
	var/obj/machinery/gun = parent
	if(gun.ship_round_type || istype(gun, /obj/machinery/porta_turret/syndicate/ship/gun_50cal))
		mount_dir = gun.dir
	var/obj/machinery/bsa/portable/artillery = parent
	if(istype(artillery))
		mount_dir = artillery.get_ship_weapon_mount_dir()
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
	if(QDELETED(gun) || QDELETED(vessel) || host() != vessel || !vessel.sector || vessel.is_jumping() || world.time < max(next_fire, gun.ship_emp_until) || burst_remaining || !gun.anchored || (gun.stat & BROKEN) || !can_aim(vessel, x, y))
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
	if(gun.ship_cooldown)
		next_fire = world.time + max(manual || !gun.ship_auto_cooldown ? gun.ship_cooldown : gun.ship_auto_cooldown, gun.ship_burst * gun.ship_burst_delay)
	cooldown_duration = next_fire - world.time
	burst_remaining = gun.ship_cooldown ? gun.ship_burst : istype(turret) ? turret.rapid : 1
	return fire_projectile_burst(CALLBACK(src, PROC_REF(burst_shot), vessel, x, y, user, target, manual), burst_remaining, gun.ship_cooldown ? gun.ship_burst_delay : istype(turret) ? turret.rapid_fire_delay : 0)

/datum/component/ship_weapon/proc/burst_shot(obj/overmap/entity/vessel, x, y, mob/user, mob/living/target, manual)
	if(!burst_remaining || !shoot(vessel, x, y, user, target, manual))
		burst_remaining = 0
		return FALSE
	burst_remaining--
	var/obj/machinery/gun = parent
	if(!burst_remaining)
		next_fire = max(next_fire, world.time + max(world.tick_lag, gun.ship_burst_delay))
	return TRUE

/datum/component/ship_weapon/proc/shoot(obj/overmap/entity/vessel, x, y, mob/user, mob/living/target, manual = TRUE)
	var/obj/machinery/gun = parent
	if(QDELETED(gun) || QDELETED(vessel) || host() != vessel || (gun.stat & BROKEN) || world.time < gun.ship_emp_until || !gun.anchored || !vessel.sector || vessel.is_jumping())
		return FALSE
	if(vessel.ship_ai && !manual)
		var/list/ai_aim = vessel.ship_ai.burst_aim(src)
		if(!ai_aim)
			return FALSE
		x = ai_aim[1]
		y = ai_aim[2]
	if(!can_aim(vessel, x, y))
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
	else if(gun.ship_round_type)
		shot = new gun.ship_round_type(null)
		playsound(gun, gun.ship_gun_sound, 65, TRUE)
	else
		shot = new /obj/projectile/bullet/ship_artillery(null)
		playsound(gun, 'sound/machines/bsa_fire.ogg', 65, TRUE)
	if(!point)
		qdel(shot)
		return FALSE
	shot.hitscan = FALSE
	shot.configure_ship_shot(user, gun, damage_scale, penetration_chance)
	shot.starting = get_turf(gun)
	shot.current = get_turf(gun)
	var/angle = delta_to_angle(x - point[1], y - point[2]) + (rand(-1000, 1000) / 1000) * gun.ship_spread
	point[1] += sin(angle) * muzzle_distance
	point[2] += cos(angle) * muzzle_distance
	if(!SSovermap.launch_sector_projectile(shot, vessel.sector, point[1], point[2], angle, vessel, manual || !!vessel.ship_ai))
		qdel(shot)
		return FALSE
	if(user)
		log_attack("[key_name(user)] fired [gun] from [vessel.get_overmap_display_name()] at overmap [vessel.sector.id] ([round(x, 0.1)], [round(y, 0.1)]).")
	return TRUE

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

/datum/component/ship_weapon/proc/target_position(obj/overmap/entity/vessel, mob/living/target)
	if(QDELETED(target) || target.stat == DEAD || target.invisibility > SEE_INVISIBLE_LIVING)
		return null
	var/obj/machinery/porta_turret/turret = parent
	var/turf/spot = get_turf(target)
	var/datum/owner = SSovermap.frame_owner(spot)
	if(!owner || SSovermap.frame_sector(owner) != vessel.sector)
		return null
	var/list/point = SSovermap.frame_to_world(owner, spot)
	var/list/origin = world_position(vessel)
	if(!origin || (point[1] - origin[1]) ** 2 + (point[2] - origin[2]) ** 2 > turret.scan_range ** 2 || !can_aim(vessel, point[1], point[2]))
		return null
	if(turret.assess_living(target, TRUE) == TURRET_NOT_TARGET)
		return null
	var/angle = delta_to_angle(point[1] - origin[1], point[2] - origin[2])
	origin[1] += sin(angle) * muzzle_distance
	origin[2] += cos(angle) * muzzle_distance
	return SSovermap.weapon_line_clear(vessel.sector, origin, point) ? point : null
