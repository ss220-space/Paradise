// MARK: Electrode
/obj/item/ammo_casing/energy/electrode
	projectile_type = /obj/projectile/energy/electrode
	muzzle_flash_color = "#FFFF00"
	select_name = "stun"
	fire_sound = 'sound/weapons/gunshots/1taser.ogg'
	delay = 2 SECONDS
	harmful = FALSE

/obj/item/ammo_casing/energy/electrode/advanced //admin-bus only, k? dont give this thing to 100 year old Charlie crew or other ghost role
	projectile_type = /obj/projectile/energy/electrode/advanced

/obj/item/ammo_casing/energy/electrode/gun
	fire_sound = 'sound/weapons/gunshots/gunshot.ogg'

/obj/item/ammo_casing/energy/electrode/hos //allows balancing of HoS and blueshit guns seperately from other energy weapons

/obj/item/ammo_casing/energy/electrode/blueshield
	e_cost = 150

/obj/item/ammo_casing/energy/electrode/old
	e_cost = 1000

// MARK: Disabler
/obj/item/ammo_casing/energy/disabler
	projectile_type = /obj/projectile/beam/disabler
	muzzle_flash_color = LIGHT_COLOR_BLUE
	select_name  = "disable"
	e_cost = 50
	fire_sound = 'sound/weapons/plasma_cutter.ogg'
	harmful = FALSE
	overlay_color = COLOR_HEALING_CYAN

// quick remind: accumulator guns have 1200 energy
/obj/item/ammo_casing/energy/disabler/energy_carbine
	projectile_type = /obj/projectile/beam/disabler/slowed
	fire_sound = 'sound/weapons/gunshots/1laser5.ogg'
	e_cost = 50 //25 shots
	overlay_color = COLOR_DARK_CYAN

/obj/item/ammo_casing/energy/disabler/energy_carbine/weak
	projectile_type = /obj/projectile/beam/disabler/slowed/weak
	e_cost = 25 //50 shots
	delay = 0.4 SECONDS

/obj/item/ammo_casing/energy/disabler/energy_carbine/heavy
	projectile_type = /obj/projectile/beam/disabler/slowed/heavy
	fire_sound = 'sound/weapons/gunshots/laserrifle2.ogg'
	e_cost = 150 //12 shots
	delay = 2 SECONDS

/obj/item/ammo_casing/energy/disabler/scatter
	projectile_type = /obj/projectile/beam/disabler/scatter
	pellets = 5
	variance = 25
	select_name = "scatter"

/obj/item/ammo_casing/energy/disabler/scatter/energy_shotgun
	projectile_type = /obj/projectile/beam/disabler/scatter/energy_shotgun
	e_cost = 120 //10 shots
	overlay_color = COLOR_COMMAND_BLUE

/obj/item/ammo_casing/energy/disabler/hos
	e_cost = 40

/obj/item/ammo_casing/energy/disabler/cyborg //seperate balancing for cyborg, again
	e_cost = 175

/obj/item/ammo_casing/energy/disabler/blueshield
	e_cost = 40
