// Basically it's both an ammo box and external magazine
// TODO: rename it to "Спидлоадер" or sum
/obj/item/ammo_box/speedloader
	gender = NEUTER
	use_bullet_type_overlay = TRUE
	can_fast_load = FALSE

// MARK: Revolvers
/obj/item/ammo_box/speedloader/a357
	name = "speed loader (.357)"
	desc = "Устройство для быстрой зарядки револьверов патронами .357 калибра."
	materials = list(MAT_METAL = 2000)
	ammo_type = /obj/item/ammo_casing/a357
	caliber = CALIBER_DOT_357
	icon_state = "357-7" // DEFAULT icon, composed of prefix + "-" + max_ammo for multiple_sprites == 1 boxes
	multiple_sprites = 1 // see: /obj/item/ammo_box/update_icon()
	icon_prefix = "357" // icon prefix, used in above formula to generate dynamic icons

/obj/item/ammo_box/speedloader/a357/get_ru_names()
	return list(
		NOMINATIVE = "устройство быстрой зарядки (.357)",
		GENITIVE = "устройства быстрой зарядки (.357)",
		DATIVE = "устройству быстрой зарядки (.357)",
		ACCUSATIVE = "устройство быстрой зарядки (.357)",
		INSTRUMENTAL = "устройством быстрой зарядки (.357)",
		PREPOSITIONAL = "устройстве быстрой зарядки (.357)",
	)

/obj/item/ammo_box/speedloader/improvised
	name = "makeshift speedloader"
	desc = "Самодельное устройство для быстрой зарядки револьверов патронами .257 калибра."
	desc = "Speedloader made from shit and sticks."
	ammo_type = null
	icon_state = "makeshift_speedloader"
	max_ammo = 4
	caliber = CALIBER_DOT_257

/obj/item/ammo_box/speedloader/improvised/get_ru_names()
	return list(
		NOMINATIVE = "самодельное устройство быстрой зарядки (.257)",
		GENITIVE = "самодельного устройства быстрой зарядки (.257)",
		DATIVE = "самодельному устройству быстрой зарядки (.257)",
		ACCUSATIVE = "самодельное устройство быстрой зарядки (.257)",
		INSTRUMENTAL = "самодельным устройством быстрой зарядки (.257)",
		PREPOSITIONAL = "самодельном устройстве быстрой зарядки (.257)",
	)

/obj/item/ammo_box/speedloader/improvised/update_overlays()
	. = ..()

	for(var/i = 1 to length(stored_ammo))
		var/obj/item/ammo_casing/ammo = stored_ammo[i]
		var/icon/new_ammo_icon = icon('icons/obj/weapons/ammo.dmi', ammo.icon_state)
		new_ammo_icon.Shift((i in list(2, 3)) ? 8 / RaiseToPower(2, round(i-2, 2)) : i, ISODD(i) ? 4 : 2)
		. += new_ammo_icon

/obj/item/ammo_box/speedloader/c38
	name = "speed loader (.38)"
	desc = "Устройство для быстрой зарядки револьверов патронами .38 калибра."
	icon_state = "38"
	materials = list(MAT_METAL = 2000)
	ammo_type = /obj/item/ammo_casing/c38
	max_ammo = 6
	caliber = CALIBER_DOT_38
	icon_state = "38-6"
	multiple_sprites = 1
	icon_prefix = "38"

/obj/item/ammo_box/speedloader/c38/get_ru_names()
	return list(
		NOMINATIVE = "устройство быстрой зарядки (.38)",
		GENITIVE = "устройства быстрой зарядки (.38)",
		DATIVE = "устройству быстрой зарядки (.38)",
		ACCUSATIVE = "устройство быстрой зарядки (.38)",
		INSTRUMENTAL = "устройством быстрой зарядки (.38)",
		PREPOSITIONAL = "устройстве быстрой зарядки (.38)",
	)

/obj/item/ammo_box/speedloader/c38/hp
	name = "speed loader (.38 Hollow-Point)"
	desc = "Устройство для быстрой зарядки револьверов экспансивными патронами .38 калибра."
	ammo_type = /obj/item/ammo_casing/c38/hp
	icon_state = "38hp-6"
	icon_prefix = "38hp"

/obj/item/ammo_box/speedloader/c38/hp/get_ru_names()
	return list(
		NOMINATIVE = "устройство быстрой зарядки (экспансивные .38)",
		GENITIVE = "устройства быстрой зарядки (экспансивные .38)",
		DATIVE = "устройству быстрой зарядки (экспансивные .38)",
		ACCUSATIVE = "устройство быстрой зарядки (экспансивные .38)",
		INSTRUMENTAL = "устройством быстрой зарядки (экспансивные .38)",
		PREPOSITIONAL = "устройстве быстрой зарядки (экспансивные .38)",
	)

/obj/item/ammo_box/speedloader/rubber45colt
	name = "speed loader (.45 Colt)"
	desc = "Устройство для быстрой перезарядки револьверов патронами калибра .45 Colt."
	icon_state = "38"
	materials = list(MAT_METAL = 2000)
	ammo_type = /obj/item/ammo_casing/c45colt/rubber
	max_ammo = 6
	caliber = CALIBER_DOT_45_COLT
	icon_state = "speedloader45colt-6"
	multiple_sprites = 1
	icon_prefix = "speedloader45colt"

/obj/item/ammo_box/speedloader/rubber45colt/empty
	start_empty = TRUE

/obj/item/ammo_box/speedloader/rubber45colt/get_ru_names()
	return list(
		NOMINATIVE = "ускоритель заряжания (.45 Colt)",
		GENITIVE = "ускорителя заряжания (.45 Colt)",
		DATIVE = "ускорителю заряжания (.45 Colt)",
		ACCUSATIVE = "ускоритель заряжания (.45 Colt)",
		INSTRUMENTAL = "ускорителем заряжания (.45 Colt)",
		PREPOSITIONAL = "ускорителе заряжания (.45 Colt)",
	)

/obj/item/ammo_box/speedloader/n762
	name = "speed loader (7.62x38)"
	desc = "Устройство для быстрой зарядки револьверов патронами 7,62x38 калибра."
	materials = list(MAT_METAL = 2000)
	ammo_type = /obj/item/ammo_casing/n762
	caliber = CALIBER_7_DOT_62X38MM
	icon_state = "762x38-7"
	icon_prefix = "762x38"

/obj/item/ammo_box/speedloader/n762/get_ru_names()
	return list(
		NOMINATIVE = "устройство быстрой зарядки (7,62x38)",
		GENITIVE = "устройства быстрой зарядки (7,62x38)",
		DATIVE = "устройству быстрой зарядки (7,62x38)",
		ACCUSATIVE = "устройство быстрой зарядки (7,62x38)",
		INSTRUMENTAL = "устройством быстрой зарядки (7,62x38)",
		PREPOSITIONAL = "устройстве быстрой зарядки (7,62x38)",
	)

// MARK: Shotguns
/obj/item/ammo_box/speedloader/shotgun
	name = "shotgun speedloader"
	desc = "Устройство для быстрой зарядки дробовиков. Вмещает 7 патронов калибра 12х70."
	icon_state = "shotgunloader"
	icon_prefix = "shotgunloader"
	origin_tech = "combat=2"
	caliber = CALIBER_12X70
	ammo_type = null
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/ammo_box/speedloader/shotgun/Initialize(mapload)
	. = ..()
	name = "shotgun speedloader"

/obj/item/ammo_box/speedloader/shotgun/get_ru_names()
	return list(
		NOMINATIVE = "устройство быстрой зарядки дробовиков",
		GENITIVE = "устройства быстрой зарядки дробовиков",
		DATIVE = "устройству быстрой зарядки дробовиков",
		ACCUSATIVE = "устройство быстрой зарядки дробовиков",
		INSTRUMENTAL = "устройством быстрой зарядки дробовиков",
		PREPOSITIONAL = "устройстве быстрой зарядки дробовиков",
	)

/obj/item/ammo_box/speedloader/shotgun/update_overlays()
	. = ..()
	for(var/i = 1 to length(stored_ammo))
		var/obj/item/ammo_casing/shotgun/ammo = stored_ammo[i]
		var/icon/new_ammo_icon = icon('icons/obj/weapons/ammo.dmi', "[initial(ammo.icon_state)]_loader")
		if(i < 7)
			new_ammo_icon.Shift(ISEVEN(i) ? WEST : EAST, 3)
		new_ammo_icon.Turn(FLOOR((i - 1) * 45, 90))
		. += new_ammo_icon

/obj/item/ammo_box/speedloader/shotgun/slug
	name = "shotgun speedloader (slug)"
	icon_state = "slugloader"
	ammo_type = /obj/item/ammo_casing/shotgun

/obj/item/ammo_box/speedloader/shotgun/buck
	name = "shotgun speedloader (buckshot)"
	icon_state = "buckshotloader"
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot

/obj/item/ammo_box/speedloader/shotgun/rubbershot
	name = "shotgun speedloader (rubbershot)"
	icon_state = "rubbershotloader"
	ammo_type = /obj/item/ammo_casing/shotgun/rubbershot

/obj/item/ammo_box/speedloader/shotgun/dart
	name = "shotgun speedloader (dart)"
	icon_state = "rubbershotloader"
	ammo_type = /obj/item/ammo_casing/shotgun/dart

/obj/item/ammo_box/speedloader/shotgun/beanbag
	name = "shotgun speedloader (beanbag)"
	icon_state = "beanbagloader"
	ammo_type = /obj/item/ammo_casing/shotgun/beanbag

/obj/item/ammo_box/speedloader/shotgun/stunslug
	name = "shotgun speedloader (stunslug)"
	icon_state = "stunslugloader"
	ammo_type = /obj/item/ammo_casing/shotgun/stunslug

/obj/item/ammo_box/speedloader/shotgun/pulseslug
	name = "shotgun speedloader (pulseslug)"
	icon_state = "pulseslugloader"
	ammo_type = /obj/item/ammo_casing/shotgun/pulseslug

/obj/item/ammo_box/speedloader/shotgun/incendiary
	name = "shotgun speedloader (incendiary)"
	icon_state = "incendiaryloader"
	ammo_type = /obj/item/ammo_casing/shotgun/incendiary

/obj/item/ammo_box/speedloader/shotgun/frag12
	name = "shotgun speedloader (frag12)"
	icon_state = "frag12loader"
	ammo_type = /obj/item/ammo_casing/shotgun/frag12

/obj/item/ammo_box/speedloader/shotgun/dragonsbreath
	name = "shotgun speedloader (dragonsbreath)"
	icon_state = "dragonsbreathloader"
	ammo_type = /obj/item/ammo_casing/shotgun/incendiary/dragonsbreath

/obj/item/ammo_box/speedloader/shotgun/ion
	name = "shotgun speedloader (ion)"
	icon_state = "ionloader"
	ammo_type = /obj/item/ammo_casing/shotgun/ion

/obj/item/ammo_box/speedloader/shotgun/laserslug
	name = "shotgun speedloader (laserslug)"
	icon_state = "laserslugloader"
	ammo_type = /obj/item/ammo_casing/shotgun/laserslug

/obj/item/ammo_box/speedloader/shotgun/lasershot
	name = "shotgun speedloader (lasershot)"
	icon_state = "lasershotloader"
	ammo_type = /obj/item/ammo_casing/shotgun/lasershot

/obj/item/ammo_box/speedloader/shotgun/tranquilizer
	name = "shotgun speedloader (tranquilizer)"
	icon_state = "tranquilizerloader"
	ammo_type = /obj/item/ammo_casing/shotgun/tranquilizer

/obj/item/ammo_box/speedloader/shotgun/improvised
	name = "shotgun speedloader (improvised)"
	icon_state = "improvisedloader"
	ammo_type = /obj/item/ammo_casing/shotgun/improvised

/obj/item/ammo_box/speedloader/shotgun/overload
	name = "shotgun speedloader (overload)"
	icon_state = "improvisedloader"
	ammo_type = /obj/item/ammo_casing/shotgun/improvised/overload

// MARK: Clips
/obj/item/ammo_box/speedloader/a762
	name = "stripper clip (7.62mm)"
	desc = "Устройство для быстрой зарядки револьверов холостыми патронами калибра 7,62х54 мм. Вмещает 5 патронов."
	icon_state = "762"
	caliber = CALIBER_7_DOT_62X54MM
	ammo_type = /obj/item/ammo_casing/a762x54
	max_ammo = 5
	multiple_sprites = 1

/obj/item/ammo_box/speedloader/a762/get_ru_names()
	return list(
		NOMINATIVE = "обойма (7,62х54 мм)",
		GENITIVE = "обойма (7,62х54 мм)",
		DATIVE = "обойму (7,62х54 мм)",
		ACCUSATIVE = "обойма (7,62х54 мм)",
		INSTRUMENTAL = "обоймой (7,62х54 мм)",
		PREPOSITIONAL = "обойме (7,62х54 мм)",
	)

// MARK: Misc
/obj/item/ammo_box/speedloader/caps
	name = "speed loader (caps)"
	desc = "Устройство для быстрой зарядки револьверов холостыми патронами .357 калибра."
	ammo_type = /obj/item/ammo_casing/cap
	caliber = CALIBER_CAP
	multiple_sprites = 1

/obj/item/ammo_box/speedloader/caps/get_ru_names()
	return list(
		NOMINATIVE = "устройство быстрой зарядки (холостые .357)",
		GENITIVE = "устройства быстрой зарядки (холостые .357)",
		DATIVE = "устройству быстрой зарядки (холостые .357)",
		ACCUSATIVE = "устройство быстрой зарядки (холостые .357)",
		INSTRUMENTAL = "устройством быстрой зарядки (холостые .357)",
		PREPOSITIONAL = "устройстве быстрой зарядки (холостые .357)",
	)
