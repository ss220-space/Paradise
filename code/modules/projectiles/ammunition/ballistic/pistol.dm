// MARK: 9mm
/obj/item/ammo_casing/c9mm
	ammo_marking = "9x19 мм"
	caliber = CALIBER_9MM
	materials = list(MAT_METAL = 1000)
	projectile_type = /obj/projectile/bullet/weakbullet3
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL
	bullet_type = BULLET_TYPE_PLAIN

/obj/item/ammo_casing/c9mm/ap
	ammo_marking = "9x19 мм ББ"
	extra_info = "Бронебойная пуля обладает повышенной проникающей способностью в ущерб останавливающего действия."
	materials = list(MAT_METAL = 1500, MAT_SILVER = 150)
	projectile_type = /obj/projectile/bullet/armourpiercing
	bullet_type = BULLET_TYPE_ARMOR_PIERCING

/obj/item/ammo_casing/c9mm/tox
	ammo_marking = "9x19 мм \"Токсин\""
	extra_info = "Токсинная пуля содержит ядовитое вещество, отравляющее цель при попадании."
	materials = list(MAT_METAL = 1500, MAT_SILVER = 150, MAT_URANIUM = 200)
	projectile_type = /obj/projectile/bullet/toxinbullet

/obj/item/ammo_casing/c9mm/inc
	ammo_marking = "9x19 мм ПЗ"
	extra_info = "Зажигательная пуля воспламеняется при попадании."
	materials = list(MAT_METAL = 1500, MAT_SILVER = 150, MAT_PLASMA = 200)
	projectile_type = /obj/projectile/bullet/incendiary/firebullet
	muzzle_flash_color = LIGHT_COLOR_FIRE
	bullet_type = BULLET_TYPE_FIRE

/obj/item/ammo_casing/rubber9mm
	ammo_marking = "9x19 мм ПР"
	extra_info = "Резиновая пуля обладает высоким останавливающим действием, не нанося смертельных ранений при попадании."
	icon_state = "r-casing"
	materials = list(MAT_METAL = 650)
	caliber = CALIBER_9MM
	projectile_type = /obj/projectile/bullet/weakbullet4
	bullet_type = BULLET_TYPE_RUBBER

// MARK: .40 N&R
/obj/item/ammo_casing/fortynr
	ammo_marking = ".40 S&W"
	materials = list(MAT_METAL = 1100)
	caliber = CALIBER_40NR
	projectile_type = /obj/projectile/bullet/weakbullet3/fortynr
	bullet_type = BULLET_TYPE_PLAIN

// MARK: 7.62x25mm
/obj/item/ammo_casing/ftt762
	ammo_marking = "7,62x25 мм"
	icon_state = "r-casing"
	materials = list(MAT_METAL = 1000)
	caliber = CALIBER_7_DOT_62X25MM
	projectile_type = /obj/projectile/bullet/ftt762
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_STRONG
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL
	bullet_type = BULLET_TYPE_PLAIN

// MARK: .50AE
/obj/item/ammo_casing/a50
	ammo_marking = ".50 AE"
	materials = list(MAT_METAL = 4000)
	caliber = CALIBER_DOT_50AE
	projectile_type = /obj/projectile/bullet/desert_eagle
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_STRONG
	bullet_type = BULLET_TYPE_PLAIN

// MARK: 10mm
/obj/item/ammo_casing/c10mm
	ammo_marking = "10x25 мм"
	materials = list(MAT_METAL = 1500)
	caliber = CALIBER_10MM
	projectile_type = /obj/projectile/bullet/midbullet3
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL
	bullet_type = BULLET_TYPE_PLAIN

/obj/item/ammo_casing/c10mm/ap
	ammo_marking = "10x25 мм ББ"
	extra_info = "Бронебойная пуля обладает повышенной проникающей способностью в ущерб останавливающего действия."
	materials = list(MAT_METAL = 2000, MAT_SILVER = 200)
	projectile_type = /obj/projectile/bullet/midbullet3/ap
	bullet_type = BULLET_TYPE_ARMOR_PIERCING

/obj/item/ammo_casing/c10mm/fire
	ammo_marking = "10x25 мм ПЗ"
	extra_info = "Зажигательная пуля воспламеняется при попадании."
	materials = list(MAT_METAL = 2000, MAT_SILVER = 200, MAT_PLASMA = 300)
	projectile_type = /obj/projectile/bullet/midbullet3/fire
	muzzle_flash_color = LIGHT_COLOR_FIRE
	bullet_type = BULLET_TYPE_FIRE

/obj/item/ammo_casing/c10mm/hp
	ammo_marking = "10x25 мм ПЭ"
	extra_info = "Экспансивная пуля обладает повышенным травмирующим действием в ущерб проникающей способности."
	materials = list(MAT_METAL = 2000, MAT_SILVER = 200)
	projectile_type = /obj/projectile/bullet/midbullet3/hp
	bullet_type = BULLET_TYPE_EXPANSIVE

// MARK: .45
/obj/item/ammo_casing/c45
	ammo_marking = ".45"
	materials = list(MAT_METAL = 1500)
	caliber = CALIBER_DOT_45
	projectile_type = /obj/projectile/bullet/midbullet
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL
	bullet_type = BULLET_TYPE_PLAIN

/obj/item/ammo_casing/c45/nostamina
	projectile_type = /obj/projectile/bullet/midbullet3

/obj/item/ammo_casing/rubber45
	ammo_marking = ".45 R"
	extra_info = "Резиновая пуля обладает высоким останавливающим действием, не нанося смертельных ранений при попадании."
	icon_state = "r-casing"
	materials = list(MAT_METAL = 650)
	caliber = CALIBER_DOT_45
	projectile_type = /obj/projectile/bullet/midbullet_r
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL
	bullet_type = BULLET_TYPE_RUBBER

// MARK: .45 Colt
/obj/item/ammo_casing/c45colt
	ammo_marking = ".45 Colt"
	materials = list(MAT_METAL = 1000)
	caliber = CALIBER_DOT_45_COLT
	projectile_type = /obj/projectile/bullet/c45colt
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL
	bullet_type = BULLET_TYPE_PLAIN

/obj/item/ammo_casing/c45colt/rubber
	ammo_marking = ".45 Colt R"
	extra_info = "Резиновая пуля обладает высоким останавливающим действием, не нанося смертельных ранений при попадании."
	icon_state = "r-casing"
	materials = list(MAT_METAL = 650)
	projectile_type = /obj/projectile/bullet/rubber45colt
	bullet_type = BULLET_TYPE_RUBBER

/obj/item/ammo_casing/c45colt/hp
	ammo_marking = ".45 Colt HP"
	extra_info = "Экспансивная пуля обладает повышенным травмирующим действием в ущерб проникающей способности."
	materials = list(MAT_METAL = 1500, MAT_SILVER = 100)
	projectile_type = /obj/projectile/bullet/c45colt/hp
	bullet_type = BULLET_TYPE_EXPANSIVE

/obj/item/ammo_casing/c45colt/ap
	ammo_marking = ".45 Colt AP"
	extra_info = "Бронебойная пуля обладает повышенной проникающей способностью в ущерб останавливающего действия."
	materials = list(MAT_METAL = 1150)
	projectile_type = /obj/projectile/bullet/c45colt/ap
	bullet_type = BULLET_TYPE_ARMOR_PIERCING

// MARK: .45 N&R
/obj/item/ammo_casing/c45nr
	ammo_marking = ".45 N&R"
	materials = list(MAT_METAL = 500)
	caliber = CALIBER_45NR
	projectile_type = /obj/projectile/bullet/weakbullet4/c45nr
	bullet_type = BULLET_TYPE_PLAIN

// MARK: 12.7x55
/obj/item/ammo_casing/c12_dot_7X55
	ammo_marking = "12,7x55 мм"
	icon_state = "casing12.7"
	materials = list(MAT_METAL = 1500, MAT_SILVER = 100)
	caliber = CALIBER_12_DOT_7X55MM
	projectile_type = /obj/projectile/bullet/c12_dot_7X55
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_STRONG
	muzzle_flash_range = MUZZLE_FLASH_RANGE_STRONG
	bullet_type = BULLET_TYPE_PLAIN
