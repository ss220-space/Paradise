// MARK: 10mm - Stechkin
/obj/item/ammo_box/magazine/m10mm
	name = "pistol magazine (10mm)"
	desc = "Магазин пистолета \"Стечкин\", заряженный патронами калибра 10 мм. Эти патроны примерно в два раза менее эффективны, чем патроны .357 калибра."
	icon_state = "9x19p"
	ammo_type = /obj/item/ammo_casing/c10mm
	caliber = CALIBER_10MM
	max_ammo = 10
	multiple_sprites = 2

/obj/item/ammo_box/magazine/m10mm/get_ru_names()
	return list(
		NOMINATIVE = "магазин пистолета \"Стечкин\" (10 мм)",
		GENITIVE = "магазина пистолета \"Стечкин\" (10 мм)",
		DATIVE = "магазину пистолета \"Стечкин\" (10 мм)",
		ACCUSATIVE = "магазин пистолета \"Стечкин\" (10 мм)",
		INSTRUMENTAL = "магазином пистолета \"Стечкин\" (10 мм)",
		PREPOSITIONAL = "магазине пистолета \"Стечкин\" (10 мм)",
	)

/obj/item/ammo_box/magazine/m10mm/fire
	name = "pistol magazine (10mm incendiary)"
	desc = "Магазин пистолета \"Стечкин\", заряженный зажигательными патронами калибра 10 мм. Эти патроны поджигают цель при попадании."
	icon_state = "9x19pI"
	ammo_type = /obj/item/ammo_casing/c10mm/fire

/obj/item/ammo_box/magazine/m10mm/fire/get_ru_names()
	return list(
		NOMINATIVE = "магазин пистолета \"Стечкин\" (зажигательные 10 мм)",
		GENITIVE = "магазина пистолета \"Стечкин\" (зажигательные 10 мм)",
		DATIVE = "магазину пистолета \"Стечкин\" (зажигательные 10 мм)",
		ACCUSATIVE = "магазин пистолета \"Стечкин\" (зажигательные 10 мм)",
		INSTRUMENTAL = "магазином пистолета \"Стечкин\" (зажигательные 10 мм)",
		PREPOSITIONAL = "магазине пистолета \"Стечкин\" (зажигательные 10 мм)",
	)

/obj/item/ammo_box/magazine/m10mm/hp
	name = "pistol magazine (10mm HP)"
	desc = "Магазин пистолета \"Стечкин\", заряженный экспансивными патронами калибра 10 мм. Эти патроны наносят намного больше повреждений, чем стандартные, но они совершенно бесполезны против брони."
	icon_state = "9x19pH"
	ammo_type = /obj/item/ammo_casing/c10mm/hp

/obj/item/ammo_box/magazine/m10mm/hp/get_ru_names()
	return list(
		NOMINATIVE = "магазин пистолета \"Стечкин\" (экспансивные 10 мм)",
		GENITIVE = "магазина пистолета \"Стечкин\" (экспансивные 10 мм)",
		DATIVE = "магазину пистолета \"Стечкин\" (экспансивные 10 мм)",
		ACCUSATIVE = "магазин пистолета \"Стечкин\" (экспансивные 10 мм)",
		INSTRUMENTAL = "магазином пистолета \"Стечкин\" (экспансивные 10 мм)",
		PREPOSITIONAL = "магазине пистолета \"Стечкин\" (экспансивные 10 мм)",
	)

/obj/item/ammo_box/magazine/m10mm/ap
	name = "pistol magazine (10mm AP)"
	desc = "Магазин пистолета \"Стечкин\", заряженный бронебойными патронами калибра 10 мм. Эти патроны наносят немного меньше повреждений, чем стандартные, но обладают высокой пробивной силой."
	icon_state = "9x19pA"
	ammo_type = /obj/item/ammo_casing/c10mm/ap

/obj/item/ammo_box/magazine/m10mm/ap/get_ru_names()
	return list(
		NOMINATIVE = "магазин пистолета \"Стечкин\" (бронебойные 10 мм)",
		GENITIVE = "магазина пистолета \"Стечкин\" (бронебойные 10 мм)",
		DATIVE = "магазину пистолета \"Стечкин\" (бронебойные 10 мм)",
		ACCUSATIVE = "магазин пистолета \"Стечкин\" (бронебойные 10 мм)",
		INSTRUMENTAL = "магазином пистолета \"Стечкин\" (бронебойные 10 мм)",
		PREPOSITIONAL = "магазине пистолета \"Стечкин\" (бронебойные 10 мм)",
	)

/obj/item/ammo_box/magazine/m10mm/update_icon_state()
	icon_state = "[initial(icon_state)]-[ammo_count() ? "15" : "0"]"

// MARK: .45 - M1911
/obj/item/ammo_box/magazine/m45
	name = "handgun magazine (.45)"
	desc = "Магазин пистолета \"M1911\", заряженный патронами .45 калибра. Эти патроны обладают сильным останавливающим действием, способным сбить с ног большинство целей, однако они не наносят серьёзных повреждений."
	icon_state = "45"
	ammo_type = /obj/item/ammo_casing/c45
	caliber = CALIBER_DOT_45
	max_ammo = 8
	multiple_sprites = 1

/obj/item/ammo_box/magazine/m45/get_ru_names()
	return list(
		NOMINATIVE = "пистолетный магазин пистолета \"M1911\" (.45)",
		GENITIVE = "магазина пистолета \"M1911\" (.45)",
		DATIVE = "магазину пистолета \"M1911\" (.45)",
		ACCUSATIVE = "магазин пистолета \"M1911\" (.45)",
		INSTRUMENTAL = "магазином пистолета \"M1911\" (.45)",
		PREPOSITIONAL = "магазине пистолета \"M1911\" (.45)",
	)

// MARK: .40 S&W - SP-8
/obj/item/ammo_box/magazine/sp8
	name = "handgun magazine .40 S&W"
	desc = "Магазин пистолета \"SP-8\", заряженный патронами .40 калибра S&W."
	icon_state = "sp8mag"
	ammo_type = /obj/item/ammo_casing/fortynr
	max_ammo = 10
	caliber = CALIBER_40NR
	materials = list(MAT_METAL = 2500)

/obj/item/ammo_box/magazine/sp8/empty
	start_empty = TRUE

/obj/item/ammo_box/magazine/sp8/get_ru_names()
	return list(
		NOMINATIVE = "магазин пистолета \"SP-8\" (.40 S&W)",
		GENITIVE = "магазина пистолета \"SP-8\" (.40 S&W)",
		DATIVE = "магазину пистолета \"SP-8\" (.40 S&W)",
		ACCUSATIVE = "магазин пистолета \"SP-8\" (.40 S&W)",
		INSTRUMENTAL = "магазином пистолета \"SP-8\" (.40 S&W)",
		PREPOSITIONAL = "магазине пистолета \"SP-8\" (.40 S&W)",
	)

/obj/item/ammo_box/magazine/sp8/update_icon_state()
	icon_state = "sp8mag-[round(ammo_count(),2)]"

// MARK: .50 AE - Desert Eagle
/obj/item/ammo_box/magazine/m50
	name = "handgun magazine (.50ae)"
	desc = "Магазин пистолета \"Desert Eagle\", предназначенный для патронов .50 калибра AE."
	icon_state = "50ae"
	ammo_type = /obj/item/ammo_casing/a50
	caliber = CALIBER_DOT_50AE
	multiple_sprites = 1

/obj/item/ammo_box/magazine/m50/get_ru_names()
	return list(
		NOMINATIVE = "магазин Desert Eagle (.50 AE)",
		GENITIVE = "магазина Desert Eagle (.50 AE)",
		DATIVE = "магазину Desert Eagle (.50 AE)",
		ACCUSATIVE = "магазина Desert Eagle (.50 AE)",
		INSTRUMENTAL = "магазином Desert Eagle (.50 AE)",
		PREPOSITIONAL = "магазине Desert Eagle (.50 AE)",
	)

// MARK: 9mm - Enforcer
/obj/item/ammo_box/magazine/enforcer
	name = "handgun magazine (9mm rubber)"
	desc = "Магазин пистолета \"Блюститель\", заряженный нелетальными патронами калибра 9 мм. Эти патроны обладают хорошим останавливающим действием, способным сбить с ног большинство целей не нанося значительных повреждений."
	icon_state = "enforcer"
	ammo_type = /obj/item/ammo_casing/rubber9mm
	max_ammo = 8
	multiple_sprites = 1
	caliber = CALIBER_9MM

/obj/item/ammo_box/magazine/enforcer/empty
	start_empty = TRUE

/obj/item/ammo_box/magazine/enforcer/get_ru_names()
	return list(
		NOMINATIVE = "магазин пистолета \"Блюститель\" (нелетальные 9 мм)",
		GENITIVE = "магазина пистолета \"Блюститель\" (нелетальные 9 мм)",
		DATIVE = "магазину пистолета \"Блюститель\" (нелетальные 9 мм)",
		ACCUSATIVE = "магазин пистолета \"Блюститель\" (нелетальные 9 мм)",
		INSTRUMENTAL = "магазином пистолета \"Блюститель\" (нелетальные 9 мм)",
		PREPOSITIONAL = "магазине пистолета \"Блюститель\" (нелетальные 9 мм)",
	)

/obj/item/ammo_box/magazine/enforcer/update_overlays()
	. = ..()
	if(ammo_count() && is_rubber())
		. += image('icons/obj/weapons/ammo.dmi', icon_state = "enforcer-r")

/obj/item/ammo_box/magazine/enforcer/examine(mob/user)
	. = ..()
	if(get_dist(user, src) <= 2)
		. += span_notice("В нем заряжены патроны с [is_rubber() ? "резиновыми" : "летальными"] пулями.") //only can see the topmost one.

/obj/item/ammo_box/magazine/enforcer/proc/is_rubber()//if the topmost bullet is a rubber one
	var/ammo = ammo_count()
	if(!ammo)
		return FALSE
	if(istype(contents[length(contents)], /obj/item/ammo_casing/rubber9mm))
		return TRUE
	return FALSE

/obj/item/ammo_box/magazine/enforcer/lethal
	name = "handgun magazine (9mm)"
	desc = "Магазин пистолета \"Блюститель\", заряженный патронами калибра 9 мм. Стандартные патроны для пистолета \"Блюститель\" службы безопасности."
	ammo_type = /obj/item/ammo_casing/c9mm

/obj/item/ammo_box/magazine/enforcer/lethal/get_ru_names()
	return list(
		NOMINATIVE = "магазин пистолета \"Блюститель\" (9 мм)",
		GENITIVE = "магазина пистолета \"Блюститель\" (9 мм)",
		DATIVE = "магазину пистолета \"Блюститель\" (9 мм)",
		ACCUSATIVE = "магазин пистолета \"Блюститель\" (9 мм)",
		INSTRUMENTAL = "магазином пистолета \"Блюститель\" (9 мм)",
		PREPOSITIONAL = "магазине пистолета \"Блюститель\" (9 мм)",
	)

/obj/item/ammo_box/magazine/enforcer/extended
	name = "extended handgun magazine (9mm)"
	desc = "Расширенный магазин пистолета \"Блюститель\", заряжается патронами калибра 9 мм. Эти патроны обладают хорошим останавливающим действием, способным сбить с ног большинство целей, не нанося значительных повреждений."
	max_ammo = 12
	start_empty = TRUE
	icon_state = "enforcer-ext"

/obj/item/ammo_box/magazine/enforcer/extended/get_ru_names()
	return list(
		NOMINATIVE = "расширенный магазин пистолета \"Блюститель\" (9 мм)",
		GENITIVE = "расширенного магазина пистолета \"Блюститель\" (9 мм)",
		DATIVE = "расширенному магазину пистолета \"Блюститель\" (9 мм)",
		ACCUSATIVE = "расширенный магазин пистолета \"Блюститель\" (9 мм)",
		INSTRUMENTAL = "расширенным магазином пистолета \"Блюститель\" (9 мм)",
		PREPOSITIONAL = "расширенном магазине пистолета \"Блюститель\" (9 мм)",
	)

// MARK: 9mm - APS
/obj/item/ammo_box/magazine/pistolm9mm
	name = "pistol magazine (9mm)"
	desc = "Магазин пистолета АПС, предназначенный для патронов калибра 9 мм."
	icon_state = "9x19p-15"
	ammo_type = /obj/item/ammo_casing/c9mm
	caliber = CALIBER_9MM
	max_ammo = 15

/obj/item/ammo_box/magazine/pistolm9mm/get_ru_names()
	return list(
		NOMINATIVE = "магазин АПС (9 мм)",
		GENITIVE = "магазина АПС (9 мм)",
		DATIVE = "магазину АПС (9 мм)",
		ACCUSATIVE = "магазина АПС (9 мм)",
		INSTRUMENTAL = "магазином АПС (9 мм)",
		PREPOSITIONAL = "магазине АПС (9 мм)",
	)

/obj/item/ammo_box/magazine/pistolm9mm/update_icon_state()
	icon_state = "9x19p-[ammo_count() ? "15" : "0"]"
