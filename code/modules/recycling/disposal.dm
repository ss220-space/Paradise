// Disposal bin
// Holds items for disposal into pipe system
// Draws air from turf, gradually charges internal reservoir
// Once full (~1 atm), uses air resv to flush items into the pipes
// Automatically recharges air (unless off), will flush when ready if pre-set
// Can hold items and human size things, no other draggables
// Toilets are a type of disposal bin for small objects only and work on magic. By magic, I mean torque rotation
#define SEND_PRESSURE (0.05*ONE_ATMOSPHERE)
#define UNSCREWED -1
#define SCREWED 1
#define OFF 0
#define CHARGING 1
#define CHARGED 2

/obj/machinery/disposal
	name = "disposal unit"
	desc = "A pneumatic waste disposal unit."
	icon = 'icons/obj/pipes_and_stuff/not_atmos/disposal.dmi'
	icon_state = "disposal"
	base_icon_state = "disposal"
	anchored = TRUE
	density = TRUE
	on_blueprints = TRUE
	armor = list("melee" = 25, "bullet" = 10, "laser" = 10, "energy" = 100, "bomb" = 0, "bio" = 100, "rad" = 100, "fire" = 90, "acid" = 30)
	max_integrity = 200
	resistance_flags = FIRE_PROOF
	active_power_usage = 600
	idle_power_usage = 100
	/// Internal air reservoir
	var/datum/gas_mixture/air_contents
	/// Disposal pipe trunk, we are attached to
	var/obj/structure/disposalpipe/trunk/trunk
	/// Current machine status
	var/mode = CHARGING
	/// Whether flush handle is pulled
	var/flush = FALSE
	/// Whether flushing is currently in progress
	var/flushing = FALSE
	/// Process cycles before it look whether it is ready to flush
	var/flush_every_ticks = 30
	/// This var adds 1 every process cycle. When it reaches flush_every_ticks it resets and tries to flush
	var/flush_count = 0
	/// Maximum amount of contents length we can have, before we stop inserting new objects
	var/storage_slots = 50
	/// Maximum value of the w_classes of all the items in contents, before we stop inserting new objects
	var/max_combined_w_class = 50
	COOLDOWN_DECLARE(eject_effects_cd)


/obj/machinery/disposal/Initialize(mapload, obj/structure/disposalconstruct/made_from)
	// this will get a copy of the air turf and take a SEND PRESSURE amount of air from it
	. = ..()
	air_contents = new()
	var/datum/milla_safe/disposal_suck_air/milla = new()
	milla.invoke_async(src)
	trunk_check()
	update()

/datum/milla_safe/disposal_suck_air

/datum/milla_safe/disposal_suck_air/on_run(obj/machinery/disposal/disposal)
	var/turf/T = get_turf(disposal)
	var/datum/gas_mixture/env = get_turf_air(T)

	var/pressure_delta = (SEND_PRESSURE + 1) - disposal.air_contents.return_pressure()

	if(env.temperature() > 0)
		var/transfer_moles = 0.1 * pressure_delta*disposal.air_contents.volume / (env.temperature() * R_IDEAL_GAS_EQUATION)

		//Actually transfer the gas
		var/datum/gas_mixture/removed = env.remove(transfer_moles)
		disposal.air_contents.merge(removed)

	// if full enough, switch to ready mode
	if(disposal.air_contents.return_pressure() >= SEND_PRESSURE)
		disposal.mode = 2
		disposal.update()

// attack by item places it in to disposal
/obj/machinery/disposal/attackby(obj/item/I, mob/user, params)
	if(stat & BROKEN || !user || I.flags & ABSTRACT)
		return

	if(loc == W)
		return FALSE //Means the item is already in the storage item
	if(contents.len >= storage_slots)
		if(!stop_messages)
			to_chat(usr, "<span class='warning'>[W] won't fit in [src], make some space!</span>")
		return FALSE //Storage item is full

	var/sum_w_class = W.w_class
	for(var/obj/item/I in contents)
		sum_w_class += I.w_class //Adds up the combined w_classes which will be in the storage item if the item is added to it.

	if(sum_w_class > max_combined_w_class)
		if(!stop_messages)
			to_chat(usr, "<span class='notice'>[src] is full, make some space.</span>")
		return FALSE

	if(HAS_TRAIT(W, TRAIT_NODROP)) //SHOULD be handled in unEquip, but better safe than sorry.
		to_chat(usr, "<span class='notice'>\the [W] is stuck to your hand, you can't put it in \the [src]</span>")
		return FALSE

	return TRUE

// attack by item places it in to disposal
/obj/machinery/disposal/attackby(obj/item/I, mob/user, params)
	if(stat & BROKEN || !I || !user)
		return

	if(istype(I, /obj/item/melee/energy/blade))
		to_chat(user, "You can't place that item inside the disposal unit.")
		return

	if(isstorage(I))
		var/obj/item/storage/storage = I
		if((storage.allow_quick_empty || storage.allow_quick_gather) && length(storage.contents))
			add_fingerprint(user)
			storage.hide_from(user)
			for(var/obj/item/item in storage.contents)
				if(!can_be_inserted(item))
					break
				storage.remove_from_storage(item, src)
				item.add_hiddenprint(user)
			if(!length(storage))
				user.visible_message("[user] empties \the [storage] into \the [src].", "You empty \the [storage] into \the [src].")
			else
				user.visible_message("[user] dumped some items from \the [storage] into \the [src].", "You dumped some items \the [storage] into \the [src].")
			storage.update_icon() // For content-sensitive icons
			update()
			return

	if(!I || !can_be_inserted(I) || !user.drop_transfer_item_to_loc(I, src))
		return

	add_fingerprint(user)
	to_chat(user, "You place \the [I] into the [src].")
	for(var/mob/viewer in (viewers(src) - user))
		viewer.show_message("[user.name] places \the [I] into the [src].", 3)

	update()


/obj/machinery/disposal/grab_attack(mob/living/grabber, atom/movable/grabbed_thing)
	. = TRUE
	if(grabber.grab_state < GRAB_AGGRESSIVE || !isliving(grabbed_thing))
		return .

	grabber.visible_message(span_notice("[grabber] starts putting [grabbed_thing.name] into the disposal."), ignored_mobs = grabber)
	if(!do_after(grabber, 2 SECONDS, src, NONE) || !grabbed_thing || grabber.pulling != grabbed_thing)
		return .

	add_fingerprint(grabber)
	grabbed_thing.forceMove(src)
	grabber.visible_message(span_warning("[grabbed_thing.name] has been placed in [src] by [grabber]."))
	add_attack_logs(grabber, grabbed_thing, "Disposal'ed")
	update()


/obj/machinery/disposal/screwdriver_act(mob/user, obj/item/I)
	if(mode > OFF) // It's on
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(contents.len > 0)
		to_chat(user, "Eject the items first!")
		return
	if(mode == OFF) // It's off but still not unscrewed
		mode = UNSCREWED // Set it to doubleoff l0l
	else if(mode == UNSCREWED)
		mode = OFF
	to_chat(user, "You [mode ? "unfasten": "fasten"] the screws around the power connection.")
	update()


/obj/machinery/disposal/welder_act(mob/user, obj/item/I)
	. = TRUE
	if(mode != UNSCREWED)
		return .
	if(length(contents))
		to_chat(user, "Eject the items first!")
		return .
	if(!I.tool_use_check(user, 0))
		return .
	WELDER_ATTEMPT_FLOOR_SLICE_MESSAGE
	if(!I.use_tool(src, user, 2 SECONDS, volume = I.tool_volume))
		return .
	WELDER_FLOOR_SLICE_SUCCESS_MESSAGE
	var/obj/structure/disposalconstruct/construct = new(loc, null, null, src)
	transfer_fingerprints_to(construct)
	construct.set_anchored(TRUE)
	qdel(src)


// mouse drop another mob or self
//
/obj/machinery/disposal/MouseDrop_T(mob/living/target, mob/living/user, params)
	if(!istype(target) || target.buckled || target.has_buckled_mobs() || !in_range(user, src) || !in_range(user, target) || user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || isAI(user))
		return
	if(isanimal(user) && target != user)
		return //animals cannot put mobs other than themselves into disposal
	if(target != user && target.anchored)
		return
	add_fingerprint(user)
	for(var/mob/viewer in viewers(user))
		if(target == user)
			viewer.show_message("[user] starts climbing into the disposal.", 3)
		else
			viewer.show_message("[user] starts stuffing [target.name] into the disposal.", 3)
	INVOKE_ASYNC(src, TYPE_PROC_REF(/obj/machinery/disposal, put_in), target, user)
	return TRUE


/obj/machinery/disposal/proc/put_in(mob/living/target, mob/living/user) // need this proc to use INVOKE_ASYNC in other proc. You're not recommended to use that one
	var/msg
	var/target_loc = target.loc
	if(!do_after(usr, 2 SECONDS, target))
		return
	if(QDELETED(src) || target_loc != target.loc)
		return
	if(target == user && !user.incapacitated())	// if drop self, then climbed in
											// must be awake, not stunned or whatever
		msg = "[user.name] climbs into [src]."
		to_chat(user, "You climb into [src].")
	else if(target != user && !user.incapacitated() && !HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		msg = "[user.name] stuffs [target.name] into [src]!"
		to_chat(user, "You stuff [target.name] into [src]!")
		if(!iscarbon(user))
			target.LAssailant = null
		else
			target.LAssailant = user
		add_attack_logs(user, target, "Disposal'ed")
	else
		return
	target.forceMove(src)

	for(var/mob/viewer in (viewers(src) - user))
		viewer.show_message(msg, 3)

	update()


// attempt to move while inside
/obj/machinery/disposal/relaymove(mob/user)
	if(user.stat || src.flushing)
		return
	go_out(user)


// leave the disposal
/obj/machinery/disposal/proc/go_out(mob/user)
	if(user)
		user.forceMove(loc)
	update()

// ai as human but can't flush
/obj/machinery/disposal/attack_ai(mob/user)
	add_hiddenprint(user)
	ui_interact(user)

/obj/machinery/disposal/attack_ghost(mob/user)
	ui_interact(user)


// human interact with machine
/obj/machinery/disposal/attack_hand(mob/user)
	if(..())
		return TRUE

	if(stat & BROKEN)
		return

	if(user && user.loc == src)
		to_chat(usr, "<span class='warning'>You cannot reach the controls from inside.</span>")
		return

	// Clumsy folks can only flush it.
	if(user.IsAdvancedToolUser())
		ui_interact(user)
	else
		flush = !flush
		update()


/obj/machinery/disposal/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "DisposalBin", name)
		ui.open()


/obj/machinery/disposal/ui_data(mob/user)
	var/list/data = list()

	data["isAI"] = isAI(user)
	data["flushing"] = flush
	data["mode"] = mode
	data["pressure"] = round(clamp(100* air_contents.return_pressure() / (SEND_PRESSURE), 0, 100),1)

	return data

/obj/machinery/disposal/ui_act(action, params)
	if(..())
		return
	if(usr.loc == src)
		to_chat(usr, "<span class='warning'>You cannot reach the controls from inside.</span>")
		return

	if(mode == UNSCREWED && action != "eject") // If the mode is -1, only allow ejection
		to_chat(usr, "<span class='warning'>The disposal units power is disabled.</span>")
		return

	if(stat & BROKEN)
		return

	add_fingerprint(usr)

	if(flushing)
		return

	if(isturf(loc))
		if(action == "pumpOn")
			mode = CHARGING
			update()
		if(action == "pumpOff")
			mode = OFF
			update()

		if(!issilicon(usr))
			if(action == "engageHandle")
				flush = TRUE
				update()
			if(action == "disengageHandle")
				flush = FALSE
				update()

			if(action == "eject")
				eject()
	return TRUE


// eject the contents of the disposal unit
/obj/machinery/disposal/proc/eject()
	pipe_eject(src, FALSE, FALSE)
	update()


/obj/machinery/disposal/AltClick(mob/user)
	if(!Adjacent(user) || !ishuman(user) || user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return ..()
	user.visible_message(
		"<span class='notice'>[user] tries to eject the contents of [src] manually.</span>",
		"<span class='notice'>You operate the manual ejection lever on [src].</span>"
	)
	if(!do_after(user, 5 SECONDS, src))
		return ..()

	user.visible_message(
		"<span class='notice'>[user] ejects the contents of [src].</span>",
		"<span class='notice'>You eject the contents of [src].</span>",
	)
	eject()


// update the icon & overlays to reflect mode & status
/obj/machinery/disposal/proc/update()
	if(stat & BROKEN)
		mode = OFF
		flush = FALSE

	update_icon()


/obj/machinery/disposal/update_icon_state()
	if(stat & BROKEN)
		icon_state = "disposal-broken"
		return
	icon_state = initial(icon_state)


/obj/machinery/disposal/update_overlays()
	. = ..()
	underlays.Cut()

	// flush handle
	if(flush)
		. += "dispover-handle"

	// only handle is shown if no power
	if((stat & (NOPOWER|BROKEN)) || mode == UNSCREWED)
		return

	// 	check for items in disposal - occupied light
	if(length(contents))
		. += "dispover-full"
		underlays += emissive_appearance(icon, "dispover-full", src)
		return

	// charging and ready light
	switch(mode)
		if(CHARGING)
			. += "dispover-charge"
			underlays += emissive_appearance(icon, "dispover-lightmask", src)
		if(CHARGED)
			. += "dispover-ready"
			underlays += emissive_appearance(icon, "dispover-lightmask", src)


// timed process
// charge the gas reservoir and perform flush if ready
/obj/machinery/disposal/process()
	use_power = NO_POWER_USE
	if(stat & BROKEN)			// nothing can happen if broken
		return

	flush_count++
	if(flush_count >= flush_every_ticks)
		if(length(contents) && mode == CHARGED)
			INVOKE_ASYNC(src, PROC_REF(flush))
		flush_count = 0

	updateDialog()

	if(flush && air_contents.return_pressure() >= SEND_PRESSURE)	// flush can happen even without power
		flush()

	if(stat & NOPOWER)			// won't charge if no power
		return

	use_power = IDLE_POWER_USE

	if(mode != CHARGING)		// if off or ready, no need to charge
		return

	// otherwise charge
	use_power = ACTIVE_POWER_USE

	var/datum/milla_safe/disposal_suck_air/milla = new()
	milla.invoke_async(src)


// perform a flush
/obj/machinery/disposal/proc/flush()
	flushing = TRUE
	flush_animation()
	sleep(1 SECONDS)
	if(COOLDOWN_FINISHED(src, eject_effects_cd))
		COOLDOWN_START(src, eject_effects_cd, DISPOSAL_SOUND_COOLDOWN)
		playsound(src, 'sound/machines/disposalflush.ogg', 50, FALSE)
	sleep(0.5 SECONDS) // wait for animation to finish
	if(QDELETED(src))
		return
	// virtual holder object which actually	travels through the pipes.
	var/obj/structure/disposalholder/holder = new(src)
	manage_wrapping(holder)
	holder.init(src)	// copy the contents of disposer to holder
	air_contents = new() // The holder just took our gas; replace it
	holder.start(src) // start the holder processing movement
	flushing = FALSE
	// now reset disposal state
	flush = FALSE
	if(mode == CHARGED)	// if was ready,
		mode = CHARGING	// switch to charging
	update()


/obj/machinery/disposal/proc/flush_animation()
	flick("[icon_state]-flush", src)


/obj/machinery/disposal/proc/manage_wrapping(obj/structure/disposalholder/holder)
	for(var/atom/movable/thing as anything in contents)
		if(isdrone(thing) || istype(thing, /mob/living/silicon/robot/syndicate/saboteur) || istype(thing, /obj/item/smallDelivery))
			holder.tomail = TRUE
			return


// called when area power changes
/obj/machinery/disposal/power_change(forced = FALSE)
	. = ..()
	if(.)
		update()	// do default setting/reset of stat NOPOWER bit


// called when holder is expelled from a disposal
// should usually only occur if the pipe network is modified
/obj/machinery/disposal/proc/expel(obj/structure/disposalholder/holder)
	holder.active = FALSE

	if(COOLDOWN_FINISHED(src, eject_effects_cd))
		COOLDOWN_START(src, eject_effects_cd, DISPOSAL_SOUND_COOLDOWN)
		playsound(src, 'sound/machines/hiss.ogg', 50, FALSE)

	pipe_eject(holder)

	holder.vent_gas(loc)
	qdel(holder)


/obj/machinery/disposal/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if((isitem(mover) && !isprojectile(mover)) && mover.throwing && mover.pass_flags != PASSEVERYTHING)
		if((prob(75)  || mover.throwing.thrower && HAS_TRAIT(mover.throwing.thrower, TRAIT_BADASS)) && can_be_inserted(mover, TRUE))
			mover.forceMove(src)
			visible_message("[mover] lands in [src].")
			update()
		else
			visible_message("[mover] bounces off of [src]'s rim!")
		return FALSE


/obj/machinery/disposal/get_remote_view_fullscreens(mob/user)
	if(user.stat == DEAD || !(user.sight & (SEEOBJS|SEEMOBS)))
		user.overlay_fullscreen("remote_view", /atom/movable/screen/fullscreen/impaired, 2)


/obj/machinery/disposal/force_eject_occupant(mob/target)
	target.forceMove(get_turf(src))


/obj/structure/disposalholder
	invisibility = INVISIBILITY_MAXIMUM
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	flags_2 = RAD_PROTECT_CONTENTS_2 | RAD_NO_CONTAMINATE_2
	var/datum/gas_mixture/gas = null	// gas used to flush, will appear at exit point
	var/active = FALSE	// true if the holder is moving, otherwise inactive
	dir = 0
	var/count = 1000	//*** can travel 1000 steps before going inactive (in case of loops)
	var/has_fat_guy = FALSE	// true if contains a fat person
	/// Destination the holder is set to, defaulting to disposals and changes if the contents have a mail/sort tag.
	var/destinationTag = 1
	var/tomail = 0 //changes if contains wrapped package
	var/hasmob = 0 //If it contains a mob

/obj/structure/disposalholder/Destroy()
	QDEL_NULL(gas)
	active = FALSE
	return ..()

	// initialize a holder from the contents of a disposal unit
/obj/structure/disposalholder/proc/init(obj/machinery/disposal/D)
	gas = D.air_contents// transfer gas resv. into holder object

	//Check for any living mobs trigger hasmob.
	//hasmob effects whether the package goes to cargo or its tagged destination.
	for(var/mob/living/M in D)
		if(M && M.stat != 2 && !isdrone(M) && !istype(M, /mob/living/silicon/robot/syndicate/saboteur))
			hasmob = 1

	//Checks 1 contents level deep. This means that players can be sent through disposals...
	//...but it should require a second person to open the package. (i.e. person inside a wrapped locker)
	for(var/obj/O in D)
		if(O.contents)
			for(var/mob/living/M in O.contents)
				if(M && M.stat != 2 && !isdrone(M) && !istype(M, /mob/living/silicon/robot/syndicate/saboteur))
					hasmob = 1

	// now everything inside the disposal gets put into the holder
	// note AM since can contain mobs or objs
	for(var/atom/movable/AM in D)
		AM.forceMove(src)
		SEND_SIGNAL(AM, COMSIG_MOVABLE_DISPOSING, src, D)
		if(ishuman(AM))
			var/mob/living/carbon/human/H = AM
			if(HAS_TRAIT(H, TRAIT_FAT))		// is a human and fat?
				has_fat_guy = TRUE			// set flag on holder
		if(istype(AM, /obj/structure/bigDelivery) && !hasmob)
			var/obj/structure/bigDelivery/T = AM
			destinationTag = T.sortTag
		if(istype(AM, /obj/item/smallDelivery) && !hasmob)
			var/obj/item/smallDelivery/T = AM
			destinationTag = T.sortTag
		//Drones can mail themselves through maint.
		if(isdrone(AM))
			var/mob/living/silicon/robot/drone/drone = AM
			destinationTag = drone.mail_destination
		if(istype(AM, /mob/living/silicon/robot/syndicate/saboteur))
			var/mob/living/silicon/robot/syndicate/saboteur/S = AM
			destinationTag = S.mail_destination
		if(istype(AM, /obj/item/shippingPackage) && !hasmob)
			var/obj/item/shippingPackage/sp = AM
			if(sp.sealed)	//only sealed packages get delivered to their intended destination
				destinationTag = sp.sortTag


	// start the movement process
	// argument is the disposal unit the holder started in
/obj/structure/disposalholder/proc/start(obj/machinery/disposal/D)
	if(!D.trunk)
		D.expel(src)	// no trunk connected, so expel immediately
		return

	forceMove(D.trunk)
	active = TRUE
	dir = DOWN
	spawn(1)
		move()		// spawn off the movement process

	return

	// movement process, persists while holder is moving through pipes
/obj/structure/disposalholder/proc/move()
	var/obj/structure/disposalpipe/last
	while(active)
	/*	if(hasmob && prob(3))
			for(var/mob/living/H in src)
				if(!istype(H,/mob/living/silicon/robot/drone)) //Drones use the mailing code to move through the disposal system,
					H.take_overall_damage(20, 0, "Blunt Trauma") */ //horribly maim any living creature jumping down disposals.  c'est la vie

		if(has_fat_guy && prob(2)) // chance of becoming stuck per segment if contains a fat guy
			active = FALSE
			// find the fat guys
			for(var/mob/living/carbon/human/H in src)
				if(HAS_TRAIT(H, TRAIT_FAT))
					to_chat(H, "<span class='userdanger'>You suddenly stop in [last], your extra weight jamming you against the walls!</span>")
			break
		sleep(1)		// was 1
		var/obj/structure/disposalpipe/curr = loc
		last = curr
		curr = curr.transfer(src)
		if(!curr)
			last.expel(src, loc, dir)

		//
		if(!(count--))
			active = FALSE
	return



	// find the turf which should contain the next pipe
/obj/structure/disposalholder/proc/nextloc()
	return get_step(loc,dir)

	// find a matching pipe on a turf
/obj/structure/disposalholder/proc/findpipe(turf/T)
	if(!T)
		return null

	var/fdir = turn(dir, 180)	// flip the movement direction
	for(var/obj/structure/disposalpipe/P in T)
		if(fdir & P.dpdir)		// find pipe direction mask that matches flipped dir
			return P
	// if no matching pipe, return null
	return null

	// merge two holder objects
	// used when a a holder meets a stuck holder
/obj/structure/disposalholder/proc/merge(obj/structure/disposalholder/other)
	for(var/atom/movable/AM in other)
		AM.forceMove(src)		// move everything in other holder to this one
		if(ismob(AM))
			var/mob/M = AM
			M.reset_perspective(src)	// if a client mob, update eye to follow this holder

	if(other.has_fat_guy)
		has_fat_guy = TRUE
	qdel(other)


	// called when player tries to move while in a pipe
/obj/structure/disposalholder/relaymove(mob/user)
	if(!isliving(user))
		return

	var/mob/living/U = user

	if(U.stat || world.time <= U.last_special)
		return

	U.last_special = world.time + 100

	if(loc)
		for(var/mob/M in hearers(loc.loc))
			to_chat(M, "<FONT size=[max(0, 5 - get_dist(src, M))]>CLONG, clong!</FONT>")

	playsound(loc, 'sound/effects/clang.ogg', 50, 0, 0)

	// called to vent all gas in holder to a location
/obj/structure/disposalholder/proc/vent_gas(turf/location)
	if(istype(location))
		location.blind_release_air(gas)

// Disposal pipes

/obj/structure/disposalpipe
	icon = 'icons/obj/pipes/disposal.dmi'
	name = "disposal pipe"
	desc = "An underfloor disposal pipe."
	anchored = TRUE
	density = FALSE

	on_blueprints = TRUE
	level = 1			// underfloor only
	var/dpdir = 0		// bitmask of pipe directions
	dir = 0				// dir will contain dominant direction for junction pipes
	var/health = 10 	// health points 0-10
	max_integrity = 200
	armor = list(MELEE = 25, BULLET = 10, LASER = 10, ENERGY = 100, BOMB = 0, RAD = 100, FIRE = 90, ACID = 30)
	damage_deflection = 10
	flags_2 = RAD_PROTECT_CONTENTS_2 | RAD_NO_CONTAMINATE_2
	plane = FLOOR_PLANE
	layer = DISPOSAL_PIPE_LAYER				// slightly lower than wires and other pipes
	base_icon_state	// initial icon state on map
	/// The last time a sound was played from this
	var/last_sound

	// new pipe, set the icon_state as on map
/obj/structure/disposalpipe/Initialize(mapload)
	. = ..()
	base_icon_state = icon_state


// pipe is deleted
// ensure if holder is present, it is expelled
/obj/structure/disposalpipe/Destroy()
	for(var/obj/structure/disposalholder/H in contents)
		H.active = FALSE
		var/turf/T = loc
		if(T.density)
			// deleting pipe is inside a dense turf (wall)
			// this is unlikely, but just dump out everything into the turf in case

			for(var/atom/movable/AM in H)
				AM.forceMove(T)
				AM.pipe_eject(0)
			qdel(H)
			..()
			return

		// otherwise, do normal expel from turf
		expel(H, T, 0)
	return ..()

/obj/structure/disposalpipe/singularity_pull(S, current_size)
	..()
	if(current_size >= STAGE_FIVE)
		deconstruct()

// returns the direction of the next pipe object, given the entrance dir
// by default, returns the bitmask of remaining directions
/obj/structure/disposalpipe/proc/nextdir(fromdir)
	return dpdir & (~turn(fromdir, 180))

// transfer the holder through this pipe segment
// overriden for special behaviour
//
/obj/structure/disposalpipe/proc/transfer(obj/structure/disposalholder/H)
	var/nextdir = nextdir(H.dir)
	H.dir = nextdir
	var/turf/T = H.nextloc()
	var/obj/structure/disposalpipe/P = H.findpipe(T)

	if(P)
		// find other holder in next loc, if inactive merge it with current
		var/obj/structure/disposalholder/H2 = locate() in P
		if(H2 && !H2.active)
			H.merge(H2)

		H.forceMove(P)
	else			// if wasn't a pipe, then set loc to turf
		if(is_blocked_turf(T))
			H.forceMove(loc)
		else
			H.forceMove(T)
		return null

	return P


// update the icon_state to reflect hidden status and change icon when welded
/obj/structure/disposalpipe/proc/update()
	var/turf/T = get_turf(src)
	hide(T.intact && !isspaceturf(T) && !T.transparent_floor)	// space and transparent floors never hide pipes
	update_icon(UPDATE_ICON_STATE)

// hide called by levelupdate if turf intact status changes
// change visibility status
/obj/structure/disposalpipe/hide(intact)
	if(intact)
		invisibility = INVISIBILITY_MAXIMUM
		alpha = 128
		return
	invisibility = INVISIBILITY_MINIMUM
	alpha = 255

// makes sure we are using the right icon state when we secure the disposals
/obj/structure/disposalpipe/update_icon_state()
	icon_state = base_icon_state

// expel the held objects into a turf
// called when there is a break in the pipe
//

/obj/structure/disposalpipe/proc/expel(obj/structure/disposalholder/H, turf/T, direction)

	if(!T)
		return

	var/turf/target

	if(T.density)		// dense ouput turf, so stop holder
		H.active = FALSE
		H.forceMove(src)
		return
	if(T.intact && isfloorturf(T)) //intact floor, pop the tile
		var/turf/simulated/floor/F = T
		var/turf_typecache = F.floor_tile
		if(F.remove_tile(null, TRUE, FALSE))
			new turf_typecache(T)

	if(direction)		// direction is specified
		if(isspaceturf(T)) // if ended in space, then range is unlimited
			target = get_edge_target_turf(T, direction)
		else						// otherwise limit to 10 tiles
			target = get_ranged_target_turf(T, direction, 10)

		if(last_sound + DISPOSAL_SOUND_COOLDOWN < world.time)
			playsound(src, 'sound/machines/hiss.ogg', 50, 0, FALSE)
			last_sound = world.time

		if(H)
			for(var/atom/movable/AM in H)
				AM.forceMove(T)
				AM.pipe_eject(direction)
				SEND_SIGNAL(AM, COMSIG_MOVABLE_EXIT_DISPOSALS)

				spawn(1)
					if(AM)
						AM.throw_at(target, 100, 1)
			H.vent_gas(T)
			qdel(H)

	else	// no specified direction, so throw in random direction

		if(last_sound + DISPOSAL_SOUND_COOLDOWN < world.time)
			playsound(src, 'sound/machines/hiss.ogg', 50, 0, FALSE)
			last_sound = world.time
		if(H)
			for(var/atom/movable/AM in H)
				target = get_offset_target_turf(T, rand(5)-rand(5), rand(5)-rand(5))

				AM.forceMove(T)
				AM.pipe_eject(0)
				SEND_SIGNAL(AM, COMSIG_MOVABLE_EXIT_DISPOSALS)

				spawn(1)
					if(AM)
						AM.throw_at(target, 5, 1)

			H.vent_gas(T)	// all gas vent to turf
			qdel(H)

// call to break the pipe
// will expel any holder inside at the time
// then delete the pipe
// remains : set to leave broken pipe pieces in place
/obj/structure/disposalpipe/proc/broken(remains = 0)
	if(remains)
		for(var/D in GLOB.cardinal)
			if(D & dpdir)
				var/obj/structure/disposalpipe/broken/P = new(src.loc)
				P.setDir(D)

	invisibility = 101	// make invisible (since we won't delete the pipe immediately)
	var/obj/structure/disposalholder/H = locate() in src
	if(H)
		// holder was present
		H.active = FALSE
		var/turf/T = src.loc
		if(T.density)
			// broken pipe is inside a dense turf (wall)
			// this is unlikely, but just dump out everything into the turf in case

			for(var/atom/movable/AM in H)
				AM.forceMove(T)
				AM.pipe_eject(0)
			qdel(H)
			return

		// otherwise, do normal expel from turf
		if(H)
			expel(H, T, 0)

	spawn(2)	// delete pipe after 2 ticks to ensure expel proc finished
		qdel(src)

// pipe affected by explosion
/obj/structure/disposalpipe/ex_act(severity)
	switch(severity)
		if(1)
			broken(0)
		if(2)
			health -= rand(5, 15)
			healthcheck()
		if(3)
			health -= rand(0, 15)
			healthcheck()

// test health for brokenness
/obj/structure/disposalpipe/proc/healthcheck()
	if(health < -2)
		broken(0)
	else if(health<1)
		broken(1)
	return

//attack by item
//weldingtool: unfasten and convert to obj/disposalconstruct

/obj/structure/disposalpipe/attackby(obj/item/I, mob/user, params)
	var/turf/T = get_turf(src)
	if(T.intact || T.transparent_floor)
		to_chat(user, "<span class='danger'>You can't interact with something that's under the floor!</span>")
		return 		// prevent interaction with T-scanner revealed pipes and pipes under glass

	add_fingerprint(user)

/obj/structure/disposalpipe/welder_act(mob/user, obj/item/I)
	. = TRUE
	var/turf/T = get_turf(src)
	if(!I.tool_use_check(user, 0))
		return
	if(T.transparent_floor)
		to_chat(user, "<span class='danger'>You can't interact with something that's under the floor!</span>")
		return
	WELDER_ATTEMPT_SLICING_MESSAGE
	if(!I.use_tool(src, user, 30, volume = I.tool_volume))
		return
	WELDER_SLICING_SUCCESS_MESSAGE
	var/obj/structure/disposalconstruct/C = new (get_turf(src))
	switch(base_icon_state)
		if("pipe-s")
			C.ptype = PIPE_DISPOSALS_STRAIGHT
		if("pipe-c")
			C.ptype = PIPE_DISPOSALS_BENT
		if("pipe-j1")
			C.ptype = PIPE_DISPOSALS_JUNCTION_RIGHT
		if("pipe-j2")
			C.ptype = PIPE_DISPOSALS_JUNCTION_LEFT
		if("pipe-y")
			C.ptype = PIPE_DISPOSALS_Y_JUNCTION
		if("pipe-t")
			C.ptype = PIPE_DISPOSALS_TRUNK
		if("pipe-j1s")
			C.ptype = PIPE_DISPOSALS_SORT_RIGHT
		if("pipe-j2s")
			C.ptype = PIPE_DISPOSALS_SORT_LEFT
	src.transfer_fingerprints_to(C)
	C.dir = dir
	C.density = FALSE
	C.anchored = TRUE
	C.update()

	qdel(src)

// *** TEST verb
//client/verb/dispstop()
//	for(var/obj/structure/disposalholder/H in world)
//		H.active = FALSE

// a straight or bent segment
/obj/structure/disposalpipe/segment
	icon_state = "pipe-s"

/obj/structure/disposalpipe/segment/Initialize(mapload)
	. = ..()
	if(icon_state == "pipe-s")
		dpdir = dir | turn(dir, 180)
	else
		dpdir = dir | turn(dir, -90)
	update()

/obj/structure/disposalpipe/segment/corner
	icon_state = "pipe-c"

//a three-way junction with dir being the dominant direction
/obj/structure/disposalpipe/junction
	icon_state = "pipe-j1"

/obj/structure/disposalpipe/junction/reversed
	icon_state = "pipe-j2"

/obj/structure/disposalpipe/junction/y
	icon_state = "pipe-y"

/obj/structure/disposalpipe/junction/Initialize(mapload)
	. = ..()
	if(icon_state == "pipe-j1")
		dpdir = dir | turn(dir, -90) | turn(dir,180)
	else if(icon_state == "pipe-j2")
		dpdir = dir | turn(dir, 90) | turn(dir,180)
	else // pipe-y
		dpdir = dir | turn(dir,90) | turn(dir, -90)
	update()


	// next direction to move
	// if coming in from secondary dirs, then next is primary dir
	// if coming in from primary dir, then next is equal chance of other dirs

/obj/structure/disposalpipe/junction/nextdir(fromdir)
	var/flipdir = turn(fromdir, 180)
	if(flipdir != dir)	// came from secondary dir
		return dir		// so exit through primary
	else				// came from primary
						// so need to choose either secondary exit
		var/mask = ..(fromdir)

		// find a bit which is set
		var/setbit = 0
		if(mask & NORTH)
			setbit = NORTH
		else if(mask & SOUTH)
			setbit = SOUTH
		else if(mask & EAST)
			setbit = EAST
		else
			setbit = WEST

		if(prob(50))	// 50% chance to choose the found bit or the other one
			return setbit
		else
			return mask & (~setbit)

//a three-way junction that sorts objects
/obj/structure/disposalpipe/sortjunction
	name = "disposal sort junction"
	icon_state = "pipe-j1s"
	var/list/sort_type = list(1)
	var/sort_type_txt //Look at the list called TAGGERLOCATIONS in /code/_globalvars/lists/flavor_misc.dm and cry
	var/posdir = 0
	var/negdir = 0
	var/sortdir = 0

/obj/structure/disposalpipe/sortjunction/reversed
	icon_state = "pipe-j2s"

/obj/structure/disposalpipe/sortjunction/proc/updatedir()
	posdir = dir
	negdir = turn(posdir, 180)

	if(icon_state == "pipe-j1s")
		sortdir = turn(posdir, -90)
	else
		icon_state = "pipe-j2s"
		sortdir = turn(posdir, 90)

	dpdir = sortdir | posdir | negdir

/obj/structure/disposalpipe/sortjunction/Initialize(mapload)
	. = ..()
	updatedir()
	if(mapload)
		parse_sort_destinations()
	update_appearance(UPDATE_DESC)
	update()
	return

/obj/structure/disposalpipe/sortjunction/proc/parse_sort_destinations()
	if(sort_type_txt == "1")
		return

	var/list/sort_type_str = splittext(sort_type_txt, ";")
	var/mapping_fail

	if(length(sort_type_str)) // Default to disposals if mapped with it along other destinations
		if("1" in sort_type_str)
			mapping_fail = "Mutually exclusive sort types in sort_type_txt"
		else
			var/new_sort_type = list()
			for(var/x in sort_type_str)
				var/n = text2num(x)
				if(n)
					new_sort_type |= n
			if(length(new_sort_type))
				sort_type = new_sort_type
			else
				mapping_fail = "No sort types after parsing sort_type_txt"
	else
		mapping_fail = "Sort_type_txt is empty"
	if(mapping_fail)
		stack_trace("[src] mapped incorrectly at [x],[y],[z] - [mapping_fail]")

/obj/structure/disposalpipe/sortjunction/attackby(obj/item/I, mob/user, params)
	if(..())
		return

	if(istype(I, /obj/item/destTagger))
		var/obj/item/destTagger/O = I
		var/tag = uppertext(GLOB.TAGGERLOCATIONS[O.currTag])
		playsound(loc, 'sound/machines/twobeep.ogg', 100, 1)
		if(O.currTag == 1)
			sort_type = list(1)
			to_chat(user, "<span class='notice'>Filter set to [tag] only.</span>")
		else if(O.currTag in sort_type)
			sort_type.Remove(O.currTag)
			to_chat(user, "<span class='notice'>Removed [tag] from filter.</span>")
			if(!length(sort_type))
				sort_type.Add(1) // Default to Disposals if everything is removed.
				to_chat(user, "<span class='notice'>Filter defaulting to [uppertext(GLOB.TAGGERLOCATIONS[1])].</span>")
		else
			if(1 in sort_type) // Remove Disposals if a destination is added.
				sort_type.Remove(1)
			sort_type.Add(O.currTag)
			to_chat(user, "<span class='notice'>Added [tag] to filter.</span>")
		update_appearance(UPDATE_NAME|UPDATE_DESC)

/obj/structure/disposalpipe/sortjunction/update_name()
	. = ..()
	name = initial(name)
	if(length(sort_type) == 1)
		name += " - [GLOB.TAGGERLOCATIONS[sort_type[1]]]"
		return
	name = "multi disposal sort junction"

/obj/structure/disposalpipe/sortjunction/update_desc()
	. = ..()
	desc = "An underfloor disposal pipe with a package sorting mechanism."
	if(length(sort_type))
		var/tags = list()
		for(var/destinations in sort_type)
			tags += GLOB.TAGGERLOCATIONS[destinations]
		desc += "\nIt's tagged with [english_list(tags)]."

	// next direction to move
	// if coming in from negdir, then next is primary dir or sortdir
	// if coming in from posdir, then flip around and go back to posdir
	// if coming in from sortdir, go to posdir

/obj/structure/disposalpipe/sortjunction/nextdir(fromdir, sortTag)
	//var/flipdir = turn(fromdir, 180)
	if(fromdir != sortdir)	// probably came from the negdir

		if(sortTag in sort_type) //if destination matches filtered types...
			return sortdir		// exit through sortdirection
		else
			return posdir
	else				// came from sortdir
						// so go with the flow to positive direction
		return posdir

/obj/structure/disposalpipe/sortjunction/transfer(obj/structure/disposalholder/H)
	var/nextdir = nextdir(H.dir, H.destinationTag)
	H.dir = nextdir
	var/turf/T = H.nextloc()
	var/obj/structure/disposalpipe/P = H.findpipe(T)

	if(P)
		// find other holder in next loc, if inactive merge it with current
		var/obj/structure/disposalholder/H2 = locate() in P
		if(H2 && !H2.active)
			H.merge(H2)
		H.forceMove(P)
	else			// if wasn't a pipe, then set loc to turf
		H.forceMove(T)
		return null

	return P


//a three-way junction that sorts objects destined for the mail office mail table (tomail = 1)
/obj/structure/disposalpipe/wrapsortjunction
	desc = "An underfloor disposal pipe which sorts wrapped and unwrapped objects."
	icon_state = "pipe-j1s"
	var/posdir = 0
	var/negdir = 0
	var/sortdir = 0

/obj/structure/disposalpipe/wrapsortjunction/reversed
	icon_state = "pipe-j2s"

/obj/structure/disposalpipe/wrapsortjunction/Initialize(mapload)
	. = ..()
	posdir = dir
	if(icon_state == "pipe-j1s")
		sortdir = turn(posdir, -90)
		negdir = turn(posdir, 180)
	else
		icon_state = "pipe-j2s"
		sortdir = turn(posdir, 90)
		negdir = turn(posdir, 180)
	dpdir = sortdir | posdir | negdir

	update()
	return


	// next direction to move
	// if coming in from negdir, then next is primary dir or sortdir
	// if coming in from posdir, then flip around and go back to posdir
	// if coming in from sortdir, go to posdir

/obj/structure/disposalpipe/wrapsortjunction/nextdir(fromdir, istomail)
	//var/flipdir = turn(fromdir, 180)
	if(fromdir != sortdir)	// probably came from the negdir
		if(istomail) //if destination matches filtered type...
			return sortdir		// exit through sortdirection
		else
			return posdir
	else				// came from sortdir
		return posdir 						// so go with the flow to positive direction

/obj/structure/disposalpipe/wrapsortjunction/transfer(obj/structure/disposalholder/H)
	var/nextdir = nextdir(H.dir, H.tomail)
	H.dir = nextdir
	var/turf/T = H.nextloc()
	var/obj/structure/disposalpipe/P = H.findpipe(T)

	if(P)
		// find other holder in next loc, if inactive merge it with current
		var/obj/structure/disposalholder/H2 = locate() in P
		if(H2 && !H2.active)
			H.merge(H2)

		H.forceMove(P)
	else			// if wasn't a pipe, then set loc to turf
		H.forceMove(T)
		return null

	return P

//a trunk joining to a disposal bin or outlet on the same turf
/obj/structure/disposalpipe/trunk
	icon_state = "pipe-t"
	var/obj/linked 	// the linked obj/machinery/disposal or obj/disposaloutlet

/obj/structure/disposalpipe/trunk/Initialize(mapload)
	. = ..()
	dpdir = dir
	addtimer(CALLBACK(src, PROC_REF(getlinked)), 0) // This has a delay of 0, but wont actually start until the MC is done

	update()
	return

/obj/structure/disposalpipe/trunk/Destroy()
	if(istype(linked, /obj/structure/disposaloutlet))
		var/obj/structure/disposaloutlet/O = linked
		O.expel(animation = 0)
	else if(istype(linked, /obj/machinery/disposal))
		var/obj/machinery/disposal/D = linked
		if(D.trunk == src)
			D.go_out()
			D.trunk = null
	remove_trunk_links()
	return ..()

/obj/structure/disposalpipe/trunk/proc/getlinked()
	var/turf/T = get_turf(src)
	var/obj/machinery/disposal/D = locate() in T
	if(D)
		nicely_link_to_other_stuff(D)
		return
	var/obj/structure/disposaloutlet/O = locate() in T
	if(O)
		nicely_link_to_other_stuff(O)

/obj/structure/disposalpipe/trunk/proc/remove_trunk_links() //disposals is well-coded
	if(!linked)
		return
	else if(istype(linked, /obj/machinery/disposal)) //jk lol
		var/obj/machinery/disposal/D = linked
		D.trunk = null
	else if(istype(linked, /obj/structure/disposaloutlet)) //God fucking damn it
		var/obj/structure/disposaloutlet/D = linked
		D.linkedtrunk = null
	linked = null

/obj/structure/disposalpipe/trunk/proc/nicely_link_to_other_stuff(obj/O)
	remove_trunk_links() //Breaks the connections between this trunk and the linked machinery so we don't get sent to nullspace or some shit like that
	if(istype(O, /obj/machinery/disposal))
		var/obj/machinery/disposal/D = O
		linked = D
		D.trunk = src
	else if(istype(O, /obj/structure/disposaloutlet))
		var/obj/structure/disposaloutlet/D = O
		linked = D
		D.linkedtrunk = src

	// Override attackby so we disallow trunkremoval when somethings ontop
/obj/structure/disposalpipe/trunk/attackby(obj/item/I, mob/user, params)

	//Disposal bins or chutes
	//Disposal constructors
	var/obj/structure/disposalconstruct/C = locate() in src.loc
	if(C && C.anchored)
		return

	var/turf/T = src.loc
	if(T.intact || T.transparent_floor)
		return		// prevent interaction with T-scanner revealed pipes
	src.add_fingerprint(user)

	// would transfer to next pipe segment, but we are in a trunk
	// if not entering from disposal bin,
	// transfer to linked object (outlet or bin)

/obj/structure/disposalpipe/trunk/transfer(obj/structure/disposalholder/H)
	if(!H)
		return
	if(H.dir == DOWN)		// we just entered from a disposer
		return ..()		// so do base transfer proc
	// otherwise, go to the linked object
	if(!linked)
		expel(H, loc, FALSE)	// expel at turf
	else if(istype(linked, /obj/structure/disposaloutlet))
		var/obj/structure/disposaloutlet/DO = linked
		for(var/atom/movable/AM in H)
			AM.forceMove(DO)
		qdel(H)
		H.vent_gas(loc)
		DO.expel()
	else if(istype(linked, /obj/machinery/disposal))
		var/obj/machinery/disposal/D = linked
		H.forceMove(D)
		D.expel(H)	// expel at disposal
	else //just in case
		expel(H, loc, FALSE)
	// nextdir

/obj/structure/disposalpipe/trunk/nextdir(fromdir)
	if(fromdir == DOWN)
		return dir
	else
		return 0

// a broken pipe
/obj/structure/disposalpipe/broken
	icon_state = "pipe-b"
	dpdir = 0		// broken pipes have dpdir=0 so they're not found as 'real' pipes
					// i.e. will be treated as an empty turf
	desc = "A broken piece of disposal pipe."

/obj/structure/disposalpipe/broken/Initialize(mapload)
	. = ..()
	update()
	return

/obj/structure/disposalpipe/broken/welder_act(mob/user, obj/item/I)
	if(I.use_tool(src, user, 0, volume = I.tool_volume))
		to_chat(user, "<span class='notice'>You remove [src]!</span>")
		I.play_tool_sound(src, I.tool_volume)
		qdel(src)
		return TRUE

// the disposal outlet machine

/obj/structure/disposaloutlet
	name = "disposal outlet"
	desc = "An outlet for the pneumatic disposal system."
	icon = 'icons/obj/pipes/disposal.dmi'
	icon_state = "outlet"
	density = TRUE
	icon_state = "intake"
	base_icon_state = "intake"
	/// Whether this chute directs all items into the cargo waste sorting area
	var/to_waste = TRUE


/obj/machinery/disposal/deliveryChute/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/destTagger))
		add_fingerprint(user)
		to_waste = !to_waste
		to_chat(user, "<span class='notice'>The chute is now set to [to_waste ? "waste" : "cargo"] disposals.</span>")
		if(COOLDOWN_FINISHED(src, eject_effects_cd))
			COOLDOWN_START(src, eject_effects_cd, DISPOSAL_SOUND_COOLDOWN)
			playsound(src.loc, 'sound/machines/twobeep.ogg', 100, TRUE)
		return
	. = ..()


/obj/machinery/disposal/deliveryChute/examine(mob/user)
	. = ..()
	. += "<span class='notice'>The chute is set to [to_waste ? "waste" : "cargo"] disposals.</span>"
	. += "<span class='info'>Use a destination tagger to change the disposal destination.</span>"


/obj/machinery/disposal/deliveryChute/interact()
	return

/obj/machinery/disposal/deliveryChute/update()
	return

/obj/machinery/disposal/deliveryChute/Bumped(atom/movable/moving_atom) //Go straight into the chute
	. = ..()
	if(ismecha(moving_atom) || isspacepod(moving_atom) || isprojectile(moving_atom) || iseffect(moving_atom))
		return .

	switch(dir)
		if(NORTH)
			if(moving_atom.loc.y != src.loc.y+1)
				return
		if(EAST)
			if(moving_atom.loc.x != src.loc.x+1)
				return
		if(SOUTH)
			if(moving_atom.loc.y != src.loc.y-1)
				return
		if(WEST)
			if(moving_atom.loc.x != src.loc.x-1)
				return

	if(isobj(moving_atom) || isliving(moving_atom))
		moving_atom.forceMove(src)

	if(mode != OFF)
		flush()


/obj/machinery/disposal/deliveryChute/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	if(isprojectile(AM))
		return ..() //chutes won't eat bullets
	if(dir == REVERSE_DIR(throwingdatum.init_dir))
		return
	return ..()

/obj/machinery/disposal/deliveryChute/flush_animation()
	flick("intake-closing", src)


/obj/machinery/disposal/deliveryChute/manage_wrapping(obj/structure/disposalholder/holder)
	var/wrap_check = FALSE
	for(var/atom/movable/thing as anything in contents)
		if(istype(thing, /obj/structure/bigDelivery))
			wrap_check = TRUE
			var/obj/structure/bigDelivery/delivery = thing
			if(delivery.sortTag == 0)
				delivery.sortTag = 1
			continue
		if(istype(thing, /obj/item/smallDelivery))
			wrap_check = TRUE
			var/obj/item/smallDelivery/delivery = thing
			if(delivery.sortTag == 0)
				delivery.sortTag = 1
			continue
		if(istype(thing, /obj/item/shippingPackage))
			wrap_check = TRUE
			var/obj/item/shippingPackage/delivery = thing
			if(!delivery.sealed || delivery.sortTag == 0)
				delivery.sortTag = 1
			continue
	if(wrap_check)
		holder.tomail = TRUE
	else if(!wrap_check && to_waste)
		holder.destinationTag = 1


#undef SEND_PRESSURE
#undef UNSCREWED
#undef OFF
#undef SCREWED
#undef CHARGING
#undef CHARGED

