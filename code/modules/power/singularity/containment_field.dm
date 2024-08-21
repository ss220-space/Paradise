/obj/machinery/field/containment
	name = "Containment Field"
	desc = "An energy field."
	icon = 'icons/obj/engines_and_power/singularity.dmi'
	icon_state = "Contain_F"
	anchored = TRUE
	density = FALSE
	move_resist = INFINITY
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	use_power = NO_POWER_USE
	light_range = 4
	layer = OBJ_LAYER + 0.1
	var/obj/machinery/field/generator/FG1 = null
	var/obj/machinery/field/generator/FG2 = null


/obj/machinery/field/containment/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)


/obj/machinery/field/containment/Destroy()
	FG1.fields -= src
	FG2.fields -= src
	return ..()

/obj/machinery/field/containment/attack_hand(mob/user)
	if(get_dist(src, user) > 1)
		return 0
	else
		shock_field(user)
		return 1


/obj/machinery/field/containment/attackby(obj/item/I, mob/user, params)
	shock(user)
	return ATTACK_CHAIN_BLOCKED_ALL


/obj/machinery/field/containment/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BURN)
			playsound(loc, 'sound/effects/empulse.ogg', 75, TRUE)
		if(BRUTE)
			playsound(loc, 'sound/effects/empulse.ogg', 75, TRUE)

/obj/machinery/field/containment/blob_act(obj/structure/blob/B)
	return FALSE


/obj/machinery/field/containment/ex_act(severity)
	return 0

/obj/machinery/field/containment/attack_animal(mob/living/simple_animal/M)
	if(!FG1 || !FG2)
		qdel(src)
		return
	if(ismegafauna(M))
		M.visible_message("<span class='warning'>[M] glows fiercely as the containment field flickers out!</span>")
		FG1.calc_power(INFINITY) //rip that 'containment' field
		M.adjustHealth(-M.obj_damage)
	else
		..()


/obj/machinery/field/containment/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	if(isliving(arrived))
		var/mob/living/victim = arrived
		if(victim.incorporeal_move)
			return
		shock_field(victim)

	else if(ismachinery(arrived) || isstructure(arrived) || ismecha(arrived))
		bump_field(arrived)


/obj/machinery/field/containment/proc/set_master(master1,master2)
	if(!master1 || !master2)
		return 0
	FG1 = master1
	FG2 = master2
	return 1

/obj/machinery/field/containment/shock_field(mob/living/user)
	if(!FG1 || !FG2)
		qdel(src)
		return 0
	..()

/obj/machinery/field/containment/Move(atom/newloc, direct = NONE, glide_size_override = 0, update_dir = TRUE)
	qdel(src)

// Abstract Field Class
// Used for overriding certain procs

/obj/machinery/field
	var/hasShocked = 0 //Used to add a delay between shocks. In some cases this used to crash servers by spawning hundreds of sparks every second.


/obj/machinery/field/Bumped(atom/movable/moving_atom)
	. = ..()
	if(hasShocked)
		return .
	if(isliving(moving_atom))
		shock_field(moving_atom)
		return .
	if(ismachinery(moving_atom) || isstructure(moving_atom) || ismecha(moving_atom))
		bump_field(moving_atom)


/obj/machinery/field/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(checkpass(mover))
		return TRUE
	if(hasShocked || isliving(mover) || ismachinery(mover) || isstructure(mover) || ismecha(mover))
		return FALSE


/obj/machinery/field/proc/shock_field(mob/living/user)
	if(isliving(user))
		var/shock_damage = min(rand(30,40),rand(30,40))
		var/is_silicon = issilicon(user)
		if(isliving(user) && !is_silicon)
			var/stun = (min(shock_damage, 15)) STATUS_EFFECT_CONSTANT
			user.Weaken(stun)
			user.electrocute_act(shock_damage, "сдерживающего барьера")

		else if(is_silicon)
			if(prob(20))
				user.Stun(4 SECONDS)
			user.take_overall_damage(0, shock_damage)
			user.visible_message("<span class='danger'>[user.name] was shocked by the [src.name]!</span>", \
			"<span class='userdanger'>Energy pulse detected, system damaged!</span>", \
			"<span class='italics'>You hear an electrical crack.</span>")

		bump_field(user)

/obj/machinery/field/proc/bump_field(atom/movable/AM)
	if(hasShocked)
		return 0
	hasShocked = 1
	do_sparks(5, 1, AM.loc)
	var/atom/target = get_edge_target_turf(AM, get_dir(src, get_step_away(AM, src)))
	AM.throw_at(target, 200, 4)
	spawn(5)
		hasShocked = 0
