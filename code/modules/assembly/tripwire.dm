////////////////////////////////////////
// MARK:	Tripwire Bridge
////////////////////////////////////////

/obj/structure/tripwire_bridge
	name = "tripwire"
	desc = "Тонкий провод. Похоже, он соединен с чем-то опасным."
	icon = 'icons/obj/tripwire.dmi'
	icon_state = "tripwire_wire"
	anchored = TRUE
	layer = LOW_OBJ_LAYER
	var/obj/item/tripwire/master_base = null

/obj/structure/tripwire_bridge/get_ru_names()
	return list(
		NOMINATIVE = "провод растяжки",
		GENITIVE = "провода растяжки",
		DATIVE = "проводу растяжки",
		ACCUSATIVE = "провод растяжки",
		INSTRUMENTAL = "проводом растяжки",
		PREPOSITIONAL = "проводе растяжки",
	)

/obj/structure/tripwire_bridge/Initialize(mapload)
	. = ..()
	RegisterSignal(loc, COMSIG_ATOM_ENTERED, PROC_REF(on_entered))

/obj/structure/tripwire_bridge/proc/on_entered(datum/source, atom/movable/movable_atom)
	SIGNAL_HANDLER

	if(!master_base || QDELETED(master_base))
		qdel(src)
		return

	if(!master_base.is_active || !isliving(movable_atom))
		return

	var/mob/living/entered_living = movable_atom

	if(!entered_living)
		return

	if(entered_living.incorporeal_move || (entered_living.movement_type & MOVETYPES_NOT_TOUCHING_GROUND))
		return

	if(entered_living.m_intent == MOVE_INTENT_WALK || (entered_living.pulledby && entered_living.pulledby.m_intent == MOVE_INTENT_WALK))
		return

	playsound(src, 'sound/machines/click.ogg', 50, TRUE)
	INVOKE_ASYNC(master_base, TYPE_PROC_REF(/obj/item/tripwire, trigger_tripwire), entered_living, src)

/obj/structure/tripwire_bridge/wirecutter_act(mob/living/user, obj/item/I)
	if(!master_base || !master_base.is_active || QDELETED(master_base))
		return

	to_chat(user, span_notice("Вы начали осторожно перерезать [declent_ru(ACCUSATIVE)]..."))

	if(!I.use_tool(src, user, 2 SECONDS, volume = 50))
		return

	if(QDELETED(src) || !master_base || !master_base.is_active)
		return

	to_chat(user, span_notice("Вы успешно перерезали провод растяжки."))

	master_base.break_wire()
	return TRUE

/obj/structure/tripwire_bridge/Destroy()
	UnregisterSignal(loc, COMSIG_ATOM_ENTERED)

	if(master_base && master_base.is_active && !master_base.breaking)
		master_base.break_wire()

	master_base = null
	return ..()

////////////////////////////////////////
// MARK:	Tripwire base
////////////////////////////////////////

/obj/item/tripwire
	name = "tripwire base"
	desc = "Металлическое основание для растяжки. Закрепите на стене, добавьте детонатор и протяните кабель."
	icon = 'icons/obj/tripwire.dmi'
	icon_state = "tripwire_base"
	var/obj/item/tripwire/linked_to = null
	var/obj/item/attached_item = null
	var/is_active = FALSE
	var/anchored_to_wall = FALSE
	var/list/wire_segments
	var/wall_dir = 0
	var/breaking = FALSE

	var/creator_key = null
	var/payload_deployer_key = null

/obj/item/tripwire/get_ru_names()
	return list(
		NOMINATIVE = "растяжка",
		GENITIVE = "растяжки",
		DATIVE = "растяжке",
		ACCUSATIVE = "растяжку",
		INSTRUMENTAL = "растяжкой",
		PREPOSITIONAL = "растяжке",
	)

/obj/item/tripwire/Destroy()
	if(is_active)
		break_wire()

	if(linked_to && !QDELETED(linked_to))
		var/obj/item/tripwire/other = linked_to
		other.linked_to = null
		other.is_active = FALSE

		if(LAZYLEN(other.wire_segments))
			for(var/obj/structure/tripwire_bridge/segment in other.wire_segments)
				qdel(segment)

			LAZYCLEARLIST(other.wire_segments)

		other.update_appearance()

	linked_to = null
	attached_item = null

	return ..()

/obj/item/tripwire/attack_hand(mob/user)
	if(anchored_to_wall)
		to_chat(user, span_warning("[DECLENT_RU_CAP(src, ACCUSATIVE)] нужно открепить ломом!"))
		return

	unanchor_base()
	return ..()

////////////////////////////////////////
// MARK:	Tripwire setting up
////////////////////////////////////////

/obj/item/tripwire/afterattack(atom/target, mob/user, proximity)
	if(!proximity || anchored_to_wall || is_active)
		return

	if(!isturf(target) && !target.density)
		return

	var/turf/user_turf = get_turf(user)
	var/dir_to_wall = get_dir(user_turf, target)

	if(!(dir_to_wall in list(NORTH, SOUTH, EAST, WEST)))
		return

	if(!user.transfer_item_to_loc(src, user_turf))
		return

	src.anchored = TRUE
	src.anchored_to_wall = TRUE
	src.wall_dir = dir_to_wall
	src.setDir(src.wall_dir)

	apply_wall_offset()

	to_chat(user, span_notice("Вы надёжно закрепили [declent_ru(ACCUSATIVE)] на стене."))
	playsound(src, 'sound/machines/click.ogg', 50, TRUE)
	update_appearance()

/obj/item/tripwire/forceMove(atom/dest)
	pixel_x = 0
	pixel_y = 0
	anchored = FALSE
	anchored_to_wall = FALSE
	return ..()

/obj/item/tripwire/proc/apply_wall_offset()
	pixel_x = 0
	pixel_y = 0
	switch(wall_dir)
		if(NORTH)
			pixel_y = 14
		if(SOUTH)
			pixel_y = -12
		if(EAST)
			pixel_x = 15
			pixel_y = -7
		if(WEST)
			pixel_x = -14
			pixel_y = -7

/obj/item/tripwire/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(ATTACK_CHAIN_CANCEL_CHECK(.))
		return .

	if(istype(I, /obj/item/stack/cable_coil))
		if(setup_wire(I, user))
			return . | ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/grenade) || istype(I, /obj/item/flash) || istype(I, /obj/item/assembly) || istype(I, /obj/item/reagent_containers/food/drinks/drinkingglass) || istype(I, /obj/item/camera))
		if(install_payload(I, user))
			return . | ATTACK_CHAIN_BLOCKED_ALL

	return .

/obj/item/tripwire/proc/setup_wire(obj/item/stack/cable_coil/cable, mob/user)
	if(is_active)
		to_chat(user, span_warning("Провод уже натянут!"))
		return

	var/list/valid_targets = list()
	for(var/obj/item/tripwire/nearby_base in range(2, src))
		if(QDELETED(nearby_base) || nearby_base == src || nearby_base.is_active || !nearby_base.anchored_to_wall)
			continue

		var/is_valid_alignment = FALSE
		var/distance_to_base = get_dist(src, nearby_base)

		if(distance_to_base > 0)
			var/turf/check_step = get_turf(src)
			var/dir_to_target = get_dir(src, nearby_base)
			var/path_blocked = FALSE
			for(var/i in 1 to distance_to_base)
				check_step = get_step(check_step, dir_to_target)
				if(check_step.density && check_step != get_turf(nearby_base))
					path_blocked = TRUE
					break

			if(path_blocked)
				continue

		if(distance_to_base == 0)
			if(src.wall_dir == turn(nearby_base.wall_dir, 180))
				is_valid_alignment = TRUE

		else if(src.x == nearby_base.x || src.y == nearby_base.y)
			var/dir_to_target = get_dir(src, nearby_base)
			var/dir_to_source = get_dir(nearby_base, src)
			if(src.wall_dir == turn(dir_to_target, 180) && nearby_base.wall_dir == turn(dir_to_source, 180))
				is_valid_alignment = TRUE

		if(is_valid_alignment)
			valid_targets += nearby_base

	if(!valid_targets.len)
		to_chat(user, span_warning("Напротив нет подходящей основы или путь заблокирован."))
		return

	var/obj/item/tripwire/target_base = valid_targets[1]
	if(valid_targets.len > 1)
		for(var/obj/item/tripwire/potential_base in valid_targets)
			if(get_dist(src, potential_base) < get_dist(src, target_base))
				target_base = potential_base

	var/needed_cable = max(get_dist(src, target_base) + 1, 1)
	if(cable.amount < needed_cable)
		to_chat(user, span_warning("Вам нужен кабель длиной [needed_cable] для такой дистанции!"))
		return

	to_chat(user, span_notice("Вы начинаете протягивать кабель к [target_base.declent_ru(DATIVE)]..."))
	var/initial_target_loc = target_base.loc

	if(!cable.use_tool(src, user, 3 SECONDS, volume = 50))
		return

	var/new_target_loc = target_base.loc

	if(QDELETED(target_base) || initial_target_loc != new_target_loc || src.z != target_base.z || is_active || target_base.is_active || QDELETED(cable) || cable.amount < needed_cable)
		return

	if(connect_to(target_base, cable))
		src.creator_key = user.ckey
		target_base.creator_key = user.ckey
		to_chat(user, span_notice("Вы успешно натянули провод между растяжками."))
		cable.use(needed_cable)

/obj/item/tripwire/proc/connect_to(obj/item/tripwire/target, obj/item/stack/cable_coil/cable)
	linked_to = target
	is_active = TRUE

	target.linked_to = src
	target.is_active = TRUE

	draw_wire(target, cable.color)
	update_appearance()
	target.update_appearance()
	return TRUE

/obj/item/tripwire/proc/draw_wire(obj/item/tripwire/target_base, wire_color)
	var/turf/current_turf = get_turf(src)
	var/turf/end_turf = get_turf(target_base)

	if(current_turf == end_turf)
		var/target_dir = (src.wall_dir == NORTH || src.wall_dir == SOUTH) ? NORTH : EAST
		create_bridge(current_turf, wire_color, target_base, target_dir)
		return

	var/direction_to_target = get_dir(current_turf, end_turf)
	var/max_dist = get_dist(src, target_base)
	var/turf/iter_turf = current_turf

	for(var/i in 0 to max_dist)
		if(!iter_turf)
			break

		if(iter_turf.density && iter_turf != current_turf && iter_turf != end_turf)
			break

		create_bridge(iter_turf, wire_color, target_base, direction_to_target)

		if(iter_turf == end_turf)
			break

		iter_turf = get_step(iter_turf, direction_to_target)

	playsound(src, 'sound/effects/stamp2.ogg', 40, TRUE)

/obj/item/tripwire/proc/create_bridge(turf/tripwire_turf, wire_color, obj/item/tripwire/target_base, dir_to_set)
	var/obj/structure/tripwire_bridge/bridge = new(tripwire_turf)
	bridge.color = wire_color
	bridge.master_base = src
	bridge.setDir(dir_to_set)

	LAZYADD(wire_segments, bridge)
	LAZYADD(target_base.wire_segments, bridge)

/obj/item/tripwire/proc/install_payload(obj/item/installing_item, mob/user)
	if(attached_item || (linked_to && linked_to.attached_item))
		to_chat(user, span_warning("На этой растяжке уже что-то установлено!"))
		return

	if(!user.transfer_item_to_loc(installing_item, src))
		return

	attached_item = installing_item
	to_chat(user, span_notice("Вы закрепили [installing_item.declent_ru(ACCUSATIVE)] на [declent_ru(ACCUSATIVE)]."))
	payload_deployer_key = user.ckey
	update_appearance()

/obj/item/tripwire/update_overlays()
	. = ..()
	if(attached_item)
		var/mutable_appearance/MA = mutable_appearance(attached_item.icon, attached_item.icon_state)
		var/matrix/M = matrix()
		M.Scale(0.8, 0.8)
		M.Turn(180)
		M.Translate(0, 8)
		MA.transform = M
		. += MA

////////////////////////////////////////
// MARK:	Tripwire Dismantling
////////////////////////////////////////

/obj/item/tripwire/wirecutter_act(mob/living/user, obj/item/I)
	if(!is_active || QDELETED(src))
		return

	to_chat(user, span_notice("Вы начали осторожно перерезать провод [declent_ru(GENITIVE)]..."))

	if(!I.use_tool(src, user, 2 SECONDS, volume = 50))
		return

	if(!is_active)
		return

	to_chat(user, span_notice("Вы успешно перерезали провод [declent_ru(GENITIVE)]."))
	break_wire()

/obj/item/tripwire/screwdriver_act(mob/living/user, obj/item/I)
	if(!attached_item)
		return

	to_chat(user, span_notice("Вы начали извлекать [attached_item.declent_ru(ACCUSATIVE)] из [declent_ru(GENITIVE)]..."))
	if(!I.use_tool(src, user, 2 SECONDS, volume = 50))
		return

	if(!attached_item)
		return

	var/obj/item/extracted_item = attached_item
	to_chat(user, span_notice("Вы успешно извлекли [attached_item.declent_ru(ACCUSATIVE)] из [declent_ru(GENITIVE)]."))
	extracted_item.forceMove(drop_location())
	attached_item = null
	update_appearance()

/obj/item/tripwire/crowbar_act(mob/living/user, obj/item/I)
	if(!anchored)
		return

	if(is_active)
		to_chat(user, span_warning("Сначала нужно перерезать натянутый провод!"))
		return

	to_chat(user, span_notice("Вы начали откреплять [declent_ru(ACCUSATIVE)] от стены..."))
	if(!I.use_tool(src, user, 2 SECONDS, volume = 50))
		return

	to_chat(user, span_notice("Вы успешно открутили [declent_ru(ACCUSATIVE)]."))
	unanchor_base()
	return TRUE

/obj/item/tripwire/proc/unanchor_base()
	anchored = FALSE
	anchored_to_wall = FALSE
	pixel_x = 0
	pixel_y = 0
	update_appearance()

/obj/item/tripwire/proc/break_wire()
	if(!is_active || breaking)
		return

	breaking = TRUE
	is_active = FALSE

	if(LAZYLEN(wire_segments))
		var/list/segments = wire_segments.Copy()
		LAZYCLEARLIST(wire_segments)
		for(var/obj/structure/tripwire_bridge/segment in segments)
			if(!QDELETED(segment))
				qdel(segment)

	var/obj/item/tripwire/other = linked_to
	linked_to = null

	if(other && !QDELETED(other))
		other.break_wire()

	update_appearance()
	breaking = FALSE

////////////////////////////////////////
// MARK:	Trigger & payloads
////////////////////////////////////////

/obj/item/tripwire/proc/trigger_flash(mob/user, obj/item/flash/flasher)
	if(QDELETED(flasher) || !flasher.try_use_flash(user))
		return

	playsound(src.loc, 'sound/weapons/flash.ogg', 100, TRUE)
	flick("[flasher.icon_state]_flash", flasher)
	set_light(2, 1, COLOR_WHITE)
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, set_light_on), FALSE), 2 SECONDS)

	for(var/mob/living/living in viewers(3, get_turf(src)))
		if(living.flash_eyes(affect_silicon = TRUE))
			living.AdjustConfused(6 SECONDS)
			living.visible_message(span_disarm("<b>[html_encode(living.name)]</b> ахает и пытается прикрыть глаза!"))

/obj/item/tripwire/proc/trigger_camera(obj/item/camera/camera, turf/trigger_turf)
	if(QDELETED(camera) || !camera.on || !camera.pictures_left)
		playsound(get_turf(src), 'sound/machines/click.ogg', 50, TRUE)
		return

	var/turf/camera_loc = get_turf(camera)
	camera.captureimage(trigger_turf, src)

	playsound(camera_loc, pick('sound/items/polaroid1.ogg', 'sound/items/polaroid2.ogg'), 75, TRUE, -3)

	if(camera.flashing_lights)
		camera_loc.set_light(3, 2, LIGHT_COLOR_TUNGSTEN)
		addtimer(CALLBACK(camera_loc, TYPE_PROC_REF(/atom, set_light), 0), 2 SECONDS)

	camera.pictures_left--
	camera.on = FALSE
	camera.update_icon()
	addtimer(CALLBACK(camera, TYPE_PROC_REF(/obj/item/camera, delayed_turn_on)), 6.4 SECONDS)

/obj/item/tripwire/proc/trigger_tripwire(mob/user)
	if(!is_active || QDELETED(src))
		return

	var/turf/trigger_turf = get_turf(src)
	var/obj/item/payload = attached_item
	var/obj/item/tripwire/owner = src

	if(!payload && !QDELETED(linked_to) && linked_to.attached_item)
		payload = linked_to.attached_item
		owner = linked_to

	if(payload)
		var/payload_info = "[payload.name] ([payload.type])"
		var/payload_info = "[html_encode(payload.name)] ([payload.type])"
		investigate_log("[html_encode(key_name(user))] activated tripwire with [payload_info] at [ADMIN_COORDJMP(trigger_turf)]. Creator: [creator_key || "unknown"], Deployer: [payload_deployer_key || "unknown"]", INVESTIGATE_BOMB)

		if(istype(payload, /obj/item/grenade))
			var/obj/item/grenade/grenade = payload
			owner.attached_item = null
			grenade.forceMove(get_turf(owner))
			grenade.active = TRUE
			grenade.update_appearance()
			playsound(grenade.loc, 'sound/weapons/armbomb.ogg', 60, TRUE)
			addtimer(CALLBACK(grenade, TYPE_PROC_REF(/obj/item/grenade, prime)), 1 SECONDS)

		else if(istype(payload, /obj/item/flash))
			trigger_flash(user, payload)

		else if(istype(payload, /obj/item/assembly))
			var/obj/item/assembly/attached_assembly = payload
			attached_assembly.activate()

		else if(istype(payload, /obj/item/reagent_containers/food/drinks/drinkingglass))
			var/obj/item/reagent_containers/food/drinks/drinkingglass/drink_glass = payload
			var/turf/payload_turf = get_turf(owner)

			if(drink_glass.reagents && drink_glass.reagents.total_volume)
				drink_glass.reagents.reaction(payload_turf, REAGENT_TOUCH)
				for(var/mob/living/living in payload_turf)
					drink_glass.reagents.reaction(living, REAGENT_TOUCH)
				drink_glass.reagents.clear_reagents()

			playsound(payload_turf, 'sound/effects/glass_step.ogg', 60, TRUE)
			new /obj/item/shard(payload_turf)
			owner.attached_item = null
			qdel(drink_glass)

		else if(istype(payload, /obj/item/camera))
			trigger_camera(payload, trigger_turf)

	owner.update_appearance()
	break_wire()
