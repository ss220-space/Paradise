// MARK: .357
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
		PREPOSITIONAL = "коробке патронов (.357)",
	)


// MARK: 7.62x38mm
/obj/item/ammo_box/n762x38
	name = "ammo box (7.62x38mm)"
	desc = "Коробка, содержащая патроны калибра 7,62х38 мм."
	icon_state = "ammobox_nagant"
	ammo_type = /obj/item/ammo_casing/n762
	max_ammo = 20

/obj/item/ammo_box/n762x38/get_ru_names()
	return list(
		NOMINATIVE = "коробка патронов (7,62х38 мм)",
		GENITIVE = "коробки патронов (7,62х38 мм)",
		DATIVE = "коробке патронов (7,62х38 мм)",
		ACCUSATIVE = "коробку патронов (7,62х38 мм)",
		INSTRUMENTAL = "коробкой патронов (7,62х38 мм)",
		PREPOSITIONAL = "коробке патронов (7,62х38 мм)",
	)

