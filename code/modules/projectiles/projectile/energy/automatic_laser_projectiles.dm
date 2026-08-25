
/obj/projectile/beam/disabler/automatic
	damage = 15
	icon_state = "disabler_weakbeam"

/obj/projectile/beam/laser/automatic
	damage = 15

//automatic laser mg
/obj/projectile/beam/laser/automatic/machine_gun
	icon_state = "laser_weakbeam"
	damage = 5

//automatic laser shotgun
/obj/projectile/beam/disabler/scatter/automatic_shotgun
	damage = 12 //48 per shot
	tile_dropoff = 0.75
	tile_dropoff_s = 1.25

/obj/projectile/beam/scatter/automatic_shotgun
	damage = 12 //48 per shot
	tile_dropoff = 0.75
	tile_dropoff_s = 1.25

//automatic laser sniper
/obj/projectile/beam/disabler/automatic_sniper
	damage = 60
	speed = 2

/obj/projectile/beam/laser/heavylaser/automatic_sniper
	damage = 50
	speed = 2
