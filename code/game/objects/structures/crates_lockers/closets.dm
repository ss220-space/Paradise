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
	pass_flags_self = PASSSTRUCTURE|LETPASSCLICKS
	interaction_flags_click = NEED_HANDS | ALLOW_RESTING

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

// Override this to spawn your things in. This lets you use probabilities, and also doesnt cause init overrides
/obj/structure/closet/proc/populate_contents()
	return

// This is called on Initialize to add contents on the tile
/obj/structure/closet/proc/take_contents()
	var/itemcount = 0
	for(var/obj/item/I in loc)
		if(I.density || I.anchored || I == src)
			continue
		I.forceMove(src)
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
	if(vname in list(NAMEOF(src, locked), NAMEOF(src, welded)))
		update_appearance()

/obj/structure/closet/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(wall_mounted)
		return TRUE

/obj/structure/closet/proc/can_open()
	if(welded)
		return FALSE
	return TRUE

/obj/structure/closet/proc/can_close()
	for(var/obj/structure/closet/closet in get_turf(src))
		if(closet != src && closet.anchored != 1)
			return FALSE

	return TRUE

/obj/structure/closet/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()

	if(no_throw_opens)
		return

	if(iswallturf(hit_atom) && prob(20))
		open()

/obj/structure/closet/proc/dump_contents()
	var/atom/L = drop_location()
	for(var/atom/movable/AM in src)
		AM.forceMove(L)
		if(throwing) // you keep some momentum when getting out of a thrown closet
			step(AM, dir)
	if(throwing)
		throwing.finalize()

/obj/structure/closet/proc/before_open()
	return TRUE

/obj/structure/closet/proc/open()
	if(opened || !can_open())
		return FALSE

	if(!before_open())
		return FALSE

	dump_contents()

	opened = TRUE
	update_icon()
	if(open_sound)
		playsound(loc, open_sound, open_sound_volume, TRUE, -3)
	else
		playsound(loc, 'sound/machines/click.ogg', open_sound_volume, TRUE, -3)
	set_density(FALSE)
	after_open()
	return TRUE

/obj/structure/closet/setOpened()
	open()

///Proc to override for effects after opening a door
/obj/structure/closet/proc/after_open(mob/living/user, force = FALSE)
	return

/obj/structure/closet/proc/close()
	if(!opened || !can_close())
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
	update_icon()
	if(close_sound)
		playsound(loc, close_sound, close_sound_volume, TRUE, -3)
	else
		playsound(loc, 'sound/machines/click.ogg', close_sound_volume, TRUE, -3)
	set_density(ignore_density_closed ? FALSE : TRUE)
	return TRUE

/obj/structure/closet/setClosed()
	close()

/obj/structure/closet/proc/toggle(mob/user, by_hand = FALSE)
	if(!(opened ? close() : open(by_hand)))
		to_chat(user, span_notice("It won't budge!"))
		return FALSE

	return TRUE

/obj/structure/closet/proc/bust_open()
	welded = FALSE //applies to all lockers
	locked = FALSE //applies to critter crates and secure lockers only
	broken = TRUE //applies to secure lockers only
	open()

/obj/structure/closet/deconstruct(disassembled = TRUE)
	if(ispath(material_drop) && material_drop_amount && !(obj_flags & NODECONSTRUCT))
		new material_drop(loc, material_drop_amount)
	qdel(src)

/obj/structure/closet/obj_break(damage_flag)
	if(!broken && !(obj_flags & NODECONSTRUCT))
		bust_open()

/obj/structure/closet/grab_attack(mob/living/grabber, atom/movable/grabbed_thing)
	. = TRUE
	MouseDrop_T(grabbed_thing, grabber)	//act like they were dragged onto the closet

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
		balloon_alert_to_viewers("[locked ? "за" : "от"]крыва[PLUR_ET_UT(user)] замок", "замок [locked ? "за" : "от"]крыт")
		update_icon()
	else
		balloon_alert(user, "нет доступа!")
	add_fingerprint(user)

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

/obj/structure/closet/MouseDrop_T(atom/movable/O, mob/living/user, params)
	. = ..()
	if(is_screen_atom(O))	//fix for HUD elements making their way into the world	-Pete
		return
	if(O.loc == user)
		return
	if(user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return
	if((!( istype(O, /atom/movable)) || O.anchored || get_dist(user, src) > 1 || get_dist(user, O) > 1 || user.contents.Find(src)))
		return
	if(user.loc==null) // just in case someone manages to get a closet into the blue light dimension, as unlikely as that seems
		return
	if(!isturf(user.loc)) // are you in a container/closet/pod/etc?
		return
	if(!opened)
		return
	if(iscloset(O))
		return
	if(user.pulling == O)
		user.stop_pulling()
	step_towards(O, loc)
	if(user != O)
		user.visible_message(
			span_danger("[user] stuffs [O] into [src]!"),
			span_danger("You stuff [O] into [src]!")
		)
	add_fingerprint(user)
	return TRUE

/obj/structure/closet/attack_ai(mob/user)
	if(isrobot(user) && Adjacent(user)) //Robots can open/close it, but not the AI
		attack_hand(user)

/obj/structure/closet/relaymove(mob/user)
	if(user.stat || !isturf(loc))
		return

	if(!open())
		to_chat(user, span_notice("It won't budge!"))
		if(!lastbang)
			lastbang = 1
			for(var/mob/M in hearers(src, null))
				to_chat(M, "<span style='font-size: [max(0, 5 - get_dist(src, M))];'>BANG, bang!</span>")
			spawn(30)
				lastbang = 0

/obj/structure/closet/attack_hand(mob/user)
	add_fingerprint(user)
	toggle(user)

/obj/structure/closet/attack_ghost(mob/user)
	if(user.can_advanced_admin_interact())
		toggle(user)

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

/obj/structure/closet/container_resist(mob/living/user)
	if(opened)
		if(user.loc == src)
			user.forceMove(get_turf(src)) // Let's just be safe here
		return //Door's open... wait, why are you in it's contents then?
	if(!welded)
		if(isobj(loc))
			var/obj/loc_as_obj = loc
			loc_as_obj.container_resist(user)
			return
		open() //for cardboard boxes
		return //closed but not welded...

	//okay, so the closet is either welded or locked... resist!!!

	user.changeNext_move(CLICK_CD_BREAKOUT)
	user.last_special = world.time + CLICK_CD_BREAKOUT
	balloon_alert_to_viewers("начинает трястись!", "вы сопротивляетесь!")

	spawn(0)
		if(do_after(user, breakout_time, src))
			if(!src || !user || user.stat != CONSCIOUS || user.loc != src || opened) //closet/user destroyed OR user dead/unconcious OR user no longer in closet OR closet opened
				return

			//Perform the same set of checks as above for weld and lock status to determine if there is even still a point in 'resisting'...
			if(!welded)
				return

			//Well then break it!
			welded = FALSE
			update_icon()
			user.visible_message(
				span_danger("[user.declent_ru(NOMINATIVE)] успешно выбира[PLUR_ET_UT(user)]ся из [declent_ru(GENITIVE)]!"),
				span_notice("Вы успешно выбираетесь из [declent_ru(GENITIVE)]!")
			)
			if(istype(loc, /obj/structure/bigDelivery)) //nullspace ect.. read the comment above
				var/obj/structure/bigDelivery/BD = loc
				BD.attack_hand(user)
			if(isobj(loc))
				var/obj/loc_as_obj = loc
				loc_as_obj.container_resist(user)
			open()

/obj/structure/closet/get_remote_view_fullscreens(mob/user)
	if(user.stat == DEAD || !(user.sight & (SEEOBJS|SEEMOBS)))
		user.overlay_fullscreen("remote_view", /atom/movable/screen/fullscreen/impaired, 1)

/obj/structure/closet/ex_act(severity, target)
	contents_explosion()
	return ..()

/obj/structure/closet/proc/contents_explosion(severity, target)
	for(var/atom/A in contents)
		A.ex_act(severity, target)
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
