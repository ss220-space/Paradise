/obj/structure/plasticflaps
	name = "plastic flaps"
	desc = "Completely impassable - or are they?"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "plasticflaps"
	density = FALSE
	anchored = TRUE
	pass_flags_self = PASSFLAPS
	can_astar_pass = CANASTARPASS_ALWAYS_PROC
	opacity = TRUE
	layer = 4
	armor = list(melee = 100, bullet = 80, laser = 80, energy = 100, bomb = 50, bio = 100, rad = 100, fire = 50, acid = 50)
	var/state = PLASTIC_FLAPS_NORMAL

/obj/structure/plasticflaps/examine(mob/user)
	. = ..()
	switch(state)
		if(PLASTIC_FLAPS_NORMAL)
			. += "<span class='notice'>[src] are <b>screwed</b> to the floor.</span>"
		if(PLASTIC_FLAPS_DETACHED)
			. += "<span class='notice'>[src] are no longer <i>screwed</i> to the floor, and the flaps can be <b>sliced</b> apart.</span>"

/obj/structure/plasticflaps/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	if(state == PLASTIC_FLAPS_NORMAL)
		user.visible_message("<span class='warning'>[user] starts unscrewing [src] from the floor...</span>", "<span class='notice'>You start to unscrew [src] from the floor...</span>", "You hear rustling noises.")
		if(!I.use_tool(src, user, 180, volume = I.tool_volume) || state != PLASTIC_FLAPS_NORMAL)
			return
		state = PLASTIC_FLAPS_DETACHED
		opacity = FALSE
		set_anchored(FALSE)
		to_chat(user, "<span class='notice'>You unscrew [src] from the floor.</span>")
	else if(state == PLASTIC_FLAPS_DETACHED)
		user.visible_message("<span class='warning'>[user] starts screwing [src] to the floor.</span>", "<span class='notice'>You start to screw [src] to the floor...</span>", "You hear rustling noises.")
		if(!I.use_tool(src, user, 40, volume = I.tool_volume) || state != PLASTIC_FLAPS_DETACHED)
			return
		opacity = TRUE
		state = PLASTIC_FLAPS_NORMAL
		set_anchored(TRUE)
		to_chat(user, "<span class='notice'>You screw [src] to the floor.</span>")

/obj/structure/plasticflaps/welder_act(mob/user, obj/item/I)
	if(state != PLASTIC_FLAPS_DETACHED)
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	WELDER_ATTEMPT_SLICING_MESSAGE
	if(I.use_tool(src, user, 120, volume = I.tool_volume))
		WELDER_SLICING_SUCCESS_MESSAGE
		var/obj/item/stack/sheet/plastic/five/P = new(drop_location())
		P.add_fingerprint(user)
		qdel(src)


/obj/structure/plasticflaps/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()

	if(checkpass(mover, PASSFLAPS)) //For anything specifically engineered to cross plastic flaps.
		return TRUE

	if(checkpass(mover, PASSGLASS))
		return prob(60)

	if(istype(mover, /obj/structure/bed))
		var/obj/structure/bed/bed_mover = mover
		if(bed_mover.density || bed_mover.has_buckled_mobs())	//if it's a bed/chair and is dense or someone is buckled, it will not pass
			return FALSE

	else if(ismecha(mover))
		return FALSE

	else if(isliving(mover)) // You Shall Not Pass!
		var/mob/living/living_mover = mover
		if(istype(living_mover.buckled, /mob/living/simple_animal/bot/mulebot)) // mulebot passenger gets a free pass.
			return TRUE

		if(living_mover.body_position != LYING_DOWN && living_mover.mob_size != MOB_SIZE_TINY && !is_ventcrawler(living_mover))	//If your not laying down, or a ventcrawler or a small creature, no pass.
			return FALSE


/obj/structure/plasticflaps/CanAStarPass(to_dir, datum/can_pass_info/pass_info)
	if(pass_info.is_living)
		if(pass_info.is_bot)
			return TRUE
		if(!pass_info.can_ventcrawl && pass_info.mob_size != MOB_SIZE_TINY)
			return FALSE

	if(pass_info.pulling_info)
		return CanAStarPass(to_dir, pass_info.pulling_info)
	return TRUE //diseases, stings, etc can pass


/obj/structure/plasticflaps/deconstruct(disassembled = TRUE)
	if(!(obj_flags & NODECONSTRUCT))
		new /obj/item/stack/sheet/plastic/five(loc)
	qdel(src)

/obj/structure/plasticflaps/mining //A specific type for mining that doesn't allow airflow because of them damn crates
	name = "airtight plastic flaps"
	desc = "Heavy duty, airtight, plastic flaps."

/obj/structure/plasticflaps/mining/Initialize()
	air_update_turf(TRUE)
	. = ..()

/obj/structure/plasticflaps/mining/Destroy()
	var/turf/T = get_turf(src)
	. = ..()
	T.air_update_turf(TRUE)

/obj/structure/plasticflaps/mining/CanAtmosPass(turf/T, vertical)
	return FALSE
