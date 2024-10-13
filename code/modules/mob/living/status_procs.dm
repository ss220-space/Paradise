//Here are the procs used to modify status effects of a mob.

// The `updating` argument is only available on effects that cause a visual/physical effect on the mob itself
// when applied, such as Stun, Weaken, and Jitter - stuff like Blindness, which has a client-side effect,
// lacks this argument.

// BOOLEAN STATES

/*
	* EyesBlocked
		Your eyes are covered somehow
	* EarsBlocked
		Your ears are covered somehow
	* Resting
		You are lying down of your own volition
	* Flying
		For some reason or another you can move while not touching the ground
*/


// STATUS EFFECTS
// All of these are handed by a status_effect in `debuffs.dm` their durations are measured in deciseconds, so the seconds define is used wherever possible, even with decimal seconds values.
// Status effects sorted alphabetically:
/*
	* Confused()				*
			Movement is scrambled.
	* Deaf()				*
			You cannot hear.
	* Disgust()				*
			Some jitter and blurry effects
	* Dizzy()					*
			The screen shifts in random directions slightly.
	* Drowsy()
			You begin to yawn, and have a chance of incrementing "Paralysis"
	* Druggy()				*
			A trippy overlay appears.
	* Drunk()					*
			Gives you a wide variety of negative effects related to being drunk, all scaling up with alcohol consumption.
	* EyeBlind()				*
			You cannot see. Prevents EyeBlurry from healing naturally.
	* EyeBlurry()				*
			A hazy overlay appears on your screen.
	* Hallucinate()			*
			Your character will imagine various effects happening to them, vividly.
	* Immobilize()
			Your character cannot walk, however they can act.
	* Jitter()				*
			Your character will visibly twitch. Higher values amplify the effect.
	* LoseBreath()			*
			Your character is unable to breathe.
	* Paralyse()				*
			Your character is knocked out.
	* Silence()				*
			Your character is unable to speak.
	* Sleeping()				*
			Your character is asleep.
	* Slowed()				*
			Your character moves slower. The amount of slowdown is variable, defaulting to 10, which is a massive amount.
	* Slurring()				*
			Your character cannot enunciate clearly.
	* CultSlurring()			*
			Your character cannot enunciate clearly while mumbling about elder codes.
	* ClockSlurring()			*
			Your character cannot enunciate clearly while mumbling about elder codes.
	* Stun()				*
			Your character is unable to move, and drops stuff in their hands. They keep standing, though.
	* Stuttering()			*
			Your character stutters parts of their messages.
	* Weaken()				*
			Your character collapses, but is still conscious. does not need to be called in tandem with Stun().
*/

#define RETURN_STATUS_EFFECT_STRENGTH(T) \
	var/datum/status_effect/transient/S = has_status_effect(T);\
	return S ? S.strength : 0

#define SET_STATUS_EFFECT_STRENGTH(T, A) \
	A = max(A, 0);\
	if(A) {;\
		var/datum/status_effect/transient/S = has_status_effect(T);\
		if(!S) {;\
			apply_status_effect(T, A);\
		} else {;\
			S.strength = A;\
		};\
	} else {;\
		remove_status_effect(T);\
	}


/**
 * Checks if we have incapacitating immunity. Godmode always passes this check.
 *
 * Arguments:
 * * check_flags - bitflag of status flags that must be set in order for the incapacitating effect to succeed. Passing NONE will always return `FALSE`.
 * * force_apply - whether we ignore incapacitating immunity with the exception of godmode.
 *
 * Returns `TRUE` if immune, `FALSE` otherwise
 */
/mob/living/proc/check_incapacitating_immunity(check_flags = CANSTUN, force_apply = FALSE)
	SHOULD_CALL_PARENT(TRUE)
	SHOULD_BE_PURE(TRUE)

	if(HAS_TRAIT(src, TRAIT_GODMODE))
		return TRUE

	if(force_apply) // Does not take priority over god mode? I guess
		return FALSE

	if(SEND_SIGNAL(src, COMSIG_LIVING_GENERIC_INCAPACITATE_CHECK, check_flags, force_apply) & COMPONENT_NO_EFFECT)
		return TRUE

	// Do we have the correct flag set to allow this status?
	// This checks that ALL flags are set, not just one of them.
	if((status_flags & check_flags) == check_flags)
		return FALSE

	return TRUE


// SCALAR STATUS EFFECTS

/**
 * Returns current amount of [confusion][/datum/status_effect/decaying/confusion], 0 if none.
 */
/mob/living/proc/get_confusion()
	RETURN_STATUS_EFFECT_STRENGTH(STATUS_EFFECT_CONFUSION)

/**
 * Sets [confusion][/datum/status_effect/decaying/confusion] if it's higher than zero.
 */
/mob/living/proc/SetConfused(amount)
	SET_STATUS_EFFECT_STRENGTH(STATUS_EFFECT_CONFUSION, amount)

/**
 * Sets [confusion][/datum/status_effect/decaying/confusion] if it's higher than current.
 */
/mob/living/proc/Confused(amount)
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		return
	SetConfused(max(get_confusion(), amount))

/**
 * Sets [confusion][/datum/status_effect/decaying/confusion] to current amount + given, clamped between lower and higher bounds.
 *
 * Arguments:
 * * amount - Amount to add. Can be negative to reduce duration.
 * * bound_lower - Minimum bound to set at least to. Defaults to 0.
 * * bound_upper - Maximum bound to set up to. Defaults to infinity.
 */
/mob/living/proc/AdjustConfused(amount, bound_lower = 0, bound_upper = INFINITY)
	SetConfused(directional_bounded_sum(get_confusion(), amount, bound_lower, bound_upper))

/**
 * Returns current amount of [disoriented][/datum/status_effect/transient/disoriented], 0 if none.
 */
/mob/living/proc/get_disoriented()
	RETURN_STATUS_EFFECT_STRENGTH(STATUS_EFFECT_DISORIENTED)

/**
 * Sets [disoriented][/datum/status_effect/transient/disoriented].
 */
/mob/living/proc/SetDisoriented(amount)
	SET_STATUS_EFFECT_STRENGTH(STATUS_EFFECT_DISORIENTED, amount)

/**
 * Sets [disoriented][/datum/status_effect/decaying/disoriented] if it's higher than current.
 */
/mob/living/proc/Disoriented(amount)
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		return
	SetDisoriented(max(get_disoriented(), amount))

// DIZZY

/**
 * Returns current amount of [dizziness][/datum/status_effect/decaying/dizziness], 0 if none.
 */
/mob/living/proc/get_dizziness()
	RETURN_STATUS_EFFECT_STRENGTH(STATUS_EFFECT_DIZZINESS)

/**
 * Sets [dizziness][/datum/status_effect/decaying/dizziness] if it's higher than zero.
 */
/mob/living/proc/SetDizzy(amount)
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		return
	SET_STATUS_EFFECT_STRENGTH(STATUS_EFFECT_DIZZINESS, amount)

/**
 * Sets [dizziness][/datum/status_effect/decaying/dizziness] if it's higher than current.
 */
/mob/living/proc/Dizzy(amount)
	SetDizzy(max(get_dizziness(), amount))

/**
 * Sets [dizziness][/datum/status_effect/decaying/dizziness] to current amount + given, clamped between lower and higher bounds.
 *
 * Arguments:
 * * amount - Amount to add. Can be negative to reduce duration.
 * * bound_lower - Minimum bound to set at least to. Defaults to 0.
 * * bound_upper - Maximum bound to set up to. Defaults to infinity.
 */
/mob/living/proc/AdjustDizzy(amount, bound_lower = 0, bound_upper = INFINITY)
	SetDizzy(directional_bounded_sum(get_dizziness(), amount, bound_lower, bound_upper))

// DROWSY

/**
 * Returns current amount of [drowsiness][/datum/status_effect/decaying/drowsiness], 0 if none.
 */
/mob/living/proc/get_drowsiness()
	RETURN_STATUS_EFFECT_STRENGTH(STATUS_EFFECT_DROWSINESS)

/**
 * Sets [drowsiness][/datum/status_effect/decaying/drowsiness] if it's higher than zero.
 */
/mob/living/proc/SetDrowsy(amount)
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		return
	SET_STATUS_EFFECT_STRENGTH(STATUS_EFFECT_DROWSINESS, amount)

/**
 * Sets [drowsiness][/datum/status_effect/decaying/drowsiness] if it's higher than current.
 */
/mob/living/proc/Drowsy(amount)
	SetDrowsy(max(get_drowsiness(), amount))

/**
 * Sets [drowsiness][/datum/status_effect/decaying/drowsiness] to current amount + given, clamped between lower and higher bounds.
 *
 * Arguments:
 * * amount - Amount to add. Can be negative to reduce duration.
 * * bound_lower - Minimum bound to set at least to. Defaults to 0.
 * * bound_upper - Maximum bound to set up to. Defaults to infinity.
 */
/mob/living/proc/AdjustDrowsy(amount, bound_lower = 0, bound_upper = INFINITY)
	SetDrowsy(directional_bounded_sum(get_drowsiness(), amount, bound_lower, bound_upper))

// DRUNK

/**
 * Returns current amount of [drunkenness][/datum/status_effect/decaying/drunkenness], 0 if none.
 */
/mob/living/proc/get_drunkenness()
	RETURN_STATUS_EFFECT_STRENGTH(STATUS_EFFECT_DRUNKENNESS)

/**
 * Sets [drunkenness][/datum/status_effect/decaying/drunkenness] if it's higher than zero.
 */
/mob/living/proc/SetDrunk(amount)
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		return
	SET_STATUS_EFFECT_STRENGTH(STATUS_EFFECT_DRUNKENNESS, amount)

/**
 * Sets [drunkenness][/datum/status_effect/decaying/drunkenness] if it's higher than current.
 */
/mob/living/proc/Drunk(amount)
	SetDrunk(max(get_drunkenness(), amount))

/**
 * Sets [drunkenness][/datum/status_effect/decaying/drunkenness] to current amount + given, clamped between lower and higher bounds.
 *
 * Arguments:
 * * amount - Amount to add. Can be negative to reduce duration.
 * * bound_lower - Minimum bound to set at least to. Defaults to 0.
 * * bound_upper - Maximum bound to set up to. Defaults to infinity.
 */
/mob/living/proc/AdjustDrunk(amount, bound_lower = 0, bound_upper = INFINITY)
	SetDrunk(directional_bounded_sum(get_drunkenness(), amount, bound_lower, bound_upper))

// DRUGGY

/mob/living/proc/AmountDruggy()
	RETURN_STATUS_EFFECT_STRENGTH(STATUS_EFFECT_DRUGGED)

/mob/living/proc/Druggy(amount)
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		return
	SetDruggy(max(AmountDruggy(), amount))

/mob/living/proc/SetDruggy(amount)
	SET_STATUS_EFFECT_STRENGTH(STATUS_EFFECT_DRUGGED, amount)

/mob/living/proc/AdjustDruggy(amount, bound_lower = 0, bound_upper = INFINITY)
	SetDruggy(directional_bounded_sum(AmountDruggy(), amount, bound_lower, bound_upper))

// EYE_BLIND
/mob/living/proc/AmountBlinded()
	RETURN_STATUS_EFFECT_STRENGTH(STATUS_EFFECT_BLINDED)

/mob/living/proc/EyeBlind(amount)
	SetEyeBlind(max(AmountBlinded(), amount))

/mob/living/proc/SetEyeBlind(amount)
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		return
	SET_STATUS_EFFECT_STRENGTH(STATUS_EFFECT_BLINDED, amount)

/mob/living/proc/AdjustEyeBlind(amount, bound_lower = 0, bound_upper = INFINITY, updating = TRUE)
	SetEyeBlind(directional_bounded_sum(AmountBlinded(), amount, bound_lower, bound_upper))

// EYE_BLURRY
/mob/living/proc/AmountEyeBlurry()
	RETURN_STATUS_EFFECT_STRENGTH(STATUS_EFFECT_BLURRY_EYES)

/mob/living/proc/EyeBlurry(amount)
	SetEyeBlurry(max(AmountEyeBlurry(), amount))

/mob/living/proc/SetEyeBlurry(amount)
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		return
	SET_STATUS_EFFECT_STRENGTH(STATUS_EFFECT_BLURRY_EYES, amount)

/mob/living/proc/AdjustEyeBlurry(amount, bound_lower = 0, bound_upper = INFINITY)
	SetEyeBlurry(directional_bounded_sum(AmountEyeBlurry(), amount, bound_lower, bound_upper))

// HALLUCINATION
/mob/living/proc/AmountHallucinate()
	RETURN_STATUS_EFFECT_STRENGTH(STATUS_EFFECT_HALLUCINATION)

/mob/living/proc/Hallucinate(amount)
	SetHallucinate(max(AmountHallucinate(), amount))

/mob/living/proc/SetHallucinate(amount)
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		amount = 0
	SET_STATUS_EFFECT_STRENGTH(STATUS_EFFECT_HALLUCINATION, amount)

/mob/living/proc/AdjustHallucinate(amount, bound_lower = 0, bound_upper = INFINITY)
	SetHallucinate(directional_bounded_sum(AmountHallucinate(), amount, bound_lower, bound_upper))

// JITTER
/mob/living/proc/AmountJitter()
	RETURN_STATUS_EFFECT_STRENGTH(STATUS_EFFECT_JITTER)

/mob/living/proc/Jitter(amount)
	SetJitter(max(AmountJitter(), amount))

/mob/living/proc/SetJitter(amount)
	// Jitter is also associated with stun
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		return
	SET_STATUS_EFFECT_STRENGTH(STATUS_EFFECT_JITTER, amount)

/mob/living/proc/AdjustJitter(amount, bound_lower = 0, bound_upper = INFINITY, force = 0)
	SetJitter(directional_bounded_sum(AmountJitter(), amount, bound_lower, bound_upper), force)

// LOSE_BREATH

/mob/living/proc/AmountLoseBreath()
	RETURN_STATUS_EFFECT_STRENGTH(STATUS_EFFECT_LOSE_BREATH)

/mob/living/proc/LoseBreath(amount)
	SetLoseBreath(max(AmountLoseBreath(), amount))

/mob/living/proc/SetLoseBreath(amount)
	if(HAS_TRAIT(src, TRAIT_NO_BREATH))
		return
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		return
	SET_STATUS_EFFECT_STRENGTH(STATUS_EFFECT_LOSE_BREATH, amount)

/mob/living/proc/AdjustLoseBreath(amount, bound_lower = 0, bound_upper = INFINITY)
	SetLoseBreath(directional_bounded_sum(AmountLoseBreath(), amount, bound_lower, bound_upper))

// PARALYSE
/mob/proc/IsParalyzed()
	return


/mob/living/IsParalyzed()
	return has_status_effect(STATUS_EFFECT_PARALYZED)


/mob/living/proc/AmountParalyzed()
	var/datum/status_effect/incapacitating/paralyzed/P = IsParalyzed()
	if(P)
		return P.duration - world.time
	return 0


/mob/living/proc/Paralyse(amount, ignore_canparalyse = FALSE)
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_PARALYZE, amount, ignore_canparalyse) & COMPONENT_NO_EFFECT)
		return
	if(check_incapacitating_immunity(CANPARALYSE, ignore_canparalyse))
		return
	var/datum/status_effect/incapacitating/paralyzed/P = IsParalyzed()
	if(P)
		P.duration = max(world.time + amount, P.duration)
	else if(amount > 0)
		P = apply_status_effect(STATUS_EFFECT_PARALYZED, amount)
	return P


/mob/living/proc/SetParalysis(amount, ignore_canparalyse = FALSE)
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_PARALYZE, amount, ignore_canparalyse) & COMPONENT_NO_EFFECT)
		return
	if(check_incapacitating_immunity(CANPARALYSE, ignore_canparalyse))
		return
	var/datum/status_effect/incapacitating/paralyzed/P = IsParalyzed()
	if(amount <= 0)
		if(P)
			qdel(P)
	else
		if(P)
			P.duration = world.time + amount
		else if(amount > 0)
			P = apply_status_effect(STATUS_EFFECT_PARALYZED, amount)
	return P


/mob/living/proc/AdjustParalysis(amount, bound_lower = 0, bound_upper = INFINITY, ignore_canparalyze = FALSE)
	return SetParalysis(directional_bounded_sum(AmountParalyzed(), amount, bound_lower, bound_upper), ignore_canparalyze)


// SILENT
/mob/living/proc/AmountSilenced()
	RETURN_STATUS_EFFECT_STRENGTH(STATUS_EFFECT_SILENCED)

/mob/living/proc/Silence(amount)
	SetSilence(max(amount, AmountSilenced()))

/mob/living/proc/SetSilence(amount)
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		return
	SET_STATUS_EFFECT_STRENGTH(STATUS_EFFECT_SILENCED, amount)

/mob/living/proc/AmountAbsoluteSilenced()
	RETURN_STATUS_EFFECT_STRENGTH(STATUS_EFFECT_ABSSILENCED)

/mob/living/proc/AbsoluteSilence(amount)
	SetAbsoluteSilence(max(amount, AmountAbsoluteSilenced()))

/mob/living/proc/SetAbsoluteSilence(amount)
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		return
	SET_STATUS_EFFECT_STRENGTH(STATUS_EFFECT_ABSSILENCED, amount)

/mob/living/proc/AdjustSilence(amount, bound_lower = 0, bound_upper = INFINITY)
	SetSilence(directional_bounded_sum(AmountSilenced(), amount, bound_lower, bound_upper))


// SLEEPING
/mob/living/proc/IsSleeping()
	return has_status_effect(STATUS_EFFECT_SLEEPING)


/mob/living/proc/AmountSleeping() //How many deciseconds remain in our sleep
	var/datum/status_effect/incapacitating/sleeping/S = IsSleeping()
	if(S)
		return S.duration - world.time
	return 0


/mob/living/proc/Sleeping(amount)
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_SLEEP, amount) & COMPONENT_NO_EFFECT)
		return
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		return
	var/datum/status_effect/incapacitating/sleeping/S = IsSleeping()
	if(S)
		S.duration = max(world.time + amount, S.duration)
	else if(amount > 0)
		S = apply_status_effect(STATUS_EFFECT_SLEEPING, amount)
	return S


/mob/living/proc/SetSleeping(amount)
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_SLEEP, amount) & COMPONENT_NO_EFFECT)
		return
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		return
	if(frozen) // If the mob has been admin frozen, sleeping should not be changeable
		return
	var/datum/status_effect/incapacitating/sleeping/S = IsSleeping()
	if(amount <= 0)
		if(S)
			qdel(S)
	else
		if(S)
			S.duration = amount + world.time
		else
			S = apply_status_effect(STATUS_EFFECT_SLEEPING, amount)
	return S


/mob/living/proc/PermaSleeping() /// used for admin freezing.
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_SLEEP, -1) & COMPONENT_NO_EFFECT)
		return
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		return
	var/datum/status_effect/incapacitating/sleeping/S = IsSleeping()
	if(S)
		S.duration = -1
	else
		S = apply_status_effect(STATUS_EFFECT_SLEEPING, -1)
	return S


/mob/living/proc/AdjustSleeping(amount, bound_lower = 0, bound_upper = INFINITY)
	SetSleeping(directional_bounded_sum(AmountSleeping(), amount, bound_lower, bound_upper))


// SLOWED
/mob/living/proc/IsSlowed()
	return has_status_effect(STATUS_EFFECT_SLOWED)

/mob/living/proc/Slowed(amount, slowdown_value)
	var/datum/status_effect/incapacitating/slowed/S = IsSlowed()
	if(S)
		S.duration = max(world.time + amount, S.duration)
		S.set_slowdown_value(slowdown_value)
	else if(amount > 0)
		S = apply_status_effect(STATUS_EFFECT_SLOWED, amount, slowdown_value)
	return S

/mob/living/proc/SetSlowed(amount, slowdown_value)
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		return
	var/datum/status_effect/incapacitating/slowed/S = IsSlowed()
	if(amount <= 0 || slowdown_value <= 0)
		if(S)
			qdel(S)
	else
		if(S)
			S.duration = amount
			S.set_slowdown_value(slowdown_value)
		else
			S = apply_status_effect(STATUS_EFFECT_SLOWED, amount, slowdown_value)
	return S


/mob/living/proc/AdjustSlowedDuration(amount, bound_lower = 0, bound_upper = INFINITY)
	var/datum/status_effect/incapacitating/slowed/S = IsSlowed()
	if(S)
		S.duration = directional_bounded_sum(S.duration, amount, bound_lower, bound_upper)

/mob/living/proc/AdjustSlowedIntensity(intensity)
	var/datum/status_effect/incapacitating/slowed/S = IsSlowed()
	if(S)
		S.slowdown_value += intensity

// SLURRING
/mob/living/proc/AmountSluring()
	RETURN_STATUS_EFFECT_STRENGTH(STATUS_EFFECT_SLURRING)

/mob/living/proc/Slur(amount)
	SetSlur(max(AmountSluring(), amount))

/mob/living/proc/SetSlur(amount)
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		return
	SET_STATUS_EFFECT_STRENGTH(STATUS_EFFECT_SLURRING, amount)

/mob/living/proc/AdjustSlur(amount, bound_lower = 0, bound_upper = INFINITY)
	SetSlur(directional_bounded_sum(AmountSluring(), amount, bound_lower, bound_upper))

// CULTSLURRING
/mob/living/proc/AmountCultSlurring()
	RETURN_STATUS_EFFECT_STRENGTH(STATUS_EFFECT_CULT_SLUR)

/mob/living/proc/CultSlur(amount)
	SetCultSlur(max(AmountCultSlurring(), amount))

/mob/living/proc/SetCultSlur(amount)
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		return
	SET_STATUS_EFFECT_STRENGTH(STATUS_EFFECT_CULT_SLUR, amount)

/mob/living/proc/AdjustCultSlur(amount, bound_lower = 0, bound_upper = INFINITY)
	SetCultSlur(directional_bounded_sum(AmountCultSlurring(), amount, bound_lower, bound_upper))

// CLOCKSLURRING
/mob/living/proc/AmountClockSlurring()
	RETURN_STATUS_EFFECT_STRENGTH(STATUS_EFFECT_CLOCK_CULT_SLUR)

/mob/living/proc/ClockSlur(amount)
	SetClockSlur(max(AmountClockSlurring(), amount))

/mob/living/proc/SetClockSlur(amount)
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		return
	SET_STATUS_EFFECT_STRENGTH(STATUS_EFFECT_CLOCK_CULT_SLUR, amount)

/mob/living/proc/AdjustClockSlur(amount, bound_lower = 0, bound_upper = INFINITY)
	SetClockSlur(directional_bounded_sum(AmountClockSlurring(), amount, bound_lower, bound_upper))

/* STUN */
/mob/proc/IsStunned()
	return


/mob/living/IsStunned() //If we're stunned
	return has_status_effect(STATUS_EFFECT_STUN)


/mob/living/proc/AmountStun() //How many deciseconds remain in our stun
	var/datum/status_effect/incapacitating/stun/S = IsStunned()
	if(S)
		return S.duration - world.time
	return 0


/mob/living/proc/Stun(amount, ignore_canstun = FALSE) //Can't go below remaining duration
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_STUN, amount, ignore_canstun) & COMPONENT_NO_EFFECT)
		return
	if(check_incapacitating_immunity(CANSTUN, ignore_canstun))
		return
	var/datum/status_effect/incapacitating/stun/S = IsStunned()
	if(S)
		S.duration = max(world.time + amount, S.duration)
	else if(amount > 0)
		S = apply_status_effect(STATUS_EFFECT_STUN, amount)
	return S


/mob/living/proc/SetStunned(amount, ignore_canstun = FALSE) //Sets remaining duration
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_STUN, amount, ignore_canstun) & COMPONENT_NO_EFFECT)
		return
	if(check_incapacitating_immunity(CANSTUN, ignore_canstun))
		return
	var/datum/status_effect/incapacitating/stun/S = IsStunned()
	if(amount <= 0)
		if(S)
			qdel(S)
	else
		if(S)
			S.duration = world.time + amount
		else
			S = apply_status_effect(STATUS_EFFECT_STUN, amount)
	return S


/mob/living/proc/AdjustStunned(amount, ignore_canstun = FALSE) //Adds to remaining duration
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_STUN, amount, ignore_canstun) & COMPONENT_NO_EFFECT)
		return
	if(check_incapacitating_immunity(CANSTUN, ignore_canstun))
		return
	var/datum/status_effect/incapacitating/stun/S = IsStunned()
	if(S)
		S.duration += amount
	else if(amount > 0)
		S = apply_status_effect(STATUS_EFFECT_STUN, amount)
	return S


/* KNOCKDOWN */

/mob/living/proc/IsKnockdown() //If we're knocked down
	return has_status_effect(STATUS_EFFECT_KNOCKDOWN)


/mob/living/proc/AmountKnockdown() //How many deciseconds remain in our knockdown
	var/datum/status_effect/incapacitating/knockdown/K = IsKnockdown()
	if(K)
		return K.duration - world.time
	return 0


/mob/living/proc/Knockdown(amount, ignore_canknockdown = FALSE) //Can't go below remaining duration
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_KNOCKDOWN, amount, ignore_canknockdown) & COMPONENT_NO_EFFECT)
		return
	if(check_incapacitating_immunity(CANKNOCKDOWN, ignore_canknockdown))
		return
	var/datum/status_effect/incapacitating/knockdown/K = IsKnockdown()
	if(K)
		K.duration = max(world.time + amount, K.duration)
	else if(amount > 0)
		K = apply_status_effect(STATUS_EFFECT_KNOCKDOWN, amount)
	return K


/mob/living/proc/SetKnockdown(amount, ignore_canknockdown = FALSE) //Sets remaining duration
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_KNOCKDOWN, amount, ignore_canknockdown) & COMPONENT_NO_EFFECT)
		return
	if(check_incapacitating_immunity(CANKNOCKDOWN, ignore_canknockdown))
		return
	var/datum/status_effect/incapacitating/knockdown/K = IsKnockdown()
	if(amount <= 0)
		if(K)
			qdel(K)
	else
		if(K)
			K.duration = world.time + amount
		else
			K = apply_status_effect(STATUS_EFFECT_KNOCKDOWN, amount)
	return K


/mob/living/proc/AdjustKnockdown(amount, ignore_canknockdown = FALSE) //Adds to remaining duration
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_KNOCKDOWN, amount, ignore_canknockdown) & COMPONENT_NO_EFFECT)
		return
	if(check_incapacitating_immunity(CANKNOCKDOWN, ignore_canknockdown))
		return
	var/datum/status_effect/incapacitating/knockdown/K = IsKnockdown()
	if(K)
		K.duration += amount
	else if(amount > 0)
		K = apply_status_effect(STATUS_EFFECT_KNOCKDOWN, amount)
	return K


/* IMMOBILIZED */
/mob/living/proc/IsImmobilized()
	return has_status_effect(STATUS_EFFECT_IMMOBILIZED)


/mob/living/proc/Immobilize(amount, ignore_canstun = FALSE)
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_IMMOBILIZE, amount, ignore_canstun) & COMPONENT_NO_EFFECT)
		return
	if(check_incapacitating_immunity(CANSTUN, ignore_canstun))
		return
	var/datum/status_effect/incapacitating/immobilized/I = IsImmobilized()
	if(I)
		I.duration = max(world.time + amount, I.duration)
	else if(amount > 0)
		I = apply_status_effect(STATUS_EFFECT_IMMOBILIZED, amount)
	return I


/mob/living/proc/SetImmobilized(amount, ignore_canstun = FALSE) //Sets remaining duration
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_IMMOBILIZE, amount, ignore_canstun) & COMPONENT_NO_EFFECT)
		return
	if(check_incapacitating_immunity(CANSTUN, ignore_canstun))
		return
	var/datum/status_effect/incapacitating/immobilized/I = IsImmobilized()
	if(amount <= 0)
		if(I)
			qdel(I)
	else
		if(I)
			I.duration = world.time + amount
		else
			I = apply_status_effect(STATUS_EFFECT_IMMOBILIZED, amount)
	return I


/mob/living/proc/AdjustImmobilized(amount, ignore_canstun = FALSE) //Adds to remaining duration
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_IMMOBILIZE, amount, ignore_canstun) & COMPONENT_NO_EFFECT)
		return
	if(check_incapacitating_immunity(CANSTUN, ignore_canstun))
		return
	var/datum/status_effect/incapacitating/immobilized/I = IsImmobilized()
	if(I)
		I.duration += amount
	else if(amount > 0)
		I = apply_status_effect(STATUS_EFFECT_IMMOBILIZED, amount)
	return I


// STUTTERING

/mob/living/proc/AmountStuttering()
	RETURN_STATUS_EFFECT_STRENGTH(STATUS_EFFECT_STAMMER)

/mob/living/proc/Stuttering(amount, ignore_canstun = FALSE)
	SetStuttering(max(AmountStuttering(), amount), ignore_canstun)

/mob/living/proc/SetStuttering(amount, ignore_canstun = FALSE)
	SET_STATUS_EFFECT_STRENGTH(STATUS_EFFECT_STAMMER, amount)

/mob/living/proc/AdjustStuttering(amount, bound_lower = 0, bound_upper = INFINITY, ignore_canstun = FALSE)
	SetStuttering(directional_bounded_sum(AmountStuttering(), amount, bound_lower, bound_upper), ignore_canstun)


// WEAKEN

/mob/proc/IsWeakened()
	return


/mob/living/IsWeakened()
	return has_status_effect(STATUS_EFFECT_WEAKENED)


/mob/living/proc/AmountWeakened() //How many deciseconds remain in our Weakened status effect
	var/datum/status_effect/incapacitating/weakened/P = IsWeakened()
	if(P)
		return P.duration - world.time
	return 0


/mob/living/proc/Weaken(amount, ignore_canweaken = FALSE) //Can't go below remaining duration
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_WEAKEN, amount, ignore_canweaken) & COMPONENT_NO_EFFECT)
		return
	if(check_incapacitating_immunity(CANWEAKEN, ignore_canweaken))
		return
	var/datum/status_effect/incapacitating/weakened/P = IsWeakened()
	if(P)
		P.duration = max(world.time + amount, P.duration)
	else if(amount > 0)
		P = apply_status_effect(STATUS_EFFECT_WEAKENED, amount)
	return P


/mob/living/proc/SetWeakened(amount, ignore_canweaken = FALSE) //Sets remaining duration
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_WEAKEN, amount, ignore_canweaken) & COMPONENT_NO_EFFECT)
		return
	if(check_incapacitating_immunity(CANWEAKEN, ignore_canweaken))
		return
	var/datum/status_effect/incapacitating/weakened/P = IsWeakened()
	if(amount <= 0)
		if(P)
			qdel(P)
	else
		if(P)
			P.duration = world.time + amount
		else
			P = apply_status_effect(STATUS_EFFECT_WEAKENED, amount)
	return P


/mob/living/proc/AdjustWeakened(amount, ignore_canweaken = FALSE) //Adds to remaining duration
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_WEAKEN, amount, ignore_canweaken) & COMPONENT_NO_EFFECT)
		return
	if(check_incapacitating_immunity(CANWEAKEN, ignore_canweaken))
		return
	var/datum/status_effect/incapacitating/weakened/P = IsWeakened()
	if(P)
		P.duration += amount
	else if(amount > 0)
		P = apply_status_effect(STATUS_EFFECT_WEAKENED, amount)
	return P


/mob/living/proc/AmountDisgust()
	RETURN_STATUS_EFFECT_STRENGTH(STATUS_EFFECT_DISGUST)

/mob/living/proc/Disgust(amount)
	SetDisgust(max(AmountDisgust(), amount))

/mob/living/proc/SetDisgust(amount)
	SET_STATUS_EFFECT_STRENGTH(STATUS_EFFECT_DISGUST, amount)

/mob/living/proc/AdjustDisgust(amount, bound_lower = 0, bound_upper = INFINITY)
	SetDisgust(directional_bounded_sum(AmountDisgust(), amount, bound_lower, bound_upper))

//DEAFNESS
/mob/living/proc/AmountDeaf()
	RETURN_STATUS_EFFECT_STRENGTH(STATUS_EFFECT_DEAF)

/mob/living/proc/Deaf(amount)
	SetDeaf(max(amount, AmountDeaf()))

/mob/living/proc/SetDeaf(amount)
	SET_STATUS_EFFECT_STRENGTH(STATUS_EFFECT_DEAF, amount)

/mob/living/proc/AdjustDeaf(amount, bound_lower = 0, bound_upper = INFINITY)
	SetDeaf(directional_bounded_sum(AmountDeaf(), amount, bound_lower, bound_upper))

/mob/living/proc/CureDeaf()
	CureIfHasDisability(GLOB.deafblock)

//
//		DISABILITIES
//

// Blind

/mob/living/proc/CureBlind(updating = TRUE)
	. = STATUS_UPDATE_NONE
	for(var/trait_source in GET_TRAIT_SOURCES(src, TRAIT_BLIND))
		REMOVE_TRAIT(src, TRAIT_BLIND, trait_source)
		. |= STATUS_UPDATE_BLIND
	if(. && updating)
		CureIfHasDisability(GLOB.blindblock)
		update_blind_effects()

// Coughing

/mob/living/proc/CureCoughing()
	CureIfHasDisability(GLOB.coughblock)

// Epilepsy

/mob/living/proc/CureEpilepsy()
	CureIfHasDisability(GLOB.epilepsyblock)

// Mute

/mob/living/proc/CureMute()
	CureIfHasDisability(GLOB.muteblock)

// Nearsighted

/mob/living/proc/CureNearsighted(updating = TRUE)
	. = STATUS_UPDATE_NONE
	for(var/trait_source in GET_TRAIT_SOURCES(src, TRAIT_NEARSIGHTED))
		REMOVE_TRAIT(src, TRAIT_NEARSIGHTED, trait_source)
		. |= STATUS_UPDATE_NEARSIGHTED
	if(. && updating)
		CureIfHasDisability(GLOB.glassesblock)
		update_nearsighted_effects()

// Nervous

/mob/living/proc/CureNervous()
	CureIfHasDisability(GLOB.nervousblock)

// Tourettes

/mob/living/proc/CureTourettes()
	CureIfHasDisability(GLOB.twitchblock)


/mob/living/proc/CureIfHasDisability(block)
	if(dna?.GetSEState(block))
		force_gene_block(block, FALSE)


///Unignores all slowdowns that lack the IGNORE_NOSLOW flag.
/mob/living/proc/unignore_slowdown(source)
	REMOVE_TRAIT(src, TRAIT_IGNORESLOWDOWN, source)
	update_movespeed()


///Ignores all slowdowns that lack the IGNORE_NOSLOW flag.
/mob/living/proc/ignore_slowdown(source)
	ADD_TRAIT(src, TRAIT_IGNORESLOWDOWN, source)
	update_movespeed()


///Ignores specific slowdowns. Accepts a list of slowdowns.
/mob/living/proc/add_movespeed_mod_immunities(source, slowdown_type, update = TRUE)
	if(islist(slowdown_type))
		for(var/listed_type in slowdown_type)
			if(ispath(listed_type))
				listed_type = "[listed_type]" //Path2String
			LAZYADDASSOCLIST(movespeed_mod_immunities, listed_type, source)
	else
		if(ispath(slowdown_type))
			slowdown_type = "[slowdown_type]" //Path2String
		LAZYADDASSOCLIST(movespeed_mod_immunities, slowdown_type, source)
	if(update)
		update_movespeed()


///Unignores specific slowdowns. Accepts a list of slowdowns.
/mob/living/proc/remove_movespeed_mod_immunities(source, slowdown_type, update = TRUE)
	if(islist(slowdown_type))
		for(var/listed_type in slowdown_type)
			if(ispath(listed_type))
				listed_type = "[listed_type]" //Path2String
			LAZYREMOVEASSOC(movespeed_mod_immunities, listed_type, source)
	else
		if(ispath(slowdown_type))
			slowdown_type = "[slowdown_type]" //Path2String
		LAZYREMOVEASSOC(movespeed_mod_immunities, slowdown_type, source)
	if(update)
		update_movespeed()


///////////////////////////////// FROZEN /////////////////////////////////////

/mob/living/proc/IsFrozen()
	return has_status_effect(/datum/status_effect/freon)


#undef RETURN_STATUS_EFFECT_STRENGTH
#undef SET_STATUS_EFFECT_STRENGTH

