/proc/overmap_release_hull(mob/living/user, obj/overmap/entity/ship)
	if(QDELETED(user) || QDELETED(ship))
		return
	var/turf/spot = get_turf(user)
	if(is_hyperspace_turf(spot) && SSovermap.frame_owner(spot) == ship)
		ship.eject_to_bubble(user, spot)

/proc/overmap_grab_hull(mob/living/user, turf/target)
	if(!istype(user) || user.a_intent != INTENT_GRAB || user.incapacitated() || user.buckled || user.body_position == LYING_DOWN || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !isturf(user.loc) || !target)
		return FALSE
	var/obj/overmap/entity/ship = SSovermap.frame_owner(target)
	if(!istype(ship) || !ship.hull_turfs[target] || ship.hull_area_turfs[get_turf(user)])
		return FALSE
	var/turf/projected = SSovermap.mirror_turf(target, get_turf(user))
	if(!projected || !projected.Adjacent(user) || fog_hides_from(user.client, target))
		return FALSE
	if(user.get_active_hand())
		return !istype(user.get_active_hand(), /obj/item/overmap_hull_grip)
	var/obj/item/overmap_hull_grip/grip = new
	if(!user.put_in_active_hand(grip))
		qdel(grip)
		return TRUE
	if(!grip.hold(user, ship, target))
		qdel(grip)
	return TRUE

/proc/overmap_hull_gripped(atom/movable/thing, obj/overmap/entity/ship)
	if(!ship.free_flight_view)
		return FALSE
	for(var/obj/item/overmap_hull_grip/grip as anything in SSovermap.hull_grips)
		if(grip.vessel == ship && grip.carrying && grip.carried_pull == thing && grip.loc == grip.holder)
			return TRUE
	var/mob/living/user = isliving(thing) ? thing : thing.pulledby
	if(!istype(user))
		return FALSE
	for(var/obj/item/overmap_hull_grip/grip in list(user.get_active_hand(), user.get_inactive_hand()))
		if(!QDELETED(grip) && grip.holder == user && grip.vessel == ship)
			return TRUE
	return FALSE

/proc/overmap_board_from_drag(mob/living/user, turf/target)
	if(!istype(user) || user.incapacitated() || user.buckled || !isturf(user.loc) || !target || target.is_blocked_turf(exclude_mobs = TRUE) || !target.Adjacent(user))
		return
	var/datum/source_frame = SSovermap.frame_owner(user.loc)
	var/datum/target_frame = SSovermap.frame_owner(target)
	if(!source_frame || !target_frame || SSovermap.frame_sector(source_frame) != SSovermap.frame_sector(target_frame))
		return
	if(!do_after(user, 1 SECONDS, target = target))
		return
	if(target.is_blocked_turf(exclude_mobs = TRUE) || !target.Adjacent(user))
		return
	for(var/obj/item/overmap_hull_grip/grip in list(user.get_active_hand(), user.get_inactive_hand()))
		grip.carrying = TRUE
	cross_frame_with_pull(user, target)
	for(var/obj/item/overmap_hull_grip/grip in list(user.get_active_hand(), user.get_inactive_hand()))
		qdel(grip)
