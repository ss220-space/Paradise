GLOBAL_LIST_INIT(freon_color_matrix, list("#2E5E69", "#60A2A8", "#A1AFB1", rgb(0, 0, 0)))

/// Simple element to handle frozen objs.
/datum/element/frozen

/datum/element/frozen/Attach(datum/target)
	. = ..()
	if(!isobj(target))
		return ELEMENT_INCOMPATIBLE

	var/obj/target_obj = target
	if(target_obj.resistance_flags & FREEZE_PROOF)
		return ELEMENT_INCOMPATIBLE

	if(HAS_TRAIT(target_obj, TRAIT_FROZEN))
		return ELEMENT_INCOMPATIBLE

	ADD_TRAIT(target_obj, TRAIT_FROZEN, ELEMENT_TRAIT(type))
	target_obj.add_atom_colour(GLOB.freon_color_matrix, TEMPORARY_COLOUR_PRIORITY)
	target_obj.alpha -= 25

	RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))
	RegisterSignal(target, COMSIG_MOVABLE_THROW_LANDED, PROC_REF(shatter_on_landed))
	RegisterSignal(target, COMSIG_MOVABLE_IMPACT, PROC_REF(shatter_on_throw))
	RegisterSignal(target, COMSIG_OBJ_UNFREEZE, PROC_REF(on_unfreeze))

/datum/element/frozen/Detach(datum/source, ...)
	var/obj/obj_source = source
	REMOVE_TRAIT(obj_source, TRAIT_FROZEN, ELEMENT_TRAIT(type))
	UnregisterSignal(obj_source, list(COMSIG_MOVABLE_MOVED, COMSIG_MOVABLE_THROW_LANDED, COMSIG_MOVABLE_IMPACT, COMSIG_OBJ_UNFREEZE))
	obj_source.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, GLOB.freon_color_matrix)
	obj_source.alpha += 25
	return ..()

/datum/element/frozen/proc/on_unfreeze(datum/source)
	SIGNAL_HANDLER
	Detach(source)

/datum/element/frozen/proc/shatter_on_throw(datum/source, atom/hit_atom, datum/thrownthing/throwing_datum, caught)
	SIGNAL_HANDLER
	if(caught)
		return
	shatter_on_landed(source, throwing_datum)

/datum/element/frozen/proc/shatter_on_landed(datum/target, datum/thrownthing/throwingdatum)
	SIGNAL_HANDLER
	var/obj/obj_target = target
	add_attack_logs(throwingdatum?.thrower, obj_target, "shattered by throwing it while frozen")
	obj_target.visible_message(span_danger("[obj_target.declent_ru(NOMINATIVE)] разлетается на миллион осколков!"))
	obj_target.deconstruct(FALSE)

/datum/element/frozen/proc/on_moved(datum/target)
	SIGNAL_HANDLER
	var/atom/movable/movable_target = target
	if(movable_target.throwing)
		return

	var/turf/simulated/turf_loc = movable_target.loc
	if(!istype(turf_loc))
		return

	var/datum/gas_mixture/air = turf_loc.get_readonly_air()
	if(air?.temperature() >= T0C)
		Detach(target)
