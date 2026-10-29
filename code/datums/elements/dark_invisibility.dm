/datum/element/dark_invisibility
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	var/base_alpha
	var/dark_alpha
	var/alpha_source

/datum/element/dark_invisibility/Attach(mob/living/target, base_alpha, dark_alpha, alpha_source)
	if(!istype(target))
		return ELEMENT_INCOMPATIBLE
	. = ..()
	src.base_alpha = base_alpha
	src.dark_alpha = dark_alpha
	src.alpha_source = alpha_source
	animate(target, time = 5, alpha = base_alpha)
	target.alpha_set(standartize_alpha(base_alpha), alpha_source)
	RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))

/datum/element/dark_invisibility/Detach(mob/living/source)
	UnregisterSignal(source, COMSIG_MOVABLE_MOVED)
	animate(source, time = 5, alpha = 255)
	source.alpha_set(1, alpha_source)
	return ..()

/datum/element/dark_invisibility/proc/on_move(mob/living/source, atom/oldloc, dir, forced)
	SIGNAL_HANDLER
	var/turf/location = get_turf(source)
	var/light_available = location.get_lumcount() * 10
	if(light_available <= 2)
		animate(source, time = 5, alpha = dark_alpha)
		source.alpha_set(standartize_alpha(dark_alpha), alpha_source)
		return
	animate(source, time = 5, alpha = base_alpha)
	source.alpha_set(standartize_alpha(base_alpha), alpha_source)

