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
	bullet_type = BULLET_TYPE_DISABLER

/obj/item/ammo_casing/energy/disabler/hos
	e_cost = 40

/obj/item/ammo_casing/energy/disabler/cyborg //seperate balancing for cyborg, again
	e_cost = 175

/obj/item/ammo_casing/energy/disabler/blueshield
	e_cost = 40
