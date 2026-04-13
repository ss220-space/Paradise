/obj/item/ammo_casing/caseless/arrow
	name = "arrow"
	desc = "Используется для стрельбы из лука. Самый примитивный вариант."
	gender = FEMALE
	icon_state = "arrow"
	item_state = "arrow"
	force = 10
	projectile_type = /obj/projectile/bullet/reusable/arrow
	muzzle_flash_effect = null
	caliber = CALIBER_ARROW

/obj/item/ammo_casing/caseless/arrow/get_ru_names()
	return list(
		NOMINATIVE = "деревянная стрела",
		GENITIVE = "деревянной стрелы",
		DATIVE = "деревянной стреле",
		ACCUSATIVE = "деревянную стрелу",
		INSTRUMENTAL = "деревянной стрелой",
		PREPOSITIONAL = "деревянной стреле",
	)

/obj/item/ammo_casing/caseless/arrow/update_names()
	return

/obj/item/ammo_casing/caseless/arrow/update_desc(updates = ALL)
	. = ..()
	desc = initial(desc)

/obj/item/ammo_casing/caseless/arrow/bone_tipped
	name = "bone-tipped arrow"
	desc = "Используется для стрельбы из лука. Выполнена из кости, дерева и сухожилий. Прочная и острая."
	icon_state = "bone_arrow"
	item_state = "bone_arrow"
	force = 12
	projectile_type = /obj/projectile/bullet/reusable/arrow/bone

/obj/item/ammo_casing/caseless/arrow/bone_tipped/get_ru_names()
	return list(
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
	icon_state = "jagged_arrow"
	force = 16
	projectile_type = /obj/projectile/bullet/reusable/arrow/jagged

/obj/item/ammo_casing/caseless/arrow/jagged/get_ru_names()
	return list(
		NOMINATIVE = "зазубренная стрела",
		GENITIVE = "зазубренной стрелы",
		DATIVE = "зазубренной стреле",
		ACCUSATIVE = "зазубренную стрелу",
		INSTRUMENTAL = "зазубренной стрелой",
		PREPOSITIONAL = "зазубренной стреле",
	)
