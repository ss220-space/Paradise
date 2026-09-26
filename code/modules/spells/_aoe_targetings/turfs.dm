/datum/aoe_targeting/turfs/get_targets(atom/center, aoe_radius)
	var/list/turfs = list()
	for(var/turf/turf in RANGE_TURFS(aoe_radius, center))
		turfs += turf
	return turfs
