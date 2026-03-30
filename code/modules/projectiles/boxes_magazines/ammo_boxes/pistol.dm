// MARK: 9mm
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
		PREPOSITIONAL = "коробке патронов (9 мм)",
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
		PREPOSITIONAL = "коробке патронов (нелетальный 9 мм)",
	)

// MARK: 10mm
/obj/item/ammo_box/m10mm
	name = "ammo box (10mm)"
	desc = "Коробка, содержащая патроны калибра 10 мм."
	icon_state = "ammobox_10AP"
	ammo_type = /obj/item/ammo_casing/c10mm
	max_ammo = 60
	materials = list(MAT_METAL = 750)

/obj/item/ammo_box/m10mm/get_ru_names()
	return list(
		NOMINATIVE = "коробка патронов (10 мм)",
		GENITIVE = "коробки патронов (10 мм)",
		DATIVE = "коробке патронов (10 мм)",
		ACCUSATIVE = "коробку патронов (10 мм)",
		INSTRUMENTAL = "коробкой патронов (10 мм)",
		PREPOSITIONAL = "коробке патронов (10 мм)",
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
		PREPOSITIONAL = "коробке патронов (бронебойные 10 мм)",
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
		PREPOSITIONAL = "коробке патронов (экспансивные 10 мм)",
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
		PREPOSITIONAL = "коробке патронов (зажигательные 10 мм)",
	)

// MARK: .40 N&R
/obj/item/ammo_box/fortynr
	name = "ammo box .40 N&R"
	desc = "Коробка, содержащая патроны  .40 калибра N&R."
	icon_state = "40n&rbox"
	ammo_type = /obj/item/ammo_casing/fortynr
	max_ammo = 40
	materials = list(MAT_METAL = 1000)

/obj/item/ammo_box/fortynr/get_ru_names()
	return list(
		NOMINATIVE = "коробка патронов (.40 N&R)",
		GENITIVE = "коробки патронов (.40 N&R)",
		DATIVE = "коробке патронов (.40 N&R)",
		ACCUSATIVE = "коробку патронов (.40 N&R)",
		INSTRUMENTAL = "коробкой патронов (.40 N&R)",
		PREPOSITIONAL = "коробке патронов (.40 N&R)",
	)

// MARK: 7.62x25mm
/obj/item/ammo_box/a762x25
	name = "ammo box (7.62x25mm)"
	desc = "Большая коробка, содержащая патроны калибра 7.62x25мм."
	icon_state = "ammobox_762x25"
	ammo_type = /obj/item/ammo_casing/ftt762
	max_ammo = 70

/obj/item/ammo_box/a762x25/get_ru_names()
	return list(
		NOMINATIVE = "коробка патронов (7.62x25мм)",
		GENITIVE = "коробки патронов (7.62x25мм)",
		DATIVE = "коробке патронов (7.62x25мм)",
		ACCUSATIVE = "коробку патронов (7.62x25мм)",
		INSTRUMENTAL = "коробкой патронов (7.62x25мм)",
		PREPOSITIONAL = "коробке патронов (7.62x25мм)",
	)

// MARK: .45
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
		PREPOSITIONAL = "коробке патронов (.45)",
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
		PREPOSITIONAL = "большой коробке патронов (.45)",
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
		PREPOSITIONAL = "коробке патронов (нелетальный .45)",
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
		PREPOSITIONAL = "большой коробке патронов (нелетальный .45)",
	)

// MARK: .45 N&R
/obj/item/ammo_box/dot45NR
	name = "ammo box (.45 N&R)"
	desc = "Коробка, содержащая патроны калибра .45 N&R."
	icon_state = "45NRbox"
	ammo_type = /obj/item/ammo_casing/c45nr
	max_ammo = 60

/obj/item/ammo_box/dot45NR/get_ru_names()
	return list(
		NOMINATIVE = "коробка патронов (.45 N&R)",
		GENITIVE = "коробки патронов (.45 N&R)",
		DATIVE = "коробке патронов (.45 N&R)",
		ACCUSATIVE = "коробку патронов (.45 N&R)",
		INSTRUMENTAL = "коробкой патронов (.45 N&R)",
		PREPOSITIONAL = "коробке патронов (.45 N&R)",
	)

// MARK: .45 Colt
/obj/item/ammo_box/c45colt
	name = "ammo box (.45 Colt)"
	desc = "Коробка, содержащая патроны калибра .45 Colt."
	icon_state = "box_c45colt"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/c45colt
	max_ammo = 30

/obj/item/ammo_box/c45colt/get_ru_names()
	return list(
		NOMINATIVE = "коробка патронов (.45 Colt)",
		GENITIVE = "коробки патронов (.45 Colt)",
		DATIVE = "коробке патронов (.45 Colt)",
		ACCUSATIVE = "коробку патронов (.45 Colt)",
		INSTRUMENTAL = "коробкой патронов (.45 Colt)",
		PREPOSITIONAL = "коробке патронов (.45 Colt)",
	)

/obj/item/ammo_box/rubber45colt
	name = "ammo box (rubber .45 Colt)"
	desc = "Коробка, содержащая резиновые патроны калибра .45 Colt."
	icon_state = "box_rubber45colt"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/c45colt/rubber
	max_ammo = 30

/obj/item/ammo_box/rubber45colt/get_ru_names()
	return list(
		NOMINATIVE = "коробка патронов (нелетальный .45 Colt)",
		GENITIVE = "коробки патронов (нелетальный .45 Colt)",
		DATIVE = "коробке патронов (нелетальный .45 Colt)",
		ACCUSATIVE = "коробку патронов (нелетальный .45 Colt)",
		INSTRUMENTAL = "коробкой патронов (нелетальный .45 Colt)",
		PREPOSITIONAL = "коробке патронов (нелетальный .45 Colt)",
	)

/obj/item/ammo_box/expansive45colt
	name = "ammo box (expansive .45 Colt)"
	desc = "Коробка, содержащая экспансивные патроны калибра .45 Colt."
	icon_state = "box_hp45colt"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/c45colt/hp
	max_ammo = 30

/obj/item/ammo_box/expansive45colt/get_ru_names()
	return list(
		NOMINATIVE = "коробка патронов (экспансивный .45 Colt)",
		GENITIVE = "коробки патронов (экспансивный .45 Colt)",
		DATIVE = "коробке патронов (экспансивный .45 Colt)",
		ACCUSATIVE = "коробку патронов (экспансивный .45 Colt)",
		INSTRUMENTAL = "коробкой патронов (экспансивный .45 Colt)",
		PREPOSITIONAL = "коробке патронов (экспансивный .45 Colt)",
	)

/obj/item/ammo_box/ap45colt
	name = "ammo box (armor piercing .45 Colt)"
	desc = "Коробка, содержащая бронебойные патроны калибра .45 Colt."
	icon_state = "box_ap45colt"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/c45colt/ap
	max_ammo = 30

/obj/item/ammo_box/ap45colt/get_ru_names()
	return list(
		NOMINATIVE = "коробка патронов (бронебойный .45 Colt)",
		GENITIVE = "коробки патронов (бронебойный .45 Colt)",
		DATIVE = "коробке патронов (бронебойный .45 Colt)",
		ACCUSATIVE = "коробку патронов (бронебойный .45 Colt)",
		INSTRUMENTAL = "коробкой патронов (бронебойный .45 Colt)",
		PREPOSITIONAL = "коробке патронов (бронебойный .45 Colt)",
	)

// MARK: .50AE
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
		PREPOSITIONAL = "коробке патронов (.50AE)",
	)
