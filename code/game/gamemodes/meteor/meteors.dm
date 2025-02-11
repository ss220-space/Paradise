//Meteors probability of spawning during a given wave
GLOBAL_LIST_INIT(meteors_normal, list(	//for normal meteor event
	/obj/effect/meteor/dust = 3,
	/obj/effect/meteor/medium = 8,
	/obj/effect/meteor/big = 3,
	/obj/effect/meteor/flaming = 1,
	/obj/effect/meteor/irradiated = 3,
))

GLOBAL_LIST_INIT(meteors_threatening, list(	//for threatening meteor event
	/obj/effect/meteor/medium = 4,
	/obj/effect/meteor/big = 8,
	/obj/effect/meteor/flaming = 3,
	/obj/effect/meteor/irradiated = 3,
))

GLOBAL_LIST_INIT(meteors_catastrophic, list(	//for catastrophic meteor event
	/obj/effect/meteor/medium = 5,
	/obj/effect/meteor/big = 75,
	/obj/effect/meteor/flaming = 10,
	/obj/effect/meteor/irradiated = 10,
	/obj/effect/meteor/tunguska = 1,
))

GLOBAL_LIST_INIT(meteors_dust, list(/obj/effect/meteor/dust)) //for space dust event

GLOBAL_LIST_INIT(meteors_gore, list(/obj/effect/meteor/gore)) //Meaty Gore

GLOBAL_LIST_INIT(meteors_ops, list(/obj/effect/meteor/gore/ops)) //Meaty Ops

GLOBAL_LIST_INIT(meteors_pigs, list(/obj/effect/meteor/gore/pigops)) // pigOps

GLOBAL_LIST_INIT(meteors_space_dust, list(/obj/effect/meteor/space_dust/weak)) //for another space dust event


///////////////////////////////
//Meteor spawning global procs
///////////////////////////////
/proc/spawn_meteors(number = 10, list/meteor_types, direction)
	for(var/i in 1 to number)
		spawn_meteor(meteor_types, direction)


/proc/spawn_meteor(list/meteor_types, direction, atom/target)
	var/turf/picked_start
	var/turf/picked_goal
	var/max_i = 10//number of tries to spawn meteor.
	while(!isspaceturf(picked_start))
		var/start_side
		if(direction) //If a direction has been specified, we set start_side to it. Otherwise, pick randomly
			start_side = direction
		else
			start_side = pick(GLOB.cardinal)
		var/start_Z = pick(levels_by_trait(STATION_LEVEL))
		picked_start = spaceDebrisStartLoc(start_side, start_Z)
		if(target)
			if(!isturf(target))
				target = get_turf(target)
			picked_goal = target
		else
			picked_goal = spaceDebrisFinishLoc(start_side, start_Z)
		max_i--
		if(max_i <= 0)
			return
	var/new_meteor = pickweight(meteor_types)
	new new_meteor(picked_start, picked_goal)


#define MAP_EDGE_PAD 1

/proc/spaceDebrisStartLoc(start_side, Z)
	var/starty
	var/startx
	switch(start_side)
		if(NORTH)
			starty = world.maxy-(TRANSITIONEDGE + MAP_EDGE_PAD)
			startx = rand((TRANSITIONEDGE + MAP_EDGE_PAD), world.maxx-(TRANSITIONEDGE + MAP_EDGE_PAD))
		if(EAST)
			starty = rand((TRANSITIONEDGE + MAP_EDGE_PAD),world.maxy-(TRANSITIONEDGE + MAP_EDGE_PAD))
			startx = world.maxx-(TRANSITIONEDGE + MAP_EDGE_PAD)
		if(SOUTH)
			starty = (TRANSITIONEDGE + MAP_EDGE_PAD)
			startx = rand((TRANSITIONEDGE + MAP_EDGE_PAD), world.maxx-(TRANSITIONEDGE + MAP_EDGE_PAD))
		if(WEST)
			starty = rand((TRANSITIONEDGE + MAP_EDGE_PAD), world.maxy-(TRANSITIONEDGE + MAP_EDGE_PAD))
			startx = (TRANSITIONEDGE + MAP_EDGE_PAD)
	. = locate(startx, starty, Z)


/proc/spaceDebrisFinishLoc(start_side, Z)
	var/endy
	var/endx
	switch(start_side)
		if(NORTH)
			endy = (TRANSITIONEDGE + MAP_EDGE_PAD)
			endx = rand((TRANSITIONEDGE + MAP_EDGE_PAD), world.maxx-(TRANSITIONEDGE + MAP_EDGE_PAD))
		if(EAST)
			endy = rand((TRANSITIONEDGE + MAP_EDGE_PAD), world.maxy-(TRANSITIONEDGE + MAP_EDGE_PAD))
			endx = (TRANSITIONEDGE + MAP_EDGE_PAD)
		if(SOUTH)
			endy = world.maxy-(TRANSITIONEDGE + MAP_EDGE_PAD)
			endx = rand((TRANSITIONEDGE + MAP_EDGE_PAD), world.maxx-(TRANSITIONEDGE + MAP_EDGE_PAD))
		if(WEST)
			endy = rand((TRANSITIONEDGE + MAP_EDGE_PAD),world.maxy-(TRANSITIONEDGE + MAP_EDGE_PAD))
			endx = world.maxx-(TRANSITIONEDGE + MAP_EDGE_PAD)
	. = locate(endx, endy, Z)

#undef MAP_EDGE_PAD


///////////////////////
//The meteor effect
//////////////////////

/obj/effect/meteor
	name = "the concept of meteor"
	desc = "You should probably run instead of gawking at this."
	icon = 'icons/obj/meteor.dmi'
	icon_state = "small"
	density = TRUE
	anchored = TRUE
	pass_flags = PASSTABLE

	///The resilience of our meteor
	var/hits = 4
	///Level of ex_act to be called on hit.
	var/hitpwr = EXPLODE_HEAVY
	//Should we shake people's screens on impact
	var/heavy = FALSE
	///Sound to play when we hit something
	var/meteorsound = 'sound/effects/meteorimpact.ogg'
	///Our starting z level, prevents infinite meteors
	var/z_original

	//Potential items to spawn when we die. Can be list.
	var/list/meteordrop = /obj/item/stack/ore/iron
	///How much stuff to spawn when we die
	var/dropamt = 2

	///The thing we're moving towards, usually a turf
	var/atom/dest
	///Lifetime in seconds
	var/lifetime = 180 SECONDS
	/// Chance to shake everyone screen on impact.
	var/shake_chance = 50


/obj/effect/meteor/Initialize(mapload, turf/target)
	. = ..()
	z_original = z
	GLOB.meteor_list += src
	SpinAnimation()
	chase_target(target)


/obj/effect/meteor/Destroy()
	GLOB.meteor_list -= src
	return ..()


/obj/effect/meteor/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	if(QDELETED(src))
		return

	if(old_loc != loc)//If did move, ram the turf we get in
		var/turf/ram_turf = get_turf(loc)
		ram_turf(ram_turf)

		if(prob(10) && !isspaceturf(ram_turf))//randomly takes a 'hit' from ramming
			get_hit()

	if(z != z_original || loc == get_turf(dest))
		qdel(src)


/obj/effect/meteor/Process_Spacemove(movement_dir = NONE, continuous_move = FALSE)
	return TRUE //Keeps us from drifting for no reason


/obj/effect/meteor/Bump(atom/bumped_atom)
	. = ..()	// What could go wrong
	if(. || !bumped_atom)
		return .
	ram_turf(get_turf(bumped_atom))
	playsound(loc, meteorsound, 40, TRUE)
	get_hit()


/obj/effect/meteor/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(istype(mover, /obj/effect/meteor))
		return TRUE


/obj/effect/meteor/proc/chase_target(atom/chasing, delay, home)
	if(!isatom(chasing))
		return
	var/datum/move_loop/new_loop = SSmove_manager.move_towards(src, chasing, delay, home, lifetime)
	if(!new_loop)
		return

	RegisterSignal(new_loop, COMSIG_QDELETING, PROC_REF(handle_stopping))


///Deals with what happens when we stop moving, IE we die
/obj/effect/meteor/proc/handle_stopping()
	SIGNAL_HANDLER
	if(!QDELETED(src))
		qdel(src)


/obj/effect/meteor/proc/ram_turf(turf/target_turf)
	//first bust whatever is in the turf
	for(var/atom/thing as anything in (target_turf.contents - src))
		thing.ex_act(hitpwr)

	//then, ram the turf if it still exists
	if(!QDELETED(target_turf))
		target_turf.ex_act(hitpwr)


//process getting 'hit' by colliding with a dense object
//or randomly when ramming turfs
/obj/effect/meteor/proc/get_hit()
	hits--
	if(hits <= 0)
		make_debris()
		meteor_effect()
		qdel(src)


/obj/effect/meteor/ex_act()
	return


/obj/effect/meteor/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/pickaxe))
		make_debris()
		qdel(src)
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()


/obj/effect/meteor/proc/make_debris()
	if(!meteordrop)
		return
	var/turf/spawn_turf = get_turf(src)
	if(!spawn_turf)
		return
	for(var/throws = dropamt, throws > 0, throws--)
		var/spawn_type = meteordrop
		if(islist(meteordrop))
			spawn_type = pick(meteordrop)
		var/obj/item/thing_to_spawn = new spawn_type(spawn_turf)
		if(dest)
			INVOKE_ASYNC(thing_to_spawn, TYPE_PROC_REF(/atom/movable, throw_at), dest, 5, 10)
	return spawn_turf


/obj/effect/meteor/proc/meteor_effect()
	if(!heavy)
		return

	var/sound/meteor_sound = sound(meteorsound)
	var/random_frequency = get_rand_frequency()

	for(var/mob/mob as anything in GLOB.player_list)
		var/turf/mob_turf = get_turf(mob)
		if(!mob_turf || mob_turf.z != z)
			continue
		var/dist = get_dist(mob.loc, loc)
		if(prob(shake_chance))
			shake_camera(mob, dist > 20 ? 3 : 5, dist > 20 ? 1 : 3)
		mob.playsound_local(loc, null, 50, TRUE, random_frequency, 10, S = meteor_sound)


/**
 * Handles the meteor's interaction with meteor shields.
 *
 * Returns TRUE if the meteor should be destroyed. Overridable for custom shield interaction.
 * Return FALSE if a meteor's interaction with meteor shields should NOT destroy it.
 *
 * Arguments:
 * * defender - The meteor shield that is vaporizing us.
 */
/obj/effect/meteor/proc/shield_defense(obj/machinery/satellite/meteor_shield/defender)
	return TRUE


///////////////////////
//Meteor types
///////////////////////

//Medium-sized
/obj/effect/meteor/medium
	name = "meteor"
	dropamt = 3


/obj/effect/meteor/medium/meteor_effect()
	. = ..()
	explosion(loc, 0, 1, 2, 3, adminlog = FALSE, cause = src)


//Large-sized
/obj/effect/meteor/big
	name = "large meteor"
	icon_state = "large"
	heavy = TRUE
	hits = 6
	dropamt = 4


/obj/effect/meteor/big/meteor_effect()
	. = ..()
	explosion(loc, 1, 2, 3, 4, adminlog = FALSE, cause = src)


//Flaming meteor
/obj/effect/meteor/flaming
	name = "flaming meteor"
	icon_state = "flaming"
	hits = 5
	heavy = TRUE
	meteorsound = 'sound/effects/bamf.ogg'
	meteordrop = /obj/item/stack/ore/plasma


/obj/effect/meteor/flaming/meteor_effect()
	. = ..()
	explosion(loc, 1, 2, 3, 4, adminlog = FALSE, flame_range = 5, cause = src)


//Radiation meteor
/obj/effect/meteor/irradiated
	name = "glowing meteor"
	icon_state = "glowing"
	heavy = TRUE
	meteordrop = /obj/item/stack/ore/uranium


/obj/effect/meteor/irradiated/meteor_effect()
	. = ..()
	explosion(loc, 0, 0, 4, 3, adminlog = FALSE, cause = src)
	new /obj/effect/decal/cleanable/greenglow(get_turf(src))
	for(var/mob/living/L in view(5, src))
		L.apply_effect(40, IRRADIATE)


//Station buster Tunguska
/obj/effect/meteor/tunguska
	name = "tunguska meteor"
	icon_state = "flaming"
	desc = "Your life briefly passes before your eyes the moment you lay them on this monstruosity."
	hits = 30
	hitpwr = EXPLODE_DEVASTATE
	heavy = TRUE
	meteorsound = 'sound/effects/bamf.ogg'
	meteordrop = /obj/item/stack/ore/plasma


/obj/effect/meteor/tunguska/meteor_effect()
	. = ..()
	explosion(loc, 5, 10, 15, 20, adminlog = FALSE, cause = src)


/obj/effect/meteor/tunguska/Bump(atom/bumped_atom)
	. = ..()
	if(. || !prob(20))
		return .
	explosion(loc, 2, 4, 6, 8, cause = src)


//Gore
/obj/effect/meteor/gore
	name = "organic debris"
	icon = 'icons/mob/human.dmi'
	icon_state = "fatbody_s"
	hits = 1
	hitpwr = EXPLODE_NONE
	meteorsound = 'sound/effects/blobattack.ogg'
	meteordrop = /obj/item/reagent_containers/food/snacks/meat
	var/meteorgibs = /obj/effect/gibspawner/generic


/obj/effect/meteor/gore/make_debris()
	. = ..()
	if(.)
		new meteorgibs(.)


/obj/effect/meteor/gore/ram_turf(turf/target_turf)
	if(!isspaceturf(target_turf))
		new /obj/effect/decal/cleanable/blood(target_turf)


/obj/effect/meteor/gore/Bump(atom/bumped_atom)
	. = ..()
	if(. || QDELETED(bumped_atom))
		return .
	bumped_atom.ex_act(hitpwr)
	get_hit()


//Meteor Ops
/obj/effect/meteor/gore/ops
	name = "meteorOps"
	icon = 'icons/mob/animal.dmi'
	icon_state = "syndicaterangedpsace"
	hits = 10
	hitpwr = EXPLODE_DEVASTATE


/obj/effect/meteor/gore/pigops
	name = "pigOps"
	icon = 'icons/mob/animal.dmi'
	icon_state = "pig"
	hitpwr = EXPLODE_DEVASTATE
	hits = 3
	shake_chance = 20


//Dust
/obj/effect/meteor/dust
	name = "dust"
	desc = "Dust in space."
	icon_state = "dust"
	pass_flags = PASSTABLE|PASSGRILLE
	hits = 1
	hitpwr = EXPLODE_LIGHT
	meteorsound = 'sound/weapons/tap.ogg'
	meteordrop = /obj/item/stack/ore/glass


// Space Dust
/obj/effect/meteor/space_dust
	name = "space dust"
	desc = "Dust in space."
	icon_state = "space_dust"
	heavy = TRUE
	hitpwr = EXPLODE_HEAVY
	hits = 2
	meteordrop = null


/obj/effect/meteor/space_dust/ex_act(severity)
	qdel(src)


/obj/effect/meteor/space_dust/weak
	hitpwr = EXPLODE_LIGHT
	hits = 1


/obj/effect/meteor/space_dust/strong
	hitpwr = EXPLODE_DEVASTATE
	hits = 6


/obj/effect/meteor/space_dust/super
	hitpwr = EXPLODE_DEVASTATE
	hits = 40

