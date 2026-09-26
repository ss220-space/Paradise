/obj/item/ammo_casing/energy/plasma
	projectile_type = /obj/projectile/plasma
	muzzle_flash_color = LIGHT_COLOR_CYAN
	select_name = "plasma burst"
	fire_sound = 'sound/weapons/pulse.ogg'
	delay = 15
	e_cost = 50 //30 shots

/obj/item/ammo_casing/energy/plasma/adv
	projectile_type = /obj/projectile/plasma/adv
	delay = 10
	e_cost = 25 //60 shots

/obj/item/ammo_casing/energy/plasma/adv/mega
	e_cost = 20 //75 shots
	projectile_type = /obj/projectile/plasma/adv/mega

/obj/item/ammo_casing/energy/plasma/shotgun
	projectile_type = /obj/projectile/plasma/shotgun
	e_cost = 75 //20 shots
	pellets = 5
	variance = 35

/obj/item/ammo_casing/energy/plasma/shotgun/mega
	e_cost = 50 //30 shots
	projectile_type = /obj/projectile/plasma/adv/mega/shotgun

// MARK: Toxin pistol
/obj/item/ammo_casing/energy/toxplasma
	projectile_type = /obj/projectile/energy/toxplasma
	muzzle_flash_color = LIGHT_COLOR_LAVENDER
	fire_sound = 'sound/weapons/gunshots/1plasma.ogg'
	select_name = "plasma dart"
	sibyl_tier = SIBYL_TIER_LETHAL

// MARK: Plasma pistol
/obj/item/ammo_casing/energy/weak_plasma
	projectile_type = /obj/projectile/energy/weak_plasma
	e_cost = 60 // With no charging, 500 damage from 25 shots.
	muzzle_flash_color = LIGHT_COLOR_LAVENDER
	fire_sound = 'sound/weapons/gunshots/1plasma.ogg'
	select_name = null //If the select name is null, it does not send a message of switching modes to the user, important on the pistol.

/obj/item/ammo_casing/energy/charged_plasma
	projectile_type = /obj/projectile/energy/charged_plasma
	e_cost = 0 //Charge is used when you charge the gun. Prevents issues.
	muzzle_flash_color = LIGHT_COLOR_LAVENDER
	fire_sound = 'sound/weapons/marauder.ogg' //Should be different enough to get attention
	select_name = null
