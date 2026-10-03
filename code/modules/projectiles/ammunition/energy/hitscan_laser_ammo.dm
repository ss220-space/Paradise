// MARK: Hitscan rifle
/obj/item/ammo_casing/energy/laser/hitscan
	name = "hitscan laser lens"
	projectile_type = /obj/projectile/beam/laser/hitscan
	select_name = "hitscan"
	delay = 0.7 SECONDS
	fire_sound = 'sound/weapons/gunshots/lasergun.ogg'

// MARK: Hitscan shotgun
/obj/item/ammo_casing/energy/laser/hitscan/laser_shotgun
	delay = 1.5 SECONDS
	e_cost = 150
	projectile_type = /obj/projectile/beam/laser/hitscan/laser_shotgun
	fire_sound = 'sound/weapons/gunshots/lasershotgun.ogg'
	select_name = "precise hitscan"

/obj/item/ammo_casing/energy/laser/hitscan/laser_shotgun/wide
	pellets = 5
	variance = 20
	select_name = "scatter hitscan"
	projectile_type = /obj/projectile/beam/laser/hitscan/laser_shotgun/pellet

// MARK: Hitscan sniper rifle
/obj/item/ammo_casing/energy/laser/hitscan/laser_rifle
	delay = 4 SECONDS
	e_cost = 200
	projectile_type = /obj/projectile/beam/laser/hitscan/laser_rifle
	fire_sound = 'sound/weapons/gunshots/laserrifle.ogg'
	select_name = "anti-vehicle hitscan"

/obj/item/ammo_casing/energy/laser/hitscan/laser_rifle/armorpierce
	fire_sound = 'sound/weapons/gunshots/laserrifle2.ogg'
	projectile_type = /obj/projectile/beam/laser/hitscan/laser_rifle/armorpierce
	select_name = "pierce hitscan"

// MARK: Hitscan MG
/obj/item/ammo_casing/energy/laser/hitscan/laser_mg
	e_cost = 40
	delay = 0.3 SECONDS
	projectile_type = /obj/projectile/beam/laser/hitscan/laser_mg
	fire_sound = 'sound/weapons/gunshots/lasermg.ogg'
	select_name = "energy hitscan"

/obj/item/ammo_casing/energy/laser/hitscan/laser_mg/ricochet
	select_name = "ricochet hitscan"
	projectile_type = /obj/projectile/beam/laser/hitscan/laser_mg/ricochet
	delay = 1

// MARK: Hitscan pistol
/obj/item/ammo_casing/energy/laser/hitscan/laser_pistol
	delay = 1 SECONDS
	projectile_type = /obj/projectile/beam/laser/hitscan/laser_pistol
	fire_sound = 'sound/weapons/gunshots/laserpistol.ogg'
	select_name = "energy hitscan"

/obj/item/ammo_casing/energy/laser/hitscan/laser_pistol/light
	projectile_type = /obj/projectile/beam/laser/hitscan/laser_pistol/light
	delay = 0.2 SECONDS
	e_cost = 50
	select_name = "fast hitscan"
