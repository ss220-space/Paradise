// MARK: 5.56x45mm
/obj/item/ammo_casing/a556
	desc = "A 5.56x45mm bullet casing."
	materials = list(MAT_METAL = 3250)
	caliber = CALIBER_5_DOT_56X45MM
	projectile_type = /obj/projectile/bullet/heavybullet
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL
	bullet_type = BULLET_TYPE_PLAIN

// MARK: 5.45x39mm
/obj/item/ammo_casing/a545
	desc = "A 5.45x39mm bullet casing."
	caliber = CALIBER_5_DOT_45X39MM
	projectile_type = /obj/projectile/bullet/midbullet3
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL
	bullet_type = BULLET_TYPE_PLAIN

/obj/item/ammo_casing/a545/fusty
	desc = "A fusty 5.45x39mm bullet casing."
	materials = list(MAT_METAL = 1000)
	projectile_type = /obj/projectile/bullet/f545
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_STRONG

// MARK: 4.6x30mm
/obj/item/ammo_casing/c46x30mm
	desc = "A 4.6x30mm bullet casing."
	materials = list(MAT_METAL = 580)
	caliber = CALIBER_4_DOT_6X30MM
	projectile_type = /obj/projectile/bullet/weakbullet3/foursix
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL
	bullet_type = BULLET_TYPE_PLAIN

/obj/item/ammo_casing/c46x30mm/ap
	materials = list(MAT_METAL = 700, MAT_SILVER = 50)
	projectile_type = /obj/projectile/bullet/weakbullet3/foursix/ap
	bullet_type = BULLET_TYPE_ARMOR_PIERCING

/obj/item/ammo_casing/c46x30mm/tox
	materials = list(MAT_METAL = 700, MAT_SILVER = 50, MAT_URANIUM = 75)
	projectile_type = /obj/projectile/bullet/weakbullet3/foursix/tox

/obj/item/ammo_casing/c46x30mm/inc
	materials = list(MAT_METAL = 700, MAT_SILVER = 50, MAT_PLASMA = 50)
	projectile_type = /obj/projectile/bullet/incendiary/foursix
	muzzle_flash_color = LIGHT_COLOR_FIRE
	bullet_type = BULLET_TYPE_FIRE
