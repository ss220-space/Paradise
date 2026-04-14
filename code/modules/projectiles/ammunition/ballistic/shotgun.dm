// MARK: Slug
/obj/item/ammo_casing/shotgun
	name = "shotgun slug"
	desc = "A 12 gauge lead slug."
	icon_state = "slugshell"
	materials = list(MAT_METAL = 4000)
	casing_drop_sound = 'sound/weapons/gun_interactions/shotgun_fall.ogg'
	caliber = CALIBER_12X70
	projectile_type = /obj/projectile/bullet/slug
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_STRONG
	muzzle_flash_range = MUZZLE_FLASH_RANGE_STRONG

// MARK: Buckshot
/obj/item/ammo_casing/shotgun/buckshot
	name = "buckshot shell"
	desc = "A 12 gauge buckshot shell."
	icon_state = "buckshotshell"
	projectile_type = /obj/projectile/bullet/pellet
	pellets = 6
	variance = 17

/obj/item/ammo_casing/shotgun/buckshot/magnum
	name = "magnum buckshot shell"
	desc = "A 12 gauge magnum buckshot shell."
	projectile_type = /obj/projectile/bullet/pellet/magnum

// MARK: Assasination slug
/obj/item/ammo_casing/shotgun/assassination
	name = "assassination shell"
	desc = "Специальная гильза для шрапнели, обработанная глушащим токсином."
	materials = list(MAT_METAL = 1500, MAT_GLASS = 200)
	projectile_type = /obj/projectile/bullet/pellet/assassination
	muzzle_flash_effect = null
	icon_state = "buckshotshell"
	pellets = 6
	variance = 15

/obj/item/ammo_casing/shotgun/assassination/get_ru_names()
	return list(
		NOMINATIVE = "патрон для убийства",
		GENITIVE = "патрона для убийства",
		DATIVE = "патрону для убийства",
		ACCUSATIVE = "патрон для убийства",
		INSTRUMENTAL = "патроном для убийства",
		PREPOSITIONAL = "патроне для убийства",
	)

// MARK: Rubbershot
/obj/item/ammo_casing/shotgun/rubbershot
	name = "rubbershot shell"
	desc = "A shotgun casing filled with densely-packed rubber balls, used to incapacitate crowds from a distance."
	icon_state = "rubbershotshell"
	materials = list(MAT_METAL = 1000)
	projectile_type = /obj/projectile/bullet/pellet/rubber
	pellets = 6
	variance = 17

// MARK: Chemical dart
/obj/item/ammo_casing/shotgun/dart
	name = "shotgun dart"
	desc = "A dart for use in shotguns. Can be injected with up to 30 units of any chemical."
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
	name = "beanbag slug"
	desc = "A weak beanbag slug for riot control."
	icon_state = "beanbagshell"
	materials = list(MAT_METAL = 1000)
	projectile_type = /obj/projectile/bullet/weakbullet
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL

/obj/item/ammo_casing/shotgun/beanbag/fake
	projectile_type = /obj/projectile/bullet/weakbullet/booze

// MARK: Taser slug
/obj/item/ammo_casing/shotgun/stunslug
	name = "taser slug"
	desc = "A stunning taser slug."
	icon_state = "stunslugshell"
	materials = list(MAT_METAL = 250)
	projectile_type = /obj/projectile/bullet/stunshot
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL
	muzzle_flash_color = "#FFFF00"

// MARK: Meteorshot
/obj/item/ammo_casing/shotgun/meteorshot
	name = "meteorshot shell"
	desc = "A shotgun shell rigged with CMC technology, which launches a massive slug when fired."
	icon_state = "meteorshotshell"
	projectile_type = /obj/projectile/bullet/meteorshot

// MARK: Breaching
/obj/item/ammo_casing/shotgun/breaching
	name = "breaching shell"
	desc = "An economic version of the meteorshot, utilizing similar technologies. Great for busting down doors."
	icon_state = "meteorshotshell"
	projectile_type = /obj/projectile/bullet/meteorshot/weak

// MARK: Pulse slug
/obj/item/ammo_casing/shotgun/pulseslug
	name = "pulse slug"
	desc = "A delicate device which can be loaded into a shotgun. The primer acts as a button which triggers the gain medium and fires a powerful \
	energy blast. While the heat and power drain limit it to one use, it can still allow an operator to engage targets that ballistic ammunition \
	would have difficulty with."
	icon_state = "pulseslugshell"
	projectile_type = /obj/projectile/beam/pulse/shot
	muzzle_flash_color = LIGHT_COLOR_DARK_BLUE

// MARK: Incendiary slug
/obj/item/ammo_casing/shotgun/incendiary
	name = "incendiary slug"
	desc = "An incendiary-coated shotgun slug."
	icon_state = "incendiaryshell"
	projectile_type = /obj/projectile/bullet/incendiary/shell
	muzzle_flash_color = LIGHT_COLOR_FIRE

/obj/item/ammo_casing/shotgun/incendiary/dragonsbreath
	name = "dragonsbreath shell"
	desc = "A shotgun shell which fires a spread of incendiary pellets."
	icon_state = "dragonsbreathshell"
	projectile_type = /obj/projectile/bullet/incendiary/shell/dragonsbreath
	pellets = 4
	variance = 25

/obj/item/ammo_casing/shotgun/incendiary/dragonsbreath/napalm
	projectile_type = /obj/projectile/bullet/incendiary/shell/dragonsbreath/napalm
	pellets = 6
	variance = 20

// MARK: Frag-12
/obj/item/ammo_casing/shotgun/frag12
	name = "FRAG-12 slug"
	desc = "A high explosive breaching round for a 12 gauge shotgun."
	icon_state = "frag12shell"
	projectile_type = /obj/projectile/bullet/frag12

// MARK: Ion
/obj/item/ammo_casing/shotgun/ion
	name = "ion shell"
	desc = "An advanced shotgun shell which uses a subspace ansible crystal to produce an effect similar to a standard ion rifle. \
	The unique properties of the crystal splot the pulse into a spread of individually weaker bolts."
	icon_state = "ionshell"
	projectile_type = /obj/projectile/ion/weak
	pellets = 4
	variance = 35
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL
	muzzle_flash_color = LIGHT_COLOR_BLUE

// MARK: Laser slug
/obj/item/ammo_casing/shotgun/laserslug
	name = "laser slug"
	desc = "An advanced shotgun shell that uses a micro laser to replicate the effects of a laser weapon in a ballistic package."
	icon_state = "laserslugshell"
	projectile_type = /obj/projectile/beam/laser/slug
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL
	muzzle_flash_color = COLOR_SOFT_RED

// MARK: Laser buckshot
/obj/item/ammo_casing/shotgun/lasershot
	name = "laser shot"
	desc = "An advanced shotgun shell that uses a micro lasers to replicate the effects of a buckshot in laser appearance."
	icon_state = "lasershotshell"
	projectile_type = /obj/projectile/beam/laser/shot
	pellets = 6
	variance = 17
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL
	muzzle_flash_color = COLOR_SOFT_RED

// MARK: Bioterror
/obj/item/ammo_casing/shotgun/bioterror
	name = "bioterror shell"
	desc = "A shotgun shell filled with deadly toxins."
	icon_state = "bioterrorshell"
	projectile_type = /obj/projectile/bullet/pellet/bioterror
	pellets = 4
	variance = 17

// MARK: Tranquilizer
/obj/item/ammo_casing/shotgun/tranquilizer
	name = "tranquilizer dart"
	desc = "A tranquilizer round used to subdue individuals utilizing stimulants."
	icon_state = "tranquilizershell"
	materials = list(MAT_METAL = 500, MAT_GLASS = 200)
	projectile_type = /obj/projectile/bullet/dart/syringe/tranquilizer
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL

// MARK: Flechette
/obj/item/ammo_casing/shotgun/flechette
	name = "flechette"
	desc = "A shotgun casing filled with tiny steel darts, used to penetrate armor. Beehive incoming!"
	icon_state = "flechetteshell"
	projectile_type = /obj/projectile/bullet/pellet/flechette
	pellets = 4
	variance = 13

// MARK: Improvised buckshot
/obj/item/ammo_casing/shotgun/improvised
	name = "improvised shell"
	desc = "An extremely weak shotgun shell with multiple small pellets made out of metal shards."
	icon_state = "improvisedshell"
	materials = list(MAT_METAL = 250)
	projectile_type = /obj/projectile/bullet/pellet/weak
	pellets = 10
	variance = 20
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL

/obj/item/ammo_casing/shotgun/improvised/overload
	name = "overloaded improvised shell"
	desc = "An extremely weak shotgun shell with multiple small pellets made out of metal shards. This one has been packed with even more \
	propellant. It's like playing russian roulette, with a shotgun."
	projectile_type = /obj/projectile/bullet/pellet/overload
	pellets = 4
	variance = 40
	muzzle_flash_range = MUZZLE_FLASH_RANGE_STRONG

// MARK: Empty tech shell
/obj/item/ammo_casing/shotgun/techshell
	name = "unloaded technological shell"
	desc = "A high-tech shotgun shell which can be loaded with materials to produce unique effects."
	icon_state = "techshell"
	materials = list(MAT_METAL = 1000, MAT_GLASS = 200)
	projectile_type = null
