/// Conveyor is currently off.
#define CONVEYOR_OFF 0
/// Conveyor is currently configured to move items forward.
#define CONVEYOR_FORWARD 1
/// Conveyor is currently configured to move items backwards.
#define CONVEYOR_BACKWARDS -1
/// List of all used conveyors and switches by id
GLOBAL_LIST_EMPTY(conveyors_by_id)


/obj/machinery/conveyor
	name = "conveyor belt"
	desc = "It's a conveyor belt, commonly used to transport large numbers of items elsewhere quite quickly."
	icon = 'icons/obj/machines/recycling.dmi'
	icon_state = "conveyor_map"
	base_icon_state = "conveyor"
	layer = CONVEYOR_LAYER 		// so they appear under stuff but not below stuff like vents
	anchored = TRUE
	processing_flags = START_PROCESSING_MANUALLY
	/// The current state of the switch.
	var/operating = CONVEYOR_OFF
	/// This is the default (forward) direction, set by the map dir.
	var/forwards
	/// The opposite of forwards. It's set in a special var for corner belts, which aren't using the opposite direction when in reverse.
	var/backwards
	/// The actual direction to move stuff in.
	var/movedir
	/// The time between movements of the conveyor belts, base 0.3 seconds
	var/speed = 0.3 SECONDS
	/// The control ID - must match at least one conveyor switch's ID to be useful.
	var/id = ""
	/// Inverts the direction the conveyor belt moves when true.
	var/inverted = FALSE
	/// Is the conveyor's belt flipped? Useful mostly for conveyor belt corners. It makes the belt point in the other direction, rather than just going in reverse.
	var/flipped = FALSE
	/// Are we currently conveying items?
	var/conveying = FALSE
	//Direction -> if we have a conveyor belt in that direction
	var/list/neighbors
	/// Timestamp used for multitool switch checks
	COOLDOWN_DECLARE(multitool_cooldown)


/obj/machinery/conveyor/Initialize(mapload, new_dir, new_id)
	. = ..()
	var/static/list/give_turf_traits
	if(!give_turf_traits)
		give_turf_traits = string_list(list(TRAIT_TURF_IGNORE_SLOWDOWN))
	AddElement(/datum/element/give_turf_traits, give_turf_traits)
	if(new_dir)
		setDir(new_dir)
	if(new_id)
		id = new_id
	neighbors = list()
	///Leaving onto conveyor detection won't work at this point, but that's alright since it's an optimization anyway
	///Should be fine without it
	var/static/list/loc_connections = list(
		COMSIG_ATOM_EXITED = PROC_REF(conveyable_exit),
		COMSIG_ATOM_ENTERED = PROC_REF(conveyable_enter),
		COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON = PROC_REF(conveyable_enter)
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	update_move_direction()
	LAZYADD(GLOB.conveyors_by_id[id], src)
	return INITIALIZE_HINT_LATELOAD


/obj/machinery/conveyor/LateInitialize()
	. = ..()
	build_neighbors()


/obj/machinery/conveyor/Destroy()
	set_operating(FALSE)
	LAZYREMOVE(GLOB.conveyors_by_id[id], src)
	return ..()


/obj/machinery/conveyor/vv_edit_var(var_name, var_value)
	if(var_name == NAMEOF(src, id))
		// if "id" is varedited, update our list membership
		LAZYREMOVE(GLOB.conveyors_by_id[id], src)
		. = ..()
		LAZYADD(GLOB.conveyors_by_id[id], src)
	else
		return ..()


/obj/machinery/conveyor/setDir(newdir)
	. = ..()
	update_move_direction()


/obj/machinery/conveyor/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	if(!.)
		return .
	//Now that we've moved, rebuild our neighbors list
	neighbors = list()
	build_neighbors()


/obj/machinery/conveyor/examine(mob/user)
	. = ..()
	if(inverted)
		. += span_notice("It is currently set to go in reverse.")
	. += span_info("Use a <b>wrench</b> on the belt to rotate it.")
	. += span_info("Use a <b>screwdriver</b> to flip its belt around.")
	. += span_info("Use a <b>wirecutterss</b> to invert its direction.")
	. += span_info("Use a <b>multitool</b> to highlight the conveyor switch.")


/obj/machinery/conveyor/update_icon_state()
	icon_state = "[base_icon_state][inverted ? -operating : operating ][flipped ? "-flipped" : ""]"


/obj/machinery/conveyor/grab_attack(mob/living/grabber, atom/movable/grabbed_thing)
	. = TRUE
	grabber.Move_Pulled(src)


/obj/machinery/conveyor/attack_hand(mob/user)
	. = ..()
	if(.)
		return .
	user.Move_Pulled(src)


/obj/machinery/conveyor/power_change(forced = FALSE)
	. = ..()
	update()


/obj/machinery/conveyor/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM || (stat & BROKEN))
		return ..()

	if(istype(I, /obj/item/conveyor_switch_construct))
		add_fingerprint(user)
		var/obj/item/conveyor_switch_construct/switch_construct = I
		if(switch_construct.id == id)
			return ..()
		LAZYREMOVE(GLOB.conveyors_by_id[id], src)
		id = switch_construct.id
		LAZYADD(GLOB.conveyors_by_id[id], src)
		to_chat(user, span_notice("You link [switch_construct] with [src]."))
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(user.drop_transfer_item_to_loc(I, loc))
		add_fingerprint(user)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/machinery/conveyor/crowbar_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume) || (stat & BROKEN))
		return .
	if(!(stat & BROKEN))
		var/obj/item/conveyor_construct/conveyor = new(loc, id)
		transfer_fingerprints_to(conveyor)
	to_chat(user, span_notice("You detach [src]."))
	qdel(src)


/obj/machinery/conveyor/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume) || (stat & BROKEN))
		return .
	setDir(turn(dir, -45))
	to_chat(user, span_notice("You rotate [src]."))


/obj/machinery/conveyor/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume) || (stat & BROKEN))
		return .
	flipped = !flipped
	update_move_direction()
	to_chat(user, span_notice("You flip [src]'s belt [flipped ? "around" : "back to normal"]."))


/obj/machinery/conveyor/wirecutter_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume) || (stat & BROKEN))
		return .
	inverted = !inverted
	update_move_direction()
	to_chat(user, span_notice("You set [src]'s direction [inverted ? "backwards" : "back to default"]."))


/obj/machinery/conveyor/multitool_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume) || !user.client || !COOLDOWN_FINISHED(src, multitool_cooldown))
		return .
	COOLDOWN_START(src, multitool_cooldown, 1 SECONDS)
	if(!id)
		to_chat(user, span_warning("This conveyor is not linked to any switch."))
		return .
	var/list/user_view = view(user.client)
	var/list/clients = list(user.client)
	var/switch_found = FALSE
	for(var/obj/machinery/conveyor_switch/belt_switch in GLOB.conveyors_by_id[id])
		if(!(belt_switch in user_view))
			continue
		switch_found = TRUE
		var/image/arrow = image('icons/mob/screen_gen.dmi', loc, "arrow", POINT_LAYER)
		SET_PLANE(arrow, GAME_PLANE, loc)
		flick_overlay(arrow, clients, 2.5 SECONDS)
		animate(arrow, pixel_x = (belt_switch.x - x) * world.icon_size + belt_switch.pixel_x, pixel_y = (belt_switch.y - y) * world.icon_size + belt_switch.pixel_y, time = 0.5 SECONDS, easing = QUAD_EASING)	// yonked from point code
	if(!switch_found)
		to_chat(user, span_warning("This conveyor is linked to the switch out of your current view."))


/obj/machinery/conveyor/proc/build_neighbors()
	//This is acceptable because conveyor belts only move sometimes. Otherwise would be n^2 insanity
	var/turf/our_turf = get_turf(src)
	for(var/direction in GLOB.cardinal)
		var/turf/new_turf = get_step(our_turf, direction)
		var/obj/machinery/conveyor/valid = locate(/obj/machinery/conveyor) in new_turf
		if(QDELETED(valid))
			continue
		neighbors["[direction]"] = TRUE
		valid.neighbors["[REVERSE_DIR(direction)]"] = TRUE
		RegisterSignal(valid, COMSIG_MOVABLE_MOVED, PROC_REF(nearby_belt_changed), override=TRUE)
		RegisterSignal(valid, COMSIG_QDELETING, PROC_REF(nearby_belt_changed), override=TRUE)
		valid.RegisterSignal(src, COMSIG_MOVABLE_MOVED, PROC_REF(nearby_belt_changed), override=TRUE)
		valid.RegisterSignal(src, COMSIG_QDELETING, PROC_REF(nearby_belt_changed), override=TRUE)


/obj/machinery/conveyor/proc/nearby_belt_changed(datum/source)
	SIGNAL_HANDLER

	neighbors = list()
	build_neighbors()


/// Proc to handle updating the directions in which the conveyor belt is moving items.
/obj/machinery/conveyor/proc/update_move_direction()
	switch(dir)
		if(NORTH)
			forwards = NORTH
			backwards = SOUTH
		if(SOUTH)
			forwards = SOUTH
			backwards = NORTH
		if(EAST)
			forwards = EAST
			backwards = WEST
		if(WEST)
			forwards = WEST
			backwards = EAST
		if(NORTHEAST)
			forwards = EAST
			backwards = SOUTH
		if(NORTHWEST)
			forwards = NORTH
			backwards = EAST
		if(SOUTHEAST)
			forwards = SOUTH
			backwards = WEST
		if(SOUTHWEST)
			forwards = WEST
			backwards = NORTH

	if(inverted)
		var/temp = forwards
		forwards = backwards
		backwards = temp
	// We need to do this this way to ensure good functionality on corner belts.
	// Basically, this allows the conveyor belts that used a flipped belt sprite to
	// still convey items in the direction of their arrows. It's different from inverted,
	// which makes them go backwards so they need to be ran separately, so a flipped conveyor
	// can also be reversed.
	if(flipped)
		var/temp = forwards
		forwards = backwards
		backwards = temp
	if(operating == CONVEYOR_FORWARD)
		movedir = forwards
	else
		movedir = backwards
	update()


/obj/machinery/conveyor/proc/set_operating(new_value)
	if(operating == new_value)
		return
	operating = new_value
	update_appearance()
	update_move_direction()
	//If we ever turn off, disable moveloops
	if(operating == CONVEYOR_OFF)
		for(var/atom/movable/movable in get_turf(src))
			stop_conveying(movable)


/obj/machinery/conveyor/proc/update()
	if(stat & (NOPOWER|BROKEN))
		set_operating(FALSE)
		return FALSE

	update_appearance()
	// If we're on, start conveying so moveloops on our tile can be refreshed if they stopped for some reason
	if(operating != CONVEYOR_OFF)
		for(var/atom/movable/movable in get_turf(src))
			start_conveying(movable)
	return TRUE


/obj/machinery/conveyor/proc/conveyable_enter(datum/source, atom/movable/conveyable)
	SIGNAL_HANDLER

	if(operating == CONVEYOR_OFF)
		SSmove_manager.stop_looping(conveyable, SSconveyors)
		return
	start_conveying(conveyable)


/obj/machinery/conveyor/proc/conveyable_exit(datum/source, atom/movable/conveyable, atom/newLoc)
	SIGNAL_HANDLER

	var/direction = get_dir(loc, newLoc)
	var/has_conveyor = neighbors["[direction]"]
	if(conveyable.z != z || !has_conveyor || !isturf(conveyable.loc)) //If you've entered something on us, stop moving
		SSmove_manager.stop_looping(conveyable, SSconveyors)


/obj/machinery/conveyor/proc/start_conveying(atom/movable/moving)
	if(QDELETED(moving))
		return
	var/datum/move_loop/move/moving_loop = SSmove_manager.processing_on(moving, SSconveyors)
	if(moving_loop)
		moving_loop.direction = movedir
		moving_loop.delay = speed
		return

	var/static/list/unconveyables = typecacheof(list(/obj/effect, /mob/dead))
	if(!istype(moving) || is_type_in_typecache(moving, unconveyables) || moving == src)
		return
	moving.AddComponent(/datum/component/convey, movedir, speed)


/obj/machinery/conveyor/proc/stop_conveying(atom/movable/thing)
	if(!ismovable(thing))
		return
	SSmove_manager.stop_looping(thing, SSconveyors)


// subtypes

/obj/machinery/conveyor/inverted //Directions inverted so you can use different corner pieces.
	icon_state = "conveyor_map_inverted"
	flipped = TRUE


/obj/machinery/conveyor/inverted/Initialize(mapload)
	. = ..()
	if(mapload && !ISDIAGONALDIR(dir))
		log_world("### MAP WARNING, [src] at [AREACOORD(src)] spawned without using a diagonal dir. Please replace with a normal version.")


// Auto conveyor is always on unless unpowered.
/obj/machinery/conveyor/auto


/obj/machinery/conveyor/auto/Initialize(mapload, new_dir, new_id)
	. = ..()
	set_operating(TRUE)


/obj/machinery/conveyor/auto/update()
	. = ..()
	if(.)
		set_operating(TRUE)


/obj/machinery/conveyor/auto/inverted
	icon_state = "conveyor_map_inverted"
	flipped = TRUE


/obj/machinery/conveyor/auto/inverted/Initialize(mapload)
	. = ..()
	if(mapload && !ISDIAGONALDIR(dir))
		log_world("### MAP WARNING, [src] at [AREACOORD(src)] spawned without using a diagonal dir. Please replace with a normal version.")


// the conveyor control switch

/obj/machinery/conveyor_switch
	name = "conveyor switch"
	desc = "A conveyor control switch."
	icon = 'icons/obj/machines/recycling.dmi'
	icon_state = "switch-off"
	base_icon_state = "switch"
	processing_flags = START_PROCESSING_MANUALLY
	anchored = TRUE
	/// The current state of the switch.
	var/position = CONVEYOR_OFF
	/// If the switch only operates the conveyor belts in a single direction.
	var/one_way = FALSE
	/// If the lever points the opposite direction when it's turned on.
	var/invert_icon = FALSE
	/// The ID of the switch, must match conveyor IDs to control them.
	var/id = ""
	/// Current set time between movements of the conveyor belts
	var/conveyor_speed = 0.3 SECONDS
	/// Minimum speed delay this switch can provide to linked conveyors
	var/conveyor_min_speed = 0.3 SECONDS
	/// Maximum speed delay this switch can provide to linked conveyors
	var/conveyor_max_speed = 3 SECONDS


/obj/machinery/conveyor_switch/Initialize(mapload, new_id)
	. = ..()
	if(new_id)
		id = new_id
	update_appearance()
	LAZYADD(GLOB.conveyors_by_id[id], src)


/obj/machinery/conveyor_switch/Destroy()
	LAZYREMOVE(GLOB.conveyors_by_id[id], src)
	return ..()


/obj/machinery/conveyor_switch/vv_edit_var(var_name, var_value)
	if(var_name == NAMEOF(src, id))
		// if "id" is varedited, update our list membership
		LAZYREMOVE(GLOB.conveyors_by_id[id], src)
		. = ..()
		LAZYADD(GLOB.conveyors_by_id[id], src)
	else
		return ..()


/obj/machinery/conveyor_switch/update_icon_state()
	icon_state = "[base_icon_state]-off"
	if(position > CONVEYOR_OFF)
		icon_state = "[base_icon_state]-[invert_icon ? "rev" : "fwd"]"
	else if(position < CONVEYOR_OFF)
		icon_state = "[base_icon_state]-[invert_icon ? "fwd" : "rev"]"


/obj/machinery/conveyor_switch/update_overlays()
	. = ..()
	if(stat & NOPOWER)
		return .
	if(position > CONVEYOR_OFF)
		. += "greenlight"
	else if(position < CONVEYOR_OFF)
		. += "redlight"


/// Updates all conveyor belts that are linked to this switch, and tells them to start processing.
/obj/machinery/conveyor_switch/proc/update_linked_conveyors()
	for(var/obj/machinery/conveyor/belt in GLOB.conveyors_by_id[id])
		belt.set_operating(position)
		belt.speed = conveyor_speed
		CHECK_TICK


/// Finds any switches with same `id` as this one, and set their position and icon to match us.
/obj/machinery/conveyor_switch/proc/update_linked_switches()
	for(var/obj/machinery/conveyor_switch/belt_switch in GLOB.conveyors_by_id[id])
		belt_switch.invert_icon = invert_icon
		belt_switch.position = position
		belt_switch.conveyor_speed = conveyor_speed
		belt_switch.update_appearance()
		CHECK_TICK


/// Updates the switch's `position` and `last_pos` variable. Useful so that the switch can properly cycle between the forwards, backwards and neutral positions.
/obj/machinery/conveyor_switch/proc/update_position(direction)
	if(position == CONVEYOR_OFF)
		if(one_way)   //is it a one way switch
			position = one_way
		else
			if(direction == CONVEYOR_FORWARD)
				position = CONVEYOR_FORWARD
			else
				position = CONVEYOR_BACKWARDS
	else
		position = CONVEYOR_OFF


/obj/machinery/conveyor_switch/proc/on_user_activation(mob/user, direction)
	add_fingerprint(user)
	if(stat & NOPOWER)
		to_chat(user, span_warning("Switch is unpowered."))
		return
	if(!allowed(user) && !user.can_advanced_admin_interact()) //this is in Para but not TG. I don't think there's any which are set anyway.
		to_chat(user, span_warning("Access denied."))
		return
	update_position(direction)
	update_appearance()
	update_linked_conveyors()
	update_linked_switches()


/obj/machinery/conveyor_switch/examine(mob/user)
	. = ..()
	. += span_notice("[src] is set to <b>[invert_icon ? "inverted": "normal"]</b> position. It can be rotated with a <b>wrench</b>.")
	. += span_notice("[src] is set to <b>[one_way ? "one way" : "default"]</b> configuration. It can be changed with a <b>multitool</b>")
	. += span_notice("[src] is set to move <b>[conveyor_speed / 10]</b> seconds per belt. It can be changed with a <b>multitool</b>")
	. += span_info("<b>Left-Click</b> to toggle forwards, <b>Alt-Click</b> to toggle backwards.")
	. += span_info("Use a <b>crowbar</b> to dislodge.")


/obj/machinery/conveyor_switch/AltClick(mob/user)
	if(Adjacent(user))
		on_user_activation(user, CONVEYOR_BACKWARDS)


/obj/machinery/conveyor_switch/attack_robot(mob/user)
	if(Adjacent(user))
		on_user_activation(user, CONVEYOR_FORWARD)


/obj/machinery/conveyor_switch/attack_hand(mob/user)
	. = ..()
	if(.)
		return .
	on_user_activation(user, CONVEYOR_FORWARD)


/obj/machinery/conveyor_switch/attack_ghost(mob/user)
	if(user.can_advanced_admin_interact())
		on_user_activation(user, CONVEYOR_FORWARD)


/obj/machinery/conveyor_switch/crowbar_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume) || (stat & NOPOWER))
		return .
	var/obj/item/conveyor_switch_construct/switch_construct = new(loc, id)
	transfer_fingerprints_to(switch_construct)
	to_chat(user, span_notice("You detach [src]."))
	qdel(src)


/obj/machinery/conveyor_switch/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume) || (stat & NOPOWER))
		return .
	invert_icon = !invert_icon
	update_appearance()
	to_chat(user, span_notice("You set [src] to [invert_icon ? "inverted": "normal"] position."))


/obj/machinery/conveyor_switch/multitool_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume) || (stat & NOPOWER))
		return
	ui_interact(user)


/obj/machinery/conveyor_switch/ui_interact(mob/user, datum/tgui/ui = null)
	user.set_machine(src)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ConveyorSwitch", name)
		ui.open()


/obj/machinery/conveyor_switch/ui_data(mob/user)
	var/list/data = list(
		"slowFactor" = conveyor_speed / 10,
		"minSpeed" = conveyor_min_speed / 10,
		"maxSpeed" = conveyor_max_speed / 10,
		"oneWay" = one_way,
		"position" = position
	)
	return data


/obj/machinery/conveyor_switch/ui_act(action, list/params)
	if(..() || (stat & NOPOWER))
		return

	switch(action)
		if("slowFactor")
			conveyor_speed = clamp(round(text2num(params["value"]), 0.1) SECONDS, conveyor_min_speed, conveyor_max_speed)
			to_chat(usr, span_notice("You change the time between moves to [conveyor_speed / 10] seconds."))
		if("toggleOneWay")
			one_way = !one_way
			to_chat(usr, span_notice("You set [src] to [one_way ? "one way" : "default"] configuration."))

	update_appearance()
	update_linked_conveyors()
	update_linked_switches()
	return TRUE


/obj/machinery/conveyor_switch/power_change(forced = FALSE)
	if(!..())
		return
	update_appearance()


// subtypes

/obj/machinery/conveyor_switch/oneway
	icon_state = "conveyor_switch_oneway"
	desc = "A conveyor control switch. It appears to only go in one direction."
	one_way = TRUE


/obj/machinery/conveyor_switch/oneway/Initialize(mapload, new_id)
	. = ..()
	if(dir == NORTH || dir == WEST)
		invert_icon = TRUE


// CONVEYOR CONSTRUCTION STARTS HERE

/obj/item/conveyor_construct
	icon = 'icons/obj/machines/recycling.dmi'
	icon_state = "conveyor_construct"
	name = "conveyor belt assembly"
	desc = "A conveyor belt assembly, used for the assembly of conveyor belt systems."
	w_class = WEIGHT_CLASS_BULKY
	/// ID for linking a belt to one or more switches, all conveyors with the same ID will be controlled the same switch(es).
	var/id = ""


/obj/item/conveyor_construct/Initialize(mapload, new_id)
	. = ..()
	if(new_id)
		id = new_id


/obj/item/conveyor_construct/examine(mob/user)
	. = ..()
	. += span_notice("<b>Use</b> the assembly on the ground to finalize it.")
	. += span_notice("Use a <b>conveyor belt switch</b> on the assembly to link them.")


/obj/item/conveyor_construct/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/conveyor_switch_construct))
		add_fingerprint(user)
		var/obj/item/conveyor_switch_construct/switch_construct = I
		to_chat(user, span_notice("You link [src] to [switch_construct]."))
		id = switch_construct.id
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()



/obj/item/conveyor_construct/afterattack(turf/interacting_with, mob/user, proximity, params)
	if(!proximity)
		return
	if(user.incapacitated())
		return
	if(!isfloorturf(interacting_with))
		return
	if(interacting_with == user.loc)
		to_chat(user, span_warning("You cannot place [src] under yourself."))
		return
	if(locate(/obj/machinery/conveyor) in interacting_with) //Can't put conveyors beneath conveyors
		to_chat(user, span_warning("There's already a conveyor there!"))
		return
	var/obj/machinery/conveyor/conveyor = new(interacting_with, user.dir, id)
	transfer_fingerprints_to(conveyor)
	qdel(src)


/obj/item/conveyor_switch_construct
	name = "conveyor switch assembly"
	desc = "A conveyor control switch assembly. When set up, it'll control any and all conveyor belts it is linked to."
	icon = 'icons/obj/machines/recycling.dmi'
	icon_state = "switch-off"
	w_class = WEIGHT_CLASS_BULKY
	/// ID of the switch-in-the-making, to link conveyor belts to it.
	var/id = ""


/obj/item/conveyor_switch_construct/Initialize(mapload, new_id)
	. = ..()
	if(new_id)
		id = new_id
	else
		id = "[world.time + rand()]" //this couldn't possibly go wrong


/obj/item/conveyor_switch_construct/examine(mob/user)
	. = ..()
	. += span_info("<b>Use</b> it on a section of conveyor belt or conveyor placer to link them together.")
	. += span_info("<b>Use</b> the assembly on the ground to finalize it.")


/obj/item/conveyor_switch_construct/afterattack(turf/interacting_with, mob/user, proximity, params)
	if(!proximity)
		return
	if(user.incapacitated())
		return
	if(!isfloorturf(interacting_with))
		return
	var/found = FALSE
	for(var/obj/machinery/conveyor/belt in view())
		if(belt.id == id)
			found = TRUE
			break
	if(!found)
		to_chat(user, span_notice("The conveyor switch did not detect any linked conveyor belts in range."))
		return
	var/obj/machinery/conveyor_switch/built_switch = new(interacting_with, id)
	transfer_fingerprints_to(built_switch)
	qdel(src)


/obj/item/conveyor_switch_construct/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/conveyor_switch_construct))
		add_fingerprint(user)
		var/obj/item/conveyor_switch_construct/switch_construct = I
		to_chat(user, span_notice("You link the two switch constructs."))
		id = switch_construct.id
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()


/obj/item/paper/conveyor
	name = "paper- 'Nano-it-up U-build series, #9: Build your very own conveyor belt, in SPACE'"
	info = "<h1>Congratulations!</h1><p>You are now the proud owner of the best conveyor set available for space mail order! \
	We at Nano-it-up know you love to prepare your own structures without wasting time, so we have devised a special streamlined \
	assembly procedure that puts all other mail-order products to shame!</p>\
	<p>Firstly, you need to link the conveyor switch assembly to each of the conveyor belt assemblies. After doing so, you simply need to install the belt \
	assemblies onto the floor, et voila, belt built. Our special Nano-it-up smart switch will detected any linked assemblies as far as the eye can see! </p>\
	<p> Set single directional switches by using your multitool on the switch after you've installed the switch assembly.</p>\
	<p> This convenience, you can only have it when you Nano-it-up. Stay nano!</p>"


#undef CONVEYOR_BACKWARDS
#undef CONVEYOR_OFF
#undef CONVEYOR_FORWARD

