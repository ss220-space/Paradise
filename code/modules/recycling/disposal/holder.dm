// virtual disposal object
// travels through pipes in lieu of actual items
// contents will be items flushed by the disposal
// this allows the gas flushed to be tracked

/obj/structure/disposalholder
	invisibility = INVISIBILITY_ABSTRACT
	resistance_flags = INDESTRUCTIBLE|LAVA_PROOF|FIRE_PROOF|UNACIDABLE|ACID_PROOF
	dir = NONE
	/// Last pipe location, used in holder movement
	var/obj/structure/disposalpipe/last_pipe
	/// Current pipe location, used in holder movement
	var/obj/structure/disposalpipe/current_pipe
	/// Gas used to flush, will appear at exit point
	var/datum/gas_mixture/gas
	/// True if the holder is moving, otherwise inactive
	var/active = FALSE
	/// Can travel 1000 steps before going inactive (in case of loops)
	var/count = 1000
	/// Changes if contains a delivery container
	var/destinationTag = NONE
	/// Contains wrapped package?
	var/tomail = FALSE
	/// Contains a mob?
	var/hasmob = FALSE
	/// Contains a fat person?
	var/has_fat_guy = FALSE


/obj/structure/disposalholder/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_WEATHER_IMMUNE, INNATE_TRAIT)


/obj/structure/disposalholder/Destroy()
	QDEL_NULL(gas)
	active = FALSE
	last_pipe = null
	current_pipe = null
	return ..()


/// Initializes a holder from the contents of a disposal unit
/obj/structure/disposalholder/proc/init(obj/machinery/disposal/disposal)
	gas = disposal.air_contents// transfer gas resv. into holder object
	var/list/disposal_contents = disposal.contents

	//Check for any living mobs trigger hasmob.
	//hasmob effects whether the package goes to cargo or its tagged destination.
	//Checks 1 contents level deep. This means that players can be sent through disposals mail...
	//...but it should require a second person to open the package. (i.e. person inside a wrapped locker)
	for(var/atom/movable/thing as anything in disposal_contents)
		if(thing == src)
			continue
		if(isobj(thing) && (locate(/mob/living) in thing.contents))
			hasmob = TRUE
		else if(isliving(thing))
			var/mob/living/mob = thing
			if(mob.client)
				mob.reset_perspective(src)
			hasmob = TRUE
			RegisterSignal(mob, COMSIG_LIVING_RESIST, PROC_REF(struggle_prep))
			if(HAS_TRAIT(mob, TRAIT_FAT))
				has_fat_guy = TRUE

	// now everything inside the disposal gets put into the holder
	// note atom_in_transit, since can contain mobs or objs
	for(var/atom/movable/atom_in_transit as anything in disposal_contents)
		if(atom_in_transit == src)
			continue
		SEND_SIGNAL(atom_in_transit, COMSIG_MOVABLE_DISPOSING, src, disposal, hasmob)
		atom_in_transit.forceMove(src)


/// Starts the movement process, argument is the disposal unit the holder started in
/obj/structure/disposalholder/proc/start(obj/machinery/disposal/disposal)
	if(QDELETED(disposal.trunk))
		disposal.expel(src) // no trunk connected, so expel immediately
		return
	forceMove(disposal.trunk)
	active = TRUE
	setDir(DOWN)
	start_moving()


/// Starts the movement process, persists while the holder is moving through pipes
/obj/structure/disposalholder/proc/start_moving()
	var/delay = world.tick_lag
	var/datum/move_loop/our_loop = SSmove_manager.move_disposals(src, delay = delay, timeout = delay * count)
	if(our_loop)
		RegisterSignal(our_loop, COMSIG_MOVELOOP_PREPROCESS_CHECK, PROC_REF(pre_move))
		RegisterSignal(our_loop, COMSIG_MOVELOOP_POSTPROCESS, PROC_REF(try_expel))
		RegisterSignal(our_loop, COMSIG_QDELETING, PROC_REF(movement_stop))
		current_pipe = loc


/// Handles the preprocess check signal, sets the current pipe as the last pipe
/obj/structure/disposalholder/proc/pre_move(datum/move_loop/source)
	SIGNAL_HANDLER

	last_pipe = loc


/// Handles the postprocess check signal, tries to leave the pipe
/obj/structure/disposalholder/proc/try_expel(datum/move_loop/source, result, visual_delay)
	SIGNAL_HANDLER

	if(current_pipe || !active)
		if(active && has_fat_guy && prob(2))
			movement_stop()
		return
	last_pipe.expel(src, get_turf(src), dir)


/// Handles what happens to the contents when the qdel signal triggers
/obj/structure/disposalholder/proc/movement_stop(datum/source)
	SIGNAL_HANDLER

	current_pipe = null
	last_pipe = null
	active = FALSE
	for(var/mob/living/piperider in contents)
		to_chat(piperider, span_notice("Your movement has slowed to a stop. If you tried, you could probably <b>struggle</b> free."))


/**
 * Starts the struggle code
 *
 * Called by resist verb (or hotkey) via signal. Makes a sanity
 * check and then calls part 2.
 */
/obj/structure/disposalholder/proc/struggle_prep(mob/living/escapee)
	SIGNAL_HANDLER

	if(escapee.loc != src)
		UnregisterSignal(escapee, COMSIG_LIVING_RESIST)
		return //Somehow they got out without telling us
	INVOKE_ASYNC(src, PROC_REF(struggle_free), escapee)


/**
 * Completes the struggle code
 *
 * The linter gets upsetti spaghetti if this is part of the above proc
 * because the do_after is a sleep.
 */
/obj/structure/disposalholder/proc/struggle_free(mob/living/escapee)
	if(!istype(loc, /obj/structure/disposalpipe))
		return //Somehow we're not in a pipe, shits probably fucked
	var/obj/structure/disposalpipe/transport_cylinder = loc
	if(active)
		to_chat(escapee, span_danger("You slide past [loc] and are unable to keep your grip!"))
		return
	var/turf/our_turf = get_turf(src)
	if(our_turf in escapee.do_afters)
		return //already trying to escape
	to_chat(escapee, span_warning("You push against the thin pipe walls..."))
	playsound(our_turf, 'sound/machines/airlock_alien_prying.ogg', 30, FALSE, 3) //yeah I know but at least it sounds like metal being bent.
	if(!do_after(escapee, 20 SECONDS, our_turf))
		return
	for(var/mob/living/jailbird in contents)
		jailbird.apply_damage(rand(5, 15), BRUTE)
	transport_cylinder.spew_forth()
	transport_cylinder.take_damage(transport_cylinder.max_integrity)


//failsafe in the case the holder is somehow forcemoved somewhere that's not a disposal pipe. Otherwise the above loop breaks.
/obj/structure/disposalholder/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	var/static/list/pipes_typecache = typecacheof(/obj/structure/disposalpipe)
	//Moved to nullspace gang
	if(!loc || pipes_typecache[loc.type])
		return
	var/turf/our_turf = get_turf(loc)
	if(our_turf)
		vent_gas(our_turf)
	var/drop_loc = drop_location()
	for(var/atom/movable/thing as anything in contents)
		thing.forceMove(drop_loc)
	qdel(src)


/// Finds the turf which should contain the next pipe
/obj/structure/disposalholder/proc/nextloc()
	return get_step(src, dir)


/// Finds a matching pipe on a turf
/obj/structure/disposalholder/proc/findpipe(turf/check_turf)
	if(!check_turf)
		return null

	var/fdir = REVERSE_DIR(dir) // flip the movement direction
	for(var/obj/structure/disposalpipe/pipe in check_turf)
		if(fdir & pipe.dpdir) // find pipe direction mask that matches flipped dir
			if(QDELING(pipe))
				CRASH("Pipe is being deleted while being used by a disposal holder at ([pipe.x], [pipe.y], [pipe.z]")
			return pipe
	// if no matching pipe, return null
	return null


/// Merge two holder objects, used when a holder meets a stuck holder
/obj/structure/disposalholder/proc/merge(obj/structure/disposalholder/other)
	for(var/atom/movable/movable as anything in other)
		movable.forceMove(src) // move everything in other holder to this one
		if(ismob(movable))
			var/mob/mob = movable
			mob.reset_perspective(src) // if a client mob, update eye to follow this holder
			RegisterSignal(mob, COMSIG_LIVING_RESIST, PROC_REF(struggle_prep))
			hasmob = TRUE
	if(destinationTag == 0 && other.destinationTag != 0)
		destinationTag = other.destinationTag
	if(!tomail && other.tomail)
		tomail = TRUE
	if(other.has_fat_guy)
		has_fat_guy = TRUE
	qdel(other)


// called when player tries to move while in a pipe
/obj/structure/disposalholder/relaymove(mob/living/user, direction)
	if(user.incapacitated() || world.time <= user.last_special)
		return
	user.last_special = world.time + 10 SECONDS
	for(var/mob/hearer in range(5, get_turf(src)))
		hearer.show_message("<FONT size=[max(0, 5 - get_dist(src, hearer))]>CLONG, clong!</FONT>", EMOTE_AUDIBLE)
	playsound(loc, 'sound/effects/clang.ogg', 50, FALSE)


/// Called to vent all gas in holder to a location
/obj/structure/disposalholder/proc/vent_gas(turf/turf)
	turf.assume_air(gas)


/obj/structure/disposalholder/AllowDrop()
	return TRUE


/obj/structure/disposalholder/ex_act(severity, target)
	return

