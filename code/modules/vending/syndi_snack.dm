/obj/machinery/vending/syndisnack
	name = "Getmore Chocolate Corp"
	desc = "Модифицированный автомат самообслуживания, любезно предоставленный шоколадной корпорацией Getmore, базирующейся на Марсе."
	slogan_list = list(
		"Попр+обуйте н+аш н+овый бат+ончик с нуг+ой!",
		"Вдв+ое б+ольше кал+орий за п+олц+ены!",
		"С+амый здор+овый!",
		"Отм+еченные нагр+адами шокол+адные бат+ончики!",
		"Ммм! Так вк+усно!",
		"О б+оже, +это так вк+усно!",
		"Перекус+ите.",
		"Зак+уски - +это зд+орово!",
		"Возьм+и немн+ого, и ещ+ё немн+ого!",
		"Зак+уски в+ысшего к+ачества пр+ямо с М+арса.",
		"Мы л+юбим шокол+ад!",
		"Попр+обуйте н+аше н+овое в+яленое м+ясо!"
	)
	icon_state = "snack_off"
	panel_overlay = "snack_panel"
	screen_overlay = "snack"
	lightmask_overlay = "snack_lightmask"
	broken_overlay = "snack_broken"
	broken_lightmask_overlay = "snack_broken_lightmask"

	products = list(
		/obj/item/reagent_containers/food/snacks/chips = 6,
		/obj/item/reagent_containers/food/snacks/sosjerky = 6,
		/obj/item/reagent_containers/food/snacks/syndicake = 6,
		/obj/item/reagent_containers/food/snacks/cheesiehonkers = 6,
	)

/obj/machinery/vending/syndisnack/get_ru_names()
	return list(
		NOMINATIVE = "торговый автомат Getmore Chocolate Corp",
		GENITIVE = "торгового автомата Getmore Chocolate Corp",
		DATIVE = "торговому автомату Getmore Chocolate Corp",
		ACCUSATIVE = "торговый автомат Getmore Chocolate Corp",
		INSTRUMENTAL = "торговым автоматом Getmore Chocolate Corp",
		PREPOSITIONAL = "торговом автомате Getmore Chocolate Corp",
	)
