/obj/machinery/vending/pai
	name = "RoboFriends"
	desc = "Потрясающий продавец ПИИ-друзей и всяких робо штучек!"
	icon_state = "paivend_off"
	panel_overlay = "paivend_panel"
	screen_overlay = "paivend"
	lightmask_overlay = "paivend_lightmask"
	broken_overlay = "paivend_broken"
	broken_lightmask_overlay = "paivend_broken_lightmask"
	slogan_list = list(
		"А вы л+юбите нас?",
		"Мы тво+и друзь+я!",
		"+Эта пок+упка войд+ёт в ист+орию!",
		"Я ПИИ прост+ой, куп+ишь мен+я, а я теб+е др+уга!",
		"Спас+ибо за пок+упку!"
	)
	resistance_flags = FIRE_PROOF
	refill_canister = /obj/item/vending_refill/pai
	default_price = PAYCHECK_CREW * 2
	default_premium_price = PAYCHECK_COMMAND * 2

	product_categories = list(
		list(
			"name" = "Улучшения для ПИИ",
			"icon" = "code",
			"products" = list(
				/obj/item/paicard = 10,
				/obj/item/pai_cartridge/female = 10,
				/obj/item/pai_cartridge/doorjack = 5,
				/obj/item/pai_cartridge/memory = 5,
				/obj/item/pai_cartridge/reset = 5
			)
		),
		list(
			"name" = "Импланты",
			"icon" = "eye",
			"products" = list(
				/obj/item/organ/internal/cyberimp/mouth/breathing_tube = 3,
				/obj/item/organ/internal/cyberimp/eyes/meson = 3,
				/obj/item/organ/internal/cyberimp/eyes/hud/diagnostic = 3,
				/obj/item/organ/internal/cyberimp/eyes/hud/science = 3,
				/obj/item/organ/internal/cyberimp/chest/nutriment = 3,
				/obj/item/organ/internal/cyberimp/brain/clown_voice = 3,
				/obj/item/organ/internal/cyberimp/arm/botanical = 2,
				/obj/item/organ/internal/cyberimp/arm/janitorial = 2,
			)
		),
		list(
			"name" = "Кибернетические органы",
			"icon" = "wheelchair",
			"products" = list(
				/obj/item/robot_parts/l_arm = 3,
				/obj/item/robot_parts/r_arm = 3,
				/obj/item/robot_parts/r_leg = 3,
				/obj/item/robot_parts/l_leg = 3,
				/obj/item/organ/internal/lungs/cybernetic = 3,
				/obj/item/organ/internal/liver/cybernetic = 3,
				/obj/item/organ/internal/kidneys/cybernetic = 3,
				/obj/item/organ/internal/heart/cybernetic = 3,
				/obj/item/organ/internal/eyes/cybernetic = 3,
				/obj/item/organ/internal/ears/cybernetic = 3,
			)
		)
	)
	premium = list(
		/obj/item/organ/internal/cyberimp/eyes/hud/medical = 1,
		/obj/item/organ/internal/cyberimp/eyes/shield = 1,
		/obj/item/organ/internal/cyberimp/arm/toolset = 1,
	)
	contraband = list(
		/obj/item/pai_cartridge/syndi_emote = 1,
		/obj/item/pai_cartridge/snake = 1,
	)

/obj/machinery/vending/pai/get_ru_names()
	return list(
		NOMINATIVE = "торговый автомат RoboFriends",
		GENITIVE = "торгового автомата RoboFriends",
		DATIVE = "торговому автомату RoboFriends",
		ACCUSATIVE = "торговый автомат RoboFriends",
		INSTRUMENTAL = "торговым автоматом RoboFriends",
		PREPOSITIONAL = "торговом автомате RoboFriends",
	)
