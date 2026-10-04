/datum/aoe_targeting/light/get_targets(atom/center, aoe_radius)
	var/list/targets = list()
	for(var/obj/machinery/light/target in range(aoe_radius, center))
		targets += target
	return targets
