/**
 * ## Death link component
 *
 * When the owner of this component dies it also gibs a linked mobs
 */
/datum/component/death_linked
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	/// Mobs in that list will die when the user dies. Contains weakrefs
	var/list/linked_mobs

/datum/component/death_linked/Initialize(list/mobs)
	. = ..()

	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	for(var/mob/mob as anything in mobs)
		LAZYADD(linked_mobs, WEAKREF(mob))

/datum/component/death_linked/Destroy(force)
	LAZYNULL(linked_mobs)

	return ..()

/datum/component/death_linked/InheritComponent(datum/component/death_linked/new_comp, i_am_original, list/mobs)
	if(!i_am_original)
		return

	if(!LAZYLEN(mobs))
		return

	for(var/mob/mob as anything in mobs)
		LAZYADD(linked_mobs, WEAKREF(mob))

/datum/component/death_linked/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_LIVING_DEATH, PROC_REF(on_death))

/datum/component/death_linked/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, COMSIG_LIVING_DEATH)

/datum/component/death_linked/proc/on_death(mob/living/target, gibbed)
	SIGNAL_HANDLER

	if(!LAZYLEN(linked_mobs))
		return

	for(var/datum/weakref/weakref as anything in linked_mobs)
		var/mob/living/linked_mob_resolved = weakref.resolve()
		linked_mob_resolved?.gib()
