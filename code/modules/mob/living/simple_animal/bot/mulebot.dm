// Mulebot - carries crates around for Quartermaster
// Navigates via floor navbeacons
// Remote Controlled from QM's PDA

#define SIGH 	0
#define ANNOYED 1
#define DELIGHT 2

/mob/living/simple_animal/bot/mulebot
	name = "\improper MULEbot"
	desc = "A Multiple Utility Load Effector bot."
	icon_state = "mulebot0"
	density = TRUE
	move_resist = MOVE_FORCE_STRONG
	animate_movement = FORWARD_STEPS
	health = 50
	maxHealth = 50
	damage_coeff = list(BRUTE = 0.5, BURN = 0.7, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	a_intent = INTENT_HARM //No swapping
	buckle_lying = 0
	can_buckle_to = FALSE
	mob_size = MOB_SIZE_LARGE
	buckle_prevents_pull = TRUE // No pulling loaded shit
	radio_channel = "Supply"

	bot_type = MULE_BOT
	bot_filter = RADIO_MULEBOT
	model = "MULE"
	bot_purpose = "deliver crates and other packages between departments, as requested"
	bot_core_type = /obj/machinery/bot_core/mulebot
	path_image_color = "#7F5200"

	suffix = ""

	/// Delay in deciseconds between each step
	var/step_delay = 2 SECONDS
	/// world.time of next move
	var/next_move_time = 0

	var/static/mulebot_count = 0
	var/atom/movable/load = null
	var/mob/living/passenger = null
	/// This is turf to navigate to (location of beacon).
	var/turf/target
	/// This the direction to unload onto/load from.
	var/loaddir = 0
	/// Tag of home beacon.
	var/home_destination = ""

	/// `TRUE` if already reached the target.
	var/reached_target = TRUE

	/// `TRUE` if auto return to home beacon after unload.
	var/auto_return = TRUE
	/// `TRUE` if auto-pickup at beacon.
	var/auto_pickup = TRUE
	/// `TRUE` if bot will announce an arrival to a location.
	var/report_delivery = TRUE

	var/obj/item/stock_parts/cell/cell
	var/datum/wires/mulebot/wires = null
	var/bloodiness = 0
	var/currentBloodColor = "#A10808"
	var/currentDNA = null


/mob/living/simple_animal/bot/mulebot/Initialize(mapload)
	. = ..()
	wires = new /datum/wires/mulebot(src)
	var/datum/job/cargo_tech/J = new/datum/job/cargo_tech
	access_card.access = J.get_access()
	prev_access = access_card.access
	cell = new /obj/item/stock_parts/cell/upgraded(src)

	mulebot_count++
	set_suffix(suffix ? suffix : "#[mulebot_count]")
	RegisterSignal(src, COMSIG_ATOM_ENTERING, PROC_REF(on_entering))


/mob/living/simple_animal/bot/mulebot/Destroy()
	SStgui.close_uis(wires)
	unload(0)
	QDEL_NULL(wires)
	QDEL_NULL(cell)
	return ..()


/mob/living/simple_animal/bot/mulebot/get_cell()
	return cell


/mob/living/simple_animal/bot/mulebot/proc/set_suffix(_suffix)
	suffix = _suffix
	if(paicard)
		bot_name = "\improper MULEbot ([suffix])"
	else
		name = "\improper MULEbot ([suffix])"


/mob/living/simple_animal/bot/mulebot/bot_reset()
	..()
	reached_target = FALSE


/mob/living/simple_animal/bot/mulebot/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		var/atom/cached_load = load
		. = ..()
		if(!ATTACK_CHAIN_CANCEL_CHECK(.) && knock_off(1 + I.force * 2))
			user.visible_message(
				span_danger("[user] has knocked [cached_load] off [src]!"),
				span_danger("You have knocked [cached_load] off [src]!"),
			)
		return .

	if(istype(I,/obj/item/stock_parts/cell))
		add_fingerprint(user)
		if(!open)
			to_chat(user, span_warning("You should open the maintenance panel first."))
			return ATTACK_CHAIN_PROCEED
		if(cell)
			to_chat(user, span_warning("The [name] already has a power cell installed."))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		cell = I
		user.visible_message(
			span_notice("[user] has inserted a cell into [src]."),
			span_notice("You have inserted the new cell into [src]."),
		)
		update_controls()
		return ATTACK_CHAIN_BLOCKED_ALL

	var/atom/cached_load = load
	. = ..()
	if(!ATTACK_CHAIN_CANCEL_CHECK(.) && knock_off(1 + I.force * 2))
		user.visible_message(
			span_danger("[user] has knocked off [cached_load] from [src]!"),
			span_danger("You have knocked off [cached_load] from [src]!"),
		)


/// Chance to knock off the rider
/mob/living/simple_animal/bot/mulebot/proc/knock_off(probability)
	if(!ismob(load) || !prob(probability))
		return FALSE
	unload(NONE)
	return TRUE


/mob/living/simple_animal/bot/mulebot/screwdriver_act(mob/living/user, obj/item/I)
	. = ..()
	if(!.)
		return .

	if(open)
		on = FALSE
	update_controls()
	update_icon()


/mob/living/simple_animal/bot/mulebot/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	if(health >= maxHealth)
		add_fingerprint(user)
		to_chat(user, span_warning("[src] does not need a repair!"))
		return .
	user.visible_message(
		span_notice("[user] starts to repair [src]."),
		span_notice("You start to repair [src]..."),
	)
	if(!I.use_tool(src, user, 2 SECONDS, volume = I.tool_volume) || health >= maxHealth)
		return .
	heal_damage_type(25, BRUTE)
	user.visible_message(
		span_notice("[user] has repaired [src]."),
		span_notice("You have repaired [src]."),
	)


/mob/living/simple_animal/bot/mulebot/crowbar_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!open)
		add_fingerprint(user)
		to_chat(user, span_warning("You should open the maintenance panel first."))
		return .
	if(!cell)
		add_fingerprint(user)
		to_chat(user, span_warning("The [name] has no power cell installed."))
		return .
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
	user.visible_message(
		span_notice("[user] has removed the power cell from [src]."),
		span_notice("You have removed the power cell from [src]."),
	)
	cell.add_fingerprint(user)
	cell.forceMove(drop_location())
	cell = null


/mob/living/simple_animal/bot/mulebot/wirecutter_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!open)
		add_fingerprint(user)
		to_chat(user, span_warning("You should open the maintenance panel first."))
		return .
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
	attack_hand(user)


/mob/living/simple_animal/bot/mulebot/multitool_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!open)
		add_fingerprint(user)
		to_chat(user, span_warning("You should open the maintenance panel first."))
		return .
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
	attack_hand(user)


/mob/living/simple_animal/bot/mulebot/emag_act(mob/user)
	if(emagged < 1)
		emagged = 1
	if(!open)
		locked = !locked
		to_chat(user, span_notice("You [locked ? "lock" : "unlock"] [src]'s controls!"))
	flick("mulebot-emagged", src)
	playsound(loc, 'sound/effects/sparks1.ogg', 100, FALSE)


/mob/living/simple_animal/bot/mulebot/update_icon_state()
	if(open)
		icon_state="mulebot-hatch"
	else
		icon_state = "mulebot[wires.is_cut(WIRE_MOB_AVOIDANCE)]"


/mob/living/simple_animal/bot/mulebot/update_overlays()
	. = ..()
	if(load && !ismob(load))//buckling handles the mob offsets
		var/image/load_overlay = image(icon = load.icon, icon_state = load.icon_state)
		load_overlay.pixel_y = initial(load.pixel_y) + 9
		if(load.layer < layer)
			load_overlay.layer = layer + 0.1
		load_overlay.overlays = load.overlays
		. += load_overlay


/mob/living/simple_animal/bot/mulebot/ex_act(severity)
	unload(0)
	switch(severity)
		if(1)
			qdel(src)
		if(2)
			for(var/i = 1; i < 3; i++)
				wires.cut_random()
		if(3)
			wires.cut_random()


/mob/living/simple_animal/bot/mulebot/bullet_act(obj/item/projectile/Proj)
	if(..())
		if(prob(50) && !isnull(load))
			unload(0)
		if(prob(25))
			visible_message(span_danger("Something shorts out inside [src]!"))
			wires.cut_random()


/mob/living/simple_animal/bot/mulebot/Topic(href, list/href_list)
	if(..())
		return TRUE

	if(usr.incapacitated() || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED))
		return

	switch(href_list["op"])
		if("lock")
			toggle_lock(usr)
		if("power")
			if(on)
				turn_off()
			else if(cell && !open)
				if(!turn_on())
					to_chat(usr, span_warning("You can't switch on [src]!"))
					return
			else
				return
			visible_message("[usr] switches [on ? "on" : "off"] [src].")
		if("cellremove")
			if(open && cell && !usr.get_active_hand())
				cell.update_icon()
				cell.forceMove_turf()
				usr.put_in_active_hand(cell, ignore_anim = FALSE)
				cell.add_fingerprint(usr)
				cell = null

				usr.visible_message(span_notice("[usr] removes the power cell from [src]."),
									span_notice("You remove the power cell from [src]."))
		if("cellinsert")
			if(open && !cell)
				var/obj/item/stock_parts/cell/C = usr.get_active_hand()
				if(istype(C))
					usr.drop_transfer_item_to_loc(C, src)
					cell = C
					C.add_fingerprint(usr)

					usr.visible_message(span_notice("[usr] inserts a power cell into [src]."),
										span_notice("You insert the power cell into [src]."))
		if("stop")
			if(mode >= BOT_DELIVER)
				bot_reset()
		if("go")
			if(mode == BOT_IDLE)
				start()
		if("home")
			if(mode == BOT_IDLE || mode == BOT_DELIVER)
				start_home()
		if("destination")
			var/new_dest = input(usr, "Enter Destination:", name, destination) as null|anything in GLOB.deliverybeacontags
			if(new_dest)
				set_destination(new_dest)
		if("setid")
			var/new_id = tgui_input_text(usr, "Enter ID:", name, suffix, MAX_NAME_LEN)
			if(new_id)
				set_suffix(new_id)
		if("sethome")
			var/new_home = input(usr, "Enter Home:", name, home_destination) as null|anything in GLOB.deliverybeacontags
			if(new_home)
				home_destination = new_home
		if("unload")
			if(load && mode != BOT_HUNT)
				if(loc == target)
					unload(loaddir)
				else
					unload(0)
		if("autoret")
			auto_return = !auto_return
		if("autopick")
			auto_pickup = !auto_pickup
		if("report")
			report_delivery = !report_delivery
	update_controls()


/mob/living/simple_animal/bot/mulebot/proc/toggle_lock(mob/user)
	if(bot_core.allowed(user))
		locked = !locked
		update_controls()
		return TRUE
	else
		to_chat(user, span_danger("Access denied."))
		return FALSE


// TODO: remove this; PDAs currently depend on it
/mob/living/simple_animal/bot/mulebot/get_controls(mob/user)
	var/ai = issilicon(user)
	var/dat
	dat += hack(user)
	dat += showpai(user)
	dat += "<h3>Multiple Utility Load Effector Mk. V</h3>"
	dat += "<b>ID:</b> [suffix]<BR>"
	dat += "<b>Power:</b> [on ? "On" : "Off"]<BR>"

	if(!open)
		dat += "<h3>Status</h3>"
		dat += "<div class='statusDisplay'>"
		switch(mode)
			if(BOT_IDLE)
				dat += "<span class='good'>Ready</span>"
			if(BOT_DELIVER)
				dat += "<span class='good'>[mode_name[BOT_DELIVER]]</span>"
			if(BOT_GO_HOME)
				dat += "<span class='good'>[mode_name[BOT_GO_HOME]]</span>"
			if(BOT_BLOCKED)
				dat += "<span class='average'>[mode_name[BOT_BLOCKED]]</span>"
			if(BOT_NAV,BOT_WAIT_FOR_NAV)
				dat += "<span class='average'>[mode_name[BOT_NAV]]</span>"
			if(BOT_NO_ROUTE)
				dat += "<span class='bad'>[mode_name[BOT_NO_ROUTE]]</span>"
		dat += "</div>"

		dat += "<b>Current Load:</b> [load ? load.name : "<i>none</i>"]<BR>"
		dat += "<b>Destination:</b> [!destination ? "<i>none</i>" : destination]<BR>"
		dat += "<b>Power level:</b> [cell ? cell.percent() : 0]%"

		if(locked && !ai && !user.can_admin_interact())
			dat += "&nbsp;<br /><div class='notice'>Controls are locked</div><a href='byond://?src=[UID()];op=unlock'>Unlock Controls</A>"
		else
			dat += "&nbsp;<br /><div class='notice'>Controls are unlocked</div><a href='byond://?src=[UID()];op=lock'>Lock Controls</A><BR><BR>"

			dat += "<a href='byond://?src=[UID()];op=power'>Toggle Power</A><BR>"
			dat += "<a href='byond://?src=[UID()];op=stop'>Stop</A><BR>"
			dat += "<a href='byond://?src=[UID()];op=go'>Proceed</A><BR>"
			dat += "<a href='byond://?src=[UID()];op=home'>Return to Home</A><BR>"
			dat += "<a href='byond://?src=[UID()];op=destination'>Set Destination</A><BR>"
			dat += "<a href='byond://?src=[UID()];op=setid'>Set Bot ID</A><BR>"
			dat += "<a href='byond://?src=[UID()];op=sethome'>Set Home</A><BR>"
			dat += "<a href='byond://?src=[UID()];op=autoret'>Toggle Auto Return Home</A> ([auto_return ? "On":"Off"])<BR>"
			dat += "<a href='byond://?src=[UID()];op=autopick'>Toggle Auto Pickup Crate</A> ([auto_pickup ? "On":"Off"])<BR>"
			dat += "<a href='byond://?src=[UID()];op=report'>Toggle Delivery Reporting</A> ([report_delivery ? "On" : "Off"])<BR>"
			if(load)
				dat += "<a href='byond://?src=[UID()];op=unload'>Unload Now</A><BR>"
			dat += "<div class='notice'>The maintenance hatch is closed.</div>"
	else
		if(!ai)
			dat += "<div class='notice'>The maintenance hatch is open.</div><BR>"
			dat += "<b>Power cell:</b> "
			if(cell)
				dat += "<a href='byond://?src=[UID()];op=cellremove'>Installed</A><BR>"
			else
				dat += "<a href='byond://?src=[UID()];op=cellinsert'>Removed</A><BR>"

			wires.Interact(user)
		else
			dat += "<div class='notice'>The bot is in maintenance mode and cannot be controlled.</div><BR>"

	return dat


// returns true if the bot has power
/mob/living/simple_animal/bot/mulebot/proc/has_power()
	return !open && cell && cell.charge > 0 && !wires.is_cut(WIRE_MAIN_POWER1) && !wires.is_cut(WIRE_MAIN_POWER2)


/mob/living/simple_animal/bot/mulebot/proc/buzz(type)
	switch(type)
		if(SIGH)
			audible_message("[src] makes a sighing buzz.")
			playsound(loc, 'sound/machines/buzz-sigh.ogg', 50, 0)
		if(ANNOYED)
			audible_message("[src] makes an annoyed buzzing sound.")
			playsound(loc, 'sound/machines/buzz-two.ogg', 50, 0)
		if(DELIGHT)
			audible_message("[src] makes a delighted ping!")
			playsound(loc, 'sound/machines/ping.ogg', 50, 0)


// mousedrop a crate to load the bot
// can load anything if hacked
/mob/living/simple_animal/bot/mulebot/MouseDrop_T(atom/movable/AM, mob/user, params)

	if(!istype(AM) || user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !in_range(user, src))
		return FALSE

	load(AM)
	return TRUE


// called to load a crate
/mob/living/simple_animal/bot/mulebot/proc/load(atom/movable/AM)
	if(!on || load || AM.anchored || get_dist(src, AM) > 1)
		return

	//I'm sure someone will come along and ask why this is here... well people were dragging screen items onto the mule, and that was not cool.
	//So this is a simple fix that only allows a selection of item types to be considered. Further narrowing-down is below.
	if(!isitem(AM) && !ismachinery(AM) && !isstructure(AM) && !ismob(AM))
		return
	if(!isturf(AM.loc)) //To prevent the loading from stuff from someone's inventory or screen icons.
		return

	var/obj/structure/closet/crate/CRATE
	if(istype(AM,/obj/structure/closet/crate))
		CRATE = AM
	else
		if(!wires.is_cut(WIRE_LOADCHECK) && !hijacked)
			buzz(SIGH)
			return	// if not hacked, only allow crates to be loaded

	if(CRATE) // if it's a crate, close before loading
		CRATE.close()

	if(isobj(AM))
		var/obj/O = AM
		if(O.has_buckled_mobs() || (locate(/mob) in AM)) //can't load non crates objects with mobs buckled to it or inside it.
			buzz(SIGH)
			return

	if(isliving(AM))
		if(!load_mob(AM))
			return
	else
		AM.forceMove(src)

	load = AM
	mode = BOT_IDLE
	update_icon(UPDATE_OVERLAYS)


/mob/living/simple_animal/bot/mulebot/proc/load_mob(mob/living/M)
	can_buckle = TRUE
	if(buckle_mob(M))
		passenger = M
		load = M
		can_buckle = FALSE
		return TRUE
	return FALSE


/mob/living/simple_animal/bot/mulebot/post_buckle_mob(mob/living/target)
	target.pixel_y = target.base_pixel_y + 9
	if(target.layer < layer)
		target.layer = layer + 0.01


/mob/living/simple_animal/bot/mulebot/post_unbuckle_mob(mob/living/target)
	load = null
	target.layer = initial(target.layer)
	target.pixel_y = target.base_pixel_y + target.body_position_pixel_y_offset


// called to unload the bot
// argument is optional direction to unload
// if zero, unload at bot's location
/mob/living/simple_animal/bot/mulebot/proc/unload(dirn)
	if(!load)
		return

	mode = BOT_IDLE

	unbuckle_all_mobs(force = TRUE)

	if(load)
		if(!ismob(load))	// already unbuckled otherwise
			load.forceMove(loc)
		if(dirn)
			var/turf/newT = get_step(load.loc, dirn)
			if(newT.CanPass(load, get_dir(newT, src))) //Can't get off onto anything that wouldn't let you pass normally
				step(load, dirn)
		load = null

	update_icon(UPDATE_OVERLAYS)

	// in case non-load items end up in contents, dump every else too
	// this seems to happen sometimes due to race conditions
	// with items dropping as mobs are loaded

	for(var/atom/movable/thing as anything in src)
		if(thing == cell || thing == access_card || thing == Radio || thing == paicard || thing == bot_core || ispulsedemon(thing))
			continue
		thing.forceMove(loc)



/mob/living/simple_animal/bot/mulebot/call_bot()
	..()
	var/area/dest_area
	if(path && length(path))
		target = ai_waypoint //Target is the end point of the path, the waypoint set by the AI.
		dest_area = get_area(target)
		destination = format_text(dest_area.name)
		pathset = TRUE //Indicates the AI's custom path is initialized.
		start()


/mob/living/simple_animal/bot/mulebot/handle_automated_action()
	diag_hud_set_botmode()

	if(!has_power())
		on = FALSE
		return
	if(!on)
		return

	// 2 / 1.5 / 1 seconds, depending on how many wires we have cut
	step_delay = initial(step_delay) - wires.is_cut(WIRE_MOTOR1) * 0.5 SECONDS - wires.is_cut(WIRE_MOTOR2) * 0.5 SECONDS
	if(!isprocessing)
		START_PROCESSING(SSfastprocess, src)


/mob/living/simple_animal/bot/mulebot/process()
	if(!on)
		return PROCESS_KILL

	switch(mode)
		if(BOT_IDLE) // idle
			return

		if(BOT_DELIVER, BOT_GO_HOME, BOT_BLOCKED) // navigating to deliver,home, or blocked
			if(world.time < next_move_time)
				return

			next_move_time = world.time + step_delay

			if(loc == target) // reached target
				at_target()
				return

			else if(length(path) && target) // valid path
				var/turf/next = path[1]
				reached_target = FALSE
				if(next == loc)
					increment_path()
					path -= next
					return
				if(isturf(next))
					var/oldloc = loc
					var/moved = step_towards(src, next) // attempt to move
					if(moved && oldloc!=loc) // successful move
						blockcount = 0
						increment_path()
						path -= loc
						if(destination == home_destination)
							mode = BOT_GO_HOME
						else
							mode = BOT_DELIVER

					else // failed to move

						blockcount++
						mode = BOT_BLOCKED
						if(blockcount == 3)
							buzz(ANNOYED)

						if(blockcount > 10) // attempt 10 times before recomputing
							// find new path excluding blocked turf
							buzz(SIGH)
							mode = BOT_WAIT_FOR_NAV
							blockcount = 0
							addtimer(CALLBACK(src, PROC_REF(process_blocked), next), 2 SECONDS)
							return
						return
				else
					buzz(ANNOYED)
					mode = BOT_NAV
					return
			else
				mode = BOT_NAV
				return

		if(BOT_NAV) // calculate new path
			mode = BOT_WAIT_FOR_NAV
			INVOKE_ASYNC(src, PROC_REF(process_nav))


/mob/living/simple_animal/bot/mulebot/proc/process_blocked(turf/next)
	calc_path(avoid = next)
	if(length(path))
		buzz(DELIGHT)
	mode = BOT_BLOCKED


/mob/living/simple_animal/bot/mulebot/proc/process_nav()
	calc_path()

	if(length(path))
		blockcount = 0
		mode = BOT_BLOCKED
		buzz(DELIGHT)
	else
		buzz(SIGH)
		mode = BOT_NO_ROUTE


/**
 * calculates a path to the current destination, given an optional turf to avoid.
 */
/mob/living/simple_animal/bot/mulebot/calc_path(turf/avoid)
	check_bot_access()
	set_path(get_path_to(src, target, max_distance = 250, access = access_card.GetAccess(), exclude = avoid, diagonal_handling = DIAGONAL_REMOVE_ALL))


/**
 * Sets the current destination. Signals all beacons matching the delivery code.
 * Beacons will return a signal giving their locations.
 */
/mob/living/simple_animal/bot/mulebot/proc/set_destination(new_dest)
	new_destination = new_dest
	get_nav()


/**
 * Starts bot moving to current destination.
 */
/mob/living/simple_animal/bot/mulebot/proc/start()
	if(!on)
		return
	if(destination == home_destination)
		mode = BOT_GO_HOME
	else
		mode = BOT_DELIVER
	update_icon()
	get_nav()


/**
 * Starts bot moving to home. Sends a beacon query to find.
 */
/mob/living/simple_animal/bot/mulebot/proc/start_home()
	if(!on)
		return
	INVOKE_ASYNC(src, PROC_REF(do_start_home))


/mob/living/simple_animal/bot/mulebot/proc/do_start_home()
	set_destination(home_destination)
	mode = BOT_BLOCKED
	update_icon()


/**
 * Called when bot reaches current target.
 */
/mob/living/simple_animal/bot/mulebot/proc/at_target()
	if(!reached_target)
		radio_channel = "Supply" //Supply channel
		audible_message("[src] makes a chiming sound!")
		playsound(loc, 'sound/machines/chime.ogg', 50, 0)
		reached_target = 1

		if(pathset) //The AI called us here, so notify it of our arrival.
			loaddir = dir //The MULE will attempt to load a crate in whatever direction the MULE is "facing".
			if(calling_ai)
				to_chat(calling_ai, "<span class='notice'>[bicon(src)] [src] wirelessly plays a chiming sound!</span>")
				playsound(calling_ai, 'sound/machines/chime.ogg',40, 0)
				calling_ai = null
				radio_channel = "AI Private" //Report on AI Private instead if the AI is controlling us.

		if(load)		// if loaded, unload at target
			if(report_delivery)
				speak("Destination <b>[destination]</b> reached. Unloading [load].", radio_channel)
			if(istype(load, /obj/structure/closet/crate))
				var/obj/structure/closet/crate/C = load
				C.notifyRecipient(destination)
			unload(loaddir)
		else
			// not loaded
			if(auto_pickup) // find a crate
				var/atom/movable/AM
				if(wires.is_cut(WIRE_LOADCHECK)) // if hacked, load first unanchored thing we find
					for(var/atom/movable/A in get_step(loc, loaddir))
						if(!A.anchored)
							AM = A
							break
				else			// otherwise, look for crates only
					AM = locate(/obj/structure/closet/crate) in get_step(loc,loaddir)
				if(AM && AM.Adjacent(src))
					load(AM)
					if(report_delivery)
						speak("Now loading [load] at <b>[get_area(src)]</b>.", radio_channel)
		// whatever happened, check to see if we return home

		if(auto_return && home_destination && destination != home_destination)
			// auto return set and not at home already
			start_home()
			mode = BOT_BLOCKED
		else
			bot_reset()	// otherwise go idle


/mob/living/simple_animal/bot/mulebot/Move(turf/simulated/next, direct = NONE, glide_size_override = 0, update_dir = TRUE)
	. = ..()

	if(. && istype(next))
		if(bloodiness)
			var/obj/effect/decal/cleanable/blood/tracks/B = locate() in next
			if(!B)
				B = new /obj/effect/decal/cleanable/blood/tracks(loc)
			if(blood_DNA && blood_DNA.len)
				B.blood_DNA |= blood_DNA.Copy()
			B.basecolor = currentBloodColor
			var/newdir = get_dir(next, loc)
			if(newdir == dir)
				B.setDir(newdir)
			else
				newdir = newdir | dir
				if(newdir == 3)
					newdir = 1
				else if(newdir == 12)
					newdir = 4
				B.setDir(newdir)
			B.update_icon()
			bloodiness--


/**
 * Called when bot bumps into anything.
 */
/mob/living/simple_animal/bot/mulebot/Bump(mob/living/bumped_living)
	. = ..()
	if(!wires.is_cut(WIRE_MOB_AVOIDANCE) || !isliving(bumped_living))
		return .

	// usually just bumps, but if avoidance disabled knock over mobs
	if(isrobot(bumped_living))
		visible_message(span_danger("[src] bumps into [bumped_living]!"))
		return .

	if(paicard)
		return .

	add_attack_logs(src, bumped_living, "Knocked down")
	visible_message(span_danger("[src] knocks over [bumped_living]!"))
	bumped_living.Weaken(16 SECONDS)


/mob/living/simple_animal/bot/mulebot/proc/RunOver(mob/living/carbon/human/H)
	if(H.player_logged)//No running over SSD people
		return
	add_attack_logs(src, H, "Run over (DAMTYPE: [uppertext(BRUTE)])")
	H.visible_message(span_danger("[src] drives over [H]!"),
					span_userdanger("[src] drives over you!"))
	playsound(loc, 'sound/effects/splat.ogg', 50, 1)

	var/damage = rand(5, 15)
	H.apply_damage(2*damage, BRUTE, BODY_ZONE_HEAD, run_armor_check(BODY_ZONE_HEAD, MELEE))
	H.apply_damage(2*damage, BRUTE, BODY_ZONE_CHEST, run_armor_check(BODY_ZONE_CHEST, MELEE))
	H.apply_damage(0.5*damage, BRUTE, BODY_ZONE_L_LEG, run_armor_check(BODY_ZONE_L_LEG, MELEE))
	H.apply_damage(0.5*damage, BRUTE, BODY_ZONE_R_LEG, run_armor_check(BODY_ZONE_R_LEG, MELEE))
	H.apply_damage(0.5*damage, BRUTE, BODY_ZONE_L_ARM, run_armor_check(BODY_ZONE_L_ARM, MELEE))
	H.apply_damage(0.5*damage, BRUTE, BODY_ZONE_R_ARM, run_armor_check(BODY_ZONE_R_ARM, MELEE))

	if(HAS_TRAIT(H, TRAIT_NO_BLOOD))//Does the run over mob have blood?
		return//If it doesn't it shouldn't bleed (Though a check should be made eventually for things with liquid in them, like slime people.)

	var/turf/T = get_turf(src)//Where are we?
	H.add_mob_blood(H)//Cover the victim in their own blood.
	H.add_splatter_floor(T)//Put the blood where we are.
	bloodiness += 4

	var/list/blood_dna = H.get_blood_dna_list()
	if(blood_dna)
		transfer_blood_dna(blood_dna)
		currentBloodColor = H.dna.species.blood_color


/mob/living/simple_animal/bot/mulebot/bot_control_message(command, mob/user, user_turf)
	switch(command)
		if("start")
			if(load)
				to_chat(src, span_warningbig("DELIVER [load] TO [destination]"))
			else
				to_chat(src, span_warningbig("PICK UP DELIVERY AT [destination]"))

		if("unload", "load")
			if(load)
				to_chat(src, span_warningbig("UNLOAD"))
			else
				to_chat(src, span_warningbig("LOAD"))
		if("autoret", "autopick", "target")
			return
		else
			..()


/mob/living/simple_animal/bot/mulebot/receive_signal(datum/signal/signal)
	if(wires.is_cut(WIRE_REMOTE_RX) || ..())
		return

	var/r_command = signal.data["command"]
	var/user = signal.data["user"]

	if(client)
		bot_control_message(r_command, user, null)
		return

	// process control input
	switch(r_command)
		if("start")
			start()

		if("target")
			set_destination(signal.data["destination"])

		if("unload")
			if(loc == target)
				unload(loaddir)
			else
				unload(0)

		if("home")
			start_home()

		if("autoret")
			auto_return = text2num(signal.data["value"])

		if("autopick")
			auto_pickup = text2num(signal.data["value"])


/**
 * Send a radio signal with multiple data key/values.
 */
/mob/living/simple_animal/bot/mulebot/post_signal_multiple(freq, list/keyval)
	if(wires.is_cut(WIRE_REMOTE_TX))
		return
	..()


/**
 * Signals bot status etc. to controller.
 */
/mob/living/simple_animal/bot/mulebot/send_status()
	var/list/key_values = list(
		"type" = MULE_BOT,
		"name" = suffix,
		"loca" = get_area(src),
		"mode" = mode,
		"powr" = (cell ? cell.percent() : 0),
		"dest" = destination,
		"home" = home_destination,
		"load" = load,
		"retn" = auto_return,
		"pick" = auto_pickup,
	)
	post_signal_multiple(control_freq, key_values)


/**
 * Player on mulebot attempted to move.
 */
/mob/living/simple_animal/bot/mulebot/relaymove(mob/user)
	if(ispulsedemon(user))
		return ..()
	if(user.incapacitated())
		return
	if(load == user)
		unload(0)


/**
 * Update navigation data. Called when commanded to deliver, return home, or a route update is needed...
 */
/mob/living/simple_animal/bot/mulebot/proc/get_nav()
	if(!on || wires.is_cut(WIRE_BEACON_RX))
		return

	for(var/obj/machinery/navbeacon/NB in GLOB.deliverybeacons)
		if(NB.location == new_destination)	// if the beacon location matches the set destination
			destination = new_destination	// the we will navigate there
			target = NB.loc
			var/direction = NB.dir	// this will be the load/unload dir
			loaddir = direction
			update_icon()
			calc_path()


/mob/living/simple_animal/bot/mulebot/emp_act(severity)
	if(cell)
		cell.emp_act(severity)
	if(load)
		load.emp_act(severity)
	..()


/mob/living/simple_animal/bot/mulebot/explode()
	visible_message(span_userdanger("[src] blows apart!"))
	var/turf/Tsec = get_turf(src)

	new /obj/item/assembly/prox_sensor(Tsec)
	new /obj/item/stack/rods(Tsec)
	new /obj/item/stack/rods(Tsec)
	new /obj/item/stack/cable_coil/cut(Tsec)
	if(cell)
		cell.forceMove(Tsec)
		cell.update_icon()
		cell = null

	do_sparks(3, 1, src)

	new /obj/effect/decal/cleanable/blood/oil(loc)
	..()


/mob/living/simple_animal/bot/mulebot/remove_air(amount) //To prevent riders suffocating
	if(loc)
		return loc.remove_air(amount)
	else
		return null


/mob/living/simple_animal/bot/mulebot/run_resist()
	. = ..()
	if(load)
		unload()


/mob/living/simple_animal/bot/mulebot/UnarmedAttack(atom/A)
	if(!can_unarmed_attack())
		return
	if(isturf(A) && isturf(loc) && loc.Adjacent(A) && load)
		unload(get_dir(loc, A))
	else
		..()


/mob/living/simple_animal/bot/mulebot/proc/on_entering(datum/source, atom/destination, atom/oldloc, list/atom/old_locs)
	SIGNAL_HANDLER

	if(!isturf(destination))
		return

	for(var/mob/living/carbon/human/mob in destination.contents)
		RunOver(mob)


#undef SIGH
#undef ANNOYED
#undef DELIGHT

/obj/machinery/bot_core/mulebot
	req_access = list(ACCESS_CARGO)
