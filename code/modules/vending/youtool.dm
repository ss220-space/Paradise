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
	armor = list(melee = 50, bullet = 20, laser = 20, energy = 20, bomb = 0, bio = 0, fire = 100, acid = 70)
	resistance_flags = FIRE_PROOF
	default_price = PAYCHECK_LOWER
	default_premium_price = PAYCHECK_CREW
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
	)
	premium = list(
		/obj/item/weldingtool/hugetank = 3,
		/obj/item/wrench/industrial = 3,
		/obj/item/crowbar/industrial = 3,
		/obj/item/wirecutters/industrial = 3,
		/obj/item/screwdriver/industrial = 3,
	)
	contraband = list(
		/obj/item/clothing/gloves/color/yellow = 1,
	)

/obj/machinery/vending/tool/sect_merconicism
	name = "божественный ларёк"
	desc = "Передвижной торгомат, благословлённый прибыльной верой."
	anchored = FALSE
	req_access = null
	scan_id = FALSE
	default_price = PAYCHECK_CREW
	default_premium_price = PAYCHECK_COMMAND
	products = list()
	premium = list()
	contraband = list()
	var/datum/religion_sect/merconicism/bound_sect
	var/last_prana_sale = 0

/obj/machinery/vending/tool/sect_merconicism/Initialize(mapload)
	products = build_merconicism_products()
	return ..()

/obj/machinery/vending/tool/sect_merconicism/proc/build_merconicism_products()
	var/static/list/product_pool = list(
		/obj/item/airalarm_electronics,
		/obj/item/airlock_electronics,
		/obj/item/analyzer,
		/obj/item/apc_electronics,
		/obj/item/assembly/control/airlock,
		/obj/item/camera_assembly,
		/obj/item/clothing/glasses/meson,
		/obj/item/clothing/glasses/meson/atmos,
		/obj/item/clothing/gloves/color/fyellow,
		/obj/item/clothing/head/hardhat,
		/obj/item/clothing/head/welding,
		/obj/item/clothing/shoes/workboots,
		/obj/item/clothing/suit/fire,
		/obj/item/crowbar,
		/obj/item/firealarm_electronics,
		/obj/item/firelock_electronics,
		/obj/item/light/tube,
		/obj/item/multitool,
		/obj/item/screwdriver,
		/obj/item/stack/cable_coil/random,
		/obj/item/stock_parts/cell,
		/obj/item/stock_parts/cell/high,
		/obj/item/stock_parts/manipulator,
		/obj/item/stock_parts/matter_bin,
		/obj/item/stock_parts/micro_laser,
		/obj/item/stock_parts/scanning_module,
		/obj/item/storage/belt/utility,
		/obj/item/t_scanner,
		/obj/item/weldingtool,
		/obj/item/weldingtool/hugetank,
		/obj/item/wirecutters,
		/obj/item/wrench
	)
	var/list/new_products = list()
	for(var/product_type as anything in shuffle(product_pool))
		if(length(new_products) >= SECT_MERCONICISM_STALL_MAX_PRODUCTS)
			break
		new_products[product_type] = rand(SECT_MERCONICISM_STALL_MIN_STOCK, SECT_MERCONICISM_STALL_MAX_STOCK)
	return new_products

/obj/machinery/vending/tool/sect_merconicism/proc/can_convert_sale_to_prana(mob/user)
	if(!QDELETED(bound_sect))
		return TRUE
	to_chat(user, span_warning("Ларёк потерял связь с алтарём и не принимает оплату."))
	return FALSE

/obj/machinery/vending/tool/sect_merconicism/proc/record_merconicism_sale(price)
	if(QDELETED(bound_sect))
		return
	var/prana_gained = price * bound_sect.credit_prana_multiplier
	bound_sect.adjust_prana(prana_gained)
	last_prana_sale = price
	if(bound_sect.altar)
		SStgui.update_uis(bound_sect.altar)

/obj/machinery/vending/tool/sect_merconicism/pay_with_cash(obj/item/stack/spacecash/cashmoney, mob/user, price, vended_name, datum/money_account/account_we_pay_on)
	if(!can_convert_sale_to_prana(user))
		return FALSE
	if(price > cashmoney.amount)
		to_chat(user, "[icon2html(cashmoney, user)] [span_warning("В этой кредитной фишке недостаточно денег.")]")
		return FALSE
	if(!cashmoney.use(price))
		return FALSE
	visible_message(span_notice("[user] вставляет кредитную фишку в [src]."))
	record_merconicism_sale(price)
	return TRUE

/obj/machinery/vending/tool/sect_merconicism/pay_with_card(mob/user, price, vended_name, datum/money_account/account_we_pay_on)
	if(!can_convert_sale_to_prana(user))
		return FALSE
	if(iscarbon(user))
		visible_message(span_notice("[user] проводит картой через [src]."))
	var/datum/money_account/customer_account = get_card_account(user)
	if(!customer_account)
		to_chat(user, span_warning("Ошибка: не удаётся получить доступ к счёту."))
		return FALSE
	if(customer_account.suspended)
		to_chat(user, span_warning("Невозможно получить доступ к счёту: счёт заблокирован."))
		return FALSE
	if(customer_account.security_level)
		var/attempt_pin = tgui_input_number(user, "Введите PIN-код", "Платёж торгомата", 111111, 999999, 111111)
		if(!attempt_account_access(customer_account.account_number, attempt_pin, 2))
			to_chat(user, span_warning("Невозможно получить доступ к счёту: неверные данные."))
			return FALSE
	if(price > customer_account.money)
		to_chat(user, span_warning("На вашем банковском счёте недостаточно денег для покупки."))
		return FALSE
	customer_account.credit(-price, "Покупка [vended_name]", name, bound_sect.name)
	if(customer_account.owner_name == GLOB.station_account.owner_name)
		add_game_logs("as silicon purchased [vended_name] in [COORD(src)]", user)
	SScapitalism.income_vedromat += price
	record_merconicism_sale(price)
	return TRUE

/obj/machinery/vending/tool/sect_merconicism/vend(datum/data/vending_product/product_record, mob/user, list/greyscale_colors)
	. = ..()
	if(!last_prana_sale)
		return
	credits_contained = max(0, credits_contained - round(last_prana_sale * VENDING_CREDITS_COLLECTION_AMOUNT))
	last_prana_sale = 0

/obj/machinery/vending/tool/sect_merconicism/get_ru_names()
	return list(
		NOMINATIVE = "божественный ларёк",
		GENITIVE = "божественного ларька",
		DATIVE = "божественному ларьку",
		ACCUSATIVE = "божественный ларёк",
		INSTRUMENTAL = "божественным ларьком",
		PREPOSITIONAL = "божественном ларьке",
	)

/obj/machinery/vending/tool/get_ru_names()
	return alist(
		NOMINATIVE = "торговый автомат YouTool",
		GENITIVE = "торгового автомата YouTool",
		DATIVE = "торговому автомату YouTool",
		ACCUSATIVE = "торговый автомат YouTool",
		INSTRUMENTAL = "торговым автоматом YouTool",
		PREPOSITIONAL = "торговом автомате YouTool",
	)
