// MARK: containment field
/obj/machinery/field/containment
	name = "containment field"
	desc = "An energy field."
	icon = 'icons/obj/engines_and_power/singularity.dmi'
	icon_state = "Contain_F"
	anchored = TRUE
	move_resist = INFINITY
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	use_power = NO_POWER_USE
	light_range = 4
	layer = ABOVE_OBJ_LAYER
	explosion_block = INFINITY
	///First of the generators producing the containment field
	var/obj/machinery/field/generator/field_gen_1 = null
	///Second of the generators producing the containment field
	var/obj/machinery/field/generator/field_gen_2 = null

/obj/machinery/field/containment/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SUPERMATTER_IMMUNE, INNATE_TRAIT)
	recalculate_atmos_connectivity()
	RegisterSignal(src, COMSIG_ATOM_SINGULARITY_TRY_MOVE, PROC_REF(block_singularity))
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	AddElement(/datum/element/give_turf_traits, string_list(list(TRAIT_CONTAINMENT_FIELD)))

/obj/machinery/field/containment/Destroy()
	if(field_gen_1)
		field_gen_1.fields -= src
		field_gen_1 = null
	if(field_gen_2)
		field_gen_2.fields -= src
		field_gen_2 = null
	recalculate_atmos_connectivity()
	return ..()

/obj/machinery/field/containment/attack_hand(mob/user)
	if(get_dist(src, user) > 1)
		return FALSE
	else
		yeet_shock(user)
		return TRUE

/obj/machinery/field/containment/attackby(obj/item/item, mob/user, params)
	yeet_shock(user)
	return ATTACK_CHAIN_BLOCKED_ALL

/obj/machinery/field/containment/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BURN)
			playsound(loc, 'sound/effects/empulse.ogg', 75, TRUE)
		if(BRUTE)
			playsound(loc, 'sound/effects/empulse.ogg', 75, TRUE)

/obj/machinery/field/containment/blob_act(obj/structure/blob/blob)
	return FALSE

/obj/machinery/field/containment/ex_act(severity, target)
	return FALSE

/obj/machinery/field/containment/attack_animal(mob/living/simple_animal/user)
	if(!field_gen_1 || !field_gen_2)
		qdel(src)
		return
	if(ismegafauna(user))
		user.visible_message(
			span_warning("[user] glows fiercely as the containment field flickers out!"),
		)
		field_gen_1.calc_power(INFINITY) // rip that 'containment' field
		user.adjustHealth(-user.obj_damage)
	else
		return ..()

/obj/machinery/field/containment/proc/on_entered(datum/source, atom/movable/considered_atom, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	if(isliving(considered_atom))
		var/mob/living/living_moving_through_field = considered_atom
		if(living_moving_through_field.incorporeal_move)
			return
		yeet_shock(considered_atom)

	if(ismachinery(considered_atom) || isstructure(considered_atom) || ismecha(considered_atom))
		bump_field(considered_atom)

/obj/machinery/field/containment/proc/set_master(master1, master2)
	if(!master1 || !master2)
		return FALSE
	field_gen_1 = master1
	field_gen_2 = master2
	return TRUE

/obj/machinery/field/containment/proc/block_singularity()
	SIGNAL_HANDLER

	return SINGULARITY_TRY_MOVE_BLOCK

/obj/machinery/field/containment/yeet_shock(mob/living/user)
	if(!field_gen_1 || !field_gen_2)
		qdel(src)
		return FALSE
	..()

/obj/machinery/field/containment/Move(atom/newloc, direct = NONE, glide_size_override = 0, update_dir = TRUE)
	qdel(src)
	return FALSE

/**
 * MARK: abstract field class
 * Used for overriding certain procs
 */
/obj/machinery/field
	abstract_type = /obj/machinery/field
	/// Used to add a delay between shocks. In some cases this used to crash servers by spawning hundreds of sparks every second.
	var/has_shocked = FALSE

/obj/machinery/field/Bumped(atom/movable/moving_atom)
	. = ..()
	if(has_shocked)
		return

	if(isliving(moving_atom))
		yeet_shock(moving_atom)
		return

	if(ismachinery(moving_atom) || isstructure(moving_atom) || ismecha(moving_atom))
		bump_field(moving_atom)
		return

/obj/machinery/field/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(checkpass(mover))
		return TRUE
	if(has_shocked || isliving(mover) || ismachinery(mover) || isstructure(mover) || ismecha(mover))
		return FALSE

/obj/machinery/field/proc/yeet_shock(mob/living/user)
	var/shock_damage = min(rand(30, 40), rand(30, 40))
	if(iscarbon(user))
		var/stun = (min(shock_damage, 15)) STATUS_EFFECT_CONSTANT
		user.Weaken(stun)
		user.electrocute_act(shock_damage, src)

	else if(issilicon(user))
		if(prob(20))
			user.Stun(4 SECONDS)
		user.take_overall_damage(burn = shock_damage)
		user.visible_message(
			span_danger("[user.name] was shocked by the [src]!"),
			span_userdanger("Energy pulse detected, system damaged!"),
			span_italics("You hear an electrical crack."),
		)

	user.updatehealth()
	bump_field(user)

/obj/machinery/field/proc/clear_shock()
	has_shocked = FALSE

/obj/machinery/field/proc/bump_field(atom/movable/considered_atom as mob|obj)
	if(has_shocked)
		return FALSE
	has_shocked = TRUE
	do_sparks(5, TRUE, considered_atom.loc)
	var/atom/target = get_edge_target_turf(considered_atom, get_dir(src, get_step_away(considered_atom, src)))
	if(isliving(considered_atom))
		to_chat(considered_atom, span_userdanger("The field repels you with tremendous force!"))
	playsound(src, 'sound/effects/gravhit.ogg', 50, TRUE)
	considered_atom.throw_at(target, 200, 4)
	addtimer(CALLBACK(src, PROC_REF(clear_shock)), 0.5 SECONDS)
