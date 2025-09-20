/**
 * AMMO BOX
 */

// REVOLVER
/obj/item/ammo_box/a357
	name = "ammo box (.357)"
	desc = "Коробка, содержащая патроны .357 калибра \"Магнум\"."
	icon_state = "357OLD"  // see previous entry for explanation of these vars
	ammo_type = /obj/item/ammo_casing/a357
	max_ammo = 21

/obj/item/ammo_box/a357/get_ru_names()
	return list(
		NOMINATIVE = "коробка патронов (.357)",
		GENITIVE = "коробки патронов (.357)",
		DATIVE = "коробке патронов (.357)",
		ACCUSATIVE = "коробку патронов (.357)",
		INSTRUMENTAL = "коробкой патронов (.357)",
		PREPOSITIONAL = "коробке патронов (.357)"
	)

/obj/item/ammo_box/a357/update_icon_state()
	icon_state = "[initial(icon_state)]-[round(length(stored_ammo) / 3)]"


/obj/item/ammo_box/n762
	name = "ammo box (7.62x38mm)"
	desc = "Коробка, содержащая патроны калибра 7,62x38 мм."
	icon_state = "riflebox"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/n762
	max_ammo = 14

/obj/item/ammo_box/n762/get_ru_names()
	return list(
		NOMINATIVE = "коробка патронов (7,62x38 мм)",
		GENITIVE = "коробки патронов (7,62x38 мм)",
		DATIVE = "коробке патронов (7,62x38 мм)",
		ACCUSATIVE = "коробку патронов (7,62x38 мм)",
		INSTRUMENTAL = "коробкой патронов (7,62x38 мм)",
		PREPOSITIONAL = "коробке патронов (7,62x38 мм)"
	)

// SHOTGUN
/obj/item/ammo_box/shotgun
	name = "ammunition box (Slug)"
	desc = "Коробка, содержащая пулевые патроны калибра 12х70."
	icon_state = "slugbox"
	ammo_type = /obj/item/ammo_casing/shotgun
	max_ammo = 7
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/ammo_box/shotgun/get_ru_names()
	return list(
		NOMINATIVE = "коробка патронов (пулевой 12х70)",
		GENITIVE = "коробки ружейных патронов (пулевой 12х70)",
		DATIVE = "коробке ружейных патронов (пулевой 12х70)",
		ACCUSATIVE = "коробку ружейных патронов (пулевой 12х70)",
		INSTRUMENTAL = "коробкой ружейных патронов (пулевой 12х70)",
		PREPOSITIONAL = "коробке ружейных патронов (пулевой 12х70)"
	)

/obj/item/ammo_box/shotgun/buck
	name = "ammunition box (buckshot)"
	desc = "Коробка, содержащая картечные патроны калибра 12х70."
	icon_state = "buckshotbox"
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot

/obj/item/ammo_box/shotgun/buck/get_ru_names()
	return list(
		NOMINATIVE = "коробка ружейных патронов (картечь 12х70)",
		GENITIVE = "коробки ружейных патронов (картечь 12х70)",
		DATIVE = "коробке ружейных патронов (картечь 12х70)",
		ACCUSATIVE = "коробку ружейных патронов (картечь 12х70)",
		INSTRUMENTAL = "коробкой ружейных патронов (картечь 12х70)",
		PREPOSITIONAL = "коробке ружейных патронов (картечь 12х70)"
	)

/obj/item/ammo_box/shotgun/buck/assassination
	name = "ammunition box (assassination shells)"
	desc = "Коробка, содержащая шрапнельные патроны с глушащим токсином калибра 12х70."
	ammo_type = /obj/item/ammo_casing/shotgun/assassination

/obj/item/ammo_box/shotgun/buck/assassination/get_ru_names()
	return list(
		NOMINATIVE = "коробка патронов (шрапнель с глушащим токсином 12х70)",
		GENITIVE = "коробки патронов (шрапнель с глушащим токсином 12х70)",
		DATIVE = "коробке патронов (шрапнель с глушащим токсином 12х70)",
		ACCUSATIVE = "коробку патронов (шрапнель с глушащим токсином 12х70)",
		INSTRUMENTAL = "коробкой патронов (шрапнель с глушащим токсином 12х70)",
		PREPOSITIONAL = "коробке патронов (шрапнель с глушащим токсином 12х70)"
	)

/obj/item/ammo_box/shotgun/buck/magnum
	name = "elite ammunition box (buckshot)"
	desc = "Коробка, содержащая патроны с магнум картечью калибра 12х70."
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot/magnum

/obj/item/ammo_box/shotgun/buck/magnum/get_ru_names()
	return list(
		NOMINATIVE = "коробка патронов (магнум картечь 12х70)",
		GENITIVE = "коробки патронов (магнум картечь 12х70)",
		DATIVE = "коробке патронов (магнум картечь 12х70)",
		ACCUSATIVE = "коробку патронов (магнум картечь 12х70)",
		INSTRUMENTAL = "коробкой патронов (магнум картечь 12х70)",
		PREPOSITIONAL = "коробке патронов (магнум картечь 12х70)"
	)

/obj/item/ammo_box/shotgun/rubbershot
	name = "ammunition box (rubbershot shells)"
	desc = "Коробка, содержащая патроны с резиновой картечью калибра 12х70."
	icon_state = "rubbershotbox"
	ammo_type = /obj/item/ammo_casing/shotgun/rubbershot

/obj/item/ammo_box/shotgun/rubbershot/get_ru_names()
	return list(
		NOMINATIVE = "коробка патронов (резиновая картечь 12х70)",
		GENITIVE = "коробки патронов (резиновая картечь 12х70)",
		DATIVE = "коробке патронов (резиновая картечь 12х70)",
		ACCUSATIVE = "коробку патронов (резиновая картечь 12х70)",
		INSTRUMENTAL = "коробкой патронов (резиновая картечь 12х70)",
		PREPOSITIONAL = "коробке патронов (резиновая картечь 12х70)"
	)

/obj/item/ammo_box/shotgun/rubbershot/dart
	name = "ammunition box (dart shells)"
	desc = "Коробка, содержащая шприцевые патроны калибра 12х70."
	ammo_type = /obj/item/ammo_casing/shotgun/dart

/obj/item/ammo_box/shotgun/rubbershot/dart/get_ru_names()
	return list(
		NOMINATIVE = "коробка патронов (патрон-шприц 12х70)",
		GENITIVE = "коробки патронов (патрон-шприц 12х70)",
		DATIVE = "коробке патронов (патрон-шприц 12х70)",
		ACCUSATIVE = "коробку патронов (патрон-шприц 12х70)",
		INSTRUMENTAL = "коробкой патронов (патрон-шприц 12х70)",
		PREPOSITIONAL = "коробке патронов (патрон-шприц 12х70)"
	)

/obj/item/ammo_box/shotgun/beanbag
	name = "ammunition box (beanbag shells)"
	desc = "Коробка, содержащая нелетальные патроны с резиновой пулей калибра 12х70."
	icon_state = "beanbagbox"
	ammo_type = /obj/item/ammo_casing/shotgun/beanbag

/obj/item/ammo_box/shotgun/beanbag/get_ru_names()
	return list(
		NOMINATIVE = "коробка патронов (резиновая пуля 12х70)",
		GENITIVE = "коробки патронов (резиновая пуля 12х70)",
		DATIVE = "коробке патронов (резиновая пуля 12х70)",
		ACCUSATIVE = "коробку патронов (резиновая пуля 12х70)",
		INSTRUMENTAL = "коробкой патронов (резиновая пуля 12х70)",
		PREPOSITIONAL = "коробке патронов (резиновая пуля 12х70)"
	)

/obj/item/ammo_box/shotgun/beanbag/fake
	ammo_type = /obj/item/ammo_casing/shotgun/beanbag/fake

/obj/item/ammo_box/shotgun/stunslug
	name = "ammunition box (stun shells)"
	desc = "Коробка, содержащая патроны с электрошоком калибра 12х70."
	icon_state = "stunslugbox"
	ammo_type = /obj/item/ammo_casing/shotgun/stunslug

/obj/item/ammo_box/shotgun/stunslug/get_ru_names/get_ru_names()
	return list(
		NOMINATIVE = "коробка патронов (электрошок 12х70)",
		GENITIVE = "коробки патронов (электрошок 12х70)",
		DATIVE = "коробке патронов (электрошок 12х70)",
		ACCUSATIVE = "коробку патронов (электрошок 12х70)",
		INSTRUMENTAL = "коробкой патронов (электрошок 12х70)",
		PREPOSITIONAL = "коробке патронов (электрошок 12х70)"
	)

/obj/item/ammo_box/shotgun/breaching
	name = "ammunition box (breaching shells)"
	desc = "Коробка, содержащая штурмовые патроны с для пробивания дверей и замков калибра 12х70."
	icon_state = "meteorshotbox"
	ammo_type = /obj/item/ammo_casing/shotgun/breaching

/obj/item/ammo_box/shotgun/breaching/get_ru_names()
	return list(
		NOMINATIVE = "коробка патронов (штурмовые 12х70)",
		GENITIVE = "коробки патронов (штурмовые 12х70)",
		DATIVE = "коробке патронов (штурмовые 12х70)",
		ACCUSATIVE = "коробку патронов (штурмовые 12х70)",
		INSTRUMENTAL = "коробкой патронов (штурмовые 12х70)",
		PREPOSITIONAL = "коробке патронов (штурмовые 12х70)"
	)

/obj/item/ammo_box/shotgun/pulseslug
	name = "ammunition box (pulse slugs)"
	desc = "Коробка, содержащая патроны \"Импульсная пуля\" калибра 12х70."
	icon_state = "pulseslugbox"
	ammo_type = /obj/item/ammo_casing/shotgun/pulseslug

/obj/item/ammo_box/shotgun/pulseslug/get_ru_names()
	return list(
		NOMINATIVE = "коробка патронов (импульсная пуля 12х70)",
		GENITIVE = "коробки патронов (импульсная пуля 12х70)",
		DATIVE = "коробке патронов (импульсная пуля 12х70)",
		ACCUSATIVE = "коробку патронов (импульсная пуля 12х70)",
		INSTRUMENTAL = "коробкой патронов (импульсная пуля 12х70)",
		PREPOSITIONAL = "коробке патронов (импульсная пуля 12х70)"
	)

/obj/item/ammo_box/shotgun/incendiary
	name = "ammunition box (incendiary slugs)"
	desc = "Коробка, содержащая зажигательные патроны калибра 12х70."
	icon_state = "incendiarybox"
	ammo_type = /obj/item/ammo_casing/shotgun/incendiary

/obj/item/ammo_box/shotgun/incendiary/get_ru_names()
	return list(
		NOMINATIVE = "коробка патронов (зажигательные 12х70)",
		GENITIVE = "коробки патронов (зажигательные 12х70)",
		DATIVE = "коробке патронов (зажигательные 12х70)",
		ACCUSATIVE = "коробку патронов (зажигательные 12х70)",
		INSTRUMENTAL = "коробкой патронов (зажигательные 12х70)",
		PREPOSITIONAL = "коробке патронов (зажигательные 12х70)"
	)

/obj/item/ammo_box/shotgun/frag12
	name = "ammunition box (frag-12 slugs)"
	desc = "Коробка, содержащая разрывные патроны калибра 12х70."
	icon_state = "frag12box"
	ammo_type = /obj/item/ammo_casing/shotgun/frag12

/obj/item/ammo_box/shotgun/frag12/get_ru_names()
	return list(
		NOMINATIVE = "коробка патронов (разрывная пуля 12х70)",
		GENITIVE = "коробки патронов (разрывная пуля 12х70)",
		DATIVE = "коробке патронов (разрывная пуля 12х70)",
		ACCUSATIVE = "коробку патронов (разрывная пуля 12х70)",
		INSTRUMENTAL = "коробкой патронов (разрывная пуля 12х70)",
		PREPOSITIONAL = "коробке патронов (разрывная пуля 12х70)"
	)

/obj/item/ammo_box/shotgun/dragonsbreath
	name = "ammunition box (dragonsbreath)"
	desc = "Коробка, содержащая патроны \"Дыхание дракона\" калибра 12х70."
	icon_state = "dragonsbreathbox"
	ammo_type = /obj/item/ammo_casing/shotgun/incendiary/dragonsbreath

/obj/item/ammo_box/shotgun/dragonsbreath/get_ru_names()
	return list(
		NOMINATIVE = "коробка патронов (дыхание дракона 12х70)",
		GENITIVE = "коробки патронов (дыхание дракона 12х70)",
		DATIVE = "коробке патронов (дыхание дракона 12х70)",
		ACCUSATIVE = "коробку патронов (дыхание дракона 12х70)",
		INSTRUMENTAL = "коробкой патронов (дыхание дракона 12х70)",
		PREPOSITIONAL = "коробке патронов (дыхание дракона 12х70)"
	)

/obj/item/ammo_box/shotgun/dragonsbreath/napalm
	name = "elite ammunition box (dragonsbreath)"
	desc = "Коробка, содержащая усиленные патроны \"Дыхание дракона\" калибра 12х70."
	ammo_type = /obj/item/ammo_casing/shotgun/incendiary/dragonsbreath/napalm

/obj/item/ammo_box/shotgun/dragonsbreath/napalm/get_ru_names()
	return list(
		NOMINATIVE = "коробка патронов (напалмовое дыхание дракона 12х70)",
		GENITIVE = "коробки патронов (напалмовое дыхание дракона 12х70)",
		DATIVE = "коробке патронов (напалмовое дыхание дракона 12х70)",
		ACCUSATIVE = "коробку патронов (напалмовое дыхание дракона 12х70)",
		INSTRUMENTAL = "коробкой патронов (напалмовое дыхание дракона 12х70)",
		PREPOSITIONAL = "коробке патронов (напалмовое дыхание дракона 12х70)"
	)

/obj/item/ammo_box/shotgun/ion
	name = "ammunition box (ion shells)"
	desc = "Коробка, содержащая патроны \"Ионная пуля\" калибра 12х70."
	icon_state = "ionbox"
	ammo_type = /obj/item/ammo_casing/shotgun/ion

/obj/item/ammo_box/shotgun/ion/get_ru_names()
	return list(
		NOMINATIVE = "коробка патронов (ионная пуля 12х70)",
		GENITIVE = "коробки патронов (ионная пуля 12х70)",
		DATIVE = "коробке патронов (ионная пуля 12х70)",
		ACCUSATIVE = "коробку патронов (ионная пуля 12х70)",
		INSTRUMENTAL = "коробкой патронов (ионная пуля 12х70)",
		PREPOSITIONAL = "коробке патронов (ионная пуля 12х70)"
	)

/obj/item/ammo_box/shotgun/laserslug
	name = "ammunition box (laser slugs)"
	desc = "Коробка, содержащая патроны \"Лазерная пуля\" калибра 12х70."
	icon_state = "laserslugbox"
	ammo_type = /obj/item/ammo_casing/shotgun/laserslug

/obj/item/ammo_box/shotgun/laserslug/get_ru_names()
	return list(
		NOMINATIVE = "коробка патронов (лазерная пуля 12х70)",
		GENITIVE = "коробки патронов (лазерная пуля 12х70)",
		DATIVE = "коробке патронов (лазерная пуля 12х70)",
		ACCUSATIVE = "коробку патронов (лазерная пуля 12х70)",
		INSTRUMENTAL = "коробкой патронов (лазерная пуля 12х70)",
		PREPOSITIONAL = "коробке патронов (лазерная пуля 12х70)"
	)

/obj/item/ammo_box/shotgun/lasershot
	name = "ammunition box (laser shots)"
	icon_state = "laserslugbox"
	desc = "Коробка, содержащая патроны \"Лазерная картечь\" калибра 12х70."
	ammo_type = /obj/item/ammo_casing/shotgun/lasershot

/obj/item/ammo_box/shotgun/lasershot/get_ru_names()
	return list(
		NOMINATIVE = "коробка патронов (лазерная картечь 12х70)",
		GENITIVE = "коробки патронов (лазерная картечь 12х70)",
		DATIVE = "коробке патронов (лазерная картечь 12х70)",
		ACCUSATIVE = "коробку патронов (лазерная картечь 12х70)",
		INSTRUMENTAL = "коробкой патронов (лазерная картечь 12х70)",
		PREPOSITIONAL = "коробке патронов (лазерная картечь 12х70)"
	)

/obj/item/ammo_box/shotgun/bioterror
	name = "ammunition box (bioterror shells)"
	desc = "Коробка, содержащая патроны \"Биотеррор\" калибра 12х70."
	icon_state = "bioterrorbox"
	ammo_type = /obj/item/ammo_casing/shotgun/bioterror

/obj/item/ammo_box/shotgun/bioterror/get_ru_names()
	return list(
		NOMINATIVE = "коробка патронов (биотеррор 12х70)",
		GENITIVE = "коробки патронов (биотеррор 12х70)",
		DATIVE = "коробке патронов (биотеррор 12х70)",
		ACCUSATIVE = "коробку патронов (биотеррор 12х70)",
		INSTRUMENTAL = "коробкой патронов (биотеррор 12х70)",
		PREPOSITIONAL = "коробке патронов (биотеррор 12х70)"
	)

/obj/item/ammo_box/shotgun/tranquilizer
	name = "ammunition box (tranquilizer darts)"
	desc = "Коробка, содержащая патроны с транквилизатором калибра 12х70."
	icon_state = "tranquilizerbox"
	ammo_type = /obj/item/ammo_casing/shotgun/tranquilizer

/obj/item/ammo_box/shotgun/tranquilizer/get_ru_names()
	return list(
		NOMINATIVE = "коробка патронов (транквилизатор 12х70)",
		GENITIVE = "коробки патронов (транквилизатор 12х70)",
		DATIVE = "коробке патронов (транквилизатор 12х70)",
		ACCUSATIVE = "коробку патронов (транквилизатор 12х70)",
		INSTRUMENTAL = "коробкой патронов (транквилизатор 12х70)",
		PREPOSITIONAL = "коробке патронов (транквилизатор 12х70)"
	)

/obj/item/ammo_box/shotgun/flechette
	name = "ammunition box (flechette)"
	desc = "Коробка, содержащая патроны \"Флешетта\" калибра 12х70."
	icon_state = "flechettebox"
	ammo_type = /obj/item/ammo_casing/shotgun/flechette

/obj/item/ammo_box/shotgun/flechette/get_ru_names()
	return list(
		NOMINATIVE = "коробка патронов (флешетта 12х70)",
		GENITIVE = "коробки патронов (флешетта 12х70)",
		DATIVE = "коробке патронов (флешетта 12х70)",
		ACCUSATIVE = "коробку патронов (флешетта 12х70)",
		INSTRUMENTAL = "коробкой патронов (флешетта 12х70)",
		PREPOSITIONAL = "коробке патронов (флешетта 12х70)"
	)

/obj/item/ammo_box/shotgun/improvised
	name = "ammunition box (improvised shells)"
	desc = "Коробка, содержащая самодельные патроны калибра 12х70."
	icon = 'icons/obj/storage.dmi'
	icon_state = "largebox"
	ammo_type = /obj/item/ammo_casing/shotgun/improvised

/obj/item/ammo_box/shotgun/improvised/get_ru_names()
	return list(
		NOMINATIVE = "коробка патронов (самодельная картечь 12х70)",
		GENITIVE = "коробки патронов (самодельная картечь 12х70)",
		DATIVE = "коробке патронов (самодельная картечь 12х70)",
		ACCUSATIVE = "коробку патронов (самодельная картечь 12х70)",
		INSTRUMENTAL = "коробкой патронов (самодельная картечь 12х70)",
		PREPOSITIONAL = "коробке патронов (самодельная картечь 12х70)"
	)

/obj/item/ammo_box/shotgun/improvised/overload
	name = "ammunition box (overload shells)"
	desc = "Коробка, содержащая самодельыне патроны повышенной мощности калибра 12х70."
	ammo_type = /obj/item/ammo_casing/shotgun/improvised/overload

/obj/item/ammo_box/shotgun/improvised/overload/get_ru_names()
	return list(
		NOMINATIVE = "коробка патронов (самодельная картечь повышенной мощности 12х70)",
		GENITIVE = "коробки патронов (самодельная картечь повышенной мощности 12х70)",
		DATIVE = "коробке патронов (самодельная картечь повышенной мощности 12х70)",
		ACCUSATIVE = "коробку патронов (самодельная картечь повышенной мощности 12х70)",
		INSTRUMENTAL = "коробкой патронов (самодельная картечь повышенной мощности 12х70)",
		PREPOSITIONAL = "коробке патронов (самодельная картечь повышенной мощности 12х70)"
	)


// AUTOMATIC
/obj/item/ammo_box/c9mm
	name = "ammo box (9mm)"
	desc = "Коробка, содержащая патроны калибра 9 мм."
	icon_state = "9mmbox"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/c9mm
	max_ammo = 30

/obj/item/ammo_box/c9mm/get_ru_names()
	return list(
		NOMINATIVE = "коробка патронов (9 мм)",
		GENITIVE = "коробки патронов (9 мм)",
		DATIVE = "коробке патронов (9 мм)",
		ACCUSATIVE = "коробку патронов (9 мм)",
		INSTRUMENTAL = "коробкой патронов (9 мм)",
		PREPOSITIONAL = "коробке патронов (9 мм)"
	)

/obj/item/ammo_box/rubber9mm
	name = "ammo box (rubber 9mm)"
	desc = "Коробка, содержащая нелетальные патроны калибра 9 мм."
	icon_state = "9mmbox"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/rubber9mm
	max_ammo = 30

/obj/item/ammo_box/rubber9mm/get_ru_names()
	return list(
		NOMINATIVE = "коробка патронов (нелетальный 9 мм)",
		GENITIVE = "коробки патронов (нелетальный 9 мм)",
		DATIVE = "коробке патронов (нелетальный 9 мм)",
		ACCUSATIVE = "коробку патронов (нелетальный 9 мм)",
		INSTRUMENTAL = "коробкой патронов (нелетальный 9 мм)",
		PREPOSITIONAL = "коробке патронов (нелетальный 9 мм)"
	)

/obj/item/ammo_box/c10mm
	name = "ammo box (10mm)"
	desc = "Коробка, содержащая патроны калибра 10 мм."
	icon_state = "10mmbox"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/c10mm
	max_ammo = 30

/obj/item/ammo_box/c10mm/get_ru_names()
	return list(
		NOMINATIVE = "коробка патронов (10 мм)",
		GENITIVE = "коробки патронов (10 мм)",
		DATIVE = "коробке патронов (10 мм)",
		ACCUSATIVE = "коробку патронов (10 мм)",
		INSTRUMENTAL = "коробкой патронов (10 мм)",
		PREPOSITIONAL = "коробке патронов (10 мм)"
	)


/obj/item/ammo_box/fortynr
	name = "ammo box .40 S&W"
	desc = "Коробка, содержащая патроны  .40 калибра S&W."
	icon_state = "40n&rbox"
	ammo_type = /obj/item/ammo_casing/fortynr
	max_ammo = 40

/obj/item/ammo_box/fortynr/get_ru_names()
	return list(
		NOMINATIVE = "коробка патронов (.40 S&W)",
		GENITIVE = "коробки патронов (.40 S&W)",
		DATIVE = "коробке патронов (.40 S&W)",
		ACCUSATIVE = "коробку патронов (.40 S&W)",
		INSTRUMENTAL = "коробкой патронов (.40 S&W)",
		PREPOSITIONAL = "коробке патронов (.40 S&W)"
	)

/obj/item/ammo_box/c45
	name = "ammo box (.45)"
	desc = "Коробка, содержащая патроны .45 калибра."
	icon_state = "45box"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/c45
	max_ammo = 20

/obj/item/ammo_box/c45/get_ru_names()
	return list(
		NOMINATIVE = "коробка патронов (.45)",
		GENITIVE = "коробки патронов (.45)",
		DATIVE = "коробке патронов (.45)",
		ACCUSATIVE = "коробку патронов (.45)",
		INSTRUMENTAL = "коробкой патронов (.45)",
		PREPOSITIONAL = "коробке патронов (.45)"
	)

/obj/item/ammo_box/c45/ext
	name = "ammo box extended (.45)"
	desc = "Большая коробка, содержащая патроны .45 калибра."
	icon_state = "ammobox_45"
	max_ammo = 40

/obj/item/ammo_box/c45/ext/get_ru_names()
	return list(
		NOMINATIVE = "большая коробка патронов (.45)",
		GENITIVE = "большой коробки патронов (.45)",
		DATIVE = "большой коробке патронов (.45)",
		ACCUSATIVE = "большую коробку патронов (.45)",
		INSTRUMENTAL = "большой коробкой патронов (.45)",
		PREPOSITIONAL = "большой коробке патронов (.45)"
	)

/obj/item/ammo_box/rubber45
	name = "ammo box (.45 rubber)"
	desc = "Коробка, содержащая нелетальные патроны .45 калибра."
	icon_state = "45box-r"
	ammo_type = /obj/item/ammo_casing/rubber45
	max_ammo = 16

/obj/item/ammo_box/rubber45/get_ru_names()
	return list(
		NOMINATIVE = "коробка патронов (нелетальный .45)",
		GENITIVE = "коробки патронов (нелетальный .45)",
		DATIVE = "коробке патронов (нелетальный .45)",
		ACCUSATIVE = "коробку патронов (нелетальный .45)",
		INSTRUMENTAL = "коробкой патронов (нелетальный .45)",
		PREPOSITIONAL = "коробке патронов (нелетальный .45)"
	)

/obj/item/ammo_box/rubber45/ext
	name = "ammo box extended(.45 rubber)"
	desc = "Большая коробка, содержащая нелетальные патроны .45 калибра."
	icon_state = "ammobox_45"
	max_ammo = 40

/obj/item/ammo_box/rubber45/ext/get_ru_names()
	return list(
		NOMINATIVE = "большая коробка патронов (нелетальный .45)",
		GENITIVE = "большой коробки патронов (нелетальный .45)",
		DATIVE = "большой коробке патронов (нелетальный .45)",
		ACCUSATIVE = "большую коробку патронов (нелетальный .45)",
		INSTRUMENTAL = "большой коробкой патронов (нелетальный .45)",
		PREPOSITIONAL = "большой коробке патронов (нелетальный .45)"
	)

/obj/item/ammo_box/a556
	name = "ammo box (5.56 mm)"
	desc = "Коробка, содержащая патроны калибра 5,56 мм."
	icon_state = "ammobox_556"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/a556
	max_ammo = 60

/obj/item/ammo_box/a556/get_ru_names()
	return list(
		NOMINATIVE = "коробка патронов (5,56 мм)",
		GENITIVE = "коробки патронов (5,56 мм)",
		DATIVE = "коробке патронов (5,56 мм)",
		ACCUSATIVE = "коробку патронов (5,56 мм)",
		INSTRUMENTAL = "коробкой патронов (5,56 мм)",
		PREPOSITIONAL = "коробке патронов (5,56 мм)"
	)

/obj/item/ammo_box/ak814
	name = "AK ammo box (5.45x39mm)"
	desc = "Коробка, содержащая патроны калибра 5,45х39 мм."
	icon_state = "ammobox_AK"
	origin_tech = "combat=5;syndicate=1"
	ammo_type = /obj/item/ammo_casing/a545
	max_ammo = 60

/obj/item/ammo_box/ak814/get_ru_names()
	return list(
		NOMINATIVE = "коробка патронов (5,45х39 мм)",
		GENITIVE = "коробки патронов (5,45х39 мм)",
		DATIVE = "коробке патронов (5,45х39 мм)",
		ACCUSATIVE = "коробку патронов (5,45х39 мм)",
		INSTRUMENTAL = "коробкой патронов (5,45х39 мм)",
		PREPOSITIONAL = "коробке патронов (5,45х39 мм)"
	)

/obj/item/ammo_box/c46x30mm
	name = "ammo box (4.6x30mm)"
	desc = "Коробка, содержащая патроны калибра 4,6x30 мм."
	icon_state = "4630mmbox"
	ammo_type = /obj/item/ammo_casing/c46x30mm
	max_ammo = 40

/obj/item/ammo_box/c46x30mm/get_ru_names()
	return list(
		NOMINATIVE = "коробка патронов (4,6x30 мм)",
		GENITIVE = "коробки патронов (4,6x30 мм)",
		DATIVE = "коробке патронов (4,6x30 мм)",
		ACCUSATIVE = "коробку патронов (4,6x30 мм)",
		INSTRUMENTAL = "коробкой патронов (4,6x30 мм)",
		PREPOSITIONAL = "коробке патронов (4,6x30 мм)"
	)

/obj/item/ammo_box/ap46x30mm
	name = "ammo box (Armour Piercing 4.6x30mm)"
	desc = "Коробка, содержащая бронебойные патроны калибра 4,6x30 мм."
	icon_state = "4630mmbox"
	ammo_type = /obj/item/ammo_casing/c46x30mm/ap
	max_ammo = 40

/obj/item/ammo_box/ap46x30mm/get_ru_names()
	return list(
		NOMINATIVE = "коробка патронов (бронебойные 4,6x30 мм)",
		GENITIVE = "коробки патронов (бронебойные 4,6x30 мм)",
		DATIVE = "коробке патронов (бронебойные 4,6x30 мм)",
		ACCUSATIVE = "коробку патронов (бронебойные 4,6x30 мм)",
		INSTRUMENTAL = "коробкой патронов (бронебойные 4,6x30 мм)",
		PREPOSITIONAL = "коробке патронов (бронебойные 4,6x30 мм)"
	)

/obj/item/ammo_box/tox46x30mm
	name = "ammo box (Toxin Tipped 4.6x30mm)"
	desc = "Коробка, содержащая отравляющие патроны калибра 4,6x30 мм."
	icon_state = "4630mmbox"
	ammo_type = /obj/item/ammo_casing/c46x30mm/tox
	max_ammo = 40

/obj/item/ammo_box/tox46x30mm/get_ru_names()
	return list(
		NOMINATIVE = "коробка патронов (отравляющие 4,6x30 мм)",
		GENITIVE = "коробки патронов (отравляющие 4,6x30 мм)",
		DATIVE = "коробке патронов (отравляющие 4,6x30 мм)",
		ACCUSATIVE = "коробку патронов (отравляющие 4,6x30 мм)",
		INSTRUMENTAL = "коробкой патронов (отравляющие 4,6x30 мм)",
		PREPOSITIONAL = "коробке патронов (отравляющие 4,6x30 мм)"
	)

/obj/item/ammo_box/inc46x30mm
	name = "ammo box (Incendiary 4.6x30mm)"
	desc = "Коробка, содержащая зажигательные патроны калибра 4,6x30 мм."
	icon_state = "4630mmbox"
	ammo_type = /obj/item/ammo_casing/c46x30mm/inc
	max_ammo = 40

/obj/item/ammo_box/inc46x30mm/get_ru_names()
	return list(
		NOMINATIVE = "коробка патронов (зажигательные 4,6x30 мм)",
		GENITIVE = "коробки патронов (зажигательные 4,6x30 мм)",
		DATIVE = "коробке патронов (зажигательные 4,6x30 мм)",
		ACCUSATIVE = "коробку патронов (зажигательные 4,6x30 мм)",
		INSTRUMENTAL = "коробкой патронов (зажигательные 4,6x30 мм)",
		PREPOSITIONAL = "коробке патронов (зажигательные 4,6x30 мм)"
	)

/obj/item/ammo_box/c9mmte
	name = "ammo box (9mm TE)"
	desc = "Коробка, содержащая нелетальные патроны калибра 9 мм TE."
	icon_state = "9mmTEbox"
	ammo_type = /obj/item/ammo_casing/c9mmte
	max_ammo = 60

/obj/item/ammo_box/c9mmte/get_ru_names()
	return list(
		NOMINATIVE = "коробка патронов (9 мм TE)",
		GENITIVE = "коробки патронов (9 мм TE)",
		DATIVE = "коробке патронов (9 мм TE)",
		ACCUSATIVE = "коробку патронов (9 мм TE)",
		INSTRUMENTAL = "коробкой патронов (9 мм TE)",
		PREPOSITIONAL = "коробке патронов (9 мм TE)"
	)

/obj/item/ammo_box/m50
	name = "ammo box (.50AE)"
	icon_state = "ammobox_50AE"
	ammo_type = /obj/item/ammo_casing/a50
	max_ammo = 21

/obj/item/ammo_box/m50/get_ru_names()
	return list(
		NOMINATIVE = "коробка патронов (.50AE)",
		GENITIVE = "коробки патронов (.50AE)",
		DATIVE = "коробке патронов (.50AE)",
		ACCUSATIVE = "коробку патронов (.50AE)",
		INSTRUMENTAL = "коробкой патронов (.50AE)",
		PREPOSITIONAL = "коробке патронов (.50AE)"
	)


// MISC
/obj/item/ammo_box/a40mm
	name = "ammo box (40mm grenades)"
	desc = "Коробка, содержащая гранаты калибра 40 мм."
	icon_state = "40mm"
	ammo_type = /obj/item/ammo_casing/a40mm
	max_ammo = 4
	multiple_sprites = 1

/obj/item/ammo_box/a40mm/get_ru_names()
	return list(
		NOMINATIVE = "коробка гранат (40 мм)",
		GENITIVE = "коробки патронов (40 мм)",
		DATIVE = "коробке патронов (40 мм)",
		ACCUSATIVE = "коробку патронов (40 мм)",
		INSTRUMENTAL = "коробкой патронов (40 мм)",
		PREPOSITIONAL = "коробке патронов (40 мм)"
	)

/obj/item/ammo_box/laserammobox
	name = "laser ammo box"
	desc = "Коробка, содержащая лазерные патроны."
	icon_state = "laserbox"
	ammo_type = /obj/item/ammo_casing/laser
	max_ammo = 40

/obj/item/ammo_box/laserammobox/get_ru_names()
	return list(
		NOMINATIVE = "коробка лазреных патронов",
		GENITIVE = "коробки лазреных патронов",
		DATIVE = "коробке лазреных патронов",
		ACCUSATIVE = "коробку лазреных патронов",
		INSTRUMENTAL = "коробкой лазреных патронов",
		PREPOSITIONAL = "коробке лазреных патронов"
	)


/obj/item/ammo_box/foambox
	name = "ammo box (Foam Darts)"
	desc = "Коробка, содержащая пенные патроны."
	icon = 'icons/obj/weapons/toy.dmi'
	icon_state = "foambox"
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart
	max_ammo = 40

/obj/item/ammo_box/foambox/get_ru_names()
	return list(
		NOMINATIVE = "коробка с пенными патронами",
		GENITIVE = "коробки с пенными патронами",
		DATIVE = "коробке с пенными патронами",
		ACCUSATIVE = "коробку с пенными патронами",
		INSTRUMENTAL = "коробкой с пенными патронами",
		PREPOSITIONAL = "коробке с пенными патронами"
	)

/obj/item/ammo_box/foambox/riot
	icon_state = "foambox_riot"
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart/riot

/obj/item/ammo_box/foambox/sniper
	name = "ammo box (Foam Sniper Darts)"
	desc = "Коробка, содержащая снайперские пенные патроны."
	icon = 'icons/obj/weapons/toy.dmi'
	icon_state = "foambox_sniper"
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart/sniper
	max_ammo = 40

/obj/item/ammo_box/foambox/sniper/get_ru_names()
	return list(
		NOMINATIVE = "коробка со снайперскими пенными патронами",
		GENITIVE = "коробки со снайперскими пенными патронами",
		DATIVE = "коробке со снайперскими пенными патронами",
		ACCUSATIVE = "коробку со снайперскими пенными патронами",
		INSTRUMENTAL = "коробкой со снайперскими пенными патронами",
		PREPOSITIONAL = "коробке со снайперскими пенными патронами"
	)

/obj/item/ammo_box/foambox/sniper/riot
	icon_state = "foambox_sniper_riot"
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart/sniper/riot

/obj/item/ammo_box/sniper_rounds_compact
	name = "Box of compact sniper rounds (.50L COMP)"
	desc = "Коробка, содержащая компактные снайперские патроны .50L калибра COMP."
	icon_state = "ammobox_sniperCOMP"
	origin_tech = "combat=5"
	ammo_type = /obj/item/ammo_casing/compact
	max_ammo = 20

/obj/item/ammo_box/sniper_rounds_compact/get_ru_names()
	return list(
		NOMINATIVE = "коробка гранат (.50L COMP)",
		GENITIVE = "коробки патронов (.50L COMP)",
		DATIVE = "коробке патронов (.50L COMP)",
		ACCUSATIVE = "коробку патронов (.50L COMP)",
		INSTRUMENTAL = "коробкой патронов (.50L COMP)",
		PREPOSITIONAL = "коробке патронов (.50L COMP)"
	)

/obj/item/ammo_box/sniper_rounds_penetrator
	name = "Box of penetrator sniper rounds (.50 PE)"
	desc = "Коробка, содержащая бронебойные патроны .50 калибра."
	icon_state = "ammobox_sniperPE"
	origin_tech = "combat=6"
	ammo_type = /obj/item/ammo_casing/penetrator
	max_ammo = 20

/obj/item/ammo_box/sniper_rounds_penetrator/get_ru_names()
	return list(
		NOMINATIVE = "коробка гранат (бронебойныые .50)",
		GENITIVE = "коробки патронов (бронебойныые .50)",
		DATIVE = "коробке патронов (бронебойныые .50)",
		ACCUSATIVE = "коробку патронов (бронебойныые .50)",
		INSTRUMENTAL = "коробкой патронов (бронебойныые .50)",
		PREPOSITIONAL = "коробке патронов (бронебойныые .50)"
	)

/obj/item/ammo_box/m10mm
	name = "ammo box (10mm)"
	desc = "Коробка, содержащая патроны калибра 10 мм."
	icon_state = "ammobox_10AP"
	ammo_type = /obj/item/ammo_casing/c10mm
	max_ammo = 60

/obj/item/ammo_box/m10mm/get_ru_names()
	return list(
		NOMINATIVE = "коробка патронов (10 мм)",
		GENITIVE = "коробки патронов (10 мм)",
		DATIVE = "коробке патронов (10 мм)",
		ACCUSATIVE = "коробку патронов (10 мм)",
		INSTRUMENTAL = "коробкой патронов (10 мм)",
		PREPOSITIONAL = "коробке патронов (10 мм)"
	)

/obj/item/ammo_box/m10mm/ap
	name = "ammo box (10mm AP)"
	desc = "Коробка, содержащая бронебойные патроны калибра 10 мм."
	ammo_type = /obj/item/ammo_casing/c10mm/ap

/obj/item/ammo_box/m10mm/ap/get_ru_names()
	return list(
		NOMINATIVE = "коробка патронов (бронебойные 10 мм)",
		GENITIVE = "коробки патронов (бронебойные 10 мм)",
		DATIVE = "коробке патронов (бронебойные 10 мм)",
		ACCUSATIVE = "коробку патронов (бронебойные 10 мм)",
		INSTRUMENTAL = "коробкой патронов (бронебойные 10 мм)",
		PREPOSITIONAL = "коробке патронов (бронебойные 10 мм)"
	)

/obj/item/ammo_box/m10mm/hp
	name = "ammo box (10mm HP)"
	desc = "Коробка, содержащая экспансивные патроны калибра 10 мм."
	icon_state = "ammobox_10HP"
	ammo_type = /obj/item/ammo_casing/c10mm/hp

/obj/item/ammo_box/m10mm/hp/get_ru_names()
	return list(
		NOMINATIVE = "коробка патронов (экспансивные 10 мм)",
		GENITIVE = "коробки патронов (экспансивные 10 мм)",
		DATIVE = "коробке патронов (экспансивные 10 мм)",
		ACCUSATIVE = "коробку патронов (экспансивные 10 мм)",
		INSTRUMENTAL = "коробкой патронов (экспансивные 10 мм)",
		PREPOSITIONAL = "коробке патронов (экспансивные 10 мм)"
	)

/obj/item/ammo_box/m10mm/fire
	name = "ammo box (10mm incendiary)"
	desc = "Коробка, содержащая зажигательные патроны калибра 10 мм."
	icon_state = "ammobox_10incendiary"
	ammo_type = /obj/item/ammo_casing/c10mm/fire

/obj/item/ammo_box/m10mm/fire/get_ru_names()
	return list(
		NOMINATIVE = "коробка патронов (зажигательные 10 мм)",
		GENITIVE = "коробки патронов (зажигательные 10 мм)",
		DATIVE = "коробке патронов (зажигательные 10 мм)",
		ACCUSATIVE = "коробку патронов (зажигательные 10 мм)",
		INSTRUMENTAL = "коробкой патронов (зажигательные 10 мм)",
		PREPOSITIONAL = "коробке патронов (зажигательные 10 мм)"
	)

/obj/item/ammo_box/specter
	origin_tech = "combat=2"
	max_ammo = 30

/obj/item/ammo_box/specter/laser
	name = "ammo box (Specter laser)"
	desc = "Коробка, содержащая 30 лазерных патронов для пистолета \"Спектр\"."
	icon_state = "speclaser"
	ammo_type = /obj/item/ammo_casing/specter/laser

/obj/item/ammo_box/specter/laser/get_ru_names()
	return list(
		NOMINATIVE = "коробка патронов (Спектр лазерные)",
		GENITIVE = "коробка патронов (Спектр лазерные)",
		DATIVE = "коробка патронов (Спектр лазерные)",
		ACCUSATIVE = "коробка патронов (Спектр лазерные)",
		INSTRUMENTAL = "коробка патронов (Спектр лазерные)",
		PREPOSITIONAL = "коробка патронов (Спектр лазерные)"
	)


/obj/item/ammo_box/specter/disabler
	name = "ammo box (Specter disabler)"
	desc = "Коробка, содержащая 30 парализующих патронов для пистолета \"Спектр\"."
	icon_state = "specstamina"
	ammo_type = /obj/item/ammo_casing/specter/disable

/obj/item/ammo_box/specter/disabler/get_ru_names()
	return list(
		NOMINATIVE = "коробка патронов (Спектр парализующие)",
		GENITIVE = "коробка патронов (Спектр парализующие)",
		DATIVE = "коробке патронов (Спектр парализующие)",
		ACCUSATIVE = "коробку патронов (Спектр парализующие)",
		INSTRUMENTAL = "коробкой патронов (Спектр парализующие)",
		PREPOSITIONAL = "коробке патронов (Спектр парализующие)"
	)

/**
 * SPEEDLOADER
 */

// REVOLVER
/obj/item/ammo_box/speedloader/a357
	name = "speed loader (.357)"
	desc = "Устройство для быстрой зарядки револьверов патронами .357 калибра."
	materials = list(MAT_METAL = 2000)
	ammo_type = /obj/item/ammo_casing/a357
	max_ammo = 7
	caliber = ".357"
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
		PREPOSITIONAL = "устройстве быстрой зарядки (.357)"
	)

/obj/item/ammo_box/speedloader/improvised
	name = "makeshift speedloader"
	desc = "Самодельное устройство для быстрой зарядки револьверов патронами .257 калибра."
	desc = "Speedloader made from shit and sticks."
	ammo_type = null
	icon_state = "makeshift_speedloader"
	max_ammo = 4
	caliber = ".257"

/obj/item/ammo_box/speedloader/improvised/get_ru_names()
	return list(
		NOMINATIVE = "самодельное устройство быстрой зарядки (.257)",
		GENITIVE = "самодельного устройства быстрой зарядки (.257)",
		DATIVE = "самодельному устройству быстрой зарядки (.257)",
		ACCUSATIVE = "самодельное устройство быстрой зарядки (.257)",
		INSTRUMENTAL = "самодельным устройством быстрой зарядки (.257)",
		PREPOSITIONAL = "самодельном устройстве быстрой зарядки (.257)"
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
	caliber = ".38"
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
		PREPOSITIONAL = "устройстве быстрой зарядки (.38)"
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
		PREPOSITIONAL = "устройстве быстрой зарядки (экспансивные .38)"
	)

/obj/item/ammo_box/nagant
	name = "ammo box (7.62x38mm nagant)"
	desc = "Коробка, содержащая патроны калибра 7,62х38 мм \"Наган\"."
	icon_state = "ammobox_nagant"
	ammo_type = /obj/item/ammo_casing/n762
	max_ammo = 20

/obj/item/ammo_box/nagant/get_ru_names()
	return list(
		NOMINATIVE = "коробка патронов (7,62х38 мм)",
		GENITIVE = "коробки патронов (7,62х38 мм)",
		DATIVE = "коробке патронов (7,62х38 мм)",
		ACCUSATIVE = "коробку патронов (7,62х38 мм)",
		INSTRUMENTAL = "коробкой патронов (7,62х38 мм)",
		PREPOSITIONAL = "коробке патронов (7,62х38 мм)"
	)

// SHOTGUN
/obj/item/ammo_box/speedloader/shotgun
	name = "shotgun speedloader"
	desc = "Устройство для быстрой зарядки дробовиков. Вмещает 7 патронов калибра 12х70."
	icon_state = "shotgunloader"
	icon_prefix = "shotgunloader"
	origin_tech = "combat=2"
	caliber = ".12"
	max_ammo = 7
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
		PREPOSITIONAL = "устройстве быстрой зарядки дробовиков"
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

// MISC
/obj/item/ammo_box/speedloader/caps
	name = "speed loader (caps)"
	desc = "Устройство для быстрой зарядки револьверов холостыми патронами .357 калибра."
	icon_state = "357"
	ammo_type = /obj/item/ammo_casing/cap
	max_ammo = 7
	multiple_sprites = 1

/obj/item/ammo_box/speedloader/caps/get_ru_names()
	return list(
		NOMINATIVE = "устройство быстрой зарядки (холостые .357)",
		GENITIVE = "устройства быстрой зарядки (холостые .357)",
		DATIVE = "устройству быстрой зарядки (холостые .357)",
		ACCUSATIVE = "устройство быстрой зарядки (холостые .357)",
		INSTRUMENTAL = "устройством быстрой зарядки (холостые .357)",
		PREPOSITIONAL = "устройстве быстрой зарядки (холостые .357)"
	)

/**
 * STRIPPER CLIP
 */

/obj/item/ammo_box/speedloader/a762
	name = "stripper clip (7.62mm)"
	desc = "Устройство для быстрой зарядки револьверов холостыми патронами калибра 7,62х54 мм. Вмещает 5 патронов."
	icon_state = "762"
	caliber = "7.62x54mm"
	ammo_type = /obj/item/ammo_casing/a762
	max_ammo = 5
	multiple_sprites = 1

/obj/item/ammo_box/speedloader/a762/get_ru_names()
	return list(
		NOMINATIVE = "обойма (7,62х54 мм)",
		GENITIVE = "обойма (7,62х54 мм)",
		DATIVE = "обойму (7,62х54 мм)",
		ACCUSATIVE = "обойма (7,62х54 мм)",
		INSTRUMENTAL = "обоймой (7,62х54 мм)",
		PREPOSITIONAL = "обойме (7,62х54 мм)"
	)

/obj/item/ammo_box/a762
	name = "ammo box (7.62x54mm mosin)"
	desc = "Коробка, содержащая патроны калибра 7,62x54 мм."
	icon_state = "ammobox_mosin"
	ammo_type = /obj/item/ammo_casing/a762
	max_ammo = 40

/obj/item/ammo_box/a762/get_ru_names()
	return list(
		NOMINATIVE = "коробка патронов (7,62x54 мм)",
		GENITIVE = "коробки патронов (7,62x54 мм)",
		DATIVE = "коробке патронов (7,62x54 мм)",
		ACCUSATIVE = "коробку патронов (7,62x54 мм)",
		INSTRUMENTAL = "коробкой патронов (7,62x54 мм)",
		PREPOSITIONAL = "коробке патронов (7,62x54 мм)"
	)
