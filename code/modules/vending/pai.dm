/obj/machinery/vending/pai
	name = "RoboFriends"
	desc = "Потрясающий продавец ПИИ-друзей!"

	icon_state = "paivend_off"
	panel_overlay = "paivend_panel"
	screen_overlay = "paivend"
	lightmask_overlay = "paivend_lightmask"
	broken_overlay = "paivend_broken"
	broken_lightmask_overlay = "paivend_broken_lightmask"

	slogan_list = list(
		"А вы л+юбите нас?",
		"Мы тво+и друзь+я!",
		"+Эта пок+упка войд+ёт в ист+орию!",
		"Я ПИИ прост+ой, куп+ишь мен+я, а я теб+е др+уга!",
		"Спас+ибо за пок+упку!"
	)
	resistance_flags = FIRE_PROOF
	products = list(
		/obj/item/paicard = 10,
		/obj/item/pai_cartridge/female = 10,
		/obj/item/pai_cartridge/doorjack = 5,
		/obj/item/pai_cartridge/memory = 5,
		/obj/item/pai_cartridge/reset = 5,
		/obj/item/robot_parts/l_arm = 1,
		/obj/item/robot_parts/r_arm = 1
	)
	contraband = list(
		/obj/item/pai_cartridge/syndi_emote = 1,
		/obj/item/pai_cartridge/snake = 1
	)
	prices = list(
		/obj/item/paicard = 199,
		/obj/item/robot_parts/l_arm = 549,
		/obj/item/robot_parts/r_arm = 549,
		/obj/item/pai_cartridge/female = 149,
		/obj/item/pai_cartridge/doorjack = 399,
		/obj/item/pai_cartridge/syndi_emote = 649,
		/obj/item/pai_cartridge/snake = 599,
		/obj/item/pai_cartridge/reset = 599,
		/obj/item/pai_cartridge/memory = 349
	)
	refill_canister = /obj/item/vending_refill/pai

/obj/machinery/vending/pai/get_ru_names()
	return list(
		NOMINATIVE = "торговый автомат RoboFriends",
		GENITIVE = "торгового автомата RoboFriends",
		DATIVE = "торговому автомату RoboFriends",
		ACCUSATIVE = "торговый автомат RoboFriends",
		INSTRUMENTAL = "торговым автоматом RoboFriends",
		PREPOSITIONAL = "торговом автомате RoboFriends"
	)
