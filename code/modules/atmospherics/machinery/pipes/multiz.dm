/obj/machinery/atmospherics/pipe/multiz ///This is an atmospherics pipe which can relay air up and down deck (Z+1).
	name = "multi deck pipe adapter"
	desc = "An adapter which allows pipes to connect to other pipenets on different decks."
	icon = 'icons/obj/pipes_and_stuff/atmospherics/pipes.dmi'
	icon_state = "multiz"
	dir = SOUTH
	layer = GAS_PIPE_VISIBLE_LAYER+0.1

	volume = 105

	var/obj/machinery/atmospherics/node
	var/obj/machinery/atmospherics/pipe/multiz/above
	var/obj/machinery/atmospherics/pipe/multiz/below
	can_be_undertile = FALSE
	can_buckle = FALSE

/*
/obj/machinery/atmospherics/pipe/multiz/update_icon()
	. = ..()
	cut_overlays() //This adds the overlay showing it's a multiz pipe. This should go above turfs and such
	var/image/multiz_overlay_node = new(src) //If we have a firing state, light em up!
	multiz_overlay_node.icon = 'icons/obj/atmos.dmi'
	multiz_overlay_node.icon_state = "multiz_pipe"
	multiz_overlay_node.layer = HIGH_OBJ_LAYER
	add_overlay(multiz_overlay_node)
*/

/obj/machinery/atmospherics/pipe/multiz/New()
	..()
	initialize_directions = dir

/obj/machinery/atmospherics/pipe/multiz/hide(var/i)
	return

/obj/machinery/atmospherics/pipe/multiz/pipeline_expansion()
	return list(node, above, below)

/obj/machinery/atmospherics/pipe/multiz/process_atmos()
	if(!parent)
		..()
	else
		. = PROCESS_KILL

/obj/machinery/atmospherics/pipe/multiz/Destroy()
	. = ..()
	if(node)
		node.disconnect(src)
		node.defer_build_network()
		node = null
	if(above)
		above.disconnect(src)
		above.defer_build_network()
		above = null
	if(below)
		below.disconnect(src)
		below.defer_build_network()
		below = null


/obj/machinery/atmospherics/pipe/multiz/disconnect(obj/machinery/atmospherics/reference)
	if(reference == node)
		if(istype(node, /obj/machinery/atmospherics/pipe))
			qdel(parent)
		node = null
	if(reference == above)
		if(istype(above, /obj/machinery/atmospherics/pipe))
			qdel(parent)
		above = null
	if(reference == below)
		if(istype(below, /obj/machinery/atmospherics/pipe))
			qdel(parent)
		below = null

	check_nodes_exist()
	update_icon()

	..()

/obj/machinery/atmospherics/pipe/multiz/atmos_init()
	..()
	for(var/obj/machinery/atmospherics/target in get_step(src, dir))
		if(target.initialize_directions & get_dir(target,src))
			var/c = check_connect_types(target,src)
			if(c)
				target.connected_to = c
				src.connected_to = c
				node = target
				break
	var/obj/machinery/atmospherics/above_temp = locate(/obj/machinery/atmospherics/pipe/multiz) in get_step_multiz(src, UP)
	var/obj/machinery/atmospherics/below_temp = locate(/obj/machinery/atmospherics/pipe/multiz) in get_step_multiz(src, DOWN)
	if(above_temp)
		above = above_temp
	if(below_temp)
		below = below_temp

	update_icon()

// self-delete if they aren't present
/obj/machinery/atmospherics/pipe/multiz/check_nodes_exist()
	if(!node && !above && !below)
		deconstruct()
		return FALSE //No nodes exist
	return TRUE

/obj/machinery/atmospherics/pipe/multiz/change_color(var/new_color)
	return // no
