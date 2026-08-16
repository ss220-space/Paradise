#define RADIAL_BLUR_FILTER_NAME "radial_blur"
#define RADIAL_BLUR_MIN_SIZE 0.005
#define RADIAL_BLUR_MAX_SIZE 0.015
#define RADIAL_BLUR_RISE_TIME 0.2 SECONDS
#define RADIAL_BLUR_FALL_TIME 1.5 SECONDS

/// Displays a pulsating radial blur across the screen while the owner has fractures.
/datum/status_effect/radial_blur
	id = "radial_blur"
	alert_type = null
	duration = STATUS_EFFECT_PERMANENT
	tick_interval = STATUS_EFFECT_NO_TICK
	status_type = STATUS_EFFECT_UNIQUE

/datum/status_effect/radial_blur/on_apply()
	if(!ishuman(owner))
		return FALSE

	RegisterSignal(owner, COMSIG_MOB_LOGIN, PROC_REF(update_blur))
	update_blur()
	return TRUE

/datum/status_effect/radial_blur/on_remove()
	UnregisterSignal(owner, COMSIG_MOB_LOGIN)
	if(!owner.hud_used)
		return

	var/atom/movable/plane_master_controller/game_plane_master_controller = owner.hud_used.plane_master_controllers[PLANE_MASTERS_GAME]
	game_plane_master_controller.remove_filter(RADIAL_BLUR_FILTER_NAME)

	for(var/mob/dead/observer/observe in owner.inventory_observers)
		if(!observe.client)
			observe.handle_when_autoobserve_move()
			LAZYREMOVE(owner.inventory_observers, observe)
			continue
		game_plane_master_controller = observe.hud_used.plane_master_controllers[PLANE_MASTERS_GAME]
		game_plane_master_controller.remove_filter(RADIAL_BLUR_FILTER_NAME)

/**
* Applies a pulsating radial blur to the owner's screen.
*
* Also processes the [COMSIG_MOB_LOGIN] signal to apply a filter
* when the mob has a client (and HUD).
*/
/datum/status_effect/radial_blur/proc/update_blur(datum/source)
	SIGNAL_HANDLER
	if(!owner.hud_used || !owner.client)
		return

	var/atom/movable/plane_master_controller/game_plane_master_controller = owner.hud_used.plane_master_controllers[PLANE_MASTERS_GAME]
	game_plane_master_controller.add_filter(RADIAL_BLUR_FILTER_NAME, 1, radial_blur_filter(size = RADIAL_BLUR_MIN_SIZE))
	for(var/blur_filter as anything in game_plane_master_controller.get_filters(RADIAL_BLUR_FILTER_NAME))
		animate(blur_filter, size = RADIAL_BLUR_MAX_SIZE, time = RADIAL_BLUR_RISE_TIME, loop = -1, easing = SINE_EASING, flags = ANIMATION_PARALLEL)
		animate(size = RADIAL_BLUR_MIN_SIZE, time = RADIAL_BLUR_FALL_TIME, easing = SINE_EASING)

	for(var/mob/dead/observer/observe in owner.inventory_observers)
		if(!observe.client)
			observe.handle_when_autoobserve_move()
			LAZYREMOVE(owner.inventory_observers, observe)
			continue
		game_plane_master_controller = observe.hud_used.plane_master_controllers[PLANE_MASTERS_GAME]
		game_plane_master_controller.add_filter(RADIAL_BLUR_FILTER_NAME, 1, radial_blur_filter(size = RADIAL_BLUR_MIN_SIZE))
		for(var/blur_filter as anything in game_plane_master_controller.get_filters(RADIAL_BLUR_FILTER_NAME))
			animate(blur_filter, size = RADIAL_BLUR_MAX_SIZE, time = RADIAL_BLUR_RISE_TIME, loop = -1, easing = SINE_EASING, flags = ANIMATION_PARALLEL)
			animate(size = RADIAL_BLUR_MIN_SIZE, time = RADIAL_BLUR_FALL_TIME, easing = SINE_EASING)

#undef RADIAL_BLUR_FILTER_NAME
#undef RADIAL_BLUR_MIN_SIZE
#undef RADIAL_BLUR_MAX_SIZE
#undef RADIAL_BLUR_RISE_TIME
#undef RADIAL_BLUR_FALL_TIME
