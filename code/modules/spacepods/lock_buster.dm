/obj/item/lock_buster
	name = "pod lock buster"
	desc = "Destroys a podlock in mere seconds once applied. Waranty void if used."
	icon = 'icons/obj/device.dmi'
	icon_state = "lock_buster_off"
	var/on = FALSE


/obj/item/lock_buster/update_icon_state()
	icon_state = "lock_buster_[on ? "on" : "off"]"


/obj/item/lock_buster/attack_self(mob/user = usr)
	on = !on
	update_icon(UPDATE_ICON_STATE)
	to_chat(user, span_notice("You turn the [src] [on ? "on" : "off"]."))

