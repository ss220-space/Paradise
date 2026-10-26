/datum/element/dark_invisibility

/datum/element/dark_invisibility/Attach(atom/target)
	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE
	. = ..()
	RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))

/datum/element/dark_invisibility/Detach(datum/source)
	UnregisterSignal(source, COMSIG_MOVABLE_MOVED)
	return ..()

/datum/element/dark_invisibility/proc/on_move(mob/living/source, atom/oldloc, dir, forced)
	SIGNAL_HANDLER
	var/turf/location = get_turf(source)
	var/light_available = location.get_lumcount() * 10
	if(light_available <= 2)
		animate(source, time = 5, alpha = 50)
		source.alpha_set(standartize_alpha(50), ALPHA_SOURCE_ZOMBIE)
		return
	animate(source, time = 5, alpha = 255)
	source.alpha_set(1, ALPHA_SOURCE_ZOMBIE)

