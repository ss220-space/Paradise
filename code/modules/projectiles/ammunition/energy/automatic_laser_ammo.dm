// MARK: automatic laser pistol
/obj/item/ammo_casing/energy/disabler/weaker_automatic
	delay = 1.2 SECONDS
	e_cost = 60 //20 shots
	smart_bullet = TRUE

/obj/item/ammo_casing/energy/laser/weaker_automatic
	delay = 1.2 SECONDS
	e_cost = 120 //10 shots
	smart_bullet = TRUE

// MARK: automatic laser rifle
/obj/item/ammo_casing/energy/disabler/automatic
	fire_sound = 'sound/weapons/gunshots/1laser.ogg'
	delay = 0.3 SECONDS
	projectile_type = /obj/projectile/beam/disabler/automatic

/obj/item/ammo_casing/energy/laser/automatic
	e_cost = 60 //25 shots
	fire_sound = 'sound/weapons/gunshots/lasergatling.ogg'
	randomspread = TRUE
	projectile_type = /obj/projectile/beam/laser/automatic

// MARK: automatic laser mg
/obj/item/ammo_casing/energy/laser/automatic/machine_gun
	e_cost = 30 //50 shots
	delay = 0.1 SECONDS
	projectile_type = /obj/projectile/beam/laser/automatic/machine_gun
	overlay_color = COLOR_MAGENTA
	select_name = "fast_shooting"

// MARK: automatic laser shotgun
/obj/item/ammo_casing/energy/disabler/scatter/automatic_shotgun
	projectile_type = /obj/projectile/beam/disabler/scatter/automatic_shotgun
	pellets = 4
	variance = 15
	delay = 0.6 SECONDS
	select_name = "scatter-disabler"
	e_cost = 100 //15 shots

/obj/item/ammo_casing/energy/laser/scatter/automatic_shotgun
	projectile_type = /obj/projectile/beam/scatter/automatic_shotgun
	pellets = 4
	variance = 15
	e_cost = 125 //12 shots
	select_name = "scatter-lethal"

// MARK: automatic laser sniper
/obj/item/ammo_casing/energy/disabler/automatic_sniper
	projectile_type = /obj/projectile/beam/disabler/automatic_sniper
	fire_sound = 'sound/weapons/gunshots/laserrifle2.ogg'
	e_cost = 200 //6 shots
	delay = 4 SECONDS
	select_name = "heavy-disabler"
	smart_bullet = TRUE

/obj/item/ammo_casing/energy/laser/automatic_sniper
	projectile_type = /obj/projectile/beam/laser/heavylaser/automatic_sniper
	delay = 5 SECONDS
	select_name = "anti-vehicle"
	fire_sound = 'sound/weapons/gunshots/laserrifle2.ogg'
	e_cost = 250 //6 shots
	smart_bullet = TRUE
