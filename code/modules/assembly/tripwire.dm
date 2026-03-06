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
	// Регистрируем сигнал: когда кто-то входит на наш тайл (loc), вызываем proc/on_entered
	RegisterSignal(loc, COMSIG_ATOM_ENTERED, .proc/on_entered)

/obj/structure/tripwire_bridge/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER

	if(!master_base || !master_base.is_active || !isliving(AM))
		return

	var/mob/living/L = AM

	// Проверка на левитацию или полет (как у осколков)
	if(L.incorporeal_move || (L.movement_type & MOVETYPES_NOT_TOUCHING_GROUND))
		return

	// Проверка на аккуратный шаг (Walk intent)
	if(L.m_intent == MOVE_INTENT_WALK || (L.pulledby && L.pulledby.m_intent == MOVE_INTENT_WALK))
		// Можно добавить тихий звук задетого кабеля
		return

	// АКТИВАЦИЯ
	playsound(src, 'sound/machines/click.ogg', 50, TRUE)
	master_base.trigger_tripwire(L)

/obj/structure/tripwire_bridge/Destroy()
	UnregisterSignal(loc, COMSIG_ATOM_ENTERED) // Не забываем отписаться
	if(master_base)
		var/obj/item/assembly/tripwire/M = master_base
		master_base = null
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
	var/wall_dir = 0            // ДОБАВЬ ЭТУ СТРОКУ

/obj/item/assembly/tripwire/attack_hand(mob/user)
	if(anchored_to_wall)
		to_chat(user, span_warning("[src] крепко привинчен к стене! Воспользуйтесь ломом."))
		return
	return ..()

/obj/item/assembly/tripwire/wirecutter_act(mob/living/user, obj/item/I)
	if(!is_active)
		return FALSE

	if(!I.use_tool(src, user, volume = I.tool_volume))
		return TRUE

	to_chat(user, span_notice("Вы осторожно перерезали провод растяжки."))
	break_wire()
	return TRUE

/obj/item/assembly/tripwire/screwdriver_act(mob/living/user, obj/item/I)
	if(!attached_item)
		return ..()

	to_chat(user, span_notice("Вы начали откручивать [attached_item] от [src]..."))
	if(I.use_tool(src, user, 20, volume = 50)) // 2 секунды задержки
		to_chat(user, span_notice("Вы успешно извлекли [attached_item]."))
		attached_item.forceMove(drop_location())
		attached_item = null
		update_appearance()
	return TRUE

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
			src.wall_dir = wall_dir // ОБЯЗАТЕЛЬНО ЗАПИСЫВАЕМ
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

	// 1. Вставка предметов (Гранаты, Ассембли, Флеш)
	if(istype(I, /obj/item/grenade) || istype(I, /obj/item/assembly) || istype(I, /obj/item/flash))
		if(attached_item || (linked_to && linked_to.attached_item))
			to_chat(user, span_warning("Тут уже установлена ловушка!"))
			return . | ATTACK_CHAIN_BLOCKED_ALL

		if(user.transfer_item_to_loc(I, src))
			attached_item = I
			to_chat(user, span_notice("Вы закрепили [I] на [src]."))
			update_appearance() // Используем update_appearance для оверлеев
		return . | ATTACK_CHAIN_BLOCKED_ALL

	// 2. Натяжение провода (Кабель) с do_after
	if(istype(I, /obj/item/stack/cable_coil))
		if(is_active)
			to_chat(user, span_warning("Провод уже натянут!"))
			return . | ATTACK_CHAIN_BLOCKED_ALL

		if(!anchored_to_wall)
			to_chat(user, span_warning("Сначала закрепите основу на стене!"))
			return . | ATTACK_CHAIN_BLOCKED_ALL

		var/list/valid_targets = list()
		for(var/obj/item/assembly/tripwire/T in range(2, src))
			if(T == src || T.is_active || !T.anchored_to_wall)
				continue

			var/is_valid_alignment = FALSE
			var/dist = get_dist(src, T)

			// СЛУЧАЙ 1: Основы на одном тайле (дверной проем)
			if(dist == 0)
				// Просто проверяем, что они смотрят в противоположные стороны (напр. NORTH и SOUTH)
				if(src.wall_dir == turn(T.wall_dir, 180))
					is_valid_alignment = TRUE

			// СЛУЧАЙ 2: Основы на разных тайлах (коридор)
			else if(src.x == T.x || src.y == T.y)
				var/dir_to_target = get_dir(src, T)
				var/dir_to_src = get_dir(T, src)
				if(src.wall_dir == turn(dir_to_target, 180) && T.wall_dir == turn(dir_to_src, 180))
					is_valid_alignment = TRUE

			if(is_valid_alignment)
				valid_targets += T

		if(!valid_targets.len)
			to_chat(user, span_warning("Напротив нет подходящей основы."))
			return . | ATTACK_CHAIN_BLOCKED_ALL

		var/obj/item/assembly/tripwire/target = valid_targets[1]
		if(valid_targets.len > 1)
			for(var/obj/item/assembly/tripwire/BT in valid_targets)
				if(get_dist(src, BT) < get_dist(src, target))
					target = BT

		// ПРОЦЕСС УСТАНОВКИ (Задержка 3 секунды)
		to_chat(user, span_notice("Вы начинаете протягивать кабель к [target]..."))
		if(do_after(user, 3 SECONDS, src))
			// Проверка условий после задержки (важно!)
			if(I && !is_active && target && !target.is_active && target.anchored_to_wall)
				if(connect_to(target, I))
					to_chat(user, span_notice("Вы успешно натянули провод между [src] и [target]."))
					I.use(1)

		return . | ATTACK_CHAIN_BLOCKED_ALL

	return .

/obj/item/assembly/tripwire/crowbar_act(mob/living/user, obj/item/I)
	if(!anchored_to_wall)
		return FALSE
	if(is_active)
		to_chat(user, span_warning("Сначала нужно перерезать натянутый провод!"))
		return TRUE

	// Используем стандартную задержку инструмента
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return TRUE

	to_chat(user, span_notice("Вы открутили [src] от стены."))
	unanchor_base()
	return TRUE

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
	var/turf/current_turf = get_turf(src)
	var/turf/end_turf = get_turf(target)

	// СЛУЧАЙ 1: Основы на одном тайле (дверной проем)
	if(current_turf == end_turf)
		var/obj/structure/tripwire_bridge/W = new(current_turf)
		W.color = wire_color
		W.master_base = src

		// ИСПРАВЛЕНИЕ: Если стены слева/справа (WEST/EAST),
		// тянем провод горизонтально (EAST или WEST)
		if(src.wall_dir == WEST || src.wall_dir == EAST)
			W.setDir(EAST)
		else
			// Если стены сверху/снизу (NORTH/SOUTH), тянем вертикально
			W.setDir(NORTH)

		LAZYADD(src.wire_segments, W)
		LAZYADD(target.wire_segments, W)

	// СЛУЧАЙ 2: Коридор (разные тайлы)
	else
		var/dir_to = get_dir(current_turf, end_turf)
		var/sanity = 0
		// Уменьшаем sanity до 3, так как макс. дистанция теперь меньше
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

	playsound(src, 'sound/effects/servostep.ogg', 40, TRUE, -1, -1, -1, -1, 1.2)

/obj/item/assembly/tripwire/proc/trigger_tripwire(mob/user)
	if(!is_active)
		return

	var/obj/item/payload = attached_item
	var/obj/item/assembly/tripwire/owner = src

	if(!payload && linked_to && linked_to.attached_item)
		payload = linked_to.attached_item
		owner = linked_to

	if(payload)
		// 1. ЛОГИКА ГРАНАТЫ (Paradise Style)
		if(istype(payload, /obj/item/grenade))
			var/obj/item/grenade/G = payload
			owner.attached_item = null
			G.forceMove(get_turf(owner))

			G.active = TRUE
			G.update_appearance(UPDATE_ICON_STATE)
			playsound(G.loc, 'sound/weapons/armbomb.ogg', 60, TRUE)

			var/final_det_time = max(G.det_time / 2, 5)
			// Используем TYPE_PROC_REF для надежности
			addtimer(CALLBACK(G, TYPE_PROC_REF(/obj/item/grenade, prime), user), final_det_time)

		// 2. ЛОГИКА ФЛЕША (Ручной флеш в базе)
		else if(istype(payload, /obj/item/flash))
			var/obj/item/flash/F = payload

			// Проверка на заряд (как в try_use_flash)
			if(F.try_use_flash(user))
				playsound(src.loc, 'sound/weapons/flash.ogg', 100, TRUE)
				// Эффект вспышки на самом объекте
				flick("[F.icon_state]_flash", F)

				// Слепим всех в радиусе 3 (как в коде флеша)
				for(var/mob/living/carbon/target in oviewers(3, get_turf(src)))
					// Вызываем стандартный эффект ослепления Paradise
					F.flash_carbon(target, user, 6 SECONDS)

			// Флеш остается в базе, но может перегореть (это внутри try_use_flash)

		// 3. ЛОГИКА АССЕМБЛИ
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
		var/mutable_appearance/MA = mutable_appearance(attached_item.icon, attached_item.icon_state)
		// Если pixel_y вызывал рантайм, попробуй сначала БЕЗ него.
		// Если БЕЗ него рантайма нет и граната видна - значит так и оставим.
		. += MA
