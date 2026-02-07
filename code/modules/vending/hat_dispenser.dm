/obj/machinery/vending/hatdispenser
	name = "Hatlord 9000"
	desc = "Торговый автомат по продаже головных уборов."
	icon_state = "hats_off"
	panel_overlay = "hats_panel"
	screen_overlay = "hats"
	lightmask_overlay = "hats_lightmask"
	broken_overlay = "hats_broken"
	broken_lightmask_overlay = "hats_broken_lightmask"
	slogan_list = list(
		"Вним+ание: не все шл+япы совмест+имы с соб+аками и обезь+янами. Надев+айте с ус+илием, но остор+ожно.",
		"Надев+айте пр+ямо на гол+ову.",
		"Кто не л+юбит тр+атить д+еньги на шл+япы?!",
		"От созд+ателей кор+обок с коллекц+ионными шл+япами — Hatlord!"
	)
	refill_canister = /obj/item/vending_refill/hatdispenser

	products = list(
		/obj/item/clothing/head/bowlerhat = 10,
		/obj/item/clothing/head/beaverhat = 10,
		/obj/item/clothing/head/boaterhat = 10,
		/obj/item/clothing/head/fedora = 10,
		/obj/item/clothing/head/fez = 10,
		/obj/item/clothing/head/beret = 10,
	)
	contraband = list(
		/obj/item/clothing/head/bearpelt = 5,
		/obj/item/clothing/head/helmet/biker = 1,
	)
	premium = list(
		/obj/item/clothing/head/soft/rainbow = 1,
	)

/obj/machinery/vending/hatdispenser/get_ru_names()
	return list(
		NOMINATIVE = "торговый автомат Hatlord 9000",
		GENITIVE = "торгового автомата Hatlord 9000",
		DATIVE = "торговому автомату Hatlord 9000",
		ACCUSATIVE = "торговый автомат Hatlord 9000",
		INSTRUMENTAL = "торговым автоматом Hatlord 9000",
		PREPOSITIONAL = "торговом автомате Hatlord 9000",
	)
