/obj/machinery/vending/chinese
	name = "\"Мистер Чанг\""
	desc = "Машина самообслуживания, созданная специально для удовлетворения вашей потребности в азиатской кухне."
	slogan_list = list(
		"Попр+обуйте 5000 лет культ+уры!",
		"\"М+истер Чанг\": од+обрено для безоп+асного потребл+ения в б+олее чем 10 сектор+ах!",
		"Ази+атская к+ухня отл+ично подх+одит для веч+ернего свид+ания или один+окого в+ечера!",
		"Вы не ошиб+ётесь, +если попр+обуете насто+ящую ази+атскую к+ухню от М+истера Ч+анга!",
		"Л+апша и рис, что м+ожет быть л+учше?"
	)

	icon_state = "chang_off"
	panel_overlay = "chang_panel"
	screen_overlay = "chang"
	lightmask_overlay = "chang_lightmask"
	broken_overlay = "chang_broken"
	broken_lightmask_overlay = "chang_broken_lightmask"
	refill_canister = /obj/item/vending_refill/chinese

	products = list(
		/obj/item/reagent_containers/food/snacks/chinese/chowmein = 6,
		/obj/item/reagent_containers/food/snacks/chinese/tao = 6,
		/obj/item/reagent_containers/food/snacks/chinese/sweetsourchickenball = 6,
		/obj/item/reagent_containers/food/snacks/chinese/newdles = 6,
		/obj/item/reagent_containers/food/snacks/chinese/rice = 6,
		/obj/item/reagent_containers/food/snacks/fortunecookie = 6,
		/obj/item/storage/box/crayfish_bucket = 5,
	)
	contraband = list(
		/obj/item/poster/cheng = 5,
		/obj/item/storage/box/mr_cheng = 3,
		/obj/item/clothing/head/rice_hat = 3,
		/obj/item/clothing/under/martialsuit/random = 1,
	)

/obj/machinery/vending/chinese/get_ru_names()
	return list(
		NOMINATIVE = "торговый автомат \"Мистер Чанг\"",
		GENITIVE = "торгового автомата \"Мистер Чанг\"",
		DATIVE = "торговому автомату \"Мистер Чанг\"",
		ACCUSATIVE = "торговый автомат \"Мистер Чанг\"",
		INSTRUMENTAL = "торговым автоматом \"Мистер Чанг\"",
		PREPOSITIONAL = "торговом автомате \"Мистер Чанг\"",
	)
