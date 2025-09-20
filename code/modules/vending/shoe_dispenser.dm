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

	products = list(/obj/item/clothing/shoes/black = 10,/obj/item/clothing/shoes/brown = 10,/obj/item/clothing/shoes/blue = 10,/obj/item/clothing/shoes/green = 10,/obj/item/clothing/shoes/yellow = 10,/obj/item/clothing/shoes/purple = 10,/obj/item/clothing/shoes/red = 10,/obj/item/clothing/shoes/white = 10,/obj/item/clothing/shoes/sandal=10,/obj/item/clothing/shoes/convers/red = 10,/obj/item/clothing/shoes/convers = 10)
	contraband = list(/obj/item/clothing/shoes/orange = 5)
	premium = list(/obj/item/clothing/shoes/rainbow = 1)
	refill_canister = /obj/item/vending_refill/shoedispenser

/obj/machinery/vending/shoedispenser/get_ru_names()
	return list(
		NOMINATIVE = "торговый автомат Shoelord 9000",
		GENITIVE = "торгового автомата Shoelord 9000",
		DATIVE = "торговому автомату Shoelord 9000",
		ACCUSATIVE = "торговый автомат Shoelord 9000",
		INSTRUMENTAL = "торговым автоматом Shoelord 9000",
		PREPOSITIONAL = "торговом автомате Shoelord 9000"
	)
