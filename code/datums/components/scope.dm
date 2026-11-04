///Used to allow reaching the maximum offset range without exiting the boundaries of the game screen.
#define MOUSE_POINTER_OFFSET_MULT 1.1
/// The red crosshair cursor used while looking through a gun scope.
#define SCOPE_CURSOR_ICON 'icons/effects/mouse_pointers/scope_pointer.dmi'

/**
 * A component that allows the parent item to be used as a scope,
 * shifting the user's view towards their cursor so they can look far away.
 *
 * Mainly intended for binoculars, but can be applied to any item.
 */
/datum/component/scope
	/// How far we can extend the view. Its meaning depends on [range_is_multiplier]:
	/// either a multiplier of half the viewport, or a maximum distance in tiles.
	var/range_modifier = 1
	/// If TRUE, [range_modifier] is a multiplier of half the viewport (binoculars).
	/// If FALSE, it is the maximum distance in tiles the view center can move (scopes).
	var/range_is_multiplier = FALSE
	/// The fullscreen object we use for tracking the user's cursor.
	var/atom/movable/screen/fullscreen/cursor_catcher/scope/tracker
	/// The ckey of the mob that owns the tracker.
	/// Used to compare against the current owner mob in case the client has left it (e.g. ghosted).
	var/tracker_owner_ckey
	/// The method used to toggle zooming.
	var/zoom_method = ZOOM_METHOD_WIELD
	/// If not null, an item action of this type will be added and used to toggle zooming.
	var/item_action_type
	/// Guard used to prevent re-entrant calls when we have to unzoom a gun ourselves.
	var/is_stopping = FALSE
	/// Saved gun crosshair, restored after the scope is lowered.
	var/old_gun_crosshair
	/// Saved client mouse icons, restored after the scope is lowered.
	var/old_mouse_pointer_icon
	var/old_mouse_override_icon

/datum/component/scope/Initialize(range_modifier = 1, zoom_method = ZOOM_METHOD_WIELD, item_action_type, range_is_multiplier = FALSE)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	src.range_modifier = range_modifier
	src.zoom_method = zoom_method
	src.item_action_type = item_action_type
	src.range_is_multiplier = range_is_multiplier

/datum/component/scope/Destroy(force)
	if(tracker?.owner)
		stop_zooming(tracker.owner)
	tracker = null
	tracker_owner_ckey = null
	return ..()

/datum/component/scope/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equipped))
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(on_dropped))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))

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
		if(ZOOM_METHOD_GUN_ZOOM)
			RegisterSignal(parent, COMSIG_GUN_ZOOM_TOGGLE, PROC_REF(on_gun_zoom_toggle))

/datum/component/scope/UnregisterFromParent()
	if(item_action_type)
		var/obj/item/parent_item = parent
		var/datum/action/item_action/scope_action = locate(item_action_type) in parent_item.actions
		parent_item.remove_item_action(scope_action)

	UnregisterSignal(parent, list(
		COMSIG_MOVABLE_MOVED,
		COMSIG_ITEM_EQUIPPED,
		COMSIG_ITEM_DROPPED,
		COMSIG_ATOM_EXAMINE,
		COMSIG_RANGED_ITEM_INTERACTING_WITH_ATOM_SECONDARY,
		COMSIG_GUN_ZOOM_TOGGLE,
		SIGNAL_ADDTRAIT(TRAIT_WIELDED),
		SIGNAL_REMOVETRAIT(TRAIT_WIELDED),
	))

/datum/component/scope/process(seconds_per_tick)
	if(!tracker)
		STOP_PROCESSING(SSprojectiles, src)
		return

	var/mob/user = tracker.owner
	var/client/user_client = user?.client
	if(!user_client)
		stop_zooming(user)
		return

	// Firing resets the mouse pointer, so keep the scope crosshair applied.
	if(zoom_method == ZOOM_METHOD_GUN_ZOOM && (user_client.mouse_pointer_icon != SCOPE_CURSOR_ICON || user_client.mouse_override_icon != SCOPE_CURSOR_ICON))
		user_client.mouse_override_icon = SCOPE_CURSOR_ICON
		user_client.mouse_pointer_icon = SCOPE_CURSOR_ICON

	tracker.calculate_params()
	if(tracker.given_turf && !user_client.intended_direction)
		user.face_atom(tracker.given_turf)

	animate(user_client, world.tick_lag, pixel_x = tracker.given_x, pixel_y = tracker.given_y)

/// Toggles zooming when the parent item is right-clicked with.
/datum/component/scope/proc/do_secondary_zoom(datum/source, mob/user, atom/target, list/modifiers)
	SIGNAL_HANDLER

	if(tracker)
		stop_zooming(user)
	else
		zoom(user)
	return TRUE

/// Stops zooming when the parent item moves, such as when it is thrown or dropped.
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

/// Starts zooming when the parent item becomes wielded.
/datum/component/scope/proc/on_wielded(obj/item/source, trait)
	SIGNAL_HANDLER

	var/mob/user = source.loc
	if(!ismob(user))
		return
	zoom(user)

/// Stops zooming when the parent item is no longer wielded.
/datum/component/scope/proc/on_unwielded(obj/item/source, trait)
	SIGNAL_HANDLER

	if(!tracker)
		return
	stop_zooming(tracker.owner)

/// Toggles zooming via the associated item action.
/datum/component/scope/proc/on_action_trigger(datum/action/source)
	SIGNAL_HANDLER

	var/obj/item/item = source.target
	var/mob/living/user = item.loc
	if(!istype(user))
		return
	if(tracker)
		stop_zooming(user)
	else
		zoom(user)

/// Starts or stops zooming when a gun with this component is zoomed in or out.
/datum/component/scope/proc/on_gun_zoom_toggle(obj/item/gun/source, mob/user, zoomed)
	SIGNAL_HANDLER

	if(zoomed)
		zoom(user)
	else
		stop_zooming(user)

/datum/component/scope/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	var/scope_text = "осмотреть окрестности"
	switch(zoom_method)
		if(ZOOM_METHOD_RIGHT_CLICK)
			examine_list += span_notice("Вы можете [scope_text], кликнув <b>правой кнопкой мыши</b>.")
		if(ZOOM_METHOD_WIELD)
			examine_list += span_notice("Вы можете [scope_text], взяв предмет <b>в обе руки</b>.")
		if(ZOOM_METHOD_ITEM_ACTION)
			examine_list += span_notice("Вы можете [scope_text], используя соответствующее <b>действие предмета</b>.")
		if(ZOOM_METHOD_GUN_ZOOM)
			examine_list += span_notice("Вы можете [scope_text], <b>прицелившись</b> из оружия.")

/**
 * Starts zooming by adding our tracker overlay and starting our processing.
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

	user.playsound_local(get_turf(parent), 'sound/weapons/gun_interactions/scope.ogg', 75, TRUE)
	var/severity = isgun(parent) ? 1 : 0
	tracker = user.overlay_fullscreen("scope", /atom/movable/screen/fullscreen/cursor_catcher/scope, severity)
	tracker.assign_to_mob(user, range_modifier, range_is_multiplier)
	tracker_owner_ckey = user.ckey

	if(isgun(parent))
		var/obj/item/gun/gun = parent
		old_gun_crosshair = gun.gun_crosshair
		gun.gun_crosshair = SCOPE_CURSOR_ICON
		old_mouse_pointer_icon = user.client.mouse_pointer_icon
		old_mouse_override_icon = user.client.mouse_override_icon
		user.client.mouse_pointer_icon = SCOPE_CURSOR_ICON
		user.client.mouse_override_icon = SCOPE_CURSOR_ICON

	RegisterSignals(user, list(COMSIG_MOB_SWAP_HANDS, COMSIG_QDELETING), PROC_REF(stop_zooming))
	RegisterSignal(user, COMSIG_ATOM_ENTERING, PROC_REF(on_enter_new_loc))
	RegisterSignals(user, list(
		COMSIG_LIVING_STATUS_KNOCKDOWN,
		COMSIG_LIVING_STATUS_PARALYZE,
		COMSIG_LIVING_STATUS_STUN,
	), PROC_REF(on_incapacitated))
	RegisterSignal(user, COMSIG_LIVING_DEATH, PROC_REF(on_death))

	START_PROCESSING(SSprojectiles, src)
	ADD_TRAIT(user, TRAIT_USER_SCOPED, UNIQUE_TRAIT_SOURCE(src))
	return TRUE

/// Stops zooming if the new location the user moves to is not a turf.
/datum/component/scope/proc/on_enter_new_loc(datum/source, atom/newloc, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	if(!tracker)
		return
	if(!isturf(newloc))
		stop_zooming(tracker.owner)

/// Stops zooming when the user dies.
/datum/component/scope/proc/on_death(mob/living/source, gibbed)
	SIGNAL_HANDLER

	if(!tracker)
		return
	stop_zooming(tracker.owner)

/// Stops zooming when the user is incapacitated.
/datum/component/scope/proc/on_incapacitated(mob/living/source, amount = 0, ignore_canstun = FALSE)
	SIGNAL_HANDLER

	if(amount > 0)
		stop_zooming(tracker?.owner)

/**
 * Stops zooming, canceling processing, resetting the user's view back to normal and deleting our tracker.
 *
 * Arguments:
 * * user: The mob we are canceling zooming on.
 */
/datum/component/scope/proc/stop_zooming(mob/user)
	SIGNAL_HANDLER

	if(!tracker || is_stopping)
		return

	is_stopping = TRUE
	STOP_PROCESSING(SSprojectiles, src)

	var/mob/tracked_user = tracker.owner
	if(!user)
		user = tracked_user

	if(user)
		UnregisterSignal(user, list(
			COMSIG_MOB_SWAP_HANDS,
			COMSIG_QDELETING,
			COMSIG_ATOM_ENTERING,
			COMSIG_LIVING_DEATH,
			COMSIG_LIVING_STATUS_KNOCKDOWN,
			COMSIG_LIVING_STATUS_PARALYZE,
			COMSIG_LIVING_STATUS_STUN,
		))
		REMOVE_TRAIT(user, TRAIT_USER_SCOPED, UNIQUE_TRAIT_SOURCE(src))

	var/mob/true_user = user
	if(tracked_user && tracked_user.ckey != tracker_owner_ckey)
		var/mob/new_owner = get_mob_by_ckey(tracker_owner_ckey)
		if(new_owner)
			true_user = new_owner

	if(true_user)
		true_user.playsound_local(get_turf(parent), 'sound/weapons/gun_interactions/scope.ogg', 75, TRUE, frequency = -1)

	if(zoom_method == ZOOM_METHOD_GUN_ZOOM && isgun(parent))
		var/obj/item/gun/gun = parent
		if(!QDELETED(gun) && gun.zoomed)
			gun.zoom(user, FALSE)

	if(zoom_method == ZOOM_METHOD_GUN_ZOOM)
		if(isgun(parent))
			var/obj/item/gun/gun = parent
			if(!QDELETED(gun))
				gun.gun_crosshair = old_gun_crosshair
		if(true_user?.client)
			true_user.client.mouse_pointer_icon = old_mouse_pointer_icon
			true_user.client.mouse_override_icon = old_mouse_override_icon
		old_gun_crosshair = null
		old_mouse_pointer_icon = null
		old_mouse_override_icon = null

	// If the mob has changed, clear the overlay from both the original and the current mob.
	if(tracked_user)
		tracked_user.clear_fullscreen("scope")
		if(true_user && true_user != tracked_user)
			true_user.clear_fullscreen("scope")

	if(true_user?.client)
		animate(true_user.client, 0.2 SECONDS, pixel_x = 0, pixel_y = 0)
	else if(tracked_user?.client)
		animate(tracked_user.client, 0.2 SECONDS, pixel_x = 0, pixel_y = 0)

	tracker = null
	tracker_owner_ckey = null
	is_stopping = FALSE

/atom/movable/screen/fullscreen/cursor_catcher/scope
	icon_state = "scope"
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	default_click = FALSE
	/// How far the view center can move. See [datum/component/scope/var/range_modifier].
	var/range_modifier = 1
	/// See [datum/component/scope/var/range_is_multiplier].
	var/range_is_multiplier = FALSE
	/// The turf currently under the cursor/crosshair.
	var/turf/crosshair_turf

/atom/movable/screen/fullscreen/cursor_catcher/scope/assign_to_mob(mob/new_owner, range_modifier, range_is_multiplier)
	src.range_modifier = range_modifier
	src.range_is_multiplier = range_is_multiplier
	return ..(new_owner)

/atom/movable/screen/fullscreen/cursor_catcher/scope/MouseMove(location, control, params)
	. = ..()
	if(usr == owner)
		calculate_params()

/atom/movable/screen/fullscreen/cursor_catcher/scope/Click(location, control, params)
	var/list/modifiers = params2list(params)
	if(!LAZYACCESS(modifiers, RIGHT_CLICK) || !owner)
		return

	var/obj/item/gun/gun = owner.get_active_hand()
	if(istype(gun) && gun.zoomed && gun.GetComponent(/datum/component/scope))
		gun.zoom(owner)

/atom/movable/screen/fullscreen/cursor_catcher/scope/calculate_params()
	if(!owner || !view_list)
		return
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
	var/x_cap
	var/y_cap
	var/uncapped_x
	var/uncapped_y

	if(range_is_multiplier)
		x_cap = range_modifier * half_x
		y_cap = range_modifier * half_y
		uncapped_x = round(range_modifier * (icon_x - half_x) * MOUSE_POINTER_OFFSET_MULT)
		uncapped_y = round(range_modifier * (icon_y - half_y) * MOUSE_POINTER_OFFSET_MULT)
	else
		x_cap = range_modifier * ICON_SIZE_X
		y_cap = range_modifier * ICON_SIZE_Y
		uncapped_x = round((icon_x - half_x) / half_x * x_cap)
		uncapped_y = round((icon_y - half_y) / half_y * y_cap)

	given_x = clamp(uncapped_x, -x_cap, x_cap)
	given_y = clamp(uncapped_y, -y_cap, y_cap)
	given_turf = locate(owner.x + round(given_x / ICON_SIZE_X, 1), owner.y + round(given_y / ICON_SIZE_Y, 1), owner.z)
	crosshair_turf = locate(owner.x + round((icon_x - half_x + given_x) / ICON_SIZE_X, 1), owner.y + round((icon_y - half_y + given_y) / ICON_SIZE_Y, 1), owner.z)

#undef MOUSE_POINTER_OFFSET_MULT
#undef SCOPE_CURSOR_ICON
