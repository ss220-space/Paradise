/**
 * AMMO BOX
 */

// REVOLVER
/obj/item/ammo_box/a357
	name = "ammo box (.357)"
	desc = "Коробка патронов калибра .357 \"Магнум\". В коробку вмещается 20 патронов."
	ru_names = list(
		NOMINATIVE = "коробка патронов (.357)",
		GENITIVE = "коробки патронов (.357)",
		DATIVE = "коробке патронов (.357)",
		ACCUSATIVE = "коробку патронов (.357)",
		INSTRUMENTAL = "коробкой патронов (.357)",
		PREPOSITIONAL = "коробке патронов (.357)"
	)
	icon_state = "357OLD"  // see previous entry for explanation of these vars
	ammo_type = /obj/item/ammo_casing/a357
	max_ammo = 20


/obj/item/ammo_box/a357/update_icon_state()
	icon_state = "[initial(icon_state)]-[round(length(stored_ammo) / 3)]"


/obj/item/ammo_box/n762
	name = "ammo box (7.62x38mm)"
	desc = "Коробка патронов калибра 7.62x38mm. В коробку вмещается 14 патронов."
	ru_names = list(
		NOMINATIVE = "коробка патронов (7.62x38mm)",
		GENITIVE = "коробки патронов (7.62x38mm)",
		DATIVE = "коробке патронов (7.62x38mm)",
		ACCUSATIVE = "коробку патронов (7.62x38mm)",
		INSTRUMENTAL = "коробкой патронов (7.62x38mm)",
		PREPOSITIONAL = "коробке патронов (7.62x38mm)"
	)
	icon_state = "riflebox"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/n762
	max_ammo = 14

// SHOTGUN
/obj/item/ammo_box/shotgun
	name = "ammunition box (Slug)"
	desc = "Коробка ружейных патронов с цельной пулей. В коробке вмещается 7 патронов."
	ru_names = list(
		NOMINATIVE = "коробка ружейных патронов (цельная пуля)",
		GENITIVE = "коробки ружейных патронов (цельная пуля)",
		DATIVE = "коробке ружейных патронов (цельная пуля)",
		ACCUSATIVE = "коробку ружейных патронов (цельная пуля)",
		INSTRUMENTAL = "коробкой ружейных патронов (цельная пуля)",
		PREPOSITIONAL = "коробке ружейных патронов (цельная пуля)"
	)
	icon_state = "slugbox"
	ammo_type = /obj/item/ammo_casing/shotgun
	max_ammo = 7
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/ammo_box/shotgun/buck
	name = "ammunition box (buckshot)"
	desc = "Коробка ружейных патронов с картечью. В коробке вмещается 7 патронов."
	ru_names = list(
		NOMINATIVE = "коробка ружейных патронов (картечь)",
		GENITIVE = "коробки ружейных патронов (картечь)",
		DATIVE = "коробке ружейных патронов (картечь)",
		ACCUSATIVE = "коробку ружейных патронов (картечь)",
		INSTRUMENTAL = "коробкой ружейных патронов (картечь)",
		PREPOSITIONAL = "коробке ружейных патронов (картечь)"
	)
	icon_state = "buckshotbox"
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot

/obj/item/ammo_box/shotgun/buck/assassination
	name = "ammunition box (assassination shells)"
	desc = "Коробка ружейных патронов с шрапнелью, обработанной глушащим токсином. В коробке вмещается 7 патронов."
	ru_names = list(
		NOMINATIVE = "коробка ружейных патронов (шрапнель с глушащим токсином)",
		GENITIVE = "коробки ружейных патронов (шрапнель с глушащим токсином)",
		DATIVE = "коробке ружейных патронов (шрапнель с глушащим токсином)",
		ACCUSATIVE = "коробку ружейных патронов (шрапнель с глушащим токсином)",
		INSTRUMENTAL = "коробкой ружейных патронов (шрапнель с глушащим токсином)",
		PREPOSITIONAL = "коробке ружейных патронов (шрапнель с глушащим токсином)"
	)
	ammo_type = /obj/item/ammo_casing/shotgun/assassination

/obj/item/ammo_box/shotgun/buck/nuclear
	name = "elite ammunition box (buckshot)"
	desc = "Коробка ружейных патронов с крупной картечью. В коробке вмещается 7 патронов."
	ru_names = list(
		NOMINATIVE = "коробка ружейных патронов (крупная картечь)",
		GENITIVE = "коробки ружейных патронов (крупная картечь)",
		DATIVE = "коробке ружейных патронов (крупная картечь)",
		ACCUSATIVE = "коробку ружейных патронов (крупная картечь)",
		INSTRUMENTAL = "коробкой ружейных патронов (крупная картечь)",
		PREPOSITIONAL = "коробке ружейных патронов (крупная картечь)"
	)
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot/nuclear

/obj/item/ammo_box/shotgun/rubbershot
	name = "ammunition box (rubbershot shells)"
	desc = "Коробка ружейных патронов с резиновой картечью. Считается нелетальным снаряжением. В коробке вмещается 7 патронов."
	ru_names = list(
		NOMINATIVE = "коробка ружейных патронов (резиновая картечь)",
		GENITIVE = "коробки ружейных патронов (резиновая картечь)",
		DATIVE = "коробке ружейных патронов (резиновая картечь)",
		ACCUSATIVE = "коробку ружейных патронов (резиновая картечь)",
		INSTRUMENTAL = "коробкой ружейных патронов (резиновая картечь)",
		PREPOSITIONAL = "коробке ружейных патронов (резиновая картечь)"
	)
	icon_state = "rubbershotbox"
	ammo_type = /obj/item/ammo_casing/shotgun/rubbershot

/obj/item/ammo_box/shotgun/rubbershot/dart
	name = "ammunition box (dart shells)"
	desc = "Коробка шприцевых ружейных патронов. В каждый патрон-шприц можно влить до 30 юнитов химиката. В коробке вмещается 7 патронов."
	ru_names = list(
		NOMINATIVE = "коробка ружейных патронов (патрон-шприц)",
		GENITIVE = "коробки ружейных патронов (патрон-шприц)",
		DATIVE = "коробке ружейных патронов (патрон-шприц)",
		ACCUSATIVE = "коробку ружейных патронов (патрон-шприц)",
		INSTRUMENTAL = "коробкой ружейных патронов (патрон-шприц)",
		PREPOSITIONAL = "коробке ружейных патронов (патрон-шприц)"
	)
	ammo_type = /obj/item/ammo_casing/shotgun/dart

/obj/item/ammo_box/shotgun/beanbag
	name = "ammunition box (beanbag shells)"
	desc = "Коробка ружейных патронов с нелетальной резиновой пулей. В коробке вмещается 7 патронов."
	ru_names = list(
		NOMINATIVE = "коробка ружейных патронов (резиновая пуля)",
		GENITIVE = "коробки ружейных патронов (резиновая пуля)",
		DATIVE = "коробке ружейных патронов (резиновая пуля)",
		ACCUSATIVE = "коробку ружейных патронов (резиновая пуля)",
		INSTRUMENTAL = "коробкой ружейных патронов (резиновая пуля)",
		PREPOSITIONAL = "коробке ружейных патронов (резиновая пуля)"
	)
	icon_state = "beanbagbox"
	ammo_type = /obj/item/ammo_casing/shotgun/beanbag

/obj/item/ammo_box/shotgun/beanbag/fake
	ammo_type = /obj/item/ammo_casing/shotgun/beanbag/fake

/obj/item/ammo_box/shotgun/stunslug
	name = "ammunition box (stun shells)"
	desc = "Коробка ружейных патронов с электрошоком. В коробке вмещается 7 патронов."
	ru_names = list(
		NOMINATIVE = "коробка ружейных патронов (электрошок)",
		GENITIVE = "коробки ружейных патронов (электрошок)",
		DATIVE = "коробке ружейных патронов (электрошок)",
		ACCUSATIVE = "коробку ружейных патронов (электрошок)",
		INSTRUMENTAL = "коробкой ружейных патронов (электрошок)",
		PREPOSITIONAL = "коробке ружейных патронов (электрошок)"
	)
	icon_state = "stunslugbox"
	ammo_type = /obj/item/ammo_casing/shotgun/stunslug

/obj/item/ammo_box/shotgun/breaching
	name = "ammunition box (breaching shells)"
	desc = "Коробка ружейных патронов для штурма дверей. В коробке вмещается 7 патронов."
	ru_names = list(
		NOMINATIVE = "коробка ружейных патронов (штурмовые)",
		GENITIVE = "коробки ружейных патронов (штурмовые)",
		DATIVE = "коробке ружейных патронов (штурмовые)",
		ACCUSATIVE = "коробку ружейных патронов (штурмовые)",
		INSTRUMENTAL = "коробкой ружейных патронов (штурмовые)",
		PREPOSITIONAL = "коробке ружейных патронов (штурмовые)"
	)
	icon_state = "meteorshotbox"
	ammo_type = /obj/item/ammo_casing/shotgun/breaching

/obj/item/ammo_box/shotgun/pulseslug
	name = "ammunition box (pulse slugs)"
	desc = "Коробка ружейных патронов \"импульсная пуля\". В коробке вмещается 7 патронов."
	ru_names = list(
		NOMINATIVE = "коробка ружейных патронов (импульсная пуля)",
		GENITIVE = "коробки ружейных патронов (импульсная пуля)",
		DATIVE = "коробке ружейных патронов (импульсная пуля)",
		ACCUSATIVE = "коробку ружейных патронов (импульсная пуля)",
		INSTRUMENTAL = "коробкой ружейных патронов (импульсная пуля)",
		PREPOSITIONAL = "коробке ружейных патронов (импульсная пуля)"
	)
	icon_state = "pulseslugbox"
	ammo_type = /obj/item/ammo_casing/shotgun/pulseslug

/obj/item/ammo_box/shotgun/incendiary
	name = "ammunition box (incendiary slugs)"
	desc = "Коробка зажигательных ружейных патронов. В коробке вмещается 7 патронов."
	ru_names = list(
		NOMINATIVE = "коробка ружейных патронов (зажигательные)",
		GENITIVE = "коробки ружейных патронов (зажигательные)",
		DATIVE = "коробке ружейных патронов (зажигательные)",
		ACCUSATIVE = "коробку ружейных патронов (зажигательные)",
		INSTRUMENTAL = "коробкой ружейных патронов (зажигательные)",
		PREPOSITIONAL = "коробке ружейных патронов (зажигательные)"
	)
	icon_state = "incendiarybox"
	ammo_type = /obj/item/ammo_casing/shotgun/incendiary

/obj/item/ammo_box/shotgun/frag12
	name = "ammunition box (frag-12 slugs)"
	desc = "Коробка разрывных ружейных патронов. В коробке вмещается 7 патронов."
	ru_names = list(
		NOMINATIVE = "коробка ружейных патронов (разрывная пуля)",
		GENITIVE = "коробки ружейных патронов (разрывная пуля)",
		DATIVE = "коробке ружейных патронов (разрывная пуля)",
		ACCUSATIVE = "коробку ружейных патронов (разрывная пуля)",
		INSTRUMENTAL = "коробкой ружейных патронов (разрывная пуля)",
		PREPOSITIONAL = "коробке ружейных патронов (разрывная пуля)"
	)
	icon_state = "frag12box"
	ammo_type = /obj/item/ammo_casing/shotgun/frag12

/obj/item/ammo_box/shotgun/dragonsbreath
	name = "ammunition box (dragonsbreath)"
	desc = "Коробка патронов \"Дыхание дракона\" калибра 12g. В коробке вмещается 7 патронов."
	ru_names = list(
		NOMINATIVE = "коробка ружейных патронов (дыхание дракона)",
		GENITIVE = "коробки ружейных патронов (дыхание дракона)",
		DATIVE = "коробке ружейных патронов (дыхание дракона)",
		ACCUSATIVE = "коробку ружейных патронов (дыхание дракона)",
		INSTRUMENTAL = "коробкой ружейных патронов (дыхание дракона)",
		PREPOSITIONAL = "коробке ружейных патронов (дыхание дракона)"
	)
	icon_state = "dragonsbreathbox"
	ammo_type = /obj/item/ammo_casing/shotgun/incendiary/dragonsbreath

/obj/item/ammo_box/shotgun/dragonsbreath/nuclear
	name = "elite ammunition box (dragonsbreath)"
	desc = "Коробка ружейных патронов \"Дыхание дракона\". В коробке вмещается 7 патронов."
	ru_names = list(
		NOMINATIVE = "коробка ружейных патронов (дыхание дракона)",
		GENITIVE = "коробки ружейных патронов (дыхание дракона)",
		DATIVE = "коробке ружейных патронов (дыхание дракона)",
		ACCUSATIVE = "коробку ружейных патронов (дыхание дракона)",
		INSTRUMENTAL = "коробкой ружейных патронов (дыхание дракона)",
		PREPOSITIONAL = "коробке ружейных патронов (дыхание дракона)"
	)
	ammo_type = /obj/item/ammo_casing/shotgun/incendiary/dragonsbreath/nuclear

/obj/item/ammo_box/shotgun/ion
	name = "ammunition box (ion shells)"
	desc = "Коробка ружейных патронов с ионными пулями. В коробке вмещается 7 патронов."
	ru_names = list(
		NOMINATIVE = "коробка ружейных патронов (ионная пуля)",
		GENITIVE = "коробки ружейных патронов (ионная пуля)",
		DATIVE = "коробке ружейных патронов (ионная пуля)",
		ACCUSATIVE = "коробку ружейных патронов (ионная пуля)",
		INSTRUMENTAL = "коробкой ружейных патронов (ионная пуля)",
		PREPOSITIONAL = "коробке ружейных патронов (ионная пуля)"
	)
	icon_state = "ionbox"
	ammo_type = /obj/item/ammo_casing/shotgun/ion

/obj/item/ammo_box/shotgun/laserslug
	name = "ammunition box (laser slugs)"
	desc = "Коробка ружейных патронов \"лазерная пуля\". В коробке вмещается 7 патронов."
	ru_names = list(
		NOMINATIVE = "коробка ружейных патронов (лазерная пуля)",
		GENITIVE = "коробки ружейных патронов (лазерная пуля)",
		DATIVE = "коробке ружейных патронов (лазерная пуля)",
		ACCUSATIVE = "коробку ружейных патронов (лазерная пуля)",
		INSTRUMENTAL = "коробкой ружейных патронов (лазерная пуля)",
		PREPOSITIONAL = "коробке ружейных патронов (лазерная пуля)"
	)
	icon_state = "laserslugbox"
	ammo_type = /obj/item/ammo_casing/shotgun/laserslug

/obj/item/ammo_box/shotgun/lasershot
	name = "ammunition box (laser shots)"
	icon_state = "laserslugbox"
	desc = "Коробка ружейных патронов \"лазерная картечь\". В коробке вмещается 7 патронов."
	ru_names = list(
		NOMINATIVE = "коробка ружейных патронов (лазерная картечь)",
		GENITIVE = "коробки ружейных патронов (лазерная картечь)",
		DATIVE = "коробке ружейных патронов (лазерная картечь)",
		ACCUSATIVE = "коробку ружейных патронов (лазерная картечь)",
		INSTRUMENTAL = "коробкой ружейных патронов (лазерная картечь)",
		PREPOSITIONAL = "коробке ружейных патронов (лазерная картечь)"
	)
	ammo_type = /obj/item/ammo_casing/shotgun/lasershot

/obj/item/ammo_box/shotgun/bioterror
	name = "ammunition box (bioterror shells)"
	desc = "Коробка ружейных патронов \"Биотеррор\". В коробке вмещается 7 патронов."
	ru_names = list(
		NOMINATIVE = "коробка ружейных патронов (биотеррор)",
		GENITIVE = "коробки ружейных патронов (биотеррор)",
		DATIVE = "коробке ружейных патронов (биотеррор)",
		ACCUSATIVE = "коробку ружейных патронов (биотеррор)",
		INSTRUMENTAL = "коробкой ружейных патронов (биотеррор)",
		PREPOSITIONAL = "коробке ружейных патронов (биотеррор)"
	)
	icon_state = "bioterrorbox"
	ammo_type = /obj/item/ammo_casing/shotgun/bioterror

/obj/item/ammo_box/shotgun/tranquilizer
	name = "ammunition box (tranquilizer darts)"
	desc = "Коробка ружейных патронов с транквилизатором. В коробке вмещается 7 патронов."
	ru_names = list(
		NOMINATIVE = "коробка ружейных патронов (транквилизатор)",
		GENITIVE = "коробки ружейных патронов (транквилизатор)",
		DATIVE = "коробке ружейных патронов (транквилизатор)",
		ACCUSATIVE = "коробку ружейных патронов (транквилизатор)",
		INSTRUMENTAL = "коробкой ружейных патронов (транквилизатор)",
		PREPOSITIONAL = "коробке ружейных патронов (транквилизатор)"
	)
	icon_state = "tranquilizerbox"
	ammo_type = /obj/item/ammo_casing/shotgun/tranquilizer

/obj/item/ammo_box/shotgun/flechette
	name = "ammunition box (flechette)"
	desc = "Коробка ружейных патронов \"Флешетта\". В коробке вмещается 7 патронов."
	ru_names = list(
		NOMINATIVE = "коробка ружейных патронов (флешетта)",
		GENITIVE = "коробки ружейных патронов (флешетта)",
		DATIVE = "коробке ружейных патронов (флешетта)",
		ACCUSATIVE = "коробку ружейных патронов (флешетта)",
		INSTRUMENTAL = "коробкой ружейных патронов (флешетта)",
		PREPOSITIONAL = "коробке ружейных патронов (флешетта)"
	)
	icon_state = "flechettebox"
	ammo_type = /obj/item/ammo_casing/shotgun/flechette

/obj/item/ammo_box/shotgun/improvised
	name = "ammunition box (improvised shells)"
	desc = "Коробка с самодельными патронами. В коробке вмещается 7 патронов."
	ru_names = list(
		NOMINATIVE = "коробка ружейных патронов (самодельная картечь)",
		GENITIVE = "коробки ружейных патронов (самодельная картечь)",
		DATIVE = "коробке ружейных патронов (самодельная картечь)",
		ACCUSATIVE = "коробку ружейных патронов (самодельная картечь)",
		INSTRUMENTAL = "коробкой ружейных патронов (самодельная картечь)",
		PREPOSITIONAL = "коробке ружейных патронов (самодельная картечь)"
	)
	icon = 'icons/obj/storage.dmi'
	icon_state = "largebox"
	ammo_type = /obj/item/ammo_casing/shotgun/improvised

/obj/item/ammo_box/shotgun/improvised/overload
	name = "ammunition box (overload shells)"
	desc = "Коробка с самодельными патронами повышенной мощности. В коробке вмещается 7 патронов."
	ru_names = list(
		NOMINATIVE = "коробка ружейных патронов (самодельная картечь повышенной мощности)",
		GENITIVE = "коробки ружейных патронов (самодельная картечь повышенной мощности)",
		DATIVE = "коробке ружейных патронов (самодельная картечь повышенной мощности)",
		ACCUSATIVE = "коробку ружейных патронов (самодельная картечь повышенной мощности)",
		INSTRUMENTAL = "коробкой ружейных патронов (самодельная картечь повышенной мощности)",
		PREPOSITIONAL = "коробке ружейных патронов (самодельная картечь повышенной мощности)"
	)
	ammo_type = /obj/item/ammo_casing/shotgun/improvised/overload

// AUTOMATIC
/obj/item/ammo_box/c9mm
	name = "ammo box (9mm)"
	icon_state = "9mmbox"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/c9mm
	max_ammo = 30

/obj/item/ammo_box/rubber9mm
	name = "ammo box (rubber 9mm)"
	icon_state = "9mmbox"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/rubber9mm
	max_ammo = 30

/obj/item/ammo_box/c10mm
	name = "ammo box (10mm)"
	icon_state = "10mmbox"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/c10mm
	max_ammo = 30

/obj/item/ammo_box/fortynr
	name = "ammo box 40N&R"
	icon_state = "40n&rbox"
	ammo_type = /obj/item/ammo_casing/fortynr
	max_ammo = 40

/obj/item/ammo_box/c45
	name = "ammo box (.45)"
	icon_state = "45box"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/c45
	max_ammo = 20

/obj/item/ammo_box/c45/ext
	name = "ammo box extended (.45)"
	icon_state = "ammobox_45"
	max_ammo = 40

/obj/item/ammo_box/rubber45
	name = "ammo box (.45 rubber)"
	icon_state = "45box-r"
	ammo_type = /obj/item/ammo_casing/rubber45
	max_ammo = 16

/obj/item/ammo_box/rubber45/ext
	name = "ammo box extended(.45 rubber)"
	icon_state = "ammobox_45"
	max_ammo = 40

/obj/item/ammo_box/a556
	name = "ammo box (5.56 mm)"
	icon_state = "ammobox_556"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/a556
	max_ammo = 60

/obj/item/ammo_box/ak814
	name = "AK ammo box (5.45x39mm)"
	icon_state = "ammobox_AK"
	origin_tech = "combat=5;syndicate=1"
	ammo_type = /obj/item/ammo_casing/a545
	max_ammo = 60

/obj/item/ammo_box/c46x30mm
	name = "ammo box (4.6x30mm)"
	icon_state = "4630mmbox"
	ammo_type = /obj/item/ammo_casing/c46x30mm
	max_ammo = 40

/obj/item/ammo_box/ap46x30mm
	name = "ammo box (Armour Piercing 4.6x30mm)"
	icon_state = "4630mmbox"
	ammo_type = /obj/item/ammo_casing/c46x30mm/ap
	max_ammo = 40

/obj/item/ammo_box/tox46x30mm
	name = "ammo box (Toxin Tipped 4.6x30mm)"
	icon_state = "4630mmbox"
	ammo_type = /obj/item/ammo_casing/c46x30mm/tox
	max_ammo = 40

/obj/item/ammo_box/inc46x30mm
	name = "ammo box (Incendiary 4.6x30mm)"
	icon_state = "4630mmbox"
	ammo_type = /obj/item/ammo_casing/c46x30mm/inc
	max_ammo = 40

/obj/item/ammo_box/c9mmte
	name = "ammo box (9mm TE)"
	icon_state = "9mmTEbox"
	ammo_type = /obj/item/ammo_casing/c9mmte
	max_ammo = 60

// MISC
/obj/item/ammo_box/a40mm
	name = "ammo box (40mm grenades)"
	icon_state = "40mm"
	ammo_type = /obj/item/ammo_casing/a40mm
	max_ammo = 4
	multiple_sprites = 1

/obj/item/ammo_box/laserammobox
	name = "laser ammo box"
	icon_state = "laserbox"
	ammo_type = /obj/item/ammo_casing/laser
	max_ammo = 40

/obj/item/ammo_box/foambox
	name = "ammo box (Foam Darts)"
	icon = 'icons/obj/weapons/toy.dmi'
	icon_state = "foambox"
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart
	max_ammo = 40

/obj/item/ammo_box/foambox/riot
	icon_state = "foambox_riot"
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart/riot

/obj/item/ammo_box/foambox/sniper
	name = "ammo box (Foam Sniper Darts)"
	icon = 'icons/obj/weapons/toy.dmi'
	icon_state = "foambox_sniper"
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart/sniper
	max_ammo = 40

/obj/item/ammo_box/foambox/sniper/riot
	icon_state = "foambox_sniper_riot"
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart/sniper/riot

/obj/item/ammo_box/sniper_rounds_compact
	name = "Box of compact sniper rounds (.50L COMP)"
	icon_state = "ammobox_sniperCOMP"
	origin_tech = "combat=5"
	ammo_type = /obj/item/ammo_casing/compact
	max_ammo = 20

/obj/item/ammo_box/sniper_rounds_penetrator
	name = "Box of penetrator sniper rounds (.50 PE)"
	icon_state = "ammobox_sniperPE"
	origin_tech = "combat=6"
	ammo_type = /obj/item/ammo_casing/penetrator
	max_ammo = 20

/obj/item/ammo_box/m10mm
	name = "ammo box (10mm)"
	icon_state = "ammobox_10AP"
	ammo_type = /obj/item/ammo_casing/c10mm
	max_ammo = 60

/obj/item/ammo_box/m10mm/ap
	name = "ammo box (10mm AP)"
	ammo_type = /obj/item/ammo_casing/c10mm/ap

/obj/item/ammo_box/m10mm/hp
	name = "ammo box (10mm HP)"
	icon_state = "ammobox_10HP"
	ammo_type = /obj/item/ammo_casing/c10mm/hp

/obj/item/ammo_box/m10mm/fire
	name = "ammo box (10mm incendiary)"
	icon_state = "ammobox_10incendiary"
	ammo_type = /obj/item/ammo_casing/c10mm/fire

/obj/item/ammo_box/specter
	origin_tech = "combat=2"
	max_ammo = 30

/obj/item/ammo_box/specter/laser
	name = "ammo box (Specter laser)"
	desc = "Коробка, содержащая 30 лазерных патронов для пистолета \"Спектр\"."
	ru_names = list(
		NOMINATIVE = "коробка патронов (Спектр лазерные)",
		GENITIVE = "коробка патронов (Спектр лазерные)",
		DATIVE = "коробка патронов (Спектр лазерные)",
		ACCUSATIVE = "коробка патронов (Спектр лазерные)",
		INSTRUMENTAL = "коробка патронов (Спектр лазерные)",
		PREPOSITIONAL = "коробка патронов (Спектр лазерные)"
	)
	icon_state = "speclaser"
	ammo_type = /obj/item/ammo_casing/specter/laser


/obj/item/ammo_box/specter/disabler
	name = "ammo box (Specter disabler)"
	desc = "Коробка, содержащая 30 парализующих патронов для пистолета \"Спектр\"."
	ru_names = list(
		NOMINATIVE = "коробка патронов (Спектр парализующие)",
		GENITIVE = "коробка патронов (Спектр парализующие)",
		DATIVE = "коробке патронов (Спектр парализующие)",
		ACCUSATIVE = "коробку патронов (Спектр парализующие)",
		INSTRUMENTAL = "коробкой патронов (Спектр парализующие)",
		PREPOSITIONAL = "коробке патронов (Спектр парализующие)"
	)
	icon_state = "specstamina"
	ammo_type = /obj/item/ammo_casing/specter/disable

/**
 * SPEEDLOADER
 */

// REVOLVER
/obj/item/ammo_box/speedloader/a357
	name = "speed loader (.357)"
	desc = "Designed to quickly reload revolvers."
	materials = list(MAT_METAL = 2000)
	ammo_type = /obj/item/ammo_casing/a357
	max_ammo = 7
	caliber = ".357"
	icon_state = "357-7" // DEFAULT icon, composed of prefix + "-" + max_ammo for multiple_sprites == 1 boxes
	multiple_sprites = 1 // see: /obj/item/ammo_box/update_icon()
	icon_prefix = "357" // icon prefix, used in above formula to generate dynamic icons

/obj/item/ammo_box/speedloader/improvised
	name = "makeshift speedloader"
	desc = "Speedloader made from shit and sticks."
	ammo_type = null
	icon_state = "makeshift_speedloader"
	max_ammo = 4
	caliber = ".257"

/obj/item/ammo_box/speedloader/improvised/update_overlays()
	. = ..()

	for(var/i = 1 to length(stored_ammo))
		var/obj/item/ammo_casing/ammo = stored_ammo[i]
		var/icon/new_ammo_icon = icon('icons/obj/weapons/ammo.dmi', ammo.icon_state)
		new_ammo_icon.Shift((i in list(2, 3)) ? 8 / RaiseToPower(2, round(i-2, 2)) : i, ISODD(i) ? 4 : 2)
		. += new_ammo_icon

/obj/item/ammo_box/speedloader/c38
	name = "speed loader (.38)"
	desc = "Designed to quickly reload revolvers."
	icon_state = "38"
	materials = list(MAT_METAL = 2000)
	ammo_type = /obj/item/ammo_casing/c38
	max_ammo = 6
	caliber = ".38"
	icon_state = "38-6"
	multiple_sprites = 1
	icon_prefix = "38"

/obj/item/ammo_box/speedloader/c38/hp
	name = "speed loader (.38 Hollow-Point)"
	ammo_type = /obj/item/ammo_casing/c38/hp
	icon_state = "38hp-6"
	icon_prefix = "38hp"

/obj/item/ammo_box/nagant
	name = "ammo box (7.62x38mm nagant)"
	icon_state = "ammobox_nagant"
	ammo_type = /obj/item/ammo_casing/n762
	max_ammo = 20

// SHOTGUN
/obj/item/ammo_box/speedloader/shotgun
	name = "shotgun speedloader"
	desc = "Designed to quickly reload shotguns."
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
	icon_state = "357"
	ammo_type = /obj/item/ammo_casing/cap
	max_ammo = 7
	multiple_sprites = 1

/**
 * STRIPPER CLIP
 */

/obj/item/ammo_box/speedloader/a762
	name = "stripper clip (7.62mm)"
	desc = "A stripper clip."
	icon_state = "762"
	caliber = "7.62x54mm"
	ammo_type = /obj/item/ammo_casing/a762
	max_ammo = 5
	multiple_sprites = 1

/obj/item/ammo_box/a762
	name = "ammo box (7.62x54mm mosin)"
	icon_state = "ammobox_mosin"
	ammo_type = /obj/item/ammo_casing/a762
	max_ammo = 40
