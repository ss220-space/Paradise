/obj/machinery/porta_turret/syndicate/ship/gun_50cal
	name = "MG338-montiert"
	icon = 'icons/obj/ship_weapons/50cal.dmi'
	ship_arc = 180
	desc = "TEMP123TEMP"
	icon_state = "idle"
	icon_state_initial = "idle"
	icon_state_active = "idle"
	icon_state_destroyed = "idle"
	appearance_flags = PIXEL_SCALE | KEEP_TOGETHER

/obj/machinery/porta_turret/syndicate/ship/adder
	parent_type = /obj/machinery/porta_turret/syndicate/ship/gun_50cal
	name = "Adder"
	icon = 'icons/obj/ship_weapons/adder.dmi'
	ship_arc = 200
	ship_round_type = /obj/projectile/ship_round/adder
	ship_cooldown = 2 SECONDS
	ship_burst = 4
	projectile = /obj/projectile/ship_round/adder
	eprojectile = /obj/projectile/ship_round/adder
	ship_damage_scale = 1
	ship_penetration_chance = 0
	rapid = 4
	shot_delay = 6 SECONDS
	ship_auto_cooldown = 6 SECONDS
	ship_burst_delay = 0.15 SECONDS
	rapid_fire_delay = 0.15 SECONDS

/obj/machinery/porta_turret/syndicate/ship/hlgg9
	parent_type = /obj/machinery/porta_turret/syndicate/ship/gun_50cal
	name = "Hlgg9"
	icon = 'icons/obj/ship_weapons/hlgg9.dmi'
	ship_round_type = /obj/projectile/ship_round/hlgg9
	ship_cooldown = 1 SECONDS
	ship_burst = 2
	projectile = /obj/projectile/ship_round/hlgg9
	eprojectile = /obj/projectile/ship_round/hlgg9
	ship_damage_scale = 1
	ship_penetration_chance = 0
	shot_delay = 1 SECONDS
	ship_gun_sound = 'sound/weapons/ship_weapons/ship_svalinn.ogg'
	shot_sound = 'sound/weapons/ship_weapons/ship_svalinn.ogg'
	eshot_sound = 'sound/weapons/ship_weapons/ship_svalinn.ogg'

/obj/machinery/porta_turret/syndicate/ship/l85
	parent_type = /obj/machinery/porta_turret/syndicate/ship/gun_50cal
	name = "L85"
	icon = 'icons/obj/ship_weapons/l85.dmi'
	ship_round_type = /obj/projectile/ship_round/l85
	ship_cooldown = 1 SECONDS
	ship_burst = 6
	projectile = /obj/projectile/ship_round/l85
	eprojectile = /obj/projectile/ship_round/l85
	ship_damage_scale = 1
	ship_penetration_chance = 0
	rapid = 6
	shot_delay = 1 SECONDS
	ship_spread = 3
	ship_gun_sound = 'sound/weapons/laser.ogg'
	shot_sound = 'sound/weapons/laser.ogg'
	eshot_sound = 'sound/weapons/laser.ogg'
	ship_burst_delay = 0.1 SECONDS
	rapid_fire_delay = 0.1 SECONDS

/obj/machinery/porta_turret/syndicate/ship/gun_50cal/Initialize(mapload)
	. = ..()
	SEND_SIGNAL(src, COMSIG_OVERMAP_WEAPON_CONFIGURE, list("arc" = ship_arc))

/obj/machinery/porta_turret/syndicate/ship/gun_50cal/shuttleRotate(rotation, params = ROTATE_DIR | ROTATE_SMOOTH | ROTATE_OFFSET)
	return ..(rotation, params & ~ROTATE_OFFSET)
