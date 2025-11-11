/obj/machinery/vending/hydroseeds
	name = "MegaSeed Servitor"
	desc = "Когда вам срочно нужны семена!"
	slogan_list = list(
		"ВОТ ГДЕ ЖИВ+УТ СЕМЕН+А! ВОЗЬМ+И СЕБ+Е НЕМН+ОГО!",
		"Без сомн+ений, л+учший в+ыбор здесь!",
		"Кр+оме тог+о, н+екоторые в+иды гриб+ов дост+упны исключ+ительно для эксп+ертов! Получ+ите сертифик+ат уж+е сег+одня!",
		"Мы л+юбим раст+ения!",
		"В+ырасти урож+ай!",
		"Раст+и, мал+ыш, раст+и-и-и-и!",
		"Ды-+а, с+ына!"
	)
	icon_state = "seeds_off"
	panel_overlay = "seeds_panel"
	screen_overlay = "seeds"
	lightmask_overlay = "seeds_lightmask"
	broken_overlay = "seeds_broken"
	broken_lightmask_overlay = "seeds_broken_lightmask"
	refill_canister = /obj/item/vending_refill/hydroseeds

	products = list(
		/obj/item/seeds/aloe = 3,
		/obj/item/seeds/ambrosia = 3,
		/obj/item/seeds/apple = 3,
		/obj/item/seeds/banana = 3,
		/obj/item/seeds/berry = 3,
		/obj/item/seeds/cabbage = 3,
		/obj/item/seeds/carrot = 3,
		/obj/item/seeds/cherry = 3,
		/obj/item/seeds/chanter = 3,
		/obj/item/seeds/chili = 3,
		/obj/item/seeds/cocoapod = 3,
		/obj/item/seeds/coffee = 3,
		/obj/item/seeds/comfrey = 3,
		/obj/item/seeds/corn = 3,
		/obj/item/seeds/cotton = 3,
		/obj/item/seeds/nymph = 3,
		/obj/item/seeds/eggplant = 3,
		/obj/item/seeds/garlic = 3,
		/obj/item/seeds/grape = 3,
		/obj/item/seeds/grass = 3,
		/obj/item/seeds/lemon = 3,
		/obj/item/seeds/lime = 3,
		/obj/item/seeds/onion = 3,
		/obj/item/seeds/orange = 3,
		/obj/item/seeds/peanuts = 3,
		/obj/item/seeds/peas = 3,
		/obj/item/seeds/pineapple = 3,
		/obj/item/seeds/poppy = 3,
		/obj/item/seeds/geranium = 3,
		/obj/item/seeds/lily = 3,
		/obj/item/seeds/potato = 3,
		/obj/item/seeds/pumpkin = 3,
		/obj/item/seeds/replicapod = 3,
		/obj/item/seeds/wheat/rice = 3,
		/obj/item/seeds/soya = 3,
		/obj/item/seeds/sugarcane = 3,
		/obj/item/seeds/sunflower = 3,
		/obj/item/seeds/tea = 3,
		/obj/item/seeds/tobacco = 3,
		/obj/item/seeds/tomato = 3,
		/obj/item/seeds/cucumber = 3,
		/obj/item/seeds/tower = 3,
		/obj/item/seeds/watermelon = 3,
		/obj/item/seeds/wheat = 3,
		/obj/item/seeds/soya/olive = 3,
		/obj/item/seeds/whitebeet = 3,
		/obj/item/seeds/shavel = 3,
		/obj/item/seeds/redflower = 3,
		/obj/item/seeds/flowerlamp = 3,
		/obj/item/seeds/carnation = 3,
		/obj/item/seeds/tulp = 3,
		/obj/item/seeds/chamomile = 3,
		/obj/item/seeds/rose = 3,
	)
	contraband = list(
		/obj/item/seeds/cannabis = 3,
		/obj/item/seeds/amanita = 2,
		/obj/item/seeds/fungus = 3,
		/obj/item/seeds/glowshroom = 2,
		/obj/item/seeds/liberty = 2,
		/obj/item/seeds/nettle = 2,
		/obj/item/seeds/plump = 2,
		/obj/item/seeds/reishi = 2,
		/obj/item/seeds/starthistle = 2,
		/obj/item/seeds/random = 2,
		/obj/item/seeds/moonlight = 2,
		/obj/item/seeds/coca = 2,
	)
	premium = list(
		/obj/item/reagent_containers/spray/waterflower = 1,
	)

/obj/machinery/vending/hydroseeds/get_ru_names()
	return list(
		NOMINATIVE = "торговый автомат MegaSeed Servitor",
		GENITIVE = "торгового автомата MegaSeed Servitor",
		DATIVE = "торговому автомату MegaSeed Servitor",
		ACCUSATIVE = "торговый автомат MegaSeed Servitor",
		INSTRUMENTAL = "торговым автоматом MegaSeed Servitor",
		PREPOSITIONAL = "торговом автомате MegaSeed Servitor",
	)
