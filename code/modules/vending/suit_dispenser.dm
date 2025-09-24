/obj/machinery/vending/suitdispenser
	name = "Suitlord 9000"
	desc = "На мгновение вы задумываетесь, почему все ваши рубашки и брюки сшиты вместе. От этого у вас начинает болеть голова, и вы перестаёте."

	icon_state = "suits_off"
	panel_overlay = "suits_panel"
	screen_overlay = "suits"
	lightmask_overlay = "suits_lightmask"
	broken_overlay = "suits_broken"
	broken_lightmask_overlay = "suits_broken_lightmask"
	slogan_list = list(
		"Предвар+ительно прогл+аженный, предвар+ительно пост+иранный, предв+а-*БЗЗЗ*",
		"Кровь тво+их враг+ов ср+азу же см+оется!",
		"Что ВЫ н+осите?",
		"В+ыглядите элег+антно! В+ыглядите как иди+от!",
		"Не подх+одит по разм+еру? А как насч+ёт тог+о, чт+обы сбр+осить п+ару килогр+аммов, ты, ж+ирный лент+яй-*БЗЗЗЗ*"
	)
	refill_canister = /obj/item/vending_refill/suitdispenser

	products = list(
		/obj/item/clothing/under/color/black = 10,
		/obj/item/clothing/under/color/blue = 10,
		/obj/item/clothing/under/color/green = 10,
		/obj/item/clothing/under/color/grey = 10,
		/obj/item/clothing/under/color/pink = 10,
		/obj/item/clothing/under/color/red = 10,
		/obj/item/clothing/under/color/white = 10,
		/obj/item/clothing/under/color/yellow = 10,
		/obj/item/clothing/under/color/lightblue = 10,
		/obj/item/clothing/under/color/aqua = 10,
		/obj/item/clothing/under/color/purple = 10,
		/obj/item/clothing/under/color/lightgreen = 10,
		/obj/item/clothing/under/color/lightblue = 10,
		/obj/item/clothing/under/color/lightbrown = 10,
		/obj/item/clothing/under/color/brown = 10,
		/obj/item/clothing/under/color/yellowgreen = 10,
		/obj/item/clothing/under/color/darkblue = 10,
		/obj/item/clothing/under/color/lightred = 10,
		/obj/item/clothing/under/color/darkred = 10,
		/obj/item/clothing/under/colour/skirt = 10,
	)
	contraband = list(
		/obj/item/clothing/under/syndicate/tacticool = 5,
		/obj/item/clothing/under/color/orange = 5,
		/obj/item/clothing/under/syndicate/tacticool/skirt = 5,
	)
	premium = list(
		/obj/item/clothing/under/rainbow = 1,
	)

/obj/machinery/vending/suitdispenser/get_ru_names()
	return list(
		NOMINATIVE = "торговый автомат Suitlord 9000",
		GENITIVE = "торгового автомата Suitlord 9000",
		DATIVE = "торговому автомату Suitlord 9000",
		ACCUSATIVE = "торговый автомат Suitlord 9000",
		INSTRUMENTAL = "торговым автоматом Suitlord 9000",
		PREPOSITIONAL = "торговом автомате Suitlord 9000"
	)
