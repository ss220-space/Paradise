/*
Fishing component. Added to all lava tiles. Used in catching... fish
I hope someone will port normal TG fishing someday, but for now...
*/

/datum/component/simple_fishing
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/deep_water = TRUE

/datum/component/simple_fishing/Initialize()
	if(!istype(parent, /turf))
		return COMPONENT_INCOMPATIBLE
	if(locate(/turf/simulated/floor/plating/asteroid/basalt) in range(3, get_turf(parent)))
		deep_water = FALSE
