/atom/movable/attack_hand(mob/living/user, list/modifiers)
	. = ..()

	if(can_buckle && has_buckled_mobs())
		if(length(buckled_mobs) > 1)
			var/mob/living/unbuckled = tgui_input_list(user, "Who do you wish to unbuckle?", "Unbuckle", sort_names(buckled_mobs))
			if(isnull(unbuckled))
				return .
			if(user_unbuckle_mob(unbuckled, user))
				return TRUE
		else
			if(user_unbuckle_mob(buckled_mobs[1], user))
				return TRUE


/atom/movable/MouseDrop_T(mob/living/dropping, mob/living/user, params)
	. = ..()
	return mouse_buckle_handling(dropping, user)


/atom/movable/attack_robot(mob/living/user)
	. = ..()

	if(can_buckle && has_buckled_mobs() && Adjacent(user))
		if(length(buckled_mobs) > 1)
			var/mob/living/unbuckled = tgui_input_list(user, "Who do you wish to unbuckle?", "Unbuckle", sort_names(buckled_mobs))
			if(isnull(unbuckled))
				return .
			if(user_unbuckle_mob(unbuckled, user))
				return TRUE
		else
			if(user_unbuckle_mob(buckled_mobs[1], user))
				return TRUE


/**
 * Does some typechecks and then calls user_buckle_mob
 *
 * Arguments:
 * target - The mob being buckled to src
 * user - The mob buckling target to src
 */
/atom/movable/proc/mouse_buckle_handling(mob/living/target, mob/living/user)
	if(can_buckle && istype(target) && istype(user))
		return user_buckle_mob(target, user, check_loc = FALSE)


/**
 * Returns amount of mobs buckled to us.
 */
/atom/movable/proc/has_buckled_mobs()
	return length(buckled_mobs)


/**
 * Set a mob as buckled to src
 *
 * If you want to have a mob buckling another mob to something, or you want a chat message sent, use user_buckle_mob instead.
 * Arguments:
 * * target - The mob to be buckled to src
 * * force - Set to TRUE to ignore src's can_buckle and target's can_buckle_to
 * * check_loc - Set to FALSE to allow buckling from adjacent turfs, or TRUE if buckling is only allowed with src and target on the same turf.
 */
/atom/movable/proc/buckle_mob(mob/living/target, force = FALSE, check_loc = TRUE)
	if(!buckled_mobs)
		buckled_mobs = list()

	if(!is_buckle_possible(target, force, check_loc))
		return FALSE

	// check if we are failed to move from adjacent turf
	if(!check_loc && target.loc != loc)
		var/old_flags = target.pass_flags
		target.pass_flags = PASSEVERYTHING
		if(!target.Move(loc) || target.loc != loc)	// no move or still the same loc, even after move
			target.pass_flags = old_flags
			return FALSE
		target.pass_flags = old_flags

	if(target.pulledby)
		if(buckle_prevents_pull)
			target.pulledby.stop_pulling()
		else if(isliving(target.pulledby))
			target.pulledby.reset_pull_offsets(target, override = TRUE)

	if(anchored)
		ADD_TRAIT(target, TRAIT_NO_FLOATING_ANIM, BUCKLED_TRAIT)
	if(!length(buckled_mobs))
		RegisterSignal(src, COMSIG_MOVABLE_SET_ANCHORED, PROC_REF(on_set_anchored))
	target.set_buckled(src)
	buckled_mobs |= target
	target.throw_alert(ALERT_BUCKLED, /atom/movable/screen/alert/restrained/buckled)
	target.set_glide_size(glide_size)
	target.setDir(dir)

	post_buckle_mob(target)

	SEND_SIGNAL(src, COMSIG_MOVABLE_BUCKLE, target, force)
	return TRUE


/obj/buckle_mob(mob/living/target, force = FALSE, check_loc = TRUE)
	. = ..()
	if(. && (resistance_flags & ON_FIRE))	//Sets the mob on fire if you buckle them to a burning atom/movableect
		target.adjust_fire_stacks(1)
		target.IgniteMob()


/atom/movable/proc/on_set_anchored(atom/movable/source, anchorvalue)
	SIGNAL_HANDLER

	for(var/mob/living/buckled_mob as anything in buckled_mobs)
		if(anchored)
			ADD_TRAIT(buckled_mob, TRAIT_NO_FLOATING_ANIM, BUCKLED_TRAIT)
		else
			REMOVE_TRAIT(buckled_mob, TRAIT_NO_FLOATING_ANIM, BUCKLED_TRAIT)


/**
 * Set a mob as unbuckled from src
 *
 * The mob must actually be buckled to src or else bad things will happen.
 * Arguments:
 * * buckled_mob - The mob to be unbuckled
 * * force - TRUE if we should ignore buckled_mob.can_buckle_to
 * * can_fall - TRUE if we are checking for zFall possibilities
 */
/atom/movable/proc/unbuckle_mob(mob/living/buckled_mob, force = FALSE, can_fall = TRUE)
	if(!isliving(buckled_mob))
		CRASH("Non-living [buckled_mob] thing called unbuckle_mob() for source.")
	if(buckled_mob.buckled != src)
		CRASH("[buckled_mob] called unbuckle_mob() for source while having buckled as [buckled_mob.buckled].")
	if(!force && !buckled_mob.can_buckle_to)
		return
	. = buckled_mob
	buckled_mob.set_buckled(null)
	buckled_mob.set_anchored(initial(buckled_mob.anchored))
	buckled_mob.clear_alert(ALERT_BUCKLED)
	buckled_mob.set_glide_size(DELAY_TO_GLIDE_SIZE(buckled_mob.cached_multiplicative_slowdown))
	buckled_mobs -= buckled_mob
	if(anchored)
		REMOVE_TRAIT(buckled_mob, TRAIT_NO_FLOATING_ANIM, BUCKLED_TRAIT)
	if(!length(buckled_mobs))
		UnregisterSignal(src, COMSIG_MOVABLE_SET_ANCHORED)
	SEND_SIGNAL(src, COMSIG_MOVABLE_UNBUCKLE, buckled_mob, force)

	if(can_fall)
		var/turf/location = buckled_mob.loc
		if(istype(location) && !buckled_mob.currently_z_moving)
			location.zFall(buckled_mob)

	post_unbuckle_mob(.)

	if(!QDELETED(buckled_mob) && !buckled_mob.currently_z_moving && isturf(buckled_mob.loc)) // In the case they unbuckled to a flying movable midflight.
		var/turf/pitfall = buckled_mob.loc
		pitfall?.zFall(buckled_mob)


/**
 * Call [/atom/movable/proc/unbuckle_mob] for all buckled mobs
 */
/atom/movable/proc/unbuckle_all_mobs(force = FALSE)
	if(!has_buckled_mobs())
		return
	for(var/mob in buckled_mobs)
		unbuckle_mob(mob, force)


/**
 * Handle any extras after buckling.
 * Called on buckle_mob()
 */
/atom/movable/proc/post_buckle_mob(mob/living/target)
	return


/**
 * Handle any extras after unbuckling.
 * Called on unbuckle_mob()
 */
/atom/movable/proc/post_unbuckle_mob(mob/living/target)
	return


/**
 * Simple helper proc that runs a suite of checks to test whether it is possible or not to buckle the target mob to src.
 *
 * Returns FALSE if any conditions that should prevent buckling are satisfied. Returns TRUE otherwise.
 * Called from [/atom/movable/proc/buckle_mob] and [/atom/movable/proc/is_user_buckle_possible].
 * Arguments:
 * * target - Target mob to check against buckling to src.
 * * force - Whether or not the buckle should be forced. If TRUE, ignores src's can_buckle var and target's can_buckle_to
 * * check_loc - TRUE if target and src have to be on the same tile, FALSE if buckling is allowed from adjacent tiles
 */
/atom/movable/proc/is_buckle_possible(mob/living/target, force = FALSE, check_loc = TRUE)
	// Make sure target is mob/living
	if(!istype(target))
		return FALSE

	// No bucking you to yourself.
	if(target == src)
		return FALSE

	// Check if we are in turf contents
	if(!isturf(loc) || !isturf(target.loc))
		return FALSE

	// Check for another dense objects in loc
	var/turf/ground = loc
	if(ground.is_blocked_turf(source_atom = src, ignore_atoms = list(src, target)))
		return FALSE

	// Check if this atom can have things buckled to it.
	if(!can_buckle && !force)
		return FALSE

	// If we're checking the loc, make sure the target is on the thing we're bucking them to.
	if(check_loc && target.loc != loc)
		return FALSE

	// Otherwise it should be at least adjacent to src.
	else if(!check_loc && !target.Adjacent(src))
		return FALSE

	// Make sure the target isn't already buckled to something.
	if(target.buckled)
		return FALSE

	// Make sure this atom can still have more things buckled to it.
	if(has_buckled_mobs() >= max_buckled_mobs)
		return FALSE

	// Stacking buckling leads to lots of jank and issues, better to just nix it entirely
	if(target.has_buckled_mobs())
		return FALSE

	// If the buckle requires restraints, make sure the target is actually restrained.
	if(buckle_requires_restraints && !HAS_TRAIT(target, TRAIT_RESTRAINED))
		return FALSE

	//If buckling is forbidden for the target, cancel
	if(!target.can_buckle_to && !force)
		return FALSE

	return TRUE


/**
 * Simple helper proc that runs a suite of checks to test whether it is possible or not for user to buckle target mob to src.
 *
 * Returns FALSE if any conditions that should prevent buckling are satisfied. Returns TRUE otherwise.
 * Called from [/atom/movable/proc/user_buckle_mob].
 * Arguments:
 * * target - Target mob to check against buckling to src.
 * * user - The mob who is attempting to buckle the target to src.
 * * check_loc - TRUE if target and src have to be on the same tile, FALSE if buckling is allowed from adjacent tiles
 */
/atom/movable/proc/is_user_buckle_possible(mob/living/target, mob/living/carbon/user, check_loc = TRUE)
	// Standard adjacency and other checks.
	if(!Adjacent(user) || !Adjacent(target) || !isturf(user.loc) || user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || target.anchored)
		return FALSE

	if(iscarbon(user) && user.usable_hands <= 0)
		return FALSE

	// Is buckling even possible in the first place?
	if(!is_buckle_possible(target, FALSE, check_loc))
		return FALSE

	return TRUE


/**
 * Handles a mob buckling another mob to src and sends a visible_message
 *
 * Basically exists to do some checks on the user and then call buckle_mob where the real buckling happens.
 * First, checks if the buckle is valid and cancels if it isn't.
 * Second, checks if src is on a different turf from the target; if it is, does a do_after and another check for sanity
 * Finally, calls [/atom/movable/proc/buckle_mob] to buckle the target to src then gives chat feedback
 * Arguments:
 * * target - The target mob/living being buckled to src
 * * user - The other mob that's buckling target to src
 * * check_loc - TRUE if src and target have to be on the same turf, false otherwise
 */
/atom/movable/proc/user_buckle_mob(mob/living/target, mob/living/user, check_loc = TRUE)
	// Is buckling even possible? Do a full suite of checks.
	if(!is_user_buckle_possible(target, user, check_loc))
		return FALSE

	add_fingerprint(user)

	if(target != user) // Cheks if user interacts with himself
		target.visible_message(
			span_warning("[user] is trying to buckle [target] to [src]!"),
			span_userdanger("[user] is trying to buckle you to [src]!"),
			span_italics("You hear metal clanking."),
		)
		if(!do_after(user, 0.7 SECONDS, target, NONE))
			to_chat(user, span_warning("You failed to buckle [target]."))
			return FALSE

		// Sanity check before we attempt to buckle. Is everything still in a kosher state for buckling after the delay?
		// Covers situations where, for example, the chair was moved or there's some other issue.
		if(!is_user_buckle_possible(target, user, check_loc))
			return FALSE

	. = buckle_mob(target, check_loc = check_loc)
	if(.)
		if(target == user)
			target.visible_message(
				span_notice("[target] buckles [target.p_them()]self to [src]."),
				span_notice("You buckle yourself to [src]."),
				span_italics("You hear metal clanking."),
			)
		else
			target.visible_message(
				span_warning("[user] buckles [target] to [src]!"),
				span_warning("[user] buckles you to [src]!"),
				span_italics("You hear metal clanking."),
			)


/**
 * Handles a user unbuckling a mob from src and sends a visible_message
 *
 * Basically just calls unbuckle_mob, sets fingerprint, and sends a visible_message
 * about the user unbuckling the mob
 * Arguments:
 * * target - The mob/living to unbuckle
 * * user - The mob unbuckling target
 */
/atom/movable/proc/user_unbuckle_mob(mob/living/target, mob/living/user)
	if(!(target in buckled_mobs) || !user.Adjacent(target))
		return
	var/mob/living/buckled_mob = unbuckle_mob(target)
	if(buckled_mob)
		if(buckled_mob != user)
			buckled_mob.visible_message(
				span_notice("[user] unbuckles [buckled_mob] from [src]."),
				span_notice("[user] unbuckles you from [src]."),
				span_italics("You hear metal clanking."),
			)
		else
			buckled_mob.visible_message(
				span_notice("[buckled_mob] unbuckles [buckled_mob.p_them()]self from [src]."),
				span_notice("You unbuckle yourself from [src]."),
				span_italics("You hear metal clanking."),
			)
		add_fingerprint(user)
		if(isliving(buckled_mob.pulledby))
			buckled_mob.pulledby.set_pull_offsets(buckled_mob, buckled_mob.pulledby.grab_state)
	return buckled_mob


/mob/living/proc/check_buckled()
	if(buckled && !(buckled in loc))
		buckled.unbuckle_mob(src, force = TRUE)

