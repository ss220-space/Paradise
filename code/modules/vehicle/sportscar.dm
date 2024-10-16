/obj/vehicle/ridden/car
	name = "sports car"
	desc = "A very luxurious vehicle."
	icon = 'icons/obj/vehicles/sportscar.dmi'
	icon_state = "sportscar"
	pull_push_slowdown = 2

/obj/vehicle/ridden/car/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/car)


#define CAR_COVER_NORTH 1
#define CAR_COVER_SOUTH 2
#define CAR_COVER_EAST 3
#define CAR_COVER_WEST 4

/obj/vehicle/ridden/car/update_overlays()
	. = ..()
	if(!has_buckled_mobs())
		return .

	var/static/list/car_covers_cache[4]
	car_covers_cache[CAR_COVER_NORTH] = mutable_appearance(icon, "sportscar_north", ABOVE_MOB_LAYER)
	car_covers_cache[CAR_COVER_SOUTH] = mutable_appearance(icon, "sportscar_south", ABOVE_MOB_LAYER)
	car_covers_cache[CAR_COVER_EAST] = mutable_appearance(icon, "sportscar_east", ABOVE_MOB_LAYER)
	car_covers_cache[CAR_COVER_WEST] = mutable_appearance(icon, "sportscar_west", ABOVE_MOB_LAYER)

	switch(dir)
		if(NORTH)
			. += car_covers_cache[CAR_COVER_NORTH]
		if(SOUTH)
			. += car_covers_cache[CAR_COVER_SOUTH]
		if(EAST)
			. += car_covers_cache[CAR_COVER_EAST]
		if(WEST)
			. += car_covers_cache[CAR_COVER_WEST]

#undef CAR_COVER_NORTH
#undef CAR_COVER_SOUTH
#undef CAR_COVER_EAST
#undef CAR_COVER_WEST
