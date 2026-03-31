// MARK: 7.62x54mm
/obj/item/ammo_box/a762x54
	name = "ammo box (7.62x54mm)"
	desc = "Коробка, содержащая патроны калибра 7,62x54 мм."
	icon_state = "ammobox_mosin"
	ammo_type = /obj/item/ammo_casing/a762x54
	max_ammo = 40

/obj/item/ammo_box/a762x54/get_ru_names()
	return list(
		NOMINATIVE = "коробка патронов (7,62x54 мм)",
		GENITIVE = "коробки патронов (7,62x54 мм)",
		DATIVE = "коробке патронов (7,62x54 мм)",
		ACCUSATIVE = "коробку патронов (7,62x54 мм)",
		INSTRUMENTAL = "коробкой патронов (7,62x54 мм)",
		PREPOSITIONAL = "коробке патронов (7,62x54 мм)",
	)

// MARK: 7.62x51mm
/obj/item/ammo_box/a762x51
	name = "ammo box (7.62x51mm)"
	desc = "Коробка, содержащая патроны калибра 7.62x51мм."
	icon_state = "ammobox_762x51"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/a762x51
	max_ammo = 60

/obj/item/ammo_box/a762x51/get_ru_names()
	return list(
		NOMINATIVE = "коробка патронов (7.62x51мм)",
		GENITIVE = "коробки патронов (7.62x51мм)",
		DATIVE = "коробке патронов (7.62x51мм)",
		ACCUSATIVE = "коробку патронов (7.62x51мм)",
		INSTRUMENTAL = "коробкой патронов (7.62x51мм)",
		PREPOSITIONAL = "коробке патронов (7.62x51мм)",
	)

/obj/item/ammo_box/a762x51/weak
	name = "weak ammo box (7.62x51mm)"
	desc = "Коробка, содержащая ослабленные патроны калибра 7.62x51мм."
	ammo_type = /obj/item/ammo_casing/a762x51/weak

/obj/item/ammo_box/a762x51/weak/get_ru_names()
	return list(
		NOMINATIVE = "коробка ослабленныx патронов (7.62x51мм)",
		GENITIVE = "коробки ослабленныx патронов (7.62x51мм)",
		DATIVE = "коробке ослабленныx патронов (7.62x51мм)",
		ACCUSATIVE = "коробку ослабленныx патронов (7.62x51мм)",
		INSTRUMENTAL = "коробкой ослабленныx патронов (7.62x51мм)",
		PREPOSITIONAL = "коробке ослабленныx патронов (7.62x51мм)",
	)

/obj/item/ammo_box/a762x51/bleeding
	name = "bleeding ammo box (7.62x51mm)"
	desc = "Коробка, содержащая кровопускающие патроны калибра 7.62x51мм."
	ammo_type = /obj/item/ammo_casing/a762x51/bleeding

/obj/item/ammo_box/a762x51/bleeding/get_ru_names()
	return list(
		NOMINATIVE = "коробка кровопускающих патронов (7.62x51мм)",
		GENITIVE = "коробки кровопускающих патронов (7.62x51мм)",
		DATIVE = "коробке кровопускающих патронов (7.62x51мм)",
		ACCUSATIVE = "коробку кровопускающих патронов (7.62x51мм)",
		INSTRUMENTAL = "коробкой кровопускающих патронов (7.62x51мм)",
		PREPOSITIONAL = "коробке кровопускающих патронов (7.62x51мм)",
	)

/obj/item/ammo_box/a762x51/hollow
	name = "hollow ammo box (7.62x51mm)"
	desc = "Коробка, содержащая экспансивные патроны калибра 7.62x51мм."
	ammo_type = /obj/item/ammo_casing/a762x51/hollow

/obj/item/ammo_box/a762x51/hollow/get_ru_names()
	return list(
		NOMINATIVE = "коробка экспансивных патронов (7.62x51мм)",
		GENITIVE = "коробки экспансивных патронов (7.62x51мм)",
		DATIVE = "коробке экспансивных патронов (7.62x51мм)",
		ACCUSATIVE = "коробку экспансивных патронов (7.62x51мм)",
		INSTRUMENTAL = "коробкой экспансивных патронов (7.62x51мм)",
		PREPOSITIONAL = "коробке экспансивных патронов (7.62x51мм)",
	)

/obj/item/ammo_box/a762x51/ap
	name = "ap ammo box (7.62x51mm)"
	desc = "Коробка, содержащая бронебойные патроны калибра 7.62x51мм."
	ammo_type = /obj/item/ammo_casing/a762x51/ap

/obj/item/ammo_box/a762x51/ap/get_ru_names()
	return list(
		NOMINATIVE = "коробка бронебойных патронов (7.62x51мм)",
		GENITIVE = "коробки бронебойных патронов (7.62x51мм)",
		DATIVE = "коробке бронебойных патронов (7.62x51мм)",
		ACCUSATIVE = "коробку бронебойных патронов (7.62x51мм)",
		INSTRUMENTAL = "коробкой бронебойных патронов (7.62x51мм)",
		PREPOSITIONAL = "коробке бронебойных патронов (7.62x51мм)",
	)

/obj/item/ammo_box/a762x51/incen
	name = "incendiary ammo box (7.62x51mm)"
	desc = "Коробка, содержащая зажигательные патроны калибра 7.62x51мм."
	ammo_type = /obj/item/ammo_casing/a762x51/incen

/obj/item/ammo_box/a762x51/incen/get_ru_names()
	return list(
		NOMINATIVE = "коробка зажигательных патронов (7.62x51мм)",
		GENITIVE = "коробки зажигательных патронов (7.62x51мм)",
		DATIVE = "коробке зажигательных патронов (7.62x51мм)",
		ACCUSATIVE = "коробку зажигательных патронов (7.62x51мм)",
		INSTRUMENTAL = "коробкой зажигательных патронов (7.62x51мм)",
		PREPOSITIONAL = "коробке зажигательных патронов (7.62x51мм)",
	)

// MARK: .50
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
		PREPOSITIONAL = "коробке патронов (бронебойныые .50)",
	)


// MARK: .50L
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
		PREPOSITIONAL = "коробке патронов (.50L COMP)",
	)

/obj/item/ammo_box/sniper_rounds_compact/penetrator
	name = "Box of compact penetrator sniper rounds (.50L COMP)"
	desc = "Коробка, содержащая компактные бронебойные снайперские патроны .50L калибра COMP."
	ammo_type = /obj/item/ammo_casing/compact/penetrator

/obj/item/ammo_box/sniper_rounds_compact/penetrator/get_ru_names()
	return list(
		NOMINATIVE = "коробка бронебойных патронов (.50L COMP)",
		GENITIVE = "коробки бронебойных патронов (.50L COMP)",
		DATIVE = "коробке бронебойных патронов (.50L COMP)",
		ACCUSATIVE = "коробку бронебойных патронов (.50L COMP)",
		INSTRUMENTAL = "коробкой бронебойных патронов (.50L COMP)",
		PREPOSITIONAL = "коробке бронебойных патронов (.50L COMP)",
	)

// MARK: .338
/obj/item/ammo_box/a338
	name = "Box of sniper rounds (.338)"
	desc = "Коробка, содержащая снайперские патроны .338 калибра."
	icon_state = "ammobox_338"
	origin_tech = "combat=5"
	ammo_type = /obj/item/ammo_casing/a338
	max_ammo = 20

/obj/item/ammo_box/a338/get_ru_names()
	return list(
		NOMINATIVE = "коробка снайперских патронов (.338)",
		GENITIVE = "коробки снайперских патронов (.338)",
		DATIVE = "коробке снайперских патронов (.338)",
		ACCUSATIVE = "коробку снайперских патронов (.338)",
		INSTRUMENTAL = "коробкой снайперских патронов (.338)",
		PREPOSITIONAL = "коробке снайперских патронов (.338)",
	)

/obj/item/ammo_box/a338/explosive
	name = "Box of explosive sniper rounds (.338)"
	desc = "Коробка, содержащая разрывные снайперские патроны .338 калибра."
	ammo_type = /obj/item/ammo_casing/a338_explosive

/obj/item/ammo_box/a338/explosive/get_ru_names()
	return list(
		NOMINATIVE = "коробка разрывных снайперских патронов (.338)",
		GENITIVE = "коробки разрывных снайперских патронов (.338)",
		DATIVE = "коробке разрывных снайперских патронов (.338)",
		ACCUSATIVE = "коробку разрывных снайперских патронов (.338)",
		INSTRUMENTAL = "коробкой разрывных снайперских патронов (.338)",
		PREPOSITIONAL = "коробке разрывных снайперских патронов (.338)",
	)

/obj/item/ammo_box/a338/penetrator
	name = "Box of penetrator sniper rounds (.338)"
	desc = "Коробка, содержащая проникающие снайперские патроны .338 калибра."
	ammo_type = /obj/item/ammo_casing/a338_penetrator

/obj/item/ammo_box/a338/penetrator/get_ru_names()
	return list(
		NOMINATIVE = "коробка проникающих снайперских патронов (.338)",
		GENITIVE = "коробки проникающих снайперских патронов (.338)",
		DATIVE = "коробке проникающих снайперских патронов (.338)",
		ACCUSATIVE = "коробку проникающих снайперских патронов (.338)",
		INSTRUMENTAL = "коробкой проникающих снайперских патронов (.338)",
		PREPOSITIONAL = "коробке проникающих снайперских патронов (.338)",
	)
