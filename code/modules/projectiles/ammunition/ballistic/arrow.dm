/obj/item/ammo_casing/caseless/arrow
	name = "arrow"
	desc = "Используется для стрельбы из лука. Самый примитивный вариант."
	ammo_marking = "\"деревянная стрела\""
	icon_state = "arrow"
	item_state = "arrow"
	force = 10
	sharp = TRUE
	projectile_type = /obj/projectile/bullet/reusable/arrow
	muzzle_flash_effect = null
	caliber = CALIBER_ARROW
	no_update_names = TRUE
	no_update_desc = TRUE

/obj/item/ammo_casing/caseless/arrow/get_ru_names()
	return alist(
		NOMINATIVE = "деревянная стрела",
		GENITIVE = "деревянной стрелы",
		DATIVE = "деревянной стреле",
		ACCUSATIVE = "деревянную стрелу",
		INSTRUMENTAL = "деревянной стрелой",
		PREPOSITIONAL = "деревянной стреле",
	)

/obj/item/ammo_casing/caseless/arrow/bone_tipped
	name = "bone-tipped arrow"
	desc = "Используется для стрельбы из лука. Выполнена из кости, дерева и сухожилий. Прочная и острая."
	ammo_marking = "\"костяная стрела\""
	icon_state = "bone_arrow"
	item_state = "bone_arrow"
	force = 12
	projectile_type = /obj/projectile/bullet/reusable/arrow/bone

/obj/item/ammo_casing/caseless/arrow/bone_tipped/get_ru_names()
	return alist(
		NOMINATIVE = "костяная стрела",
		GENITIVE = "костяной стрелы",
		DATIVE = "костяной стреле",
		ACCUSATIVE = "костяную стрелу",
		INSTRUMENTAL = "костяной стрелой",
		PREPOSITIONAL = "костяной стреле",
	)

/obj/item/ammo_casing/caseless/arrow/jagged
	name = "jagged-tipped arrow"
	desc = "Используется для стрельбы из лука. Выполнена из зубов хищной рыбы. Невероятно острая и крепкая."
	ammo_marking = "\"зазубренная стрела\""
	icon_state = "jagged_arrow"
	force = 16
	projectile_type = /obj/projectile/bullet/reusable/arrow/jagged

/obj/item/ammo_casing/caseless/arrow/jagged/get_ru_names()
	return alist(
		NOMINATIVE = "зазубренная стрела",
		GENITIVE = "зазубренной стрелы",
		DATIVE = "зазубренной стреле",
		ACCUSATIVE = "зазубренную стрелу",
		INSTRUMENTAL = "зазубренной стрелой",
		PREPOSITIONAL = "зазубренной стреле",
	)

/obj/item/ammo_casing/caseless/arrow/modern
	name = "modern arrow"
	desc = "Используется для стрельбы из лука. Стрела из высококачественных композитных материалов."
	ammo_marking = "\"композитная стрела\""
	icon_state = "arrow_modern"
	item_state = "arrow_modern"
	force = 30
	projectile_type = /obj/projectile/bullet/reusable/arrow/modern

/obj/item/ammo_casing/caseless/arrow/modern/get_ru_names()
	return alist(
		NOMINATIVE = "композитная стрела",
		GENITIVE = "композитной стрелы",
		DATIVE = "композитной стреле",
		ACCUSATIVE = "композитную стрелу",
		INSTRUMENTAL = "композитной стрелой",
		PREPOSITIONAL = "композитной стреле",
	)

/obj/item/ammo_casing/caseless/arrow/homemade
	name = "homemade arrow"
	desc = "Используется для стрельбы из лука. Подобие стрелы из куска арматуры с ближайшей кучи мусора. Как этим вообще можно стрелять?"
	ammo_marking = "\"самодельная стрела\""
	icon_state = "arrow_homemade"
	item_state = "arrow_homemade"
	projectile_type = /obj/projectile/bullet/reusable/arrow/homemade

/obj/item/ammo_casing/caseless/arrow/homemade/get_ru_names()
	return alist(
		NOMINATIVE = "самодельная стрела",
		GENITIVE = "самодельной стрелы",
		DATIVE = "самодельной стреле",
		ACCUSATIVE = "самодельную стрелу",
		INSTRUMENTAL = "самодельной стрелой",
		PREPOSITIONAL = "самодельной стреле",
	)
