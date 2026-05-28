/obj/machinery/vending/magivend
	name = "MagiVend"
	desc = "Волшебный торговый автомат."
	icon_state = "magivend_off"
	panel_overlay = "magivend_panel"
	screen_overlay = "magivend"
	lightmask_overlay = "magivend_lightmask"
	broken_overlay = "magivend_broken"
	broken_lightmask_overlay = "magivend_broken_lightmask"
	slogan_list = list(
		"MagiVend превращ+ает произнош+ение заклин+аний в с+ущий пуст+як!",
		"Стань сам себ+е Гуд+ини! Исп+ользуй MagiVend!",
		"FJKLFJSD",
		"AJKFLBJAKL",
		"1234 LOONIES LOL!",
		"БАМП!",
		"Уб+ей +этих убл+юдков!",
		"ДА ГДЕ +ЭТОТ Ч+ЁРТОВ ДИСК?!",
		"ХОНК!",
		"EI NATH",
		"Разнес+ите всё к черт+ям!",
		"Адм+инские з+аговоры стар+ы как сам+о вр+емя!",
		"Обор+удование для изг+иба простр+анства и вр+емени!",
		"АБРАКАД+АБРА!",
	)
	vend_reply = "Жел+аю вам чуд+есного в+ечера!"
	all_products_free = TRUE

	products = list(
		/obj/item/clothing/head/wizard = 5,
		/obj/item/clothing/suit/wizrobe = 5,
		/obj/item/clothing/head/wizard/red = 5,
		/obj/item/clothing/suit/wizrobe/red = 5,
		/obj/item/clothing/shoes/sandal = 5,
		/obj/item/clothing/suit/wizrobe/clown = 5,
		/obj/item/clothing/head/wizard/clown = 5,
		/obj/item/clothing/mask/gas/clownwiz = 5,
		/obj/item/clothing/shoes/clown_shoes/magical = 5,
		/obj/item/clothing/suit/wizrobe/mime = 5,
		/obj/item/clothing/head/wizard/mime = 5,
		/obj/item/clothing/mask/gas/mime/wizard = 5,
		/obj/item/clothing/head/wizard/marisa = 5,
		/obj/item/clothing/suit/wizrobe/marisa = 5,
		/obj/item/clothing/shoes/sandal/marisa = 5,
		/obj/item/twohanded/staff/broom = 5,
		/obj/item/clothing/head/wizard/black = 5,
		/obj/item/clothing/head/wizard/fluff/dreamy = 5,
		/obj/item/twohanded/staff = 10,
		/obj/item/clothing/head/helmet/space/plasmaman/wizard = 5,
		/obj/item/clothing/under/plasmaman/wizard = 5,
		/obj/item/tank/internals/plasmaman/belt/full = 5,
		/obj/item/clothing/mask/breath = 5,
		/obj/item/tank/internals/emergency_oxygen/double/vox = 5,
		/obj/item/clothing/mask/breath/vox = 5,
	)
	contraband = list(
		/obj/item/reagent_containers/glass/bottle/wizarditis = 1,
	)

	armor = list(melee = 100, bullet = 100, laser = 100, energy = 100, bomb = 0, bio = 0, fire = 100, acid = 50)
	resistance_flags = FIRE_PROOF
	tiltable = FALSE

/obj/machinery/vending/magivend/get_ru_names()
	return list(
		NOMINATIVE = "торговый автомат MagiVend",
		GENITIVE = "торгового автомата MagiVend",
		DATIVE = "торговому автомату MagiVend",
		ACCUSATIVE = "торговый автомат MagiVend",
		INSTRUMENTAL = "торговым автоматом MagiVend",
		PREPOSITIONAL = "торговом автомате MagiVend",
	)
