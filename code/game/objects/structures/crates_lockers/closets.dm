GLOBAL_LIST_EMPTY(closets)

/obj/structure/closet
	name = "closet"
	desc = "It's a basic storage unit."
	gender = MALE
	icon = 'icons/obj/closet.dmi'
	icon_state = "closed"
	density = TRUE
	layer = LOW_ITEM_LAYER	//Prevents items from dropping on turf visually
	max_integrity = 200
	integrity_failure = 50
	armor = list(MELEE = 20, BULLET = 10, LASER = 10, ENERGY = 0, BOMB = 10, BIO = 0, FIRE = 70, ACID = 60)
	pass_flags_self = PASSSTRUCTURE | LETPASSCLICKS

	/// Special marker for the closet to use default icon_closed/icon_opened states, skipping everything else.
	var/no_overlays = FALSE
	var/icon_closed = "closed" //stays here for compatibility issues
	var/icon_opened = "open"

	//following overlays are used by default for states, override if necessary
	var/overlay_sparking = "sparking"
	var/overlay_unlocked = "unlocked"
	var/overlay_locked = "locked"
	var/overlay_locker = null // TODO: 'locker'less closet sprites.
	var/custom_door_overlay = null //handles overlay of door looking into screen
	var/custom_open_overlay = null //handles overlay of opened door (its inner side)

	var/ignore_density_closed = FALSE
	var/opened = FALSE
	var/welded = FALSE
	var/locked = FALSE
	var/anchorable = TRUE
	/// secure locker or not, also used if overriding a non-secure locker with a secure door overlay to add fancy lights
	var/secure = FALSE
	//Time to breakout
	var/breakout_time = 2 MINUTES
	var/large = TRUE
	var/can_be_emaged = FALSE
	var/can_weld_shut = TRUE
	var/wall_mounted = FALSE //never solid (You can always pass over it)
	var/lastbang
	var/open_sound = 'sound/machines/closet_open.ogg'
	var/close_sound = 'sound/machines/closet_close.ogg'
	var/open_sound_volume = 35
	var/close_sound_volume = 50
	var/sparking_duration = 1 SECONDS
	var/storage_capacity = 30 //This is so that someone can't pack hundreds of items in a locker/crate then open it in a populated area to crash clients.
	var/mob_storage_capacity //if null, than not limited
	var/material_drop = /obj/item/stack/sheet/metal
	var/material_drop_amount = 2
	var/ignore_shoves = FALSE
	var/no_throw_opens = FALSE
	COOLDOWN_DECLARE(message_cd)
	var/dense_when_open = FALSE //if it's dense when open or not

	/// How many pixels the closet can shift on the x axis when shaking
	var/x_shake_pixel_shift = 2
	/// how many pixels the closet can shift on the y axes when shaking
	var/y_shake_pixel_shift = 1


// Please dont override this unless you absolutely have to
/obj/structure/closet/Initialize(mapload)
	. = ..()
	GLOB.closets += src
	if(mapload && !opened)
		// Youre probably asking, why is this a 0 seconds timer AA?
		// Well, I will tell you. One day, all /obj/effect/spawner will use Initialize
		// This includes maint loot spawners. The problem with that is if a closet loads before a spawner,
		// the loot will just be in a pile. Adding a timer with 0 delay will cause it to only take in contents once the MC has loaded,
		// therefore solving the issue on mapload. During rounds, everything will happen as normal
		END_OF_TICK(CALLBACK(src, PROC_REF(take_contents)))
	update_icon() // Set it to the right icon if needed
	populate_contents()
	register_context()

/obj/structure/closet/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	var/screentip_change = FALSE

	if(isnull(held_item))
		if(!welded)
			context[SCREENTIP_CONTEXT_LMB] = opened ? "Close" : "Open"
			context[SCREENTIP_CONTEXT_RMB] = opened ? "Close" : "Open"
		if(secure && !broken)
			if(opened)
				context[SCREENTIP_CONTEXT_RMB] = "Close"
			else
				context[SCREENTIP_CONTEXT_RMB] = !locked ? "Lock" : "Unlock"
				if(locked)
					context[SCREENTIP_CONTEXT_LMB] = "Unlock"
		screentip_change = TRUE
	if(secure && !opened && is_id_card(held_item))
		context[SCREENTIP_CONTEXT_LMB] = !locked ? "Lock" : "Unlock"
		context[SCREENTIP_CONTEXT_RMB] = !locked ? "Lock" : "Unlock"
		screentip_change = TRUE

	if(iswelder(held_item))
		if(opened)
			context[SCREENTIP_CONTEXT_LMB] = "Deconstruct"
			screentip_change = TRUE
		else
			if(!welded && can_weld_shut)
				context[SCREENTIP_CONTEXT_LMB] = "Weld"
				screentip_change = TRUE
			else if(welded)
				context[SCREENTIP_CONTEXT_LMB] = "Unweld"
				screentip_change = TRUE

	if(istype(held_item) && held_item.tool_behaviour == TOOL_WRENCH && anchorable)
		context[SCREENTIP_CONTEXT_RMB] = anchored ? "Unanchor" : "Anchor"
		screentip_change = TRUE

	return screentip_change ? CONTEXTUAL_SCREENTIP_SET : NONE

/obj/structure/closet/examine(mob/user)
	. = ..()
	if(can_weld_shut && !welded)
		. += span_notice("It can be [EXAMINE_HINT("welded")] shut.")
	if(welded)
		. += span_notice("It's [EXAMINE_HINT("welded")] shut.")
	if(anchorable && !anchored)
		. += span_notice("It can be [EXAMINE_HINT("bolted")] to the ground.")
	if(anchored)
		. += span_notice("It's [anchorable ? EXAMINE_HINT("bolted") : "attached firmly"] to the ground.")

// Override this to spawn your things in. This lets you use probabilities, and also doesnt cause init overrides
/obj/structure/closet/proc/populate_contents()
	return

// This is called on Initialize to add contents on the tile
/obj/structure/closet/proc/take_contents()
	var/atom/location = drop_location()
	if(!location)
		return
	var/itemcount = 0
	for(var/obj/item/item in location)
		if(item.density || item.anchored || item == src)
			continue
		item.forceMove(src)
		// Ensure the storage cap is respected
		if(++itemcount >= storage_capacity)
			break

// Fix for #383 - C4 deleting fridges with corpses
/obj/structure/closet/Destroy(force)
	GLOB.closets -= src
	if(force)
		for(var/atom/movable/thing in contents)
			qdel(thing, force)

		return ..()

	dump_contents()
	return ..()

/obj/structure/closet/vv_edit_var(vname, vval)
	if(vname == NAMEOF(src, opened))
		if(vval == opened)
			return FALSE
		if(vval && !opened && open())
			datum_flags |= DF_VAR_EDITED
			return TRUE
		else if(!vval && opened && close())
			datum_flags |= DF_VAR_EDITED
			return TRUE
		return FALSE
	. = ..()
	if(vname == NAMEOF(src, welded) && welded && !can_weld_shut)
		can_weld_shut = TRUE
	else if(vname == NAMEOF(src, can_weld_shut) && !can_weld_shut && welded)
		welded = FALSE
		update_appearance()
	if(vname in list(NAMEOF(src, locked), NAMEOF(src, welded), NAMEOF(src, secure)))
		update_appearance()

/obj/structure/closet/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(wall_mounted)
		return TRUE

/obj/structure/closet/proc/can_open(mob/living/user, force = FALSE)
	if(force)
		return TRUE
	if(welded || locked)
		return FALSE
	if(isliving(user))
		if(!(user.mobility_flags & MOBILITY_USE))
			return FALSE
	var/turf/current_turf = get_turf(src)
	for(var/mob/living/user_living in current_turf)
		if(user_living.anchored || IS_HORIZONTAL(user_living) && user_living.mob_size > MOB_SIZE_TINY && user_living.density)
			if(user)
				to_chat(user, span_danger("There's something large on top of [src], preventing it from opening."))
			return FALSE
	return TRUE

/obj/structure/closet/proc/can_close(mob/living/user)
	var/turf/current_turf = get_turf(src)
	for(var/obj/structure/closet/closet in current_turf)
		if(closet != src && !closet.wall_mounted)
			if(user)
				balloon_alert(user, "[closet.name] is in the way!")
			return FALSE
	for(var/mob/living/user_living in current_turf)
		if(user_living.anchored || IS_HORIZONTAL(user_living) && user_living.mob_size > MOB_SIZE_TINY && user_living.density)
			if(user)
				to_chat(user, span_danger("There's something too large in [src], preventing it from closing."))
			return FALSE
	return TRUE

/obj/structure/closet/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()

	if(no_throw_opens)
		return

	if(iswallturf(hit_atom) && prob(20))
		open()

/obj/structure/closet/proc/dump_contents()
	var/atom/drop_spot = drop_location()
	for(var/atom/movable/item in src)
		item.forceMove(drop_spot)
		if(throwing) // you keep some momentum when getting out of a thrown closet
			step(item, dir)
	if(throwing)
		throwing.finalize()

///Proc to write checks before opening a door
/obj/structure/closet/proc/before_open(mob/living/user, force)
	return TRUE

/obj/structure/closet/proc/open(mob/living/user, force = FALSE)
	if(opened || !can_open(user, force))
		return FALSE

	if(!before_open(user, force))
		return FALSE
	welded = FALSE
	unlock()
	if(open_sound)
		playsound(loc, open_sound, open_sound_volume, TRUE, -3)
	else
		playsound(loc, 'sound/machines/click.ogg', open_sound_volume, TRUE, -3)
	opened = TRUE
	if(!dense_when_open)
		set_density(FALSE)
	dump_contents()
	update_appearance()
	after_open(user, force)
	return TRUE

/obj/structure/closet/set_opened()
	open()

///Proc to override for effects after opening a door
/obj/structure/closet/proc/after_open(mob/living/user, force = FALSE)
	return

///Proc to write checks before closing a door
/obj/structure/closet/proc/before_close(mob/living/user)
	return TRUE

/obj/structure/closet/proc/close(mob/living/user)
	if(!opened || !can_close(user))
		return FALSE

	if(!before_close(user))
		return FALSE

	var/itemcount = 0
	var/mobcount = 0

	//Cham Projector Exception
	for(var/obj/effect/dummy/chameleon/AD in loc)
		if(itemcount >= storage_capacity)
			break
		AD.forceMove(src)
		itemcount++

	for(var/obj/item/I in loc)
		if(itemcount >= storage_capacity)
			break
		if(!I.anchored && I.can_put_in_closet)
			I.forceMove(src)
			itemcount++

	for(var/mob/M in loc)
		if(itemcount >= storage_capacity)
			break
		if(!isnull(mob_storage_capacity) && (mobcount >= mob_storage_capacity))
			break
		if(isobserver(M))
			continue
		if(istype(M, /mob/living/simple_animal/bot/mulebot))
			continue
		if(ismegafauna(M))
			continue
		if(M.buckled || M.anchored || M.has_buckled_mobs())
			continue
		if(isAI(M))
			continue

		M.forceMove(src)
		itemcount++
		mobcount++

	opened = FALSE
	set_density(ignore_density_closed ? FALSE : TRUE)
	update_appearance()
	after_close(user)
	if(close_sound)
		playsound(loc, close_sound, close_sound_volume, TRUE, -3)
	else
		playsound(loc, 'sound/machines/click.ogg', close_sound_volume, TRUE, -3)
	return TRUE

///Proc to do effects after closet has closed
/obj/structure/closet/proc/after_close(mob/living/user)
	return

/obj/structure/closet/set_closed()
	close()

/**
 * Toggles a closet open or closed, to the opposite state. Does not respect locked or welded states, however.
 */
/obj/structure/closet/proc/toggle(mob/living/user)
	if(opened)
		return close(user)
	else
		return open(user)

/obj/structure/closet/deconstruct(disassembled = TRUE)
	if(ispath(material_drop) && material_drop_amount && !(obj_flags & NODECONSTRUCT))
		new material_drop(loc, material_drop_amount)
	qdel(src)

/obj/structure/closet/obj_break(damage_flag)
	if(!broken && !(obj_flags & NODECONSTRUCT))
		bust_open()

/obj/structure/closet/grab_attack(mob/living/grabber, atom/movable/grabbed_thing)
	mouse_drop_receive(grabbed_thing, grabber)	//act like they were dragged onto the closet
	return TRUE

/obj/structure/closet/attackby(obj/item/I, mob/user, params)
	if(opened)
		if(user.a_intent == INTENT_HARM || (I.item_flags & ABSTRACT) || I.is_robot_module())
			return ..()
		if(!user.drop_transfer_item_to_loc(I, loc)) //couldn't drop the item
			return ..()
		add_fingerprint(user)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/rcs))
		var/obj/item/rcs/rcs = I
		add_fingerprint(user)
		rcs.try_send_container(user, src)
		return ATTACK_CHAIN_BLOCKED_ALL

	var/is_emag = istype(I, /obj/item/card/emag)
	if(is_emag || istype(I, /obj/item/melee/energy/blade))
		add_fingerprint(user)
		if(!can_be_emaged || broken)
			var/add_flags = NONE
			if(is_emag)
				add_flags |= ATTACK_CHAIN_NO_AFTERATTACK
			return ..() | add_flags
		emag_act(user)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/stack/packageWrap))
		return ATTACK_CHAIN_PROCEED	// afterattack handles it

	if(user.a_intent != INTENT_HARM)
		closed_item_click(user)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()

/obj/structure/closet/proc/togglelock(mob/living/user)
	if(!istype(user))
		return
	if(user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		balloon_alert(user, "невозможно!")
		return
	if(opened)
		balloon_alert(user, "нужно закрыть!")
		return
	if(broken)
		balloon_alert(user, "сломано!")
		return
	if(user.loc == src)
		balloon_alert(user, "невозможно изнутри!")
		return
	if(allowed(user))
		locked = !locked
		playsound(loc, SFX_CLOSET_TOGGLE_LOCK, 15, TRUE, -3)
		balloon_alert_to_viewers("[locked ? "за" : "от"]крыва[PLUR_ET_YUT(user)] замок", "замок [locked ? "за" : "от"]крыт")
		update_icon()
	else
		balloon_alert(user, "нет доступа!")
	if(iscarbon(user))
		add_fingerprint(user)
	update_appearance()
	return TRUE

// What happens when the closet is attacked by a random item not on harm mode
/obj/structure/closet/proc/closed_item_click(mob/user)
	attack_hand(user)

/obj/structure/closet/welder_act(mob/user, obj/item/I)
	. = TRUE
	if(!opened && user.loc == src)
		to_chat(user, span_warning("You can't weld [src] from inside!"))
		return
	if(!I.tool_use_check(user, 0))
		return
	if(opened)
		WELDER_ATTEMPT_SLICING_MESSAGE
		if(I.use_tool(src, user, 40, volume = I.tool_volume))
			WELDER_SLICING_SUCCESS_MESSAGE
			deconstruct(TRUE)
			return
	else
		if(!can_weld_shut)
			return
		var/adjective = welded ? "open" : "shut"
		user.visible_message(
			span_notice("[user] begins welding [src] [adjective]..."),
			span_notice("You begin welding [src] [adjective]..."),
			span_warning("You hear welding.")
		)
		if(I.use_tool(src, user, 15, volume = I.tool_volume))
			if(opened)
				to_chat(user, span_notice("Keep [src] shut while doing that!"))
				return
			user.visible_message(
				span_notice("[user] welds [src] [adjective]!"),
				span_notice("You weld [src] [adjective]!")
			)
			welded = !welded
			update_icon()

/obj/structure/closet/mouse_drop_receive(atom/movable/target_movable, mob/living/user, params)
	if(!istype(target_movable) || target_movable.anchored || is_screen_atom(target_movable))
		return
	if(user == target_movable) //try to climb onto it
		return ..()
	if(!opened)
		return
	if(!isturf(target_movable.loc))
		return
	if(user.pulling == target_movable)
		user.stop_pulling()

	var/actually_is_mob = FALSE
	if(isliving(target_movable))
		actually_is_mob = TRUE
	else if(!isitem(target_movable))
		return
	var/turf/current_turf = get_turf(src)
	add_fingerprint(user)
	user.visible_message(
		span_warning("[user] [actually_is_mob ? "tries to ":""]stuff [target_movable] into [src]."),
		span_warning("You [actually_is_mob ? "try to ":""]stuff [target_movable] into [src]."),
		span_hear("You hear clanging."),
	)
	if(actually_is_mob)
		if(do_after(user, 4 SECONDS, target_movable))
			user.visible_message(
				span_notice("[user] stuffs [target_movable] into [src]."),
				span_notice("You stuff [target_movable] into [src]."),
				span_hear("You hear a loud metal bang."),
			)
			var/mob/living/target_living = target_movable
			if(!issilicon(target_living))
				target_living.Paralyse(40)
			if(istype(src, /obj/structure/closet/supplypod/extractionpod))
				target_movable.forceMove(src)
			else
				target_movable.forceMove(current_turf)
				close()
			add_attack_logs(user, target_movable, "stuffed inside of [src]", ATKLOG_ALMOSTALL)
	else
		target_movable.forceMove(current_turf)

/obj/structure/closet/wrench_act_secondary(mob/living/user, obj/item/tool)
	if(!anchorable)
		balloon_alert(user, "no anchor bolts!")
		return TRUE
	if(isinspace() && !anchored) // We want to prevent anchoring a locker in space, but we should still be able to unanchor it there
		balloon_alert(user, "nothing to anchor to!")
		return TRUE
	default_unfasten_wrench(user, tool, 5 SECONDS)
	tool.play_tool_sound(src, 75)
	user.balloon_alert_to_viewers("[anchored ? "anchored" : "unanchored"]")
	return TRUE

/obj/structure/closet/relaymove(mob/living/user, direction)
	if(user.stat || !isturf(loc))
		return
	if(locked)
		if(COOLDOWN_FINISHED(src, message_cd))
			COOLDOWN_START(src, message_cd, 5 SECONDS)
			to_chat(user, span_warning("[src]'s door won't budge!"))
		return
	container_resist_act(user)

/obj/structure/closet/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return

	if(user.body_position == LYING_DOWN && get_dist(src, user) > 0)
		return

	if(toggle(user))
		return TRUE

	if(!opened)
		return togglelock(user)

/obj/structure/closet/attack_ghost(mob/user)
	if(user.can_advanced_admin_interact())
		toggle(user)

/obj/structure/closet/attack_robot(mob/user)
	if(user.Adjacent(src))
		return attack_hand(user)

/obj/structure/closet/attack_ai(mob/user)
	if(isrobot(user) && Adjacent(user)) //Robots can open/close it, but not the AI
		attack_hand(user)

/obj/structure/closet/attack_robot_secondary(mob/user, list/modifiers)
	if(!user.Adjacent(src))
		return SECONDARY_ATTACK_CONTINUE_CHAIN
	togglelock(user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

// tk grab then use on self
/obj/structure/closet/attack_self_tk(mob/user)
	add_fingerprint(user)
	toggle()

/obj/structure/closet/verb/verb_toggleopen()
	set src in oview(1)
	set name = "Toggle Open"

	if(usr.incapacitated() || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED))
		return

	if(ishuman(usr) || isrobot(usr) || istype(usr, /mob/living/simple_animal/hostile/gorilla))
		add_fingerprint(usr)
		toggle(usr)
	else
		to_chat(usr, span_warning("This mob type can't use this verb."))

/obj/structure/closet/update_icon(updates = ALL)
	if(no_overlays)
		return ..(UPDATE_ICON_STATE)
	return ..()

/obj/structure/closet/update_icon_state()
	if(no_overlays)
		icon_state = opened ? icon_opened : icon_closed

/obj/structure/closet/update_overlays()
	. = ..()
	if(opened)
		if(custom_open_overlay)
			. += mutable_appearance(icon, "[custom_open_overlay]_open", CLOSET_OLAY_LAYER_DOOR)
		else
			. += mutable_appearance(icon, "[icon_state]_open", CLOSET_OLAY_LAYER_DOOR)
	else
		for(var/olay in apply_contents_overlays())
			. += olay
		if(custom_door_overlay)
			. += mutable_appearance(icon, "[custom_door_overlay]_door", CLOSET_OLAY_LAYER_DOOR)
		else
			. += mutable_appearance(icon, "[icon_state]_door", CLOSET_OLAY_LAYER_DOOR)
		if(welded)
			. += mutable_appearance(icon, "welded", CLOSET_OLAY_LAYER_WELDED)

/**
 * Additional overlays for contents inside the closet. Usefull when the door is transparent.
 */
/obj/structure/closet/proc/apply_contents_overlays()
	RETURN_TYPE(/list)
	. = list()

// Objects that try to exit a locker by stepping were doing so successfully,
// and due to an oversight in turf/Enter() were going through walls.  That
// should be independently resolved, but this is also an interesting twist.
/obj/structure/closet/Exit(atom/movable/leaving, atom/newLoc)
	open()
	if(leaving.loc == src)
		return FALSE
	return TRUE

/obj/structure/closet/container_resist_act(mob/living/user, loc_required = TRUE)
	if(opened)
		return
	if(ismovable(loc))
		user.changeNext_move(CLICK_CD_BREAKOUT)
		user.last_special = world.time + CLICK_CD_BREAKOUT
		var/atom/movable/movable_parent = loc
		movable_parent.relay_container_resist_act(user, src)
		return
	if(!welded && !locked)
		open(user)
		return

	if(DOING_INTERACTION_WITH_TARGET(user, src))
		return
	//okay, so the closet is either welded or locked... resist!!!
	user.changeNext_move(CLICK_CD_BREAKOUT)
	user.last_special = world.time + CLICK_CD_BREAKOUT
	user.visible_message(
		span_warning("[src] begins to shake violently!"),
		span_notice("You lean on the back of [src] and start pushing the door open... (this will take about [DisplayTimeText(breakout_time)].)"),
		span_hear("You hear banging from [src]."),
	)

	addtimer(CALLBACK(src, PROC_REF(check_if_shake)), 1 SECONDS)

	if(do_after(user,(breakout_time), target = src))
		if(!user || user.stat != CONSCIOUS || (loc_required && (user.loc != src)) || opened || (!locked && !welded))
			return
		//we check after a while whether there is a point of resisting anymore and whether the user is capable of resisting
		user.visible_message(
			span_danger("[user] successfully broke out of [src]!"),
			span_notice("You successfully break out of [src]!"),
		)
		bust_open()
	else
		if(user.loc == src) //so we don't get the message if we resisted multiple times and succeeded.
			to_chat(user, span_warning("You fail to break out of [src]!"))

/obj/structure/closet/relay_container_resist_act(mob/living/user, obj/container)
	container_resist_act(user)

/// Check if someone is still resisting inside, and choose to either keep shaking or stop shaking the closet
/obj/structure/closet/proc/check_if_shake()
	// Assuming we decide to shake again, how long until we check to shake again
	var/next_check_time = 1 SECONDS

	// How long we shake between different calls of Shake(), so that it starts shaking and stops, instead of a steady shake
	var/shake_duration =  0.3 SECONDS

	for(var/mob/living/mob in contents)
		if(DOING_INTERACTION_WITH_TARGET(mob, src))
			// Shake and queue another check_if_shake
			Shake(x_shake_pixel_shift, y_shake_pixel_shift, shake_duration, shake_interval = 0.1 SECONDS)
			addtimer(CALLBACK(src, PROC_REF(check_if_shake)), next_check_time)
			return TRUE

	// If we reach here, nobody is resisting, so don't shake
	return FALSE

/obj/structure/closet/proc/bust_open()
	SIGNAL_HANDLER
	welded = FALSE //applies to all lockers
	unlock() //applies to critter crates and secure lockers only
	broken = TRUE //applies to secure lockers only
	open(force = TRUE)

/obj/structure/closet/attack_hand_secondary(mob/user, modifiers)
	. = ..()

	if(!user.can_perform_action(src) || !isturf(loc))
		return

	if(!opened && secure)
		togglelock(user)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/// toggles the lock state of a closet
/obj/structure/closet/proc/lock()
	if(locked)
		return
	locked = TRUE
	play_closet_lock_sound()
	update_appearance()

/// unlocks the closet
/obj/structure/closet/proc/unlock()
	if(!locked)
		return
	locked = FALSE
	play_closet_lock_sound()
	update_appearance()

/// plays the closet's lock/unlock sound, this should be placed AFTER you've changed the lock state
/obj/structure/closet/proc/play_closet_lock_sound()
	playsound(src, SFX_CLOSET_TOGGLE_LOCK, 50, TRUE)

/obj/structure/closet/get_remote_view_fullscreens(mob/user)
	if(user.stat == DEAD || !(user.sight & (SEEOBJS|SEEMOBS)))
		user.overlay_fullscreen("remote_view", /atom/movable/screen/fullscreen/impaired, 1)

/obj/structure/closet/ex_act(severity, target)
	contents_explosion()
	return ..()

/obj/structure/closet/proc/contents_explosion(severity, target)
	for(var/atom/target_atom in contents)
		target_atom.ex_act(severity, target)
		CHECK_TICK

/obj/structure/closet/singularity_act()
	dump_contents()
	..()

/obj/structure/closet/AllowDrop()
	return TRUE

/obj/structure/closet/force_eject_occupant(mob/target)
	// Its okay to silently teleport mobs out of lockers, since the only thing affected is their contents list.
	return

/obj/structure/closet/click_alt(mob/living/simple_animal/hostile/gorilla/gorilla)
	if(istype(gorilla))
		gorilla.face_atom(src)
		toggle()
		gorilla.oogaooga()
		return CLICK_ACTION_SUCCESS
	return ..()

/obj/structure/closet/shove_impact(mob/living/target, mob/living/attacker)
	if(ignore_shoves)
		return ..()

	if(opened && can_close())
		target.forceMove(src)
		visible_message(
			span_danger("[attacker] shoves [target] inside [src]!"),
			span_userdanger("You shove [target] inside [src]!"),
			span_warning("You hear a thud, and something clangs shut.")
		)
		close()
		add_attack_logs(attacker, target, "shoved into [src]")
		return TRUE

	if(locked && allowed(target))
		locked = !locked
		visible_message(span_danger("[attacker] shoves [target] against [src], knocking the lock [locked ? null : "un"]locked!"))
		target.Knockdown(3 SECONDS)
		playsound(loc, SFX_CLOSET_TOGGLE_LOCK, 15, TRUE, -3)
		update_icon()
		return TRUE

	if(!opened && can_open())
		open()
		visible_message(span_danger("[attacker] shoves [target] against [src], knocking it open!"))
		target.Knockdown(3 SECONDS)
		return TRUE

	return ..()
