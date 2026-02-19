/obj/item/pai_cable
	desc = "A flexible coated cable with a universal jack on one end."
	name = "data cable"
	icon = 'icons/obj/engines_and_power/power.dmi'
	icon_state = "wire1"
	item_flags = NOBLUDGEON
	var/obj/machinery/machine
	var/list/allowed_types = list(/obj/machinery/door, /obj/machinery/power/apc, /obj/machinery/alarm, /obj/machinery/computer/rdconsole)

/obj/item/pai_cable/proc/plugin(obj/machinery/M, mob/user)
	if(is_type_in_list(M, allowed_types))
		user.visible_message("[user] inserts [src] into a data port on [M].", "You insert [src] into a data port on [M].", "You hear the satisfying click of a wire jack fastening into place.")
		user.drop_transfer_item_to_loc(src, M)
		src.machine = M
	else
		user.visible_message("[user] dumbly fumbles to find a place on [M] to plug in [src].", "There aren't any ports on [M] that match the jack belonging to [src].")

/obj/item/pai_cable/afterattack(obj/machinery/M, mob/user, proximity, params)
	. = ..()
	if(istype(M) && proximity)
		plugin(M, user)
