/*
Immovable rod random event.
The rod will spawn at some location outside the station, and travel in a straight line to the opposite side of the station
Everything solid in the way will be ex_act()'d
In my current plan for it, 'solid' will be defined as anything with density == 1

--NEOFite
*/

/datum/event/immovable_rod
	announceWhen = 5

/datum/event/immovable_rod/announce()
	GLOB.event_announcement.Announce("Что это за хуйня?!", "ВНИМАНИЕ: ОБЩАЯ ТРЕВОГА.")

/datum/event/immovable_rod/start()
	var/startside = pick(GLOB.cardinal)
	var/level = pick(levels_by_trait(STATION_LEVEL))
	var/turf/startT = spaceDebrisStartLoc(startside, level)
	var/turf/endT = spaceDebrisFinishLoc(startside, level)
	new /obj/effect/immovablerod(startT, endT)


/obj/effect/immovablerod
	name = "\proper незыблемый стержень"
	desc = "Что это за херня?"
	icon = 'icons/obj/objects.dmi'
	icon_state = "immrod"
	throwforce = 100
	move_force = INFINITY
	move_resist = INFINITY
	pull_force = INFINITY
	density = TRUE
	anchored = TRUE
	movement_type = PHASING|FLYING
	/// The turf we're looking to coast to.
	var/turf/destination_turf
	/// Whether we notify ghosts.
	var/notify = TRUE
	/// We can designate a specific target to aim for, in which case we'll try to snipe them rather than just flying in a random direction
	var/atom/special_target
	/// How many mobs we've penetrated one way or another
	var/num_mobs_hit = 0
	/// How many mobs we've hit with clients
	var/num_sentient_mobs_hit = 0
	/// How many people we've hit with clients
	var/num_sentient_people_hit = 0
	/// The rod levels up with each kill, increasing in size and auto-renaming itself.
	var/dnd_style_level_up = FALSE
	/// Whether the rod can loop across other z-levels. The rod will still loop when the z-level is self-looping even if this is FALSE.
	var/loopy_rod = FALSE
	/// Basically our speed, lower = faster
	var/move_delay = 1
	/// Whether this rod was spawned by admins.
	var/admin_spawned = FALSE


/obj/effect/immovablerod/Initialize(mapload, atom/target_atom, atom/special_target, move_delay = 1, force_looping = FALSE)
	. = ..()

	GLOB.poi_list |= src
	src.destination_turf = get_turf(target_atom)
	src.special_target = special_target
	src.move_delay = move_delay
	src.loopy_rod ||= force_looping

	if(!destination_turf && !special_target)
		admin_spawned = TRUE

	RegisterSignal(src, COMSIG_ATOM_ENTERING, PROC_REF(on_entering_atom))

	if(dnd_style_level_up)
		update_appearance(UPDATE_NAME)

	if(notify)
		notify_ghosts("Приближается [name]!", enter_link="<a href=?src=[UID()];follow=1>(Click to follow)</a>", source = src, action = NOTIFY_FOLLOW)

	if(special_target)
		SSmove_manager.home_onto(src, special_target, delay = move_delay)
	else
		SSmove_manager.move_towards(src, destination_turf, delay = move_delay)


/obj/effect/immovablerod/Destroy(force)
	UnregisterSignal(src, COMSIG_ATOM_ENTERING)
	destination_turf = null
	special_target = null
	GLOB.poi_list -= src
	return ..()


/obj/effect/immovablerod/update_name(updates = ALL)
	. = ..()
	if(!dnd_style_level_up)
		name = initial(name)
		return .
	switch(num_sentient_mobs_hit)
		if(0)
			name = "молодой [initial(name)]"
		if(1 to 2)
			name = "[initial(name)] дебютант"
		if(3)
			name = "трёхочковый [initial(name)]"
		if(4 to 10)
			name = "сокрушающий [initial(name)]"
		if(10 to 15)
			name = "неостановимый [initial(name)]"
		if(20 to INFINITY)
			name = "[initial(name)] бич Божий"


/obj/effect/immovablerod/Topic(href, href_list)
	if(href_list["follow"])
		var/mob/dead/observer/ghost = usr
		if(istype(ghost))
			ghost.ManualFollow(src)


/obj/effect/immovablerod/examine(mob/user)
	. = ..()
	if(!isobserver(user))
		return .

	if(!num_mobs_hit)
		. += span_notice("Этот стержень пока не поразил ни одного существа...")
		return .

	. += "\t<span class='notice'>Этот стержень установил следующий счёт: \n\
		\t\t<b>[num_mobs_hit]</b> [declension_ru(num_mobs_hit, "живое существо", "живых существа", "живых существ")], \n\
		\t\t<b>[num_sentient_mobs_hit]</b> из которых [declension_ru(num_sentient_mobs_hit, "обладало", "обладали", "обладали")] разумом, и \n\
		\t\t<b>[num_sentient_people_hit]</b> из них [declension_ru(num_sentient_people_hit, "было гуманоидом", "были гуманоидами", "были гуманоидами")].</span>"


/obj/effect/immovablerod/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	if(!loc)
		return ..()

	for(var/atom/movable/to_bump in loc)
		if((to_bump != src) && !QDELETED(to_bump) && (to_bump.density || isliving(to_bump)))
			Bump(to_bump)

	// If we have a special target, we should definitely make an effort to go find them.
	if(special_target)
		var/turf/target_turf = get_turf(special_target)
		if(!target_turf)	// well they escaped to nullspace, its a shame
			qdel(src)
			return

		// Did they escape the z-level? Let's see if we can chase them down!
		var/z_diff = target_turf.z - z

		if(z_diff)
			var/direction = z_diff > 0 ? UP : DOWN
			var/turf/target_z_turf = get_step_multiz(src, direction)

			visible_message(span_danger("[src] phases out of reality."))

			if(!do_teleport(src, target_z_turf))
				// We failed to teleport. Might as well admit defeat.
				qdel(src)
				return

			visible_message(span_danger("[src] phases into reality."))
			SSmove_manager.home_onto(src, special_target, delay = move_delay)

		if(loc == target_turf)
			complete_trajectory()

		return ..()

	// If we have a destination turf, let's make sure it's also still valid.
	if(destination_turf)

		// If the rod is a loopy_rod, run complete_trajectory() to get a new edge turf to fly to.
		// Otherwise, qdel the rod.
		if(destination_turf.z != z)
			if(loopy_rod)
				complete_trajectory()
				return ..()

			qdel(src)
			return

		// Did we reach our destination? Let's get rid of ourselves.
		// Ordinarily this won't happen as the average destination is the edge of the map and
		// the rod will auto transition to a new z-level.
		if(loc == destination_turf)
			qdel(src)
			return

	return ..()


/obj/effect/immovablerod/possessed_relay_move(mob/user, direction)
	. = ..()
	if(. && !admin_spawned)
		walk_in_direction(direction)


/obj/effect/immovablerod/proc/on_entering_atom(datum/source, atom/destination, atom/oldloc, list/atom/old_locs)
	SIGNAL_HANDLER

	if(destination.density && isturf(destination))
		Bump(destination)


/obj/effect/immovablerod/proc/complete_trajectory(random_shift = FALSE)
	// We hit what we wanted to hit, time to go.
	special_target = null
	if(random_shift)
		walk_in_direction(turn(dir, pick(5; 90, 5; -90, 45; 45, 45; -45)))
	else
		walk_in_direction(dir)


/obj/effect/immovablerod/ex_act(severity)
	return


/obj/effect/immovablerod/singularity_act()
	return


/obj/effect/immovablerod/singularity_pull()
	return


/obj/effect/immovablerod/Process_Spacemove(movement_dir = NONE, continuous_move = FALSE)
	return TRUE


/obj/effect/immovablerod/Bump(atom/clong)
	if(prob(10))
		playsound(src, 'sound/effects/bang.ogg', 50, TRUE)
		audible_message(span_danger("Вы слышите ЛЯЗГ!"))

	if(special_target && clong == special_target)
		complete_trajectory()
	else if(!special_target && !admin_spawned && prob(2))
		complete_trajectory(random_shift = TRUE)

	if(isturf(clong))	// If we Bump into a turf, turf go boom.
		clong.ex_act(EXPLODE_HEAVY)
		return ..()

	if(isobj(clong))	// If we Bump into the object make it suffer
		var/obj/clong_obj = clong
		clong_obj.take_damage(INFINITY, BRUTE, NONE, TRUE, dir, INFINITY)
		return ..()

	if(isliving(clong))	// If we Bump into a living thing, living thing goes splat.
		penetrate(clong)
		return ..()

	if(isatom(clong))	// If we Bump into anything else, anything goes boom.
		clong.ex_act(EXPLODE_HEAVY)
		return ..()

	CRASH("[src] Bump()ed into non-atom thing [clong] ([clong.type])")


/obj/effect/immovablerod/proc/penetrate(mob/living/smeared_mob)
	smeared_mob.visible_message(
		span_danger("[smeared_mob] был пронзён незыблемым стержнем!"),
		span_userdanger("Незыблемый стержень пронзил Вас!"),
		span_danger("Вы слышите ЛЯЗГ!"),
	)

	if(smeared_mob.stat != DEAD)
		num_mobs_hit++
		if(smeared_mob.client)
			num_sentient_mobs_hit++
			if(iscarbon(smeared_mob))
				num_sentient_people_hit++
			if(dnd_style_level_up)
				transform = transform.Scale(1.005, 1.005)
				update_appearance(UPDATE_NAME)

	if(ishuman(smeared_mob))
		smeared_mob.adjustBruteLoss(160)

	if(smeared_mob.density || prob(10))
		smeared_mob.ex_act(EXPLODE_HEAVY)


/* Below are a couple of admin helper procs when dealing with immovable rod memes. */
/**
 * Stops your rod's automated movement. Sit... Stay... Good rod!
 */
/obj/effect/immovablerod/proc/sit_stay_good_rod()
	SSmove_manager.stop_looping(src)


/**
 * Allows your rod to release restraint level zero and go for a walk.
 *
 * If walkies_location is set, rod will move towards the location, chasing it across z-levels if necessary.
 * If walkies_location is not set, rod will call complete_trajectory() and follow the logic from that proc.
 *
 * Arguments:
 * * walkies_location - Any atom that the immovable rod will now chase down as a special target.
 */
/obj/effect/immovablerod/proc/go_for_a_walk(walkies_location = null)
	if(walkies_location)
		special_target = walkies_location
		SSmove_manager.home_onto(src, special_target, delay = move_delay)
		return
	complete_trajectory()


/**
 * Rod will walk towards edge turf in the specified direction.
 *
 * Arguments:
 * * direction - The direction to walk the rod towards: NORTH, SOUTH, EAST, WEST.
 */
/obj/effect/immovablerod/proc/walk_in_direction(direction)
	destination_turf = get_edge_target_turf(src, direction)
	SSmove_manager.move_towards(src, destination_turf, delay = move_delay)

