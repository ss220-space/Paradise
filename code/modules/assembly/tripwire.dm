/*
 * TRIPWIRE SYSTEM - Paradise 1984
 */

// 1. Объект провода (Bridge)
/obj/structure/tripwire_bridge
	name = "tripwire wire"
	desc = "Тонкий кабель. Похоже, он соединен с чем-то опасным."
	icon = 'icons/obj/assemblies/new_assemblies.dmi'
	icon_state = "tripwire_wire"
	anchored = TRUE
	density = FALSE
	layer = LOW_OBJ_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/obj/item/assembly/tripwire/master_base = null

/obj/structure/tripwire_bridge/Crossed(atom/movable/AM)
	..()
	if(!master_base || !master_base.is_active || !isliving(AM))
		return
	var/mob/living/L = AM
	// Проверка на аккуратный шаг
	if(L.m_intent == MOVE_INTENT_WALK || (L.pulledby && L.pulledby.m_intent == MOVE_INTENT_WALK))
		return

	// Звук срабатывания (щелчок)
	playsound(src, 'sound/machines/click.ogg', 50, TRUE)
	master_base.trigger_tripwire(L)

/obj/structure/tripwire_bridge/Destroy()
	if(master_base)
		var/obj/item/assembly/tripwire/M = master_base
		master_base = null // Убираем ссылку, чтобы не зациклить
		M.break_wire()
	return ..()

// 2. Основа растяжки (Base)
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

/obj/item/assembly/tripwire/attack_hand(mob/user)
	if(anchored_to_wall)
		to_chat(user, span_warning("[src] крепко привинчен к стене! Воспользуйтесь ломом."))
		return
	return ..()

// Сброс всех смещений при перемещении предмета
/obj/item/assembly/tripwire/forceMove(atom/dest)
	pixel_x = 0
	pixel_y = 0
	anchored = FALSE
	anchored_to_wall = FALSE
	return ..()

/obj/item/assembly/tripwire/afterattack(atom/target, mob/user, proximity)
	if(!proximity || anchored_to_wall || is_active)
		return

	// Крепление к стене
	if(isturf(target) && target.density)
		var/turf/T = get_turf(user)
		var/wall_dir = get_dir(T, target)
		if(!(wall_dir in list(NORTH, SOUTH, EAST, WEST)))
			return

		if(user.transfer_item_to_loc(src, T))
			src.anchored = TRUE
			src.anchored_to_wall = TRUE
			src.setDir(wall_dir)

			switch(wall_dir)
				if(NORTH) pixel_y = 14
				if(SOUTH) pixel_y = -14
				if(EAST)  pixel_x = 14
				if(WEST)  pixel_x = -14

			to_chat(user, span_notice("Вы закрепили [src] на стене."))
			playsound(src, 'sound/items/screwdriver.ogg', 50, TRUE)
			update_icon()

/obj/item/assembly/tripwire/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(ATTACK_CHAIN_CANCEL_CHECK(.))
		return .

	// Демонтаж ломом
	if(istype(I, /obj/item/crowbar))
		if(anchored_to_wall)
			if(is_active)
				to_chat(user, span_warning("Сначала нужно перерезать провод!"))
				return . | ATTACK_CHAIN_BLOCKED_ALL
			to_chat(user, span_notice("Вы откручиваете [src] от стены."))
			unanchor_base()
			return . | ATTACK_CHAIN_BLOCKED_ALL

	// Вставка предметов (Гранаты, Ассембли, Флеш)
	if(istype(I, /obj/item/grenade) || istype(I, /obj/item/assembly) || istype(I, /obj/item/flash))
		if(attached_item || (linked_to && linked_to.attached_item))
			to_chat(user, span_warning("Тут уже установлена ловушка!"))
			return . | ATTACK_CHAIN_BLOCKED_ALL

		if(user.transfer_item_to_loc(I, src))
			attached_item = I
			to_chat(user, span_notice("Вы закрепили [I] на [src]."))
			update_icon()
		return . | ATTACK_CHAIN_BLOCKED_ALL

	// Протяжка кабеля
	if(istype(I, /obj/item/stack/cable_coil))
		if(is_active)
			to_chat(user, span_warning("Провод уже натянут!"))
			return . | ATTACK_CHAIN_BLOCKED_ALL

		var/list/nearby_bases = list()
		for(var/obj/item/assembly/tripwire/T in range(3, src))
			if(T == src || T.is_active) continue
			if(T.x == src.x || T.y == src.y)
				nearby_bases += T

		if(!nearby_bases.len)
			to_chat(user, span_warning("В пределах 3-х тайлов по прямой нет подходящей основы."))
			return . | ATTACK_CHAIN_BLOCKED_ALL

		var/obj/item/assembly/tripwire/target = nearby_bases[1] // Берем первый элемент для начала
		if(nearby_bases.len > 1)
			for(var/obj/item/assembly/tripwire/T in nearby_bases)
				if(get_dist(src, T) < get_dist(src, target))
					target = T

		if(connect_to(target, I))
			to_chat(user, span_notice("Вы натянули провод между опорами."))
			I.use(1)

		return . | ATTACK_CHAIN_BLOCKED_ALL

	return .

/obj/item/assembly/tripwire/proc/unanchor_base()
	anchored = FALSE
	anchored_to_wall = FALSE
	pixel_x = 0
	pixel_y = 0
	update_icon()

/obj/item/assembly/tripwire/proc/connect_to(obj/item/assembly/tripwire/target, obj/item/stack/cable_coil/C)
	src.linked_to = target
	target.linked_to = src
	src.is_active = TRUE
	target.is_active = TRUE
	draw_wire(target, C.color)
	update_icon()
	target.update_icon()
	return TRUE

/obj/item/assembly/tripwire/proc/draw_wire(obj/item/assembly/tripwire/target, wire_color)
	var/turf/start_turf = get_turf(src)
	var/turf/end_turf = get_turf(target)
	var/dir_to = get_dir(start_turf, end_turf)
	var/dist = get_dist(start_turf, end_turf)

	// Если основы стоят вплотную, провод все равно нужен на одном из тайлов или между ними
	// Но по логике SS13 провод должен занимать все тайлы МЕЖДУ ними
	var/turf/current_turf = start_turf

	for(var/i in 1 to dist)
		// Если это последний тайл (где стоит вторая основа), мы можем либо ставить там провод, либо нет
		// Давай ставить на всех тайлах, включая тот, где цель, чтобы линия была полной
		var/obj/structure/tripwire_bridge/W = new(current_turf)
		W.color = wire_color
		W.master_base = src
		W.setDir(dir_to)

		// Убедимся, что провод виден
		W.layer = ABOVE_OPEN_TURF_LAYER // Или 3.1, чтобы был над полом
		W.alpha = 255

		LAZYADD(src.wire_segments, W)
		LAZYADD(target.wire_segments, W)

		if(current_turf == end_turf)
			break

		current_turf = get_step(current_turf, dir_to)

	playsound(src, 'sound/effects/servostep.ogg', 40, TRUE, -1, -1, -1, -1, 1.2)

/obj/item/assembly/tripwire/proc/trigger_tripwire(mob/user)
	if(!is_active) return

	var/obj/item/payload = attached_item
	var/obj/item/assembly/tripwire/owner = src

	if(!payload && linked_to && linked_to.attached_item)
		payload = linked_to.attached_item
		owner = linked_to

	if(payload)
		if(istype(payload, /obj/item/grenade))
			var/obj/item/grenade/G = payload
			owner.attached_item = null
			G.forceMove(get_turf(owner))
			G.det_time = max(G.det_time / 2, 5)
			G.prime(user)
		else if(istype(payload, /obj/item/flash))
			var/obj/item/flash/F = payload
			//F.activate()
		else if(istype(payload, /obj/item/assembly))
			var/obj/item/assembly/A = payload
			A.activate()

	break_wire()

/obj/item/assembly/tripwire/proc/break_wire()
	if(!is_active) return
	is_active = FALSE

	if(wire_segments && wire_segments.len)
		for(var/W in wire_segments)
			var/obj/structure/tripwire_bridge/WB = W
			if(istype(WB))
				WB.master_base = null
				qdel(WB)
		wire_segments.Cut()

	if(linked_to)
		var/obj/item/assembly/tripwire/L = linked_to
		linked_to = null
		L.break_wire()
	update_icon()

/obj/item/assembly/tripwire/update_overlays()
	. = ..()
	if(attached_item)
		var/image/I = image(attached_item.icon, attached_item.icon_state)
		I.pixel_y = 4
		. += I
