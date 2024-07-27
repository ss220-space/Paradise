// the disposal outlet machine

/obj/structure/disposaloutlet
	name = "disposal outlet"
	desc = "An outlet for the pneumatic disposal system."
	icon = 'icons/obj/pipes_and_stuff/not_atmos/disposal.dmi'
	icon_state = "outlet"
	density = TRUE
	anchored = TRUE
	/// This will be where the output objects are 'thrown' to.
	var/turf/target
	/// Direct ref to the trunk pipe underneath us
	var/obj/structure/disposalpipe/trunk/trunk
	/// Is the maintenance panel open? Different than normal disposal's mode
	var/mode = FALSE
	/// How far we're spitting fir- atoms
	var/eject_range = 3
	/// How fast we're spitting fir- atoms
	var/eject_speed = 1
	COOLDOWN_DECLARE(eject_effects_cd)


/obj/structure/disposaloutlet/Initialize(mapload, obj/structure/disposalconstruct/made_from)
	. = ..()
	if(made_from)
		setDir(made_from.dir)

	target = get_ranged_target_turf(src, dir, 10)

	return INITIALIZE_HINT_LATELOAD


/obj/structure/disposaloutlet/LateInitialize()
	. = ..()
	var/obj/structure/disposalpipe/trunk/found_trunk = locate() in loc
	if(found_trunk)
		found_trunk.set_linked(src)
		trunk = found_trunk


/obj/structure/disposaloutlet/Destroy()
	if(trunk)
		// preemptively expel the contents from the trunk
		// in case the outlet is deleted before expel_holder could be called.
		var/obj/structure/disposalholder/holder = locate() in trunk
		if(holder)
			trunk.expel(holder)
		trunk.linked = null
		trunk = null
	return ..()


// expel the contents of the holder object, then delete it
// called when the holder exits the outlet
/obj/structure/disposaloutlet/proc/expel(obj/structure/disposalholder/holder)
	holder.active = FALSE
	flick("outlet-open", src)
	if(COOLDOWN_FINISHED(src, eject_effects_cd))
		COOLDOWN_START(src, eject_effects_cd, DISPOSAL_SOUND_COOLDOWN)
		playsound(src, 'sound/machines/warning-buzzer.ogg', 50, FALSE, FALSE)
		addtimer(CALLBACK(src, PROC_REF(expel_holder), holder, TRUE), 2 SECONDS)
	else
		addtimer(CALLBACK(src, PROC_REF(expel_holder), holder), 2 SECONDS)


/obj/structure/disposaloutlet/proc/expel_holder(obj/structure/disposalholder/holder, playsound = FALSE)
	if(playsound)
		playsound(src, 'sound/machines/hiss.ogg', 50, FALSE)

	if(QDELETED(holder))
		return

	pipe_eject(holder, dir, TRUE, target, eject_range, eject_speed)
	holder.vent_gas(loc)
	qdel(holder)


/obj/structure/disposaloutlet/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return .
	add_fingerprint(user)
	to_chat(user, span_notice("You [mode == FALSE ? "remove" : "attach"] the screws around the power connection."))
	mode = !mode


/obj/structure/disposaloutlet/welder_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return .
	WELDER_ATTEMPT_FLOOR_SLICE_MESSAGE
	if(!I.use_tool(src, user, 2 SECONDS, volume = I.tool_volume))
		return
	WELDER_FLOOR_SLICE_SUCCESS_MESSAGE
	broken(anchor = TRUE)


/obj/structure/disposaloutlet/proc/broken(anchor = FALSE)
	var/obj/structure/disposalconstruct/construct = new(loc, null, null, src)
	if(anchor)
		construct.set_anchored(TRUE)
	transfer_fingerprints_to(construct)
	qdel(src)


//When the disposalsoutlet is forcefully moved. Due to meteorshot or the recall item spell for instance
/obj/structure/disposaloutlet/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	if(!loc)
		return .
	var/turf/simulated/floor/floor = old_loc
	if(isfloorturf(floor) && floor.intact)
		floor.remove_tile(null, TRUE, TRUE)
		floor.visible_message(
			span_warning("The floortile is ripped from the floor!"),
			span_warning("You hear a loud bang!"),
		)
	broken()

