// Laser sight component

#define LASER_SIGHT_MOUSEUP 0
#define LASER_SIGHT_MOUSEDOWN 1

//MARK: Component
/datum/component/laser_sight
	var/datum/action/toggle_laser_sight/action = null
	var/enable = FALSE
	var/atom/target
	var/turf/target_loc
	var/mouse_parameters
	var/mouse_status = LASER_SIGHT_MOUSEUP
	var/obj/effect/overlay/crosshair = null
	var/obj/effect/overlay/laser_sight_line/current_beam = null
	var/sight_timer = null
	var/atom/sight_target = null


/datum/component/laser_sight/Initialize()
	. = ..()
	if(!isgun(parent))
		return COMPONENT_INCOMPATIBLE
	action = new /datum/action/toggle_laser_sight(src)
	action.sight = src
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equip))
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(on_drop))


/datum/component/laser_sight/Destroy()
	UnregisterSignal(parent, COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED)
	QDEL_NULL(crosshair)
	QDEL_NULL(current_beam)
	QDEL_NULL(action)
	sight_target = null
	return ..()


/datum/component/laser_sight/proc/on_equip(datum/source, mob/user, slot)
	SIGNAL_HANDLER
	if(!(slot & ITEM_SLOT_HANDS))
		// If its not in their hands, disable laser, and remove the action button.
		process_aim(user, FALSE)
		action.Remove(user)
		sight_target = null
		return FALSE

	// The gun is equipped in their hands, give them the zoom ability.
	action.Grant(user)

/datum/component/laser_sight/proc/on_drop(datum/source, mob/user)
	SIGNAL_HANDLER
	process_aim(user, FALSE)
	action.Remove(user)
	sight_target = null
	return FALSE

// There is a gun and there is a user wielding it. The component now waits for the mouse click.
/datum/component/laser_sight/proc/process_aim(mob/user, forced_enable = null)
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

	if(enable)
		crosshair = new /obj/effect/overlay/laser_sight_dot(user.loc)
		current_beam = new /obj/effect/overlay/laser_sight_line(user.loc)
		update_sight_laser(user)
		sight_timer = addtimer(CALLBACK(src, PROC_REF(update_sight_laser), user), 0.1, TIMER_STOPPABLE | TIMER_LOOP)
	else
		QDEL_NULL(crosshair)
		QDEL_NULL(current_beam)
		if(sight_timer)
			deltimer(sight_timer)
			sight_timer = null


/datum/component/laser_sight/proc/update_sight_laser(mob/user)
	if(!isturf(user.loc)) //No laser from inside lockers and stuff.
		//current_beam.alpha = 0
		return
	var/atom/current_target = SSmouse_entered.hovers[user.client]
	if(current_target)
		sight_target = current_target
	if(!sight_target)
		//current_beam.alpha = 0
		return
	if(!isturf(sight_target))
		sight_target = sight_target.loc
	if(!sight_target)
		//current_beam.alpha = 0
		return

	if(current_beam.loc != user.loc)
		current_beam.Move(user.loc, update_dir = FALSE)
	if(crosshair.loc != sight_target)
		crosshair.forceMove(sight_target)
	update_beam(user, crosshair)

/datum/component/laser_sight/proc/update_beam(atom/start, atom/end)
	if(QDELETED(start) || QDELETED(end))
		current_beam.alpha = 0
		return

	var/turf/start_turf = get_turf(start)
	var/turf/end_turf = get_turf(end)

	if(!start_turf || !end_turf)
		current_beam.alpha = 0
		return

	current_beam.alpha = 255
	// Вычисляем трансформацию
	var/dx = (start_turf.x - end_turf.x) * ICON_SIZE_ALL
	var/dy = (start_turf.y - end_turf.y) * ICON_SIZE_ALL
	var/distance = sqrt(dx*dx + dy*dy)
	var/angle = get_stable_angle(dx, dy)
	// Создаем матрицу трансформации
	var/matrix/trans = matrix()
	trans.Translate(0, -ICON_SIZE_ALL/2)
	var/scale = max(distance / ICON_SIZE_ALL, 1)
	trans.Scale(1, scale)  // Растягиваем по X
	trans.Turn(angle)
	animate(current_beam, transform = trans, time = 2)
	// current_beam.transform = trans

/proc/get_stable_angle(dx, dy)
	var/angle = arctan(dy, dx)
	return normalize_angle(angle)

/proc/normalize_angle(angle)
	while(angle > 90)
		angle -= 360
	while(angle < -90)
		angle += 360
	return angle


// MARK: Laser sight action

/datum/action/toggle_laser_sight
	name = "Лазерный целеуказатель"
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_HANDS_BLOCKED|AB_CHECK_INCAPACITATED
	button_icon_state = "sniper_zoom"
	var/datum/component/laser_sight/sight = null

/datum/action/toggle_laser_sight/Trigger(left_click = TRUE)
	sight.process_aim(owner)

/datum/action/toggle_laser_sight/IsAvailable()
	. = ..()
	if(!. && sight)
		sight.process_aim(owner, FALSE)

/datum/action/toggle_laser_sight/Remove(mob/living/living)
	sight.process_aim(living, FALSE)
	..()



//used to show where dropship ordnance will impact.
/obj/effect/overlay/laser_sight_dot
	name = "laser sight dot"
	anchored = TRUE
	light_range = 1
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer = ABOVE_ALL_MOB_LAYER
	icon = 'icons/effects/effects.dmi'
	icon_state = "laser_dot"

/obj/effect/overlay/laser_sight_line
	name = "laser sight beam"
	layer = OBJ_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	icon = 'icons/effects/beam.dmi'
	icon_state = "laser_sight"
