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

	req_access = list(11,24) // Engineers and atmos techs can use this
	products = list(/obj/item/clothing/glasses/meson = 2,/obj/item/multitool = 4,/obj/item/airlock_electronics = 10,/obj/item/firelock_electronics = 10,/obj/item/firealarm_electronics = 10,/obj/item/apc_electronics = 10,/obj/item/airalarm_electronics = 10,/obj/item/access_control = 10,/obj/item/assembly/control/airlock = 10,/obj/item/stock_parts/cell/high = 10,/obj/item/camera_assembly = 10)
	contraband = list(/obj/item/stock_parts/cell/potato = 3)
	premium = list(/obj/item/storage/belt/utility = 3)
	refill_canister = /obj/item/vending_refill/engivend

/obj/machinery/vending/engivend/get_ru_names()
	return list(
		NOMINATIVE = "торговый автомат Engi-Vend",
		GENITIVE = "торгового автомата Engi-Vend",
		DATIVE = "торговому автомату Engi-Vend",
		ACCUSATIVE = "торговый автомат Engi-Vend",
		INSTRUMENTAL = "торговым автоматом Engi-Vend",
		PREPOSITIONAL = "торговом автомате Engi-Vend"
	)
