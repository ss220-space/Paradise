/obj/machinery/vending/ammo
	name = "Liberty"
	desc = "Боеприпасы для тех, кто стреляет первым."
	slogan_list = list(
		"Я не встр+ечал ник+ого умн+ее пул+и!",
		"К+огда я ск+ажу 3, то б+уду стр+елять! 3!",
		"6 выстр+елов, б+олее чем дост+аточно, чт+обы уб+ить всё, что движ+ется!",
		"Офиц+ер! Я не могу дыш+ать!",
	)
	icon_state = "ammovend_off"
	panel_overlay = "ammovend_panel"
	screen_overlay = "ammovend_overlay"
	refill_canister = /obj/item/vending_refill/ammo
	all_products_free = TRUE

	product_categories = list(
		list(
			"name" = "Боеприпасы",
			"icon" = "box-archive",
			"products" = list(
				/obj/item/ammo_box/shotgun = 1,
				/obj/item/ammo_box/shotgun/buck = 2,
				/obj/item/ammo_box/shotgun/beanbag = 2,
				/obj/item/ammo_box/shotgun/tranquilizer = 1,
				/obj/item/ammo_box/secgl/solid = 2,
				/obj/item/ammo_box/secgl/flash = 2,
				/obj/item/ammo_box/secgl/gas = 1,
				/obj/item/ammo_box/secgl/barricade = 1,
				/obj/item/ammo_box/secgl/paint = 1,
			),
		),
		list(
			"name" = "Магазины",
			"icon" = "gun",
			"products" = list(
				/obj/item/ammo_box/magazine/wt550m9  = 10,
				/obj/item/ammo_box/magazine/sp91rc = 10,
				/obj/item/ammo_box/magazine/sparkle_a12 = 10,
				/obj/item/ammo_box/magazine/enforcer/lethal = 10,
				/obj/item/ammo_box/magazine/lr30mag = 10,
				/obj/item/weapon_cell/specter = 10,
			),
		),
		list(
			"name" = "Гранаты",
			"icon" = "bomb",
			"products" = list(
				/obj/item/grenade/flashbang = 10,
				/obj/item/grenade/barrier = 10,
				/obj/item/grenade/chem_grenade/teargas = 10,
			),
		),
	)

	contraband = list(
		/obj/item/storage/box/flashbangs = 2,
		/obj/item/storage/box/barrier = 2,
		/obj/item/storage/box/teargas = 2,
		/obj/item/ammo_box/a357 = 1,
	)

/obj/machinery/vending/ammo/get_ru_names()
	return	list(
		NOMINATIVE = "торговый автомат Liberty",
		GENITIVE = "торгового автомата Liberty",
		DATIVE = "торговому автомату Liberty",
		ACCUSATIVE = "торговый автомат Liberty",
		INSTRUMENTAL = "торговым автоматом Liberty",
		PREPOSITIONAL = "торговом автомате Liberty",
	)
