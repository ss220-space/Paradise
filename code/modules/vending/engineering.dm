/obj/machinery/vending/engineering
	name = "Robco Tool Maker"
	desc = "Всё, что вам требуется для самостоятельного обслуживания станции."
	icon_state = "engi_off"
	panel_overlay = "engi_panel"
	screen_overlay = "engi"
	lightmask_overlay = "engi_lightmask"
	broken_overlay = "engi_broken"
	broken_lightmask_overlay = "engi_broken_lightmask"
	deny_overlay = "engi_deny"
	deny_lightmask = "engi_deny_lightmask"

	req_access = list(ACCESS_ENGINE_EQUIP)
	products = list(/obj/item/clothing/under/rank/chief_engineer = 4,/obj/item/clothing/under/rank/engineer = 4,/obj/item/clothing/shoes/workboots = 4,/obj/item/clothing/head/hardhat = 4,
					/obj/item/storage/belt/utility = 4,/obj/item/clothing/glasses/meson = 4,/obj/item/clothing/gloves/color/yellow = 4, /obj/item/screwdriver = 12,
					/obj/item/crowbar = 12,/obj/item/wirecutters = 12,/obj/item/multitool = 12,/obj/item/wrench = 12,/obj/item/t_scanner = 12,
					/obj/item/stack/cable_coil = 8, /obj/item/stock_parts/cell = 8, /obj/item/weldingtool = 8,/obj/item/clothing/head/welding = 8,
					/obj/item/light/tube = 10,/obj/item/clothing/suit/fire = 4, /obj/item/stock_parts/scanning_module = 5,/obj/item/stock_parts/micro_laser = 5,
					/obj/item/stock_parts/matter_bin = 5,/obj/item/stock_parts/manipulator = 5)
	refill_canister = /obj/item/vending_refill/engineering

/obj/machinery/vending/engineerin/get_ru_names()
	return list(
		NOMINATIVE = "торговый автомат Robco Tool Maker",
		GENITIVE = "торгового автомата Robco Tool Maker",
		DATIVE = "торговому автомату Robco Tool Maker",
		ACCUSATIVE = "торговый автомат Robco Tool Maker",
		INSTRUMENTAL = "торговым автоматом Robco Tool Maker",
		PREPOSITIONAL = "торговом автомате Robco Tool Maker"
	)
