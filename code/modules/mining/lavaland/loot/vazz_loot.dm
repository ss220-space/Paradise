/obj/structure/closet/crate/necropolis/vazz
	name = "Vazz chest"

/obj/structure/closet/crate/necropolis/vazz/get_ru_names()
	return alist(
		NOMINATIVE = "сундук Вазза",
		GENITIVE = "сундука Вазза",
		DATIVE = "сундуку Вазза",
		ACCUSATIVE = "сундук Вазза",
		INSTRUMENTAL = "сундуком Вазза",
		PREPOSITIONAL = "сундуке Вазза",
	)

/obj/structure/closet/crate/necropolis/vazz/Initialize(mapload)
	. = ..()
	new /obj/item/clothing/suit/space/hostile_environment/mk2(src)
	new /obj/item/clothing/head/helmet/space/hostile_environment/mk2(src)
	new /obj/item/gem/vazz(src)

/obj/structure/closet/crate/necropolis/vazz/crusher
	name = "broken vazz chest"

/obj/structure/closet/crate/necropolis/vazz/crusher/get_ru_names()
	return alist(
		NOMINATIVE = "сломанный сундук Вазза",
		GENITIVE = "сломанного сундука Вазза",
		DATIVE = "сломанному сундуку Вазза",
		ACCUSATIVE = "сломанный сундук Вазза",
		INSTRUMENTAL = "сломанным сундуком Вазза",
		PREPOSITIONAL = "сломанном сундуке Вазза",
	)

/obj/structure/closet/crate/necropolis/vazz/crusher/Initialize(mapload)
	. = ..()
	new /obj/item/crusher_trophy/vazz_shard(src)
