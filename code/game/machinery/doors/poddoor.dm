/obj/machinery/door/poddoor
	name = "blast door"
	desc = "A heavy duty blast door that opens mechanically."
	icon = 'icons/obj/doors/blastdoor.dmi'
	icon_state = "closed"
	layer = BLASTDOOR_LAYER
	closingLayer = CLOSED_BLASTDOOR_LAYER
	explosion_block = 3
	heat_proof = TRUE
	safe = FALSE
	max_integrity = 600
	armor = list("melee" = 50, "bullet" = 100, "laser" = 100, "energy" = 100, "bomb" = 50, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 70)
	resistance_flags = FIRE_PROOF
	damage_deflection = 70
	var/id_tag
	var/protected = 1

/obj/machinery/door/poddoor/preopen
	icon_state = "open"
	density = FALSE
	opacity = FALSE

/obj/machinery/door/poddoor/impassable
	name = "reinforced blast door"
	desc = "A heavy duty blast door that opens mechanically. Looks even tougher than usual."
	resistance_flags = INDESTRUCTIBLE|LAVA_PROOF|FIRE_PROOF|UNACIDABLE|ACID_PROOF
	hackable = FALSE


/obj/machinery/door/poddoor/impassable/unhittable
	obj_flags = IGNORE_HITS


/obj/machinery/door/poddoor/Bumped(atom/movable/moving_atom, skip_effects = TRUE)
	. = ..()

/obj/machinery/door/poddoor/impassable/preopen
	icon_state = "open"
	density = FALSE
	opacity = FALSE

//"BLAST" doors are obviously stronger than regular doors when it comes to BLASTS.
/obj/machinery/door/poddoor/ex_act(severity)
	if(severity == 3)
		return
	..()

/obj/machinery/door/poddoor/do_animate(animation)
	switch(animation)
		if("opening")
			flick("opening", src)
			playsound(src, 'sound/machines/blastdoor.ogg', 30, 1)
		if("closing")
			flick("closing", src)
			playsound(src, 'sound/machines/blastdoor.ogg', 30, 1)

/obj/machinery/door/poddoor/update_icon_state()
	icon_state = density ? "closed" : "open"
	SSdemo.mark_dirty(src)

/obj/machinery/door/poddoor/try_to_activate_door(mob/user)
 	return

/obj/machinery/door/poddoor/try_to_crowbar(mob/user, obj/item/I)
	if(!density)
		return
	if(!hasPower())
		to_chat(user, span_notice("You start forcing [src] open..."))
		if(do_after(user, 5 SECONDS * I.toolspeed, src, category = DA_CAT_TOOL))
			if(!hasPower())
				open()
			else
				to_chat(user, span_warning("[src] resists your efforts to force it!"))
	else
		to_chat(user, span_warning("[src] resists your efforts to force it!"))

 // Whoever wrote the old code for multi-tile spesspod doors needs to burn in hell. - Unknown
 // Wise words. - Bxil
/obj/machinery/door/poddoor/multi_tile
	name = "large pod door"
	layer = CLOSED_DOOR_LAYER
	closingLayer = CLOSED_DOOR_LAYER


/obj/machinery/door/poddoor/multi_tile/Initialize(mapload)
	. = ..()
	apply_opacity_to_my_turfs(opacity)


/obj/machinery/door/poddoor/multi_tile/open()
	. = ..()
	if(.)
		apply_opacity_to_my_turfs(opacity)


/obj/machinery/door/poddoor/multi_tile/close()
	. = ..()
	if(.)
		apply_opacity_to_my_turfs(opacity)


/obj/machinery/door/poddoor/multi_tile/Destroy()
	apply_opacity_to_my_turfs(FALSE)
	return ..()


//Multi-tile poddoors don't turn invisible automatically, so we change the opacity of the turfs below instead one by one.
/obj/machinery/door/poddoor/multi_tile/proc/apply_opacity_to_my_turfs(new_opacity)
	for(var/turf/turf as anything in locs)
		turf.set_opacity(new_opacity)
	update_freelook_sight()


/obj/machinery/door/poddoor/multi_tile/four_tile_ver
	icon = 'icons/obj/doors/1x4blast_vert.dmi'
	width = 4
	dir = NORTH

/obj/machinery/door/poddoor/multi_tile/three_tile_ver
	icon = 'icons/obj/doors/1x3blast_vert.dmi'
	width = 3
	dir = NORTH

/obj/machinery/door/poddoor/multi_tile/two_tile_ver
	icon = 'icons/obj/doors/1x2blast_vert.dmi'
	width = 2
	dir = NORTH

/obj/machinery/door/poddoor/multi_tile/four_tile_hor
	icon = 'icons/obj/doors/1x4blast_hor.dmi'
	width = 4
	dir = EAST

/obj/machinery/door/poddoor/multi_tile/three_tile_hor
	icon = 'icons/obj/doors/1x3blast_hor.dmi'
	width = 3
	dir = EAST

/obj/machinery/door/poddoor/multi_tile/two_tile_hor
	icon = 'icons/obj/doors/1x2blast_hor.dmi'
	width = 2
	dir = EAST
