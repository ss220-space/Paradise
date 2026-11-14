/obj/projectile/ship_round/adder
	overmap_radar_kind = "light"
	name = "Adder projectile"
	damage = 14
	structure_damage = 14
	wall_damage = 14
	overmap_velocity = 100

/obj/projectile/ship_round/ak820
	name = "Ak820 projectile"
	wall_damage = 10
	preserve_walls = TRUE
	preserve_floors = TRUE
	penetration_left = 1
	penetration_first = 20
	blast_heavy = 1.5
	blast_light = 1.5

/obj/projectile/ship_round/apollo
	overmap_radar_kind = "heavy"
	name = "Apollo projectile"
	blast_devastation = 1
	blast_heavy = 3
	blast_light = 5

/obj/projectile/ship_round/bofors
	parent_type = /obj/projectile/ship_round/ak820
	name = "Bofors projectile"
	overmap_velocity = 200 / 3.6

/obj/projectile/ship_round/cerberus
	overmap_radar_kind = "ion"
	name = "Cerberus projectile"
	overmap_velocity = 60 / 3.6
	damage = 0
	structure_damage = 0
	wall_damage = 0
	emp_heavy = 3
	emp_light = 5

/obj/projectile/ship_round/charon
	overmap_radar_kind = "heavy"
	name = "Charon projectile"
	overmap_velocity = 340 / 3.6
	damage = 100
	structure_damage = 300
	wall_damage = 100
	penetration_left = 3
	penetration_next = 50

/obj/projectile/ship_round/cyrexa
	parent_type = /obj/projectile/ship_round/ak820
	overmap_radar_kind = "heavy"
	name = "Cyrexa projectile"
	blast_devastation = 1
	blast_heavy = 1
	blast_light = 1

/obj/projectile/ship_round/dymere
	parent_type = /obj/projectile/ship_round/apollo
	name = "Dymere projectile"
	overmap_velocity = 60 / 3.6
	blast_devastation = 2
	blast_heavy = 6
	blast_light = 10

/obj/projectile/ship_round/fang
	name = "Fang projectile"
	damage = 40
	structure_damage = 40
	wall_damage = 40
	penetration_left = -1
	penetration_first = 30

	penetration_next = 30

/obj/projectile/ship_round/hades
	parent_type = /obj/projectile/ship_round/cyrexa
	name = "Hades projectile"

/obj/projectile/ship_round/harbringer
	overmap_radar_kind = "ion"
	name = "Harbringer projectile"
	overmap_velocity = 520 / 3.6
	damage = 0
	structure_damage = 0
	wall_damage = 0
	emp_heavy = 6
	emp_light = 10

/obj/projectile/ship_round/hlgg9
	overmap_radar_kind = "laser_light"
	name = "Hlgg9 projectile"
	damage = 20
	energy_budget = 80
	damage_cap = 40
	overmap_velocity = 100
	damage_type = BURN
	flag = LASER
	icon_state = "laser"

/obj/projectile/ship_round/l85
	overmap_radar_kind = "laser_light"
	name = "L85 projectile"
	damage = 10
	energy_budget = 40
	damage_cap = 20
	overmap_velocity = 100
	damage_type = BURN
	flag = LASER
	icon_state = "laser"

/obj/projectile/ship_round/leviathan
	overmap_radar_kind = "capital"
	name = "Leviathan projectile"
	overmap_velocity = 50 / 3.6
	penetration_left = 2
	blast_devastation = 4
	blast_heavy = 7
	blast_light = 10

/obj/projectile/ship_round/paladin
	overmap_radar_kind = "missile"
	name = "Paladin projectile"
	blast_devastation = 0
	blast_heavy = 1
	blast_light = 2

/obj/projectile/ship_round/prometheus
	overmap_radar_kind = "laser_heavy"
	name = "Prometheus projectile"
	overmap_velocity = 400 / 3.6
	damage = 90
	energy_budget = 600
	damage_cap = 300
	damage_type = BURN
	flag = LASER
	icon_state = "laser"

/obj/projectile/ship_round/rac_30_draupnir
	overmap_radar_kind = "light"
	name = "RAC-30 projectile"
	damage = 20
	structure_damage = 20
	wall_damage = 20
	penetration_left = -1
	penetration_first = 20

	penetration_next = 20

/obj/projectile/ship_round/sandbox
	overmap_radar_kind = "capital"
	name = "Sandbox projectile"
	overmap_velocity = 280 / 3.6
	blast_devastation = 6
	blast_heavy = 10
	blast_light = 14

/obj/projectile/ship_round/scylla
	overmap_radar_kind = "capital_ion"
	name = "Scylla projectile"
	overmap_velocity = 280 / 3.6
	damage = 0
	structure_damage = 0
	wall_damage = 0
	emp_heavy = 12
	emp_light = 18

/obj/projectile/ship_round/serpent
	overmap_radar_kind = "guided_missile"
	name = "Serpent projectile"
	overmap_velocity = 60 / 3.6
	guided = TRUE
	blast_devastation = 1
	blast_heavy = 3
	blast_light = 5

/obj/projectile/ship_round/t241
	overmap_radar_kind = "laser_capital"
	name = "T241 projectile"
	overmap_velocity = 400 / 3.6
	damage = 160
	energy_budget = 2000
	damage_cap = 400
	damage_type = BURN
	flag = LASER
	icon_state = "laser"

/obj/projectile/ship_round/tartarus
	overmap_radar_kind = "laser_capital"
	name = "Tartarus projectile"
	overmap_velocity = 400 / 3.6
	damage = 300
	energy_budget = 6000
	damage_cap = 600
	damage_type = BURN
	flag = LASER
	icon_state = "laser"

/obj/projectile/ship_round/thanatos
	overmap_radar_kind = "capital_rail"
	name = "Thanatos projectile"
	overmap_velocity = 920 / 3.6
	damage = 1000
	erase_obstacles = TRUE

/obj/projectile/ship_round/vanquisher
	overmap_radar_kind = "missile"
	name = "Vanquisher projectile"
	blast_devastation = 0
	blast_heavy = 2
	blast_light = 3

/obj/projectile/ship_round/ak820/stealth
	overmap_radar_visible = FALSE

/obj/projectile/ship_round/charon/stealth
	overmap_radar_visible = FALSE

/obj/projectile/ship_round/fang/stealth
	overmap_radar_visible = FALSE
