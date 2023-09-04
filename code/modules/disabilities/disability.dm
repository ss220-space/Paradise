/datum/disability
	/// The name of the disability.
	var/name = "Disability"
	/// Mind that owns this datum.
	var/datum/mind/owner

/datum/disability/Destroy(force, ...)
	remove_disability()
	if(owner)
		LAZYREMOVE(owner.disability_datums, src)
	owner = null
	return ..()

/datum/disability/proc/on_gain(var/mob/current_mob)
	if(!owner?.current)
		return FALSE
	apply_disability(current_mob)
	return TRUE

/datum/disability/proc/apply_disability(var/mob/current_mob)
	return

/datum/disability/proc/remove_disability()
	return
