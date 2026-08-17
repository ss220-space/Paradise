/obj/projectile/beam/laser/hitscan
	hitscan = TRUE
	damage = 20

// hitscan sniper
/obj/projectile/beam/laser/hitscan/laser_rifle
	tracer_type = /obj/effect/projectile/tracer/laser/heavy
	muzzle_type = /obj/effect/projectile/muzzle/laser/heavy
	impact_type = /obj/effect/projectile/impact/laser/heavy
	damage = 40

/obj/projectile/beam/laser/hitscan/laser_rifle/armorpierce
	tracer_type = /obj/effect/projectile/tracer/laser/armorpierce
	muzzle_type = /obj/effect/projectile/muzzle/laser/armorpierce
	impact_type = /obj/effect/projectile/impact/laser/armorpierce
	armour_penetration = 50
	damage = 20
	forcedodge = 2
	ricochet_chance = 0

//hitscan shotgun
/obj/projectile/beam/laser/hitscan/laser_shotgun
	tracer_type = /obj/effect/projectile/tracer/laser/heavy
	muzzle_type = /obj/effect/projectile/muzzle/laser/heavy
	impact_type = /obj/effect/projectile/impact/laser/heavy
	damage = 25
	armour_penetration = 25

/obj/projectile/beam/laser/hitscan/laser_shotgun/pellet
	tracer_type = /obj/effect/projectile/tracer/laser/light
	muzzle_type = /obj/effect/projectile/muzzle/laser/light
	impact_type = /obj/effect/projectile/impact/laser/light
	damage = 7
	armour_penetration = 0

//hitscan smg
/obj/projectile/beam/laser/hitscan/laser_mg
	tracer_type = /obj/effect/projectile/tracer/laser/light
	muzzle_type = /obj/effect/projectile/muzzle/laser/light
	impact_type = /obj/effect/projectile/impact/laser/light
	damage = 5

/obj/projectile/beam/laser/hitscan/laser_mg/ricochet
	icon_state = "lasershot"
	range = 40
	hitscan = FALSE
	can_ricochet_from_everything = TRUE
	ricochet_chance = 100
	ricochets_max = 10
	speed = 2
	reflectability = REFLECTABILITY_PHYSICAL

//hitscan pistol
/obj/projectile/beam/laser/hitscan/laser_pistol

/obj/projectile/beam/laser/hitscan/laser_pistol/light
	tracer_type = /obj/effect/projectile/tracer/laser/light
	muzzle_type = /obj/effect/projectile/muzzle/laser/light
	impact_type = /obj/effect/projectile/impact/laser/light
	damage = 10
