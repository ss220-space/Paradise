// MARK: 7.62x54mm
/obj/item/ammo_casing/a762x54
	desc = "A 7.62x54mm bullet casing."
	icon_state = "762-casing"
	materials = list(MAT_METAL = 4000)
	caliber = CALIBER_7_DOT_62X54MM
	projectile_type = /obj/projectile/bullet
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_STRONG
	muzzle_flash_range = MUZZLE_FLASH_RANGE_STRONG
	bullet_type = BULLET_TYPE_PLAIN

/obj/item/ammo_casing/a762x54/enchanted
	materials = list(MAT_METAL = 1000)
	projectile_type = /obj/projectile/bullet/weakbullet3

// MARK: 7.62x51mm
/obj/item/ammo_casing/a762x51
	desc = "A 7.62x51mm bullet casing."
	icon_state = "762-casing"
	caliber = CALIBER_7_DOT_62X51MM
	projectile_type = /obj/projectile/bullet/saw
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_STRONG
	muzzle_flash_range = MUZZLE_FLASH_RANGE_STRONG
	bullet_type = BULLET_TYPE_PLAIN

/obj/item/ammo_casing/a762x51/weak
	projectile_type = /obj/projectile/bullet/saw/weak

/obj/item/ammo_casing/a762x51/bleeding
	desc = "A 7.62x51mm bullet casing with specialized inner-casing, that when it makes contact with a target, release tiny shrapnel to induce internal bleeding."
	projectile_type = /obj/projectile/bullet/saw/bleeding

/obj/item/ammo_casing/a762x51/hollow
	desc = "A 7.62x51mm bullet casing designed to cause more damage to unarmored targets."
	projectile_type = /obj/projectile/bullet/saw/hollow
	bullet_type = BULLET_TYPE_EXPANSIVE

/obj/item/ammo_casing/a762x51/ap
	desc = "A 7.62x51mm bullet casing designed with a hardened-tipped core to help penetrate armored targets."
	projectile_type = /obj/projectile/bullet/saw/ap
	bullet_type = BULLET_TYPE_ARMOR_PIERCING

/obj/item/ammo_casing/a762x51/incen
	desc = "A 7.62x51mm bullet casing designed with a chemical-filled capsule on the tip that when bursted, reacts with the atmosphere to produce a fireball, engulfing the target in flames. "
	projectile_type = /obj/projectile/bullet/saw/incen
	muzzle_flash_color = LIGHT_COLOR_FIRE
	bullet_type = BULLET_TYPE_FIRE

// MARK: .50
// MAKE IT /point50 TYPE PLEASE
/obj/item/ammo_casing/point50
	desc = "A .50 bullet casing."
	caliber = CALIBER_DOT_50
	projectile_type = /obj/projectile/bullet/sniper
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_STRONG
	muzzle_flash_range = MUZZLE_FLASH_RANGE_STRONG
	icon_state = ".50"
	bullet_type = BULLET_TYPE_PLAIN

/obj/item/ammo_casing/soporific
	desc = "A .50 bullet casing, specialised in sending the target to sleep, instead of hell."
	caliber = CALIBER_DOT_50
	projectile_type = /obj/projectile/bullet/sniper/soporific
	icon_state = ".50sop"
	harmful = FALSE

/obj/item/ammo_casing/explosive
	desc = "A .50 bullet casing, specialised in destruction"
	caliber = CALIBER_DOT_50
	projectile_type = /obj/projectile/bullet/sniper/explosive
	icon_state = ".50exp"

/obj/item/ammo_casing/haemorrhage
	desc = "A .50 bullet casing, specialised in causing massive bloodloss"
	caliber = CALIBER_DOT_50
	projectile_type = /obj/projectile/bullet/sniper/haemorrhage
	icon_state = ".50exp"

/obj/item/ammo_casing/penetrator
	desc = "A .50 caliber penetrator round casing."
	caliber = CALIBER_DOT_50
	projectile_type = /obj/projectile/bullet/sniper/penetrator
	icon_state = ".50pen"
	bullet_type = BULLET_TYPE_ARMOR_PIERCING

// MARK: .50L
/obj/item/ammo_casing/compact
	desc = "A .50 caliber compact round casing."
	caliber = CALIBER_DOT_50L
	projectile_type = /obj/projectile/bullet/sniper/compact
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL
	icon_state = ".50"
	bullet_type = BULLET_TYPE_PLAIN

/obj/item/ammo_casing/compact/penetrator
	desc = "A .50 caliber penetrator round casing."
	projectile_type = /obj/projectile/bullet/sniper/penetrator
	icon_state = ".50pen"

/obj/item/ammo_casing/compact/soporific
	desc = "A .50 bullet casing, specialised in sending the target to sleep, instead of hell."
	projectile_type = /obj/projectile/bullet/sniper/soporific
	icon_state = ".50sop"
	harmful = FALSE

// MARK: .338
// MAKE IT /a338 TYPE PLEASE
/obj/item/ammo_casing/a338
	desc = "Гильзя калибра .338."
	caliber = CALIBER_DOT_338
	projectile_type = /obj/projectile/bullet/sniper/a338
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_STRONG
	muzzle_flash_range = MUZZLE_FLASH_RANGE_STRONG
	icon_state = ".50"
	bullet_type = BULLET_TYPE_PLAIN

/obj/item/ammo_casing/a338_soporific
	caliber = CALIBER_DOT_338
	projectile_type = /obj/projectile/bullet/sniper/soporific/a338
	icon_state = ".50sop"
	harmful = FALSE

/obj/item/ammo_casing/a338_explosive
	caliber = CALIBER_DOT_338
	projectile_type = /obj/projectile/bullet/sniper/explosive/a338
	icon_state = ".50exp"

/obj/item/ammo_casing/a338_haemorrhage
	caliber = CALIBER_DOT_338
	projectile_type = /obj/projectile/bullet/sniper/haemorrhage/a338
	icon_state = ".50exp"

/obj/item/ammo_casing/a338_penetrator
	caliber = CALIBER_DOT_338
	projectile_type = /obj/projectile/bullet/sniper/penetrator/a338
	icon_state = ".50pen"
	bullet_type = BULLET_TYPE_ARMOR_PIERCING
