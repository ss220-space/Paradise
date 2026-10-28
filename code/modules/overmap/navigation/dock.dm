/obj/docking_port/stationary/overmap
	name = "overmap pad"
	width = 1
	height = 1

/obj/docking_port/stationary/overmap/get_ru_names()
	return alist(
		NOMINATIVE = "площадка стыковки",
		GENITIVE = "площадки стыковки",
		DATIVE = "площадке стыковки",
		ACCUSATIVE = "площадку стыковки",
		INSTRUMENTAL = "площадкой стыковки",
		PREPOSITIONAL = "площадке стыковки",
	)

/obj/docking_port/stationary/overmap/New(loc, pad_id)
	if(pad_id)
		id = pad_id
	..()

/obj/docking_port/stationary/overmap/Initialize(mapload, pad_id)
	if(pad_id)
		id = pad_id
	if(!id)
		id = "overmap_pad_[UID()]"
	. = ..()
	register()

/obj/docking_port/stationary/overmap/apply_overmap_dock_role()
	overmap_dock_mode = OVERMAP_DOCK_MANUAL
	if(dock_airlock?.dock_name)
		overmap_dock_label = dock_airlock.dock_name
	else if(!overmap_dock_label)
		overmap_dock_label = id

/obj/docking_port/stationary/overmap/Destroy(force)
	if(dock_airlock?.overmap_pad == src)
		dock_airlock.overmap_pad = null
		dock_airlock.owns_overmap_pad = FALSE
	dock_airlock = null
	return ..()

/obj/machinery/door/airlock/external/docking
	name = "docking airlock"
	assemblytype = /obj/structure/door_assembly/door_assembly_docking
	autoclose = FALSE

	var/dock_name

	var/overmap_collar_id
	var/obj/docking_port/stationary/overmap_pad
	var/owns_overmap_pad = FALSE
	var/overmap_is_support = FALSE

/obj/machinery/door/airlock/external/docking/get_ru_names()
	return alist(
		NOMINATIVE = "стыковочный шлюз",
		GENITIVE = "стыковочного шлюза",
		DATIVE = "стыковочному шлюзу",
		ACCUSATIVE = "стыковочный шлюз",
		INSTRUMENTAL = "стыковочным шлюзом",
		PREPOSITIONAL = "стыковочном шлюзе",
	)

/obj/machinery/door/airlock/external/docking/Initialize(mapload)
	. = ..()
	if(mapload)
		initialize_overmap_pad()
		sync_overmap_bolts()

/obj/machinery/door/airlock/external/docking/Destroy()
	if(owns_overmap_pad && overmap_pad)
		var/obj/docking_port/stationary/pad = overmap_pad
		overmap_pad = null
		owns_overmap_pad = FALSE
		if(!QDELETED(pad))
			if(pad.dock_airlock == src)
				pad.dock_airlock = null
			qdel(pad, TRUE)
	else if(overmap_pad?.dock_airlock == src)
		overmap_pad.dock_airlock = null
	overmap_pad = null
	return ..()

/obj/machinery/door/airlock/external/docking/multitool_act(mob/user, obj/item/I)
	if(!headbutt_shock_check(user))
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(panel_open)
		configure_overmap_params(user)
		return
	return ..()

/obj/machinery/door/airlock/external/docking/proc/configure_overmap_dock(mob/user)
	setup_overmap_pad(user)
	sync_overmap_bolts()

/obj/machinery/door/airlock/external/docking/proc/configure_overmap_params(mob/user)
	if(overmap_is_support)
		var/new_id = tgui_input_text(user, "Идентификатор стыковочного шлюза, с которым связать этот шлюз", "Саппорт-шлюз", id_tag, max_length = MAX_NAME_LEN)
		if(QDELETED(src) || !new_id)
			return
		id_tag = new_id
		to_chat(user, span_notice("Саппорт-шлюз привязан к [id_tag]."))
		sync_overmap_bolts()
		return
	var/choice = tgui_input_list(user, "Параметр стыковочного шлюза", src, list("Имя", "Направление"))
	if(QDELETED(src) || !choice)
		return
	if(choice == "Имя")
		var/new_name = tgui_input_text(user, "Название дока", src, dock_name, max_length = MAX_NAME_LEN)
		if(QDELETED(src) || !new_name)
			return
		dock_name = new_name
		sync_dock_label()
		return
	var/dir_name = tgui_input_list(user, "Направление шлюза в сторону стыковки(от корпуса)", src, list("Север", "Восток", "Юг", "Запад"))
	if(QDELETED(src) || !dir_name)
		return
	var/new_dir = NORTH
	switch(dir_name)
		if("Восток")
			new_dir = EAST
		if("Юг")
			new_dir = SOUTH
		if("Запад")
			new_dir = WEST
	setDir(new_dir)
	place_overmap_pad()
	to_chat(user, span_notice("Направление стыковки: [dir2text(dir)]."))

/obj/machinery/door/airlock/external/docking/proc/setup_overmap_pad(mob/user)
	if(user && overmap_is_support)
		if(!id_tag)
			configure_overmap_params(user)
		return
	if(user)
		if(is_area_shuttle(get_area(src)))
			if(!dock_name)
				var/chosen = tgui_input_text(user, "Название дока", "Стыковочный шлюз", dock_name, max_length = MAX_NAME_LEN)
				if(!QDELETED(src) && chosen)
					dock_name = chosen
		else if(!overmap_pad && !dock_name)
			var/chosen = tgui_input_text(user, "Название площадки для штурвала", "Стыковочный шлюз", "", max_length = MAX_NAME_LEN)
			if(!QDELETED(src) && chosen)
				dock_name = chosen
	var/obj/docking_port/stationary/pad_result = initialize_overmap_pad()
	if(user && pad_result && overmap_pad == pad_result)
		to_chat(user, span_notice("Площадка «[pad_result.overmap_dock_label || pad_result.id]» зарегистрирована ([pad_result.id])."))
	return pad_result

/obj/machinery/door/airlock/external/docking/proc/initialize_overmap_pad()
	if(overmap_is_support)
		return
	if(is_area_shuttle(get_area(src)))
		if(!id_tag)
			id_tag = "s_docking_airlock"
		return
	if(overmap_pad && !QDELETED(overmap_pad))
		id_tag = overmap_pad.id
		sync_dock_label()
		return overmap_pad
	var/desired_id = id_tag
	var/obj/docking_port/stationary/existing = desired_id ? SSshuttle.getDock(desired_id, warn = FALSE) : locate_overmap_pad()
	if(existing && !istype(existing, /obj/docking_port/stationary/transit))
		link_overmap_pad(existing, FALSE)
		return existing
	var/turf/pad_turf = get_overmap_pad_turf()
	if(!pad_turf)
		return
	var/obj/docking_port/stationary/overmap/pad = new(pad_turf, desired_id)
	link_overmap_pad(pad, TRUE)
	return pad

/obj/machinery/door/airlock/external/docking/proc/get_overmap_pad_turf()
	return get_step(src, dir) || get_turf(src)

/obj/machinery/door/airlock/external/docking/proc/locate_overmap_pad()
	var/turf/ahead = get_overmap_pad_turf()
	if(ahead)
		var/obj/docking_port/stationary/ahead_pad = locate() in ahead
		if(ahead_pad)
			return ahead_pad
	var/turf/here = get_turf(src)
	if(here)
		return locate(/obj/docking_port/stationary) in here
	return null

/obj/machinery/door/airlock/external/docking/proc/place_overmap_pad()
	if(!overmap_pad || QDELETED(overmap_pad))
		return
	if(!owns_overmap_pad && get_turf(overmap_pad) != get_turf(src))
		return
	overmap_pad.setDir(dir)
	var/turf/pad_turf = get_overmap_pad_turf()
	if(pad_turf && overmap_pad.loc != pad_turf)
		overmap_pad.forceMove(pad_turf)

/obj/machinery/door/airlock/external/docking/proc/link_overmap_pad(obj/docking_port/stationary/pad, created)
	overmap_pad = pad
	owns_overmap_pad = created
	pad.dock_airlock = src
	id_tag = pad.id
	place_overmap_pad()
	sync_dock_label()

/obj/machinery/door/airlock/external/docking/proc/sync_dock_label()
	if(!overmap_pad)
		return
	if(dock_name)
		overmap_pad.overmap_dock_label = dock_name
	else if(!overmap_pad.overmap_dock_label)
		overmap_pad.apply_overmap_dock_role()

/obj/machinery/door/airlock/external/docking/proc/get_helm_label()
	return dock_name || overmap_pad?.overmap_dock_label || name

/obj/machinery/door/airlock/external/docking/proc/sync_overmap_bolts()
	var/obj/docking_port/stationary/pad = overmap_pad
	if(!pad && id_tag)
		pad = SSshuttle.getDock(id_tag, warn = FALSE)
	if(pad?.get_docked())
		if(locked)
			unlock(TRUE)
		return
	close()
	lock()

/obj/machinery/door/airlock/external/docking/onShuttleMove()
	if(owns_overmap_pad && !overmap_pad?.get_docked())
		qdel(overmap_pad, TRUE)
	. = ..()
	if(.)
		INVOKE_ASYNC(src, PROC_REF(lock))

/obj/machinery/door/airlock/external/docking/glass
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/airlock/external/docking/support
	name = "docking support airlock"
	overmap_is_support = TRUE
	assemblytype = /obj/structure/door_assembly/door_assembly_docking_support

/obj/machinery/door/airlock/external/docking/support/get_ru_names()
	return alist(
		NOMINATIVE = "саппорт-шлюз стыковки",
		GENITIVE = "саппорт-шлюза стыковки",
		DATIVE = "саппорт-шлюзу стыковки",
		ACCUSATIVE = "саппорт-шлюз стыковки",
		INSTRUMENTAL = "саппорт-шлюзом стыковки",
		PREPOSITIONAL = "саппорт-шлюзе стыковки",
	)

/obj/machinery/door/airlock/external/docking/support/glass
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/airlock/external/docking/shuttle
	name = "shuttle hatch"
	icon = 'icons/obj/doors/airlocks/shuttle/shuttle.dmi'
	overlays_file = 'icons/obj/doors/airlocks/shuttle/overlays.dmi'
	note_overlay_file = 'icons/obj/doors/airlocks/shuttle/overlays.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_docking_shuttle
	paintable = FALSE

/obj/machinery/door/airlock/external/docking/shuttle/get_ru_names()
	return alist(
		NOMINATIVE = "стыковочный шлюз",
		GENITIVE = "стыковочного шлюза",
		DATIVE = "стыковочному шлюзу",
		ACCUSATIVE = "стыковочный шлюз",
		INSTRUMENTAL = "стыковочным шлюзом",
		PREPOSITIONAL = "стыковочном шлюзе",
	)

/obj/machinery/door/airlock/external/docking/shuttle/glass
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/airlock/external/docking/shuttle/support
	overmap_is_support = TRUE
	assemblytype = /obj/structure/door_assembly/door_assembly_docking_shuttle_support

/obj/machinery/door/airlock/external/docking/shuttle/support/get_ru_names()
	return alist(
		NOMINATIVE = "саппорт-шлюз стыковки",
		GENITIVE = "саппорт-шлюза стыковки",
		DATIVE = "саппорт-шлюзу стыковки",
		ACCUSATIVE = "саппорт-шлюз стыковки",
		INSTRUMENTAL = "саппорт-шлюзом стыковки",
		PREPOSITIONAL = "саппорт-шлюзе стыковки",
	)

/obj/machinery/door/airlock/external/docking/shuttle/support/glass
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/airlock/external/docking/hatch
	name = "airtight hatch"
	icon = 'icons/obj/doors/airlocks/hatch/centcom.dmi'
	overlays_file = 'icons/obj/doors/airlocks/hatch/overlays.dmi'
	note_overlay_file = 'icons/obj/doors/airlocks/hatch/overlays.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_docking_hatch
	paintable = FALSE

/obj/machinery/door/airlock/external/docking/hatch/get_ru_names()
	return alist(
		NOMINATIVE = "стыковочный люк",
		GENITIVE = "стыковочного люка",
		DATIVE = "стыковочному люку",
		ACCUSATIVE = "стыковочный люк",
		INSTRUMENTAL = "стыковочным люком",
		PREPOSITIONAL = "стыковочном люке",
	)

/obj/machinery/door/airlock/external/docking/hatch/support
	overmap_is_support = TRUE
	assemblytype = /obj/structure/door_assembly/door_assembly_docking_hatch_support

/obj/docking_port/stationary/overmap/landing
	var/temporary_stop = FALSE
	var/list/landing_bounds
	var/list/beacon_corners
	name = "landing pad"
	overmap_dock_label = "Посадочный маяк"

/obj/docking_port/stationary/overmap/landing/apply_overmap_dock_role()
	overmap_dock_mode = OVERMAP_DOCK_MANUAL
	if(!overmap_dock_label)
		overmap_dock_label = "Посадочный маяк"

/obj/docking_port/stationary/overmap/landing/get_docked()
	return locate(/obj/docking_port/mobile) in loc

GLOBAL_LIST_EMPTY(landing_beacons)

/obj/machinery/landing_beacon
	name = "landing beacon"
	desc = "Четыре маяка с одинаковым названием в углах прямоугольника задают посадочную область."
	icon = 'icons/obj/radio.dmi'
	icon_state = "beacon"
	anchored = TRUE
	layer = OBJ_LAYER
	use_power = NO_POWER_USE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	light_range = 2
	light_power = 0.8
	light_color = "#7ec8e3"

	var/dock_name = "Посадочный маяк"
	var/obj/docking_port/stationary/overmap/landing/pad

/obj/machinery/landing_beacon/get_ru_names()
	return alist(
		NOMINATIVE = "посадочный маяк",
		GENITIVE = "посадочного маяка",
		DATIVE = "посадочному маяку",
		ACCUSATIVE = "посадочный маяк",
		INSTRUMENTAL = "посадочным маяком",
		PREPOSITIONAL = "посадочном маяке",
	)

/obj/machinery/landing_beacon/Initialize(mapload)
	. = ..()
	GLOB.landing_beacons += src
	drop_to_turf()
	setup_pad()

/obj/machinery/landing_beacon/Destroy()
	GLOB.landing_beacons -= src
	overmap_rebuild_landing_zones()
	pad = null
	return ..()

/obj/machinery/landing_beacon/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()
	if(isturf(loc))
		setup_pad()

/obj/machinery/landing_beacon/proc/drop_to_turf()
	var/turf/spot = get_turf(src)
	if(spot && loc != spot)
		forceMove(spot)

/obj/machinery/landing_beacon/examine(mob/user)
	. = ..()
	if(pad && !QDELETED(pad))
		. += span_notice("Площадка стыковки: [pad.overmap_dock_label || pad.id].")
	else
		. += span_warning("Площадка стыковки не зарегистрирована.")

/obj/machinery/landing_beacon/proc/setup_pad()
	overmap_rebuild_landing_zones()

/obj/machinery/landing_beacon/proc/sync_pad()
	overmap_rebuild_landing_zones()

/proc/overmap_rebuild_landing_zones()
	var/list/available = list()
	var/list/pads = list()
	for(var/obj/machinery/landing_beacon/beacon as anything in GLOB.landing_beacons)
		if(!QDELETED(beacon) && isturf(beacon.loc))
			available += beacon
		if(!QDELETED(beacon.pad))
			pads |= beacon.pad
	for(var/obj/docking_port/stationary/overmap/landing/pad as anything in pads)
		var/valid = length(pad.beacon_corners) == 4
		for(var/obj/machinery/landing_beacon/corner as anything in pad.beacon_corners)
			if(QDELETED(corner) || !(corner in available) || corner.dock_name != pad.overmap_dock_label || corner.z != pad.z)
				valid = FALSE
		if(valid)
			var/list/bounds = pad.landing_bounds
			var/list/positions = list()
			for(var/obj/machinery/landing_beacon/corner as anything in pad.beacon_corners)
				if((corner.x != bounds[1] - 1 && corner.x != bounds[3] + 1) || (corner.y != bounds[2] - 1 && corner.y != bounds[4] + 1))
					valid = FALSE
				positions["[corner.x],[corner.y]"] = TRUE
			if(length(positions) != 4)
				valid = FALSE
		if(valid)
			available -= pad.beacon_corners
			continue
		for(var/obj/machinery/landing_beacon/corner as anything in pad.beacon_corners)
			if(!QDELETED(corner))
				corner.pad = null
		qdel(pad, TRUE)
	for(var/obj/machinery/landing_beacon/first as anything in available)
		if(first.pad)
			continue
		var/list/best
		var/best_area = INFINITY
		for(var/obj/machinery/landing_beacon/opposite as anything in available)
			if(opposite.pad || opposite.z != first.z || opposite.dock_name != first.dock_name || opposite.x <= first.x + 2 || opposite.y <= first.y + 2)
				continue
			var/obj/machinery/landing_beacon/second
			var/obj/machinery/landing_beacon/third
			for(var/obj/machinery/landing_beacon/corner as anything in available)
				if(corner.pad || corner.z != first.z || corner.dock_name != first.dock_name)
					continue
				if(corner.x == opposite.x && corner.y == first.y)
					second = corner
				if(corner.x == first.x && corner.y == opposite.y)
					third = corner
			var/size = (opposite.x - first.x) * (opposite.y - first.y)
			if(second && third && size < best_area)
				best = list(first, second, third, opposite)
				best_area = size
		if(!best)
			continue
		var/obj/machinery/landing_beacon/opposite = best[4]
		var/turf/center = locate(round((first.x + opposite.x) / 2), round((first.y + opposite.y) / 2), first.z)
		var/obj/docking_port/stationary/overmap/landing/pad = new(center)
		pad.landing_bounds = list(first.x + 1, first.y + 1, opposite.x - 1, opposite.y - 1)
		pad.beacon_corners = best
		pad.overmap_dock_label = first.dock_name
		pad.turf_type = center.type
		var/area/place = get_area(center)
		pad.area_type = place.type
		for(var/obj/machinery/landing_beacon/corner as anything in best)
			corner.pad = pad
		first.bind_pad_host()

/obj/machinery/landing_beacon/proc/bind_pad_host()
	if(!pad || QDELETED(pad) || !SSovermap)
		return
	for(var/datum/component/overmap_dock_host/host_comp as anything in SSovermap.dock_hosts)
		if(QDELETED(host_comp) || !host_comp.matches_pad(pad))
			continue
		var/obj/overmap/entity/token = host_comp.parent
		if(!istype(token))
			continue
		pad.overmap_host_uid = token.UID()
		return

/obj/machinery/landing_beacon/shuttle_crush_react(turf/stationary_turf, mobile_dir, skip_ungibable_search = FALSE)
	return FALSE

/obj/machinery/landing_beacon/onShuttleMove()
	return FALSE

/obj/machinery/landing_beacon/multitool_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	var/new_name = tgui_input_text(user, "Название площадки", src, dock_name, max_length = MAX_NAME_LEN)
	if(QDELETED(src) || !new_name)
		return
	dock_name = new_name
	sync_pad()

/obj/item/overmap_landing_beacon
	name = "landing beacon"
	desc = "Установите четыре маяка в углах прямоугольной посадочной области."
	icon = 'icons/obj/radio.dmi'
	icon_state = "beacon"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/overmap_landing_beacon/get_ru_names()
	return alist(
		NOMINATIVE = "посадочный маяк",
		GENITIVE = "посадочного маяка",
		DATIVE = "посадочному маяку",
		ACCUSATIVE = "посадочный маяк",
		INSTRUMENTAL = "посадочным маяком",
		PREPOSITIONAL = "посадочном маяке",
	)

/obj/item/overmap_landing_beacon/attack_self(mob/user)
	deploy(get_turf(user), user)

/obj/item/overmap_landing_beacon/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	var/turf/spot = get_turf(interacting_with)
	if(!spot)
		return NONE
	deploy(spot, user)
	return ITEM_INTERACT_SUCCESS

/obj/item/overmap_landing_beacon/proc/deploy(turf/spot, mob/user)
	if(!spot)
		return
	if(user && !user.temporarily_remove_item_from_inventory(src))
		return
	new /obj/machinery/landing_beacon(spot)
	if(user)
		to_chat(user, span_notice("Вы устанавливаете посадочный маяк."))
	qdel(src)
