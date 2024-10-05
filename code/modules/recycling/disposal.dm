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
	if(made_from)
		setDir(made_from.dir)
	return INITIALIZE_HINT_LATELOAD


/obj/machinery/disposal/LateInitialize()
	. = ..()
	var/datum/gas_mixture/env = new
	env.copy_from(loc.return_air())
	var/datum/gas_mixture/removed = env.remove(SEND_PRESSURE + 1)
	air_contents = new
	air_contents.merge(removed)
	trunk_check()
	update()


/obj/machinery/disposal/proc/trunk_check()
	var/obj/structure/disposalpipe/trunk/found_trunk = locate() in loc
	if(!found_trunk)
		mode = OFF
		flush = FALSE
	else
		mode = initial(mode)
		flush = initial(flush)
		found_trunk.set_linked(src) // link the pipe trunk to self
		trunk = found_trunk


//When the disposalsoutlet is forcefully moved. Due to meteorshot (not the recall spell)
/obj/machinery/disposal/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
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
	var/obj/structure/disposalconstruct/construct = new(loc, null, null, src)
	transfer_fingerprints_to(construct)
	qdel(src)


/obj/machinery/disposal/Destroy()
	eject()
	if(trunk)
		trunk.linked = null
		trunk = null
	return ..()


/obj/machinery/disposal/singularity_pull(S, current_size)
	..()
	if(current_size >= STAGE_FIVE)
		deconstruct()


//This proc returns TRUE if the item can be picked up and FALSE if it can't.
//Set the stop_messages to stop it from printing messages
/obj/machinery/disposal/proc/can_be_inserted(obj/item/W, stop_messages = FALSE)
	if(!istype(W) || (W.item_flags & ABSTRACT)) //Not an item
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


/obj/machinery/disposal/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM || (stat & BROKEN))
		return ..()

	add_fingerprint(user)
	if(istype(I, /obj/item/melee/energy/blade))	// why???
		to_chat(user, span_warning("You cannot place that item inside the disposal unit."))
		return ATTACK_CHAIN_PROCEED

	if(isstorage(I))
		var/obj/item/storage/storage = I
		if((storage.allow_quick_empty || storage.allow_quick_gather) && length(storage.contents))
			storage.hide_from_all_viewers()
			for(var/obj/item/item as anything in storage.contents)
				if(!can_be_inserted(item, TRUE))
					continue
				storage.remove_from_storage(item, src)
				item.add_fingerprint(user)
			if(length(storage))
				user.visible_message(
					span_notice("[user] has dumped some items from [storage] into [src]."),
					span_notice("You have dumped some items from [storage] into [src]."),
				)
			else
				user.visible_message(
					span_notice("[user] has emptied [storage] into [src]."),
					span_notice("You have emptied [storage] into [src]."),
				)
			update()
			return ATTACK_CHAIN_PROCEED_SUCCESS

	if(!can_be_inserted(I) || !user.drop_transfer_item_to_loc(I, src))
		return ..()

	user.visible_message(
		span_notice("[user] has placed [I] into [src]."),
		span_notice("You have placed [I] into [src]."),
	)
	update()
	return ATTACK_CHAIN_BLOCKED_ALL


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


/obj/machinery/disposal/shove_impact(mob/living/target, mob/living/attacker)
	target.visible_message(
		span_warning("[attacker] shoves [target] inside of [src]!"),
		span_userdanger("[attacker] shoves you inside of [src]!"),
		span_warning("You hear the sound of something being thrown in the trash.")
	)
	target.forceMove(src)
	add_attack_logs(attacker, target, "Shoved into disposals")
	playsound(src, "sound/effects/bang.ogg")
	update()
	return TRUE


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

	var/atom/L = loc						// recharging from loc turf

	var/datum/gas_mixture/env = L.return_air()
	var/pressure_delta = (SEND_PRESSURE*1.01) - air_contents.return_pressure()

	if(env.temperature > 0)
		var/transfer_moles = 0.1 * pressure_delta*air_contents.volume/(env.temperature * R_IDEAL_GAS_EQUATION)

		//Actually transfer the gas
		var/datum/gas_mixture/removed = env.remove(transfer_moles)
		air_contents.merge(removed)
		air_update_turf()

	// if full enough, switch to ready mode
	if(air_contents.return_pressure() >= SEND_PRESSURE)
		mode = CHARGED
		update()


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


/obj/machinery/disposal/deliveryChute
	name = "Delivery chute"
	desc = "A chute for big and small packages alike!"
	density = TRUE
	icon_state = "intake"
	base_icon_state = "intake"
	/// Whether this chute directs all items into the cargo waste sorting area
	var/to_waste = TRUE


/obj/machinery/disposal/deliveryChute/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(I, /obj/item/destTagger))
		add_fingerprint(user)
		to_waste = !to_waste
		to_chat(user, span_notice("The chute is now set to [to_waste ? "waste" : "cargo"] disposals."))
		if(COOLDOWN_FINISHED(src, eject_effects_cd))
			COOLDOWN_START(src, eject_effects_cd, DISPOSAL_SOUND_COOLDOWN)
			playsound(loc, 'sound/machines/twobeep.ogg', 100, TRUE)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return  ..()


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

