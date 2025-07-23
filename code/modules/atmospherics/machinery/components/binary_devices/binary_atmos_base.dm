/obj/machinery/atmospherics/components/binary
	icon = 'icons/obj/atmospherics/binary_devices.dmi'
	dir = SOUTH
	initialize_directions = SOUTH|NORTH
	use_power = IDLE_POWER_USE

	layer = GAS_PIPE_VISIBLE_LAYER + GAS_PUMP_OFFSET
	layer_offset = GAS_PUMP_OFFSET
	device_type = BINARY


/obj/machinery/atmospherics/components/binary/SetInitDirections()
	switch(dir)
		if(NORTH)
			initialize_directions = NORTH|SOUTH
		if(SOUTH)
			initialize_directions = NORTH|SOUTH
		if(EAST)
			initialize_directions = EAST|WEST
		if(WEST)
			initialize_directions = EAST|WEST


/obj/machinery/atmospherics/components/binary/hide(intact)
	update_icon()

	..(intact)

/obj/machinery/atmospherics/components/binary/atmos_init()
	var/node2_connect = dir
	var/node1_connect = turn(dir, 180)

	var/list/node_connects = list(node1_connect, node2_connect)

	..(node_connects)
