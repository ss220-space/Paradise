/** Money printer
 * author: trava0861
 */
/obj/machinery/money_printer
	name = "money printer"
	desc = "Устройство для печати кредитов, очевидно является нелегальным."
	icon = 'icons/obj/money_printer.dmi'
	icon_state = "money_printer"
	density = TRUE
	anchored = TRUE
	var/printer_level = 1
	var/print_delay = 60 SECONDS
	var/print_credits_amount = 400
	var/total_credits_amount = 0
	var/max_credits_amount = 100000
	var/work_timer
	var/opened = FALSE

/obj/machinery/money_printer/get_ru_names()
	return list(
		NOMINATIVE = "принтер кредитов",
		GENITIVE = "принтера кредитов",
		DATIVE = "принтеру кредитов",
		ACCUSATIVE = "принтер кредитов",
		INSTRUMENTAL = "принтером кредитов",
		PREPOSITIONAL = "принтере кредитов",
	)

/obj/machinery/money_printer/Initialize(mapload)
	. = ..()
	start_print()

/obj/machinery/money_printer/proc/start_print()
	work_timer = addtimer(CALLBACK(src, PROC_REF(do_print_money)), print_delay, TIMER_STOPPABLE | TIMER_LOOP)

/obj/machinery/money_printer/proc/stop_print()
	if(!work_timer)
		return
	if(deltimer(work_timer))
		work_timer = null

/obj/machinery/money_printer/proc/do_print_money()
	playsound(src, 'sound/machines/cash_machine.wav', 50, TRUE)
	total_credits_amount = min(total_credits_amount + print_credits_amount, max_credits_amount)
	if(opened)
		close_cash()

/obj/machinery/money_printer/wrench_act(mob/user, obj/item/item)
	. = TRUE
	if(!item.use_tool(src, user, 0, volume = item.tool_volume))
		return
	set_anchored(!anchored)
	if(anchored)
		WRENCH_ANCHOR_MESSAGE
	else
		stop_print()
		WRENCH_UNANCHOR_MESSAGE

/obj/machinery/money_printer/attack_hand(mob/user)
	. = ..()
	if(opened)
		close_cash()
		return

	opened = TRUE
	icon_state = "[initial(icon_state)]_opened"
	update_icon(UPDATE_ICON_STATE)
	if(total_credits_amount <= 0)
		return

	var/obj/item/stack/spacecash/credits = new(src)
	credits.amount = total_credits_amount
	total_credits_amount = 0
	credits.forceMove(loc)

/obj/machinery/money_printer/proc/close_cash()
	opened = FALSE
	icon_state = initial(icon_state)
	update_icon(UPDATE_ICON_STATE)
	return

/obj/machinery/money_printer/click_alt(mob/user)
	. = ..()
	if(work_timer)
		stop_print()
		balloon_alert_to_viewers("принтер выключен", "принтер выключен")
		return
	start_print()
	balloon_alert_to_viewers("принтер включен", "принтер включен")

/obj/machinery/money_printer/examine(mob/user)
	. = ..()
	. += "<b>Уровень [printer_level].</b>"
	. += "<b>Скорость печати:</b> [print_credits_amount] кредитов за [print_delay / 10] секунд."
	. += span_notice("<b>Доступно кредитов:</b> [total_credits_amount]/[max_credits_amount].")

	if(work_timer)
		. += "<b>Статус:</b> принтер работает."
		. += span_italics("Используйте Alt+Клик чтобы выключить принтер.")
	else
		. += "<b>Статус:</b> принтер выключен."
		. += span_italics("Используйте Alt+Клик чтобы включить принтер.")


// MARK: Craft blueprints
/obj/item/craft_blueprints/one_use/money_printer
	crafting_name = "Принтер кредитов"
	tools = list(TOOL_WRENCH, TOOL_SCREWDRIVER)
	components = list(
		/obj/item/stack/sheet/metal = 30,
		/obj/item/stack/sheet/glass = 10,
	)
	var/printer_level = 1
	var/money_amount = 400

/obj/item/craft_blueprints/one_use/money_printer/create_craft_item(mob/user)
	var/obj/machinery/money_printer/printer = new /obj/machinery/money_printer(loc)
	printer.printer_level = printer_level
	printer.print_credits_amount = money_amount
	return printer

/obj/item/craft_blueprints/one_use/money_printer/level2
	components = list(
		/obj/item/stack/sheet/metal = 60,
		/obj/item/stack/sheet/mineral/silver = 10,
	)
	printer_level = 2
	money_amount = 800

/obj/item/craft_blueprints/one_use/money_printer/level3
	components = list(
		/obj/item/stack/sheet/metal = 90,
		/obj/item/stack/sheet/glass = 10,
		/obj/item/stack/sheet/mineral/silver = 10,
		/obj/item/stack/sheet/mineral/gold = 10,
	)
	printer_level = 3
	money_amount = 1600

/obj/item/craft_blueprints/one_use/money_printer/level4
	components = list(
		/obj/item/stack/sheet/metal = 120,
		/obj/item/stack/sheet/glass = 10,
		/obj/item/stack/sheet/mineral/uranium = 10,
		/obj/item/stack/sheet/mineral/diamond = 1,
	)
	printer_level = 4
	money_amount = 3200

/obj/item/craft_blueprints/one_use/money_printer/level5
	components = list(
		/obj/item/stack/sheet/metal = 100,
		/obj/item/stack/sheet/glass = 50,
		/obj/item/stack/ore/bluespace_crystal = 20,
		/obj/item/stack/sheet/mineral/diamond = 5,
	)
	printer_level = 5
	money_amount = 10000
