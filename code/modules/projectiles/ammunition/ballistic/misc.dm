// MARK: Speargun
/obj/item/ammo_casing/caseless/magspear
	name = "magnetic spear"
	desc = "A reusable spear that is typically loaded into kinetic spearguns."
	projectile_type = /obj/projectile/bullet/reusable/magspear
	caliber = CALIBER_SPEAR
	icon_state = "magspear"
	throwforce = 15 //still deadly when thrown
	throw_speed = 3
	muzzle_flash_color = null

// MARK: .75 - Gyro pistol
/obj/item/ammo_casing/caseless/a75
	desc = "A .75 bullet casing."
	caliber = CALIBER_DOT_75
	materials = list(MAT_METAL = 8000)
	projectile_type = /obj/projectile/bullet/gyro
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_STRONG
	muzzle_flash_range = MUZZLE_FLASH_RANGE_STRONG

// MARK: Laser
/obj/item/ammo_casing/laser
	icon_state = "lasercasing"
	materials = list(MAT_METAL = 1000)
	caliber = CALIBER_LASER
	projectile_type = /obj/projectile/beam/laser
	muzzle_flash_effect = /obj/effect/temp_visual/target_angled/muzzle_flash/energy
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL
	muzzle_flash_color = COLOR_SOFT_RED
	bullet_type = BULLET_TYPE_LASER

// MARK: Glockroack
/obj/item/ammo_casing/caseless/glockroach
	name = "0.9mm bullet casing"
	desc = "Это... 0.9mm гильза? Чего?"
	projectile_type = /obj/projectile/glockroachbullet

/obj/item/ammo_casing/caseless/glockroach/get_ru_names()
	return list(
		NOMINATIVE = "гильза 0,9 мм",
		GENITIVE = "гильзы 0,9 мм",
		DATIVE = "гильзе 0,9 мм",
		ACCUSATIVE = "гильзу 0,9 мм",
		INSTRUMENTAL = "гильзой 0,9 мм",
		PREPOSITIONAL = "гильзе 0,9 мм",
	)
