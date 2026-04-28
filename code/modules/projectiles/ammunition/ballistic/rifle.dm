// MARK: 7.62x54mm
/obj/item/ammo_casing/a762x54
	ammo_marking = "7,62x54 мм"
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
	ammo_marking = "7,62x51 мм"
	icon_state = "762-casing"
	caliber = CALIBER_7_DOT_62X51MM
	projectile_type = /obj/projectile/bullet/saw
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_STRONG
	muzzle_flash_range = MUZZLE_FLASH_RANGE_STRONG
	bullet_type = BULLET_TYPE_PLAIN

// TODO: replace it with /obj/item/ammo_casing/a762x51
/obj/item/ammo_casing/a762x51/weak
	projectile_type = /obj/projectile/bullet/saw/weak

/obj/item/ammo_casing/a762x51/bleeding
	ammo_marking = "7,62x51 мм \"Кровосток\""
	extra_info = "Специализированный боеприпас, который при попадании выпускает крошечные осколки для вызова внутреннего кровотечения."
	projectile_type = /obj/projectile/bullet/saw/bleeding

/obj/item/ammo_casing/a762x51/hollow
	ammo_marking = "7,62x51 мм ПЭ"
	extra_info = "Экспансивная пуля обладает повышенным травмирующим действием в ущерб проникающей способности."
	projectile_type = /obj/projectile/bullet/saw/hollow
	bullet_type = BULLET_TYPE_EXPANSIVE

/obj/item/ammo_casing/a762x51/ap
	ammo_marking = "7,62x51 мм ББ"
	extra_info = "Бронебойная пуля обладает повышенной проникающей способностью в ущерб останавливающего действия."
	projectile_type = /obj/projectile/bullet/saw/ap
	bullet_type = BULLET_TYPE_ARMOR_PIERCING

/obj/item/ammo_casing/a762x51/incen
	ammo_marking = "7,62x51 мм ПЗ"
	extra_info = "Зажигательная пуля воспламеняется при попадании."
	projectile_type = /obj/projectile/bullet/saw/incen
	muzzle_flash_color = LIGHT_COLOR_FIRE
	bullet_type = BULLET_TYPE_FIRE

// MARK: .50
// MAKE IT /point50 TYPE PLEASE
/obj/item/ammo_casing/point50
	ammo_marking = ".50"
	caliber = CALIBER_DOT_50
	projectile_type = /obj/projectile/bullet/sniper
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_STRONG
	muzzle_flash_range = MUZZLE_FLASH_RANGE_STRONG
	icon_state = ".50"
	bullet_type = BULLET_TYPE_PLAIN

/obj/item/ammo_casing/soporific
	ammo_marking = ".50 \"Сон\""
	extra_info = "Специализированный боеприпас, заполненный седативным веществом. При попадании усыпляет цель, не нанося повреждений."
	caliber = CALIBER_DOT_50
	projectile_type = /obj/projectile/bullet/sniper/soporific
	icon_state = ".50sop"
	harmful = FALSE

/obj/item/ammo_casing/explosive
	ammo_marking = ".50 \"Взрывной\""
	extra_info = "Специализированный боеприпас, начинённый взрывчатым веществом. При попадании вызывает взрыв."
	caliber = CALIBER_DOT_50
	projectile_type = /obj/projectile/bullet/sniper/explosive
	icon_state = ".50exp"

/obj/item/ammo_casing/haemorrhage
	ammo_marking = ".50 \"Кровосток\""
	extra_info = "Специализированный боеприпас, который при попадании выпускает крошечные осколки для вызова внутреннего кровотечения."
	caliber = CALIBER_DOT_50
	projectile_type = /obj/projectile/bullet/sniper/haemorrhage
	icon_state = ".50exp"

/obj/item/ammo_casing/penetrator
	ammo_marking = ".50 AP"
	extra_info = "Бронебойная пуля обладает повышенной проникающей способностью в ущерб останавливающего действия."
	caliber = CALIBER_DOT_50
	projectile_type = /obj/projectile/bullet/sniper/penetrator
	icon_state = ".50pen"
	bullet_type = BULLET_TYPE_ARMOR_PIERCING

// MARK: .50L
/obj/item/ammo_casing/compact
	ammo_marking = ".50 L"
	extra_info = "Облегчённая версия патрона .50."
	caliber = CALIBER_DOT_50L
	projectile_type = /obj/projectile/bullet/sniper/compact
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL
	icon_state = ".50"
	bullet_type = BULLET_TYPE_PLAIN

/obj/item/ammo_casing/compact/penetrator
	ammo_marking = ".50 L AP"
	extra_info = "Облегчённая версия патрона .50 AP. Бронебойная пуля обладает повышенной проникающей способностью в ущерб останавливающего действия."
	projectile_type = /obj/projectile/bullet/sniper/penetrator
	icon_state = ".50pen"

/obj/item/ammo_casing/compact/soporific
	ammo_marking = ".50 L \"Сон\""
	extra_info = "Облегчённая версия патрона .50 \"Сон\". Специализированный боеприпас, заполненный седативным веществом. При попадании усыпляет цель, не нанося повреждений."
	projectile_type = /obj/projectile/bullet/sniper/soporific
	icon_state = ".50sop"
	harmful = FALSE

// MARK: .338
/obj/item/ammo_casing/a338
	ammo_marking = ".338"
	caliber = CALIBER_DOT_338
	projectile_type = /obj/projectile/bullet/sniper/a338
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_STRONG
	muzzle_flash_range = MUZZLE_FLASH_RANGE_STRONG
	icon_state = ".50"
	bullet_type = BULLET_TYPE_PLAIN

/obj/item/ammo_casing/a338_soporific
	ammo_marking = ".338 \"Сон\""
	extra_info = "Специализированный боеприпас, заполненный седативным веществом. При попадании усыпляет цель, не нанося повреждений."
	caliber = CALIBER_DOT_338
	projectile_type = /obj/projectile/bullet/sniper/soporific/a338
	icon_state = ".50sop"
	harmful = FALSE

/obj/item/ammo_casing/a338_explosive
	ammo_marking = ".338 \"Взрывной\""
	extra_info = "Специализированный боеприпас, начинённый взрывчатым веществом. При попадании вызывает взрыв."
	caliber = CALIBER_DOT_338
	projectile_type = /obj/projectile/bullet/sniper/explosive/a338
	icon_state = ".50exp"

/obj/item/ammo_casing/a338_haemorrhage
	ammo_marking = ".338 \"Кровосток\""
	extra_info = "Специализированный боеприпас, который при попадании выпускает крошечные осколки для вызова внутреннего кровотечения."
	caliber = CALIBER_DOT_338
	projectile_type = /obj/projectile/bullet/sniper/haemorrhage/a338
	icon_state = ".50exp"

/obj/item/ammo_casing/a338_penetrator
	ammo_marking = ".338 AP"
	extra_info = "Бронебойная пуля обладает повышенной проникающей способностью в ущерб останавливающего действия."
	caliber = CALIBER_DOT_338
	projectile_type = /obj/projectile/bullet/sniper/penetrator/a338
	icon_state = ".50pen"
	bullet_type = BULLET_TYPE_ARMOR_PIERCING
