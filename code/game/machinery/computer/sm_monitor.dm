/obj/machinery/computer/sm_monitor
	name = "консоль мониторинга суперматерии"
	desc = "Crystal Integrity Monitoring System, connects to specially calibrated supermatter sensors to provide information on the status of supermatter-based engines."
	icon_keyboard = "power_key"
	icon_screen = "smmon_0"
	circuit = /obj/item/circuitboard/sm_monitor
	light_color = LIGHT_COLOR_DIM_YELLOW
	/// Last status of the active supermatter for caching purposes
	var/last_status = SUPERMATTER_INACTIVE
	var/datum/ui_module/supermatter_monitor/monitor

/obj/machinery/computer/sm_monitor/get_ru_names()
	return alist(
		NOMINATIVE = "консоль мониторинга суперматерии",
		GENITIVE = "консоли мониторинга суперматерии",
		DATIVE = "консоли мониторинга суперматерии",
		ACCUSATIVE = "консоль мониторинга суперматерии",
		INSTRUMENTAL = "консолью мониторинга суперматерии",
		PREPOSITIONAL = "консоли мониторинга суперматерии"
	)

/obj/machinery/computer/sm_monitor/Initialize(mapload, obj/structure/computerframe/frame)
	. = ..()
	monitor = new(src)
	monitor.refresh()

/obj/machinery/computer/sm_monitor/Destroy()
	QDEL_NULL(monitor)
	return ..()

/obj/machinery/computer/sm_monitor/attack_ai(mob/user)
	attack_hand(user)

/obj/machinery/computer/sm_monitor/attack_hand(mob/user)
	if(stat & (BROKEN|NOPOWER))
		return

	if(..())
		return TRUE

	add_fingerprint(user)
	ui_interact(user)

/obj/machinery/computer/sm_monitor/ui_interact(mob/user, datum/tgui/ui = null)
	monitor.ui_interact(user, ui)

/obj/machinery/computer/sm_monitor/process()
	if(stat & (NOPOWER|BROKEN))
		return FALSE

	var/new_status = monitor.get_status()
	if(last_status != new_status)
		last_status = new_status
		icon_screen = "smmon_[last_status]"
		update_appearance()

	return TRUE
