// MARK: Rack
/obj/structure/rack
	name = "rack"
	desc = "Белый крупный стеллаж, удобен для хранения различных вещей."
	gender = MALE
	icon = 'icons/obj/structures/rack.dmi'
	icon_state = "rack"
	layer = TABLE_LAYER
	density = TRUE
	anchored = TRUE
	pass_flags_self = LETPASSTHROW
	max_integrity = 20
	/// If TRUE, this is a wooden version that disables certain interactions.
	var/wooden_version = FALSE
	/// The type of parts created when deconstructing.
	var/parts_type = /obj/item/rack_parts

/obj/structure/rack/get_ru_names()
	return list(
		NOMINATIVE = "стеллаж",
		GENITIVE = "стеллажа",
		DATIVE = "стеллажу",
		ACCUSATIVE = "стеллаж",
		INSTRUMENTAL = "стеллажом",
		PREPOSITIONAL = "стеллаже",
	)

/obj/structure/rack/Initialize(mapload)
	. = ..()
	register_context()

/obj/structure/rack/add_context(atom/source, list/context, obj/item/held_item, mob/living/user)
	if(isnull(held_item))
		return NONE

	if(held_item.tool_behaviour == TOOL_WRENCH)
		context[SCREENTIP_CONTEXT_RMB] = "Разобрать"
		return CONTEXTUAL_SCREENTIP_SET

	return NONE

/obj/structure/rack/examine(mob/user)
	. = ..()
	if(!wooden_version)
		. += span_notice("Держится на паре [span_bold("болтов")].")

/obj/structure/rack/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(.)
		return
	if(istype(mover) && (mover.pass_flags & PASSTABLE))
		return TRUE

/obj/structure/rack/mouse_drop_receive(obj/item/dropped_item, mob/user, params)
	if(!isitem(dropped_item) || user.get_active_hand() != dropped_item || isrobot(user))
		return FALSE
	if(dropped_item.loc != loc && user.transfer_item_to_loc(dropped_item, loc))
		add_fingerprint(user)
		return TRUE
	return FALSE

/obj/structure/rack/base_item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	. = ..()
	if(.)
		return .
	if((tool.item_flags & ABSTRACT) || (user.a_intent  == INTENT_HARM && !(tool.item_flags & NOBLUDGEON)))
		return NONE
	if(user.transfer_item_to_loc(tool, get_turf(src)))
		return ITEM_INTERACT_SUCCESS
	return ITEM_INTERACT_BLOCKING

/obj/structure/rack/wrench_act_secondary(mob/living/user, obj/item/tool)
	tool.play_tool_sound(src)
	deconstruct(TRUE)
	return ITEM_INTERACT_SUCCESS

/obj/structure/rack/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(wooden_version)
		return ..()
	if(user.a_intent != INTENT_HARM || user.body_position == LYING_DOWN || user.usable_legs < 2)
		return
	add_fingerprint(user)
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src, ATTACK_EFFECT_KICK)
	user.visible_message(
		span_warning("[DECLENT_RU_CAP(user, NOMINATIVE)] пинает [declent_ru(ACCUSATIVE)]."),
		span_danger("Вы пинаете [declent_ru(ACCUSATIVE)]."),
		vision_distance = COMBAT_MESSAGE_RANGE,
	)
	take_damage(rand(4, 8), damage_type = BRUTE, damage_flag = MELEE, sound_effect = TRUE)

/obj/structure/rack/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(loc, 'sound/items/dodgeball.ogg', 80, TRUE)
			else
				playsound(loc, 'sound/weapons/tap.ogg', 50, TRUE)
		if(BURN)
			playsound(loc, 'sound/items/welder.ogg', 40, TRUE)

/obj/structure/rack/deconstruct(disassembled = TRUE)
	if(obj_flags & NODECONSTRUCT)
		return ..()
	set_density(FALSE)
	pre_deconstruct()
	var/obj/item/new_parts = new parts_type(drop_location())
	transfer_fingerprints_to(new_parts)
	return ..()

/// Called before creating parts during deconstruction.
/obj/structure/rack/proc/pre_deconstruct()
	return

// MARK: Skeletal Minibar
/obj/structure/rack/skeletal_bar
	name = "skeletal minibar"
	desc = "Сделано из черепов павших."
	icon_state = "minibar"

/obj/structure/rack/skeletal_bar/left
	icon_state = "minibar_left"

/obj/structure/rack/skeletal_bar/right
	icon_state = "minibar_right"

// MARK: Gun Rack
/obj/structure/rack/gunrack
	name = "gun rack"
	desc = "Оружейная стойка для хранения оружия."
	icon_state = "gunrack"
	parts_type = /obj/item/rack_parts/gunrack_parts

/// Attempts to place a gun onto the rack.
/obj/structure/rack/gunrack/proc/place_gun(obj/item/gun/gun_item, mob/user, list/modifiers)
	if(!ishuman(user) || user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return FALSE
	if(!istype(gun_item))
		to_chat(user, span_warning("Этот предмет не подходит!"))
		return FALSE
	if(gun_item.item_flags & ABSTRACT)
		return FALSE
	if(!user.drop_item_ground(gun_item))
		return FALSE
	if(gun_item.loc != loc)
		add_fingerprint(user)
		gun_item.reset_direction()
		gun_item.place_on_rack()
		gun_item.do_drop_animation(src)
		gun_item.Move(loc)
		// Offset the icon based on click position
		var/icon_x = LAZYACCESS(modifiers, ICON_X)
		var/icon_y = LAZYACCESS(modifiers, ICON_Y)
		if(icon_x && icon_y)
			gun_item.pixel_x = clamp(text2num(icon_x) - 16, -(ICON_SIZE_X / 2), ICON_SIZE_X / 2)
			gun_item.pixel_y = 0
		return TRUE
	return FALSE

/obj/structure/rack/gunrack/mouse_drop_receive(obj/item/gun/gun_item, mob/user, params)
	return place_gun(gun_item, user, params2list(params))

/obj/structure/rack/gunrack/base_item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	. = ..()
	if(.)
		return .
	place_gun(tool, user, modifiers)
	return ITEM_INTERACT_BLOCKING

/obj/structure/rack/gunrack/Initialize(mapload)
	. = ..()
	if(!mapload)
		return
	for(var/obj/item/gun/weapon in loc)
		weapon.place_on_rack()

/obj/structure/rack/gunrack/pre_deconstruct()
	var/atom/drop_loc = drop_location()
	if(!drop_loc)
		return
	for(var/obj/item/item_in_loc in drop_loc.contents)
		if(!isgun(item_in_loc))
			continue
		var/obj/item/gun/weapon = item_in_loc
		weapon.remove_from_rack()

// MARK: Wooden Rack
/obj/structure/rack/wooden
	name = "wooden rack"
	desc = "Небольшой стеллаж, сделанный из дерева. Вы можете хранить на нём вещи!"
	icon_state = "wooden_rack"
	wooden_version = TRUE
	obj_flags = NODECONSTRUCT

/obj/structure/rack/wooden/get_ru_names()
	return list(
		NOMINATIVE = "деревянный стеллаж",
		GENITIVE = "деревянного стеллажа",
		DATIVE = "деревянному стеллажу",
		ACCUSATIVE = "деревянный стеллаж",
		INSTRUMENTAL = "деревянным стеллажом",
		PREPOSITIONAL = "деревянном стеллаже",
	)

/obj/structure/rack/wooden/Initialize(mapload)
	. = ..()
	update_icon(UPDATE_OVERLAYS)

/obj/structure/rack/wooden/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_WOOD, -40, 5)

/obj/structure/rack/wooden/mouse_drop_receive(obj/item/dropped_item, mob/user, params)
	. = ..()
	update_icon(UPDATE_OVERLAYS)

/obj/structure/rack/wooden/update_overlays()
	. = ..()
	var/mutable_appearance/wooden_rack_overlay = mutable_appearance('icons/obj/objects.dmi', "wooden_rack_overlay", ABOVE_OBJ_LAYER)
	. += wooden_rack_overlay

/obj/structure/rack/wooden/wrench_act_secondary(mob/living/user, obj/item/tool)
	return NONE
