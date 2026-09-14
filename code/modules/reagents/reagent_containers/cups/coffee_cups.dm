// MARK: Coffee cups
/obj/item/reagent_containers/cup/glass/coffee_cup
	name = ""
	desc = ""
	max_integrity = 20
	isGlass = FALSE

/obj/item/reagent_containers/cup/glass/coffee_cup/examine(mob/user)
	. = ..()
	. += span_notice("Вмещает до <b>[volume]</b> единиц[declension_ru(volume, "ы", "", "")] вещества.")

/obj/item/reagent_containers/cup/glass/coffee_cup/on_reagent_change()
	update_icon(UPDATE_OVERLAYS)

/obj/item/reagent_containers/cup/glass/coffee_cup/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/coffeemaker_item_loader, "cups")

// MARK: Coffee cup
/obj/item/reagent_containers/cup/glass/coffee_cup/normal
	name = "coffee cup"
	desc = "Удобный бумажный стакан со снимающейся крышкой. Предназначен для питья кофе."
	icon_state = "coffeecup"
	base_icon_state = "coffeecup"
	possible_transfer_amounts = list(10,25,50)
	can_lid = TRUE
	fill_icon_thresholds = list(55, 70, 85, 100)

/obj/item/reagent_containers/cup/glass/coffee_cup/normal/get_ru_names()
	return alist(
		NOMINATIVE = "стакан кофе",
		GENITIVE = "стакана кофе",
		DATIVE = "стакану кофе",
		ACCUSATIVE = "стакан кофе",
		INSTRUMENTAL = "стаканом кофе",
		PREPOSITIONAL = "стакане кофе"
	)

// MARK: Small coffee cup
/obj/item/reagent_containers/cup/glass/coffee_cup/small
	name = "small coffee cup"
	desc = "Небольшой бумажный стакан. Обычно в таких подают кофе. Далеко не самый удобный."
	icon_state = "coffeecup_small"
	base_icon_state = "coffeecup_small"
	possible_transfer_amounts = list(10,30)
	volume = 30
	fill_icon_thresholds = list(40, 60, 80, 100)

/obj/item/reagent_containers/cup/glass/coffee_cup/small/get_ru_names()
	return alist(
		NOMINATIVE = "стаканчик кофе",
		GENITIVE = "стаканчика кофе",
		DATIVE = "стаканчику кофе",
		ACCUSATIVE = "стаканчик кофе",
		INSTRUMENTAL = "стаканчиком кофе",
		PREPOSITIONAL = "стаканчике кофе"
	)

/obj/item/reagent_containers/cup/glass/coffee_cup/small/coffee
	list_reagents = list("coffee" = 30)

/obj/item/reagent_containers/cup/glass/coffee_cup/small/coffee/experimentor
	name = "cup of suspicious liquid"
	desc = "На боковой стороне крупными, едва заметными, чернилами напечатан символ химической опасности."
	var/selected_reagent

/obj/item/reagent_containers/cup/glass/coffee_cup/small/coffee/experimentor/small/get_ru_names()
	return alist(
		NOMINATIVE = "стаканчик подозрительной жидкости",
		GENITIVE = "стаканчика подозрительной жидкости",
		DATIVE = "стаканчику подозрительной жидкости",
		ACCUSATIVE = "стаканчик подозрительной жидкости",
		INSTRUMENTAL = "стаканчиком подозрительной жидкости",
		PREPOSITIONAL = "стаканчике подозрительной жидкости"
	)

/obj/item/reagent_containers/cup/glass/coffee_cup/small/coffee/experimentor/Initialize(mapload)
	. = ..()
	spawn_reagent()

/obj/item/reagent_containers/cup/glass/coffee_cup/small/coffee/experimentor/proc/spawn_reagent()
	var/chosenchem = pick_reagent()
	selected_reagent = chosenchem
	reagents.remove_all(25)
	reagents.add_reagent(chosenchem, 50)

/obj/item/reagent_containers/cup/glass/coffee_cup/small/coffee/experimentor/proc/pick_reagent()
	return /datum/reagent/consumable/drink/coffee

/obj/item/reagent_containers/cup/glass/coffee_cup/small/coffee/experimentor/heat/pick_reagent()
	return pick(
		/datum/reagent/plasma,
		/datum/reagent/consumable/capsaicin,
		/datum/reagent/consumable/ethanol,
	)

/obj/item/reagent_containers/cup/glass/coffee_cup/small/coffee/experimentor/cold/pick_reagent()
	return pick(
		/datum/reagent/uranium,
		/datum/reagent/consumable/frostoil,
		/datum/reagent/medicine/ephedrine,
	)
