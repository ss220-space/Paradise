/obj/projectile/beam/disabler/slowed
	speed = 1

/obj/projectile/beam/laser/slowed
	speed = 1

// smg
/obj/projectile/beam/disabler/slowed/weak
	damage = 12
	icon_state = "disabler_weakbeam"

/obj/projectile/beam/laser/slowed/weak
	damage = 12
	icon_state = "laser_weakbeam"

//sniper
/obj/projectile/beam/disabler/slowed/heavy
	damage = 60

/obj/projectile/beam/laser/slowed/heavy
	damage = 50

// shotgun
/obj/projectile/beam/disabler/scatter/energy_shotgun
	speed = 1
	damage = 15 //75 per shot
	tile_dropoff = 0.75
	tile_dropoff_s = 1.25

/obj/projectile/beam/scatter/energy_shotgun
	speed = 1
	damage = 11 //55 per shot
	tile_dropoff = 0.75
	tile_dropoff_s = 1.25

//pistol
/obj/projectile/beam/disabler/energy_pistol
	shield_buster = TRUE
	icon_state = "disabler_plasma"
	armour_penetration = 20
	speed = 1

/obj/projectile/beam/laser/energy_pistol
	shield_buster = TRUE
	icon_state = "laser_plasma"
	armour_penetration = 20
	speed = 1
