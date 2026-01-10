/obj/machinery/vending/tool
	name = "YouTool"
	desc = "Инструменты для инструментов."
	icon_state = "tool_off"
	panel_overlay = "tool_panel"
	screen_overlay = "tool"
	lightmask_overlay = "tool_lightmask"
	broken_overlay = "tool_broken"
	broken_lightmask_overlay = "tool_broken_lightmask"
	deny_overlay = "tool_deny"
	refill_canister = /obj/item/vending_refill/youtool
	armor = list(melee = 50, bullet = 20, laser = 20, energy = 20, bomb = 0, bio = 0, rad = 0, fire = 100, acid = 70)
	resistance_flags = FIRE_PROOF

	products = list(
		/obj/item/stack/cable_coil/random = 10,
		/obj/item/crowbar = 5,
		/obj/item/weldingtool = 3,
		/obj/item/wirecutters = 5,
		/obj/item/wrench = 5,
		/obj/item/analyzer = 5,
		/obj/item/t_scanner = 5,
		/obj/item/screwdriver = 5,
		/obj/item/clothing/gloves/color/fyellow = 2,
		/obj/item/weldingtool/hugetank = 3,
		/obj/item/wrench/industrial = 3,
		/obj/item/crowbar/industrial = 3,
		/obj/item/wirecutters/industrial = 3,
		/obj/item/screwdriver/industrial = 3,
	)
	contraband = list(
		/obj/item/clothing/gloves/color/yellow = 1,
	)
	prices = list(
		/obj/item/stack/cable_coil/random = 29,
		/obj/item/crowbar = 49,
		/obj/item/weldingtool = 49,
		/obj/item/wirecutters = 49,
		/obj/item/wrench = 49,
		/obj/item/analyzer = 29,
		/obj/item/t_scanner = 29,
		/obj/item/screwdriver = 49,
		/obj/item/clothing/gloves/color/fyellow = 249,
		/obj/item/weldingtool/hugetank = 299,
		/obj/item/wrench/industrial = 299,
		/obj/item/crowbar/industrial = 299,
		/obj/item/wirecutters/industrial = 299,
		/obj/item/screwdriver/industrial = 299,
		/obj/item/clothing/gloves/color/yellow = 499,
	)

/obj/machinery/vending/tool/get_ru_names()
	return list(
		NOMINATIVE = "торговый автомат YouTool",
		GENITIVE = "торгового автомата YouTool",
		DATIVE = "торговому автомату YouTool",
		ACCUSATIVE = "торговый автомат YouTool",
		INSTRUMENTAL = "торговым автоматом YouTool",
		PREPOSITIONAL = "торговом автомате YouTool",
	)
