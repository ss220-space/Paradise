/**
 * MARK: Base cartridge
 */

/obj/item/coffee_cartridge
	name = "coffeemaker cartridge – Caffè Generico"
	desc = "Картридж, содержащий перемолотые кофейные зёрна. Совместим с кофемашиной \"Моделло 3\". \
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

/**
 * MARK: Fancy cartridge
 */

/obj/item/coffee_cartridge/fancy
	name = "coffeemaker cartridge – Caffè Fantasioso"
	desc = "Преимального качества картридж, содержащий перемолотые кофейные зёрна. \
			Совместим с кофемашиной \"Моделло 3\". \
			Произведён компанией \"Бытовая Техника Пиччонайя\"."
	icon_state = "cartridge_blend"
	/// Associated cartridge datum
	var/datum/coffee_cartridge_type/cartridge_type

/obj/item/coffee_cartridge/fancy/get_ru_names()
	return list(
		NOMINATIVE = "кофе-картридж \"Каффе Фантазиосо\"",
		GENITIVE = "кофе-картриджа \"Каффе Фантазиосо\"",
		DATIVE = "кофе-картриджу \"Каффе Фантазиосо\"",
		ACCUSATIVE = "кофе-картридж \"Каффе Фантазиосо\"",
		INSTRUMENTAL = "кофе-картриджем \"Каффе Фантазиосо\"",
		PREPOSITIONAL = "кофе-картридже \"Каффе Фантазиосо\"",
	)

// Yep, same reagent for every cartridge – that's intentional
/obj/item/coffee_cartridge/fancy/Initialize(mapload)
	. = ..()

	// Picking a random type
	var/list/types = list(
		/datum/coffee_cartridge_type/blend,
		/datum/coffee_cartridge_type/blue_mountain,
		/datum/coffee_cartridge_type/kilimanjaro,
		/datum/coffee_cartridge_type/mocha,
	)
	var/chosen_type = pick(types)
	cartridge_type = new chosen_type()

	// Applying parameters from the datum
	name = "coffeemaker cartridge – [cartridge_type.name_en]"
	var/type_name = cartridge_type.ru_name_base
	ru_names = list(
		NOMINATIVE = "кофейный картридж \"[type_name]\"",
		GENITIVE = "кофейного картриджа \"[type_name]\"",
		DATIVE = "кофейному картриджу \"[type_name]\"",
		ACCUSATIVE = "кофейный картридж \"[type_name]\"",
		INSTRUMENTAL = "кофейным картриджем \"[type_name]\"",
		PREPOSITIONAL = "кофейном картридже \"[type_name]\"",
	)
	icon_state = cartridge_type.icon_state

/**
 * MARK: Decaf cartridge
 */

//TODO: make it actually decaf, maybe by adding a reagent that reduces caffeine's effects or sum?
/obj/item/coffee_cartridge/decaf
	name = "coffeemaker cartridge – Caffè Decaffeinato"
	desc = "Картридж, содержащий перемолотые кофейные зёрна, из которых был искусственно удалён кофеин. \
			Совместим с кофемашиной \"Моделло 3\". Произведён компанией \"Бытовая Техника Пиччонайя\"."
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

/**
 * MARK: Bootleg cartridge
 */

// no you can't just squeeze the juice bag into a glass!
/obj/item/coffee_cartridge/bootleg
	name = "coffeemaker cartridge – Botany Blend"
	desc = "Самодельный картридж, содержащий перемолотые кофейные зёрна. Теоретически совместим с кофемашиной \"Моделло 3\", \
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

/**
 * MARK: Blank cartridge
 */

/obj/item/blank_coffee_cartridge
	name = "blank coffee cartridge"
	desc = "Пустой картридж для перемолотых кофейных зёрен. Совместим с кофемашиной \"Моделло 3\"."
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
