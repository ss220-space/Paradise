/obj/machinery/vending/snack
	name = "Getmore Chocolate Corp"
	desc = "Автомат самообслуживания, любезно предоставленный шоколадной корпорацией Getmore, базирующейся на Марсе."
	slogan_list = list(
		"Попр+обуйте наш н+овый бат+ончик с нуг+ой!",
		"Вдв+ое б+ольше кал+орий за п+олц+ены!",
		"С+амый здор+овый!",
		"Отм+еченные нагр+адами шокол+адные бат+ончики!",
		"Ммм! Так вк+усно!",
		"О б+оже, ++это так вк+усно!",
		"Перекус+ите.",
		"Зак+уски - ++это зд+орово!",
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

	products = list(/obj/item/reagent_containers/food/snacks/candy/candybar = 6,
					/obj/item/reagent_containers/food/drinks/dry_ramen = 6,
					/obj/item/reagent_containers/food/snacks/doshik = 6,
					/obj/item/reagent_containers/food/snacks/doshik_spicy = 6,
					/obj/item/reagent_containers/food/snacks/chips =6,
					/obj/item/reagent_containers/food/snacks/sosjerky = 6,
					/obj/item/reagent_containers/food/snacks/no_raisin = 6,
					/obj/item/reagent_containers/food/snacks/pistachios =6,
					/obj/item/reagent_containers/food/snacks/spacetwinkie = 6,
					/obj/item/reagent_containers/food/snacks/cheesiehonkers = 6,
					/obj/item/reagent_containers/food/snacks/tastybread = 6
					)
	contraband = list(/obj/item/reagent_containers/food/snacks/syndicake = 6)
	prices = list(/obj/item/reagent_containers/food/snacks/candy/candybar = 19,
					/obj/item/reagent_containers/food/drinks/dry_ramen = 29,
					/obj/item/reagent_containers/food/snacks/doshik = 29,
					/obj/item/reagent_containers/food/snacks/doshik_spicy = 149,
					/obj/item/reagent_containers/food/snacks/chips =19,
					/obj/item/reagent_containers/food/snacks/sosjerky = 29,
					/obj/item/reagent_containers/food/snacks/no_raisin = 19,
					/obj/item/reagent_containers/food/snacks/pistachios = 29,
					/obj/item/reagent_containers/food/snacks/spacetwinkie = 29,
					/obj/item/reagent_containers/food/snacks/cheesiehonkers = 19,
					/obj/item/reagent_containers/food/snacks/tastybread = 29,
					/obj/item/reagent_containers/food/snacks/syndicake = 49)
	refill_canister = /obj/item/vending_refill/snack

/obj/machinery/vending/snack/get_ru_names()
	return list(
		NOMINATIVE = "торговый автомат Getmore Chocolate Corp",
		GENITIVE = "торгового автомата Getmore Chocolate Corp",
		DATIVE = "торговому автомату Getmore Chocolate Corp",
		ACCUSATIVE = "торговый автомат Getmore Chocolate Corp",
		INSTRUMENTAL = "торговым автоматом Getmore Chocolate Corp",
		PREPOSITIONAL = "торговом автомате Getmore Chocolate Corp"
	)

/obj/machinery/vending/snack/free
	prices = list()
