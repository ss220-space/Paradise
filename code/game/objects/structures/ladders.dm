// Basic ladder. By default links to the z-level above/below.
/obj/structure/ladder
	name = "ladder"
	desc = "A sturdy metal ladder."
	icon = 'icons/obj/structures.dmi'
	icon_state = "ladder11"
	anchored = TRUE
	var/obj/structure/ladder/down   //the ladder below this one
	var/obj/structure/ladder/up     //the ladder above this one
	obj_flags = BLOCK_Z_OUT_DOWN
	/// Optional travel time for ladder in deciseconds
	var/travel_time = 0

/obj/structure/ladder/Initialize(mapload, obj/structure/ladder/up, obj/structure/ladder/down)
	..()
	if (up)
		src.up = up
		up.down = src
		up.update_icon(UPDATE_ICON_STATE)
	if (down)
		src.down = down
		down.up = src
		down.update_icon(UPDATE_ICON_STATE)
	return INITIALIZE_HINT_LATELOAD

/obj/structure/ladder/Destroy(force)
	if((resistance_flags & INDESTRUCTIBLE) && !force)
		return QDEL_HINT_LETMELIVE
	disconnect()
	return ..()

/obj/structure/ladder/LateInitialize()
	// By default, discover ladders above and below us vertically
	var/turf/T = get_turf(src)
	var/obj/structure/ladder/L

	if(!down)
		L = locate() in GET_TURF_BELOW(T)
		if(L)
			down = L
			L.up = src  // Don't waste effort looping the other way
			L.update_icon(UPDATE_ICON_STATE)
	if(!up)
		L = locate() in GET_TURF_ABOVE(T)
		if(L)
			up = L
			L.down = src  // Don't waste effort looping the other way
			L.update_icon()

	update_icon(UPDATE_ICON_STATE)

/obj/structure/ladder/proc/disconnect()
	if(up && up.down == src)
		up.down = null
		up.update_icon()
	if(down && down.up == src)
		down.up = null
		down.update_icon()
	up = down = null

/obj/structure/ladder/update_icon_state()
	if(up && down)
		icon_state = "ladder11"

	else if(up)
		icon_state = "ladder10"

	else if(down)
		icon_state = "ladder01"

	else	//wtf make your ladders properly assholes
		icon_state = "ladder00"

/obj/structure/ladder/singularity_pull()
	if(!(resistance_flags & INDESTRUCTIBLE))
		visible_message("<span class='danger'>[src] is torn to pieces by the gravitational pull!</span>")
		qdel(src)

/obj/structure/ladder/proc/travel(going_up, mob/user, is_ghost, obj/structure/ladder/ladder)
	if(!is_ghost)
		ladder.add_fingerprint(user)
		if(!do_after(user, travel_time, src))
			return
		show_fluff_message(going_up, user)

	var/turf/target = get_turf(ladder)
	user.zMove(target = target, z_move_flags = ZMOVE_CHECK_PULLEDBY|ZMOVE_ALLOW_BUCKLED|ZMOVE_INCLUDE_PULLED)
	ladder.use(user) //reopening ladder radial menu ahead

/obj/structure/ladder/proc/use(mob/user, is_ghost = FALSE)
	if(!is_ghost && !in_range(src, user))
		return

	var/list/tool_list = list()
	if (up)
		tool_list["Up"] = image(icon = 'icons/misc/Testing/turf_analysis.dmi', icon_state = "red_arrow", dir = NORTH)
	if (down)
		tool_list["Down"] = image(icon = 'icons/misc/Testing/turf_analysis.dmi', icon_state = "red_arrow", dir = SOUTH)
	if (!length(tool_list))
		to_chat(user, span_warning("[src] doesn't seem to lead anywhere!"))
		return
	var/result = show_radial_menu(user, src, tool_list, custom_check = CALLBACK(src, PROC_REF(check_menu), user, is_ghost), require_near = !is_ghost)
	if (!is_ghost && !in_range(src, user))
		return  // nice try
	switch(result)
		if("Up")
			travel(TRUE, user, is_ghost, up)
		if("Down")
			travel(FALSE, user, is_ghost, down)
		if("Cancel")
			return

	if(!is_ghost)
		add_fingerprint(user)

/obj/structure/ladder/proc/check_menu(mob/user, is_ghost)
	if(is_ghost)
		return TRUE
	if(user.incapacitated() || (!user.Adjacent(src) && !is_ghost))
		return FALSE
	return TRUE


/obj/structure/ladder/attackby(obj/item/I, mob/user, params)
	use(user)
	return ATTACK_CHAIN_BLOCKED_ALL


/obj/structure/ladder/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	use(user)

/obj/structure/ladder/attack_animal(mob/living/simple_animal/user)
	use(user)
	return TRUE

/obj/structure/ladder/attack_alien(mob/living/carbon/alien/humanoid/user)
	use(user)
	return TRUE

/obj/structure/ladder/attack_larva(mob/user)
	use(user)
	return TRUE

/obj/structure/ladder/attack_slime(mob/living/simple_animal/slime/user)
	use(user)
	return TRUE

/obj/structure/ladder/attack_robot(mob/living/silicon/robot/user)
	if(user.Adjacent(src))
		use(user)
	return TRUE

//ATTACK GHOST IGNORING PARENT RETURN VALUE
/obj/structure/ladder/attack_ghost(mob/dead/observer/user)
	use(user, TRUE)

/obj/structure/ladder/proc/show_fluff_message(going_up, mob/user)
	if(going_up)
		user.visible_message("[user] climbs up [src].","<span class='notice'>You climb up [src].</span>")
	else
		user.visible_message("[user] climbs down [src].","<span class='notice'>You climb down [src].</span>")


// Indestructible away mission ladders which link based on a mapped ID and height value rather than X/Y/Z.
/obj/structure/ladder/unbreakable
	name = "sturdy ladder"
	desc = "An extremely sturdy metal ladder."
	resistance_flags = INDESTRUCTIBLE
	var/id
	var/height = 0  // higher numbers are considered physically higher

/obj/structure/ladder/unbreakable/Initialize(mapload)
	GLOB.ladders += src
	return ..()

/obj/structure/ladder/unbreakable/Destroy()
	. = ..()
	if(. != QDEL_HINT_LETMELIVE)
		GLOB.ladders -= src

/obj/structure/ladder/unbreakable/LateInitialize()
	// Override the parent to find ladders based on being height-linked
	if(!id || (up && down))
		update_icon(UPDATE_ICON_STATE)
		return

	for(var/obj/structure/ladder/unbreakable/unbreakable_ladder in GLOB.ladders)
		if(unbreakable_ladder.id != id)
			continue  // not one of our pals
		if(!down && unbreakable_ladder.height == height - 1)
			down = unbreakable_ladder
			unbreakable_ladder.up = src
			unbreakable_ladder.update_icon(UPDATE_ICON_STATE)
			if(up)
				break  // break if both our connections are filled
		else if(!up && unbreakable_ladder.height == height + 1)
			up = unbreakable_ladder
			unbreakable_ladder.down = src
			unbreakable_ladder.update_icon(UPDATE_ICON_STATE)
			if (down)
				break  // break if both our connections are filled

	update_icon(UPDATE_ICON_STATE)

/obj/structure/ladder/unbreakable/dive_point/buoy
	name = "diving point buoy"
	desc = "A buoy marking the location of an underwater dive area."
	icon = 'icons/misc/beach.dmi'
	icon_state = "buoy"
	id = "dive"
	height = 2
	layer = MOB_LAYER + 0.2		//0.1 higher than the water overlay, this also means people can "swim" behind/under it


/obj/structure/ladder/unbreakable/dive_point/buoy/show_fluff_message(going_up, mob/user)
	if(going_up)
		user.visible_message("[user] swims up [src].","<span class='notice'>You swim up [src].</span>")
	else
		user.visible_message("[user] swims down [src].","<span class='notice'>You swim down [src].</span>")

/obj/structure/ladder/unbreakable/dive_point/anchor
	name = "diving point anchor"
	desc = "An anchor tethered to the buoy at the surface, to keep the dive area marked."
	icon = 'icons/misc/beach.dmi'
	icon_state = "anchor"
	id = "dive"
	height = 1
	light_range = 5

/obj/structure/ladder/dive_point/Initialize(mapload)
	. = ..()
	set_light(light_range, light_power)		//magical glowing anchor

/obj/structure/ladder/unbreakable/dive_point/update_icon_state()
	return
