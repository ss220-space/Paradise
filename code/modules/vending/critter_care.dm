/obj/machinery/vending/crittercare
	name = "CritterCare"
	desc = "Торговый автомат по продаже зоотоваров."
	slogan_list = list(
		"Здесь всё, чт+обы ваш пит+омец был всем дов+олен!",
		"Крут+ые пит+омцы засл+уживают крут+ой ош+ейник!",
		"Дом+ашние жив+отные в к+осмосе — что м+ожет быть очаров+ательнее?",
		"С+амая св+ежая икр+а в сист+еме!",
		"К+амни — л+учшие пит+омцы, куп+ите себ+е их уж+е сег+одня!",
		"Дрессир+овка на дом+у опл+ачивается дополн+ительно!",
		"Теп+ерь на 1000 процентов б+ольше кош+ачьей ш+ерсти!",
		"Аллерг+ия — пр+изнак сл+абости!",
		"Соб+аки — л+учшие друзь+я гуман+оида!",
		"Нагрев+ательные л+ампы для ун+атхов!",
		"Вокс х+очет кр+екер?"
	)
	icon_state = "crittercare_off"
	panel_overlay = "crittercare_panel"
	screen_overlay = "crittercare"
	lightmask_overlay = "crittercare_lightmask"
	broken_overlay = "crittercare_broken"
	broken_lightmask_overlay = "crittercare_broken_lightmask"
	refill_canister = /obj/item/vending_refill/crittercare
	default_price = PAYCHECK_LOWER
	default_premium_price = PAYCHECK_CREW

	products = list(
		/obj/item/clothing/accessory/petcollar = 5,
		/obj/item/storage/firstaid/aquatic_kit/full = 5,
		/obj/item/fish_eggs/goldfish = 5,
		/obj/item/fish_eggs/clownfish = 5,
		/obj/item/fish_eggs/shark = 5,
		/obj/item/fish_eggs/feederfish = 10,
		/obj/item/fish_eggs/salmon = 5,
		/obj/item/fish_eggs/catfish = 5,
		/obj/item/fish_eggs/glofish = 5,
		/obj/item/fish_eggs/electric_eel = 5,
		/obj/item/fish_eggs/crayfish = 5,
		/obj/item/fish_eggs/shrimp = 10,
		/obj/item/toy/pet_rock = 5,
		/obj/item/pet_carrier/normal = 3,
		/obj/item/pet_carrier = 5,
		/obj/item/reagent_containers/food/condiment/animalfeed = 5,
		/obj/item/reagent_containers/glass/pet_bowl = 3,
	)
	contraband = list(
		/obj/item/fish_eggs/babycarp = 5,
	)
	premium = list(
		/obj/item/toy/pet_rock/fred = 1,
		/obj/item/toy/pet_rock/roxie = 1,
	)

/obj/machinery/vending/crittercare/get_ru_names()
	return list(
		NOMINATIVE = "торговый автомат CritterCare",
		GENITIVE = "торгового автомата CritterCare",
		DATIVE = "торговому автомату CritterCare",
		ACCUSATIVE = "торговый автомат CritterCare",
		INSTRUMENTAL = "торговым автоматом CritterCare",
		PREPOSITIONAL = "торговом автомате CritterCare",
	)
