/obj/structure/tripwire_bridge
	name = "tripwire"
	desc = "Тонкий кабель. Похоже, он соединен с чем-то опасным."
	icon = 'icons/obj/assemblies/new_assemblies.dmi'
	icon_state = "tripwire_wire"
	anchored = TRUE
	density = FALSE
	layer = LOW_OBJ_LAYER
	mouse_opacity = MOUSE_OPACITY_ICON
	var/obj/item/assembly/tripwire/master_base = null

/obj/structure/tripwire_bridge/Initialize(mapload)
	. = ..()
	RegisterSignal(loc, COMSIG_ATOM_ENTERED, .proc/on_entered)

/obj/structure/tripwire_bridge/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER

	if(!master_base || !master_base.is_active || !isliving(AM))
		return

	var/mob/living/L = AM

	if(L.incorporeal_move || (L.movement_type & MOVETYPES_NOT_TOUCHING_GROUND))
		return

	if(L.m_intent == MOVE_INTENT_WALK || (L.pulledby && L.pulledby.m_intent == MOVE_INTENT_WALK))
		return

	playsound(src, 'sound/machines/click.ogg', 50, TRUE)
	master_base.trigger_tripwire(L)

/obj/structure/tripwire_bridge/Destroy()
	UnregisterSignal(loc, COMSIG_ATOM_ENTERED)
	if(master_base)
		var/obj/item/assembly/tripwire/M = master_base
		master_base = null
		M.break_wire()
	return ..()

// Base of tripwire
/obj/item/assembly/tripwire
	name = "tripwire base"
	desc = "Металлическое основание для растяжки. Закрепите на стене, добавьте детонатор и протяните кабель."
	icon = 'icons/obj/assemblies/new_assemblies.dmi'
	icon_state = "tripwire_base"
	var/obj/item/assembly/tripwire/linked_to = null
	var/obj/item/attached_item = null
	var/is_active = FALSE
	var/anchored_to_wall = FALSE
	var/list/wire_segments = list()
	var/wall_dir = 0
	var/creator_key = null

/obj/item/assembly/tripwire/attack_hand(mob/user)
	if(anchored_to_wall)
		to_chat(user, span_warning("[src] крепко привинчен к стене! Воспользуйтесь ломом."))
		return
	return ..()

/obj/item/assembly/tripwire/wirecutter_act(mob/living/user, obj/item/I)
	if(!is_active || QDELETED(src))
		return FALSE

	to_chat(user, span_notice("Вы начали осторожно перерезать провод растяжки..."))

	if(!I.use_tool(src, user, 2 SECONDS, volume = 50))
		return TRUE

	if(QDELETED(src) || !is_active)
		return TRUE

	to_chat(user, span_notice("Вы успешно перерезали провод растяжки."))
	break_wire()
	return TRUE

/obj/item/assembly/tripwire/screwdriver_act(mob/living/user, obj/item/I)
	if(!attached_item)
		return FALSE

	to_chat(user, span_notice("Вы начали извлекать [attached_item] из [src]..."))
	if(!I.use_tool(src, user, 2 SECONDS, volume = 50))
		return TRUE

	if(QDELETED(src) || !attached_item)
		return TRUE

	var/obj/item/extracted_item = attached_item
	to_chat(user, span_notice("Вы успешно извлекли [extracted_item] из [src]."))
	extracted_item.forceMove(drop_location())
	attached_item = null
	update_appearance()
	return TRUE

/obj/item/assembly/tripwire/forceMove(atom/dest)
	pixel_x = 0
	pixel_y = 0
	anchored = FALSE
	anchored_to_wall = FALSE
	return ..()

/obj/item/assembly/tripwire/afterattack(atom/target, mob/user, proximity)
	if(!proximity || anchored_to_wall || is_active)
		return

	if(isturf(target) && target.density)
		var/turf/T = get_turf(user)
		var/wall_dir = get_dir(T, target)
		if(!(wall_dir in list(NORTH, SOUTH, EAST, WEST)))
			return

		if(user.transfer_item_to_loc(src, T))
			src.anchored = TRUE
			src.anchored_to_wall = TRUE
			src.wall_dir = wall_dir
			src.setDir(wall_dir)

			switch(wall_dir)
				if(NORTH) pixel_y = 14
				if(SOUTH) pixel_y = -14
				if(EAST)  pixel_x = 14
				if(WEST)  pixel_x = -14

			to_chat(user, span_notice("Вы закрепили [src] на стене."))
			playsound(src, 'sound/items/screwdriver.ogg', 50, TRUE)
			update_appearance()

/obj/item/assembly/tripwire/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/grenade) || istype(I, /obj/item/assembly) || istype(I, /obj/item/flash))
		if(attached_item || (linked_to && linked_to.attached_item))
			to_chat(user, span_warning("Тут уже установлена ловушка!"))
			return . | ATTACK_CHAIN_BLOCKED_ALL

		if(user.transfer_item_to_loc(I, src))
			attached_item = I
			to_chat(user, span_notice("Вы закрепили [I] на [src]."))
			update_appearance()
		return . | ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/stack/cable_coil))
		if(is_active)
			to_chat(user, span_warning("Провод уже натянут!"))
			return . | ATTACK_CHAIN_BLOCKED_ALL

		if(!anchored_to_wall)
			to_chat(user, span_warning("Сначала закрепите основу на стене!"))
			return . | ATTACK_CHAIN_BLOCKED_ALL

		var/list/valid_targets = list()
		for(var/obj/item/assembly/tripwire/nearby_base in range(2, src))
			if(QDELETED(nearby_base) || nearby_base == src || nearby_base.is_active || !nearby_base.anchored_to_wall)
				continue

			var/is_valid_alignment = FALSE
			var/distance_to_base = get_dist(src, nearby_base)

			if(distance_to_base == 0)
				if(src.wall_dir == turn(nearby_base.wall_dir, 180))
					is_valid_alignment = TRUE

			else if(src.x == nearby_base.x || src.y == nearby_base.y)
				var/direction_to_target = get_dir(src, nearby_base)
				var/direction_to_source = get_dir(nearby_base, src)
				if(src.wall_dir == turn(direction_to_target, 180) && nearby_base.wall_dir == turn(direction_to_source, 180))
					is_valid_alignment = TRUE

			if(is_valid_alignment)
				valid_targets += nearby_base

		if(!valid_targets.len)
			to_chat(user, span_warning("Напротив нет подходящей основы."))
			return . | ATTACK_CHAIN_BLOCKED_ALL

		var/obj/item/assembly/tripwire/target_base = valid_targets[1]
		if(valid_targets.len > 1)
			for(var/obj/item/assembly/tripwire/potential_base in valid_targets)
				if(get_dist(src, potential_base) < get_dist(src, target_base))
					target_base = potential_base

		var/needed_cable = max(get_dist(src, target_base), 1)
		var/obj/item/stack/cable_coil/cable_stack = I
		if(cable_stack.amount < needed_cable)
			to_chat(user, span_warning("Вам нужно [needed_cable] ед. кабеля для такой дистанции!"))
			return . | ATTACK_CHAIN_BLOCKED_ALL

		to_chat(user, span_notice("Вы начинаете протягивать кабель к [target_base]..."))

		if(!do_after(user, 3 SECONDS, src))
			return . | ATTACK_CHAIN_BLOCKED_ALL

		if(src.z != target_base.z)
			return . | ATTACK_CHAIN_BLOCKED_ALL

		if(cable_stack.amount < needed_cable)
			to_chat(user, span_warning("Кабель внезапно закончился!"))
			return . | ATTACK_CHAIN_BLOCKED_ALL

		if(connect_to(target_base, cable_stack))
			src.creator_key = user.ckey
			target_base.creator_key = user.ckey
			to_chat(user, span_notice("Вы успешно натянули провод между [src] и [target_base]."))
			cable_stack.use(needed_cable)

		return . | ATTACK_CHAIN_BLOCKED_ALL

	return .

/obj/item/assembly/tripwire/crowbar_act(mob/living/user, obj/item/I)
	if(QDELETED(src) || !anchored_to_wall)
		return FALSE
	if(is_active)
		to_chat(user, span_warning("Сначала нужно перерезать натянутый провод!"))
		return TRUE

	to_chat(user, span_notice("Вы начали откручивать [src] от стены..."))

	if(!I.use_tool(src, user, 2 SECONDS, volume = 50))
		return TRUE

	if(QDELETED(src) || !anchored_to_wall || is_active)
		return TRUE

	to_chat(user, span_notice("Вы успешно открутили [src] от стены."))
	unanchor_base()
	return TRUE

/obj/item/assembly/tripwire/proc/unanchor_base()
	anchored = FALSE
	anchored_to_wall = FALSE
	pixel_x = 0
	pixel_y = 0
	update_appearance()

/obj/item/assembly/tripwire/proc/connect_to(obj/item/assembly/tripwire/target, obj/item/stack/cable_coil/C)
	src.linked_to = target
	target.linked_to = src
	src.is_active = TRUE
	target.is_active = TRUE
	draw_wire(target, C.color)
	update_appearance()
	target.update_appearance()
	return TRUE

/obj/item/assembly/tripwire/proc/draw_wire(obj/item/assembly/tripwire/target, wire_color)
	var/turf/current_turf = get_turf(src)
	var/turf/end_turf = get_turf(target)

	if(current_turf == end_turf)
		var/obj/structure/tripwire_bridge/W = new(current_turf)
		W.color = wire_color
		W.master_base = src
		W.setDir((src.wall_dir == WEST || src.wall_dir == EAST) ? EAST : NORTH)

		LAZYADD(src.wire_segments, W)
		LAZYADD(target.wire_segments, W)

	else
		var/dir_to = get_dir(current_turf, end_turf)
		var/sanity = 0
		while(current_turf && sanity < 4)
			var/obj/structure/tripwire_bridge/W = new(current_turf)
			W.color = wire_color
			W.master_base = src
			W.setDir(dir_to)

			LAZYADD(src.wire_segments, W)
			LAZYADD(target.wire_segments, W)

			if(current_turf == end_turf)
				break

			current_turf = get_step(current_turf, dir_to)
			sanity++

	playsound(src, 'sound/effects/servostep.ogg', 40, TRUE)

/obj/item/assembly/tripwire/proc/trigger_tripwire(mob/user)
	if(!is_active || QDELETED(src))
		return

	var/turf/trigger_turf = get_turf(src)
	var/obj/item/payload = attached_item
	var/obj/item/assembly/tripwire/owner = src

	if(!payload && !QDELETED(linked_to) && linked_to.attached_item)
		payload = linked_to.attached_item
		owner = linked_to

	var/payload_name = payload ? payload.name : "пустая растяжка"
	investigate_log("[key_name(user)] активировал растяжку ([payload_name]) на [ADMIN_COORDJMP(trigger_turf)]. Создатель: [creator_key ? creator_key : "неизвестен"].", INVESTIGATE_BOMB)

	if(!QDELETED(payload))
		if(istype(payload, /obj/item/grenade))
			var/obj/item/grenade/grenade = payload
			owner.attached_item = null
			grenade.forceMove(get_turf(owner))

			if(!QDELETED(grenade))
				grenade.active = TRUE
				grenade.update_appearance(UPDATE_ICON_STATE)
				playsound(grenade.loc, 'sound/weapons/armbomb.ogg', 60, TRUE)
				var/final_det_time = max(round(grenade.det_time / 2), 5)
				addtimer(CALLBACK(grenade, TYPE_PROC_REF(/obj/item/grenade, prime), user), final_det_time)

		else if(istype(payload, /obj/item/flash))
			var/obj/item/flash/F = payload
			if(F.try_use_flash(user))
				playsound(src.loc, 'sound/weapons/flash.ogg', 100, TRUE)
				flick("[F.icon_state]_flash", F)
				for(var/mob/living/carbon/target in oviewers(3, get_turf(src)))
					F.flash_carbon(target, user, 6 SECONDS)

		else if(istype(payload, /obj/item/assembly))
			var/obj/item/assembly/A = payload
			A.activate()

	break_wire()

/obj/item/assembly/tripwire/proc/break_wire()
	if(!is_active)
		return
	is_active = FALSE

	if(wire_segments && wire_segments.len)
		var/list/segments_to_delete = wire_segments.Copy()
		wire_segments.Cut()

		for(var/obj/structure/tripwire_bridge/segment in segments_to_delete)
			if(!QDELETED(segment))
				segment.master_base = null
				qdel(segment)

	if(!QDELETED(linked_to))
		var/obj/item/assembly/tripwire/other_base = linked_to
		linked_to = null
		other_base.break_wire()

	update_appearance()

/obj/item/assembly/tripwire/update_overlays()
	. = ..()
	if(attached_item)
		var/mutable_appearance/MA = mutable_appearance(attached_item.icon, attached_item.icon_state)
		. += MA
