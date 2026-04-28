// MARK: Slug
/obj/item/ammo_casing/shotgun
	ammo_marking = "12g \"Пуля\""
	extra_info = "Латунная пуля для гладкоствольного ружья."
	icon_state = "slugshell"
	materials = list(MAT_METAL = 4000)
	casing_drop_sound = 'sound/weapons/gun_interactions/shotgun_fall.ogg'
	caliber = CALIBER_12G
	projectile_type = /obj/projectile/bullet/slug
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_STRONG
	muzzle_flash_range = MUZZLE_FLASH_RANGE_STRONG

// MARK: Buckshot
/obj/item/ammo_casing/shotgun/buckshot
	ammo_marking = "12g \"Картечь\""
	extra_info = "При выстреле разлетается на множество поражающих элементов."
	icon_state = "buckshotshell"
	projectile_type = /obj/projectile/bullet/pellet
	pellets = 6
	variance = 17

/obj/item/ammo_casing/shotgun/buckshot/magnum
	ammo_marking = "12g \"Магнум\""
	extra_info = "Усиленная картечь с повышенной мощностью. При выстреле разлетается на множество поражающих элементов."
	projectile_type = /obj/projectile/bullet/pellet/magnum

// MARK: Assasination slug
/obj/item/ammo_casing/shotgun/assassination
	ammo_marking = "12g \"Тишь\""
	extra_info = "Специальная картечь, обработанная глушащим токсином."
	materials = list(MAT_METAL = 1500, MAT_GLASS = 200)
	projectile_type = /obj/projectile/bullet/pellet/assassination
	muzzle_flash_effect = null
	icon_state = "buckshotshell"
	pellets = 6
	variance = 15

// MARK: Rubbershot
/obj/item/ammo_casing/shotgun/rubbershot
	ammo_marking = "12g \"Резиновая картечь\""
	extra_info = "Резиновая картечь. Обладает высоким останавливающим действием, не нанося смертельных ранений при попадании."
	icon_state = "rubbershotshell"
	materials = list(MAT_METAL = 1000)
	projectile_type = /obj/projectile/bullet/pellet/rubber
	pellets = 6
	variance = 17

// MARK: Chemical dart
/obj/item/ammo_casing/shotgun/dart
	ammo_marking = "12g \"Дротик\""
	extra_info = "Дротик для использования в гладкоствольных ружьях. Может содержать до 30 единиц вещества."
	icon_state = "rubbershotshell"
	container_type = OPENCONTAINER
	materials = list(MAT_METAL = 500, MAT_GLASS = 200)
	projectile_type = /obj/projectile/bullet/dart
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL
	can_be_box_inserted = FALSE

/obj/item/ammo_casing/shotgun/dart/Initialize(mapload)
	. = ..()
	create_reagents(30)

// MARK: Beanbag
/obj/item/ammo_casing/shotgun/beanbag
	ammo_marking = "12g \"Погремушка\""
	extra_info = "Резиновая пуля. Обладает высоким останавливающим действием, не нанося смертельных ранений при попадании."
	icon_state = "beanbagshell"
	materials = list(MAT_METAL = 1000)
	projectile_type = /obj/projectile/bullet/weakbullet
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL

/obj/item/ammo_casing/shotgun/beanbag/fake
	projectile_type = /obj/projectile/bullet/weakbullet/booze

// MARK: Taser slug
/obj/item/ammo_casing/shotgun/stunslug
	ammo_marking = "12g \"Тазер\""
	extra_info = "При попадании оглушает цель электрическим током."
	icon_state = "stunslugshell"
	materials = list(MAT_METAL = 250)
	projectile_type = /obj/projectile/bullet/stunshot
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL
	muzzle_flash_color = "#FFFF00"

// MARK: Meteorshot
/obj/item/ammo_casing/shotgun/meteorshot
	ammo_marking = "12g \"Метеорит\""
	extra_info = "При выстреле запускает метеорит благодаря использования блюспейс-технологий."
	icon_state = "meteorshotshell"
	projectile_type = /obj/projectile/bullet/meteorshot

// MARK: Breaching
/obj/item/ammo_casing/shotgun/breaching
	ammo_marking = "12g \"Пробивной\""
	extra_info = "При выстреле запускает метеорит благодаря использования блюспейс-технологий. \
			Специализированная версия с уменьшенным импульсом."
	icon_state = "meteorshotshell"
	projectile_type = /obj/projectile/bullet/meteorshot/weak

// MARK: Pulse slug
/obj/item/ammo_casing/shotgun/pulseslug
	ammo_marking = "12g \"Импульсный\""
	extra_info = "Специализированная пуля при выстреле запускает импульсный заряд."
	icon_state = "pulseslugshell"
	projectile_type = /obj/projectile/beam/pulse/shot
	muzzle_flash_color = LIGHT_COLOR_DARK_BLUE

// MARK: Incendiary slug
/obj/item/ammo_casing/shotgun/incendiary
	ammo_marking = "12g \"Зажигательный\""
	extra_info = "Зажигательная пуля с покрытием."
	icon_state = "incendiaryshell"
	projectile_type = /obj/projectile/bullet/incendiary/shell
	muzzle_flash_color = LIGHT_COLOR_FIRE

/obj/item/ammo_casing/shotgun/incendiary/dragonsbreath
	ammo_marking = "12g \"Дыхание дракона\""
	extra_info = "Наполнен гранулами с пиротехнической смесью, которые воспламеняются при выстреле."
	icon_state = "dragonsbreathshell"
	projectile_type = /obj/projectile/bullet/incendiary/shell/dragonsbreath
	pellets = 4
	variance = 25

/obj/item/ammo_casing/shotgun/incendiary/dragonsbreath/napalm
	ammo_marking = "12g \"Напалм\""
	extra_info = "Наполнен гранулами с напалмом, которые воспламеняются при выстреле."
	projectile_type = /obj/projectile/bullet/incendiary/shell/dragonsbreath/napalm
	pellets = 6
	variance = 20

// MARK: Frag-12
/obj/item/ammo_casing/shotgun/frag12
	ammo_marking = "12g \"FRAG-12\""
	extra_info = "Специализированный боеприпас, начинённый взрывчаткой. При попадании взрывается."
	icon_state = "frag12shell"
	projectile_type = /obj/projectile/bullet/frag12

// MARK: Ion
/obj/item/ammo_casing/shotgun/ion
	ammo_marking = "12g \"Ионный\""
	extra_info = "Специализированный боеприпас, создающий ЭМИ при попадании."
	icon_state = "ionshell"
	projectile_type = /obj/projectile/ion/weak
	pellets = 4
	variance = 35
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL
	muzzle_flash_color = LIGHT_COLOR_BLUE

// MARK: Laser slug
/obj/item/ammo_casing/shotgun/laserslug
	ammo_marking = "12g \"Лазерный\""
	extra_info = "Специализированный боеприпас с микролазером, имитирующий лазерное оружие."
	icon_state = "laserslugshell"
	projectile_type = /obj/projectile/beam/laser/slug
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL
	muzzle_flash_color = COLOR_SOFT_RED

// MARK: Laser buckshot
/obj/item/ammo_casing/shotgun/lasershot
	ammo_marking = "12g \"Лазерная картечь\""
	extra_info = "Специализированный боеприпас с системой микролазеров, имитирующий классическую картечь в лазерном исполнении."
	icon_state = "lasershotshell"
	projectile_type = /obj/projectile/beam/laser/shot
	pellets = 6
	variance = 17
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL
	muzzle_flash_color = COLOR_SOFT_RED

// MARK: Bioterror
/obj/item/ammo_casing/shotgun/bioterror
	ammo_marking = "12g \"Биотеррор\""
	extra_info = "Наполнен гранулами со смертельными токсинами, отравляющими цель при попадании."
	icon_state = "bioterrorshell"
	projectile_type = /obj/projectile/bullet/pellet/bioterror
	pellets = 4
	variance = 17

// MARK: Tranquilizer
/obj/item/ammo_casing/shotgun/tranquilizer
	ammo_marking = "12g \"Транквилизатор\""
	extra_info = "Специализированный боеприпас, представляющий собой дротик с седативным веществом."
	icon_state = "tranquilizershell"
	materials = list(MAT_METAL = 500, MAT_GLASS = 200)
	projectile_type = /obj/projectile/bullet/dart/syringe/tranquilizer
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL

// MARK: Flechette
/obj/item/ammo_casing/shotgun/flechette
	ammo_marking = "12g \"Флешетта\""
	extra_info = "Дробовик, заполненный крошечными стальными дротиками для пробития брони."
	icon_state = "flechetteshell"
	projectile_type = /obj/projectile/bullet/pellet/flechette
	pellets = 4
	variance = 13

// MARK: Improvised buckshot
/obj/item/ammo_casing/shotgun/improvised
	ammo_marking = "12g \"Самодельный\""
	extra_info = "Самодельный боеприпас, начинённый множеством металлических гранул и малым количеством пороха."
	icon_state = "improvisedshell"
	materials = list(MAT_METAL = 250)
	projectile_type = /obj/projectile/bullet/pellet/weak
	pellets = 10
	variance = 20
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL

/obj/item/ammo_casing/shotgun/improvised/overload
	ammo_marking = "12g \"Самодельный+\""
	extra_info = "Самодельный боеприпас, начинённый крупными металлическими гранулами и избыточным количеством пороха. Чрезвычайно нестабильный."
	projectile_type = /obj/projectile/bullet/pellet/overload
	pellets = 4
	variance = 40
	muzzle_flash_range = MUZZLE_FLASH_RANGE_STRONG

// MARK: Empty tech shell
/obj/item/ammo_casing/shotgun/techshell
	name = "unloaded technological shell"
	desc = "Высокотехнологичная гильза калибра 12g. Совместима с широким спектром материалов для создания уникальных эффектов."
	ammo_marking = null
	extra_info = null
	icon_state = "techshell"
	materials = list(MAT_METAL = 1000, MAT_GLASS = 200)
	projectile_type = null
	no_update_names = TRUE
	no_update_desc = TRUE

/obj/item/ammo_casing/shotgun/techshell/get_ru_names()
	return list(
		NOMINATIVE = "пустая технологическая гильза [caliber]",
		GENITIVE = "пустой технологической гильзы [caliber]",
		DATIVE = "пустой технологической гильзе [caliber]",
		ACCUSATIVE = "пустую технологическую гильзу [caliber]",
		INSTRUMENTAL = "пустой технологической гильзой [caliber]",
		PREPOSITIONAL = "пустой технологической гильзе [caliber]"
	)
