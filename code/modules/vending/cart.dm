/obj/machinery/vending/cart
	name = "PTech"
	desc = "Торговый автомат от компании \"PTech\": \"лучшие КПК в галактике!\""
	slogan_list = list(
		"Не заб+удьте закуп+ить п+ару к+артриджей!",
		"К+артриджы и КПК! КПК и к+артриджи!",
		"Как портат+ивно! Как уд+обно!"
	)

	icon_state = "cart_off"
	panel_overlay = "cart_panel"
	screen_overlay = "cart"
	lightmask_overlay = "cart_lightmask"
	broken_overlay = "cart_broken"
	broken_lightmask_overlay = "cart_broken_lightmask"
	deny_overlay = "cart_deny"

	products = list(/obj/item/pda = 10,
					/obj/item/eftpos = 6,
					/obj/item/cartridge/medical = 10,
					/obj/item/cartridge/chemistry = 10,
					/obj/item/cartridge/engineering = 10,
					/obj/item/cartridge/atmos = 10,
					/obj/item/cartridge/janitor = 10,
					/obj/item/cartridge/signal/toxins = 10,
					/obj/item/cartridge/signal = 10)
	contraband = list(/obj/item/cartridge/clown = 1,/obj/item/cartridge/mime = 1)
	prices = list(/obj/item/pda = 299,
					/obj/item/eftpos = 199,
					/obj/item/cartridge/medical = 199,
					/obj/item/cartridge/chemistry = 149,
					/obj/item/cartridge/engineering = 99,
					/obj/item/cartridge/atmos = 69,
					/obj/item/cartridge/janitor = 99,
					/obj/item/cartridge/signal/toxins = 149,
					/obj/item/cartridge/signal = 69)
	refill_canister = /obj/item/vending_refill/cart

/obj/machinery/vending/cart/get_ru_names()
	return list(
		NOMINATIVE = "торговый автомат PTech",
		GENITIVE = "торгового автомата PTech",
		DATIVE = "торговому автомату PTech",
		ACCUSATIVE = "торговый автомат PTech",
		INSTRUMENTAL = "торговым автоматом PTech",
		PREPOSITIONAL = "торговом автомате PTech"
	)

/obj/machinery/vending/cart/free
	prices = list()
