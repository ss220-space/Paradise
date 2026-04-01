
// MARK: 5.45x39mm
/obj/item/ammo_box/a545x39
	name = "AK ammo box (5.45x39mm)"
	desc = "Коробка, содержащая патроны калибра 5,45х39 мм."
	icon_state = "ammobox_AK"
	origin_tech = "combat=5;syndicate=1"
	ammo_type = /obj/item/ammo_casing/a545
	max_ammo = 60

/obj/item/ammo_box/a545x39/get_ru_names()
	return list(
		NOMINATIVE = "коробка патронов (5,45х39 мм)",
		GENITIVE = "коробки патронов (5,45х39 мм)",
		DATIVE = "коробке патронов (5,45х39 мм)",
		ACCUSATIVE = "коробку патронов (5,45х39 мм)",
		INSTRUMENTAL = "коробкой патронов (5,45х39 мм)",
		PREPOSITIONAL = "коробке патронов (5,45х39 мм)",
	)

/obj/item/ammo_box/a545x39/fusty
	name = "AK fusty ammo box (5.45x39mm)"
	desc = "Коробка, содержащая затхлые патроны калибра 5,45х39 мм."
	ammo_type = /obj/item/ammo_casing/a545/fusty

/obj/item/ammo_box/a545x39/fusty/get_ru_names()
	return list(
		NOMINATIVE = "коробка затхлых патронов (5,45х39 мм)",
		GENITIVE = "коробки затхлых патронов (5,45х39 мм)",
		DATIVE = "коробке затхлых патронов (5,45х39 мм)",
		ACCUSATIVE = "коробку затхлых патронов (5,45х39 мм)",
		INSTRUMENTAL = "коробкой затхлых патронов (5,45х39 мм)",
		PREPOSITIONAL = "коробке затхлых патронов (5,45х39 мм)",
	)

// MARK: 5.56x45mm
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
		PREPOSITIONAL = "коробке патронов (5,56 мм)",
	)

// MARK: 4.6x30mm
/obj/item/ammo_box/c46x30mm
	name = "ammo box (4.6x30mm)"
	desc = "Коробка, содержащая патроны калибра 4,6x30 мм."
	icon_state = "4630mmbox"
	ammo_type = /obj/item/ammo_casing/c46x30mm
	max_ammo = 60
	materials = list(MAT_METAL = 1200)

/obj/item/ammo_box/c46x30mm/get_ru_names()
	return list(
		NOMINATIVE = "коробка патронов (4,6x30 мм)",
		GENITIVE = "коробки патронов (4,6x30 мм)",
		DATIVE = "коробке патронов (4,6x30 мм)",
		ACCUSATIVE = "коробку патронов (4,6x30 мм)",
		INSTRUMENTAL = "коробкой патронов (4,6x30 мм)",
		PREPOSITIONAL = "коробке патронов (4,6x30 мм)",
	)

/obj/item/ammo_box/ap46x30mm
	name = "ammo box (Armour Piercing 4.6x30mm)"
	desc = "Коробка, содержащая бронебойные патроны калибра 4,6x30 мм."
	icon_state = "4630mmbox"
	ammo_type = /obj/item/ammo_casing/c46x30mm/ap
	max_ammo = 60

/obj/item/ammo_box/ap46x30mm/get_ru_names()
	return list(
		NOMINATIVE = "коробка патронов (бронебойные 4,6x30 мм)",
		GENITIVE = "коробки патронов (бронебойные 4,6x30 мм)",
		DATIVE = "коробке патронов (бронебойные 4,6x30 мм)",
		ACCUSATIVE = "коробку патронов (бронебойные 4,6x30 мм)",
		INSTRUMENTAL = "коробкой патронов (бронебойные 4,6x30 мм)",
		PREPOSITIONAL = "коробке патронов (бронебойные 4,6x30 мм)",
	)

/obj/item/ammo_box/tox46x30mm
	name = "ammo box (Toxin Tipped 4.6x30mm)"
	desc = "Коробка, содержащая отравляющие патроны калибра 4,6x30 мм."
	icon_state = "4630mmbox"
	ammo_type = /obj/item/ammo_casing/c46x30mm/tox
	max_ammo = 60

/obj/item/ammo_box/tox46x30mm/get_ru_names()
	return list(
		NOMINATIVE = "коробка патронов (отравляющие 4,6x30 мм)",
		GENITIVE = "коробки патронов (отравляющие 4,6x30 мм)",
		DATIVE = "коробке патронов (отравляющие 4,6x30 мм)",
		ACCUSATIVE = "коробку патронов (отравляющие 4,6x30 мм)",
		INSTRUMENTAL = "коробкой патронов (отравляющие 4,6x30 мм)",
		PREPOSITIONAL = "коробке патронов (отравляющие 4,6x30 мм)",
	)

/obj/item/ammo_box/inc46x30mm
	name = "ammo box (Incendiary 4.6x30mm)"
	desc = "Коробка, содержащая зажигательные патроны калибра 4,6x30 мм."
	icon_state = "4630mmbox"
	ammo_type = /obj/item/ammo_casing/c46x30mm/inc
	max_ammo = 60

/obj/item/ammo_box/inc46x30mm/get_ru_names()
	return list(
		NOMINATIVE = "коробка патронов (зажигательные 4,6x30 мм)",
		GENITIVE = "коробки патронов (зажигательные 4,6x30 мм)",
		DATIVE = "коробке патронов (зажигательные 4,6x30 мм)",
		ACCUSATIVE = "коробку патронов (зажигательные 4,6x30 мм)",
		INSTRUMENTAL = "коробкой патронов (зажигательные 4,6x30 мм)",
		PREPOSITIONAL = "коробке патронов (зажигательные 4,6x30 мм)",
	)
