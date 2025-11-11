// Laser sight component

//MARK: Base component
/datum/component/laser_sight
	var/enable = FALSE
	var/datum/action/toggle_laser_sight/action = null
	var/sight_timer = null
	var/atom/sight_target = null

/datum/component/laser_sight/Initialize()
	. = ..()
	if(!isgun(parent))
		return COMPONENT_INCOMPATIBLE
	action = new /datum/action/toggle_laser_sight(src)
	action.sight = src

/datum/component/laser_sight/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equip))
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(on_drop))
	RegisterSignal(parent, COMSIG_GUN_MODULE_ATTACH, PROC_REF(on_attach_module))
	RegisterSignal(parent, COMSIG_GUN_MODULE_DETACH, PROC_REF(on_detach_module))
	RegisterSignal(parent, COMSIG_KEYBINDING_GUN_LASER_SIGHT, PROC_REF(on_laser_sight_keybinding))

/datum/component/laser_sight/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED, COMSIG_GUN_MODULE_ATTACH, COMSIG_GUN_MODULE_DETACH)

/datum/component/laser_sight/Destroy()
	QDEL_NULL(action)
	sight_target = null
	if(sight_timer)
		deltimer(sight_timer)
		sight_timer = null
	return ..()

/datum/component/laser_sight/proc/on_equip(datum/source, mob/user, slot)
	SIGNAL_HANDLER

	if(!(slot & ITEM_SLOT_HANDS))
		// If its not in their hands, disable laser, and remove the action button.
		toggle_enable(user, FALSE)
		process_aim(user)
		action.Remove(user)
		sight_target = null
		return FALSE

	// The gun is equipped in their hands, give them the zoom ability.
	action.Grant(user)

/datum/component/laser_sight/proc/on_attach_module(datum/source, mob/user, obj/item/gun, obj/item/gun_module/gun_mod)
	SIGNAL_HANDLER

	if(!user.is_in_hands(gun))
		return
	on_equip(src, user, ITEM_SLOT_HANDS)

/datum/component/laser_sight/proc/on_detach_module(datum/source, mob/user, obj/item/gun, obj/item/gun_module/gun_mod)
	SIGNAL_HANDLER

	on_drop(source, user)

/datum/component/laser_sight/proc/on_drop(datum/source, mob/user)
	SIGNAL_HANDLER

	toggle_enable(user, FALSE)
	process_aim(user)
	action.Remove(user)
	sight_target = null
	return FALSE

/datum/component/laser_sight/proc/on_laser_sight_keybinding(datum/sourc, mob/user, obj/item/gun/target_gun)
	SIGNAL_HANDLER

	toggle_enable(user)
	process_aim(user)

// There is a gun and there is a user wielding it. The component now waits for the mouse click.
/datum/component/laser_sight/proc/toggle_enable(mob/user, forced_enable = null)
	var/old_enable = enable
	switch(forced_enable)
		if(FALSE)
			enable = FALSE
		if(TRUE)
			enable = TRUE
		else
			enable = !enable

	if(old_enable == enable)
		return // no changes
	if(!parent)
		return
	SEND_SIGNAL(parent, COMSIG_GUN_AFTER_LASER_SIGHT_TOGGLE, user, enable)

/datum/component/laser_sight/proc/process_aim(mob/user)
	if(enable)
		on_enable_sight(user)
		update_sight_laser(user)
		sight_timer = addtimer(CALLBACK(src, PROC_REF(update_sight_laser), user), 0.1, TIMER_STOPPABLE | TIMER_LOOP)
		return
	on_disable_sight(user)
	if(!sight_timer)
		return
	deltimer(sight_timer)
	sight_timer = null

/datum/component/laser_sight/proc/on_enable_sight(mob/user)
	return

/datum/component/laser_sight/proc/on_disable_sight(mob/user)
	return

/datum/component/laser_sight/proc/update_sight_laser(mob/user)
	if(!isturf(user.loc)) //No laser from inside lockers and stuff.
		return
	var/atom/current_target = SSmouse_entered.hovers[user.client]
	if(current_target) //Target updated
		sight_target = current_target
	if(sight_target && !isturf(sight_target)) //convert target to turf
		sight_target = sight_target.loc
	if(!sight_target)//No still exists target, skip it
		return
	on_update_sight(user)

/datum/component/laser_sight/proc/on_update_sight(mob/user)
	return

/datum/component/laser_sight/ClearFromParent()
	if(enable)
		toggle_enable(usr, FALSE)
		process_aim(usr)
	. = ..()

// MARK: Point

/datum/component/laser_sight/point
	var/obj/effect/overlay/point = null
	var/move_range = 8
	var/animation_speed = 2 SECONDS
	var/rand_move_timer = null

/datum/component/laser_sight/point/Destroy()
	QDEL_NULL(point)
	if(rand_move_timer)
		deltimer(rand_move_timer)
		rand_move_timer = null
	. = ..()

/datum/component/laser_sight/point/on_enable_sight(mob/user)
	point = new /obj/effect/overlay/laser_sight_dot(user.loc)
	start_point_random_move()

/datum/component/laser_sight/point/proc/start_point_random_move()
	if(QDELETED(src))
		return
	var/target_x = rand(-move_range, move_range)
	var/target_y = rand(-move_range, move_range)
	var/duration = randfloat(animation_speed * 0.5, animation_speed * 1.5)
	animate(point,
		pixel_x = target_x,
		pixel_y = target_y,
		time = duration,
		easing = SINE_EASING,
		flags = ANIMATION_PARALLEL)
	rand_move_timer = addtimer(CALLBACK(src, PROC_REF(start_point_random_move)), duration, TIMER_STOPPABLE)

/datum/component/laser_sight/point/on_disable_sight(mob/user)
	QDEL_NULL(point)
	if(!rand_move_timer)
		return
	deltimer(rand_move_timer)
	rand_move_timer = null

/datum/component/laser_sight/point/on_update_sight(mob/user)
	if(point.loc == sight_target)
		return
	point.forceMove(sight_target)

// MARK: Ray

/datum/component/laser_sight/ray
	var/obj/effect/overlay/laser_sight_line/current_beam = null
	var/obj/effect/overlay/laser_sight_dot/point = null
	var/move_range = 8

/datum/component/laser_sight/ray/Destroy()
	QDEL_NULL(current_beam)
	QDEL_NULL(point)
	. = ..()

/datum/component/laser_sight/ray/on_enable_sight(mob/user)
	current_beam = new /obj/effect/overlay/laser_sight_line(user.loc)
	point = new /obj/effect/overlay/laser_sight_dot/invisible(user.loc)

/datum/component/laser_sight/ray/on_disable_sight(mob/user)
	QDEL_NULL(current_beam)
	QDEL_NULL(point)

/datum/component/laser_sight/ray/on_update_sight(mob/user)
	if(current_beam.loc != user.loc)
		current_beam.Move(user.loc, update_dir = FALSE)
	update_point(user)
	update_beam(user, point)

/datum/component/laser_sight/ray/proc/update_point(mob/user)
	if(point.loc != sight_target)
		point.forceMove(sight_target)
	if(!prob(50))
		return
	point.pixel_x = clamp(point.pixel_x + rand(-1, 1), -move_range, move_range)
	point.pixel_y = clamp(point.pixel_y + rand(-1, 1), -move_range, move_range)

/datum/component/laser_sight/ray/proc/update_beam(atom/start, atom/end)
	if(QDELETED(start) || QDELETED(end))
		return
	var/turf/start_turf = get_turf(start)
	var/turf/end_turf = get_turf(end)
	if(!start_turf || !end_turf)
		return
	//calculate transform
	var/dx = (start_turf.x - end_turf.x) * ICON_SIZE_ALL + (start.pixel_x - end.pixel_x)
	var/dy = (start_turf.y - end_turf.y) * ICON_SIZE_ALL + (start.pixel_y - end.pixel_y)
	var/distance = sqrt(dx * dx + dy * dy)
	var/angle = arctan(dy, dx)
	angle = normalize_angle(angle)
	get_angle()
	var/matrix/trans = matrix()
	trans.Translate(0, -ICON_SIZE_ALL / 2)
	//scale to distance
	var/scale = max(distance / ICON_SIZE_ALL, 0)
	trans.Scale(1, scale)
	trans.Turn(angle)
	animate(current_beam, transform = trans, time = 2)

/datum/component/laser_sight/ray/proc/get_stable_angle(dx, dy)
	var/angle = arctan(dy, dx)
	return normalize_angle(angle)

// MARK: Action

/datum/action/toggle_laser_sight
	name = "Лазерный целеуказатель"
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_HANDS_BLOCKED|AB_CHECK_INCAPACITATED
	button_icon_state = "sniper_zoom"
	var/datum/component/laser_sight/sight = null

/datum/action/toggle_laser_sight/Trigger(left_click = TRUE)
	sight.toggle_enable(owner)
	sight.process_aim(owner)

/datum/action/toggle_laser_sight/IsAvailable()
	. = ..()
	if(. || !sight)
		return
	sight.toggle_enable(owner, FALSE)
	sight.process_aim(owner)

/datum/action/toggle_laser_sight/Remove(mob/living/living)
	sight.toggle_enable(owner, FALSE)
	sight.process_aim(living)
	return ..()

// MARK: Effects

/obj/effect/overlay/laser_sight_dot
	name = "laser sight dot"
	light_range = 1
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer = ABOVE_ALL_MOB_LAYER
	icon_state = "laser_dot"

/obj/effect/overlay/laser_sight_dot/invisible
	alpha = 0

/obj/effect/overlay/laser_sight_line
	name = "laser sight ray"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	icon = 'icons/effects/beam.dmi'
	icon_state = "laser_sight"
