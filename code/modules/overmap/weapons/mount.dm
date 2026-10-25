GLOBAL_LIST_EMPTY(overmap_weapons)

/obj/machinery
	var/obj/overmap/entity/virtual_structure/virtual_weapon_owner
	var/virtual_weapon_x
	var/virtual_weapon_y

/datum/component/ship_weapon
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/arc = 180
	var/mount_dir
	var/automatic = TRUE
	var/next_fire = 0
	var/burst = 1
	var/damage_scale = 1
	var/penetration_chance = 0
	var/muzzle_distance = 0.8

/datum/component/ship_weapon/Initialize()
	if(!ismachinery(parent) && !istype(parent, /obj/item/spacepod_equipment/weaponry))
		return COMPONENT_INCOMPATIBLE
	var/obj/gun = parent
	mount_dir = gun.dir
	GLOB.overmap_weapons += src

/datum/component/ship_weapon/Destroy()
	GLOB.overmap_weapons -= src
	return ..()

/datum/component/ship_weapon/proc/host()
	if(istype(parent, /obj/item/spacepod_equipment/weaponry))
		var/obj/item/spacepod_equipment/weaponry/module = parent
		var/obj/spacepod/craft = module.my_atom
		if(!QDELETED(craft) && craft.equipment_system?.weapon_system == module)
			return craft.overmap_vessel || SSovermap.get_or_register_pod(craft)
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
	if(QDELETED(gun) || host() != vessel || !vessel.sector || vessel.is_jumping() || vessel.relay_jump_from || world.time < next_fire || !gun.anchored || (gun.stat & BROKEN) || !can_aim(vessel, x, y))
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
	if(!shoot(vessel, x, y, user, target))
		return FALSE
	if(burst > 1)
		for(var/index in 2 to burst)
			addtimer(CALLBACK(src, PROC_REF(shoot), vessel, x, y, user, target), (index - 1) * 2)
	return TRUE

/datum/component/ship_weapon/proc/shoot(obj/overmap/entity/vessel, x, y, mob/user, mob/living/target)
	var/obj/machinery/gun = parent
	if(QDELETED(gun) || QDELETED(vessel) || host() != vessel || (gun.stat & BROKEN) || vessel.is_jumping() || vessel.relay_jump_from || !can_aim(vessel, x, y))
		return FALSE
	if(target)
		var/list/aim = target_position(vessel, target)
		if(!automatic || !aim)
			return FALSE
		x = aim[1]
		y = aim[2]
	var/list/point = world_position(vessel)
	var/shot_type = /obj/projectile/bullet/ship_artillery
	var/shot_sound = 'sound/machines/bsa_fire.ogg'
	var/obj/machinery/porta_turret/turret = gun
	if(istype(turret))
		if(!turret.enabled || turret.disabled || turret.health <= 0)
			return FALSE
		shot_type = (turret.emagged || turret.lethal) ? turret.eprojectile : turret.projectile
		shot_sound = (turret.emagged || turret.lethal) ? turret.eshot_sound : turret.shot_sound
	if(!ispath(shot_type, /obj/projectile))
		return FALSE
	var/obj/projectile/shot = new shot_type(null)
	shot.hitscan = FALSE
	shot.damage *= damage_scale
	if(penetration_chance)
		shot.ship_penetrations = 1
		shot.ship_penetration_chance = penetration_chance
		shot.ship_penetration_decay = 0.5
	shot.firer = user
	shot.firer_source_atom = gun
	shot.starting = get_turf(gun)
	shot.current = get_turf(gun)
	LAZYADD(shot.permutated, gun)
	var/angle = delta_to_angle(x - point[1], y - point[2])
	point[1] += sin(angle) * muzzle_distance
	point[2] += cos(angle) * muzzle_distance
	if(!SSovermap.launch_sector_projectile(shot, vessel.sector, point[1], point[2], angle, vessel))
		qdel(shot)
		return FALSE
	if(shot_sound)
		playsound(gun, shot_sound, 65, TRUE)
	if(user)
		log_attack("[key_name(user)] fired [gun] from [vessel.get_overmap_display_name()] at overmap [vessel.sector.id] ([round(x, 0.1)], [round(y, 0.1)]).")
	return TRUE

/datum/controller/subsystem/overmap
	var/weapon_targets_until = 0
	var/list/weapon_targets = list()

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

/obj/machinery/porta_turret
	var/datum/component/ship_weapon/ship_weapon

/obj/machinery/porta_turret/shuttleRotate(rotation, params)
	. = ..()
	if(ship_weapon)
		ship_weapon.mount_dir = angle2dir(dir2angle(ship_weapon.mount_dir) + rotation)

/obj/machinery/bsa/portable/shuttleRotate(rotation, params)
	. = ..()
	var/datum/component/ship_weapon/weapon = GetComponent(/datum/component/ship_weapon)
	if(weapon)
		weapon.mount_dir = angle2dir(dir2angle(weapon.mount_dir) + rotation)

/obj/machinery/bsa/portable
	name = "portable bluespace artillery"
	desc = "Корабельное блюспейс-орудие с узким сектором обстрела. Управляется через Helm."
	icon_state = "emitter_center"
	density = TRUE
	anchored = TRUE
	use_power = NO_POWER_USE
	max_integrity = 300

/obj/machinery/bsa/portable/Initialize(mapload)
	. = ..()
	var/datum/component/ship_weapon/weapon = AddComponent(/datum/component/ship_weapon)
	weapon.arc = 30
	weapon.automatic = FALSE

/obj/machinery/bsa/portable/wrench_act(mob/living/user, obj/item/tool)
	. = TRUE
	default_unfasten_wrench(user, tool)

/obj/machinery/bsa/portable/screwdriver_act(mob/living/user, obj/item/tool)
	if(anchored)
		to_chat(user, span_warning("Сначала открепите орудие гаечным ключом."))
		return TRUE
	if(tool.use_tool(src, user, volume = tool.tool_volume))
		setDir(turn(dir, 90))
		var/datum/component/ship_weapon/weapon = GetComponent(/datum/component/ship_weapon)
		weapon.mount_dir = dir
	return TRUE

/obj/machinery/porta_turret/syndicate/ship
	name = "ship defence turret"

/obj/machinery/porta_turret/syndicate/ship/Initialize(mapload)
	. = ..()
	ship_weapon.burst = 2
	ship_weapon.damage_scale = 0.5
	ship_weapon.penetration_chance = 50
