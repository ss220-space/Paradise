#define ACTION_WORKING 0
#define ACTION_FAILED 1
#define ACTION_SUCCEEDED 2

/datum/timed_action
	/// Atom performing the action
	var/atom/movable/user
	/// Atoms on which the action is performed
	var/list/targets
	/// Progress bar displayed to the user/override
	var/datum/progressbar/progressbar
	/// Cog visual displayed to everyone else
	var/datum/cogbar/cogbar
	/// Callback to invoke each tick to check for condition validity
	var/datum/callback/extra_checks
	// Start and end world.tick for the action
	var/start_time
	var/end_time
	/// Flags of our action
	var/timed_action_flags = NONE
	/// Status of the action to pass into the main wait loop
	var/status = ACTION_WORKING
	var/drifting = FALSE
	var/cancel_on_max
	var/cancel_message
	var/category
	var/interaction_key
	var/max_interact_count
	var/datum/weakref/user_loc

/datum/timed_action/New(atom/movable/user, list/targets, delay, show_progress = TRUE, timed_action_flags = NONE, datum/callback/extra_checks = null, cog_icon = null, cog_iconstate = null, mob/bar_override = null, cancel_on_max = FALSE, cancel_message = span_warning("Attempt cancelled."), category = DA_CAT_ALL, interaction_key = null, max_interact_count = null)
	. = ..()
	src.user = user
	src.timed_action_flags = timed_action_flags
	src.extra_checks = extra_checks
	src.cancel_on_max = cancel_on_max
	src.cancel_message = cancel_message
	src.category = category
	if(interaction_key)
		src.interaction_key = interaction_key
	if(max_interact_count)
		src.max_interact_count = max_interact_count
	user_loc = WEAKREF(user.loc)
	if(isnull(targets))
		targets = list(user)
	else if(!islist(targets))
		targets = list(targets)

	src.targets = targets

	drifting = !!GLOB.move_manager.processing_on(user, SSspacedrift)

	if(show_progress)
		if(astype(user, /mob)?.client || bar_override?.client)
			progressbar = new(bar_override || user, delay, targets[1] || user)

		if(!isnull(cog_icon) && delay >= 1 SECONDS)
			cogbar = new(user, cog_icon, cog_iconstate)

#ifdef UNIT_TESTS
	timed_action_flags &= ~DA_IGNORE_SLOWDOWNS // Test dummies are a special case
#endif

	if(!ismob(user))
		timed_action_flags |= DA_IGNORE_HELD_ITEM | DA_IGNORE_INCAPACITATED | DA_IGNORE_SLOWDOWNS
	else if(!(timed_action_flags & DA_IGNORE_SLOWDOWNS))
		delay *= astype(user, /mob).get_actionspeed_by_category(category)

	start_time = world.time
	end_time = world.time + delay

	register_signals()

/datum/timed_action/Destroy(force)
	user = null
	targets = null
	// Only qdel these two in case of an await() runtime/early deletion/whatever, otherwise let them play out their animation and self-delete
	if(status == ACTION_WORKING)
		qdel(progressbar)
		qdel(cogbar)
	progressbar = null
	cogbar = null
	extra_checks = null
	STOP_PROCESSING(SStimed_actions, src)
	status = ACTION_FAILED
	return ..()

/datum/timed_action/proc/register_signals()
	RegisterSignal(user, COMSIG_QDELETING, PROC_REF(on_user_deleted))
	if(cancel_on_max && interaction_key)
		RegisterSignal(user, COMSIG_DO_AFTER_PRE_BEGAN, PROC_REF(on_do_after_pre_began))

	if(timed_action_flags & DA_DO_AFTER_CHECK_NEXT_MOVE)
		RegisterSignal(user, COMSIG_LIVING_CHANGENEXT_MOVE, PROC_REF(on_changenext_move))

	if(!(timed_action_flags & DA_IGNORE_USER_LOC_CHANGE))
		RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(on_user_moved))

	if(!(timed_action_flags & DA_IGNORE_INCAPACITATED))
		RegisterSignal(user, SIGNAL_ADDTRAIT(TRAIT_INCAPACITATED), PROC_REF(on_user_incapacitated))

	if(!(timed_action_flags & DA_IGNORE_LYING))
		RegisterSignal(user, COMSIG_LIVING_SET_BODY_POSITION, PROC_REF(on_living_set_body_position))

	if(!(timed_action_flags & DA_IGNORE_RESTRAINED))
		RegisterSignal(user, SIGNAL_ADDTRAIT(TRAIT_RESTRAINED), PROC_REF(on_user_restrained))

	if(!(timed_action_flags & DA_IGNORE_CONSCIOUSNESS))
		RegisterSignal(user, COMSIG_MOB_STATCHANGE, PROC_REF(on_living_set_body_position))

	var/mob/user_mob = astype(user, /mob)
	var/obj/item/gripper/gripper = user_mob?.get_active_hand()
	if(!(timed_action_flags & DA_IGNORE_EMPTY_GRIPPER) && istype(gripper) && !gripper.isEmpty())
		RegisterSignal(gripper, COMSIG_GRIPPED_ITEM_CHANGE, PROC_REF(on_gripped_item_change))

	if(!(timed_action_flags & DA_IGNORE_HELD_ITEM))
		RegisterSignal(user, COMSIG_MOB_EQUIPPED_ITEM, PROC_REF(on_item_equipped))
		RegisterSignal(user, COMSIG_MOB_SWAP_HANDS, PROC_REF(on_hands_swapped))
		RegisterSignal(user, COMSIG_MOB_UNEQUIPPED_ITEM, PROC_REF(on_item_dropped))

	for(var/atom/target as anything in targets)
		if(target == user)
			continue
		RegisterSignal(target, COMSIG_QDELETING, PROC_REF(on_target_deleted))
		if(!(timed_action_flags & DA_IGNORE_TARGET_LOC_CHANGE))
			RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(on_target_moved))

/datum/timed_action/proc/cancel()
	if(status != ACTION_WORKING)
		return FALSE

	status = ACTION_FAILED
	STOP_PROCESSING(SStimed_actions, src)
	return TRUE

/datum/timed_action/proc/await(delay = world.tick_lag)
	START_PROCESSING(SStimed_actions, src)
	status = ACTION_WORKING

	while(status == ACTION_WORKING && world.time < end_time)
		sleep(world.tick_lag)

	if(status == ACTION_WORKING) // Due to how MC handles sleeping, await will tick first before the subsystem itself, so we need to tick ourselves one last time if we haven't been aborted
		process()

	. = (status == ACTION_SUCCEEDED)

	if(!QDELETED(progressbar))
		progressbar.end_progress()
	if(!QDELETED(cogbar))
		cogbar.remove()

	qdel(src)

/datum/timed_action/process(seconds_per_tick)
	if(extra_checks && !extra_checks.InvokeAsync())
		cancel()
		return

	if(!QDELETED(progressbar))
		progressbar.update(world.time - start_time)

	if(world.time >= end_time)
		status = ACTION_SUCCEEDED
		return PROCESS_KILL

/datum/timed_action/proc/on_user_deleted(datum/source)
	SIGNAL_HANDLER
	user = null
	cancel()

/datum/timed_action/proc/on_do_after_pre_began(mob/source, interaction_key)
	SIGNAL_HANDLER
	if(interaction_key == src.interaction_key)
		var/reduced_interaction_count = LAZYACCESS(source.do_afters, interaction_key)
		if(reduced_interaction_count >= max_interact_count)
			if(cancel_message)
				to_chat(user, "[cancel_message]")
			cancel()

/datum/timed_action/proc/on_target_deleted(datum/source)
	SIGNAL_HANDLER
	targets -= source
	cancel()

/datum/timed_action/proc/on_user_incapacitated(datum/source)
	SIGNAL_HANDLER
	cancel()

/datum/timed_action/proc/on_user_restrained(datum/source)
	SIGNAL_HANDLER
	cancel()

/datum/timed_action/proc/on_changenext_move(datum/source, next_move, delay)
	SIGNAL_HANDLER
	if(next_move > world.time)
		cancel()

/datum/timed_action/proc/on_item_equipped(mob/source, obj/item/item, slot)
	SIGNAL_HANDLER
	// We picked up an item
	if(item == source.get_active_hand())
		cancel()

/datum/timed_action/proc/on_hands_swapped(datum/source)
	SIGNAL_HANDLER
	cancel()

/datum/timed_action/proc/on_item_dropped(mob/source, obj/item/item_dropping, force, atom/newloc, no_move, invdrop, silent, slot)
	SIGNAL_HANDLER
	// Dropped held item
	if(source.get_active_item_slot_hand() == slot)
		cancel()

/datum/timed_action/proc/on_living_set_body_position(mob/source, body_position)
	SIGNAL_HANDLER
	if(source.IsLying())
		cancel()

/datum/timed_action/proc/on_living_stat_change(mob/source, new_stat)
	SIGNAL_HANDLER
	if(source.stat != CONSCIOUS)
		cancel()

/datum/timed_action/proc/on_gripped_item_change(obj/item/gripper/source, new_item)
	SIGNAL_HANDLER
	if(source.isEmpty())
		cancel()

/datum/timed_action/proc/on_user_moved(datum/source, atom/old_loc, dir, forced, list/old_locs)
	SIGNAL_HANDLER

	if(user.loc == old_loc)
		return

	if(drifting && !GLOB.move_manager.processing_on(user, SSspacedrift))
		drifting = FALSE
		user_loc = WEAKREF(user.loc)
		return

	if(!drifting && user.loc != user_loc?.resolve())
		cancel()
		return

	for(var/atom/target as anything in targets)
		if(!target.Adjacent(user))
			cancel()
			return

/datum/timed_action/proc/on_target_moved(atom/movable/source, atom/old_loc, dir, forced, list/old_locs)
	SIGNAL_HANDLER

	if(source.loc == old_loc)
		return

	if(!GLOB.move_manager.processing_on(source, SSspacedrift) || !source.Adjacent(user))
		cancel()

/**
 * Timed action involving one mob user. Target is optional.
 *
 * Checks that `user` does not move, change hands, get stunned, etc. for the
 * given `delay`. Returns `TRUE` on success or `FALSE` on failure.
 *
 * - user - The mob performing the action.
 * - delay - The time in deciseconds. Use the SECONDS define for readability. `1 SECONDS` is 10 deciseconds.
 * - target - The target of the action. This is where the progressbar will display.
 * - timed_action_flags - Flags to control the behavior of the timed action.
 * - show_progress - Whether to display a progress bar / cogbar.
 * - extra_checks - Additional checks to perform before the action is executed.
 * - interaction_key - The assoc key under which the do_after is capped, with max_interact_count being the cap. Interaction key will default to target if not set.
 * - max_interact_count - The maximum amount of interactions allowed.
 * - cog_icon - The icon file of the cog. Default: 'icons/effects/progressbar.dmi'
 * - cog_iconstate - The icon state of the cog. Default: "Cog"
 * - bar_override - Mob which should see the bar instead of the user
 * - cancel_on_max - If `TRUE`, when the interaction limit is reached, the currently running action(s) with the same interaction_key and max_interact_count will be cancelled and the proc will fail. Note: Requires either consistent max_interact_count per interaction_key, or unique interaction_key per distinct max_interact_count value.
 * - cancel_message - Message shown to the user if cancel_on_max is set to `TRUE` and they exceeds max interaction count. Use empty string ("") to skip default cancel message.
 * - category - Used to apply proper action speed modifier to passed delay.
 */
/proc/do_after(atom/movable/user, delay, atom/target, timed_action_flags = DEFAULT_DOAFTER_IGNORE, show_progress = TRUE, datum/callback/extra_checks, interaction_key, max_interact_count = INFINITY, cog_icon = 'icons/effects/progressbar.dmi', cog_iconstate = "cog", mob/bar_override = null, cancel_on_max = FALSE, cancel_message = span_warning("Attempt cancelled."), category = DA_CAT_ALL)
	if(!user)
		return FALSE
	var/mob/as_mob = astype(user, /mob)
	if((!(timed_action_flags & DA_IGNORE_CONSCIOUSNESS) && as_mob.stat) \
		|| (!(timed_action_flags & DA_IGNORE_LYING) && as_mob.IsLying()) \
		|| (!(timed_action_flags & DA_IGNORE_INCAPACITATED) && HAS_TRAIT_NOT_FROM(as_mob, TRAIT_INCAPACITATED, STAT_TRAIT)) \
		|| (!(timed_action_flags & DA_IGNORE_RESTRAINED) && HAS_TRAIT(as_mob, TRAIT_RESTRAINED)))
		return FALSE

	ASSERT(isnum(delay), "do_after was passed a non-number delay: [delay || "null"].")
	ASSERT(!isnum(target), "a do_after created by [user] had a target set as [target] - probably intended to be the time instead.")
	ASSERT(!isatom(delay), "a do_after created by [user] had a timer of [delay] - probably intended to be the target instead.")

	if(delay <= 0)
		return TRUE

	if(!interaction_key && ismob(user))
		if(!islist(target))
			if(cancel_on_max)
				interaction_key = "[UID_of(target)]+[max_interact_count]"
			else
				interaction_key = target //Use the direct ref to the target
		else
			var/list/temp = list()
			for(var/atom/atom as anything in target)
				temp += atom.UID()

			sortTim(temp, GLOBAL_PROC_REF(cmp_text_asc))
			interaction_key = jointext(temp, "-")

	SEND_SIGNAL(user, COMSIG_DO_AFTER_PRE_BEGAN, interaction_key)

	if(interaction_key && ismob(user)) // Do we have a interaction_key now?
		var/current_interaction_count = LAZYACCESS(as_mob.do_afters, interaction_key)
		if(current_interaction_count >= max_interact_count) // We are at our peak
			return
		LAZYSET(as_mob.do_afters, interaction_key, current_interaction_count + 1)

	SEND_SIGNAL(user, COMSIG_DO_AFTER_BEGAN)

	var/datum/timed_action/action = new(user, target, delay, show_progress, timed_action_flags, extra_checks, cog_icon, cog_iconstate, bar_override, interaction_key = interaction_key, max_interact_count = max_interact_count)

	. = action.await()

	if(interaction_key && ismob(user))
		var/reduced_interaction_count = LAZYACCESS(as_mob.do_afters, interaction_key)
		if(reduced_interaction_count > 1) // Not done yet!
			LAZYSET(as_mob.do_afters, interaction_key, reduced_interaction_count - 1)
		else
			LAZYREMOVE(as_mob.do_afters, interaction_key)
	SEND_SIGNAL(user, COMSIG_DO_AFTER_ENDED)

#undef ACTION_WORKING
#undef ACTION_FAILED
#undef ACTION_SUCCEEDED
