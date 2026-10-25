/datum/controller/subsystem/overmap
	var/list/obj/item/overmap_hull_grip/hull_grips = list()

/obj/item/overmap_hull_grip
	name = "захват обшивки"
	desc = "Вы держитесь за обшивку."
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "grab_passive"
	layer = ABOVE_HUD_LAYER
	plane = ABOVE_HUD_PLANE
	item_flags = DROPDEL | ABSTRACT | NOBLUDGEON
	w_class = WEIGHT_CLASS_HUGE
	var/mob/living/holder
	var/obj/overmap/entity/vessel
	var/anchor_x
	var/anchor_y
	var/carrying = FALSE
	var/atom/movable/carried_pull
	var/turf/gripped_turf

/obj/item/overmap_hull_grip/Destroy()
	SSovermap.hull_grips -= src
	if(holder)
		UnregisterSignal(holder, list(COMSIG_MOB_CLIENT_PRE_MOVE, COMSIG_LIVING_RESTING, COMSIG_LIVING_SET_BODY_POSITION, COMSIG_MOVABLE_MOVED))
		var/turf/spot = get_turf(holder)
		if(vessel && is_hyperspace_turf(spot) && SSovermap.frame_owner(spot) == vessel)
			addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(overmap_release_hull), holder, vessel), 0)
	holder = null
	vessel = null
	return ..()

/obj/item/overmap_hull_grip/attack_self(mob/user)
	qdel(src)

/obj/item/overmap_hull_grip/proc/release()
	SIGNAL_HANDLER
	qdel(src)

/obj/item/overmap_hull_grip/proc/on_moved()
	SIGNAL_HANDLER
	if(!carrying)
		qdel(src)

/obj/item/overmap_hull_grip/proc/hold(mob/living/user, obj/overmap/entity/ship, turf/contact)
	var/turf/spot = get_turf(user)
	var/datum/frame = SSovermap.frame_owner(spot)
	if(!frame)
		return FALSE
	var/list/point_world = SSovermap.frame_to_world(frame, spot)
	var/list/anchor = ship.world_to_hull(point_world[1], point_world[2])
	var/turf/destination = SSovermap.world_to_frame(ship, point_world[1], point_world[2])
	if(contact)
		var/nearest = INFINITY
		destination = null
		for(var/turf/candidate in RANGE_TURFS(1, contact))
			if(abs(candidate.x - contact.x) + abs(candidate.y - contact.y) != 1)
				continue
			if(ship.hull_area_turfs[candidate] || SSovermap.frame_owner(candidate) != ship || candidate.is_blocked_turf(exclude_mobs = TRUE))
				continue
			var/distance = (candidate.x - anchor[1]) ** 2 + (candidate.y - anchor[2]) ** 2
			if(distance < nearest)
				destination = candidate
				nearest = distance
	if(!destination || destination.is_blocked_turf(exclude_mobs = TRUE))
		return FALSE
	holder = user
	vessel = ship
	gripped_turf = contact
	anchor_x = destination.x
	anchor_y = destination.y
	qdel(user.GetComponent(/datum/component/drift))
	SSovermap.hull_grips += src
	carried_pull = user.pulling
	carrying = TRUE
	cross_frame_with_pull(user, destination)
	carrying = FALSE
	carried_pull = null
	RegisterSignal(user, COMSIG_MOB_CLIENT_PRE_MOVE, PROC_REF(release))
	RegisterSignal(user, COMSIG_LIVING_RESTING, PROC_REF(release))
	RegisterSignal(user, COMSIG_LIVING_SET_BODY_POSITION, PROC_REF(release))
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))
	playsound(user, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)
	return TRUE

/obj/item/overmap_hull_grip/afterattack(atom/target, mob/user, proximity_flag, list/modifiers, status)
	if(user != holder || holder.incapacitated())
		return
	var/obj/effect/abstract/hull_proxy_tile/proxy = target
	var/turf/spot = istype(proxy) ? proxy.source_turf() : get_turf(target)
	if(!spot || SSovermap.frame_owner(spot) != vessel || fog_hides_from(holder.client, spot))
		return
	if(vessel.hull_area_turfs[spot] && !spot.is_blocked_turf(exclude_mobs = TRUE))
		if(!spot.Adjacent(holder))
			return
		carried_pull = holder.pulling
		carrying = TRUE
		cross_frame_with_pull(holder, spot)
		carrying = FALSE
		carried_pull = null
		qdel(src)
		return
	if(!vessel.hull_turfs[spot] || !gripped_turf || get_dist(gripped_turf, spot) > 1)
		return
	var/turf/destination
	var/nearest = INFINITY
	for(var/turf/candidate in RANGE_TURFS(1, spot))
		if(abs(candidate.x - spot.x) + abs(candidate.y - spot.y) != 1)
			continue
		if(vessel.hull_area_turfs[candidate] || SSovermap.frame_owner(candidate) != vessel || candidate.is_blocked_turf(exclude_mobs = TRUE) || get_dist(holder, candidate) > 1)
			continue
		var/distance = get_dist(holder, candidate) + get_dist(candidate, spot) / 10
		if(distance < nearest)
			destination = candidate
			nearest = distance
	if(!destination)
		return
	carried_pull = holder.pulling
	carrying = TRUE
	cross_frame_with_pull(holder, destination)
	carrying = FALSE
	carried_pull = null
	anchor_x = destination.x
	anchor_y = destination.y
	gripped_turf = spot
	playsound(holder, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)

/proc/overmap_release_hull(mob/living/user, obj/overmap/entity/ship)
	if(QDELETED(user) || QDELETED(ship))
		return
	var/turf/spot = get_turf(user)
	if(is_hyperspace_turf(spot) && SSovermap.frame_owner(spot) == ship)
		ship.eject_to_bubble(user, spot)

/obj/item/overmap_hull_grip/proc/carry()
	if(QDELETED(holder) || QDELETED(vessel) || loc != holder || holder.incapacitated() || holder.body_position == LYING_DOWN || !vessel.free_flight_view)
		qdel(src)
		return
	var/datum/frame = SSovermap.frame_owner(get_turf(holder))
	if(!frame || SSovermap.frame_sector(frame) != vessel.sector)
		qdel(src)
		return
	if(frame == vessel)
		return
	var/list/point_world = vessel.hull_to_world(anchor_x, anchor_y)
	var/turf/target = SSovermap.world_to_frame(frame, point_world[1], point_world[2])
	if(!target || target.is_blocked_turf(exclude_mobs = TRUE))
		qdel(src)
		return
	carrying = TRUE
	cross_frame_with_pull(holder, target)
	carrying = FALSE

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
