/obj/item/ammo_casing/energy/kinetic
	projectile_type = /obj/projectile/kinetic
	muzzle_flash_color = null
	select_name = "kinetic"
	e_cost = 500
	fire_sound = 'sound/weapons/kenetic_accel.ogg'

/obj/item/ammo_casing/energy/kinetic/ready_proj(atom/target, mob/living/user, quiet, zone_override = "")
	..()
	if(loc && istype(loc, /obj/item/gun/energy/kinetic_accelerator))
		var/obj/item/gun/energy/kinetic_accelerator/KA = loc
		KA.modify_projectile(BB)
