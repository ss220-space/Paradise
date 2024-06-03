/**
 * # Status effect absorption
 *
 * Applies temporal or permanent immunities for certain status effects, with additional info tied to it,
 * such as showing a message on trigger / examine, or only blocking a limited amount.
 *
 * Currently works with incapacitating effects only: stun, weaken, knockdown, immobile, paralyze, sleep.
 *
 * Apply this via [/mob/living/proc/add_status_effect_absorption]. If you do not supply a duration,
 * remove this via [/mob/living/proc/remove_status_effect_absorption].
 */
/datum/status_effect/effect_absorption
	id = "absorb_effect"
	tick_interval = -1
	alert_type = null
	status_type = STATUS_EFFECT_MULTIPLE

	/// The string key sourcer of the absorption, used for logging
	var/source
	/// Type of the effect we are absorbing
	var/effect_type
	/// The priority of the effect absorption. Used so that multiple sources will not trigger at once.
	/// This number is arbitrary but try to keep in sane / in line with other sources that exist.
	var/priority = -1
	/// How many total seconds of effect that have been blocked.
	var/seconds_of_effect_absorbed = 0 SECONDS
	/// The max number of seconds we can block before self-deleting.
	var/max_seconds_of_effect_blocked = INFINITY
	/// The message shown via visible message to all nearby mobs when the effect triggers.
	var/shown_message
	/// The message shown  to the owner when the effect triggers.
	var/self_message
	/// Message shown on anyone examining the owner.
	var/examine_message
	/// If `TRUE`, after passing the max seconds of effect blocked, we will delete ourself.
	/// If `FALSE`, we will instead recharge after some time.
	var/delete_after_passing_max
	/// If [delete_after_passing_max] is `FALSE`, this is how long we will wait before recharging.
	var/recharge_time
	/// Static associative list of all status effects we can work with.
	/// In a form: key = effect_type, value = signal sent from the corresponding proc.
	var/static/list/effect_signals = list(
		STUN = COMSIG_LIVING_STATUS_STUN,
		WEAKEN = COMSIG_LIVING_STATUS_WEAKEN,
		KNOCKDOWN = COMSIG_LIVING_STATUS_KNOCKDOWN,
		IMMOBILIZE = COMSIG_LIVING_STATUS_IMMOBILIZE,
		PARALYZE = COMSIG_LIVING_STATUS_PARALYZE,
		SLEEP = COMSIG_LIVING_STATUS_SLEEP,
	)


/datum/status_effect/effect_absorption/on_creation(
	mob/living/new_owner,
	source,
	effect_type,
	duration,
	priority = -1,
	shown_message,
	self_message,
	examine_message,
	max_seconds_of_effect_blocked = INFINITY,
	delete_after_passing_max = TRUE,
	recharge_time = 1 MINUTES,
)

	if(isnum(duration))
		src.duration = duration

	src.source = source
	src.effect_type = effect_type
	src.priority = priority
	src.shown_message = shown_message
	src.self_message = self_message
	src.examine_message = examine_message
	src.max_seconds_of_effect_blocked = max_seconds_of_effect_blocked
	src.delete_after_passing_max = delete_after_passing_max
	src.recharge_time = recharge_time

	return ..()


/datum/status_effect/effect_absorption/on_apply()
	if(!effect_type)
		CRASH("No effect_type passed for status effect absorption.")
	if(!effect_signals[effect_type])
		CRASH("No signals are registered for the '[effect_type]' effect_type.")
	if(owner.mind || owner.client)
		owner.create_log(ATTACK_LOG, "gained effect absorption (from: [source || "Unknown"])")

	RegisterSignal(owner, effect_signals[effect_type], PROC_REF(try_absorb_effect))
	return TRUE


/datum/status_effect/effect_absorption/on_remove()
	if(owner.mind || owner.client)
		owner.create_log(ATTACK_LOG, "lost effect absorption (from: [source || "Unknown"])")

	UnregisterSignal(owner, effect_signals[effect_type])


/datum/status_effect/effect_absorption/get_examine_text()
	if(examine_message && can_absorb_effect())
		return replacetext(examine_message, "%EFFECT_OWNER_THEYRE", "[owner.p_they(TRUE)] [owner.p_are()]")


/**
 * Signal proc for all the signals in var/static/list/effect_signals.
 *
 * When effect we are protecting from is applied, we will try to absorb a number of seconds from it, and return [COMPONENT_NO_EFFECT] if we succeed.
 */
/datum/status_effect/effect_absorption/proc/try_absorb_effect(mob/living/source, amount = 0, ignore_effect = FALSE)
	SIGNAL_HANDLER

	// we blocked an effect this tick that resulting in us qdeling, so stop
	if(QDELING(src))
		return NONE

	// amount less than (or equal to) zero is removing the effect, so we don't want to block that
	if(amount <= 0 || ignore_effect)
		return NONE

	if(!absorb_effect(amount))
		return NONE

	return COMPONENT_NO_EFFECT


/// Simply checks if the owner of the effect is in a valid state to absorb effects.
/datum/status_effect/effect_absorption/proc/can_absorb_effect()
	if(seconds_of_effect_absorbed > max_seconds_of_effect_blocked)
		return FALSE
	return TRUE


/**
 * Absorb a number of seconds of effect.
 * If we hit the max amount of absorption, we will qdel ourself in this proc.
 *
 * * amount - this is the number of deciseconds being absorbed at once.
 *
 * Returns `TRUE` on successful absorption, `FALSE` otherwise.
 */
/datum/status_effect/effect_absorption/proc/absorb_effect(amount)
	if(!can_absorb_effect())
		return FALSE

	// Now we gotta check that no other effect absorption we have is blocking us
	for(var/datum/status_effect/effect_absorption/similar_effect in owner.status_effects)
		if(similar_effect == src)
			continue
		// they blocked an effect this tick that resulted in them qdeling, so disregard
		if(QDELING(similar_effect))
			continue
		// other effect type
		if(similar_effect.effect_type != effect_type)
			continue
		// if we have another effect absorption with higher priority,
		// don't do anything, let them handle it instead
		if(similar_effect.priority > priority)
			return FALSE

	// At this point, an effect was successfully absorbed

	// Only do additional stuff if the amount was > 0 seconds
	if(amount > 0 SECONDS)
		// Show the message
		if(shown_message)
			// We do this replacement meme, instead of just setting it up in creation,
			// so that we respect indentity changes done while active
			var/really_shown_message = replacetext(shown_message, "%EFFECT_OWNER", "[owner]")
			owner.visible_message(really_shown_message, ignored_mobs = owner)

		// Send the self message
		if(self_message)
			to_chat(owner, self_message)

		// Count seconds absorbed
		seconds_of_effect_absorbed += amount
		if(delete_after_passing_max)
			if(seconds_of_effect_absorbed >= max_seconds_of_effect_blocked)
				qdel(src)

		else if(recharge_time > 0 SECONDS)
			addtimer(CALLBACK(src, PROC_REF(recharge_absorption), amount), recharge_time)

	return TRUE


/// Used in callbacks to "recharge" the effect after passing the max seconds of blocked time.
/datum/status_effect/effect_absorption/proc/recharge_absorption(amount)
	seconds_of_effect_absorbed = max(seconds_of_effect_absorbed - amount, 0)


/**
 * [proc/apply_status_effect] wrapper specifically for [/datum/status_effect/effect_absorption],
 * specifically so that it's easier to apply effects absorptions with named arguments.
 *
 * If the mob already has an effect absorption from the same source, will not re-apply the effect,
 * unless the new effect's priority is higher than the old effect's priority.
 *
 * Arguments
 * * source - the source of the effect absorption.
 * * effect_type - status effect identifier (can be list), used to register proper signals.
 * * duration - how long does the effect absorption last before it ends? -1 or null (or infinity) = infinite duration
 * * priority - what is this effect's priority to other effect absorptions? higher = more priority
 * * message - optional, "other message" arg of visible message, shown on trigger. Use %EFFECT_OWNER if you want the owner's name to be inserted.
 * * self_message - optional, "self message" arg of visible message, shown on trigger
 * * examine_message - optional, what is shown on examine of the mob.
 * * max_seconds_of_effect_blocked - optional, how many seconds of time can it block before deleting? the effect that breaks over this number is still blocked, even if it is much higher.
 * * delete_after_passing_max - optional, if `TRUE`, after passing the max seconds of effectss blocked, we will delete ourself.
 * If `FALSE`, we will instead recharge after some time.
 * * recharge_time - optional, if [delete_after_passing_max] is `FALSE`, this is how long we will wait before recharging.
 * does nothing if [delete_after_passing_max] is `TRUE`.
 *
 * Returns `TRUE` if any effect were applied, `FALSE` otherwise
 */
/mob/living/proc/add_status_effect_absorption(
	source,
	effect_type,
	duration,
	priority = -1,
	message,
	self_message,
	examine_message,
	max_seconds_of_effect_blocked = INFINITY,
	delete_after_passing_max = TRUE,
	recharge_time,
	recharge_alert,
)

	if(!islist(effect_type))
		effect_type = list(effect_type)

	for(var/effect_identifier in effect_type)
		// Handle duplicate sources
		var/apply_new_effect = TRUE
		for(var/datum/status_effect/effect_absorption/existing_effect in status_effects)
			if(existing_effect.source != source)
				continue

			if(existing_effect.effect_type != effect_identifier)
				continue

			// If an existing effect's priority is greater or equal to our passed priority...
			if(existing_effect.priority >= priority)
				// don't bother re-applying the effect
				apply_new_effect = FALSE
				break

			// otherwise, delete existing and replace with new
			qdel(existing_effect)

		if(apply_new_effect)
			. = apply_status_effect(
				/datum/status_effect/effect_absorption,
				source,
				effect_identifier,
				duration,
				priority,
				message,
				self_message,
				examine_message,
				max_seconds_of_effect_blocked,
				delete_after_passing_max,
				recharge_time,
			)


/**
 * Removes all effects absorptions of effect_type (or list of effect types) with the passed source.
 *
 * Returns `TRUE` if any effects were deleted, `FALSE` otherwise
 */
/mob/living/proc/remove_status_effect_absorption(source, effect_type)
	. = FALSE

	if(!islist(effect_type))
		effect_type = list(effect_type)

	for(var/effect_identifier in effect_type)
		for(var/datum/status_effect/effect_absorption/effect in status_effects)
			if(effect.source != source)
				continue

			if(effect.effect_type != effect_identifier)
				continue

			qdel(effect)
			. = TRUE

