/datum/element/effect_aura
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY
	var/list/range_by_target = list()
	var/list/active_by_target = list()
	var/list/monitor_by_target = list()

/datum/element/effect_aura/Attach(datum/target, range = 1, enabled = TRUE)
	. = ..()
	if(!isatom(target) || isarea(target))
		return ELEMENT_INCOMPATIBLE
	var/atom/atom_target = target
	range_by_target[atom_target] = max(0, range)
	active_by_target[atom_target] = enabled
	RegisterSignal(atom_target, COMSIG_AURA_SET_ENABLED, PROC_REF(on_set_enabled))

	if(!enabled)
		return
	var/datum/proximity_monitor/advanced/aura/mon = new(atom_target, range_by_target[atom_target], FALSE, src, atom_target)
	monitor_by_target[atom_target] = mon

/datum/element/effect_aura/Detach(datum/source, ...)
	UnregisterSignal(source, COMSIG_AURA_SET_ENABLED)
	var/datum/proximity_monitor/advanced/aura/mon = monitor_by_target[source]
	if(mon)
		QDEL_NULL(mon)
	range_by_target -= source
	active_by_target -= source
	monitor_by_target -= source
	return ..()

/datum/element/effect_aura/Destroy(force)
	if(!force)
		return QDEL_HINT_LETMELIVE
	range_by_target = null
	active_by_target = null
	monitor_by_target = null
	return ..()

/datum/element/effect_aura/proc/enable_aura(atom/target, enabled = TRUE)
	if(!(target in active_by_target))
		return FALSE
	if(active_by_target[target] == enabled)
		return TRUE
	active_by_target[target] = enabled
	var/datum/proximity_monitor/advanced/aura/mon = monitor_by_target[target]
	if(!enabled)
		if(mon)
			QDEL_NULL(mon)
			monitor_by_target -= target
		return TRUE
	if(mon)
		return TRUE
	mon = new(target, range_by_target[target], FALSE, src, target)
	monitor_by_target[target] = mon
	return TRUE

/datum/element/effect_aura/proc/toggle_aura(atom/target)
	if(!(target in active_by_target))
		return FALSE
	return enable_aura(target, !active_by_target[target])

/datum/element/effect_aura/proc/on_set_enabled(atom/target, enabled)
	SIGNAL_HANDLER
	enable_aura(target, enabled)

/datum/element/effect_aura/proc/set_aura_range(atom/target, range)
	if(!(target in range_by_target))
		return FALSE
	range_by_target[target] = max(0, range)
	var/datum/proximity_monitor/advanced/aura/mon = monitor_by_target[target]
	if(mon)
		mon.set_range(range_by_target[target], TRUE)
		mon.recalculate_field(TRUE)
	return TRUE

/datum/element/effect_aura/proc/on_atom_enter(atom/aura_owner, atom/movable/arrived)
	return

/datum/element/effect_aura/proc/on_atom_exit(atom/aura_owner, atom/movable/gone)
	return

/datum/proximity_monitor/advanced/aura
	edge_is_a_field = TRUE
	var/datum/element/effect_aura/owner
	var/atom/aura_owner
	var/list/inside = list()

/datum/proximity_monitor/advanced/aura/New(atom/_host, range, _ignore_if_not_on_turf = TRUE, datum/element/effect_aura/_owner, atom/_aura_owner)
	owner = _owner
	aura_owner = _aura_owner
	..()
	recalculate_field(TRUE)

/datum/proximity_monitor/advanced/aura/Destroy()
	clear_inside()
	owner = null
	aura_owner = null
	inside = null
	return ..()

/datum/proximity_monitor/advanced/aura/proc/is_inside(turf/target_turf)
	if(!target_turf)
		return FALSE
	if(target_turf in field_turfs)
		return TRUE
	if(edge_is_a_field && (target_turf in edge_turfs))
		return TRUE
	return FALSE

/datum/proximity_monitor/advanced/aura/proc/clear_inside()
	if(!inside)
		return
	for(var/atom/movable/inside_movable in inside.Copy())
		inside -= inside_movable
		owner?.on_atom_exit(aura_owner, inside_movable)
	inside = list()

/datum/proximity_monitor/advanced/aura/proc/handle_enter(atom/movable/movable_target)
	if(movable_target in inside)
		return
	inside |= movable_target
	owner?.on_atom_enter(aura_owner, movable_target)

/datum/proximity_monitor/advanced/aura/proc/handle_exit_if_outside(atom/movable/movable_target, turf/new_loc = null)
	if(!(movable_target in inside))
		return
	var/turf/current_turf = new_loc ? new_loc : get_turf(movable_target)
	if(is_inside(current_turf))
		return
	inside -= movable_target
	owner?.on_atom_exit(aura_owner, movable_target)

/datum/proximity_monitor/advanced/aura/setup_field_turf(turf/target_turf)
	for(var/atom/movable/movable_target in target_turf)
		handle_enter(movable_target)

/datum/proximity_monitor/advanced/aura/cleanup_field_turf(turf/target_turf)
	for(var/atom/movable/movable_target in target_turf)
		handle_exit_if_outside(movable_target)

/datum/proximity_monitor/advanced/aura/field_turf_crossed(atom/movable/movable, turf/old_location, turf/new_location)
	handle_enter(movable)

/datum/proximity_monitor/advanced/aura/field_turf_uncrossed(atom/movable/movable, turf/old_location, turf/new_location)
	handle_exit_if_outside(movable, new_location)


//MARK: NO RANGED


/datum/element/effect_aura/no_ranged

/datum/element/effect_aura/no_ranged/on_atom_enter(atom/aura_owner, atom/movable/arrived)
	if(!isliving(arrived))
		return
	var/mob/living/target = arrived
	ADD_TRAIT(target, TRAIT_RANGED_MALFUNCTION, aura_owner)

/datum/element/effect_aura/no_ranged/on_atom_exit(atom/aura_owner, atom/movable/gone)
	if(!isliving(gone))
		return
	var/mob/living/target = gone
	REMOVE_TRAIT(target, TRAIT_RANGED_MALFUNCTION, aura_owner)
