/datum/aoe_targeting/doors_and_closets/get_targets(atom/center, aoe_radius)
	var/list/things = list()

	for(var/obj/machinery/door/door in range(aoe_radius, center))
		if(istype(door, /obj/machinery/door/airlock/hatch/gamma))
			continue
		things += door

	for(var/obj/structure/closet/closet in range(aoe_radius, center))
		things += closet

	return things
