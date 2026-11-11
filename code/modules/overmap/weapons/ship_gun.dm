/obj/machinery/ship_gun
	abstract_type = /obj/machinery/ship_gun
	name = "ship gun"
	desc = "TEMP123TEMP"
	icon_state = "idle"
	density = TRUE
	anchored = TRUE
	use_power = NO_POWER_USE
	max_integrity = 300
	appearance_flags = PIXEL_SCALE | KEEP_TOGETHER
	ship_round_type = /obj/projectile/ship_round
	ship_cooldown = 4 SECONDS

/obj/machinery/ship_gun/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/ship_weapon, arc = ship_arc, automatic = FALSE, mount_dir = dir)

/obj/machinery/ship_gun/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	ship_emp_until = max(ship_emp_until, world.time + (severity == EMP_HEAVY ? 20 SECONDS : 10 SECONDS))

/obj/machinery/ship_gun/wrench_act(mob/living/user, obj/item/tool)
	default_unfasten_wrench(user, tool)
	return TRUE

/obj/machinery/ship_gun/screwdriver_act(mob/living/user, obj/item/tool)
	if(anchored)
		to_chat(user, span_warning("Unfasten the gun before rotating it."))
		return TRUE
	if(tool.use_tool(src, user, volume = tool.tool_volume))
		setDir(turn(dir, 90))
		SEND_SIGNAL(src, COMSIG_OVERMAP_WEAPON_ROTATED, 0, dir)
	return TRUE

/obj/machinery/ship_gun/shuttleRotate(rotation, params = ROTATE_DIR | ROTATE_SMOOTH | ROTATE_OFFSET)
	. = ..(rotation, params & ~ROTATE_OFFSET)
	SEND_SIGNAL(src, COMSIG_OVERMAP_WEAPON_ROTATED, rotation, dir)

/obj/machinery/porta_turret/syndicate/ship/gun_50cal/Initialize(mapload)
	. = ..()
	var/datum/component/ship_weapon/mount = GetComponent(/datum/component/ship_weapon)
	mount.arc = ship_arc

/obj/machinery/porta_turret/syndicate/ship/gun_50cal/shuttleRotate(rotation, params = ROTATE_DIR | ROTATE_SMOOTH | ROTATE_OFFSET)
	return ..(rotation, params & ~ROTATE_OFFSET)
