/obj/item/ammo_casing/energy/bsg
	projectile_type = /obj/projectile/energy/bsg
	muzzle_flash_color = LIGHT_COLOR_DARK_BLUE
	muzzle_flash_range = MUZZLE_FLASH_RANGE_STRONG
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_STRONG
	fire_sound = 'sound/weapons/wave.ogg'
	e_cost = 10000
	select_name = null //No one is sticking this into another gun / so I don't have to rename 20 icon states
	delay = 4 SECONDS //Looooooong cooldown // Used to be 10 seconds, has been rebalanced to be normal firing rate now

/obj/item/ammo_casing/energy/bsg/ready_proj(atom/target, mob/living/user, quiet, zone_override = "")
	..()
	var/obj/projectile/energy/bsg/P = BB
	addtimer(CALLBACK(P, TYPE_PROC_REF(/obj/projectile/energy/bsg, make_chain), P, user), 1)

