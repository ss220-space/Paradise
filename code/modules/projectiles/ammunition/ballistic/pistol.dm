// MARK: 9mm
/obj/item/ammo_casing/c9mm
	desc = "A 9mm bullet casing."
	caliber = CALIBER_9MM
	materials = list(MAT_METAL = 1000)
	projectile_type = /obj/projectile/bullet/weakbullet3
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL
	bullet_type = BULLET_TYPE_PLAIN

/obj/item/ammo_casing/c9mm/ap
	materials = list(MAT_METAL = 1500, MAT_SILVER = 150)
	projectile_type = /obj/projectile/bullet/armourpiercing
	bullet_type = BULLET_TYPE_ARMOR_PIERCING

/obj/item/ammo_casing/c9mm/tox
	materials = list(MAT_METAL = 1500, MAT_SILVER = 150, MAT_URANIUM = 200)
	projectile_type = /obj/projectile/bullet/toxinbullet

/obj/item/ammo_casing/c9mm/inc
	materials = list(MAT_METAL = 1500, MAT_SILVER = 150, MAT_PLASMA = 200)
	projectile_type = /obj/projectile/bullet/incendiary/firebullet
	muzzle_flash_color = LIGHT_COLOR_FIRE
	bullet_type = BULLET_TYPE_FIRE

/obj/item/ammo_casing/rubber9mm
	desc = "A 9mm rubber bullet casing."
	icon_state = "r-casing"
	materials = list(MAT_METAL = 650)
	caliber = CALIBER_9MM
	projectile_type = /obj/projectile/bullet/weakbullet4
	bullet_type = BULLET_TYPE_RUBBER

// MARK: 9mm - Enforcer special
// DELETE THIS PLEASE
/obj/item/ammo_casing/enforcer/laser
	desc = "Лазерный патрон для пистолета \"Блюститель\"."
	icon_state = "laser-casing"
	caliber = CALIBER_9MM
	materials = list(MAT_METAL = 1150)
	projectile_type = /obj/projectile/beam/specter/laser
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL
	muzzle_flash_color = COLOR_SOFT_RED
	fire_sound = 'sound/weapons/gunshots/1laser7.ogg'
	bullet_type = BULLET_TYPE_LASER

/obj/item/ammo_casing/enforcer/disable
	desc = "Парализующий патрон для пистолета \"Блюститель\"."
	icon_state = "stam-casing"
	caliber = CALIBER_9MM
	materials = list(MAT_METAL = 800)
	projectile_type = /obj/projectile/beam/specter/disabler
	muzzle_flash_color = LIGHT_COLOR_BLUE
	fire_sound = 'sound/weapons/plasma_cutter.ogg'
	bullet_type = BULLET_TYPE_DISABLER

// MARK: .40 N&R
/obj/item/ammo_casing/fortynr
	desc = "A 40nr bullet casing."
	materials = list(MAT_METAL = 1100)
	caliber = CALIBER_40NR
	projectile_type = /obj/projectile/bullet/weakbullet3/fortynr
	bullet_type = BULLET_TYPE_PLAIN

// MARK: 7.62x25mm
/obj/item/ammo_casing/ftt762
	desc = "A fusty 7.62x25mm TT bullet casing."
	icon_state = "r-casing"
	materials = list(MAT_METAL = 1000)
	caliber = CALIBER_7_DOT_62X25MM
	projectile_type = /obj/projectile/bullet/ftt762
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_STRONG
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL
	bullet_type = BULLET_TYPE_PLAIN

// MARK: .50AE
/obj/item/ammo_casing/a50
	desc = "A .50AE bullet casing."
	materials = list(MAT_METAL = 4000)
	caliber = CALIBER_DOT_50AE //change to diffrent caliber because players got deagle in uplink
	projectile_type = /obj/projectile/bullet/desert_eagle
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_STRONG
	bullet_type = BULLET_TYPE_PLAIN

// MARK: 10mm
/obj/item/ammo_casing/c10mm
	desc = "A 10mm bullet casing."
	materials = list(MAT_METAL = 1500)
	caliber = CALIBER_10MM
	projectile_type = /obj/projectile/bullet/midbullet3
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL
	bullet_type = BULLET_TYPE_PLAIN

/obj/item/ammo_casing/c10mm/ap
	materials = list(MAT_METAL = 2000, MAT_SILVER = 200)
	projectile_type = /obj/projectile/bullet/midbullet3/ap
	bullet_type = BULLET_TYPE_ARMOR_PIERCING

/obj/item/ammo_casing/c10mm/fire
	materials = list(MAT_METAL = 2000, MAT_SILVER = 200, MAT_PLASMA = 300)
	projectile_type = /obj/projectile/bullet/midbullet3/fire
	muzzle_flash_color = LIGHT_COLOR_FIRE
	bullet_type = BULLET_TYPE_FIRE

/obj/item/ammo_casing/c10mm/hp
	materials = list(MAT_METAL = 2000, MAT_SILVER = 200)
	projectile_type = /obj/projectile/bullet/midbullet3/hp
	bullet_type = BULLET_TYPE_EXPANSIVE

// MARK: .45
/obj/item/ammo_casing/c45
	desc = "A .45 bullet casing."
	materials = list(MAT_METAL = 1500)
	caliber = CALIBER_DOT_45
	projectile_type = /obj/projectile/bullet/midbullet
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL
	bullet_type = BULLET_TYPE_PLAIN

/obj/item/ammo_casing/c45/nostamina
	materials = list(MAT_METAL = 1500)
	projectile_type = /obj/projectile/bullet/midbullet3

/obj/item/ammo_casing/rubber45
	desc = "A .45 rubber bullet casing."
	icon_state = "r-casing"
	materials = list(MAT_METAL = 650)
	caliber = CALIBER_DOT_45
	projectile_type = /obj/projectile/bullet/midbullet_r
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL
	bullet_type = BULLET_TYPE_RUBBER

// MARK: .45 Colt
/obj/item/ammo_casing/c45colt
	desc = "A .45 Colt bullet casing."
	materials = list(MAT_METAL = 1000)
	caliber = CALIBER_DOT_45_COLT
	projectile_type = /obj/projectile/bullet/c45colt
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL
	bullet_type = BULLET_TYPE_PLAIN

/obj/item/ammo_casing/c45colt/rubber
	desc = "A .45 Colt rubber bullet casing."
	icon_state = "r-casing"
	materials = list(MAT_METAL = 650)
	projectile_type = /obj/projectile/bullet/rubber45colt
	bullet_type = BULLET_TYPE_RUBBER

/obj/item/ammo_casing/c45colt/hp
	desc = "A .45 Colt expansive bullet casing."
	materials = list(MAT_METAL = 1500, MAT_SILVER = 100)
	projectile_type = /obj/projectile/bullet/c45colt/hp
	bullet_type = BULLET_TYPE_EXPANSIVE

/obj/item/ammo_casing/c45colt/ap
	desc = "A .45 Colt armor piercing bullet casing."
	materials = list(MAT_METAL = 1150)
	projectile_type = /obj/projectile/bullet/c45colt/ap
	bullet_type = BULLET_TYPE_ARMOR_PIERCING

// MARK: .45 N&R
/obj/item/ammo_casing/c45nr
	desc = "A 45 N&R bullet casing."
	materials = list(MAT_METAL = 500)
	caliber = CALIBER_45NR
	projectile_type = /obj/projectile/bullet/weakbullet4/c45nr
	bullet_type = BULLET_TYPE_PLAIN
