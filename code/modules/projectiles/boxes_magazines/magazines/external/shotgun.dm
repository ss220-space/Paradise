// MARK: 12 ammo - Standart
/obj/item/ammo_box/magazine/m12g
	name = "shotgun magazine (12g magnum buckshot)"
	desc = "Барабанный магазин, предназначенный для картечных магнум патронов калибра 12х70."
	icon_state = "m12gbc"
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot/magnum
	caliber = CALIBER_12X70
	max_ammo = 12
	multiple_sprites = 2

/obj/item/ammo_box/magazine/m12g/get_ru_names()
	return list(
		NOMINATIVE = "барабанный магазин (12х70)",
		GENITIVE = "барабанного магазина (12х70)",
		DATIVE = "барабанному магазину (12х70)",
		ACCUSATIVE = "барабанный магазина (12х70)",
		INSTRUMENTAL = "барабанным магазином (12х70)",
		PREPOSITIONAL = "барабанном магазине (12х70)",
	)

/obj/item/ammo_box/magazine/cheap_m12g
	name = "shotgun magazine (12g buckshot slugs)"
	desc = "Барабанный магазин, предназначенный для картечных патронов калибра 12х70."
	icon_state = "m12gbc"
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot
	caliber = CALIBER_12X70
	max_ammo = 12
	multiple_sprites = 2
	color = COLOR_ASSEMBLY_BROWN

/obj/item/ammo_box/magazine/cheap_m12g/get_ru_names()
	return list(
		NOMINATIVE = "барабанный магазин (картечный 12х70)",
		GENITIVE = "барабанного магазина (картечный 12х70)",
		DATIVE = "барабанному магазину (картечный 12х70)",
		ACCUSATIVE = "барабанный магазина (картечный 12х70)",
		INSTRUMENTAL = "барабанным магазином (картечный 12х70)",
		PREPOSITIONAL = "барабанном магазине (картечный 12х70)",
	)

/obj/item/ammo_box/magazine/m12g/slug
	name = "shotgun magazine (12g slugs)"
	desc = "Барабанный магазин, предназначенный для пулевых патронов калибра 12х70."
	icon_state = "m12gb"
	ammo_type = /obj/item/ammo_casing/shotgun

/obj/item/ammo_box/magazine/m12g/slug/get_ru_names()
	return list(
		NOMINATIVE = "барабанный магазин (12х70)",
		GENITIVE = "барабанного магазина (12х70)",
		DATIVE = "барабанному магазину (12х70)",
		ACCUSATIVE = "барабанный магазина (12х70)",
		INSTRUMENTAL = "барабанным магазином (12х70)",
		PREPOSITIONAL = "барабанном магазине (12х70)",
	)

/obj/item/ammo_box/magazine/m12g/stun
	name = "shotgun magazine (12g taser slugs)"
	desc = "Барабанный магазин, предназначенный для шоковых патронов калибра 12х70."
	icon_state = "m12gs"
	ammo_type = /obj/item/ammo_casing/shotgun/stunslug

/obj/item/ammo_box/magazine/m12g/stun/get_ru_names()
	return list(
		NOMINATIVE = "барабанный магазин (шоковый 12х70)",
		GENITIVE = "барабанного магазина (шоковый 12х70)",
		DATIVE = "барабанному магазину (шоковый 12х70)",
		ACCUSATIVE = "барабанный магазина (шоковый 12х70)",
		INSTRUMENTAL = "барабанным магазином (шоковый 12х70)",
		PREPOSITIONAL = "барабанном магазине (шоковый 12х70)",
	)

/obj/item/ammo_box/magazine/m12g/dragon
	name = "shotgun magazine (12g napalm dragon's breath)"
	desc = "Барабанный магазин, предназначенный для патронов \"напалмовое Дыхание дракона\" калибра 12х70."
	icon_state = "m12gf"
	ammo_type = /obj/item/ammo_casing/shotgun/incendiary/dragonsbreath/napalm

/obj/item/ammo_box/magazine/m12g/dragon/get_ru_names()
	return list(
		NOMINATIVE = "барабанный магазин (дыхание дракона 12х70)",
		GENITIVE = "барабанного магазина (дыхание дракона 12х70)",
		DATIVE = "барабанному магазину (дыхание дракона 12х70)",
		ACCUSATIVE = "барабанный магазина (дыхание дракона 12х70)",
		INSTRUMENTAL = "барабанным магазином (дыхание дракона 12х70)",
		PREPOSITIONAL = "барабанном магазине (дыхание дракона 12х70)",
	)

/obj/item/ammo_box/magazine/m12g/bioterror
	name = "shotgun magazine (12g bioterror)"
	desc = "Барабанный магазин, предназначенный для патронов \"Биотеррор\" калибра 12х70."
	icon_state = "m12gt"
	ammo_type = /obj/item/ammo_casing/shotgun/bioterror

/obj/item/ammo_box/magazine/m12g/bioterror/get_ru_names()
	return list(
		NOMINATIVE = "барабанный магазин (биотеррор 12х70)",
		GENITIVE = "барабанного магазина (биотеррор 12х70)",
		DATIVE = "барабанному магазину (биотеррор 12х70)",
		ACCUSATIVE = "барабанный магазина (биотеррор 12х70)",
		INSTRUMENTAL = "барабанным магазином (биотеррор 12х70)",
		PREPOSITIONAL = "барабанном магазине (биотеррор 12х70)",
	)

/obj/item/ammo_box/magazine/m12g/breach
	name = "shotgun magazine (12g breacher slugs)"
	desc = "Барабанный магазин, предназначенный для разрывных патронов калибра 12х70."
	icon_state = "m12gmt"
	ammo_type = /obj/item/ammo_casing/shotgun/breaching

/obj/item/ammo_box/magazine/m12g/breach/get_ru_names()
	return list(
		NOMINATIVE = "барабанный магазин (разрывные 12х70)",
		GENITIVE = "барабанного магазина (разрывные 12х70)",
		DATIVE = "барабанному магазину (разрывные 12х70)",
		ACCUSATIVE = "барабанный магазина (разрывные 12х70)",
		INSTRUMENTAL = "барабанным магазином (разрывные 12х70)",
		PREPOSITIONAL = "барабанном магазине (разрывные 12х70)",
	)

/obj/item/ammo_box/magazine/m12g/flechette
	name = "shotgun magazine (12g flechette)"
	desc = "Барабанный магазин, предназначенный для патронов \"Флешетта\" калибра 12х70."
	icon_state = "m12gb"
	ammo_type = /obj/item/ammo_casing/shotgun/flechette

/obj/item/ammo_box/magazine/m12g/flechette/get_ru_names()
	return list(
		NOMINATIVE = "барабанный магазин (флешетты 12х70)",
		GENITIVE = "барабанного магазина (флешетты 12х70)",
		DATIVE = "барабанному магазину (флешетты 12х70)",
		ACCUSATIVE = "барабанный магазина (флешетты 12х70)",
		INSTRUMENTAL = "барабанным магазином (флешетты 12х70)",
		PREPOSITIONAL = "барабанном магазине (флешетты 12х70)",
	)

// MARK: 24 ammo - Standart
/obj/item/ammo_box/magazine/m12g/XtrLrg
	name = "XL shotgun magazine (12g buckshot slugs)"
	desc = "Увеличенный барабанный магазин, предназначенный для картечных магнум патронов калибра 12х70."
	icon_state = "m12gXlBs"
	w_class = WEIGHT_CLASS_NORMAL
	max_ammo = 24

/obj/item/ammo_box/magazine/m12g/XtrLrg/get_ru_names()
	return list(
		NOMINATIVE = "увеличенный барабанный магазин (усиленные 12х70)",
		GENITIVE = "увеличенного барабанного магазина (усиленные 12х70)",
		DATIVE = "увеличенному барабанному магазину (усиленные 12х70)",
		ACCUSATIVE = "увеличенный барабанный магазин (усиленные 12х70)",
		INSTRUMENTAL = "увеличенным барабанным магазином (усиленные 12х70)",
		PREPOSITIONAL = "увеличенном барабанном магазине (усиленные 12х70)",
	)

/obj/item/ammo_box/magazine/m12g/XtrLrg/flechette
	name = "XL shotgun magazine (12g flechette)"
	desc = "Увеличенный барабанный магазин, предназначенный для патронов \"Флешетта\" калибра 12х70."
	icon_state = "m12gXlSl"
	ammo_type = /obj/item/ammo_casing/shotgun/flechette

/obj/item/ammo_box/magazine/m12g/XtrLrg/flechette/get_ru_names()
	return list(
		NOMINATIVE = "увеличенный барабанный магазин (флешетты 12х70)",
		GENITIVE = "увеличенного барабанного магазина (флешетты 12х70)",
		DATIVE = "увеличенному барабанному магазину (флешетты 12х70)",
		ACCUSATIVE = "увеличенный барабанный магазин (флешетты 12х70)",
		INSTRUMENTAL = "увеличенным барабанным магазином (флешетты 12х70)",
		PREPOSITIONAL = "увеличенном барабанном магазине (флешетты 12х70)",
	)

/obj/item/ammo_box/magazine/m12g/XtrLrg/slug
	name = "XL shotgun magazine (12g slugs)"
	desc = "Увеличенный барабанный магазин, предназначенный для пулевых патронов калибра 12х70."
	icon_state = "m12gXlSl"
	ammo_type = /obj/item/ammo_casing/shotgun

/obj/item/ammo_box/magazine/m12g/XtrLrg/slug/get_ru_names()
	return list(
		NOMINATIVE = "увеличенный барабанный магазин (пулевой 12х70)",
		GENITIVE = "увеличенного барабанного магазина (пулевой 12х70)",
		DATIVE = "увеличенному барабанному магазину (пулевой 12х70)",
		ACCUSATIVE = "увеличенный барабанный магазин (пулевой 12х70)",
		INSTRUMENTAL = "увеличенным барабанным магазином (пулевой 12х70)",
		PREPOSITIONAL = "увеличенном барабанном магазине (пулевой 12х70)",
	)

/obj/item/ammo_box/magazine/m12g/XtrLrg/dragon
	name = "XL shotgun magazine (12g napalm dragon's breath)"
	desc = "Увеличенный барабанный магазин, предназначенный для патронов \"напалмовое Дыхание дракона\" калибра 12х70."
	icon_state = "m12gXlDb"
	ammo_type = /obj/item/ammo_casing/shotgun/incendiary/dragonsbreath/napalm

/obj/item/ammo_box/magazine/m12g/XtrLrg/dragon/get_ru_names()
	return list(
		NOMINATIVE = "увеличенный барабанный магазин (напалмовое дыхание дракона 12х70)",
		GENITIVE = "увеличенного барабанного магазина (напалмовое дыхание дракона 12х70)",
		DATIVE = "увеличенному барабанному магазину (напалмовое дыхание дракона 12х70)",
		ACCUSATIVE = "увеличенный барабанный магазин (напалмовое дыхание дракона 12х70)",
		INSTRUMENTAL = "увеличенным барабанным магазином (напалмовое дыхание дракона 12х70)",
		PREPOSITIONAL = "увеличенном барабанном магазине (напалмовое дыхание дракона 12х70)",
	)

// MARK: 8 ammo - C.A.T.S.
/obj/item/ammo_box/magazine/cats12g
	name = "C.A.T.S. magazine (12g slug)"
	desc = "Барабанный магазин дробовика C.A.T.S., предназначенный для пулевых патронов калибра 12х70."
	icon_state = "cats_mag_slug"
	ammo_type = /obj/item/ammo_casing/shotgun
	multiple_sprites = 2
	max_ammo = 8

/obj/item/ammo_box/magazine/cats12g/get_ru_names()
	return list(
		NOMINATIVE = "барабанный магазин C.A.T.S. (пулевой 12х70)",
		GENITIVE = "барабанного магазина C.A.T.S. (пулевой 12х70)",
		DATIVE = "барабанному магазину C.A.T.S. (пулевой 12х70)",
		ACCUSATIVE = "барабанный магазина C.A.T.S. (пулевой 12х70)",
		INSTRUMENTAL = "барабанным магазином C.A.T.S. (пулевой 12х70)",
		PREPOSITIONAL = "барабанном магазине C.A.T.S. (пулевой 12х70)",
	)

/obj/item/ammo_box/magazine/cats12g/beanbang
	name = "C.A.T.S. magazine (12g-beanbang)"
	desc = "Барабанный магазин дробовика C.A.T.S., предназначенный для резиновых патронов калибра 12х70."
	icon_state = "cats_mag_bean"
	ammo_type = /obj/item/ammo_casing/shotgun/beanbag

/obj/item/ammo_box/magazine/cats12g/beanbang/get_ru_names()
	return list(
		NOMINATIVE = "барабанный магазин C.A.T.S. (резиновая пуля 12х70)",
		GENITIVE = "барабанного магазина C.A.T.S. (резиновая пуля 12х70)",
		DATIVE = "барабанному магазину C.A.T.S. (резиновая пуля 12х70)",
		ACCUSATIVE = "барабанный магазина C.A.T.S. (резиновая пуля 12х70)",
		INSTRUMENTAL = "барабанным магазином C.A.T.S. (резиновая пуля 12х70)",
		PREPOSITIONAL = "барабанном магазине C.A.T.S. (резиновая пуля 12х70)",
	)

/obj/item/ammo_box/magazine/cats12g/universal
	name = "C.A.T.S. magazine (12g)-U"
	desc = "Барабанный магазин дробовика C.A.T.S., предназначенный для любых патронов калибра 12х70."
	icon_state = "cats_mag"
	caliber = CALIBER_12X70
	ammo_type = null

/obj/item/ammo_box/magazine/cats12g/universal/get_ru_names()
	return list(
		NOMINATIVE = "барабанный магазин C.A.T.S. (12х70)",
		GENITIVE = "барабанного магазина C.A.T.S. (12х70)",
		DATIVE = "барабанному магазину C.A.T.S. (12х70)",
		ACCUSATIVE = "барабанный магазина C.A.T.S. (12х70)",
		INSTRUMENTAL = "барабанным магазином C.A.T.S. (12х70)",
		PREPOSITIONAL = "барабанном магазине C.A.T.S. (12х70)",
	)

// MARK: 14 ammo - C.A.T.S.
/obj/item/ammo_box/magazine/cats12g/large
	name = "C.A.T.S. magazine (12g-slug)-L"
	desc = "Увеличенный барабанный магазин дробовика C.A.T.S., предназначенный для пулевых патронов калибра 12х70."
	icon_state = "cats_mag_large_slug"
	max_ammo = 14

/obj/item/ammo_box/magazine/cats12g/large/get_ru_names()
	return list(
		NOMINATIVE = "увеличенный барабанный магазин C.A.T.S. (пулевой 12х70)",
		GENITIVE = "увеличенного барабанного магазина C.A.T.S. (пулевой 12х70)",
		DATIVE = "увеличенному барабанному магазину C.A.T.S. (пулевой 12х70)",
		ACCUSATIVE = "увеличенный барабанный магазин C.A.T.S. (пулевой 12х70)",
		INSTRUMENTAL = "увеличенным барабанным магазином C.A.T.S. (пулевой 12х70)",
		PREPOSITIONAL = "увеличенном барабанном магазине C.A.T.S. (пулевой 12х70)",
	)

/obj/item/ammo_box/magazine/cats12g/large/beanbag
	name = "C.A.T.S. magazine (12g-beanbang)-L"
	desc = "Увеличенный барабанный магазин дробовика C.A.T.S., предназначенный для резиновых патронов калибра 12х70."
	icon_state = "cats_mag_large_bean"
	ammo_type = /obj/item/ammo_casing/shotgun/beanbag

/obj/item/ammo_box/magazine/cats12g/large/beanbag/get_ru_names()
	return list(
		NOMINATIVE = "увеличенный барабанный магазин C.A.T.S. (резиновая пуля 12х70)",
		GENITIVE = "увеличенного барабанного магазина C.A.T.S. (резиновая пуля 12х70)",
		DATIVE = "увеличенному барабанному магазину C.A.T.S. (резиновая пуля 12х70)",
		ACCUSATIVE = "увеличенный барабанный магазин C.A.T.S. (резиновая пуля 12х70)",
		INSTRUMENTAL = "увеличенным барабанным магазином C.A.T.S. (резиновая пуля 12х70)",
		PREPOSITIONAL = "увеличенном барабанном магазине C.A.T.S. (резиновая пуля 12х70)",
	)

/obj/item/ammo_box/magazine/cats12g/large/universal
	name = "C.A.T.S. magazine (12g)-UL"
	desc = "Увеличенный барабанный магазин дробовика C.A.T.S., предназначенный для любых патронов калибра 12х70."
	icon_state = "cats_mag_large"
	caliber = CALIBER_12X70
	ammo_type = null

/obj/item/ammo_box/magazine/cats12g/large/universal/get_ru_names()
	return list(
		NOMINATIVE = "увеличенный барабанный магазин C.A.T.S. (12х70)",
		GENITIVE = "увеличенного барабанного магазина C.A.T.S. (12х70)",
		DATIVE = "увеличенному барабанному магазину C.A.T.S. (12х70)",
		ACCUSATIVE = "увеличенный барабанный магазин C.A.T.S. (12х70)",
		INSTRUMENTAL = "увеличенным барабанным магазином C.A.T.S. (12х70)",
		PREPOSITIONAL = "увеличенном барабанном магазине C.A.T.S. (12х70)",
	)
