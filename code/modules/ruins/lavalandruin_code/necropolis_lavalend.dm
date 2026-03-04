/area/mine/necropolis
	name = "Necropolis"
	icon_state = "cave"
	tele_proof = TRUE
	holomap_should_draw = FALSE

/obj/effect/landmark/map_loader/lavaland_room
	icon = 'icons/misc/Testing/turf_analysis.dmi'
	icon_state = "arrow"

	var/static/list/south_necropolisroom_templates
	var/static/list/north_necropolisroom_templates
	var/static/list/west_necropolisroom_templates
	var/static/list/east_necropolisroom_templates
	var/static/templates_loaded = FALSE
	var/static/obj/effect/landmark/map_loader/lavaland_room/loader_landmark

/obj/effect/landmark/map_loader/lavaland_room/Initialize(mapload)
	. = ..()
	if(!loader_landmark)
		loader_landmark = src
	INVOKE_ASYNC(src, PROC_REF(load_room_async))

/obj/effect/landmark/map_loader/lavaland_room/proc/load_room_async()
	if(QDELETED(src))
		return

	if(!templates_loaded)
		if(src == loader_landmark)
			load_templates()
		else
			UNTIL(templates_loaded)

	// Selecting a template in the direction of the landmark
	var/list/room_list = get_room_list_by_dir(dir)
	var/datum/map_template/map_template = safepick(room_list)
	if(map_template)
		// Removing the selected template from the list so as not to repeat
		room_list -= map_template
		load(map_template)

/obj/effect/landmark/map_loader/lavaland_room/proc/load_templates()
	if(templates_loaded)
		return

	// Initializing the lists
	south_necropolisroom_templates = list()
	north_necropolisroom_templates = list()
	west_necropolisroom_templates = list()
	east_necropolisroom_templates = list()

	var/path = "_maps/map_files/templates/lavaland/"
	for(var/map in flist(path))
		if(cmptext(copytext(map, length(map) - 3), ".dmm"))
			var/datum/map_template/map_template = new(path = "[path][map]", rename = "[map]")
			switch(copytext(map, 1, 3))
				if("n_")
					north_necropolisroom_templates += map_template
				if("s_")
					south_necropolisroom_templates += map_template
				if("e_")
					east_necropolisroom_templates += map_template
				if("w_")
					west_necropolisroom_templates += map_template
				else
					// Files without a prefix are considered omnidirectional - we distribute them randomly
					if(prob(50))
						north_necropolisroom_templates += map_template
					else
						south_necropolisroom_templates += map_template

	templates_loaded = TRUE

/obj/effect/landmark/map_loader/lavaland_room/proc/get_room_list_by_dir(dir)
	switch(dir)
		if(NORTH)
			return north_necropolisroom_templates
		if(SOUTH)
			return south_necropolisroom_templates
		if(WEST)
			return west_necropolisroom_templates
		else
			return east_necropolisroom_templates

//----------------------------------------------------------------------------------------------------------------------
//-------------------------------------------door-------------------------------------------------------------
//----------------------------------------------------------------------------------------------------------------------

/obj/machinery/door/poddoor/impassable/necropolisdoor
	name = "necropolis door"
	desc = "Древние двери которые откроются только избранным."
	icon = 'icons/obj/lavaland/necrdoor.dmi'
	icon_state = "necr"

/obj/machinery/door/poddoor/impassable/necropolisdoor/preopen
	icon_state = "necropen"
	density = FALSE
	opacity = FALSE

/obj/machinery/door/poddoor/impassable/necropolisdoor/do_animate(animation)
	switch(animation)
		if("opening")
			flick("necropening", src)
			playsound(src, 'sound/effects/stonedoor_openclose.ogg', 30, TRUE)
		if("closing")
			flick("necrclosing", src)
			playsound(src, 'sound/effects/stonedoor_openclose.ogg', 30, TRUE)

/obj/machinery/door/poddoor/impassable/necropolisdoor/update_icon_state()
	if(density)
		icon_state = "necr"
	else
		icon_state = "necropen"
	SSdemo.mark_dirty(src)

/obj/machinery/door/poddoor/impassable/necropolisdoor/try_to_activate_door(mob/user)
	return

/obj/machinery/door/poddoor/impassable/necropolisdoor/try_to_crowbar(mob/user, obj/item/I)
		to_chat(user, span_warning("[src] resists your efforts to force it!"))

/mob/living/simple_animal/hostile/megafauna/legion/proc/UnlockBlastDoors(target_id_tag)
	for(var/obj/machinery/door/poddoor/impassable/necropolisdoor/P in GLOB.airlocks)
		if(P.density && P.id_tag == target_id_tag && P.z == z && !P.operating)
			P.open()

//----------------------------------------------------------------------------------------------------------------------
//-------------------------------------------multi tile door-------------------------------------------------------------
//----------------------------------------------------------------------------------------------------------------------

/obj/machinery/door/poddoor/impassable/necropolisdoor/multi_tile/Initialize(mapload)
	. = ..()
	apply_opacity_to_my_turfs(opacity)

/obj/machinery/door/poddoor/impassable/necropolisdoor/multi_tile/open()
	. = ..()
	if(.)
		apply_opacity_to_my_turfs(opacity)

/obj/machinery/door/poddoor/impassable/necropolisdoor/multi_tile/close()
	. = ..()
	if(.)
		apply_opacity_to_my_turfs(opacity)

/obj/machinery/door/poddoor/impassable/necropolisdoor/multi_tile/Destroy()
	apply_opacity_to_my_turfs(FALSE)
	return ..()

/obj/machinery/door/poddoor/impassable/necropolisdoor/multi_tile/proc/apply_opacity_to_my_turfs(new_opacity)
	for(var/turf/turf as anything in locs)
		turf.set_opacity(new_opacity)
	update_freelook_sight()

/obj/machinery/door/poddoor/impassable/necropolisdoor/multi_tile/four_tile_hor
	name = "Заваленный проход"
	desc = "По всей видимости этот проход ведет в основную часть этого места, но камни из неизвестного материала преграждают путь, интересно есть ли какой-то способ их убрать?.."
	icon = 'icons/obj/lavaland/gate_to_the necropolis.dmi'
	icon_state = "blocked_passage"
	width = 3
	dir = EAST
	layer = TABLE_LAYER

/obj/machinery/door/poddoor/impassable/necropolisdoor/multi_tile/four_tile_hor/do_animate(animation)
	switch(animation)
		if("opening")
			flick("blocked_passage", src)
			playsound(src, 'sound/effects/stonedoor_openclose.ogg', 30, TRUE)
		if("closing")
			flick("blocked_passage", src)
			playsound(src, 'sound/effects/stonedoor_openclose.ogg', 30, TRUE)

/obj/machinery/door/poddoor/impassable/necropolisdoor/multi_tile/four_tile_hor/update_icon_state()
	if(density)
		icon_state = "blocked_passage"
	else
		icon_state = "blocked_passage"
