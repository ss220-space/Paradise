/obj/vehicle/car
	name = "sports car"
	desc = "A very luxurious vehicle."
	icon = 'icons/obj/vehicles/sportscar.dmi'
	icon_state = "sportscar"
	vehicle_move_delay = 0.25 SECONDS
	pull_push_slowdown = 2


#define CAR_COVER_NORTH 1
#define CAR_COVER_SOUTH 2
#define CAR_COVER_EAST 3
#define CAR_COVER_WEST 4

/obj/vehicle/car/update_overlays()
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


/obj/vehicle/car/handle_vehicle_icons()
	update_icon(UPDATE_OVERLAYS)


/obj/vehicle/car/handle_vehicle_offsets()
	if(!has_buckled_mobs())
		return
	for(var/mob/living/buckled_mob as anything in buckled_mobs)
		buckled_mob.setDir(dir)
		switch(dir)
			if(NORTH)
				buckled_mob.pixel_x = 2
				buckled_mob.pixel_y = 20
			if(EAST)
				buckled_mob.pixel_x = 20
				buckled_mob.pixel_y = 23
			if(SOUTH)
				buckled_mob.pixel_x = 20
				buckled_mob.pixel_y = 27
			if(WEST)
				buckled_mob.pixel_x = 34
				buckled_mob.pixel_y = 10


/obj/vehicle/car/handle_vehicle_layer()
	return	// we got custom layers, dont worry

