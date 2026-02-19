/obj/machinery/vending/engivend
	name = "Engi-Vend"
	desc = "Автомат с запасными инструментами. Что? Вы ожидали какого-нибудь остроумного описания?"
	icon_state = "engivend_off"
	panel_overlay = "engivend_panel"
	screen_overlay = "engivend"
	lightmask_overlay = "engivend_lightmask"
	broken_overlay = "engivend_broken"
	broken_lightmask_overlay = "engivend_broken_lightmask"
	deny_overlay = "engivend_deny"
	refill_canister = /obj/item/vending_refill/engivend
	req_access = list(ACCESS_ENGINE_EQUIP, ACCESS_ATMOSPHERICS)
	default_price = PAYCHECK_MIN * 1.2
	default_premium_price = PAYCHECK_CREW

	products = list(
		/obj/item/multitool = 4,
		/obj/item/airlock_electronics = 10,
		/obj/item/firelock_electronics = 10,
		/obj/item/firealarm_electronics = 10,
		/obj/item/apc_electronics = 10,
		/obj/item/airalarm_electronics = 10,
		/obj/item/access_control = 10,
		/obj/item/assembly/control/airlock = 10,
		/obj/item/stock_parts/cell/high = 10,
		/obj/item/camera_assembly = 10,
	)
	contraband = list(
		/obj/item/stock_parts/cell/potato = 3,
	)
	premium = list(
		/obj/item/clothing/glasses/meson = 3,
		/obj/item/storage/belt/utility = 3,
	)

/obj/machinery/vending/engivend/get_ru_names()
	return list(
		NOMINATIVE = "торговый автомат Engi-Vend",
		GENITIVE = "торгового автомата Engi-Vend",
		DATIVE = "торговому автомату Engi-Vend",
		ACCUSATIVE = "торговый автомат Engi-Vend",
		INSTRUMENTAL = "торговым автоматом Engi-Vend",
		PREPOSITIONAL = "торговом автомате Engi-Vend",
	)
