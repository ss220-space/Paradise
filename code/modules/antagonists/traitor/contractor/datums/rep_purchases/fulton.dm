/**
  * # Rep Purchase - Fulton Extraction Kit
  */
/datum/rep_purchase/item/fulton
	name = "Набор для эвакуации \"Фултон\""
	description = "Устройство, похожее на шахтёрское оборудование, но предназначенное для работы на космической станции. Оно используется для транспортировки целей в труднодоступные места."
	cost = 1
	stock = 2
	item_type = /obj/item/storage/box/contractor/fulton_kit

/obj/item/extraction_pack/contractor
	name = "black fulton extraction pack"
	desc = "Модифицированный Фултон, который можно использовать в помещении благодаря блюспейс-технологиям. Пользуется спросом у Контрактников Синдиката."
	ru_names = list(
		NOMINATIVE = "система эвакуации \"Фултон\"",
		GENITIVE = "системы эвакуации \"Фултон\"",
		DATIVE = "системе эвакуации \"Фултон\"",
		ACCUSATIVE = "систему эвакуации \"Фултон\"",
		INSTRUMENTAL = "системой эвакуации \"Фултон\"",
		PREPOSITIONAL = "системе эвакуации \"Фултон\""
	)
	icon_state = "black"
	can_use_indoors = TRUE

/obj/item/storage/box/contractor/fulton_kit
	name = "fulton extraction kit"
	ru_names = list(
		NOMINATIVE = "набор для эвакуации Фултон",
		GENITIVE = "набора для эвакуации Фултон",
		DATIVE = "набору для эвакуации Фултон",
		ACCUSATIVE = "набор для эвакуации Фултон",
		INSTRUMENTAL = "набором для эвакуации Фултон",
		PREPOSITIONAL = "наборе для эвакуации Фултон"
	)
	gender = MALE
	icon_state = "box_of_doom"

/obj/item/storage/box/contractor/fulton_kit/populate_contents()
	new /obj/item/extraction_pack/contractor(src)
	new /obj/item/fulton_core(src)
