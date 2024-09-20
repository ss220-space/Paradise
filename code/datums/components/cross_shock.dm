/datum/component/cross_shock
	var/shock_damage
	var/energy_cost
	var/delay_between_shocks
	var/requires_cable
	///what we give to connect_loc by default
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	COOLDOWN_DECLARE(last_shock)


/datum/component/cross_shock/Initialize(shock_damage, energy_cost, delay_between_shocks, requires_cable = TRUE)
	if(!isatom(parent) || isarea(parent))
		return COMPONENT_INCOMPATIBLE
	if(ismovable(parent))
		AddComponent(/datum/component/connect_loc_behalf, parent, loc_connections)
		RegisterSignal(parent, COMSIG_ATOM_ENTERING, PROC_REF(on_entering))
		if(ismob(parent))
			RegisterSignal(parent, COMSIG_CARBON_LOSE_ORGAN, PROC_REF(on_organ_removal))
	else
		RegisterSignal(parent, COMSIG_ATOM_ENTERED, PROC_REF(on_entered))

	src.shock_damage = shock_damage
	src.energy_cost = energy_cost
	src.delay_between_shocks = delay_between_shocks
	src.requires_cable = requires_cable


/datum/component/cross_shock/UnregisterFromParent()
	if(ismovable(parent))
		qdel(GetComponent(/datum/component/connect_loc_behalf))
		UnregisterSignal(parent, COMSIG_ATOM_ENTERING)
	else
		UnregisterSignal(parent, COMSIG_ATOM_ENTERED)


/datum/component/cross_shock/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	if(isliving(arrived) && can_shock())
		do_shock(arrived)


/datum/component/cross_shock/proc/on_entering(datum/source, atom/destination, atom/oldloc, list/atom/old_locs)
	SIGNAL_HANDLER

	if(isturf(destination) && can_shock())
		for(var/mob/living/mob in (destination.contents - parent))
			do_shock(mob)


/datum/component/cross_shock/proc/can_shock()
	if(!COOLDOWN_FINISHED(src, last_shock))
		return FALSE
	var/atom/atom_parent = parent
	var/turf/our_turf = atom_parent.loc
	if(!isturf(our_turf))
		return FALSE
	if(isliving(parent))
		var/mob/living/mob_parent = parent
		if(mob_parent.stat == DEAD || mob_parent.incapacitated())
			return FALSE
	if(requires_cable)
		if((our_turf.transparent_floor == TURF_TRANSPARENT) || our_turf.intact || HAS_TRAIT(our_turf, TRAIT_TURF_COVERED))
			return FALSE
		var/obj/structure/cable/our_cable =	locate(/obj/structure/cable) in our_turf
		if(!our_cable || !our_cable.powernet || !our_cable.powernet.avail)
			return FALSE
	return TRUE


/datum/component/cross_shock/proc/do_shock(mob/living/victim)
	var/atom/atom_parent = parent
	if(requires_cable)
		var/obj/structure/cable/our_cable =	locate() in atom_parent.loc
		victim.electrocute_act(shock_damage, atom_parent.name)
		our_cable.add_load(energy_cost)
	else
		victim.electrocute_act(shock_damage, atom_parent.name)
	playsound(victim, 'sound/effects/eleczap.ogg', 30, TRUE)
	COOLDOWN_START(src, last_shock, delay_between_shocks)


/datum/component/cross_shock/proc/on_organ_removal(datum/source, obj/item/organ/internal/organ)
	SIGNAL_HANDLER

	if(istype(organ, /obj/item/organ/internal/heart/demon/pulse))
		qdel(src)

