// Rust charge, a charge action that can only be started on rust (and only destroys rust tiles)
/obj/effect/proc_holder/spell/mob_cooldown/charge/rust
	name = "Rust Charge"
	desc = "A charge that must be started on a rusted tile and will destroy any rusted objects you come into contact with, \
		will deal high damage to others and rust around you during the charge. \
		As it is the rust that empowers you with this ability, no focus is needed."
	charge_distance = 10
	charge_damage = 50
	base_cooldown = 45 SECONDS


/obj/effect/proc_holder/spell/mob_cooldown/charge/rust/on_spell_gain(mob/user)
	..()
	var/turf/start_turf = get_turf(action.owner)
	if(!istype(start_turf) || !HAS_TRAIT(start_turf, TRAIT_RUSTY))
		return FALSE

	cooldown_handler.start_recharge(135 SECONDS, 135 SECONDS)
	charge_sequence(action.owner, user, charge_delay, charge_past)
	cooldown_handler.start_recharge()
	return TRUE


/obj/effect/proc_holder/spell/mob_cooldown/charge/rust/on_move(atom/source, atom/new_loc, atom/target)
	var/turf/victim = get_turf(action.owner)
	if(!actively_moving)
		return COMPONENT_MOVABLE_BLOCK_PRE_MOVE

	new /obj/effect/temp_visual/decoy/fading(source.loc, source)
	INVOKE_ASYNC(src, PROC_REF(DestroySurroundings), source)
	victim.rust_heretic_act()
	for(var/dir in GLOB.cardinal)
		var/turf/nearby_turf = get_step(victim, dir)
		if(!istype(nearby_turf))
			continue

		nearby_turf.rust_heretic_act()


/obj/effect/proc_holder/spell/mob_cooldown/charge/rust/DestroySurroundings(atom/movable/charger)
	if(!destroy_objects)
		return

	for(var/dir in GLOB.cardinal)
		var/turf/source = get_turf(action.owner)
		var/turf/simulated/wall/next_turf = get_step(charger, dir)
		if(!istype(source) || !istype(next_turf) || !HAS_TRAIT(source, TRAIT_RUSTY) || !HAS_TRAIT(next_turf, TRAIT_RUSTY))
			continue

		next_turf.ex_act(EXPLODE_HEAVY)


/obj/effect/proc_holder/spell/mob_cooldown/charge/rust/on_bump(atom/movable/source, atom/target)
	if(action.owner == target)
		return

	if(destroy_objects)
		if(isturf(target))
			INVOKE_ASYNC(src, PROC_REF(DestroySurroundings), source)
		if(isobj(target) && target.density)
			target.ex_act(EXPLODE_HEAVY)

	INVOKE_ASYNC(src, PROC_REF(DestroySurroundings), source)
	try_hit_target(source, target, charge_damage)
