// Basically it's both an ammo box and external magazine
/obj/item/ammo_box/speedloader
	gender = MALE
	use_bullet_type_overlay = TRUE
	can_fast_load = FALSE
	var/gun_name = "револьверов"

/obj/item/ammo_box/speedloader/get_ru_names()
	return list(
		NOMINATIVE = "ускоритель заряжания [get_cartridge_marking()]",
		GENITIVE = "ускорителя заряжания [get_cartridge_marking()]",
		DATIVE = "ускорителю заряжания [get_cartridge_marking()]",
		ACCUSATIVE = "ускоритель заряжания [get_cartridge_marking()]",
		INSTRUMENTAL = "ускорителем заряжания [get_cartridge_marking()]",
		PREPOSITIONAL = "ускорителе заряжания [get_cartridge_marking()]",
	)

/obj/item/ammo_box/speedloader/update_desc(updates = ALL)
	. = ..()
	desc = "Устройство для быстрой перезарядки [gun_name] калибра [caliber]. Вмещает вплоть до [max_ammo] \
			боеприпас[declension_ru(max_ammo, "а", "ов", "ов")].[extra_info ? " " + extra_info : ""]"

// MARK: Revolvers
/obj/item/ammo_box/speedloader/a357
	materials = list(MAT_METAL = 2000)
	ammo_type = /obj/item/ammo_casing/a357
	caliber = CALIBER_DOT_357
	icon_state = "357-7" // DEFAULT icon, composed of prefix + "-" + max_ammo for multiple_sprites == 1 boxes
	multiple_sprites = 1 // see: /obj/item/ammo_box/update_icon()
	icon_prefix = "357" // icon prefix, used in above formula to generate dynamic icons

/obj/item/ammo_box/speedloader/improvised
	extra_info = "Импровизированный вариант, сделанный из подручных материалов."
	ammo_type = null
	icon_state = "makeshift_speedloader"
	max_ammo = 4
	caliber = CALIBER_DOT_257

/obj/item/ammo_box/speedloader/improvised/update_overlays()
	. = ..()

	for(var/i = 1 to length(stored_ammo))
		var/obj/item/ammo_casing/ammo = stored_ammo[i]
		var/icon/new_ammo_icon = icon('icons/obj/weapons/ammo.dmi', ammo.icon_state)
		new_ammo_icon.Shift((i in list(2, 3)) ? 8 / RaiseToPower(2, round(i-2, 2)) : i, ISODD(i) ? 4 : 2)
		. += new_ammo_icon

/obj/item/ammo_box/speedloader/c38
	icon_state = "38"
	materials = list(MAT_METAL = 2000)
	ammo_type = /obj/item/ammo_casing/c38
	max_ammo = 6
	caliber = CALIBER_DOT_38
	icon_state = "38-6"
	multiple_sprites = 1
	icon_prefix = "38"

/obj/item/ammo_box/speedloader/c38/hp
	ammo_type = /obj/item/ammo_casing/c38/hp
	icon_state = "38hp-6"
	icon_prefix = "38hp"

/obj/item/ammo_box/speedloader/rubber45colt
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

/obj/item/ammo_box/speedloader/n762
	materials = list(MAT_METAL = 2000)
	ammo_type = /obj/item/ammo_casing/n762
	caliber = CALIBER_7_DOT_62X38MM
	icon_state = "762x38-7"
	icon_prefix = "762x38"

// MARK: Shotguns
/obj/item/ammo_box/speedloader/shotgun
	icon_state = "shotgunloader"
	icon_prefix = "shotgunloader"
	origin_tech = "combat=2"
	caliber = CALIBER_12G
	ammo_type = null
	w_class = WEIGHT_CLASS_NORMAL
	gun_name = "дробовиков"

/obj/item/ammo_box/speedloader/shotgun/Initialize(mapload)
	. = ..()

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
	icon_state = "slugloader"
	ammo_type = /obj/item/ammo_casing/shotgun

/obj/item/ammo_box/speedloader/shotgun/buck
	icon_state = "buckshotloader"
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot

/obj/item/ammo_box/speedloader/shotgun/rubbershot
	icon_state = "rubbershotloader"
	ammo_type = /obj/item/ammo_casing/shotgun/rubbershot

/obj/item/ammo_box/speedloader/shotgun/dart
	icon_state = "rubbershotloader"
	ammo_type = /obj/item/ammo_casing/shotgun/dart

/obj/item/ammo_box/speedloader/shotgun/beanbag
	icon_state = "beanbagloader"
	ammo_type = /obj/item/ammo_casing/shotgun/beanbag

/obj/item/ammo_box/speedloader/shotgun/stunslug
	icon_state = "stunslugloader"
	ammo_type = /obj/item/ammo_casing/shotgun/stunslug

/obj/item/ammo_box/speedloader/shotgun/pulseslug
	icon_state = "pulseslugloader"
	ammo_type = /obj/item/ammo_casing/shotgun/pulseslug

/obj/item/ammo_box/speedloader/shotgun/incendiary
	icon_state = "incendiaryloader"
	ammo_type = /obj/item/ammo_casing/shotgun/incendiary

/obj/item/ammo_box/speedloader/shotgun/frag12
	icon_state = "frag12loader"
	ammo_type = /obj/item/ammo_casing/shotgun/frag12

/obj/item/ammo_box/speedloader/shotgun/dragonsbreath
	icon_state = "dragonsbreathloader"
	ammo_type = /obj/item/ammo_casing/shotgun/incendiary/dragonsbreath

/obj/item/ammo_box/speedloader/shotgun/ion
	icon_state = "ionloader"
	ammo_type = /obj/item/ammo_casing/shotgun/ion

/obj/item/ammo_box/speedloader/shotgun/laserslug
	icon_state = "laserslugloader"
	ammo_type = /obj/item/ammo_casing/shotgun/laserslug

/obj/item/ammo_box/speedloader/shotgun/lasershot
	icon_state = "lasershotloader"
	ammo_type = /obj/item/ammo_casing/shotgun/lasershot

/obj/item/ammo_box/speedloader/shotgun/tranquilizer
	icon_state = "tranquilizerloader"
	ammo_type = /obj/item/ammo_casing/shotgun/tranquilizer

/obj/item/ammo_box/speedloader/shotgun/improvised
	icon_state = "improvisedloader"
	ammo_type = /obj/item/ammo_casing/shotgun/improvised

/obj/item/ammo_box/speedloader/shotgun/overload
	icon_state = "improvisedloader"
	ammo_type = /obj/item/ammo_casing/shotgun/improvised/overload

// MARK: Clips
/obj/item/ammo_box/speedloader/a762
	gender = FEMALE
	icon_state = "762"
	caliber = CALIBER_7_DOT_62X54MM
	ammo_type = /obj/item/ammo_casing/a762x54
	max_ammo = 5
	multiple_sprites = 1
	gun_name = "винтовок"

/obj/item/ammo_box/speedloader/a762/get_ru_names()
	return list(
		NOMINATIVE = "обойма [get_cartridge_marking()]",
		GENITIVE = "обоймы [get_cartridge_marking()]",
		DATIVE = "обойме [get_cartridge_marking()]",
		ACCUSATIVE = "обойму [get_cartridge_marking()]",
		INSTRUMENTAL = "обоймой [get_cartridge_marking()]",
		PREPOSITIONAL = "обойме [get_cartridge_marking()]",
	)

// MARK: Misc
/obj/item/ammo_box/speedloader/caps
	ammo_type = /obj/item/ammo_casing/cap
	caliber = CALIBER_CAP
	multiple_sprites = 1
