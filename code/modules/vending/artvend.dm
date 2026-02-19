/obj/machinery/vending/artvend
	name = "ArtVend"
	desc = "Торговый автомат для всех ваших художественных нужд."
	slogan_list = list(
		"Забир+айте сво+и прик+ольные вещ+ички!",
		"Раскр+асьте пол цветн+ыми карандаш+ами, а не кр+овью!",
		"Не будь голод+ающим творц+ом, исп+ользуй ArtVend.",
		"Не сри, твор+и!",
		"Пр+ямо как в д+етском саду!",
		"Теп+ерь на 1000 процентов б+ольше +ярких цвет+ов!",
		"Креат+ивность леж+ит в осн+ове к+аждого специал+иста!",
		"Ст+олько цвет+ов, ты т+олько глянь!",
		"Пор+адуйте ваш+его вн+утреннего реб+ёнка!"
	)

	icon_state = "artvend_off"
	panel_overlay = "artvend_panel"
	screen_overlay = "artvend"
	lightmask_overlay = "artvend_lightmask"
	broken_overlay = "artvend_broken"
	broken_lightmask_overlay = "artvend_broken_lightmask"
	default_price = PAYCHECK_MIN * 0.4
	default_premium_price = PAYCHECK_LOWER * 0.5

	products = list(
		/obj/item/toy/crayon/spraycan = 2,
		/obj/item/stack/cable_coil/random = 10,
		/obj/item/camera = 4,
		/obj/item/camera_film = 6,
		/obj/item/storage/photo_album = 2,
		/obj/item/stack/wrapping_paper = 4,
		/obj/item/stack/tape_roll = 5,
		/obj/item/stack/packageWrap = 4,
		/obj/item/storage/fancy/crayons = 4,
		/obj/item/storage/fancy/glowsticks_box = 3,
		/obj/item/hand_labeler = 4,
		/obj/item/paper = 10,
		/obj/item/c_tube = 10,
		/obj/item/pen = 5,
		/obj/item/pen/blue = 5,
		/obj/item/pen/red = 5,
	)
	contraband = list(
		/obj/item/toy/crayon/mime = 1,
		/obj/item/toy/crayon/rainbow = 1,
		/obj/item/weaponcrafting/receiver = 1,
	)
	premium = list(
		/obj/item/poster/random_contraband = 5,
	)

/obj/machinery/vending/artvend/get_ru_names()
	return list(
		NOMINATIVE = "торговый автомат ArtVend",
		GENITIVE = "торгового автомата ArtVend",
		DATIVE = "торговому автомату ArtVend",
		ACCUSATIVE = "торговый автомат ArtVend",
		INSTRUMENTAL = "торговым автоматом ArtVend",
		PREPOSITIONAL = "торговом автомате ArtVend",
	)
