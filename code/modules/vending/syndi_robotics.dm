/obj/machinery/vending/syndierobotics
	name = "Syndie Robo-Deluxe"
	desc = "Всё что нужно, чтобы сделать личного железного друга из ваших врагов!"
	slogan_list = list(
		"Заст+авьте их п+ищать и гуд+еть, как и подоб+ает р+оботу!",
		"Роботиз+ация — +это НЕ преступл+ение!",
		"Бип-буп!"
	)
	icon_state = "robotics_off"
	panel_overlay = "robotics_panel"
	screen_overlay = "robotics"
	lightmask_overlay = "robotics_lightmask"
	broken_overlay = "robotics_broken"
	broken_lightmask_overlay = "robotics_broken_lightmask"
	deny_overlay = "robotics_deny"
	deny_lightmask = "robotics_deny_lightmask"
	req_access = list(ACCESS_SYNDICATE)

	products = list(
		/obj/item/robot_parts/robot_suit = 2,
		/obj/item/robot_parts/chest = 2,
		/obj/item/robot_parts/head = 2,
		/obj/item/robot_parts/l_arm = 2,
		/obj/item/robot_parts/r_arm = 2,
		/obj/item/robot_parts/l_leg = 2,
		/obj/item/robot_parts/r_leg = 2,
		/obj/item/stock_parts/cell/high = 6,
		/obj/item/crowbar = 2,
		/obj/item/flash = 4,
		/obj/item/stack/cable_coil = 4,
		/obj/item/mmi/syndie = 2,
		/obj/item/robotanalyzer = 2,
	)

/obj/machinery/vending/syndierobotics/get_ru_names()
	return list(
		NOMINATIVE = "торговый автомат Syndie Robo-Deluxe",
		GENITIVE = "торгового автомата Syndie Robo-Deluxe",
		DATIVE = "торговому автомату Syndie Robo-Deluxe",
		ACCUSATIVE = "торговый автомат Syndie Robo-Deluxe",
		INSTRUMENTAL = "торговым автоматом Syndie Robo-Deluxe",
		PREPOSITIONAL = "торговом автомате Syndie Robo-Deluxe"
	)
