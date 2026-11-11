/obj/machinery/porta_turret/syndicate/ship/gun_50cal
	name = "MG338-montiert"
	icon = 'icons/obj/ship_weapons/monofrontier/50cal.dmi'
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
	icon = 'icons/obj/ship_weapons/monofrontier/adder.dmi'
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

/obj/projectile/ship_round/adder
	overmap_radar_kind = "light"
	name = "Adder projectile"
	damage = 14
	structure_damage = 14
	wall_damage = 14
	overmap_velocity = 50

/obj/machinery/ship_gun/ak820
	name = "Ak820"
	icon = 'icons/obj/ship_weapons/monofrontier/ak820.dmi'
	pixel_x = -32
	pixel_y = -32
	ship_arc = 45
	ship_round_type = /obj/projectile/ship_round/ak820
	ship_burst = 2

/obj/projectile/ship_round/ak820
	name = "Ak820 projectile"
	wall_damage = 10
	preserve_walls = TRUE
	preserve_floors = TRUE
	penetration_left = 1
	penetration_first = 20
	blast_heavy = 1.5
	blast_light = 1.5

/obj/machinery/ship_gun/apollo
	name = "Apollo"
	icon = 'icons/obj/ship_weapons/monofrontier/apollo.dmi'
	pixel_x = -32
	pixel_y = -32
	ship_arc = 10
	ship_round_type = /obj/projectile/ship_round/apollo
	ship_cooldown = 12 SECONDS
	ship_gun_sound = 'sound/weapons/monofrontier/ship_perforator.ogg'

/obj/projectile/ship_round/apollo
	overmap_radar_kind = "heavy"
	name = "Apollo projectile"
	blast_devastation = 1
	blast_heavy = 3
	blast_light = 5

/obj/machinery/ship_gun/bofors
	name = "Bofors"
	icon = 'icons/obj/ship_weapons/monofrontier/bofors.dmi'
	pixel_x = -48
	pixel_y = -48
	ship_arc = 45
	ship_round_type = /obj/projectile/ship_round/bofors
	ship_gun_sound = 'sound/weapons/monofrontier/cannon.ogg'

/obj/projectile/ship_round/bofors
	parent_type = /obj/projectile/ship_round/ak820
	name = "Bofors projectile"
	overmap_velocity = 100 / 3.6

/obj/machinery/ship_gun/cerberus
	name = "Cerberus"
	icon = 'icons/obj/ship_weapons/monofrontier/cerberus.dmi'
	pixel_x = -8
	pixel_y = -8
	ship_round_type = /obj/projectile/ship_round/cerberus
	ship_cooldown = 12 SECONDS
	ship_burst = 2
	ship_gun_sound = 'sound/weapons/laser.ogg'
	ship_burst_delay = 1 SECONDS

/obj/projectile/ship_round/cerberus
	overmap_radar_kind = "ion"
	name = "Cerberus projectile"
	overmap_velocity = 30 / 3.6
	damage = 0
	structure_damage = 0
	wall_damage = 0
	emp_heavy = 3
	emp_light = 5

/obj/machinery/ship_gun/charon
	name = "Charon"
	icon = 'icons/obj/ship_weapons/monofrontier/charon.dmi'
	pixel_x = -32
	pixel_y = -32
	ship_arc = 10
	ship_round_type = /obj/projectile/ship_round/charon
	ship_cooldown = 20 SECONDS
	ship_gun_sound = 'sound/weapons/monofrontier/leviathan_fire.ogg'

/obj/projectile/ship_round/charon
	overmap_radar_kind = "heavy"
	name = "Charon projectile"
	overmap_velocity = 170 / 3.6
	damage = 100
	structure_damage = 300
	wall_damage = 100
	penetration_left = 3
	penetration_next = 50

/obj/machinery/ship_gun/cyrexa
	name = "Cyrexa"
	icon = 'icons/obj/ship_weapons/monofrontier/cyrexa.dmi'
	pixel_x = -48
	pixel_y = -48
	ship_arc = 45
	ship_round_type = /obj/projectile/ship_round/cyrexa
	ship_burst = 2
	ship_burst_delay = 1 SECONDS

/obj/projectile/ship_round/cyrexa
	parent_type = /obj/projectile/ship_round/ak820
	overmap_radar_kind = "heavy"
	name = "Cyrexa projectile"
	blast_devastation = 1
	blast_heavy = 1
	blast_light = 1

/obj/machinery/ship_gun/dymere
	name = "Dymere"
	icon = 'icons/obj/ship_weapons/monofrontier/dymere.dmi'
	pixel_x = -48
	pixel_y = -48
	ship_arc = 10
	ship_round_type = /obj/projectile/ship_round/dymere
	ship_cooldown = 36 SECONDS
	ship_burst = 2
	ship_burst_delay = 2 SECONDS

/obj/projectile/ship_round/dymere
	parent_type = /obj/projectile/ship_round/apollo
	name = "Dymere projectile"
	overmap_velocity = 30 / 3.6
	blast_devastation = 2
	blast_heavy = 6
	blast_light = 10

/obj/machinery/ship_gun/fang
	name = "Fang"
	icon = 'icons/obj/ship_weapons/monofrontier/fang.dmi'
	pixel_x = -16
	pixel_y = -16
	ship_arc = 60
	ship_round_type = /obj/projectile/ship_round/fang
	ship_burst = 2

/obj/projectile/ship_round/fang
	name = "Fang projectile"
	damage = 40
	structure_damage = 40
	wall_damage = 40
	penetration_left = -1
	penetration_first = 30

	penetration_next = 30

/obj/machinery/ship_gun/hades
	parent_type = /obj/machinery/ship_gun/cyrexa
	name = "Hades"
	icon = 'icons/obj/ship_weapons/monofrontier/hades.dmi'
	ship_round_type = /obj/projectile/ship_round/hades
	ship_gun_sound = 'sound/weapons/monofrontier/cannon.ogg'

/obj/projectile/ship_round/hades
	parent_type = /obj/projectile/ship_round/cyrexa
	name = "Hades projectile"

/obj/machinery/ship_gun/harbringer
	name = "Harbringer"
	icon = 'icons/obj/ship_weapons/monofrontier/harbringer.dmi'
	pixel_x = -32
	pixel_y = -32
	ship_arc = 10
	ship_round_type = /obj/projectile/ship_round/harbringer
	ship_cooldown = 45 SECONDS
	ship_gun_sound = 'sound/weapons/monofrontier/leviathan_fire.ogg'

/obj/projectile/ship_round/harbringer
	overmap_radar_kind = "ion"
	name = "Harbringer projectile"
	overmap_velocity = 260 / 3.6
	damage = 0
	structure_damage = 0
	wall_damage = 0
	emp_heavy = 6
	emp_light = 10

/obj/machinery/porta_turret/syndicate/ship/hlgg9
	parent_type = /obj/machinery/porta_turret/syndicate/ship/gun_50cal
	name = "Hlgg9"
	icon = 'icons/obj/ship_weapons/monofrontier/hlgg9.dmi'
	ship_round_type = /obj/projectile/ship_round/hlgg9
	ship_cooldown = 1 SECONDS
	ship_burst = 2
	projectile = /obj/projectile/ship_round/hlgg9
	eprojectile = /obj/projectile/ship_round/hlgg9
	ship_damage_scale = 1
	ship_penetration_chance = 0
	shot_delay = 1 SECONDS
	ship_gun_sound = 'sound/weapons/monofrontier/ship_svalinn.ogg'
	shot_sound = 'sound/weapons/monofrontier/ship_svalinn.ogg'
	eshot_sound = 'sound/weapons/monofrontier/ship_svalinn.ogg'

/obj/projectile/ship_round/hlgg9
	overmap_radar_kind = "laser_light"
	name = "Hlgg9 projectile"
	damage = 20
	energy_budget = 80
	damage_cap = 40
	overmap_velocity = 50
	damage_type = BURN
	flag = LASER
	icon_state = "laser"

/obj/machinery/porta_turret/syndicate/ship/l85
	parent_type = /obj/machinery/porta_turret/syndicate/ship/gun_50cal
	name = "L85"
	icon = 'icons/obj/ship_weapons/monofrontier/l85.dmi'
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

/obj/projectile/ship_round/l85
	overmap_radar_kind = "laser_light"
	name = "L85 projectile"
	damage = 10
	energy_budget = 40
	damage_cap = 20
	overmap_velocity = 50
	damage_type = BURN
	flag = LASER
	icon_state = "laser"

/obj/machinery/ship_gun/leviathan
	name = "Leviathan"
	icon = 'icons/obj/ship_weapons/monofrontier/leviathan.dmi'
	pixel_x = -48
	pixel_y = -48
	ship_arc = 45
	ship_round_type = /obj/projectile/ship_round/leviathan
	ship_cooldown = 180 SECONDS

/obj/projectile/ship_round/leviathan
	overmap_radar_kind = "capital"
	name = "Leviathan projectile"
	overmap_velocity = 25 / 3.6
	penetration_left = 2
	blast_devastation = 4
	blast_heavy = 7
	blast_light = 10

/obj/machinery/ship_gun/paladin
	name = "Paladin"
	icon = 'icons/obj/ship_weapons/monofrontier/paladin.dmi'
	pixel_x = -32
	pixel_y = -32
	ship_arc = 60
	ship_round_type = /obj/projectile/ship_round/paladin
	ship_cooldown = 60 SECONDS
	ship_burst = 8

/obj/projectile/ship_round/paladin
	overmap_radar_kind = "missile"
	name = "Paladin projectile"
	blast_devastation = 0
	blast_heavy = 1
	blast_light = 2

/obj/machinery/ship_gun/prometheus
	name = "Prometheus"
	icon = 'icons/obj/ship_weapons/monofrontier/prometheus.dmi'
	pixel_x = -16
	pixel_y = -16
	ship_round_type = /obj/projectile/ship_round/prometheus
	ship_cooldown = 12 SECONDS
	ship_gun_sound = 'sound/weapons/monofrontier/ship_perforator.ogg'

/obj/projectile/ship_round/prometheus
	overmap_radar_kind = "laser_heavy"
	name = "Prometheus projectile"
	overmap_velocity = 200 / 3.6
	damage = 90
	energy_budget = 600
	damage_cap = 300
	damage_type = BURN
	flag = LASER
	icon_state = "laser"

/obj/machinery/ship_gun/rac_30_draupnir
	name = "RAC-30"
	icon = 'icons/obj/ship_weapons/monofrontier/rac_30_draupnir.dmi'
	pixel_x = -16
	pixel_y = -16
	ship_arc = 120
	ship_round_type = /obj/projectile/ship_round/rac_30_draupnir
	ship_cooldown = 1.2 SECONDS
	ship_burst = 12
	ship_spread = 3
	ship_burst_delay = 0.1 SECONDS

/obj/projectile/ship_round/rac_30_draupnir
	overmap_radar_kind = "light"
	name = "RAC-30 projectile"
	damage = 20
	structure_damage = 20
	wall_damage = 20
	penetration_left = -1
	penetration_first = 20

	penetration_next = 20

/obj/machinery/ship_gun/sandbox
	name = "Sandbox"
	icon = 'icons/obj/ship_weapons/monofrontier/sandbox.dmi'
	pixel_x = -56
	pixel_y = -56
	ship_arc = 10
	ship_round_type = /obj/projectile/ship_round/sandbox
	ship_cooldown = 300 SECONDS
	ship_burst = 2
	ship_burst_delay = 2 SECONDS

/obj/projectile/ship_round/sandbox
	overmap_radar_kind = "capital"
	name = "Sandbox projectile"
	overmap_velocity = 140 / 3.6
	blast_devastation = 6
	blast_heavy = 10
	blast_light = 14

/obj/machinery/ship_gun/scylla
	name = "Scylla"
	icon = 'icons/obj/ship_weapons/monofrontier/scylla.dmi'
	pixel_x = -32
	pixel_y = -32
	ship_arc = 10
	ship_round_type = /obj/projectile/ship_round/scylla
	ship_cooldown = 300 SECONDS
	ship_burst = 2
	ship_gun_sound = 'sound/weapons/laser.ogg'
	ship_burst_delay = 2 SECONDS

/obj/projectile/ship_round/scylla
	overmap_radar_kind = "capital_ion"
	name = "Scylla projectile"
	overmap_velocity = 140 / 3.6
	damage = 0
	structure_damage = 0
	wall_damage = 0
	emp_heavy = 12
	emp_light = 18

/obj/machinery/ship_gun/serpent
	name = "Serpent"
	icon = 'icons/obj/ship_weapons/monofrontier/serpent.dmi'
	ship_arc = 70
	ship_round_type = /obj/projectile/ship_round/serpent
	ship_cooldown = 45 SECONDS
	ship_burst = 2
	ship_burst_delay = 1 SECONDS

/obj/projectile/ship_round/serpent
	overmap_radar_kind = "guided_missile"
	name = "Serpent projectile"
	overmap_velocity = 30 / 3.6
	guided = TRUE
	blast_devastation = 1
	blast_heavy = 3
	blast_light = 5

/obj/machinery/ship_gun/t241
	name = "T241"
	icon = 'icons/obj/ship_weapons/monofrontier/t241.dmi'
	pixel_x = -32
	pixel_y = -32
	ship_round_type = /obj/projectile/ship_round/t241
	ship_cooldown = 60 SECONDS
	ship_burst = 3
	ship_gun_sound = 'sound/weapons/laser.ogg'
	ship_burst_delay = 2 SECONDS

/obj/projectile/ship_round/t241
	overmap_radar_kind = "laser_capital"
	name = "T241 projectile"
	overmap_velocity = 200 / 3.6
	damage = 160
	energy_budget = 2000
	damage_cap = 400
	damage_type = BURN
	flag = LASER
	icon_state = "laser"

/obj/machinery/ship_gun/tartarus
	name = "Tartarus"
	icon = 'icons/obj/ship_weapons/monofrontier/tartarus.dmi'
	pixel_x = -32
	pixel_y = -32
	ship_arc = 10
	ship_round_type = /obj/projectile/ship_round/tartarus
	ship_cooldown = 200 SECONDS
	ship_gun_sound = 'sound/weapons/monofrontier/leviathan_fire.ogg'

/obj/projectile/ship_round/tartarus
	overmap_radar_kind = "laser_capital"
	name = "Tartarus projectile"
	overmap_velocity = 200 / 3.6
	damage = 300
	energy_budget = 6000
	damage_cap = 600
	damage_type = BURN
	flag = LASER
	icon_state = "laser"

/obj/machinery/ship_gun/thanatos
	name = "Thanatos"
	icon = 'icons/obj/ship_weapons/monofrontier/thanatos.dmi'
	pixel_x = -48
	pixel_y = -48
	ship_arc = 10
	ship_round_type = /obj/projectile/ship_round/thanatos
	ship_cooldown = 300 SECONDS
	ship_burst = 2
	ship_gun_sound = 'sound/weapons/monofrontier/leviathan_fire.ogg'
	ship_burst_delay = 2 SECONDS

/obj/projectile/ship_round/thanatos
	overmap_radar_kind = "capital_rail"
	name = "Thanatos projectile"
	overmap_velocity = 460 / 3.6
	damage = 1000
	erase_obstacles = TRUE

/obj/machinery/ship_gun/vanquisher
	name = "Vanquisher"
	icon = 'icons/obj/ship_weapons/monofrontier/vanquisher.dmi'
	pixel_x = -32
	pixel_y = -32
	ship_arc = 60
	ship_round_type = /obj/projectile/ship_round/vanquisher
	ship_cooldown = 90 SECONDS
	ship_burst = 12

/obj/projectile/ship_round/vanquisher
	overmap_radar_kind = "missile"
	name = "Vanquisher projectile"
	blast_devastation = 0
	blast_heavy = 2
	blast_light = 3
