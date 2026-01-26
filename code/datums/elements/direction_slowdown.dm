/datum/element/directional_slowdown
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	var/direction
	var/slowdown_value = 10 // defaults to this value if none is specified

/datum/element/directional_slowdown/Attach(datum/target, direction, slowdown_value)
	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE

	src.direction = direction
	src.slowdown_value = slowdown_value

	. = ..()
	RegisterSignal(target, COMSIG_MOB_CLIENT_PRE_LIVING_MOVE, PROC_REF(on_mob_client_pre_living_move))

/datum/element/directional_slowdown/Detach(datum/source, ...)
	var/mob/living/mob = source
	mob.remove_movespeed_modifier(/datum/movespeed_modifier/directional_slowdown)
	UnregisterSignal(source, COMSIG_MOB_CLIENT_PRE_LIVING_MOVE)
	. = ..()


/datum/element/directional_slowdown/proc/on_mob_client_pre_living_move(mob/source, new_loc, direct)
	SIGNAL_HANDLER
	var/slowdown = count_slowdown(direct)
	source.remove_movespeed_modifier(/datum/movespeed_modifier/directional_slowdown)
	var/datum/movespeed_modifier/directional_slowdown/slowdown_modifier = new()
	slowdown_modifier.multiplicative_slowdown = slowdown
	source.add_movespeed_modifier(slowdown_modifier)

/datum/element/directional_slowdown/proc/count_slowdown(direct)
	if(direction == direct)
		return slowdown_value

	if(REVERSE_DIR(direction) == direct)
		return 0

	if(!(direction in GLOB.cardinal) && !(direct in GLOB.cardinal))
		return slowdown_value / 2

	if(direction & direct)
		return slowdown_value

	if(!(REVERSE_DIR(direction) & direct))
		return slowdown_value / 2

	return 0

/datum/movespeed_modifier/directional_slowdown
	movetypes = GROUND
