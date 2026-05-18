///////////////////////////////////////
// MARK:	Tripwire Bridge
///////////////////////////////////////

/obj/structure/tripwire_bridge
	name = "tripwire"
	desc = "Тонкий провод. Похоже, он соединен с чем-то опасным."
	icon = 'icons/obj/tripwire.dmi'
	icon_state = "tripwire_wire"
	anchored = TRUE
	layer = LOW_OBJ_LAYER
	var/obj/item/tripwire/master_base

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

	if(entered_living.incorporeal_move || (entered_living.movement_type & MOVETYPES_NOT_TOUCHING_GROUND))
		return

	if(entered_living.m_intent == MOVE_INTENT_WALK || (entered_living.pulledby && entered_living.pulledby.m_intent == MOVE_INTENT_WALK))
		return

	playsound(src, 'sound/machines/click.ogg', 50, TRUE)
	SEND_SIGNAL(master_base, COMSIG_TRIPWIRE_BASE_ACTIVATE, entered_living)

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
	if(master_base && !master_base.breaking)
		master_base.break_wire()

	master_base = null
	UnregisterSignal(loc, COMSIG_ATOM_ENTERED)
	return ..()

////////////////////////////////////////
// MARK:	Tripwire base
////////////////////////////////////////

/obj/item/tripwire
	name = "tripwire base"
	desc = "Металлическое основание для растяжки. Не забудьте про кабель!"
	icon = 'icons/obj/tripwire.dmi'
	icon_state = "tripwire_base"
	var/obj/item/tripwire/linked_to = null
	var/obj/item/attached_item = null
	var/is_active = FALSE
	var/anchored_to_wall = FALSE
	var/list/wire_segments
	var/wall_dir = 0
	var/breaking = FALSE

	var/datum/weakref/creator_mind = null
	var/datum/weakref/payload_mind = null

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
		QDEL_LIST(other.wire_segments)

	linked_to = null
	attached_item = null

	return ..()

/obj/item/tripwire/attack_hand(mob/user)
	if(anchored_to_wall)
		to_chat(user, span_warning("[DECLENT_RU_CAP(src, ACCUSATIVE)] нужно открепить ломом!"))
		return

	unanchor_base()
	return ..()

/obj/item/tripwire/two_for_craft

/obj/item/tripwire/two_for_craft/Initialize(mapload)
	. = ..()
	new /obj/item/tripwire(loc)
	new /obj/item/tripwire(loc)
	qdel(src)

////////////////////////////////////////
// MARK:	Tripwire setting up
////////////////////////////////////////

/obj/item/tripwire/afterattack(atom/target, mob/user, proximity_flag, list/modifiers, status)
	if(!proximity_flag || anchored_to_wall || is_active)
		return

	if(!isturf(target))
		return

	var/turf/user_turf = get_turf(user)
	var/dir_to_wall = get_dir(user_turf, target)

	if(!(dir_to_wall in GLOB.cardinal))
		return

	if(!user.transfer_item_to_loc(src, user_turf))
		return

	anchored = TRUE
	anchored_to_wall = TRUE
	wall_dir = dir_to_wall
	setDir(wall_dir)

	apply_wall_offset()

	to_chat(user, span_notice("Вы надёжно закрепили [declent_ru(ACCUSATIVE)] на стене."))
	playsound(src, 'sound/machines/click.ogg', 50, TRUE)
	update_appearance(UPDATE_OVERLAYS | UPDATE_ICON_STATE)

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
			pixel_y = -18
		if(EAST)
			pixel_x = 15
			pixel_y = -7
		if(WEST)
			pixel_x = -14
			pixel_y = -7

/obj/item/tripwire/proc/can_be_used_on_tripwire(obj/item)
	if(HAS_TRAIT(item, TRAIT_CAN_ATTACH_TO_TRIPWIRE))
		return TRUE
	return FALSE

/obj/item/tripwire/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(ATTACK_CHAIN_CANCEL_CHECK(.))
		return .

	if(iscoil(I))
		if(setup_wire(I, user))
			return . | ATTACK_CHAIN_BLOCKED_ALL

	if(can_be_used_on_tripwire(I))
		if(install_payload(I, user))
			return . | ATTACK_CHAIN_BLOCKED_ALL

	return .

/obj/item/tripwire/proc/is_valid_target(obj/item/tripwire/target)
	if(QDELETED(target) || target == src || target.is_active || !target.anchored_to_wall)
		return FALSE

	var/distance = get_dist(src, target)

	if(distance > 0)
		var/turf/check_step = get_turf(src)
		var/dir_to_target = get_dir(src, target)
		for(var/i in 1 to distance)
			check_step = get_step(check_step, dir_to_target)
			if(check_step.density && check_step != get_turf(target))
				return FALSE

	if(distance == 0)
		return (wall_dir == turn(target.wall_dir, 180))

	if(x == target.x || y == target.y)
		var/dir_to_target = get_dir(src, target)
		var/dir_to_source = get_dir(target, src)
		return (wall_dir == turn(dir_to_target, 180) && target.wall_dir == turn(dir_to_source, 180))

	return FALSE

/obj/item/tripwire/proc/find_best_target()
	var/obj/item/tripwire/best_target = null
	var/min_dist = INFINITY

	for(var/obj/item/tripwire/nearby in range(2, src))
		if(!is_valid_target(nearby))
			continue

		var/distance = get_dist(src, nearby)
		if(distance < min_dist)
			min_dist = distance
			best_target = nearby

	return best_target

/obj/item/tripwire/proc/setup_wire(obj/item/stack/cable_coil/cable, mob/user)
	if(is_active)
		to_chat(user, span_warning("Провод уже натянут!"))
		return

	var/obj/item/tripwire/target_base = find_best_target()
	if(!target_base)
		to_chat(user, span_warning("Напротив нет подходящей основы или путь заблокирован."))
		return

	var/needed_cable = max(get_dist(src, target_base) + 1, 1)
	if(cable.amount < needed_cable)
		to_chat(user, span_warning("Вам нужен кабель длиной [needed_cable] для такой дистанции!"))
		return

	to_chat(user, span_notice("Вы начинаете протягивать кабель к [target_base.declent_ru(DATIVE)]..."))
	var/initial_target_loc = target_base.loc

	if(!cable.use_tool(src, user, 3 SECONDS, volume = 50))
		return

	if(QDELETED(target_base) || target_base.loc != initial_target_loc || z != target_base.z || is_active || target_base.is_active || QDELETED(cable) || cable.amount < needed_cable)
		return

	if(!connect_to(target_base, cable))
		return

	if(user.mind)
		var/datum/weakref/mind_weakref = WEAKREF(user.mind)
		creator_mind = mind_weakref
		target_base.creator_mind = mind_weakref

	to_chat(user, span_notice("Вы успешно натянули провод между растяжками."))
	cable.use(needed_cable)

/obj/item/tripwire/proc/connect_to(obj/item/tripwire/target, obj/item/stack/cable_coil/cable)
	linked_to = target
	is_active = TRUE
	target.linked_to = src
	target.is_active = TRUE

	draw_wire(target, cable.color)
	update_appearance(UPDATE_OVERLAYS | UPDATE_ICON_STATE)
	target.update_appearance(UPDATE_OVERLAYS | UPDATE_ICON_STATE)

	RegisterSignal(src, COMSIG_TRIPWIRE_BASE_ACTIVATE, PROC_REF(trigger_tripwire), override = TRUE)
	target.RegisterSignal(target, COMSIG_TRIPWIRE_BASE_ACTIVATE, PROC_REF(trigger_tripwire), override = TRUE)

	if(attached_item)
		RegisterSignal(src, COMSIG_TRIPWIRE_TRIGGERED, PROC_REF(on_payload_activate), override = TRUE)

	if(target.attached_item)
		target.RegisterSignal(target, COMSIG_TRIPWIRE_TRIGGERED, PROC_REF(on_payload_activate), override = TRUE)

	return TRUE

/obj/item/tripwire/proc/draw_wire(obj/item/tripwire/target_base, wire_color)
	var/turf/current_turf = get_turf(src)
	var/turf/end_turf = get_turf(target_base)

	if(current_turf == end_turf)
		var/target_dir = (wall_dir == NORTH || wall_dir == SOUTH) ? NORTH : EAST
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

/obj/item/tripwire/proc/install_payload(obj/item/item, mob/user)
	if(attached_item || (linked_to && linked_to.attached_item))
		to_chat(user, span_warning("На растяжке уже что-то установлено!"))
		return

	if(!user.transfer_item_to_loc(item, src))
		return

	attached_item = item
	if(user.mind)
		payload_mind = WEAKREF(user.mind)

	RegisterSignal(src, COMSIG_TRIPWIRE_TRIGGERED, PROC_REF(on_payload_activate), override = TRUE)
	to_chat(user, span_notice("Вы закрепили [item.declent_ru(ACCUSATIVE)] на растяжке."))
	update_appearance()

/obj/item/tripwire/update_overlays()
	. = ..()
	if(!attached_item)
		return

	var/mutable_appearance/mutable_appearance = mutable_appearance(attached_item.icon, attached_item.icon_state)
	var/matrix/matrix = matrix()
	matrix.Scale(0.8, 0.8)
	matrix.Turn(180)
	matrix.Translate(0, 8)
	mutable_appearance.transform = matrix
	. += mutable_appearance

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
	UnregisterSignal(src, COMSIG_TRIPWIRE_TRIGGERED)
	update_appearance(UPDATE_OVERLAYS | UPDATE_ICON_STATE)

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
	update_appearance(UPDATE_OVERLAYS | UPDATE_ICON_STATE)

/obj/item/tripwire/proc/break_wire()
	if(breaking || !is_active)
		return

	breaking = TRUE
	is_active = FALSE
	UnregisterSignal(src, list(COMSIG_TRIPWIRE_BASE_ACTIVATE, COMSIG_TRIPWIRE_TRIGGERED))

	var/obj/item/tripwire/other = linked_to
	if(other && !QDELETED(other))
		linked_to = null
		if(!other.breaking)
			other.break_wire()

	QDEL_LIST(wire_segments)

	update_appearance(UPDATE_OVERLAYS | UPDATE_ICON_STATE)
	breaking = FALSE

////////////////////////////////////////
// MARK:	Trigger & payloads
////////////////////////////////////////
#define TRIPWIRE_GRENADE_DETONATION_TIME 1 SECONDS

/obj/item/tripwire/proc/on_payload_activate(datum/source, mob/user)
	SIGNAL_HANDLER
	if(!attached_item)
		return

	attached_item.on_tripwire_trigger(src, user)

/obj/item/tripwire/proc/trigger_tripwire(datum/source, mob/user)
	SIGNAL_HANDLER
	if(!is_active || QDELETED(src))
		return

	var/obj/item/tripwire/owner = get_tripwire_with_payload()
	if(!owner)
		break_wire()
		return

	if(owner.attached_item)
		var/turf/owner_turf = get_turf(owner)

		var/creator_info = key_name(owner.creator_mind?.resolve())
		var/deployer_info = key_name(owner.payload_mind?.resolve())

		investigate_log("Tripwire activated by [key_name(user)] at [ADMIN_COORDJMP(owner_turf)]. Payload: [owner.attached_item.name]. Creator: [creator_info]. Payload deployer: [deployer_info].", INVESTIGATE_BOMB)
		SEND_SIGNAL(owner, COMSIG_TRIPWIRE_TRIGGERED, user)

	owner.update_appearance(UPDATE_OVERLAYS | UPDATE_ICON_STATE)
	break_wire()

/obj/item/tripwire/proc/get_tripwire_with_payload()
	if(QDELETED(src) || QDELETED(linked_to))
		return

	if(attached_item)
		return src

	else if(linked_to.attached_item)
		return linked_to

	return

#undef TRIPWIRE_GRENADE_DETONATION_TIME
