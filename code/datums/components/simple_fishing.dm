/*
Fishing component. Added to all lava tiles. Used in catching... fish
I hope someone will port normal TG fishing someday, but for now...
*/

/datum/component/simple_fishing
	dupe_mode = COMPONENT_DUPE_UNIQUE

	/// Is the lava close to the shore
	var/deep_water = TRUE

	var/list/catchable_fish = list()

/datum/component/simple_fishing/Initialize()
	if(!istype(parent, /turf))
		return COMPONENT_INCOMPATIBLE
	if(locate(/turf/simulated/floor/plating/asteroid/basalt) in range(3, get_turf(parent)))
		deep_water = FALSE
	calculate_fish()


/datum/component/simple_fishing/proc/calculate_fish()
	if(deep_water)
		for(var/fish in subtypesof(/obj/item/lavaland_fish/deep_water))
			var/obj/item/lavaland_fish/deep_water/deep_fish = fish
			catchable_fish += deep_fish
	else
		for(var/fish in subtypesof(/obj/item/lavaland_fish/shoreline))
			var/obj/item/lavaland_fish/shoreline/shore_fish = fish
			catchable_fish += shore_fish
