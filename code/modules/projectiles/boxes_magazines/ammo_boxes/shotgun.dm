// MARK: Slug
/obj/item/ammo_box/shotgun
	name = "ammunition box (Slug)"
	desc = "Коробка, содержащая пулевые патроны калибра 12х70."
	icon_state = "slugbox"
	ammo_type = /obj/item/ammo_casing/shotgun
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/ammo_box/shotgun/get_ru_names()
	return list(
		NOMINATIVE = "коробка патронов (пулевой 12х70)",
		GENITIVE = "коробки ружейных патронов (пулевой 12х70)",
		DATIVE = "коробке ружейных патронов (пулевой 12х70)",
		ACCUSATIVE = "коробку ружейных патронов (пулевой 12х70)",
		INSTRUMENTAL = "коробкой ружейных патронов (пулевой 12х70)",
		PREPOSITIONAL = "коробке ружейных патронов (пулевой 12х70)",
	)

// MARK: Buckshot
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
		PREPOSITIONAL = "коробке ружейных патронов (картечь 12х70)",
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
		PREPOSITIONAL = "коробке патронов (шрапнель с глушащим токсином 12х70)",
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
		PREPOSITIONAL = "коробке патронов (магнум картечь 12х70)",
	)

// MARK: Rubbershot
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
		PREPOSITIONAL = "коробке патронов (резиновая картечь 12х70)",
	)

// MARK: Dart
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
		PREPOSITIONAL = "коробке патронов (патрон-шприц 12х70)",
	)

// MARK: Beanbag slug
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
		PREPOSITIONAL = "коробке патронов (резиновая пуля 12х70)",
	)

/obj/item/ammo_box/shotgun/beanbag/fake
	ammo_type = /obj/item/ammo_casing/shotgun/beanbag/fake

// MARK: Taser slug
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
		PREPOSITIONAL = "коробке патронов (электрошок 12х70)",
	)

// MARK: Meteor slug
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
		PREPOSITIONAL = "коробке патронов (штурмовые 12х70)",
	)

// MARK: Pulse slug
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
		PREPOSITIONAL = "коробке патронов (импульсная пуля 12х70)",
	)

// MARK: Incendiary
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
		PREPOSITIONAL = "коробке патронов (зажигательные 12х70)",
	)

// MARK: Frag-12
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
		PREPOSITIONAL = "коробке патронов (разрывная пуля 12х70)",
	)

// MARK: Dragon's Breath
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
		PREPOSITIONAL = "коробке патронов (дыхание дракона 12х70)",
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
		PREPOSITIONAL = "коробке патронов (напалмовое дыхание дракона 12х70)",
	)

// MARK: Ion slug
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
		PREPOSITIONAL = "коробке патронов (ионная пуля 12х70)",
	)

// MARK: Laser slug
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
		PREPOSITIONAL = "коробке патронов (лазерная пуля 12х70)",
	)

// MARK: Lasershot
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
		PREPOSITIONAL = "коробке патронов (лазерная картечь 12х70)",
	)

// MARK: Bioterror
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
		PREPOSITIONAL = "коробке патронов (биотеррор 12х70)",
	)

// MARK: Tranquilizer
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
		PREPOSITIONAL = "коробке патронов (транквилизатор 12х70)",
	)

// MARK: Flechette
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
		PREPOSITIONAL = "коробке патронов (флешетта 12х70)",
	)

// MARK: Improvised
/obj/item/ammo_box/shotgun/improvised
	name = "ammunition box (improvised shells)"
	desc = "Коробка, содержащая самодельные патроны калибра 12х70."
	icon = 'icons/obj/storage/boxes.dmi'
	icon_state = "largebox"
	ammo_type = /obj/item/ammo_casing/shotgun/improvised

/obj/item/ammo_box/shotgun/improvised/get_ru_names()
	return list(
		NOMINATIVE = "коробка патронов (самодельная картечь 12х70)",
		GENITIVE = "коробки патронов (самодельная картечь 12х70)",
		DATIVE = "коробке патронов (самодельная картечь 12х70)",
		ACCUSATIVE = "коробку патронов (самодельная картечь 12х70)",
		INSTRUMENTAL = "коробкой патронов (самодельная картечь 12х70)",
		PREPOSITIONAL = "коробке патронов (самодельная картечь 12х70)",
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
		PREPOSITIONAL = "коробке патронов (самодельная картечь повышенной мощности 12х70)",
	)
