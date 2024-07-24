// Used by /turf/open/chasm and subtypes to implement the "dropping" mechanic
/datum/component/chasm
	var/turf/target_turf
	var/obj/effect/abstract/chasm_storage/storage
	var/fall_message = "GAH! Ah... where are you?"
	var/oblivion_message = "You stumble and stare into the abyss before you. It stares back, and you fall into the enveloping dark."

	/// List of refs to falling objects -> how many levels deep we've fallen
	var/static/list/falling_atoms = list()
	var/static/list/forbidden_types = typecacheof(list(
		/obj/machinery/bfl_receiver,
		/obj/singularity,
		/obj/docking_port,
		/obj/structure/lattice,
		/obj/structure/stone_tile,
		/obj/item/projectile,
		/obj/effect/portal,
		/obj/effect/hotspot,
		/obj/effect/landmark,
		/obj/effect/temp_visual,
		/obj/effect/light_emitter/tendril,
		/obj/effect/collapse,
		/obj/effect/abstract,
		/obj/effect/particle_effect/smoke,
		/obj/effect/particle_effect/ion_trails,
		/obj/effect/particle_effect/sparks,
		/obj/effect/particle_effect/expl_particles,
		/obj/effect/wisp,
		/obj/effect/ebeam,
		/obj/effect/spawner,
		/obj/structure/railing,
		/mob/living/simple_animal/hostile/megafauna, //failsafe
	))


/datum/component/chasm/Initialize(turf/target_turf, mapload)
	if(!isturf(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, SIGNAL_ADDTRAIT(TRAIT_CHASM_STOPPED), PROC_REF(on_chasm_stopped))
	RegisterSignal(parent, SIGNAL_REMOVETRAIT(TRAIT_CHASM_STOPPED), PROC_REF(on_chasm_no_longer_stopped))
	src.target_turf = target_turf
	RegisterSignal(parent, COMSIG_ATOM_ABSTRACT_ENTERED, PROC_REF(entered))
	RegisterSignal(parent, COMSIG_ATOM_ABSTRACT_EXITED, PROC_REF(exited))
	RegisterSignal(parent, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON, PROC_REF(initialized_on))
	RegisterSignal(parent, COMSIG_ATOM_INTERCEPT_TELEPORTING, PROC_REF(block_teleport))
	//allow catwalks to give the turf the CHASM_STOPPED trait before dropping stuff when the turf is changed.
	//otherwise don't do anything because turfs and areas are initialized before movables.
	if(!mapload)
		addtimer(CALLBACK(src, PROC_REF(drop_stuff)), 0)


/datum/component/chasm/UnregisterFromParent()
	storage = null


/datum/component/chasm/proc/entered(datum/source, atom/movable/arrived)
	SIGNAL_HANDLER

	drop_stuff(arrived)


/datum/component/chasm/proc/exited(datum/source, atom/movable/exited)
	SIGNAL_HANDLER

	UnregisterSignal(exited, list(COMSIG_MOVETYPE_FLAG_DISABLED, COMSIG_LIVING_SET_BUCKLED, COMSIG_MOVABLE_THROW_LANDED))


/datum/component/chasm/proc/initialized_on(datum/source, atom/movable/movable, mapload)
	SIGNAL_HANDLER

	drop_stuff(movable)


/datum/component/chasm/proc/block_teleport()
	SIGNAL_HANDLER

	return COMPONENT_BLOCK_TELEPORT


/datum/component/chasm/proc/on_chasm_stopped(datum/source)
	SIGNAL_HANDLER

	var/atom/atom_parent = parent
	UnregisterSignal(atom_parent, list(COMSIG_ATOM_ABSTRACT_ENTERED, COMSIG_ATOM_ABSTRACT_EXITED, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON))
	for(var/atom/movable/movable as anything in atom_parent)
		UnregisterSignal(movable, list(COMSIG_MOVETYPE_FLAG_DISABLED, COMSIG_LIVING_SET_BUCKLED, COMSIG_MOVABLE_THROW_LANDED))


/datum/component/chasm/proc/on_chasm_no_longer_stopped(datum/source)
	SIGNAL_HANDLER

	RegisterSignal(parent, COMSIG_ATOM_ABSTRACT_ENTERED, PROC_REF(entered))
	RegisterSignal(parent, COMSIG_ATOM_ABSTRACT_EXITED, PROC_REF(exited))
	RegisterSignal(parent, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON, PROC_REF(initialized_on))
	drop_stuff()


#define CHASM_NOT_DROPPING 0
#define CHASM_DROPPING 1
///Doesn't drop the movable, but registers a few signals to try again if the conditions change.
#define CHASM_REGISTER_SIGNALS 2


/datum/component/chasm/proc/drop_stuff(atom/movable/dropped_thing)
	if(HAS_TRAIT(parent, TRAIT_CHASM_STOPPED))
		return
	var/atom/atom_parent = parent
	var/list/to_check = dropped_thing ? list(dropped_thing) : atom_parent.contents
	for(var/atom/movable/thing in to_check)
		var/dropping = droppable(thing)
		switch(dropping)
			if(CHASM_DROPPING)
				INVOKE_ASYNC(src, PROC_REF(drop), thing)
			if(CHASM_REGISTER_SIGNALS)
				RegisterSignal(thing, list(COMSIG_MOVETYPE_FLAG_DISABLED, COMSIG_LIVING_SET_BUCKLED, COMSIG_MOVABLE_THROW_LANDED), PROC_REF(drop_stuff), override = TRUE)


/datum/component/chasm/proc/droppable(atom/movable/dropped_thing)
	var/atom/atom_parent = parent
	if(!dropped_thing.simulated)
		return CHASM_NOT_DROPPING
	var/datum/weakref/falling_ref = WEAKREF(dropped_thing)
	// avoid an infinite loop, but allow falling a large distance
	if(falling_atoms[falling_ref] && falling_atoms[falling_ref] > 30)
		return CHASM_NOT_DROPPING
	if(is_type_in_typecache(dropped_thing, forbidden_types) || (!isliving(dropped_thing) && !isobj(dropped_thing)))
		return CHASM_NOT_DROPPING
	if(dropped_thing.throwing || (dropped_thing.movement_type & MOVETYPES_NOT_TOUCHING_GROUND))
		return CHASM_REGISTER_SIGNALS
	for(var/atom/thing_to_check as anything in atom_parent)
		if(HAS_TRAIT(thing_to_check, TRAIT_CHASM_STOPPER))
			return CHASM_NOT_DROPPING

	//Flies right over the chasm
	if(ismob(dropped_thing))
		var/mob/dropped_mob = dropped_thing
		if(dropped_mob.buckled) //middle statement to prevent infinite loops just in case!
			var/mob/buckled_to = dropped_mob.buckled
			if((!ismob(buckled_to) || (buckled_to.buckled != dropped_mob)) && !droppable(buckled_to))
				return CHASM_REGISTER_SIGNALS
		if(isliving(dropped_mob))
			var/mob/living/dropped_living = dropped_mob
			if(dropped_living.incorporeal_move)
				return CHASM_NOT_DROPPING
			if(ishuman(dropped_mob))
				var/obj/item/wormhole_jaunter/jaunter = locate() in dropped_mob.GetAllContents()
				if(jaunter)
					var/turf/chasm = get_turf(dropped_mob)
					var/fall_into_chasm = jaunter.chasm_react(dropped_mob)
					if(!fall_into_chasm)
						chasm.visible_message(span_boldwarning("[dropped_mob] falls into the [chasm]!")) //To freak out any bystanders
					return fall_into_chasm ? CHASM_DROPPING : CHASM_NOT_DROPPING

	return CHASM_DROPPING


#undef CHASM_NOT_DROPPING
#undef CHASM_DROPPING
#undef CHASM_REGISTER_SIGNALS


/datum/component/chasm/proc/drop(atom/movable/dropped_thing)
	var/atom/atom_parent = parent
	var/datum/weakref/falling_ref = WEAKREF(dropped_thing)
	//Make sure the item is still there after our sleep
	if(!dropped_thing || !falling_ref?.resolve())
		falling_atoms -= falling_ref
		return
	falling_atoms[falling_ref] = (falling_atoms[falling_ref] || 0) + 1
	var/turf/below_turf = target_turf

	if(falling_atoms[falling_ref] > 1)
		return // We're already handling this

	if(below_turf)
		// send to the turf below
		dropped_thing.visible_message(span_boldwarning("[dropped_thing] falls into [atom_parent]!"), span_userdanger("[fall_message]"))
		below_turf.visible_message(span_boldwarning("[dropped_thing] falls from above!"))
		playsound(below_turf, 'sound/effects/break_stone.ogg', 50, TRUE)
		dropped_thing.forceMove(below_turf)
		if(isliving(dropped_thing))
			var/mob/living/fallen = dropped_thing
			fallen.Weaken(10 SECONDS)
			fallen.adjustBruteLoss(30)
		falling_atoms -= falling_ref
		return

	// send to oblivion
	dropped_thing.visible_message(span_boldwarning("[dropped_thing] falls into [atom_parent]!"), span_userdanger("[oblivion_message]"))
	if(isliving(dropped_thing))
		var/mob/living/falling_mob = dropped_thing
		ADD_TRAIT(falling_mob, TRAIT_NO_TRANSFORM, UNIQUE_TRAIT_SOURCE(src))
		falling_mob.Stun(20 SECONDS)

	var/oldtransform = dropped_thing.transform
	var/oldcolor = dropped_thing.color
	var/oldalpha = dropped_thing.alpha
	var/oldoffset = dropped_thing.pixel_y

	if(ishuman(dropped_thing))
		var/mob/living/carbon/human/dropped_human = dropped_thing
		if(dropped_human.stat != DEAD && prob(25))
			playsound(atom_parent, 'sound/effects/wilhelm_scream.ogg', 150)

	animate(dropped_thing, transform = matrix() - matrix(), alpha = 0, color = rgb(0, 0, 0), time = 10)
	for(var/i in 1 to 5)
		//Make sure the item is still there after our sleep
		if(QDELETED(dropped_thing))
			return
		dropped_thing.pixel_y--
		sleep(0.2 SECONDS)

	//Make sure the item is still there after our sleep
	if(QDELETED(dropped_thing))
		return

	if(isrobot(dropped_thing))
		var/mob/living/silicon/robot/robot = dropped_thing
		qdel(robot.mmi)
		qdel(dropped_thing)
		falling_atoms -= falling_ref
		return

	if(!storage)
		storage = (locate() in atom_parent) || new(atom_parent)

	if(storage.contains(dropped_thing))
		return

	dropped_thing.alpha = oldalpha
	dropped_thing.color = oldcolor
	dropped_thing.transform = oldtransform
	dropped_thing.pixel_y = oldoffset

	if(!dropped_thing.forceMove(storage))
		atom_parent.visible_message(span_boldwarning("[atom_parent] spits out [dropped_thing]!"))
		dropped_thing.throw_at(get_edge_target_turf(atom_parent, pick(GLOB.alldirs)), rand(1, 10), rand(1, 10))

	else if(isliving(dropped_thing))
		var/mob/living/fallen_mob = dropped_thing
		REMOVE_TRAIT(fallen_mob, TRAIT_NO_TRANSFORM, UNIQUE_TRAIT_SOURCE(src))
		if(fallen_mob.stat != DEAD)
			fallen_mob.investigate_log("has died from falling into a chasm.", INVESTIGATE_DEATHS)
			fallen_mob.death(TRUE)
			fallen_mob.apply_damage(1000)

	falling_atoms -= falling_ref



/**
 * An abstract object which is basically just a bag that the chasm puts people inside
 */
/obj/effect/abstract/chasm_storage
	name = "chasm depths"
	desc = "The bottom of a hole. You shouldn't be able to interact with this."
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT


/obj/effect/abstract/chasm_storage/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(isliving(arrived))
		RegisterSignal(arrived, COMSIG_LIVING_REVIVE, PROC_REF(on_revive))


/obj/effect/abstract/chasm_storage/Exited(atom/movable/departed, atom/newLoc)
	. = ..()
	if(isliving(departed))
		UnregisterSignal(departed, COMSIG_LIVING_REVIVE)


/obj/effect/abstract/chasm_storage/proc/get_fish(mob/fish, atom/new_loc)
	if(!(fish in src))
		stack_trace("Attempting to remove [fish] which is not in [src] contents")
		return
	UnregisterSignal(fish, COMSIG_LIVING_REVIVE)
	if(new_loc)
		fish.forceMove(new_loc)


/**
 * Called if something comes back to life inside the pit. Expected sources are badmins and changelings.
 * Ethereals should take enough damage to be smashed and not revive.
 * Arguments
 * escapee - Lucky guy who just came back to life at the bottom of a hole.
 */
/obj/effect/abstract/chasm_storage/proc/on_revive(mob/living/escapee)
	SIGNAL_HANDLER

	var/turf/ourturf = get_turf(src)
	if(ourturf.GetComponent(/datum/component/chasm))
		ourturf.visible_message(span_boldwarning("After a long climb, [escapee] leaps out of [ourturf]!"))
	else
		playsound(ourturf, 'sound/effects/bang.ogg', 50, TRUE)
		ourturf.visible_message(span_boldwarning("[escapee] busts through [ourturf], leaping out of the chasm below!"))
		ourturf.ChangeTurf(ourturf.baseturf)
	ADD_TRAIT(escapee, TRAIT_MOVE_FLYING, CHASM_TRAIT) //Otherwise they instantly fall back in
	escapee.forceMove(ourturf)
	escapee.throw_at(get_edge_target_turf(ourturf, pick(GLOB.alldirs)), rand(1, 10), rand(1, 10))
	REMOVE_TRAIT(escapee, TRAIT_MOVE_FLYING, CHASM_TRAIT)
	escapee.Sleeping(20 SECONDS)
	UnregisterSignal(escapee, COMSIG_LIVING_REVIVE)

