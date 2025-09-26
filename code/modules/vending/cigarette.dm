/obj/machinery/vending/cigarette
	name = "ShadyCigs Deluxe"
	desc = "Если вы собираетесь заболеть раком, по крайней мере, сделайте это стильно!"
	slogan_list = list(
		"Космосигар+еты весьм+а хор+оши на вкус, как+ими он+и и должн+ы быть!",
		"Затян+итесь!",
		"Не в+ерьте иссл+едованиям — кур+ите!",
		"Наверняк+а не +очень-то и вр+едно для вас!",
		"Не в+ерьте уч+ёным!",
		"На здор+овье!",
		"Не брос+айте кур+ить, куп+ите ещ+ё!",
		"Никот+иновый рай!",
		"Л+учшие сигар+еты с 2150 г+ода!",
		"Сигар+еты со мн+ожеством нагр+ад!",
		"Наверняк+а не +очень-то и вр+едно для вас!",
		"Никот+ин провед+ёт ч+ерез безд+енежье л+учше, чем д+еньги ч+ерез безникот+инье!",
		"На здор+овье!",
		"Включ+и, подожг+и, закур+и!",
		"С табак+ом жить весел+ей!",
		"Затян+итесь!",
		"Сохран+яй ул+ыбку на уст+ах и п+есню в сво+ём с+ердце!",
	)
	icon_state = "cigs_off"
	panel_overlay = "cigs_panel"
	screen_overlay = "cigs"
	lightmask_overlay = "cigs_lightmask"
	broken_overlay = "cigs_broken"
	broken_lightmask_overlay = "cigs_broken_lightmask"
	refill_canister = /obj/item/vending_refill/cigarette

	product_categories = list(
		list(
			"name" = "Курительные приспособления",
			"icon" = "smoking",
			"products" = list(
				/obj/item/storage/fancy/cigarettes/cigpack_robust = 12,
				/obj/item/storage/fancy/cigarettes/cigpack_uplift = 6,
				/obj/item/storage/fancy/cigarettes/cigpack_random = 6,
				/obj/item/storage/fancy/cigarettes/cigpack_robustgold = 1,
				/obj/item/clothing/mask/cigarette/cigar/havana = 2,
			),
		),
		list(
			"name" = "Зажигательные приспособления",
			"icon" = "fire",
			"products" = list(
				/obj/item/storage/box/matches = 10,
				/obj/item/lighter/random = 4,
				/obj/item/lighter/zippo = 4,
			),
		),
		list(
			"name" = "Другое",
			"icon" = "ellipsis",
			"products" = list(
				/obj/item/reagent_containers/food/pill/patch/nicotine = 10,
				/obj/item/storage/fancy/rollingpapers = 5,
			),
		),
	)
	contraband = list(
		/obj/item/clothing/mask/cigarette/pipe/oldpipe = 3,
		/obj/item/storage/fancy/cigarettes/cigpack_med = 1,
	)
	prices = list(
		/obj/item/storage/fancy/cigarettes/cigpack_robust = 179,
		/obj/item/storage/fancy/cigarettes/cigpack_uplift = 239,
		/obj/item/storage/fancy/cigarettes/cigpack_random = 359,
		/obj/item/reagent_containers/food/pill/patch/nicotine = 69,
		/obj/item/storage/box/matches = 9,
		/obj/item/lighter/random = 59,
		/obj/item/storage/fancy/rollingpapers = 19,
		/obj/item/clothing/mask/cigarette/pipe/oldpipe = 249,
		/obj/item/lighter/zippo = 249,
		/obj/item/clothing/mask/cigarette/cigar/havana = 999,
		/obj/item/storage/fancy/cigarettes/cigpack_robustgold = 699,
		/obj/item/storage/fancy/cigarettes/cigpack_med = 499,
	)

/obj/machinery/vending/cigarette/get_ru_names()
	return list(
		NOMINATIVE = "торговый автомат ShadyCigs Deluxe",
		GENITIVE = "торгового автомата ShadyCigs Deluxe",
		DATIVE = "торговому автомату ShadyCigs Deluxe",
		ACCUSATIVE = "торговый автомат ShadyCigs Deluxe",
		INSTRUMENTAL = "торговым автоматом ShadyCigs Deluxe",
		PREPOSITIONAL = "торговом автомате ShadyCigs Deluxe"
	)

/obj/machinery/vending/cigarette/free
	prices = list()

/obj/machinery/vending/cigarette/syndicate
	product_categories = list(
		list(
			"name" = "Курительные приспособления",
			"icon" = "smoking",
			"products" = list(
				/obj/item/storage/fancy/cigarettes/cigpack_syndicate = 7,
				/obj/item/storage/fancy/cigarettes/cigpack_uplift = 3,
				/obj/item/storage/fancy/cigarettes/cigpack_robust = 2,
				/obj/item/storage/fancy/cigarettes/cigpack_carp = 3,
				/obj/item/storage/fancy/cigarettes/cigpack_midori = 1,
			),
		),
		list(
			"name" = "Зажигательные приспособления",
			"icon" = "fire",
			"products" = list(
				/obj/item/storage/box/matches = 10,
				/obj/item/lighter/zippo = 4,
			),
		),
		list(
			"name" = "Другое",
			"icon" = "ellipsis",
			"products" = list(
				/obj/item/storage/fancy/rollingpapers = 5,
			),
		),
	)

/obj/machinery/vending/cigarette/syndicate/free
	prices = list()


/obj/machinery/vending/cigarette/beach //Used in the lavaland_biodome_beach.dmm ruin
	name = "ShadyCigs Ultra"
	desc = "Теперь с дополнительными продуктами премиум-класса!"
	slogan_list = list(
		"Наверняк+а не +очень-то и вр+едно для вас!",
		"Никот+ин провед+ёт ч+ерез безд+енежье л+учше, чем д+еньги ч+ерез безникот+инье!",
		"На здор+овье!",
		"Включ+и, подожг+и, закур+и!",
		"С табак+ом жить весел+ей!",
		"Затян+итесь!",
		"Сохран+яй ул+ыбку на уст+ах и п+есню в сво+ём с+ердце!"
	)

	product_categories = list(
		list(
			"name" = "Курительные приспособления",
			"icon" = "smoking",
			"products" = list(
				/obj/item/storage/fancy/cigarettes = 5,
				/obj/item/storage/fancy/cigarettes/cigpack_uplift = 3,
				/obj/item/storage/fancy/cigarettes/cigpack_robust = 3,
				/obj/item/storage/fancy/cigarettes/cigpack_carp = 3,
				/obj/item/storage/fancy/cigarettes/cigpack_midori = 3,
			),
		),
		list(
			"name" = "Зажигательные приспособления",
			"icon" = "fire",
			"products" = list(
				/obj/item/storage/box/matches = 10,
				/obj/item/lighter/random = 4,
			),
		),
		list(
			"name" = "Другое",
			"icon" = "ellipsis",
			"products" = list(
				/obj/item/storage/fancy/rollingpapers = 5,
			),
		),
	)
	premium = list(
		/obj/item/clothing/mask/cigarette/cigar/havana = 2,
		/obj/item/storage/fancy/cigarettes/cigpack_robustgold = 1,
		/obj/item/lighter/zippo = 3,
	)
	prices = list()

/obj/machinery/vending/cigarette/beach/get_ru_names()
	return list(
		NOMINATIVE = "торговый автомат ShadyCigs Ultra",
		GENITIVE = "торгового автомата ShadyCigs Ultra",
		DATIVE = "торговому автомату ShadyCigs Ultra",
		ACCUSATIVE = "торговый автомат ShadyCigs Ultra",
		INSTRUMENTAL = "торговым автоматом ShadyCigs Ultra",
		PREPOSITIONAL = "торговом автомате ShadyCigs Ultra"
	)
