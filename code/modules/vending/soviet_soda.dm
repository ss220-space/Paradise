/obj/machinery/vending/sovietsoda
	name = "BODA"
	desc = "Старый автомат по продаже сладкой газировки."
	icon_state = "sovietsoda_off"
	panel_overlay = "sovietsoda_panel"
	screen_overlay = "sovietsoda"
	lightmask_overlay = "sovietsoda_lightmask"
	broken_overlay = "sovietsoda_broken"
	broken_lightmask_overlay = "sovietsoda_broken_lightmask"
	slogan_list = list(
		"За Р+одину!",
		"Ты уж+е осуществ+ил сво+ю н+орму пит+ания на сег+одня?",
		"+Очень хор+ошо!",
		"Жри что да+ют.",
		"+Если есть челов+ек, то есть и пробл+ема. +Если нет челов+ека, то нет и пробл+емы.",
		"П+артия уж+е позаб+отилась о в+ашем пит+ании."
	)
	resistance_flags = FIRE_PROOF
	refill_canister = /obj/item/vending_refill/sovietsoda

	products = list(
		/obj/item/reagent_containers/food/drinks/drinkingglass/soda = 30,
	)
	contraband = list(
		/obj/item/reagent_containers/food/drinks/drinkingglass/cola = 20,
	)

/obj/machinery/vending/sovietsoda/get_ru_names()
	return list(
		NOMINATIVE = "торговый автомат BODA",
		GENITIVE = "торгового автомата BODA",
		DATIVE = "торговому автомату BODA",
		ACCUSATIVE = "торговый автомат BODA",
		INSTRUMENTAL = "торговым автоматом BODA",
		PREPOSITIONAL = "торговом автомате BODA",
	)
