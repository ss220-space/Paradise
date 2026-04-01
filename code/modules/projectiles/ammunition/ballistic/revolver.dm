// MARK: .357
/obj/item/ammo_casing/a357
	desc = "A .357 bullet casing."
	materials = list(MAT_METAL = 3750)
	caliber = CALIBER_DOT_357
	projectile_type = /obj/projectile/bullet
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_STRONG
	bullet_type = BULLET_TYPE_PLAIN

// MARK: .38
/obj/item/ammo_casing/c38
	desc = "A .38 bullet casing."
	icon_state = "r-casing"
	materials = list(MAT_METAL = 650)
	caliber = CALIBER_DOT_38
	projectile_type = /obj/projectile/bullet/weakbullet2
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL
	bullet_type = BULLET_TYPE_RUBBER

/obj/item/ammo_casing/c38/hp
	desc = "A .38 Hollow-Point bullet casing."
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
	desc = "A .36 bullet casing."
	caliber = CALIBER_DOT_36
	projectile_type = /obj/projectile/bullet/midbullet2
	bullet_type = BULLET_TYPE_PLAIN

// MARK: 7.62x38mm
/obj/item/ammo_casing/n762
	desc = "A 7.62x38mm bullet casing."
	materials = list(MAT_METAL = 4000)
	caliber = CALIBER_7_DOT_62X38MM
	projectile_type = /obj/projectile/bullet
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_STRONG
	bullet_type = BULLET_TYPE_PLAIN

// MARK: .257 Improvised
/obj/item/ammo_casing/revolver/improvised
	name = "improvised shell"
	desc = "Full metal shell leaking oil. This is clearly an unreliable bullet."
	icon_state = "rev-improv-casing"
	materials = list(MAT_METAL = 100)
	caliber = CALIBER_DOT_257
	projectile_type = /obj/projectile/bullet/weakbullet3/c257
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL
	bullet_type = BULLET_TYPE_PLAIN

/obj/item/ammo_casing/revolver/improvised/phosphorus
	desc = "Full metal shell leaking oil and phosphorous. This is clearly an unreliable bullet."
	icon_state = "rev-phosphor-casing"
	projectile_type = /obj/projectile/bullet/weakbullet3/c257/phosphorus
