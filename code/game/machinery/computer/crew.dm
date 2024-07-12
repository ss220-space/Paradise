/obj/machinery/computer/crew
	name = "crew monitoring computer"
	desc = "Used to monitor active health sensors built into most of the crew's uniforms."
	icon_keyboard = "med_key"
	icon_screen = "crew"
	use_power = IDLE_POWER_USE
	idle_power_usage = 250
	active_power_usage = 500
	light_color = LIGHT_COLOR_DARKBLUE
	circuit = /obj/item/circuitboard/crew
	var/datum/ui_module/crew_monitor/crew_monitor

/obj/machinery/computer/crew/New()
	crew_monitor = new(src)
	..()

/obj/machinery/computer/crew/Destroy()
	QDEL_NULL(crew_monitor)
	return ..()

/obj/machinery/computer/crew/attack_ai(mob/user)
	attack_hand(user)

/obj/machinery/computer/crew/attack_hand(mob/user)
	if(stat & (BROKEN|NOPOWER))
		return

	if(..())
		return TRUE

	add_fingerprint(user)
	ui_interact(user)

/obj/machinery/computer/crew/ui_interact(mob/user, datum/tgui/ui = null)
	crew_monitor.ui_interact(user, ui)

/obj/machinery/computer/crew/interact(mob/user)
	crew_monitor.ui_interact(user)

/obj/machinery/computer/crew/old_frame
	icon = 'icons/obj/machines/computer3.dmi'
	icon_screen = "med_oldframe"
	icon_state = "frame-med"
	icon_keyboard = "kb3"
