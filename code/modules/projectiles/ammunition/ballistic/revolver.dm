// MARK: .357
/obj/item/ammo_casing/a357
	ammo_marking = ".357 Magnum"
	materials = list(MAT_METAL = 3750)
	caliber = CALIBER_DOT_357
	projectile_type = /obj/projectile/bullet
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_STRONG
	bullet_type = BULLET_TYPE_PLAIN

// MARK: .38
/obj/item/ammo_casing/c38
	ammo_marking = ".38"
	icon_state = "r-casing"
	materials = list(MAT_METAL = 650)
	caliber = CALIBER_DOT_38
	projectile_type = /obj/projectile/bullet/weakbullet2
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL
	bullet_type = BULLET_TYPE_RUBBER

/obj/item/ammo_casing/c38/hp
	ammo_marking = ".38 HP"
	extra_info = "Экспансивная пуля обладает повышенным травмирующим действием в ущерб проникающей способности."
	icon_state = "rhp-casing"
	materials = list(MAT_METAL = 5000)
	projectile_type = /obj/projectile/bullet/hp38
	bullet_type = BULLET_TYPE_EXPANSIVE

/obj/item/ammo_casing/c38/invisible
	projectile_type = /obj/projectile/bullet/weakbullet2/invisible
	muzzle_flash_effect = null // invisible eh

/obj/item/ammo_casing/c38/invisible/fake
	projectile_type = /obj/projectile/bullet/weakbullet2/invisible/fake

// MARK: .36
/obj/item/ammo_casing/c38/c36
	ammo_marking = ".36"
	caliber = CALIBER_DOT_36
	projectile_type = /obj/projectile/bullet/midbullet2
	bullet_type = BULLET_TYPE_PLAIN

// MARK: 7.62x38mm
/obj/item/ammo_casing/n762
	ammo_marking = "7.62x38 мм"
	materials = list(MAT_METAL = 4000)
	caliber = CALIBER_7_DOT_62X38MM
	projectile_type = /obj/projectile/bullet
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_STRONG
	bullet_type = BULLET_TYPE_PLAIN

// MARK: .257 Improvised
/obj/item/ammo_casing/revolver/improvised
	desc = "Полностью металлическая гильза, из которой течёт масло. Это явно ненадёжный патрон."
	ammo_marking = ".257"
	icon_state = "rev-improv-casing"
	materials = list(MAT_METAL = 100)
	caliber = CALIBER_DOT_257
	projectile_type = /obj/projectile/bullet/weakbullet3/c257
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL
	bullet_type = BULLET_TYPE_PLAIN

/obj/item/ammo_casing/revolver/improvised/update_desc(updates = ALL)
	. = ..()
	desc = initial(desc)

/obj/item/ammo_casing/revolver/improvised/phosphorus
	desc = "Полностью металлическая гильза, из которой течёт масло и фосфор. Это явно ненадёжный патрон."
	ammo_marking = ".257 \"Фосфор\""
	icon_state = "rev-phosphor-casing"
	projectile_type = /obj/projectile/bullet/weakbullet3/c257/phosphorus
