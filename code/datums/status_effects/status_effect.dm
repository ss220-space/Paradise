//Status effects are used to apply temporary or permanent effects to mobs. Mobs are aware of their status effects at all times.
//This file contains their code, plus code for applying and removing them.
//When making a new status effect, add a define to status_effects.dm in __DEFINES for ease of use!

/datum/status_effect
	/// The ID of the effect. ID is used in adding and removing effects to check for duplicates, among other things.
	var/id = "effect"
	/// When set initially / in on_creation, this is how long the status effect lasts in deciseconds.
	/// While processing, this becomes the world.time when the status effect will expire.
	/// -1 = infinite duration.
	var/duration = -1
	/// When set initially / in on_creation, this is how long between [proc/tick] calls in deciseconds.
	/// Note that this cannot be faster than the processing subsystem you choose to fire the effect on. (See: [var/processing_speed])
	/// While processing, this becomes the world.time when the next tick will occur.
	/// -1 = will prevent ticks, and if duration is also unlimited (-1), stop processing wholesale.
	var/tick_interval = 1 SECONDS
	/// The mob affected by the status effect.
	var/mob/living/owner
	/// How many of the effect can be on one mob, and/or what happens when you try to add a duplicate.
	var/status_type = STATUS_EFFECT_UNIQUE
	/// If TRUE, we call [proc/on_remove] when owner is deleted. Otherwise, we call [proc/be_replaced].
	var/on_remove_on_mob_delete = FALSE
	/// If defined, this text will appear when the mob is examined - to use he, she etc.
	/// use "SUBJECTPRONOUN" and replace it in the examines themselves
	var/examine_text
	/// The typepath to the alert thrown by the status effect when created.
	/// Status effect "name"s and "description"s are shown to the owner here.
	var/alert_type = /atom/movable/screen/alert/status_effect
	/// The alert itself, created in [proc/on_creation] (if alert_type is specified).
	var/atom/movable/screen/alert/status_effect/linked_alert
	/// Used to define if the status effect should be using SSfastprocess or SSprocessing
	var/processing_speed = STATUS_EFFECT_FAST_PROCESS


/datum/status_effect/New(list/arguments)
	on_creation(arglist(arguments))


/// Called from New() with any supplied status effect arguments.
/// Not guaranteed to exist by the end.
/// Returning FALSE from on_apply will stop on_creation and self-delete the effect.
/datum/status_effect/proc/on_creation(mob/living/new_owner, ...)
	if(new_owner)
		owner = new_owner
	if(QDELETED(owner) || !on_apply())
		qdel(src)
		return FALSE
	if(owner)
		LAZYADD(owner.status_effects, src)
	if(duration != -1)
		duration = world.time + duration
	if(tick_interval != -1)
		tick_interval = world.time + tick_interval
	if(alert_type)
		var/atom/movable/screen/alert/status_effect/A = owner.throw_alert(id, alert_type)
		A.attached_effect = src //so the alert can reference us, if it needs to
		linked_alert = A //so we can reference the alert, if we need to
	if(duration > world.time || tick_interval > world.time) //don't process if we don't care
		switch(processing_speed)
			if(STATUS_EFFECT_FAST_PROCESS)
				START_PROCESSING(SSfastprocess, src)
			if(STATUS_EFFECT_NORMAL_PROCESS)
				START_PROCESSING(SSprocessing, src)
	return TRUE


/datum/status_effect/Destroy()
	switch(processing_speed)
		if(STATUS_EFFECT_FAST_PROCESS)
			STOP_PROCESSING(SSfastprocess, src)
		if(STATUS_EFFECT_NORMAL_PROCESS)
			STOP_PROCESSING(SSprocessing, src)
	if(owner)
		owner.clear_alert(id)
		LAZYREMOVE(owner.status_effects, src)
		on_remove()
		owner = null
	if(linked_alert)
		linked_alert.attached_effect = null
		linked_alert = null
	return ..()


// Status effect process. Handles adjusting its duration and ticks.
// If you're adding processed effects, put them in [proc/tick]
// instead of extending / overriding the process() proc.
/datum/status_effect/process(seconds_per_tick)
	SHOULD_NOT_OVERRIDE(TRUE)
	if(QDELETED(owner))
		qdel(src)
		return
	if(tick_interval != -1 && tick_interval <= world.time)
		var/tick_length = initial(tick_interval)
		tick(tick_length / (1 SECONDS))
		tick_interval = world.time + tick_length
		if(QDELING(src))
			// tick deleted us, no need to continue
			return
	if(duration != -1 && duration < world.time)
		on_timeout()
		qdel(src)


/// Called whenever the effect is applied in on_created
/// Returning FALSE will cause it to delete itself during creation instead.
/datum/status_effect/proc/on_apply()
	return TRUE


/// Gets and formats examine text associated with our status effect.
/// Return 'null' to have no examine text appear (default behavior).
/datum/status_effect/proc/get_examine_text()
	return


/**
 * Called every tick from process().
 * This is only called of tick_interval is not -1.
 *
 * Note that every tick =/= every processing cycle.
 *
 * * seconds_between_ticks = This is how many SECONDS that elapse between ticks.
 * This is a constant value based upon the initial tick interval set on the status effect.
 * It is similar to seconds_per_tick, from processing itself, but adjusted to the status effect's tick interval.
 */
/datum/status_effect/proc/tick(seconds_between_ticks)
	return



/// Called whenever the buff expires or is removed (qdeleted)
/// Note that at the point this is called, it is out of the owner's status_effects list, but owner is not yet null
/datum/status_effect/proc/on_remove()
	return


/// Called specifically whenever the status effect expires.
/datum/status_effect/proc/on_timeout()


/// Called instead of on_remove when a status effect
/// of status_type STATUS_EFFECT_REPLACE is replaced by itself,
/// or when a status effect with on_remove_on_mob_delete
/// set to FALSE has its mob deleted
/datum/status_effect/proc/be_replaced()
	linked_alert = null
	owner.clear_alert(id)
	LAZYREMOVE(owner.status_effects, src)
	owner = null
	qdel(src)


/// Called before being fully removed (before on_remove)
/// Returning FALSE will cancel removal
/datum/status_effect/proc/before_remove()
	return TRUE


/// Called when a status effect of status_type STATUS_EFFECT_REFRESH
/// has its duration refreshed in apply_status_effect - is passed New() args
/datum/status_effect/proc/refresh(effect, ...)
	var/original_duration = initial(duration)
	if(original_duration == -1)
		return
	duration = world.time + original_duration


/// Adds nextmove modifier multiplicatively to the owner while applied
/datum/status_effect/proc/nextmove_modifier()
	return 1


/// Adds nextmove adjustment additiviely to the owner while applied
/datum/status_effect/proc/nextmove_adjust()
	return 0


/// Remove [seconds] of duration from the status effect, qdeling / ending if we eclipse the current world time.
/datum/status_effect/proc/remove_duration(seconds)
	if(duration == -1) // Infinite duration
		return FALSE

	duration -= seconds
	if(duration <= world.time)
		qdel(src)
		return TRUE

	return FALSE


////////////////
// ALERT HOOK //
////////////////

/atom/movable/screen/alert/status_effect
	name = "Curse of Mundanity"
	desc = "You don't feel any different..."
	var/datum/status_effect/attached_effect

/atom/movable/screen/alert/status_effect/Destroy()
	if(attached_effect)
		attached_effect.linked_alert = null
	attached_effect = null
	return ..()


//////////////////
// HELPER PROCS //
//////////////////

/**
 * Applies a given status effect to this mob.
 *
 * new_effect - TYPEPATH of a status effect to apply.
 * Additional status effect arguments can be passed.
 *
 * Returns the instance of the created effected, if successful.
 * Returns 'null' if unsuccessful.
 */
/mob/living/proc/apply_status_effect(datum/status_effect/new_effect, ...)
	RETURN_TYPE(/datum/status_effect)

	// The arguments we pass to the start effect. The 1st argument is this mob.
	var/list/arguments = args.Copy()
	arguments[1] = src

	// If the status effect we're applying doesn't allow multiple effects, we need to handle it
	if(initial(new_effect.status_type) != STATUS_EFFECT_MULTIPLE)
		for(var/datum/status_effect/existing_effect as anything in status_effects)
			if(existing_effect.id != initial(new_effect.id))
				continue

			switch(existing_effect.status_type)
				// Multiple are allowed, continue as normal. (Not normally reachable)
				if(STATUS_EFFECT_MULTIPLE)
					break
				// Only one is allowed of this type - early return
				if(STATUS_EFFECT_UNIQUE)
					return
				// Replace the existing instance (deletes it).
				if(STATUS_EFFECT_REPLACE)
					existing_effect.be_replaced()
				// Refresh the existing type, then early return
				if(STATUS_EFFECT_REFRESH)
					existing_effect.refresh(arglist(arguments))
					return

	// Create the status effect with our mob + our arguments
	var/datum/status_effect/new_instance = new new_effect(arguments)
	if(!QDELETED(new_instance))
		SEND_SIGNAL(src, COMSIG_LIVING_GAINED_STATUS_EFFECT, new_instance)
		return new_instance


/**
 * Removes all instances of a given status effect from this mob
 *
 * removed_effect - TYPEPATH of a status effect to remove.
 * Additional status effect arguments can be passed - these are passed into before_remove.
 *
 * Returns TRUE if at least one was removed.
 */
/mob/living/proc/remove_status_effect(datum/status_effect/removed_effect, ...)
	var/list/arguments = args.Copy(2)

	. = FALSE
	for(var/datum/status_effect/existing_effect as anything in status_effects)
		if(existing_effect.id == initial(removed_effect.id) && existing_effect.before_remove(arglist(arguments)))
			SEND_SIGNAL(src, COMSIG_LIVING_EARLY_LOST_STATUS_EFFECT, existing_effect)
			qdel(existing_effect)
			. = TRUE


/**
 * Checks if this mob has a status effect that shares the passed effect's ID
 *
 * checked_effect - TYPEPATH of a status effect to check for. Checks for its ID, not it's typepath
 *
 * Returns an instance of a status effect, or NULL if none were found.
 */
/mob/proc/has_status_effect(datum/status_effect/checked_effect)
	// Yes I'm putting this on the mob level even though status effects only apply to the living level
	// There's quite a few places (namely examine and, bleh, cult code) where it's easier to not need to cast to living before checking
	// for an effect such as blindness
	return null


/mob/living/has_status_effect(datum/status_effect/checked_effect)
	RETURN_TYPE(/datum/status_effect)

	for(var/datum/status_effect/present_effect as anything in status_effects)
		if(present_effect.id == initial(checked_effect.id))
			return present_effect


///Gets every status effect of an ID and returns all of them in a list, rather than the individual 'has_status_effect'
/mob/living/proc/get_all_status_effect_of_id(datum/status_effect/checked_effect)
	RETURN_TYPE(/list/datum/status_effect)

	. = list()
	for(var/datum/status_effect/present_effect as anything in status_effects)
		if(present_effect.id == initial(checked_effect.id))
			. += present_effect


//////////////////////
// STACKING EFFECTS //
//////////////////////

/datum/status_effect/stacking
	id = "stacking_base"
	duration = -1 //removed under specific conditions
	alert_type = null
	var/stacks = 0 //how many stacks are accumulated, also is # of stacks that target will have when first applied
	var/delay_before_decay //deciseconds until ticks start occuring, which removes stacks (first stack will be removed at this time plus tick_interval)
	tick_interval = 10 //deciseconds between decays once decay starts
	var/stack_decay = 1 //how many stacks are lost per tick (decay trigger)
	var/stack_threshold //special effects trigger when stacks reach this amount
	var/max_stacks //stacks cannot exceed this amount
	var/consumed_on_threshold = TRUE //if status should be removed once threshold is crossed
	var/threshold_crossed = FALSE //set to true once the threshold is crossed, false once it falls back below
	var/reset_ticks_on_stack = FALSE //resets the current tick timer if a stack is gained
	var/overlay_file
	var/underlay_file
	var/overlay_state // states in .dmi must be given a name followed by a number which corresponds to a number of stacks. put the state name without the number in these state vars
	var/underlay_state // the number is concatonated onto the string based on the number of stacks to get the correct state name
	var/mutable_appearance/status_overlay
	var/mutable_appearance/status_underlay

/datum/status_effect/stacking/proc/threshold_cross_effect() //what happens when threshold is crossed

/datum/status_effect/stacking/proc/stacks_consumed_effect() //runs if status is deleted due to threshold being crossed

/datum/status_effect/stacking/proc/fadeout_effect() //runs if status is deleted due to being under one stack

/datum/status_effect/stacking/proc/stack_decay_effect() //runs every time tick() causes stacks to decay

/datum/status_effect/stacking/proc/on_threshold_cross()
	threshold_cross_effect()
	if(consumed_on_threshold)
		stacks_consumed_effect()
		qdel(src)

/datum/status_effect/stacking/proc/on_threshold_drop()

/datum/status_effect/stacking/proc/can_have_status()
	return owner.stat != DEAD

/datum/status_effect/stacking/proc/can_gain_stacks()
	return owner.stat != DEAD

/datum/status_effect/stacking/tick(seconds_between_ticks)
	if(!can_have_status())
		qdel(src)
	else
		add_stacks(-stack_decay)
		stack_decay_effect()

/datum/status_effect/stacking/proc/add_stacks(stacks_added)
	if(stacks_added > 0 && !can_gain_stacks())
		return FALSE
	owner.cut_overlay(status_overlay)
	owner.underlays -= status_underlay
	stacks += stacks_added
	if(reset_ticks_on_stack)
		tick_interval = world.time + initial(tick_interval)
	if(stacks > 0)
		if(stacks >= stack_threshold && !threshold_crossed) //threshold_crossed check prevents threshold effect from occuring if changing from above threshold to still above threshold
			threshold_crossed = TRUE
			on_threshold_cross()
		else if(stacks < stack_threshold && threshold_crossed)
			threshold_crossed = FALSE //resets threshold effect if we fall below threshold so threshold effect can trigger again
			on_threshold_drop()
		if(stacks_added > 0)
			tick_interval += delay_before_decay //refreshes time until decay
		stacks = min(stacks, max_stacks)
		status_overlay.icon_state = "[overlay_state][stacks]"
		status_underlay.icon_state = "[underlay_state][stacks]"
		owner.add_overlay(status_overlay)
		owner.underlays += status_underlay
	else
		fadeout_effect()
		qdel(src) //deletes status if stacks fall under one

/datum/status_effect/stacking/on_creation(mob/living/new_owner, stacks_to_apply)
	. = ..()
	if(.)
		add_stacks(stacks_to_apply)

/datum/status_effect/stacking/on_apply()
	if(!can_have_status())
		return FALSE
	status_overlay = mutable_appearance(overlay_file, "[overlay_state][stacks]")
	status_underlay = mutable_appearance(underlay_file, "[underlay_state][stacks]")
	var/icon/I = icon(owner.icon, owner.icon_state, owner.dir)
	var/icon_height = I.Height()
	status_overlay.pixel_x = -owner.pixel_x
	status_overlay.pixel_y = FLOOR(icon_height * 0.25, 1)
	status_overlay.transform = matrix() * (icon_height/world.icon_size) //scale the status's overlay size based on the target's icon size
	status_underlay.pixel_x = -owner.pixel_x
	status_underlay.transform = matrix() * (icon_height/world.icon_size) * 3
	status_underlay.alpha = 40
	owner.add_overlay(status_overlay)
	owner.underlays += status_underlay
	return ..()

/datum/status_effect/stacking/Destroy()
	if(owner)
		owner.cut_overlay(status_overlay)
		owner.underlays -= status_underlay
	QDEL_NULL(status_overlay)
	return ..()


/// Status effect from multiple sources, when all sources are removed, so is the effect
/datum/status_effect/grouped
	status_type = STATUS_EFFECT_MULTIPLE //! Adds itself to sources and destroys itself if one exists already, there are never multiple
	var/list/sources = list()


/datum/status_effect/grouped/on_creation(mob/living/new_owner, source)
	var/datum/status_effect/grouped/existing = new_owner.has_status_effect(type)
	if(existing)
		existing.sources |= source
		qdel(src)
		return FALSE
	else
		sources |= source
		return ..()


/datum/status_effect/grouped/before_remove(source)
	sources -= source
	return !length(sources)


/**
 * # Transient Status Effect (basetype)
 *
 * A status effect that works off a (possibly decimal) counter before expiring, rather than a specified world.time.
 * This allows for a more precise tweaking of status durations at runtime (e.g. paralysis).
 */
/datum/status_effect/transient
	tick_interval = 0.2 SECONDS // SSfastprocess interval
	alert_type = null
	/// How much strength left before expiring? time in deciseconds.
	var/strength = 0


/datum/status_effect/transient/on_creation(mob/living/new_owner, set_duration)
	if(isnum(set_duration))
		strength = set_duration
	. = ..()


/datum/status_effect/transient/tick(seconds_between_ticks)
	if(QDELETED(src) || QDELETED(owner))
		return FALSE
	. = TRUE
	strength += calc_decay()
	if(strength <= 0)
		qdel(src)
		return FALSE


/**
 * Returns how much strength should be adjusted per tick.
 */
/datum/status_effect/transient/proc/calc_decay()
	return -0.2 SECONDS // 1 per second by default
