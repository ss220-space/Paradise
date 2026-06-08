//local gps units to let the ruins be found easier.

/obj/item/gps/ruin
	name = "navigation console"
	desc = "A console for navigation in local space, gives off a weak signal that can be picked up if sufficiently close."
	icon = 'icons/obj/machines/terminals.dmi'
	icon_state = "gps_console"
	anchored = TRUE
	local = TRUE
	gpstag = "Unknown Signal"

/obj/item/gps/ruin/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_MOUSEDROP_ONTO, PROC_REF(on_mousedrop_onto))

/obj/item/gps/ruin/proc/on_mousedrop_onto(datum/source, atom/over, mob/user)
	SIGNAL_HANDLER
	if(anchored)
		user.balloon_alert(user, "прикручен к стене!")
		return COMPONENT_CANCEL_MOUSEDROP_ONTO
	return NONE

/obj/item/gps/ruin/ui_state(mob/user)
	return GLOB.default_state

/obj/item/gps/ruin/attack_hand(mob/user)
	attack_self(user)
