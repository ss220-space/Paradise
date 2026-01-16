/obj/machinery/vending/shoedispenser
	name = "Shoelord 9000"
	desc = "Оу, шляпы у Hatlord такие классные, костюмы у Suitlord такие элегантные, а у этого всё такое обычное... Дизайнер, должно быть, идиот."
	icon_state = "shoes_off"
	icon_state = "shoes_off"
	panel_overlay = "shoes_panel"
	screen_overlay = "shoes"
	lightmask_overlay = "shoes_lightmask"
	broken_overlay = "shoes_broken"
	broken_lightmask_overlay = "shoes_broken_lightmask"
	slogan_list = list(
		"Опуст+и н+огу!",
		"Один разм+ер подх+одит всем!",
		"Я ШАГ+АЮ В ЛУЧ+АХ С+ОЛНЦА!",
		"Х+оббитам вход воспрещ+ён.",
		"НЕТ, ПОЖ+АЛУЙСТА, В+ИЛЛИ, НЕ Д+ЕЛАЙ МНЕ Б+ОЛЬНО-*БЗЗЗЗ*"
	)
	refill_canister = /obj/item/vending_refill/shoedispenser

	products = list(
		/obj/item/clothing/shoes/color/black = 10,
		/obj/item/clothing/shoes/color/brown = 10,
		/obj/item/clothing/shoes/color/blue = 10,
		/obj/item/clothing/shoes/color/green = 10,
		/obj/item/clothing/shoes/color/yellow = 10,
		/obj/item/clothing/shoes/color/purple = 10,
		/obj/item/clothing/shoes/color/red = 10,
		/obj/item/clothing/shoes/color/white = 10,
		/obj/item/clothing/shoes/sandal=10,
		/obj/item/clothing/shoes/convers/red = 10,
		/obj/item/clothing/shoes/convers = 10,
		/obj/item/clothing/shoes/color/orange = 10,
	)
	contraband = list(
		/obj/item/clothing/shoes/color/orange/prison = 5,
	)
	premium = list(
		/obj/item/clothing/shoes/rainbow = 1,
	)

/obj/machinery/vending/shoedispenser/get_ru_names()
	return list(
		NOMINATIVE = "торговый автомат Shoelord 9000",
		GENITIVE = "торгового автомата Shoelord 9000",
		DATIVE = "торговому автомату Shoelord 9000",
		ACCUSATIVE = "торговый автомат Shoelord 9000",
		INSTRUMENTAL = "торговым автоматом Shoelord 9000",
		PREPOSITIONAL = "торговом автомате Shoelord 9000",
	)
