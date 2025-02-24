/**
  * # Rep Purchase - Fulton Extraction Kit
  */
/datum/rep_purchase/item/fulton
	name = "Набор для эвакуации Фултон"
	description = "Устройство, похожее на шахтёрский набор, но предназначенное для работы на космической станции. Оно используется для транспортировки целей в труднодоступные места."
	cost = 1
	stock = 2
	item_type = /obj/item/storage/box/contractor/fulton_kit

/obj/item/extraction_pack/contractor
	name = "black fulton extraction pack"
	desc = "Модифицированный фултон, который можно использовать в помещении благодаря технологии блюспейс. Пользуется спросом у Контракторов Синдиката."
	ru_names = list(
		NOMINATIVE = "чёрный фултон пакет",
		GENITIVE = "чёрного фултон пакета",
		DATIVE = "чёрному фултон пакету",
		ACCUSATIVE = "чёрный фултон пакет",
		INSTRUMENTAL = "чёрным фултон пакетом",
		PREPOSITIONAL = "чёрном фултон пакете"
	)
	gender = MALE
	icon_state = "black"
	can_use_indoors = TRUE

/obj/item/storage/box/contractor/fulton_kit
	name = "fulton extraction kit"
	ru_names = list(
		NOMINATIVE = "набор для эвакуации фултон",
		GENITIVE = "набора для эвакуации фултон",
		DATIVE = "набору для эвакуации фултон",
		ACCUSATIVE = "набор для эвакуации фултон",
		INSTRUMENTAL = "набором для эвакуации фултон",
		PREPOSITIONAL = "наборе для эвакуации фултон"
	)
	gender = MALE
	icon_state = "box_of_doom"

/obj/item/storage/box/contractor/fulton_kit/populate_contents()
	new /obj/item/extraction_pack/contractor(src)
	new /obj/item/fulton_core(src)
