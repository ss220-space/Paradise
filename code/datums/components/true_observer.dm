/**
 * # True Observer component
 *
 * This component is attached to a ghost/observer to link its vision, HUD,
 * and other client-side feedback directly to a living mob they are observing.
 * It replaces old polling loops and manual updates with a signal-driven approach.
 */
/datum/component/true_observer
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	/// The mob which observed by component parent
	var/mob/living/observe_target
	var/mob/dead/observer/observe
	/// What we give to connect_loc by default, makes slippable mobs moving over us slip
	var/static/list/default_connections = list(
		COMSIG_MOB_UPDATE_SIGHT = PROC_REF(on_update_sight),
		COMSIG_MOB_RESET_PERSPECTIVE = PROC_REF(on_reset_perspective),
		COMSIG_CLIENT_SET_EYE = PROC_REF(on_set_eye),

		COMSIG_MOB_UNEQUIPPED_ITEM = PROC_REF(on_unequipped_item),

		COMSIG_LIVING_STORAGE_SHOW_TO = PROC_REF(on_storage_show_to),
		COMSIG_LIVING_STORAGE_HIDE_FROM = PROC_REF(on_storage_hide_from),

		COMSIG_MOB_HUD_REFRESHED = PROC_REF(on_hud_refreshed),
		COMSIG_CLIENT_SCREEN_ELEMENT = PROC_REF(on_screen_element),
		COMSIG_DO_AFTER_BEGAN = PROC_REF(on_do_after_began),

		COMSIG_MOB_STATUS_EFFECT_CREATED = PROC_REF(on_status_effect_created),
		COMSIG_MOB_STATUS_EFFECT_ENDED = PROC_REF(on_status_effect_ended),
		COMSIG_MOB_BALOON_ALERT = PROC_REF(on_baloon_alert),

		COMSIG_MOB_ZOOMED = PROC_REF(on_zoomed),

		COMSIG_QDELETING = PROC_REF(on_target_destroyed),
	)

/**
 * Initialize the "True-Observe(Vison)" component behaviour
 *
 * When applied to any observer in the game this will let him to see the observe_target client screen
 * Arguments:
 * * observe_target - the target whose screen will be shown to the observer
 */
/datum/component/true_observer/Initialize(
	observe_target,
)
	if (!isobserver(parent) || !observe_target)
		return COMPONENT_INCOMPATIBLE
	src.observe = parent
	src.observe_target = observe_target
	ADD_TRAIT(observe, TRAIT_OBSERVING_INVENTORY, src)

/datum/component/true_observer/RegisterWithParent()
	for (var/key,value in default_connections)
		RegisterSignal(observe_target, key, value, TRUE)
	RegisterSignal(observe, COMSIG_ORBITER_ORBIT_STOP, PROC_REF(UnregisterFromParent), TRUE)
	sync_vision_with_target()
	observe.show_other_mob_action_buttons(observe_target)
	on_hud_refreshed(observe_target, observe_target.hud_used)

/datum/component/true_observer/UnregisterFromParent()
	for(var/key,_ in default_connections)
		UnregisterSignal(observe_target, key)
	if(isnull(observe.client))
		return
	clear_vision()
	observe.hide_other_mob_action_buttons(observe_target)

/datum/component/true_observer/Destroy(force)
	// null
	REMOVE_TRAIT(parent, TRAIT_OBSERVING_INVENTORY, src)
	return ..()

/datum/component/true_observer/InheritComponent(
	datum/component/true_observer/component,
	i_am_original,
	observe,
	observe_target
)
	if(component)
		observe = component.observe
		observe_target = component.observe_target
	UnregisterFromParent()
	src.observe = observe
	src.observe_target = observe_target
	RegisterWithParent()

/datum/component/true_observer/proc/sync_vision_with_target()
	observe.nightvision = observe_target.nightvision
	observe.vision_type = observe_target.vision_type
	observe.reset_perspective(observe_target)
	observe.set_sight(observe_target.sight)
	observe.set_invis_see(observe_target.see_invisible)
	observe.sync_lighting_plane_alpha()

/datum/component/true_observer/proc/clear_vision()
	observe.nightvision = initial(observe.nightvision)
	observe.add_sight(SEE_TURFS|SEE_MOBS|SEE_OBJS|SEE_SELF)
	observe.set_invis_see(SEE_INVISIBLE_OBSERVER_AI_EYE)
	observe.reset_perspective(null)
	observe.sync_lighting_plane_alpha()
	if(observe.client)
		observe.client.pixel_w = initial(observe.client.pixel_w)
		observe.client.pixel_z = initial(observe.client.pixel_z)
	observe.clear_fullscreens()

/// ------------ SIGNAL PROCS ------------

///datum/component/true_observer/proc/ ()
//	SIGNAL_HANDLER

/datum/component/true_observer/proc/on_zoomed()
	SIGNAL_HANDLER
	if(!observe.client || !observe_target?.client)
		return
	observe.client.pixel_w = observe_target.client.pixel_w
	observe.client.pixel_z = observe_target.client.pixel_z

/datum/component/true_observer/proc/on_storage_show_to(mob/living/mob_source, obj/item/storage/storage)
	SIGNAL_HANDLER
	storage.show_to(observe, TRUE)

/datum/component/true_observer/proc/on_storage_hide_from(mob/living/mob_source, obj/item/storage/storage)
	SIGNAL_HANDLER
	storage.hide_from(observe, TRUE)

/datum/component/true_observer/proc/on_hud_refreshed(mob/living/mob_source, datum/hud/hud_source)
	SIGNAL_HANDLER
	hud_source?.show_hud(hud_source.hud_version, observe)

/datum/component/true_observer/proc/on_status_effect_created(mob/living/mob_source, datum/status_effect/transient/effect_type)
	SIGNAL_HANDLER
	if(istype(effect_type) == FALSE)
		return

	var/datum/hud/hud = observe.hud_used
	if(!hud)
		return

	var/atom/movable/plane_master_controller/game_plane_master_controller = observe.hud_used?.plane_master_controllers[PLANE_MASTERS_GAME]
	if(!game_plane_master_controller)
		return

	switch(effect_type.type)
		if(/datum/status_effect/transient/eye_blurry)
	///mob/living/update_blurry_effects()
			var/AmountEyeBlurry = observe_target.AmountEyeBlurry()
			if(AmountEyeBlurry)
				game_plane_master_controller.add_filter("eye_blur", 1, gauss_blur_filter(clamp(AmountEyeBlurry * EYE_BLUR_TO_FILTER_SIZE_MULTIPLIER, 0.6, MAX_EYE_BLURRY_FILTER_SIZE)))
			return
		//if(/*your/path*/)
			/*your/code*/
		//	return

/datum/component/true_observer/proc/on_status_effect_ended(mob/living/mob_source, datum/status_effect/transient/effect_type)
	SIGNAL_HANDLER
	if(istype(effect_type) == FALSE)
		return

	var/datum/hud/hud = observe.hud_used
	if(!hud)
		return

	var/atom/movable/plane_master_controller/game_plane_master_controller = observe.hud_used?.plane_master_controllers[PLANE_MASTERS_GAME]
	if(!game_plane_master_controller)
		return

	switch(effect_type.type)
		if(/datum/status_effect/transient/eye_blurry)
	///mob/living/update_blurry_effects()

			game_plane_master_controller.remove_filter("eye_blur")
			return
		//if(/*your/path*/)
			/*your/code*/
		//	return
	return

/datum/component/true_observer/proc/on_baloon_alert(mob/viewer, atom/source, text)
	SIGNAL_HANDLER
	source.balloon_alert(observe, text)
	return

/datum/component/true_observer/proc/on_do_after_began(mob/living/mob_source, datum/progressbar/bar)
	SIGNAL_HANDLER
	if(!observe.client)
		return
	observe.client.add_progressbar(bar)

/datum/component/true_observer/proc/on_reset_perspective()
	SIGNAL_HANDLER
	if(!observe || !observe_target?.client)
		return
	observe.reset_perspective(observe_target.client.eye)

/datum/component/true_observer/proc/on_set_eye(mob/living/mob_source, old_eye, new_eye)
	SIGNAL_HANDLER
	if(!observe.client || !observe_target?.client)
		return
	observe.client.set_eye(observe_target.client.eye)

/datum/component/true_observer/proc/on_target_destroyed(mob/living/mob_source, force)
	SIGNAL_HANDLER
	ClearFromParent()

/datum/component/true_observer/proc/on_unequipped_item(mob/living/mob_source, I, force, newloc, no_move, invdrop, silent)
	SIGNAL_HANDLER
	if(!observe.client || !observe_target?.client)
		return
	observe.client.screen -= I

/datum/component/true_observer/proc/on_update_sight()
	SIGNAL_HANDLER
	sync_vision_with_target()

/datum/component/true_observer/proc/on_screen_element(mob/living/mob_source, element, is_added)
	SIGNAL_HANDLER
	if(!observe.client || !observe_target?.client)
		return
	if(is_added)
		observe.client.screen |= element
	else
		observe.client.screen -= element

