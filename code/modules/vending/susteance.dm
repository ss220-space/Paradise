/obj/machinery/vending/sustenance
	name = "Sustenance Vendor"
	desc = "Торговый автомат, в котором продаются продукты питания, в соответствии с разделом 47-С Соглашения об этическом обращении с заключёнными \"Нанотрейзен\"."
	slogan_list = list(
		"При+ятного аппет+ита!",
		"Дост+аточное кол+ичество кал+орий для интенс+ивной раб+оты.",
		"С+амый здор+овый!",
		"Отм+еченные нагр+адами шокол+адные бат+ончики!",
		"Ммм! Так вк+усно!",
		"О б+оже, +это так вк+усно!",
		"Перекус+ите.",
		"Зак+уски - +это зд+орово!",
		"Возьм+и немн+ого, и ещ+ё немн+ого!",
		"Зак+уски в+ысшего к+ачества пр+ямо с М+арса.",
		"Мы л+юбим шокол+ад!",
		"Попр+обуйте н+аше н+овое в+яленое м+ясо!"
	)
	icon_state = "sustenance_off"
	panel_overlay = "snack_panel"
	screen_overlay = "snack"
	lightmask_overlay = "snack_lightmask"
	broken_overlay = "snack_broken"
	broken_lightmask_overlay = "snack_broken_lightmask"
	broken_lightmask_overlay = "snack_broken_lightmask"
	refill_canister = /obj/item/vending_refill/sustenance
	default_price = PAYCHECK_MIN / 2 // prisoners are very poor
	default_premium_price = PAYCHECK_LOWER / 2

	products = list(
		/obj/item/reagent_containers/food/snacks/tofu = 24,
		/obj/item/reagent_containers/food/drinks/ice = 12,
		/obj/item/reagent_containers/food/snacks/candy/candy_corn = 6,
	)
	contraband = list(
		/obj/item/kitchen/knife = 6,
		/obj/item/reagent_containers/food/drinks/cups/coffee_cup/small/coffee = 12,
		/obj/item/tank/internals/emergency_oxygen = 6,
		/obj/item/clothing/mask/breath = 6,
	)

/obj/machinery/vending/sustenance/get_ru_names()
	return list(
		NOMINATIVE = "торговый автомат Sustenance Vendor",
		GENITIVE = "торгового автомата Sustenance Vendor",
		DATIVE = "торговому автомату Sustenance Vendor",
		ACCUSATIVE = "торговый автомат Sustenance Vendor",
		INSTRUMENTAL = "торговым автоматом Sustenance Vendor",
		PREPOSITIONAL = "торговом автомате Sustenance Vendor",
	)

/obj/machinery/vending/sustenance/additional
	desc = "Какого чёрта этот автомат тут оказался?!"
	products = list(
		/obj/item/reagent_containers/food/snacks/tofu = 12,
		/obj/item/reagent_containers/food/drinks/ice = 6,
		/obj/item/reagent_containers/food/snacks/candy/candy_corn = 6,
	)
	contraband = list(
		/obj/item/kitchen/knife = 2,
	)
