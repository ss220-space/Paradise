/obj/machinery/atmospherics/components/unary
	icon = 'icons/obj/atmospherics/unary_devices.dmi'
	dir = SOUTH
	initialize_directions = SOUTH
	layer = TURF_LAYER+0.1
	device_type = UNARY
	var/id_tag

/obj/machinery/atmospherics/components/unary/SetInitDirections()
	initialize_directions = dir


/obj/machinery/atmospherics/components/unary/hide(intact)
	update_icon()

	..(intact)
/*
Housekeeping and pipe network stuff below
*/

/obj/machinery/atmospherics/components/unary/default_change_direction_wrench(mob/user, obj/item/wrench/W)
	if(..())
		return 0
	initialize_directions = dir
	var/obj/machinery/atmospherics/node = NODE1

	if(node)
		node.disconnect(src)
		NODE1 = null

	nullifyPipenet(PARENT1)
	atmos_init()
	if(node)
		node.atmos_init()
		node.addMember(src)
	build_network()
	. = 1
	NODE1 = node
