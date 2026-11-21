/// The red crosshair cursor used while looking through a gun scope.
#define SCOPE_CURSOR_ICON 'icons/effects/mouse_pointers/scope_pointer.dmi'

/**
 * A component that allows the parent item to be used as a scope,
 * shifting the user's view towards their cursor so they can look far away.
 *
 * Mainly intended for binoculars, but can be applied to any item.
 */
/datum/component/scope
	/// How far we can extend the view.
	var/range_modifier = 1
	/// The fullscreen object we use for tracking the user's cursor.
	var/atom/movable/screen/fullscreen/cursor_catcher/scope/tracker
	/// The ckey of the mob that owns the tracker.
	/// Used to compare against the current owner mob in case the client has left it (e.g. ghosted).
	var/tracker_owner_ckey
	/// The method used to toggle zooming.
	var/zoom_method = ZOOM_METHOD_WIELD
	/// If not null, an item action of this type will be added and used to toggle zooming.
	var/item_action_type
	/// Flags for scoping. Check `code\__DEFINES\flags.dm`
	var/flags
	/// A trait you want to add when scoped in to the mob.
	var/trait_to_add
	var/severity
	var/crosshair_icon

/datum/component/scope/Initialize(range_modifier = 1, zoom_method = ZOOM_METHOD_RIGHT_CLICK, item_action_type = /datum/action/zoom, flags, trait_to_add, severity = SEVERITY_GUN, crosshair_icon)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	src.range_modifier = range_modifier
	src.zoom_method = zoom_method
	src.item_action_type = item_action_type
	src.flags = flags
	src.trait_to_add = trait_to_add
	src.severity = severity
	src.crosshair_icon = crosshair_icon
	if(severity == SEVERITY_GUN && !src.crosshair_icon)
		src.crosshair_icon = SCOPE_CURSOR_ICON

/datum/component/scope/Destroy(force)
	if(tracker?.owner)
		stop_zooming(tracker.owner)
	tracker = null
	return ..()

/datum/component/scope/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equipped))
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(on_dropped))
	switch(zoom_method)
		if(ZOOM_METHOD_RIGHT_CLICK)
			RegisterSignal(parent, COMSIG_RANGED_ITEM_INTERACTING_WITH_ATOM_SECONDARY, PROC_REF(do_secondary_zoom))
		if(ZOOM_METHOD_WIELD)
			RegisterSignal(parent, SIGNAL_ADDTRAIT(TRAIT_WIELDED), PROC_REF(on_wielded))
			RegisterSignal(parent, SIGNAL_REMOVETRAIT(TRAIT_WIELDED), PROC_REF(on_unwielded))
		if(ZOOM_METHOD_ITEM_ACTION)
			if(!item_action_type)
				CRASH("[src] was given the item action zoom method without an action type")
			var/obj/item/parent_item = parent
			var/datum/action/item_action/scope_action = parent_item.add_item_action(item_action_type)
			RegisterSignal(scope_action, COMSIG_ACTION_TRIGGER, PROC_REF(on_action_trigger))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))

/datum/component/scope/UnregisterFromParent()
	if(item_action_type)
		var/obj/item/parent_item = parent
		var/datum/action/item_action/scope_action = locate(item_action_type) in parent_item.actions
		parent_item.remove_item_action(scope_action)
	UnregisterSignal(parent, list(
		COMSIG_MOVABLE_MOVED,
		COMSIG_ITEM_EQUIPPED,
		COMSIG_ITEM_DROPPED,
		COMSIG_RANGED_ITEM_INTERACTING_WITH_ATOM_SECONDARY,
		SIGNAL_ADDTRAIT(TRAIT_WIELDED),
		SIGNAL_REMOVETRAIT(TRAIT_WIELDED),
		COMSIG_ATOM_EXAMINE
	))

/datum/component/scope/process(seconds_per_tick)
	if(!tracker)
		STOP_PROCESSING(SSprojectiles, src)
		return
	var/mob/user_mob = tracker.owner
	var/client/user_client = user_mob.client
	if(!user_client)
		stop_zooming(user_mob)
		return
	tracker.calculate_params()
	if(!user_client.intended_direction)
		user_mob.face_atom(tracker.given_turf)
	animate(user_client, world.tick_lag, pixel_x = tracker.given_x, pixel_y = tracker.given_y)

/datum/component/scope/proc/on_move(atom/movable/source, atom/oldloc, dir, forced)
	SIGNAL_HANDLER

	if(!tracker)
		return
	stop_zooming(tracker.owner)

/// Stops zooming when the parent item is equipped into any slot.
/datum/component/scope/proc/on_equipped(datum/source, mob/user, slot)
	SIGNAL_HANDLER

	if(!tracker)
		return
	stop_zooming(tracker.owner)

/// Stops zooming when the parent item is dropped.
/datum/component/scope/proc/on_dropped(datum/source, mob/user, slot)
	SIGNAL_HANDLER

	if(!tracker)
		return
	stop_zooming(tracker.owner)

/datum/component/scope/proc/do_secondary_zoom(datum/source, mob/user, atom/target, list/modifiers)
	SIGNAL_HANDLER

	if(tracker)
		stop_zooming(user)
	else
		zoom(user)
	return ITEM_INTERACT_BLOCKING

/datum/component/scope/proc/on_action_trigger(datum/action/source)
	SIGNAL_HANDLER
	var/obj/item/item = source.target
	var/mob/living/user = item.loc
	if(is_internal_organ(item))
		var/obj/item/organ/internal/organ = item
		user = organ.owner

	if(!istype(user))
		return
	if(tracker)
		stop_zooming(user)
	else
		zoom(user)

/datum/component/scope/proc/on_wielded(obj/item/source, trait)
	SIGNAL_HANDLER
	var/mob/living/user = source.loc
	zoom(user)

/datum/component/scope/proc/on_unwielded(obj/item/source, trait)
	SIGNAL_HANDLER
	var/mob/living/user = source.loc
	stop_zooming(user)

/datum/component/scope/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	var/scope_text = severity == SEVERITY_GUN ? "прицелиться" : "осмотреть окрестности"
	switch(zoom_method)
		if(ZOOM_METHOD_RIGHT_CLICK)
			examine_list += span_notice("Вы можете [scope_text], кликнув <b>правой кнопкой мыши</b>.")
		if(ZOOM_METHOD_WIELD)
			examine_list += span_notice("Вы можете [scope_text], взяв предмет <b>в обе руки</b>.")
		if(ZOOM_METHOD_ITEM_ACTION)
			examine_list += span_notice("Вы можете [scope_text], используя соответствующее <b>действие предмета</b>.")

/**
 * We start zooming by adding our tracker overlay and starting our processing.
 *
 * Arguments:
 * * user: The mob we are starting zooming on.
*/
/datum/component/scope/proc/zoom(mob/user)
	if(isnull(user.client))
		return

	if(HAS_TRAIT(user, TRAIT_USER_SCOPED))
		user.balloon_alert(user, "уже используется!")
		return

	if((flags & SCOPE_TURF_ONLY) && !isturf(user.loc))
		user.balloon_alert(user, "недостаточно места!")
		return

	if((flags & SCOPE_NEED_ACTIVE_HAND) && user.get_active_hand() != parent)
		user.balloon_alert(user, "нужна активная рука!")
		return

	user.playsound_local(get_turf(parent), 'sound/weapons/gun_interactions/scope.ogg', 75, TRUE)
	tracker = user.overlay_fullscreen("scope", /atom/movable/screen/fullscreen/cursor_catcher/scope, severity)
	if(crosshair_icon)
		user.scope_pointer_icon = crosshair_icon
		user.update_mouse_pointer()
	tracker.assign_to_mob(user, range_modifier)
	if(flags & SCOPE_MOVEMENT_CANCELS)
		RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	if(flags & SCOPE_CLICK_MIDDLE)
		RegisterSignal(tracker, COMSIG_CLICK, PROC_REF(generic_click))
	tracker_owner_ckey = user.ckey
	if(user.is_in_hands(parent))
		RegisterSignals(user, list(COMSIG_MOB_SWAP_HANDS, COMSIG_QDELETING), PROC_REF(stop_zooming))
		RegisterSignal(user, COMSIG_ATOM_ENTERING, PROC_REF(on_enter_new_loc))
	else // The item is likely worn (eg. mothic cap)
		RegisterSignal(user, COMSIG_QDELETING, PROC_REF(stop_zooming))
		RegisterSignal(user, COMSIG_ATOM_ENTERING, PROC_REF(on_enter_new_loc))
		var/static/list/capacity_signals = list(
			COMSIG_LIVING_STATUS_KNOCKDOWN,
			COMSIG_LIVING_STATUS_PARALYZE,
			COMSIG_LIVING_STATUS_STUN,
		)
		RegisterSignals(user, capacity_signals, PROC_REF(on_incapacitated))
		RegisterSignal(user, COMSIG_LIVING_DEATH, PROC_REF(on_death))
	START_PROCESSING(SSprojectiles, src)
	ADD_TRAIT(user, TRAIT_USER_SCOPED, UNIQUE_TRAIT_SOURCE(src))
	if(trait_to_add)
		ADD_TRAIT(user, trait_to_add, UNIQUE_TRAIT_SOURCE(src))
		user.update_sight()
	toggle_zoom(TRUE, user)
	return TRUE

/datum/component/scope/proc/toggle_zoom(zoomed, mob/user)
	SEND_SIGNAL(parent, COMSIG_GUN_ZOOM_TOGGLE, user, zoomed)

///Stop scoping if the `newloc` we move to is not a turf
/datum/component/scope/proc/on_enter_new_loc(datum/source, atom/newloc, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	if(!tracker)
		return

	if(!isturf(newloc) && (flags & SCOPE_TURF_ONLY))
		stop_zooming(tracker.owner)

/// Stops zooming when the user dies.
/datum/component/scope/proc/on_death(mob/living/source, gibbed)
	SIGNAL_HANDLER

	if(!tracker)
		return
	stop_zooming(tracker.owner)

/datum/component/scope/proc/on_incapacitated(mob/living/source, amount = 0, ignore_canstun = FALSE)
	SIGNAL_HANDLER

	if(amount > 0)
		stop_zooming(source)

/datum/component/scope/proc/generic_click(/obj/source, location, control, params)
	SIGNAL_HANDLER // COMSIG_CLICK
	INVOKE_ASYNC(tracker.owner, TYPE_PROC_REF(/mob, ClickOn), get_scope_target(tracker.given_turf, tracker), params)

/**
 * We find and return the best target to hit on a given turf.
 *
 * Arguments:
 * * target_turf: The turf we are looking for targets on.
*/
/proc/get_scope_target(turf/target_turf, atom/movable/screen/fullscreen/cursor_catcher/scope/tracker)
	var/list/object_targets = list()
	var/list/non_dense_targets = list()
	for(var/atom/movable/possible_target in target_turf)
		if(possible_target.layer <= PROJECTILE_HIT_THRESHOLD_LAYER)
			continue
		if(possible_target.invisibility > tracker.owner.see_invisible)
			continue
		if(!possible_target.mouse_opacity)
			continue
		if(iseffect(possible_target))
			continue
		if(ismob(possible_target))
			if(possible_target == tracker.owner)
				continue
			return possible_target
		if(!possible_target.density)
			non_dense_targets += possible_target
			continue
		object_targets += possible_target
	for(var/obj/important_object as anything in object_targets)
		return important_object
	for(var/obj/unimportant_object as anything in non_dense_targets)
		return unimportant_object
	return target_turf

/**
 * We stop zooming, canceling processing, resetting stuff back to normal and deleting our tracker.
 *
 * Arguments:
 * * user: The mob we are canceling zooming on.
*/
/datum/component/scope/proc/stop_zooming(mob/user)
	SIGNAL_HANDLER

	if(!HAS_TRAIT(user, TRAIT_USER_SCOPED))
		return

	STOP_PROCESSING(SSprojectiles, src)
	UnregisterSignal(user, list(
		COMSIG_LIVING_STATUS_KNOCKDOWN,
		COMSIG_LIVING_STATUS_PARALYZE,
		COMSIG_LIVING_STATUS_STUN,
		COMSIG_MOB_SWAP_HANDS,
		COMSIG_QDELETING,
		COMSIG_ATOM_ENTERING,
		COMSIG_LIVING_DEATH,
		COMSIG_MOVABLE_MOVED
	))
	REMOVE_TRAIT(user, TRAIT_USER_SCOPED, UNIQUE_TRAIT_SOURCE(src))
	if(trait_to_add)
		REMOVE_TRAIT(user, trait_to_add, UNIQUE_TRAIT_SOURCE(src))
		user.update_sight()
	toggle_zoom(FALSE, user)

	user.playsound_local(get_turf(parent), 'sound/weapons/gun_interactions/scope.ogg', 75, TRUE, frequency = -1)
	user.clear_fullscreen("scope")
	if(crosshair_icon && user.scope_pointer_icon == crosshair_icon)
		user.scope_pointer_icon = null
		user.update_mouse_pointer()

	// if the client has ended up in another mob, find that mob so we can fix their cursor
	var/mob/true_user
	if(user.ckey != tracker_owner_ckey)
		true_user = get_mob_by_ckey(tracker_owner_ckey)

	if(!isnull(true_user))
		user = true_user

	if(crosshair_icon && user.scope_pointer_icon == crosshair_icon)
		user.scope_pointer_icon = null
		user.update_mouse_pointer()

	if(user.client)
		animate(user.client, 0.2 SECONDS, pixel_x = 0, pixel_y = 0)
	tracker = null
	tracker_owner_ckey = null

#undef SCOPE_CURSOR_ICON

/atom/movable/screen/fullscreen/cursor_catcher/scope
	icon_state = "scope"
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	/// How far the view center can move. See [datum/component/scope/var/range_modifier].
	var/range_modifier = 1
	/// The turf currently under the cursor/crosshair.
	var/turf/crosshair_turf

/atom/movable/screen/fullscreen/cursor_catcher/scope/assign_to_mob(mob/new_owner, range_modifier)
	src.range_modifier = range_modifier
	return ..()

/atom/movable/screen/fullscreen/cursor_catcher/scope/Click(location, control, params)
	if(usr == owner)
		calculate_params()
	return ..()

/atom/movable/screen/fullscreen/cursor_catcher/scope/MouseDrag(over_object, src_location, over_location, src_control, over_control, params)
	MouseMove(over_location, over_control, params)
	if(usr == owner)
		calculate_params()
	return ..()

/atom/movable/screen/fullscreen/cursor_catcher/scope/calculate_params()
	var/list/modifiers = params2list(mouse_params)
	var/icon_x = text2num(LAZYACCESS(modifiers, VIS_X))
	if(isnull(icon_x))
		icon_x = text2num(LAZYACCESS(modifiers, ICON_X))
		if(isnull(icon_x))
			icon_x = view_list[1] * ICON_SIZE_X / 2
	var/icon_y = text2num(LAZYACCESS(modifiers, VIS_Y))
	if(isnull(icon_y))
		icon_y = text2num(LAZYACCESS(modifiers, ICON_Y))
		if(isnull(icon_y))
			icon_y = view_list[2] * ICON_SIZE_Y / 2
	var/half_x = view_list[1] * ICON_SIZE_X / 2
	var/half_y = view_list[2] * ICON_SIZE_Y / 2
	var/ax = (view_list[1] - 1) * ICON_SIZE_X / 2
	var/ay = (view_list[2] - 1) * ICON_SIZE_Y / 2

	var/dx = icon_x - half_x
	var/dy = icon_y - half_y
	var/nx = dx / ax
	var/ny = dy / ay
	var/n = sqrt(nx * nx + ny * ny)
	if(n > 1)
		nx /= n
		ny /= n
	given_x = range_modifier * nx * ax
	given_y = range_modifier * ny * ay
	given_turf = locate(owner.x + round(given_x / ICON_SIZE_X, 1), owner.y + round(given_y / ICON_SIZE_Y, 1), owner.z)
	crosshair_turf = locate(owner.x + floor((icon_x - half_x + given_x) / ICON_SIZE_X), owner.y + floor((icon_y - half_y + given_y) / ICON_SIZE_Y), owner.z)

/datum/action/zoom
	name = "Масштаб"
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_HANDS_BLOCKED|AB_CHECK_INCAPACITATED
	button_icon_state = "sniper_zoom"
