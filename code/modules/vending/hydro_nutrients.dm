/obj/machinery/vending/hydronutrients
	name = "NutriMax"
	desc = "Поставщик питательных веществ для растений."
	slogan_list = list(
		"Вам не н+адо уд+обрять п+очву ест+ественным путём — р+азве +это не чуд+есно?",
		"Теп+ерь на 50 проц+ентов м+еньше в+они!",
		"Раст+ения т+оже жив+ые!",
		"Мы л+юбим раст+ения!",
		"М+ожет с+ами пр+имете?",
		"С+амые зел+ёные кн+опки на св+ете.",
		"Мы л+юбим больш+ие раст+ения.",
		"М+ягкая п+очва…"
	)
	icon_state = "nutri_off"
	panel_overlay = "nutri_panel"
	screen_overlay = "nutri"
	lightmask_overlay = "nutri_lightmask"
	broken_overlay = "nutri_broken"
	broken_lightmask_overlay = "nutri_broken_lightmask"
	deny_overlay = "nutri_deny"
	refill_canister = /obj/item/vending_refill/hydronutrients

	products = list(
		/obj/item/reagent_containers/glass/bottle/nutrient/ez = 20,
		/obj/item/reagent_containers/glass/bottle/nutrient/l4z = 13,
		/obj/item/reagent_containers/glass/bottle/nutrient/rh = 6,
		/obj/item/reagent_containers/spray/pestspray = 20,
		/obj/item/reagent_containers/syringe = 5,
		/obj/item/storage/bag/plants = 5,
		/obj/item/cultivator = 3,
		/obj/item/shovel/spade = 3,
		/obj/item/plant_analyzer = 4,
	)
	contraband = list(
		/obj/item/reagent_containers/glass/bottle/ammonia = 10,
		/obj/item/reagent_containers/glass/bottle/diethylamine = 5,
	)

/obj/machinery/vending/hydronutrients/get_ru_names()
	return list(
		NOMINATIVE = "торговый автомат NutriMax",
		GENITIVE = "торгового автомата NutriMax",
		DATIVE = "торговому автомату NutriMax",
		ACCUSATIVE = "торговый автомат NutriMax",
		INSTRUMENTAL = "торговым автоматом NutriMax",
		PREPOSITIONAL = "торговом автомате NutriMax"
	)
