/* Morgue stuff
 * Contains:
 *		Morgue
 *		Morgue trays
 *		Creamatorium
 *		Creamatorium trays
 */

/*
 * Morgue
 */

#define EXTENDED_TRAY "extended"
#define EMPTY_MORGUE "empty"
#define UNREVIVABLE "unrevivable"
#define REVIVABLE "revivable"
#define NOT_BODY "notbody"
#define GHOST_CONNECTED "ghost"

/obj/structure/morgue
	name = "morgue"
	desc = "Used to keep bodies in until someone fetches them."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "morgue"
	density = TRUE
	max_integrity = 400
	dir = EAST
	anchored = TRUE
	var/obj/structure/m_tray/connected
	var/static/status_descriptors = list(
		EXTENDED_TRAY = "The tray is currently extended.",
		EMPTY_MORGUE = "The tray is currently empty.",
		UNREVIVABLE = "The tray contains an unviable body.",
		REVIVABLE = "The tray contains a body that is responsive to revival techniques.",
		NOT_BODY = "The tray contains something that is not a body.",
		GHOST_CONNECTED = "The tray contains a body that might be responsive.",
	)
	var/toggle_sound = 'sound/items/deconstruct.ogg'
	var/status


/obj/structure/morgue/Initialize(mapload)
	. = ..()
	update_state()


/obj/structure/morgue/Destroy()
	if(!connected)
		var/turf/move_to = loc
		for(var/atom/movable/check in src)
			check.forceMove(move_to)
	else
		QDEL_NULL(connected)
	return ..()


/obj/structure/morgue/proc/get_revivable(closing = FALSE)
	var/mob/living/mob_check = locate() in contents
	var/obj/structure/closet/body_bag/body_bag = locate() in contents

	if(!mob_check)
		mob_check = locate() in body_bag

	if(!mob_check)
		return

	if(closing)
		RegisterSignal(mob_check, COMSIG_LIVING_GHOSTIZED, PROC_REF(update_state))
		RegisterSignal(mob_check, COMSIG_LIVING_REENTERED_BODY, PROC_REF(update_state))
		RegisterSignal(mob_check, COMSIG_LIVING_SET_DNR, PROC_REF(update_state))
	else
		UnregisterSignal(mob_check, COMSIG_LIVING_GHOSTIZED)
		UnregisterSignal(mob_check, COMSIG_LIVING_REENTERED_BODY)
		UnregisterSignal(mob_check, COMSIG_LIVING_SET_DNR)


/obj/structure/morgue/proc/update_state()
	if(connected)
		status = EXTENDED_TRAY
		return update_icon(UPDATE_OVERLAYS)

	if(!length(contents))
		status = EMPTY_MORGUE
		return update_icon(UPDATE_OVERLAYS)

	var/mob/living/mob_check = locate() in contents
	var/obj/structure/closet/body_bag/body_bag = locate() in contents

	if(!mob_check)
		mob_check = locate() in body_bag

	if(!mob_check)
		status = NOT_BODY
		return update_icon(UPDATE_OVERLAYS)

	var/mob/dead/observer/ghosty = mob_check.get_ghost()

	if(mob_check.mind && !mob_check.mind.suicided && !mob_check.suiciding)
		if(mob_check.client)
			status = REVIVABLE
			return update_icon(UPDATE_OVERLAYS)

		if(ghosty?.client) //There is a ghost and it is connected to the server
			status = GHOST_CONNECTED
			return update_icon(UPDATE_OVERLAYS)

	status = UNREVIVABLE
	return update_icon(UPDATE_OVERLAYS)


/obj/structure/morgue/update_overlays()
	. = ..()
	underlays.Cut()

	if(!connected)
		. += "morgue_[status]"
		underlays += emissive_appearance(icon, "morgue_[status]", src)

	if(name != initial(name))
		. += "morgue_label"


/obj/structure/morgue/examine(mob/user)
	. = ..()
	. += "[status_descriptors[status]]"


/obj/structure/morgue/attackby(obj/item/I, mob/user, params)
	if(is_pen(I))
		var/rename = rename_interactive(user, I)
		if(!isnull(rename))
			update_icon(UPDATE_OVERLAYS)
		return ATTACK_CHAIN_PROCEED_SUCCESS
	return ..()


/obj/structure/morgue/wirecutter_act(mob/user, obj/item/I)
	if(name == initial(name))
		return FALSE

	. = TRUE

	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return .

	to_chat(user, span_notice("You cut the tag off the morgue."))
	name = initial(name)
	update_icon(UPDATE_OVERLAYS)


/obj/structure/morgue/attack_hand(mob/user)
	tray_toggle(user)


/obj/structure/morgue/proc/tray_toggle(mob/user)
	if(connected)
		for(var/atom/movable/check in connected.loc)
			if(check.anchored || check.move_resist == INFINITY)
				continue
			check.forceMove(src)

		get_revivable(closing = TRUE)
		playsound(loc, toggle_sound, 50, TRUE)
		QDEL_NULL(connected)
	else
		var/turf/check_turf = get_step(src, dir)
		var/desity_found = check_turf.density
		if(!desity_found)
			for(var/atom/movable/check in check_turf)
				if(check.density)
					desity_found = TRUE
					break
		if(desity_found)
			if(user)
				to_chat(user, span_warning("Tray location is blocked!"))
			return FALSE
		playsound(loc, toggle_sound, 50, TRUE)
		get_revivable(closing = FALSE)
		connect()

	if(user)
		add_fingerprint(user)
	update_state()
	return TRUE


/obj/structure/morgue/relaymove(mob/user)
	if(user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return
	tray_toggle(user)


/obj/structure/morgue/proc/connect()
	var/turf/target_turf = get_step(src, dir)

	connected = new /obj/structure/m_tray(target_turf)

	if(target_turf.contents.Find(connected))
		connected.morgue = src

		for(var/atom/movable/check in src)
			check.forceMove(connected.loc)

		connected.dir = dir
		return

	QDEL_NULL(connected)


/obj/structure/morgue/container_resist(mob/living/carbon/user)
	if(!iscarbon(user) || user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return

	to_chat(user, span_alert("You attempt to slide yourself out of [src]..."))
	attack_hand(user)


/obj/structure/morgue/get_remote_view_fullscreens(mob/user)
	if(user.stat == DEAD || !(user.sight & (SEEOBJS|SEEMOBS)))
		user.overlay_fullscreen("remote_view", /atom/movable/screen/fullscreen/impaired, 2)


/obj/structure/morgue/ex_act(severity)
	switch(severity)
		if(1)
			ex_act_effect(severity)
		if(2)
			ex_act_effect(severity, 50)
		if(3)
			ex_act_effect(severity, 5)


/obj/structure/morgue/proc/ex_act_effect(severity, probability = 100)
	if(!prob(probability))
		return
	for(var/atom/movable/check in src)
		check.forceMove(loc)
		check.ex_act(severity)
	qdel(src)


#undef EXTENDED_TRAY
#undef EMPTY_MORGUE
#undef UNREVIVABLE
#undef REVIVABLE
#undef NOT_BODY
#undef GHOST_CONNECTED


/*
 * Morgue tray
 */
/obj/structure/m_tray
	name = "morgue tray"
	desc = "Apply corpse before closing."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "morgue_tray"
	density = TRUE
	anchored = TRUE
	pass_flags_self = PASSTABLE|LETPASSTHROW
	layer = BELOW_OBJ_LAYER
	max_integrity = 350
	var/obj/structure/morgue/morgue


/obj/structure/m_tray/Destroy()
	if(morgue && morgue.connected == src)
		morgue.connected = null
	morgue = null
	return ..()


/obj/structure/m_tray/attack_hand(mob/user)
	morgue?.tray_toggle(user)


/obj/structure/m_tray/grab_attack(mob/living/grabber, atom/movable/grabbed_thing)
	. = TRUE
	if(grabber.grab_state < GRAB_AGGRESSIVE || !isliving(grabbed_thing))
		return .
	var/mob/living/target = grabbed_thing
	target.forceMove(loc)
	target.set_resting(TRUE, instant = TRUE)


/obj/structure/m_tray/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM || !user.drop_transfer_item_to_loc(I, loc))
		return ..()
	add_fingerprint(user)
	return ATTACK_CHAIN_BLOCKED_ALL


/obj/structure/m_tray/MouseDrop_T(atom/movable/dropping, mob/living/user, params)
	if((!istype(dropping) || dropping.anchored || get_dist(user, src) > 1 || get_dist(user, dropping) > 1 || user.contents.Find(src) || user.contents.Find(dropping)))
		return

	if(!ismob(dropping) && !istype(dropping, /obj/structure/closet/body_bag))
		return

	if(!ismob(user) || user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return

	if(isliving(dropping))
		var/mob/living/target = dropping
		target.set_resting(TRUE, instant = TRUE)

	dropping.forceMove(loc)

	if(user != dropping)
		user.visible_message(span_warning("[user] stuffs [dropping] into [src]!"))
	return TRUE


/obj/structure/m_tray/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(.)
		return TRUE
	if(locate(/obj/structure/table) in get_turf(mover))
		return TRUE


/obj/structure/m_tray/CanAStarPass(to_dir, datum/can_pass_info/pass_info)
	if(!density)
		return TRUE
	if(pass_info.pass_flags == PASSEVERYTHING || (pass_info.pass_flags & PASSTABLE))
		return TRUE
	return FALSE


/mob/proc/update_morgue()
	if(stat != DEAD)
		return

	var/obj/structure/morgue/morgue
	var/mob/living/creature = src
	var/mob/dead/observer/ghost = src

	if(istype(ghost) && ghost.can_reenter_corpse && ghost.mind) //We're a ghost, let's find our corpse
		creature = ghost.mind.current

	if(istype(creature)) //We found our corpse, is it inside a morgue?
		morgue = get(creature.loc, /obj/structure/morgue)
		if(morgue)
			morgue.update_icon(UPDATE_OVERLAYS)


/*
 * Crematorium
 */
GLOBAL_LIST_EMPTY(crematoriums)

/obj/machinery/crematorium
	name = "crematorium"
	desc = "A human incinerator. Works well on barbeque nights."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "crema"
	max_integrity = 1000
	anchored = TRUE
	density = TRUE
	req_access = list(ACCESS_CREMATORIUM)
	var/list/saved_contents
	var/obj/structure/c_tray/connected
	var/cremating = FALSE
	var/id = 1
	var/toggle_sound = 'sound/items/deconstruct.ogg'


/obj/machinery/crematorium/Initialize(mapload)
	. = ..()
	GLOB.crematoriums += src
	update_icon(UPDATE_OVERLAYS)


/obj/machinery/crematorium/Destroy()
	GLOB.crematoriums -= src
	remove_contents()
	return ..()


/obj/machinery/crematorium/obj_break(damage_flag)
	remove_contents()
	return ..()


/obj/machinery/crematorium/proc/remove_contents()
	if(connected)
		QDEL_NULL(connected)
	var/turf/source_turf = get_turf(src)
	for(var/atom/movable/target in src)
		target.forceMove(source_turf)


/obj/machinery/crematorium/examine(mob/user)
	. = ..()
	. += span_info("You can rotate [src] by using </b>wrench<b>.")


/obj/machinery/crematorium/update_overlays()
	. = ..()
	underlays.Cut()

	if(connected)
		return

	. += "crema_closed"

	if(cremating)
		. += "crema_active"
		underlays += emissive_appearance(icon, "crema_active_lightmask", src)
		return

	if(length(contents))
		. += "crema_full"


/obj/machinery/crematorium/attackby(obj/item/I, mob/user, params)
	if(is_pen(I))
		rename_interactive(user, I)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(cremating)
		flame_spread(user)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/machinery/crematorium/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	if(cremating)
		flame_spread(user)
		return .
	if(length(contents))
		to_chat(user, span_warning("You can not rotate [src] while its full!"))
		return .
	if(connected)
		to_chat(user, span_warning("You can not rotate [src] while its open!"))
		return .
	if(!I.use_tool(src, user, 3 SECONDS, volume = I.tool_volume) || cremating || length(contents) || connected)
		return .
	dir = turn(dir, 90)
	to_chat(user, span_notice("You rotate [src]."))


/obj/machinery/crematorium/proc/flame_spread(mob/living/user)
	if(!isliving(user))
		return
	visible_message(span_userdanger("The flame escapes from [src] and spreads to [user]!"))
	user.apply_damage(40, BURN, user.hand ? BODY_ZONE_L_ARM : BODY_ZONE_R_ARM)
	user.adjust_fire_stacks(20)
	user.IgniteMob()


/obj/machinery/crematorium/attack_ai(mob/user)
	return


/obj/machinery/crematorium/attack_hand(mob/user)
	tray_toggle(user)


/obj/machinery/crematorium/proc/tray_toggle(mob/user, skip_checks = FALSE)
	if(cremating)
		if(user)
			to_chat(user, span_warning("It's locked!"))
		return FALSE
	if(connected)
		for(var/atom/movable/check in connected.loc)
			if(!skip_checks && (check.anchored || check.move_resist == INFINITY || istype(check, /obj/effect/decal/cleanable/ash)))
				continue
			check.forceMove(src)

		playsound(loc, toggle_sound, 50, TRUE)
		QDEL_NULL(connected)
	else
		var/turf/check_turf = get_step(src, dir)
		var/desity_found = check_turf.density
		if(!skip_checks && !desity_found)
			for(var/atom/movable/check in check_turf)
				if(!skip_checks && check.density)
					desity_found = TRUE
					break
		if(!skip_checks && desity_found)
			if(user)
				to_chat(user, span_warning("Tray location is blocked!"))
			return FALSE
		playsound(loc, toggle_sound, 50, TRUE)
		connect()

	if(user)
		add_fingerprint(user)
	update_icon(UPDATE_OVERLAYS)
	return TRUE


/obj/machinery/crematorium/proc/connect()
	var/turf/target_turf = get_step(src, dir)

	connected = new /obj/structure/c_tray(target_turf)

	if(target_turf.contents.Find(connected))
		connected.crematorium = src
		update_icon(UPDATE_OVERLAYS)

		for(var/atom/movable/check in src)
			check.forceMove(connected.loc)

		connected.dir = dir
		return

	QDEL_NULL(connected)


/obj/machinery/crematorium/relaymove(mob/user)
	if(cremating || user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return
	tray_toggle(user)


/obj/machinery/crematorium/container_resist(mob/living/carbon/user)
	if(cremating || !iscarbon(user) || user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return
	to_chat(user, span_alert("You attempt to slide yourself out of [src]..."))
	tray_toggle(user)


/obj/machinery/crematorium/get_remote_view_fullscreens(mob/user)
	if(user.stat == DEAD || !(user.sight & (SEEOBJS|SEEMOBS)))
		user.overlay_fullscreen("remote_view", /atom/movable/screen/fullscreen/impaired, 2)


/obj/machinery/crematorium/verb/cremate_verb()
	set name = "Cremate"
	set src in oview(1)

	try_cremate(usr)


/obj/machinery/crematorium/proc/try_cremate(mob/user)
	if(user.incapacitated() || !isAI(user) && HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return

	if(stat & NOPOWER)
		to_chat(user, span_warning("[src] is unpowered!"))
		return

	if(cremating)
		to_chat(user, span_warning("[src] is working!"))
		return

	if(connected)
		to_chat(user, span_warning("You should close the tray first!"))
		return

	if(user.loc == src)
		to_chat(user, span_warning("You can not reach inceneration button!"))
		return

	if(allowed(user) || user.can_advanced_admin_interact())
		cremate(user)
		return

	to_chat(user, span_warning("Access denied."))
	playsound(src, pick('sound/machines/button.ogg', 'sound/machines/button_alternate.ogg', 'sound/machines/button_meloboom.ogg'), 20)


/obj/machinery/crematorium/proc/cremate(mob/user)
	// we are saving our prescious cap lazor
	saved_contents = drop_ungibbable_items(src)

	// connected check is probably unnecessary, since its qdeled after closing, but better safe than sorry
	var/list/crema_content = get_all_contents() - src - connected - saved_contents

	if(!length(crema_content))
		audible_message(span_warning("You hear a hollow crackle."))
		refuse_ungibbable_items()
		return

	use_power(400000)
	audible_message(span_warning("You hear a roar as [src] activates!"))
	cremating = TRUE
	update_icon(UPDATE_OVERLAYS)

	for(var/mob/living/entity in crema_content)
		if(QDELETED(entity))
			continue
		if(entity.stat != DEAD)
			entity.emote("scream")
		if(user)
			add_attack_logs(user, entity, "Cremated")

		entity.death(gibbed = TRUE)

		if(QDELETED(entity))
			continue // Re-check for mobs that delete themselves on death

		entity.ghostize()
		qdel(entity)

	for(var/obj/target in crema_content)
		qdel(target)

	addtimer(CALLBACK(src, PROC_REF(reset_state)), 3 SECONDS)


/obj/machinery/crematorium/proc/refuse_ungibbable_items()
	if(length(saved_contents))
		visible_message(span_boldnotice("[src] refuses to burn [lowertext(english_list(saved_contents))]."))
		tray_toggle(skip_checks = TRUE)
		saved_contents.Cut()


/obj/machinery/crematorium/proc/reset_state()
	if(QDELETED(src))
		return

	cremating = FALSE

	if(length(saved_contents))
		refuse_ungibbable_items()
	else
		update_icon(UPDATE_OVERLAYS)

	playsound(loc, 'sound/machines/ding.ogg', 50, TRUE)

	// No more ash stock-piling
	var/turf/drop_loc = get_step(src, dir)
	var/obj/effect/decal/cleanable/ash/ash_pile = locate() in drop_loc
	if(!ash_pile)
		new /obj/effect/decal/cleanable/ash(drop_loc)


/obj/machinery/crematorium/ex_act(severity)
	switch(severity)
		if(1)
			ex_act_effect(severity)
		if(2)
			ex_act_effect(severity, 50)
		if(3)
			ex_act_effect(severity, 5)


/obj/machinery/crematorium/proc/ex_act_effect(severity, probability = 100)
	if(!prob(probability))
		return
	for(var/atom/movable/check in src)
		check.forceMove(loc)
		check.ex_act(severity)
	qdel(src)


/obj/machinery/crematorium/on_deconstruction()
	if(length(component_parts))
		var/obj/item/circuitboard/machine/crematorium/circuit = locate() in component_parts
		if(circuit)
			component_parts -= circuit
			qdel(circuit)


/obj/item/circuitboard/machine/crematorium
	board_name = "Crematorium"
	build_path = /obj/machinery/crematorium
	origin_tech = "engineering=4;powerstorage=4"
	req_components = list(
		/obj/item/stack/sheet/metal = 5,
		/obj/item/assembly/igniter = 3,
		/obj/item/stock_parts/cell = 3,
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stock_parts/micro_laser = 2,
	)


/*
 * Crematorium tray
 */
/obj/structure/c_tray
	name = "crematorium tray"
	desc = "Apply body before burning."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "crema_tray"
	density = TRUE
	anchored = TRUE
	pass_flags_self = PASSTABLE|LETPASSTHROW
	layer = BELOW_OBJ_LAYER
	max_integrity = 350
	var/obj/machinery/crematorium/crematorium


/obj/structure/c_tray/Destroy()
	if(crematorium && crematorium.connected == src)
		crematorium.connected = null
	crematorium = null
	return ..()


/obj/structure/c_tray/CanAStarPass(to_dir, datum/can_pass_info/pass_info)
	if(!density)
		return TRUE
	if(pass_info.pass_flags == PASSEVERYTHING || (pass_info.pass_flags & PASSTABLE))
		return TRUE
	return FALSE


/obj/structure/c_tray/attack_hand(mob/user)
	crematorium?.tray_toggle(user)


/obj/structure/c_tray/grab_attack(mob/living/grabber, atom/movable/grabbed_thing)
	. = TRUE
	if(grabber.grab_state < GRAB_AGGRESSIVE || !isliving(grabbed_thing))
		return .
	var/mob/living/target = grabbed_thing
	target.forceMove(loc)
	target.set_resting(TRUE, instant = TRUE)


/obj/structure/c_tray/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM || !user.drop_transfer_item_to_loc(I, loc))
		return ..()
	add_fingerprint(user)
	return ATTACK_CHAIN_BLOCKED_ALL


/obj/structure/c_tray/MouseDrop_T(atom/movable/dropping, mob/living/user, params)
	if(!istype(dropping) || dropping.anchored || get_dist(user, src) > 1 || get_dist(user, dropping) > 1 || user.contents.Find(src) || user.contents.Find(dropping))
		return

	if(!ismob(dropping) && !istype(dropping, /obj/structure/closet/body_bag))
		return

	if(!ismob(user) || user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return

	if(isliving(dropping))
		var/mob/living/target = dropping
		target.set_resting(TRUE, instant = TRUE)

	dropping.forceMove(loc)

	if(user != dropping)
		user.visible_message(span_warning("[user] stuffs [dropping] into [src]!"))
	return TRUE


/obj/structure/c_tray/Process_Spacemove(movement_dir = NONE, continuous_move = FALSE)
	return TRUE


// Crematorium switch
/obj/machinery/crema_switch
	desc = "Burn baby burn!"
	name = "crematorium igniter"
	icon = 'icons/obj/engines_and_power/power.dmi'
	icon_state = "crema_switch"
	anchored = TRUE
	req_access = list(ACCESS_CREMATORIUM)
	/// ID of the crematorium to hook into
	var/id = 1


/obj/machinery/crema_switch/attack_ghost(mob/user)
	if(user.can_advanced_admin_interact())
		return attack_hand(user)


/obj/machinery/crema_switch/attack_hand(mob/user)
	for(var/obj/machinery/crematorium/crema as anything in GLOB.crematoriums)
		if(crema.id == id)
			crema.try_cremate(user)
			break

