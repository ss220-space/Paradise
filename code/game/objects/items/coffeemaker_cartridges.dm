/obj/item/coffee_cartridge
	name = "coffeemaker cartridge – Caffè Generico"
	desc = "Картридж, содержащий перемолотые кофейные зёрна. \
			Совместим с кофемашиной \"Моделло 3\". \
			Произведён компанией \"Бытовая Техника Пиччонайя\"."
	gender = MALE
	icon = 'icons/obj/food/cartridges.dmi'
	icon_state = "cartridge_basic"
	w_class = WEIGHT_CLASS_SMALL
	var/charges = 4
	var/list/drink_type = list("coffee" = 150)

/obj/item/coffee_cartridge/get_ru_names()
	return list(
		NOMINATIVE = "кофейный картридж \"Каффе Дженерико\"",
		GENITIVE = "кофейного картриджа \"Каффе Дженерико\"",
		DATIVE = "кофейному картриджу \"Каффе Дженерико\"",
		ACCUSATIVE = "кофейный картридж \"Каффе Дженерико\"",
		INSTRUMENTAL = "кофейным картриджем \"Каффе Дженерико\"",
		PREPOSITIONAL = "кофейном картридже \"Каффе Дженерико\""
	)

/obj/item/coffee_cartridge/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/coffeemaker_item_loader)

/obj/item/coffee_cartridge/examine(mob/user)
	. = ..()
	if(charges)
		. += span_notice("Хватит ещё на <b>[charges]</b> использовани[declension_ru(charges, "е", "я", "й")].")
	else
		. += span_notice("<b>Пусто</b>.")

/obj/item/coffee_cartridge/fancy
	name = "coffeemaker cartridge – Caffè Fantasioso"
	desc = "Преимального качества картридж, содержащий перемолотые кофейные зёрна. \
			Совместим с кофемашиной \"Моделло 3\". \
			Произведён компанией \"Бытовая Техника Пиччонайя\"."
	icon_state = "cartridge_blend"

/obj/item/coffee_cartridge/fancy/get_ru_names()
	return list(
		NOMINATIVE = "премиальный кофе-картридж \"Каффе Фантазиосо\"",
		GENITIVE = "премиального кофе-картриджа \"Каффе Фантазиосо\"",
		DATIVE = "премиальному кофе-картриджу \"Каффе Фантазиосо\"",
		ACCUSATIVE = "премиальный кофе-картридж \"Каффе Фантазиосо\"",
		INSTRUMENTAL = "премиальным кофе-картриджем \"Каффе Фантазиосо\"",
		PREPOSITIONAL = "премиальном кофе-картридже \"Каффе Фантазиосо\"",
	)

/obj/item/coffee_cartridge/fancy/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/coffeemaker_item_loader)

// Yep, same reagent for every cartridge – that's intentional
/obj/item/coffee_cartridge/fancy/Initialize(mapload)
	. = ..()
	var/coffee_type = pick("blend", "blue_mountain", "kilimanjaro", "mocha")
	switch(coffee_type)
		if("blend")
			name = "coffeemaker cartridge – Miscela di Piccione"
			ru_names = list(
				NOMINATIVE = "премиальный кофе-картридж \"Миццела Де Пиччионе\"",
				GENITIVE = "премиального кофе-картриджа \"Миццела Де Пиччионе\"",
				DATIVE = "премиальному кофе-картриджу \"Миццела Де Пиччионе\"",
				ACCUSATIVE = "премиальный кофе-картридж \"Миццела Де Пиччионе\"",
				INSTRUMENTAL = "премиальным кофе-картриджем \"Миццела Де Пиччионе\"",
				PREPOSITIONAL = "премиальном кофе-картридже \"Миццела Де Пиччионе\""
			)
			icon_state = "cartridge_blend"
		if("blue_mountain")
			name = "coffeemaker cartridge – Montagna Blu"
			ru_names = list(
				NOMINATIVE = "премиальный кофе-картридж \"Монтанна Блю\"",
				GENITIVE = "премиального кофе-картриджа \"Монтанна Блю\"",
				DATIVE = "премиальному кофе-картриджу \"Монтанна Блю\"",
				ACCUSATIVE = "премиальный кофе-картридж \"Монтанна Блю\"",
				INSTRUMENTAL = "премиальным кофе-картриджем \"Монтанна Блю\"",
				PREPOSITIONAL = "премиальном кофе-картридже \"Монтанна Блю\""
			)
			icon_state = "cartridge_blue_mtn"
		if("kilimanjaro")
			name = "coffeemaker cartridge – Kilimangiaro"
			ru_names = list(
				NOMINATIVE = "премиальный кофе-картридж \"Килиманджаро\"",
				GENITIVE = "премиального кофе-картриджа \"Килиманджаро\"",
				DATIVE = "премиальному кофе-картриджу \"Килиманджаро\"",
				ACCUSATIVE = "премиальный кофе-картридж \"Килиманджаро\"",
				INSTRUMENTAL = "премиальным кофе-картриджем \"Килиманджаро\"",
				PREPOSITIONAL = "премиальном кофе-картридже \"Килиманджаро\""
			)
			icon_state = "cartridge_kilimanjaro"
		if("mocha")
			name = "coffeemaker cartridge – Moka Arabica"
			ru_names = list(
				NOMINATIVE = "премиальный кофе-картридж \"Моккачино Арабика\"",
				GENITIVE = "премиального кофе-картриджа \"Моккачино Арабика\"",
				DATIVE = "премиальному кофе-картриджу \"Моккачино Арабика\"",
				ACCUSATIVE = "премиальный кофе-картридж \"Моккачино Арабика\"",
				INSTRUMENTAL = "премиальным кофе-картриджем \"Моккачино Арабика\"",
				PREPOSITIONAL = "премиальном кофе-картридже \"Моккачино Арабика\""
			)
			icon_state = "cartridge_mocha"

/obj/item/coffee_cartridge/decaf
	name = "coffeemaker cartridge – Caffè Decaffeinato"
	desc = "Картридж, содержащий перемолотые кофейные зёрна, \
			из которых был искусственно удалён кофеин. \
			Совместим с кофемашиной \"Моделло 3\". \
			Произведён компанией \"Бытовая Техника Пиччонайя\"."
	icon_state = "cartridge_decaf"

/obj/item/coffee_cartridge/decaf/get_ru_names()
	return list(
		NOMINATIVE = "кофе-картридж \"Каффе Декаффинато\"",
		GENITIVE = "кофе-картриджа \"Каффе Декаффинато\"",
		DATIVE = "кофе-картриджу \"Каффе Декаффинато\"",
		ACCUSATIVE = "кофе-картридж \"Каффе Декаффинато\"",
		INSTRUMENTAL = "кофе-картриджем \"Каффе Декаффинато\"",
		PREPOSITIONAL = "кофе-картридже \"Каффе Декаффинато\""
	)

/obj/item/coffee_cartridge/decaf/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/coffeemaker_item_loader)

// no you can't just squeeze the juice bag into a glass!
/obj/item/coffee_cartridge/bootleg
	name = "coffeemaker cartridge – Botany Blend"
	desc = "Самодельный картридж, содержащий перемолотые кофейные зёрна. \
			Теоретически совместим с кофемашиной \"Моделло 3\", \
			но никто этого не гарантирует."
	icon_state = "cartridge_bootleg"

/obj/item/coffee_cartridge/bootleg/get_ru_names()
	return list(
		NOMINATIVE = "кофе-картридж \"Ботанический специальный\"",
		GENITIVE = "кофе-картриджа \"Ботанический специальный\"",
		DATIVE = "кофе-картриджу \"Ботанический специальный\"",
		ACCUSATIVE = "кофе-картридж \"Ботанический специальный\"",
		INSTRUMENTAL = "кофе-картриджем \"Ботанический специальный\"",
		PREPOSITIONAL = "кофе-картридже \"Ботанический специальный\""
	)

/obj/item/coffee_cartridge/bootleg/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/coffeemaker_item_loader)

/obj/item/blank_coffee_cartridge
	name = "blank coffee cartridge"
	desc = "Пустой картридж для перемолотых кофейных зёрен. \
			Совместим с кофемашиной \"Моделло 3\"."
	gender = MALE
	icon = 'icons/obj/food/cartridges.dmi'
	icon_state = "cartridge_blank"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/blank_coffee_cartridge/get_ru_names()
	return list(
		NOMINATIVE = "пустой кофе-картридж",
		GENITIVE = "пустого кофе-картриджа",
		DATIVE = "пустому кофе-картриджу",
		ACCUSATIVE = "пустой кофе-картридж",
		INSTRUMENTAL = "пустым кофе-картриджем",
		PREPOSITIONAL = "пустом кофе-картридже"
	)
