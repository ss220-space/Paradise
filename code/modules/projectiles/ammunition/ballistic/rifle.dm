// MARK: 7.62x54mm
/obj/item/ammo_casing/a762
	desc = "A 7.62x54mm bullet casing."
	icon_state = "762-casing"
	materials = list(MAT_METAL = 4000)
	caliber = CALIBER_7_DOT_62X54MM
	projectile_type = /obj/projectile/bullet
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_STRONG
	muzzle_flash_range = MUZZLE_FLASH_RANGE_STRONG
	bullet_type = BULLET_TYPE_PLAIN

/obj/item/ammo_casing/a762/enchanted
	materials = list(MAT_METAL = 1000)
	projectile_type = /obj/projectile/bullet/weakbullet3
