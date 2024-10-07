//WATER EFFECTS
/obj/effect/particle_effect/water
	name = "water"
	icon_state = "extinguish"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	pass_flags = PASSTABLE|PASSMACHINE|PASSSTRUCTURE|PASSGRILLE|PASSBLOB|PASSVEHICLE
	var/life = 15

/obj/effect/particle_effect/water/Initialize(mapload)
	. = ..()
	QDEL_IN(src, 7 SECONDS)


/obj/effect/particle_effect/water/Move(atom/newloc, direct = NONE, glide_size_override = 0, update_dir = TRUE)
	if(--life < 1)
		qdel(src)
		return FALSE
	. = ..()
	if(isturf(loc))
		reagents_effect(loc)


/obj/effect/particle_effect/water/Bump(atom/bumped_atom)
	. = ..()
	if(.)
		return .
	var/bumped_turf = isturf(bumped_atom)
	if(!bumped_turf && !isturf(bumped_atom.loc))
		return .
	reagents_effect(bumped_turf ? bumped_atom : bumped_atom.loc)


/obj/effect/particle_effect/water/proc/reagents_effect(turf/turf)
	for(var/atom/movable/thing as anything in turf)
		thing.water_act(life, COLD_WATER_TEMPERATURE, src)
	turf.water_act(life, COLD_WATER_TEMPERATURE, src)


///Extinguisher snowflake
/obj/effect/particle_effect/water/extinguisher


/obj/effect/particle_effect/water/extinguisher/reagents_effect(turf/turf)
	if(!reagents)
		return

	// should be full water to extinguish mobs
	var/should_extinguish = reagents.has_reagent("water", amount = 1)
	for(var/atom/movable/thing as anything in turf)
		reagents.reaction(thing)
		if(should_extinguish && isliving(thing))
			var/mob/living/mob = thing
			mob.ExtinguishMob()
	reagents.reaction(turf)


/// Starts the effect moving at a target with a delay in deciseconds, and a lifetime in moves
/// Returns the created loop
/obj/effect/particle_effect/water/extinguisher/proc/move_at(atom/target, delay, lifetime)
	var/datum/move_loop/loop = SSmove_manager.move_towards_legacy(src, target, delay, timeout = delay * lifetime, flags = MOVEMENT_LOOP_START_FAST, priority = MOVEMENT_ABOVE_SPACE_PRIORITY)
	RegisterSignal(loop, COMSIG_MOVELOOP_POSTPROCESS, PROC_REF(post_forcemove))
	RegisterSignal(loop, COMSIG_QDELETING, PROC_REF(movement_stopped))
	return loop


/obj/effect/particle_effect/water/extinguisher/proc/post_forcemove(datum/move_loop/source, success)
	SIGNAL_HANDLER
	if(!success)
		end_life(source)


/obj/effect/particle_effect/water/extinguisher/proc/movement_stopped(datum/move_loop/source)
	SIGNAL_HANDLER
	if(!QDELETED(src))
		end_life(source)


/obj/effect/particle_effect/water/extinguisher/proc/end_life(datum/move_loop/engine)
	QDEL_IN(src, engine.delay) //Gotta let it stop drifting
	animate(src, alpha = 0, time = engine.delay)


/////////////////////////////////////////////
// GENERIC STEAM SPREAD SYSTEM

//Usage: set_up(number of bits of steam, use North/South/East/West only, spawn location)
// The attach(atom/atom) proc is optional, and can be called to attach the effect
// to something, like a smoking beaker, so then you can just call start() and the steam
// will always spawn at the items location, even if it's moved.

/* Example:
	var/datum/effect_system/steam_spread/steam = new /datum/effect_system/steam_spread() -- creates new system
	steam.set_up(5, 0, mob.loc) -- sets up variables
	OPTIONAL: steam.attach(mob)
	steam.start() -- spawns the effect
*/
/////////////////////////////////////////////
/obj/effect/particle_effect/steam
	name = "steam"
	icon_state = "extinguish"
	density = FALSE

/obj/effect/particle_effect/steam/New()
	..()
	QDEL_IN(src, 20)

/datum/effect_system/steam_spread
	effect_type = /obj/effect/particle_effect/steam
