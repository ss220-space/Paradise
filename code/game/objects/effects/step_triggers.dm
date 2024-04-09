/* Simple object type, calls a proc when "stepped" on by something */

/obj/effect/step_trigger
	var/affect_ghosts = FALSE
	var/stopper = TRUE // stops throwers
	var/mobs_only = FALSE
	var/client_only = FALSE
	invisibility = INVISIBILITY_ABSTRACT // nope cant see this shit
	anchored = TRUE

/obj/effect/step_trigger/proc/Trigger(atom/movable/A)
	return FALSE

/obj/effect/step_trigger/Crossed(atom/movable/AM, oldloc)
	. = ..()
	if(!AM)
		return
	if(isobserver(AM) && !affect_ghosts)
		return
	if(!ismob(AM) && mobs_only)
		return
	if(mobs_only && client_only)
		var/mob/crossed_mob = AM
		if(!crossed_mob.client)
			return
	Trigger(AM)

/obj/effect/step_trigger/singularity_act()
	return

/obj/effect/step_trigger/singularity_pull()
	return

/* Sends a message to mob when triggered*/

/obj/effect/step_trigger/message
	var/message	//the message to give to the mob
	var/once = 1
	mobs_only = TRUE

/obj/effect/step_trigger/message/Trigger(mob/M)
	if(M.client)
		to_chat(M, "<span class='info'>[message]</span>")
		if(once)
			qdel(src)

/* Tosses things in a certain direction */

/obj/effect/step_trigger/thrower
	var/direction = SOUTH // the direction of throw
	var/tiles = 3	// if 0: forever until atom hits a stopper
	var/immobilize = 1 // if nonzero: prevents mobs from moving while they're being flung
	var/speed = 1	// delay of movement
	var/nostop = 0 // if 1: will only be stopped by teleporters
	var/list/affecting = list()

/obj/effect/step_trigger/thrower/Trigger(atom/A)
	if(!A || !ismovable(A))
		return
	var/atom/movable/AM = A
	var/curtiles = 0
	var/stopthrow = 0
	for(var/obj/effect/step_trigger/thrower/T in orange(2, src))
		if(AM in T.affecting)
			return

	if(isliving(AM))
		var/mob/living/M = AM
		if(immobilize)
			M.canmove = FALSE

	affecting.Add(AM)
	while(AM && !stopthrow)
		if(tiles)
			if(curtiles >= tiles)
				break
		if(AM.z != src.z)
			break

		curtiles++

		sleep(speed)

		// Calculate if we should stop the process
		if(!nostop)
			for(var/obj/effect/step_trigger/T in get_step(AM, direction))
				if(T.stopper && T != src)
					stopthrow = 1
		else
			for(var/obj/effect/step_trigger/teleporter/T in get_step(AM, direction))
				if(T.stopper)
					stopthrow = 1

		if(AM)
			step(AM, direction)


	affecting.Remove(AM)

	if(isliving(AM))
		var/mob/living/M = AM
		if(immobilize)
			M.canmove = TRUE

/* Stops things thrown by a thrower, doesn't do anything */

/obj/effect/step_trigger/stopper

/* Instant teleporter */

/obj/effect/step_trigger/teleporter
	var/teleport_x = 0	// teleportation coordinates (if one is null, then no teleport!)
	var/teleport_y = 0
	var/teleport_z = 0

/obj/effect/step_trigger/teleporter/Trigger(atom/movable/A)
	if(teleport_x && teleport_y && teleport_z)

		var/turf/T = locate(teleport_x, teleport_y, teleport_z)
		A.forceMove(T)

/* Random teleporter, teleports atoms to locations ranging from teleport_x - teleport_x_offset, etc */

/obj/effect/step_trigger/teleporter/random
	var/teleport_x_offset = 0
	var/teleport_y_offset = 0
	var/teleport_z_offset = 0

/obj/effect/step_trigger/teleporter/random/Trigger(atom/movable/A)
	if(teleport_x && teleport_y && teleport_z)
		if(teleport_x_offset && teleport_y_offset && teleport_z_offset)

			var/turf/T = locate(rand(teleport_x, teleport_x_offset), rand(teleport_y, teleport_y_offset), rand(teleport_z, teleport_z_offset))
			if (T)
				A.forceMove(T)

/* Fancy teleporter, creates sparks and smokes when used */

/obj/effect/step_trigger/teleport_fancy
	var/locationx
	var/locationy
	var/uses = 1	//0 for infinite uses
	var/entersparks = 0
	var/exitsparks = 0
	var/entersmoke = 0
	var/exitsmoke = 0

/obj/effect/step_trigger/teleport_fancy/Trigger(mob/M)
	var/dest = locate(locationx, locationy, z)
	M.Move(dest)

	if(entersparks)
		var/datum/effect_system/spark_spread/s = new
		s.set_up(4, 1, src)
		s.start()
	if(exitsparks)
		var/datum/effect_system/spark_spread/s = new
		s.set_up(4, 1, dest)
		s.start()

	if(entersmoke)
		var/datum/effect_system/smoke_spread/s = new
		s.set_up(4, 1, src, 0)
		s.start()
	if(exitsmoke)
		var/datum/effect_system/smoke_spread/s = new
		s.set_up(4, 1, dest, 0)
		s.start()

	uses--
	if(uses == 0)
		qdel(src)

/* Simple sound player, Mapper friendly! */

/obj/effect/step_trigger/sound_effect
	icon = 'icons/effects/mapping_helpers.dmi'
	icon_state = "sound"
	var/list/sound //eg. path to the sound, inside '' eg: 'growl.ogg'
	var/volume = 100
	var/freq_vary = 1 //Should the frequency of the sound vary?
	var/extra_range = 0 // eg World.view = 7, extra_range = 1, 7+1 = 8, 8 turfs radius
	var/happens_once = 0
	var/triggerer_only = 0 //Whether the triggerer is the only person who hears this


/obj/effect/step_trigger/sound_effect/Trigger(atom/movable/A)
	var/turf/T = get_turf(A)

	if(!T)
		return

	if(triggerer_only && ismob(A))
		var/mob/B = A
		B.playsound_local(T, pick(sound), volume, freq_vary)
	else
		playsound(T, pick(sound), volume, freq_vary, extra_range)

	if(happens_once)
		qdel(src)

/obj/effect/step_trigger/sound_effect/explosion_far
	mobs_only = TRUE
	sound = list('sound/effects/explosionfar.ogg', 'sound/effects/explosioncreak2.ogg', 'sound/effects/explosioncreak1.ogg', 'sound/effects/explosion_distant.ogg')
	volume = 200
	happens_once = 1
	extra_range = 4

/obj/effect/step_trigger/sound_effect/scary_moan
	mobs_only = TRUE
	client_only = TRUE
	happens_once = 1
	sound = list('sound/ambience/spooky/moan1.ogg')

/obj/effect/step_trigger/sound_effect/scream_female
	mobs_only = TRUE
	client_only = TRUE
	happens_once = 1
	triggerer_only = 1
	sound = list('sound/ambience/spooky/scream1.ogg')

/obj/effect/step_trigger/sound_effect/scary_breath
	mobs_only = TRUE
	client_only = TRUE
	happens_once = 1
	triggerer_only = 1
	sound = list('sound/ambience/spooky/scared_breathing1.ogg', 'sound/ambience/spooky/scared_breathing2.ogg', 'sound/ambience/spooky/scared_sob1.ogg', 'sound/ambience/spooky/scared_sob2.ogg')


///////////////////////
////////////// GROUP TRIGGERS
///////////////////////

GLOBAL_LIST_EMPTY(group_triggers)
/obj/effect/step_trigger/group_triggers
	name = "group trigger"
	icon = 'icons/effects/mapping_helpers.dmi'
	icon_state = "not_for_map"
	var/id = 1 //// must be tied with step_trigger_spawner id

/obj/effect/step_trigger/group_triggers/Initialize(mapload)
	. = ..()
	GLOB.group_triggers += src

/obj/effect/step_trigger/group_triggers/Destroy()
	GLOB.group_triggers -= src
	..()

/obj/effect/step_trigger/group_triggers/Trigger()
	for(var/obj/effect/step_trigger/group_triggers/trigger as anything in GLOB.group_triggers)
		if(trigger.id == id)
			qdel(trigger)

//// Spawners for group triggers

/// How it works? Use receivers whith the same id (if you want a large group) or just one (anyway better to change id), if one of receivers is triggered,
/// than step_trigger_spawner spawns anything from spawn_list and all that group of effects deletes itself
/obj/effect/step_trigger/group_triggers/receiver
	icon_state = "alert"
	mobs_only = TRUE
	client_only = TRUE

/obj/effect/step_trigger/group_triggers/receiver/Trigger(atom/movable/A)
	for(var/obj/effect/spawner/step_trigger_spawner/step_spawner as anything in GLOB.step_trigger_spawners)
		if(step_spawner.id == id)
			step_spawner.trigger()
	..()

GLOBAL_LIST_EMPTY(step_trigger_spawners)
/obj/effect/spawner/step_trigger_spawner
	name = "step trigger spawner"
	icon = 'icons/effects/mapping_helpers.dmi'
	icon_state = "yellow"
	invisibility = INVISIBILITY_ABSTRACT
	var/id = 1  //// must be tied with group_triggers id
	var/list/spawn_list

/obj/effect/spawner/step_trigger_spawner/Initialize(mapload)
	. = ..()
	GLOB.step_trigger_spawners += src

/obj/effect/spawner/step_trigger_spawner/Destroy()
	GLOB.step_trigger_spawners -= src
	..()

/obj/effect/spawner/step_trigger_spawner/proc/trigger()
	for(var/path in spawn_list)
		new path(loc)
