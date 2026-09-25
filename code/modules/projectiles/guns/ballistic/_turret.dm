#define TURRET_SOURCE "turret"

/obj/structure/stationary_machinegun
	name = "stationary machinegun"
	desc = "Тренога со стационарным пулеметом. Вы можете встать за него для стрельбы."
	icon = 'icons/obj/weapons/stationary.dmi'
	icon_state = "pkm"
	can_buckle = TRUE
	buckle_lying = 0 // you stay in a stationary machinegun, not lay
	max_integrity = 250
	integrity_failure = 25
	pull_push_slowdown = 1.5
	interaction_flags_click = NEED_HANDS | ALLOW_RESTING
	interaction_flags_mouse_drop = NEED_HANDS | ALLOW_RESTING
	buckle_bonus_spread = 0
	var/obj/item/stationary_machinegun/item = /obj/item/stationary_machinegun
	var/obj/item/gun/projectile/automatic/internal_gun = /obj/item/gun/projectile/automatic/l6_saw
	var/offset_x = 12
	var/allow_move = TRUE

/obj/structure/stationary_machinegun/get_ru_names()
	return list(
		NOMINATIVE = "станковый пулемет",
		GENITIVE = "станкового пулемета",
		DATIVE = "станковому пулемету",
		ACCUSATIVE = "станковый пулемет",
		INSTRUMENTAL = "станковым пулеметом",
		PREPOSITIONAL = "станковом пулемете",
	)

/obj/structure/stationary_machinegun/Initialize(mapload)
	. = ..()
	item = new item(src)
	item.origin = src
	internal_gun = new internal_gun(src)

/obj/structure/stationary_machinegun/Destroy()
	QDEL_NULL(item)
	return ..()

/obj/structure/stationary_machinegun/click_alt(mob/living/user)
	rotate(user)
	return CLICK_ACTION_SUCCESS

/obj/structure/stationary_machinegun/proc/rotate(mob/living/user)
	if(user)
		if(isobserver(user))
			if(!CONFIG_GET(flag/ghost_interaction))
				return FALSE
		else if(!isliving(user) || user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !Adjacent(user))
			return FALSE

	setDir(turn(dir, 90))
	handle_rotation()
	return TRUE

/obj/structure/stationary_machinegun/proc/handle_rotation(direction)
	handle_layer()
	if(has_buckled_mobs())
		for(var/mob/living/buckled_mob as anything in buckled_mobs)
			buckled_mob.setDir(dir)
		handle_offsets()

/obj/structure/stationary_machinegun/proc/handle_layer()
	if(has_buckled_mobs() && dir == SOUTH)
		layer = ABOVE_MOB_LAYER
	else
		layer = initial(layer)

/obj/structure/stationary_machinegun/mouse_drop_dragged(atom/over_object, mob/user, src_location, over_location, params)
	if(over_object != user || !ishuman(user) || !item || has_buckled_mobs() || !allow_move)
		return

	user.visible_message(
		span_notice("[user] grabs [src]."),
		span_notice("You grab [src]."),
	)

	item.forceMove(drop_location())
	transfer_fingerprints_to(item)
	user.put_in_hands(item, ignore_anim = FALSE)
	src.anchored = FALSE
	src.forceMove(item)

/obj/structure/stationary_machinegun/post_buckle_mob(mob/living/target)
	. = ..()
	internal_gun.forceMove(drop_location())
	if(!target.put_in_hands(internal_gun, ignore_anim = TRUE))
		internal_gun.forceMove(src)
		unbuckle_mob(target)
		return

	handle_layer()
	handle_offsets()
	ADD_TRAIT(internal_gun, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)

/obj/structure/stationary_machinegun/post_unbuckle_mob(mob/living/target)
	. = ..()
	handle_layer()
	target.remove_offsets(TURRET_SOURCE)
	REMOVE_TRAIT(internal_gun, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)
	target.drop_item_ground(internal_gun)
	internal_gun.forceMove(src)

/obj/structure/stationary_machinegun/proc/handle_offsets()
	for(var/mob/living/buckled_mob in buckled_mobs)
		switch(dir)
			if(EAST)
				buckled_mob.add_offsets(TURRET_SOURCE, x_add = -offset_x)
			if(WEST)
				buckled_mob.add_offsets(TURRET_SOURCE, x_add = offset_x)
			else
				buckled_mob.remove_offsets(TURRET_SOURCE)


// MARK: Item
/obj/item/stationary_machinegun
	name = "stationary machinegun"
	desc = "Тренога со стационарным пулеметом. Необходимо установить чтобы встать за него."
	icon = 'icons/obj/weapons/stationary.dmi'
	icon_state = "pkmp"
	item_state = "folded_chair"
	lefthand_file = 'icons/mob/inhands/chairs_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/chairs_righthand.dmi'
	w_class = WEIGHT_CLASS_HUGE
	force = 12
	throwforce = 15
	throw_range = 2
	hitsound = 'sound/items/trayhit1.ogg'
	hit_reaction_chance = 15
	materials = list(MAT_METAL = 5000)
	var/break_chance = 5 //Likely hood of smashing the chair.
	var/obj/structure/stationary_machinegun/origin = /obj/structure/stationary_machinegun

/obj/item/stationary_machinegun/get_ru_names()
	return list(
		NOMINATIVE = "станковый пулемет",
		GENITIVE = "станкового пулемета",
		DATIVE = "станковому пулемету",
		ACCUSATIVE = "станковый пулемет",
		INSTRUMENTAL = "станковым пулеметом",
		PREPOSITIONAL = "станковом пулемете",
	)

/obj/item/stationary_machinegun/attack_self(mob/user)
	plant(user)

/obj/item/stationary_machinegun/proc/plant(mob/user)
	if(QDELETED(src))
		return
	var/turf/location = get_turf(loc)
	if(density || isopenspaceturf(location))
		to_chat(user, span_warning("Вам нужен пол чтобы установить стационарный пулемет!"))
		return

	for(var/obj/other_obj in get_turf(location))
		if(istype(other_obj, /obj/structure/stationary_machinegun))
			to_chat(user, span_danger("Здесь уже установлен другой пулемет!"))
			return

	user.visible_message(span_notice("[user] устанавливает [declent_ru(NOMINATIVE)]."), span_notice("Вы установили [declent_ru(NOMINATIVE)]."))
	if(ispath(origin))
		origin = new origin(src)
	var/obj/structure/stationary_machinegun/machinegun = origin
	machinegun.forceMove(get_turf(loc))
	machinegun.anchored = TRUE
	transfer_fingerprints_to(machinegun)
	machinegun.setDir(user.dir)
	user.drop_item_ground(src)
	src.forceMove(machinegun)


#undef TURRET_SOURCE
