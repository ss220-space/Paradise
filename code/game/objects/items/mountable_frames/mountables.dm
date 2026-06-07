/obj/item/mounted
	/// The list of types on which it can be built
	var/list/buildon_types = list(/turf/simulated/wall)
	/// For frames that are external to the wall they are placed on, like light fixtures and cameras.
	var/wall_external = FALSE
	/// Is it possible to build it on the floor?
	var/allow_floor_mounting = FALSE

/obj/item/mounted/afterattack(atom/target, mob/user, proximity_flag, list/modifiers, status)
	if(is_type_in_list(target, buildon_types))
		if(try_build(target, user))
			return do_build(target, user)
	..()

/**
 * Check if we can build on this support structure
 *
 * Arguments
 * * atom/support - the atom we are trying to mount on
 * * mob/user - the player attempting to do the mount
*/
/obj/item/mounted/proc/try_build(atom/support, mob/user)
	if(!support || !user)
		return FALSE

	if(get_dist(support, user) > 1)
		balloon_alert(user, "вы слишком далеко!")
		return FALSE

	if(allow_floor_mounting)
		return TRUE

	var/floor_to_support = get_dir(support, user)
	if(!(floor_to_support in GLOB.cardinal))
		balloon_alert(user, "встаньте лицом к стене!")
		return FALSE

	var/turf/wall_location = get_turf(user)
	if(check_wall_item(wall_location, floor_to_support, wall_external))
		balloon_alert(user, "здесь уже что-то есть!")
		return FALSE

	return TRUE

/obj/item/mounted/proc/do_build(turf/on_wall, mob/user) //the buildy bit after we pass the checks
	return
