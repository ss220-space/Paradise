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
	AddComponent(/datum/component/ship_weapon, arc = 30, automatic = FALSE, mount_dir = get_ship_weapon_mount_dir())

/obj/machinery/bsa/portable/proc/get_ship_weapon_mount_dir()
	return dir

/obj/machinery/bsa/portable/wrench_act(mob/living/user, obj/item/tool)
	. = TRUE
	default_unfasten_wrench(user, tool)

/obj/machinery/bsa/portable/screwdriver_act(mob/living/user, obj/item/tool)
	if(anchored)
		to_chat(user, span_warning("Сначала открепите орудие гаечным ключом."))
		return TRUE
	if(tool.use_tool(src, user, volume = tool.tool_volume))
		setDir(turn(dir, 90))
		SEND_SIGNAL(src, COMSIG_OVERMAP_WEAPON_ROTATED, 0, get_ship_weapon_mount_dir())
	return TRUE

/obj/machinery/porta_turret/syndicate/ship
	name = "ship defence turret"
	rapid = 2
	ship_damage_scale = 0.5
	ship_penetration_chance = 50
