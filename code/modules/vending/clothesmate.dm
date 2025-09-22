/obj/machinery/vending/clothesmate
	name = "ClothesMate"
	desc = "Автомат по продаже разнообразной одежды."
	icon_state = "clothes_off"
	panel_overlay = "clothes_panel"
	screen_overlay = "clothes"
	lightmask_overlay = "clothes_lightmask"
	broken_overlay = "clothes_broken"
	broken_lightmask_overlay = "clothes_broken_lightmask"

	slogan_list = list(
		"Приод+енься для усп+еха!",
		"Пригот+овьтесь в+ыглядеть потряс+ающе!",
		"Посмотр+ите на все +эти кл+ассные в+ещи!",
		"Зач+ем оставл+ять стиль на произв+ол судьб+ы? Исп+ользуйте ClothesMate!"
	)

	vend_reply = "Спас+ибо за исп+ользование ClothesMate!"

	product_categories = list(

		list(
			"name" = "Головные уборы",
			"icon" = "hat-cowboy",
			"products" = list(
				/obj/item/clothing/head/that = 2,
				/obj/item/clothing/head/fedora = 1,
				/obj/item/clothing/head/beanie = 3,
				/obj/item/clothing/head/beanie/black = 3,
				/obj/item/clothing/head/beanie/red = 3,
				/obj/item/clothing/head/beanie/green = 3,
				/obj/item/clothing/head/beanie/darkblue = 3,
				/obj/item/clothing/head/beanie/purple = 3,
				/obj/item/clothing/head/beanie/yellow = 3,
				/obj/item/clothing/head/beanie/orange = 3,
				/obj/item/clothing/head/beanie/cyan = 3,
				/obj/item/clothing/head/beanie/christmas = 3,
				/obj/item/clothing/head/beanie/striped = 3,
				/obj/item/clothing/head/beanie/stripedred = 3,
				/obj/item/clothing/head/beanie/stripedblue = 3,
				/obj/item/clothing/head/beanie/stripedgreen = 3,
				/obj/item/clothing/head/beanie/rasta = 3,
				/obj/item/clothing/head/sombrero = 1,
			),
		),

		list(
			"name" = "Аксессуары",
			"icon" = "glasses",
			"products" = list(
				/obj/item/clothing/glasses/monocle = 1,
				/obj/item/clothing/glasses/regular = 2,
				/obj/item/clothing/glasses/sunglasses_fake = 2,
				/obj/item/clothing/accessory/scarf/red = 1,
				/obj/item/clothing/accessory/scarf/green = 1,
				/obj/item/clothing/accessory/scarf/darkblue = 1,
				/obj/item/clothing/accessory/scarf/purple = 1,
				/obj/item/clothing/accessory/scarf/yellow = 1,
				/obj/item/clothing/accessory/scarf/orange = 1,
				/obj/item/clothing/accessory/scarf/lightblue = 1,
				/obj/item/clothing/accessory/scarf/white = 1,
				/obj/item/clothing/accessory/scarf/black = 1,
				/obj/item/clothing/accessory/scarf/zebra = 1,
				/obj/item/clothing/accessory/scarf/christmas = 1,
				/obj/item/clothing/accessory/stripedredscarf = 1,
				/obj/item/clothing/accessory/stripedbluescarf = 1,
				/obj/item/clothing/accessory/stripedgreenscarf = 1,
				/obj/item/clothing/accessory/waistcoat = 1,
				/obj/item/clothing/neck/poncho = 1,
				/obj/item/clothing/neck/mantle = 2,
				/obj/item/clothing/neck/mantle/old = 1,
				/obj/item/clothing/neck/mantle/regal = 2,
				/obj/item/clothing/neck/cloak/grey = 1,
				/obj/item/storage/belt/fannypack = 1,
				/obj/item/storage/belt/fannypack/blue = 1,
				/obj/item/storage/belt/fannypack/red = 1,
				/obj/item/clothing/gloves/brown_short_gloves = 3,
				/obj/item/clothing/gloves/fingerless = 2,
			),
		),

		list(
			"name" = "Униформа",
			"icon" = "shirt",
			"products" = list(
				/obj/item/clothing/under/suit_jacket/navy = 2,
				/obj/item/clothing/under/kilt = 1,
				/obj/item/clothing/under/overalls = 1,
				/obj/item/clothing/under/suit_jacket/really_black = 2,
				/obj/item/clothing/under/pants/galifepants = 3,
				/obj/item/clothing/under/pants/sandpants = 3,
				/obj/item/clothing/under/pants/jeans = 3,
				/obj/item/clothing/under/pants/classicjeans = 2,
				/obj/item/clothing/under/pants/camo = 1,
				/obj/item/clothing/under/pants/blackjeans = 2,
				/obj/item/clothing/under/pants/khaki = 2,
				/obj/item/clothing/under/pants/white = 2,
				/obj/item/clothing/under/pants/red = 1,
				/obj/item/clothing/under/pants/black = 2,
				/obj/item/clothing/under/pants/tan = 2,
				/obj/item/clothing/under/pants/blue = 1,
				/obj/item/clothing/under/pants/track = 1,
				/obj/item/clothing/under/sundress = 2,
				/obj/item/clothing/under/stripeddress = 1,
				/obj/item/clothing/under/sailordress = 1,
				/obj/item/clothing/under/redeveninggown = 1,
				/obj/item/clothing/under/blacktango = 1,
			),
		),

		list(
			"name" = "Верхняя одежда",
			"icon" = "vest",
			"products" = list(
				/obj/item/clothing/suit/jacket/miljacket = 1,
				/obj/item/clothing/suit/storage/lawyer/blackjacket = 2,
				/obj/item/clothing/suit/jacket = 3,
				/obj/item/clothing/suit/jacket/motojacket = 3,
				/obj/item/clothing/suit/ianshirt = 1,
				/obj/item/clothing/suit/storage/bomber = 4,
			),
		),

		list(
			"name" = "Обувь",
			"icon" = "socks",
			"products" = list(
				/obj/item/clothing/shoes/laceup = 2,
				/obj/item/clothing/shoes/black = 4,
				/obj/item/clothing/shoes/sandal = 1,
				/obj/item/clothing/shoes/leather_boots = 3,
			),
		),
	)

	contraband = list(
		/obj/item/clothing/under/syndicate/tacticool = 1,
		/obj/item/clothing/under/syndicate/tacticool/skirt = 1,
		/obj/item/clothing/mask/balaclava = 1,
		/obj/item/clothing/under/syndicate/blackops_civ = 1,
		/obj/item/clothing/head/ushanka = 1,
		/obj/item/clothing/under/soviet = 1,
		/obj/item/storage/belt/fannypack/black = 1,
	)

	premium = list(
		/obj/item/clothing/under/suit_jacket/checkered = 1,
		/obj/item/clothing/head/mailman = 1,
		/obj/item/clothing/under/rank/mailman = 1,
		/obj/item/clothing/suit/jacket/leather = 1,
		/obj/item/clothing/under/pants/mustangjeans = 1,
		/obj/item/clothing/suit/storage/zazalord = 1,
	)

	refill_canister = /obj/item/vending_refill/clothing

/obj/machinery/vending/clothesmate/get_ru_names()
	return list(
		NOMINATIVE = "торговый автомат ClothesMate",
		GENITIVE = "торгового автомата ClothesMate",
		DATIVE = "торговому автомату ClothesMate",
		ACCUSATIVE = "торговый автомат ClothesMate",
		INSTRUMENTAL = "торговым автоматом ClothesMate",
		PREPOSITIONAL = "торговом автомате ClothesMate"
	)
