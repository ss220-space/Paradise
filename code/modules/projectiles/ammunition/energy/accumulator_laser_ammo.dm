// quick remind: accumulator guns have 1200 energy
// MARK: accumulator carbine
/obj/item/ammo_casing/energy/disabler/energy_carbine
	projectile_type = /obj/projectile/beam/disabler/slowed
	fire_sound = 'sound/weapons/gunshots/1laser5.ogg'
	overlay_color = COLOR_DARK_CYAN

/obj/item/ammo_casing/energy/laser/energy_carbine
	projectile_type = /obj/projectile/beam/laser/slowed
	e_cost = 75 //16 shots

// MARK: accumulator smg
/obj/item/ammo_casing/energy/disabler/energy_carbine/weak
	projectile_type = /obj/projectile/beam/disabler/slowed/weak
	e_cost = 25 //50 shots


/obj/item/ammo_casing/energy/laser/energy_carbine/weak
	projectile_type = /obj/projectile/beam/laser/slowed/weak
	e_cost = 40 //30 shots

// MARK: accumulator sniper
/obj/item/ammo_casing/energy/disabler/energy_carbine/heavy
	projectile_type = /obj/projectile/beam/disabler/slowed/heavy
	fire_sound = 'sound/weapons/gunshots/laserrifle2.ogg'
	e_cost = 150 //12 shots
	delay = 2 SECONDS
	select_name = "heavy-disabler"

/obj/item/ammo_casing/energy/laser/energy_carbine/heavy
	e_cost = 200 //6 shots
	fire_sound = 'sound/weapons/gunshots/laserrifle.ogg'
	projectile_type = /obj/projectile/beam/laser/slowed/heavy
	delay = 2 SECONDS
	select_name = "anti-vehicle"

// MARK: accumulator shotgun
/obj/item/ammo_casing/energy/disabler/scatter/energy_shotgun
	projectile_type = /obj/projectile/beam/disabler/scatter/energy_shotgun
	e_cost = 120 //10 shots
	select_name = "scatter-disabler"

/obj/item/ammo_casing/energy/laser/scatter/energy_shotgun
	projectile_type = /obj/projectile/beam/scatter/energy_shotgun
	e_cost = 120 //10 shots
	select_name = "scatter-lethal"
