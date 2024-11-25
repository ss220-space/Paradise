// This item just has an integrated camera console, which the data is "proxied" to
/obj/item/camera_bug
	name = "camera bug"
	desc = "Для незаконного слежения через сеть камер наблюдения."
	icon = 'icons/obj/device.dmi'
	icon_state	= "camera_bug"
	w_class		= WEIGHT_CLASS_TINY
	item_state	= "camera_bug"
	throw_speed	= 4
	throw_range	= 20
	origin_tech = "syndicate=1;engineering=3"
	/// Integrated camera console to serve UI data
	var/obj/machinery/computer/security/camera_bug/integrated_console

/obj/machinery/computer/security/camera_bug
	name = "invasive camera utility"
	desc = "Как это сюда попало?! Пожалуйста, сообщите об этом как об ошибке на github."
	use_power = NO_POWER_USE

/obj/item/camera_bug/Initialize(mapload)
	. = ..()
	integrated_console = new(src)
	integrated_console.parent = src
	integrated_console.network = list("SS13")

/obj/item/camera_bug/Destroy()
	QDEL_NULL(integrated_console)
	return ..()

/obj/item/camera_bug/attack_self(mob/user as mob)
	ui_interact(user)

/obj/item/camera_bug/ui_state(mob/user)
	return GLOB.inventory_state

/obj/item/camera_bug/ui_interact(mob/user, datum/tgui/ui = null)
	integrated_console.ui_interact(user, ui)

/obj/item/camera_bug/ert
	name = "ERT Camera Monitor"
	desc = "Небольшое портативное устройство, используемое командирами ОБР для удаленного наблюдения."

/obj/item/camera_bug/ert/Initialize(mapload)
	. = ..()
	integrated_console.network = list("ERT")

