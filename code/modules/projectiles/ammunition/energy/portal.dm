/obj/item/ammo_casing/energy/wormhole
	projectile_type = /obj/projectile/beam/wormhole
	muzzle_flash_color = "#33CCFF"
	delay = 10
	fire_sound = 'sound/weapons/pulse3.ogg'
	select_name = "blue"
	harmful = FALSE

/obj/item/ammo_casing/energy/wormhole/orange
	projectile_type = /obj/projectile/beam/wormhole/orange
	muzzle_flash_color = "#FF6600"
	select_name = "orange"

/obj/item/ammo_casing/energy/teleport
	projectile_type = /obj/projectile/energy/teleport
	muzzle_flash_color = LIGHT_COLOR_BLUE
	fire_sound = 'sound/weapons/wave.ogg'
	e_cost = 250
	select_name = "teleport beam"
	var/teleport_target

/obj/item/ammo_casing/energy/teleport/New()
	..()
	BB = null

/obj/item/ammo_casing/energy/teleport/newshot()
	..(teleport_target)
