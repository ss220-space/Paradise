/** Money printer
 * author: trava0861
 */
/obj/machinery/money_printer
	name = "money printer"
	desc = "Устройство для печати кредитов, очевидно является нелегальным."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "papershredder0"
	density = TRUE
	anchored = TRUE
	var/print_delay = 60 SECONDS
	var/credits_amount = 100
	var/work_timer

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

/obj/machinery/money_printer/proc/start_print(mob/user)
	work_timer = addtimer(CALLBACK(src, PROC_REF(do_print_money)), print_delay, TIMER_STOPPABLE | TIMER_LOOP)

/obj/machinery/money_printer/proc/stop_print(mob/user)
	if(!work_timer)
		return
	if(deltimer(work_timer))
		work_timer = null

/obj/machinery/money_printer/proc/do_print_money()
	playsound(src, 'sound/machines/cash_machine.wav', 50, TRUE)
	var/obj/item/stack/spacecash/credits = new(src)
	credits.amount = credits_amount
	credits.update_icon_state()
	credits.forceMove(loc)

/obj/machinery/money_printer/wrench_act(mob/user, obj/item/item)
	. = TRUE
	if(!item.use_tool(src, user, 0, volume = item.tool_volume))
		return
	set_anchored(!anchored)
	if(anchored)
		WRENCH_ANCHOR_MESSAGE
	else
		WRENCH_UNANCHOR_MESSAGE

/obj/machinery/money_printer/attack_hand(mob/user)
	. = ..()
	if(work_timer)
		stop_print(user)
		balloon_alert_to_viewers("Принтер выключен", "Принтер выключен")
		return
	start_print(user)
	balloon_alert_to_viewers("Принтер включен", "Принтер выключен")

/obj/machinery/money_printer/examine(mob/user)
	. = ..()
	if(work_timer)
		. += span_notice("Принтер работает.")
		return
	. += span_notice("Принтер выключен.")


// MARK: Craft blueprints
/obj/item/craft_blueprints/one_use/money_printer
	crafting_name = "Принтера кредитов"
	tools = list(TOOL_WRENCH, TOOL_SCREWDRIVER)
	components = list(
		/obj/item/stack/sheet/metal = 30,
		/obj/item/stack/sheet/glass = 10,
	)
	var/printer_sprite = "papershredder1"
	var/money_amount = 400

/obj/item/craft_blueprints/one_use/money_printer/create_craft_item(mob/user)
	var/obj/machinery/money_printer/printer = new /obj/machinery/money_printer(loc)
	printer.icon_state = printer_sprite
	printer.update_icon()
	printer.credits_amount = money_amount
	return printer

/obj/item/craft_blueprints/one_use/money_printer/level2
	components = list(
		/obj/item/stack/sheet/metal = 30,
		/obj/item/stack/sheet/mineral/silver = 10,
	)
	printer_sprite = "papershredder2"
	money_amount = 800

/obj/item/craft_blueprints/one_use/money_printer/level3
	components = list(
		/obj/item/stack/sheet/metal = 30,
		/obj/item/stack/sheet/glass = 10,
		/obj/item/stack/sheet/mineral/silver = 10,
		/obj/item/stack/sheet/mineral/gold = 10,
	)
	printer_sprite = "papershredder3"
	money_amount = 1600

/obj/item/craft_blueprints/one_use/money_printer/level4
	components = list(
		/obj/item/stack/sheet/metal = 30,
		/obj/item/stack/sheet/glass = 10,
		/obj/item/stack/sheet/mineral/uranium = 10,
		/obj/item/stack/sheet/mineral/diamond = 1,
	)
	printer_sprite = "papershredder4"
	money_amount = 3200

/obj/item/craft_blueprints/one_use/money_printer/level5
	components = list(
		/obj/structure/toilet/captain_toilet = 1,
		/obj/item/stack/ore/bluespace_crystal = 20,
	)
	printer_sprite = "papershredder5"
	money_amount = 10000
