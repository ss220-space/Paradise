// MARK: .40mm
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
		PREPOSITIONAL = "коробке патронов (40 мм)",
	)

// MARK: .40mm - GL-06
/obj/item/ammo_box/secgl
	icon = 'icons/obj/weapons/bombarda.dmi'
	icon_state = "secgl_box_gas"
	ammo_type = /obj/item/ammo_casing/a40mm/secgl
	max_ammo = 4

/obj/item/ammo_box/secgl/solid
	name = "ammo box (40mm solid)"
	desc = "Коробка, содержащая гранаты с цельной резиновой пулей калибра 40 мм."
	ammo_type = /obj/item/ammo_casing/a40mm/secgl/solid
	icon_state = "secgl_box_solid"

/obj/item/ammo_box/secgl/solid/get_ru_names()
	return list(
		NOMINATIVE = "коробка гранат (40 мм цельная резина)",
		GENITIVE = "коробки гранат (40 мм цельная резина)",
		DATIVE = "коробке гранат (40 мм цельная резина)",
		ACCUSATIVE = "коробку гранат (40 мм цельная резина)",
		INSTRUMENTAL = "коробкой гранат (40 мм цельная резина)",
		PREPOSITIONAL = "коробке гранат (40 мм цельная резина)",
	)

/obj/item/ammo_box/secgl/flash
	name = "ammo box (40mm flashbang)"
	desc = "Коробка, содержащая светошумовые гранаты калибра 40 мм."
	ammo_type = /obj/item/ammo_casing/a40mm/secgl/flash
	icon_state = "secgl_box_flash"

/obj/item/ammo_box/secgl/flash/get_ru_names()
	return list(
		NOMINATIVE = "коробка гранат (40 мм светошумовая)",
		GENITIVE = "коробки гранат (40 мм светошумовая)",
		DATIVE = "коробке гранат (40 мм светошумовая)",
		ACCUSATIVE = "коробку гранат (40 мм светошумовая)",
		INSTRUMENTAL = "коробкой гранат (40 мм светошумовая)",
		PREPOSITIONAL = "коробке гранат (40 мм светошумовая)",
	)

/obj/item/ammo_box/secgl/gas
	name = "ammo box (40mm teargas)"
	desc = "Коробка, содержащая гранаты со слезоточивым газом калибра 40 мм."
	ammo_type = /obj/item/ammo_casing/a40mm/secgl/gas

/obj/item/ammo_box/secgl/gas/get_ru_names()
	return list(
		NOMINATIVE = "коробка гранат (40 мм слезоточивый газ)",
		GENITIVE = "коробки гранат (40 мм слезоточивый газ)",
		DATIVE = "коробке гранат (40 мм слезоточивый газ)",
		ACCUSATIVE = "коробку гранат (40 мм слезоточивый газ)",
		INSTRUMENTAL = "коробкой гранат (40 мм слезоточивый газ)",
		PREPOSITIONAL = "коробке гранат (40 мм слезоточивый газ)",
	)

/obj/item/ammo_box/secgl/barricade
	name = "ammo box (40mm barricade)"
	desc = "Коробка, содержащая гранаты с баррикадой калибра 40 мм."
	ammo_type = /obj/item/ammo_casing/a40mm/secgl/barricade
	icon_state = "secgl_box_barricade"

/obj/item/ammo_box/secgl/barricade/get_ru_names()
	return list(
		NOMINATIVE = "коробка гранат (40 мм баррикада)",
		GENITIVE = "коробки гранат (40 мм баррикада)",
		DATIVE = "коробке гранат (40 мм баррикада)",
		ACCUSATIVE = "коробку гранат (40 мм баррикада)",
		INSTRUMENTAL = "коробкой гранат (40 мм баррикада)",
		PREPOSITIONAL = "коробке гранат (40 мм баррикада)",
	)

/obj/item/ammo_box/secgl/exp
	name = "ammo box (40mm frag)"
	desc = "Коробка, содержащая осколочные гранаты калибра 40 мм."
	ammo_type = /obj/item/ammo_casing/a40mm/secgl/exp
	icon_state = "secgl_box_exp"

/obj/item/ammo_box/secgl/exp/get_ru_names()
	return list(
		NOMINATIVE = "коробка гранат (40 мм осколочные)",
		GENITIVE = "коробки гранат (40 мм осколочные)",
		DATIVE = "коробке гранат (40 мм осколочные)",
		ACCUSATIVE = "коробку гранат (40 мм осколочные)",
		INSTRUMENTAL = "коробкой гранат (40 мм осколочные)",
		PREPOSITIONAL = "коробке гранат (40 мм осколочные)",
	)

/obj/item/ammo_box/secgl/paint
	name = "ammo box (40mm paint)"
	desc = "Коробка, содержащая гранаты с краской калибра 40 мм."
	ammo_type = /obj/item/ammo_casing/a40mm/secgl/paint
	icon_state = "secgl_box_paint"

/obj/item/ammo_box/secgl/paint/get_ru_names()
	return list(
		NOMINATIVE = "коробка гранат (40 мм краска)",
		GENITIVE = "коробки гранат (40 мм краска)",
		DATIVE = "коробке гранат (40 мм краска)",
		ACCUSATIVE = "коробку гранат (40 мм краска)",
		INSTRUMENTAL = "коробкой гранат (40 мм краска)",
		PREPOSITIONAL = "коробке гранат (40 мм краска)",
	)
