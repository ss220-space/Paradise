// the disposal outlet machine

/obj/structure/disposaloutlet
	name = "disposal outlet"
	desc = "An outlet for the pneumatic disposal system."
	icon = 'icons/obj/pipes_and_stuff/not_atmos/disposal.dmi'
	icon_state = "outlet"
	density = TRUE
	anchored = TRUE
	var/active = FALSE
	var/turf/target	// this will be where the output objects are 'thrown' to.
	var/obj/structure/disposalpipe/trunk/linkedtrunk
	var/mode = FALSE // Is the maintenance panel open? Different than normal disposal's mode
	/// The last time a sound was played
	var/last_sound


/obj/structure/disposaloutlet/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(setup)), 0) // Wait of 0, but this wont actually do anything until the MC is firing

/obj/structure/disposaloutlet/proc/setup()
	target = get_ranged_target_turf(src, dir, 10)
	var/obj/structure/disposalpipe/trunk/T = locate() in get_turf(src)
	if(T)
		T.nicely_link_to_other_stuff(src)

/obj/structure/disposaloutlet/Destroy()
	if(linkedtrunk)
		linkedtrunk.remove_trunk_links()
	expel(FALSE)
	return ..()


/obj/structure/disposaloutlet/proc/expel(animation = TRUE)
	if(animation)
		flick("outlet-open", src)
		var/play_sound = FALSE
		if(last_sound + DISPOSAL_SOUND_COOLDOWN < world.time)
			play_sound = TRUE
			last_sound = world.time
		if(play_sound)
			playsound(src, 'sound/machines/warning-buzzer.ogg', 50, 0, FALSE)
			//wait until correct animation frame
			addtimer(CALLBACK(GLOBAL_PROC, /proc/playsound, src, 'sound/machines/hiss.ogg', 50, FALSE, 0), 2 SECONDS, TIMER_DELETE_ME)
	for(var/atom/movable/AM in contents)
		AM.forceMove(loc)
		AM.pipe_eject(dir)
		if(QDELETED(AM))
			return
		if(isliving(AM))
			var/mob/living/mob_to_immobilize = AM
			if(isdrone(mob_to_immobilize) || istype(mob_to_immobilize, /mob/living/silicon/robot/syndicate/saboteur)) //Drones keep smashing windows from being fired out of chutes. Bad for the station. ~Z
				return
			mob_to_immobilize.Immobilize(1 SECONDS)
		AM.throw_at(target, 3, 1)


/obj/structure/disposaloutlet/screwdriver_act(mob/user, obj/item/I)
	add_fingerprint(user)
	I.play_tool_sound(src)
	to_chat(user, span_notice("You [mode == FALSE ? "remove" : "attach"] the screws around the power connection."))
	mode = !mode
	return TRUE


/obj/structure/disposaloutlet/welder_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	WELDER_ATTEMPT_FLOOR_SLICE_MESSAGE
	if(I.use_tool(src, user, 20, volume = I.tool_volume))
		WELDER_FLOOR_SLICE_SUCCESS_MESSAGE
		var/obj/structure/disposalconstruct/C = new (src.loc)
		C.ptype = PIPE_DISPOSALS_OUTLET
		C.update()
		C.set_anchored(TRUE)
		C.set_density(TRUE)
		transfer_fingerprints_to(C)
		qdel(src)


//When the disposalsoutlet is forcefully moved. Due to meteorshot or the recall item spell for instance
/obj/structure/disposaloutlet/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	if(!loc)
		return
	var/turf/T = old_loc
	if(T.intact)
		var/turf/simulated/floor/F = T
		F.remove_tile(null,TRUE,TRUE)
		T.visible_message("<span class='warning'>The floortile is ripped from the floor!</span>", "<span class='warning'>You hear a loud bang!</span>")
	if(linkedtrunk)
		linkedtrunk.remove_trunk_links()
	var/obj/structure/disposalconstruct/C = new (loc)
	transfer_fingerprints_to(C)
	C.ptype = PIPE_DISPOSALS_OUTLET
	C.update()
	C.set_anchored(FALSE)
	C.set_density(TRUE)
	qdel(src)
