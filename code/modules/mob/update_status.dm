// These are procs that cause immediate updates to features of the mob - prefixed with `update_`
// Procs that have a stacking effect depending on how many times they are called
// do not belong in this file - those go in `life.dm` instead, with the prefix `handle_`

// OVERLAY/SIGHT PROCS

// These return 0 if they are not applying an overlay, and 1 if they are

// Call this to immediately apply blindness effects, instead of
// waiting for the next `Life` tick
/mob/proc/update_blind_effects()
	// No handling for this on the mob level
	return 0

/mob/proc/update_blurry_effects()
	// No handling for this on the mob level
	return 0

/mob/proc/update_druggy_effects()
	// No handling for this on the mob level
	return 0

/mob/proc/update_nearsighted_effects()
	// No handling for this on the mob level
	return 0

/mob/proc/update_sleeping_effects()
	// No handling for this on the mob level
	return 0

/mob/proc/update_tint_effects()
	// No handling for this on the mob level
	return 0

// Procs that give information about the status of the mob

/mob/proc/has_vision(information_only = FALSE)
	return 1

/mob/proc/can_speak()
	return 1

/// Called whenever anything that modifes incapacitated is ran, updates it and sends a signal if it changes
/// Returns TRUE if anything changed, FALSE otherwise
/mob/proc/update_incapacitated()
	SIGNAL_HANDLER
	var/old_incap = incapacitated
	incapacitated = build_incapacitated()
	if(old_incap == incapacitated)
		return FALSE

	SEND_SIGNAL(src, COMSIG_MOB_INCAPACITATE_CHANGED, old_incap, incapacitated)
	return TRUE

/// Returns an updated incapacitated bitflag. If a flag is set it means we're incapacitated in that case
/mob/proc/build_incapacitated()
	return NONE

// Procs that update other things about the mob

/mob/proc/update_stat()
	return

/mob/proc/update_health_hud()
	return

/mob/proc/update_stamina_hud()
	return

/mob/proc/update_nutrition_hud()
	return
