/datum/aoe_targeting/rev_haunt/get_targets(atom/center, aoe_radius)
	var/list/targets = list()
	for(var/obj/item/nearby_item in range(aoe_radius, center))
		// Don't throw around anchored things or dense things
		// (Or things not on a turf but I am not sure if range can catch that)
		if(nearby_item.anchored || nearby_item.density || nearby_item.move_resist == INFINITY || !isturf(nearby_item.loc))
			continue
		// Don't throw abstract things
		if(nearby_item.item_flags & ABSTRACT)
			continue
		// Don't throw things we can't see
		if(nearby_item.invisibility > owner.see_invisible)
			continue

		var/distance_from_user = max(get_dist(get_turf(nearby_item), get_turf(owner)), 1) // get_dist() for same tile dists return -1, we do not want that
		var/chance_of_haunting = 150 / distance_from_user // The further away things are, the less likely they are to be picked
		if(!prob(chance_of_haunting))
			continue
		targets += nearby_item
	return targets
