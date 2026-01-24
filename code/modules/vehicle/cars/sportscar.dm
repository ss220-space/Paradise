/*
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

*/

/// Big 3x3 car only available to admins which can run people over
/obj/vehicle/sealed/car/speedwagon
	name = "BM Speedwagon"
	desc = "Push it to the limit, walk along the razor's edge."
	icon = 'icons/obj/vehicles/car.dmi'
	icon_state = "speedwagon"
	layer = LYING_MOB_LAYER
	max_occupants = 4
	pixel_y = -48
	pixel_x = -48
	enter_delay = 0 SECONDS
	escape_time = 0 SECONDS // Just get out dumbass
	vehicle_move_delay = 0
	///Determines whether we throw all things away when ramming them or just mobs, varedit only
	var/crash_all = FALSE
	var/overlay_state = "speedwagon_cover"
	var/mutable_appearance/cover_overlay

/obj/vehicle/ridden/speedbike/Initialize(mapload)
	. = ..()
	cover_overlay = mutable_appearance(icon, overlay_state, ABOVE_MOB_LAYER)

/obj/vehicle/ridden/speedbike/Destroy()
	cover_overlay = null
	return ..()

/obj/vehicle/sealed/car/speedwagon/update_overlays()
	. = ..()
	if(!has_buckled_mobs())
		return .
	//cover_overlay = color_atom_overlay(cover_overlay)
	. += cover_overlay

/obj/vehicle/sealed/car/speedwagon/Bump(atom/bumped)
	. = ..()
	if(!bumped.density || occupant_amount() == 0)
		return

	if(crash_all)
		if(ismovable(bumped))
			var/atom/movable/flying_debris = bumped
			flying_debris.throw_at(get_edge_target_turf(bumped, dir), 4, 3)
		visible_message(span_danger("[src] crashes into [bumped]!"))
		playsound(src, 'sound/effects/bang.ogg', 50, TRUE)
	if(!ishuman(bumped))
		return
	var/mob/living/carbon/human/rammed = bumped
	rammed.Paralyse(100)
	rammed.adjustStaminaLoss(30)
	rammed.apply_damage(rand(20,35), BRUTE)
	if(!crash_all)
		rammed.throw_at(get_edge_target_turf(bumped, dir), 4, 3)
		visible_message(span_danger("[src] crashes into [rammed]!"))
		playsound(src, 'sound/effects/bang.ogg', 50, TRUE)

/obj/vehicle/sealed/car/speedwagon/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	if(occupant_amount() == 0)
		return
	for(var/atom/future_statistic in range(2, src))
		if(future_statistic == src)
			continue
		if(!LAZYACCESS(occupants, future_statistic))
			Bump(future_statistic)