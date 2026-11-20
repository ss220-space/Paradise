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

/obj/vehicle/ridden/car/cat
	name = "catr"
	desc = "Эта машина настолько пушистая что в ней можно утонуть."
	icon = 'icons/mob/pets.dmi'
	icon_state = "penny"
	var/can_bump_stan = TRUE

/obj/vehicle/ridden/car/cat/get_ru_names()
	return alist(
		NOMINATIVE = "кошина",
		GENITIVE = "кошины",
		DATIVE = "кошине",
		ACCUSATIVE = "кошину",
		INSTRUMENTAL = "кошиной",
		PREPOSITIONAL = "кошине",
	)

/obj/vehicle/ridden/car/cat/Initialize(mapload)
	. = ..()
	var/matrix/cat_transform = matrix(transform)
	cat_transform.Scale(2.5, 1)
	transform = cat_transform

/obj/vehicle/ridden/car/cat/Bump(atom/bumped_atom)
	. = ..()
	if(!can_bump_stan || !ishuman(bumped_atom))
		return
	can_bump_stan = FALSE
	var/mob/living/carbon/human/bumped_human = bumped_atom
	playsound(src, 'sound/voice/tajarahiss.mp3', 50, TRUE)
	bumped_human.Knockdown(1 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(reset_bump_stun)), 10 SECONDS)

/obj/vehicle/ridden/car/cat/proc/reset_bump_stun()
	can_bump_stan = TRUE

/obj/vehicle/ridden/car/cat/update_overlays()
	return mutable_appearance(icon, "penny", ABOVE_MOB_LAYER)

#undef CAR_COVER_NORTH
#undef CAR_COVER_SOUTH
#undef CAR_COVER_EAST
#undef CAR_COVER_WEST
