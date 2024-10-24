// This item just has an integrated camera console, which the data is "proxied" to
/obj/item/camera_bug
	name = "camera bug"
	desc = "For illicit snooping through the camera network."
	icon = 'icons/obj/device.dmi'
	icon_state	= "camera_bug"
	w_class		= WEIGHT_CLASS_TINY
	item_state	= "camera_bug"
	throw_speed	= 4
	throw_range	= 20
	origin_tech = "syndicate=1;engineering=3"
	/// Integrated camera console to serve UI data
	var/integrated_console_type = /obj/machinery/computer/security/camera_bug
	var/obj/machinery/computer/security/camera_bug/integrated_console
	var/list/network = list("SS13")

/obj/machinery/computer/security/camera_bug
	name = "invasive camera utility"
	desc = "How did this get here?! Please report this as a bug to github"
	use_power = NO_POWER_USE

/obj/item/camera_bug/Initialize(mapload)
	. = ..()
	integrated_console = new integrated_console_type(src)
	integrated_console.parent = src
	integrated_console.network = network

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
	desc = "A small handheld device used by ERT commanders to view camera feeds remotely."

/obj/item/camera_bug/ert/Initialize(mapload)
	. = ..()
	integrated_console.network = list("ERT")

