/*
Quick overview:

Pipes combine to form pipelines
Pipelines and other atmospheric objects combine to form pipe_networks
	Note: A single pipe_network represents a completely open space

Pipes -> Pipelines
Pipelines + Other Objects -> Pipe network
*/
/obj/machinery/atmospherics
	anchored = TRUE
	resistance_flags = FIRE_PROOF
	max_integrity = 200
	plane = GAME_PLANE
	idle_power_usage = 0
	active_power_usage = 0
	power_channel = ENVIRON
	on_blueprints = TRUE
	layer = GAS_PIPE_HIDDEN_LAYER  //under wires
	/// Generic over VISIBLE and HIDDEN, should be less than 0.01, or you'll reorder non-pipe things.
	var/layer_offset = 0.0
	/// Can this be unwrenched?
	var/can_unwrench = FALSE
	/// Can this be put under a tile?
	var/can_be_undertile = FALSE
	/// If the machine is currently operating or not.
	var/on = FALSE
	/// Whether its currently welded
	var/welded = FALSE
	/// The bitflag that's being checked on ventcrawling. Default is to allow ventcrawling and seeing pipes.
	var/vent_movement = VENTCRAWL_ALLOWED|VENTCRAWL_CAN_SEE

	// Vars below this point are all pipe related
	// I know not all subtypes are pipes, but this helps

	/// Type of pipes this machine can connect to
	var/list/connect_types = list(CONNECT_TYPE_NORMAL)
	/// What this machine is connected to
	var/connected_to = CONNECT_TYPE_NORMAL
	/// Icon suffix for connection, can be "-supply" or "-scrubbers"
	var/icon_connect_type = ""
	/// Directions to initialize in to grab pipes
	var/initialize_directions = 0
	/// Pipe colour, not used for all subtypes
	var/pipe_color
	/// The image of the pipe/device used for ventcrawling
	var/image/pipe_vision_img



/obj/machinery/atmospherics/New()
	if (!armor)
		armor = list("melee" = 25, "bullet" = 10, "laser" = 10, "energy" = 100, "bomb" = 0, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 70)
	..()

	if(!pipe_color)
		pipe_color = color
	color = null

	if(!pipe_color_check(pipe_color))
		pipe_color = null

/obj/machinery/atmospherics/Initialize()
	. = ..()
	SSair.atmos_machinery += src

/obj/machinery/atmospherics/proc/atmos_init()
	// Updates all pipe overlays and underlays
	update_underlays()


/obj/machinery/atmospherics/Destroy()
	SSair.atmos_machinery -= src
	SSair.deferred_pipenet_rebuilds -= src
	for(var/mob/living/mob in contents) //ventcrawling is serious business
		mob.stop_ventcrawling()
	QDEL_NULL(pipe_vision_img) //we have to qdel it, or it might keep a ref somewhere else
	return ..()


/obj/machinery/atmospherics/examine(mob/living/user)
	. = ..()
	if((vent_movement & VENTCRAWL_ENTRANCE_ALLOWED) && is_ventcrawler(user))
		. += span_info("Alt-click to crawl through it.")


/obj/machinery/atmospherics/set_frequency(new_frequency)
	SSradio.remove_object(src, frequency)
	frequency = new_frequency
	if(frequency)
		radio_connection = SSradio.add_object(src, frequency, RADIO_ATMOSIA)

// Icons/overlays/underlays
/obj/machinery/atmospherics/update_icon_state()
	switch(level)
		if(1)
			SET_PLANE_IMPLICIT(src, FLOOR_PLANE)
			layer = GAS_PIPE_HIDDEN_LAYER + layer_offset
		if(2)
			SET_PLANE_IMPLICIT(src, GAME_PLANE)
			layer = GAS_PIPE_VISIBLE_LAYER + layer_offset


/obj/machinery/atmospherics/proc/update_pipe_image()
	pipe_vision_img = image(src, loc = src.loc, layer = ABOVE_HUD_LAYER + src.layer, dir = src.dir)
	var/turf/T = get_turf(src)
	SET_PLANE_EXPLICIT(pipe_vision_img, PIPECRAWL_IMAGES_PLANE, T)


/obj/machinery/atmospherics/proc/check_icon_cache()
	if(!SSair.icon_manager)
		return FALSE
	return TRUE

/obj/machinery/atmospherics/proc/color_cache_name(var/obj/machinery/atmospherics/node)
	//Don't use this for standard pipes
	if(!istype(node))
		return null

	return node.pipe_color

/obj/machinery/atmospherics/proc/add_underlay(turf/T, obj/machinery/atmospherics/node, direction, icon_connect_type)
	if(node)
		if(T.intact && node.level == 1 && istype(node, /obj/machinery/atmospherics/pipe) && !T.transparent_floor)
			underlays += SSair.icon_manager.get_atmos_icon("underlay", direction, color_cache_name(node), "down" + icon_connect_type)
		else
			underlays += SSair.icon_manager.get_atmos_icon("underlay", direction, color_cache_name(node), "intact" + icon_connect_type)
	else
		if(T.transparent_floor) //we want to keep pipes under transparent floors connected normally
			underlays += SSair.icon_manager.get_atmos_icon("underlay", direction, color_cache_name(node), "intact" + icon_connect_type)
		else
			underlays += SSair.icon_manager.get_atmos_icon("underlay", direction, color_cache_name(node), "exposed" + icon_connect_type)

/obj/machinery/atmospherics/proc/update_underlays()
	return check_icon_cache()

// Connect types
/obj/machinery/atmospherics/proc/check_connect_types(obj/machinery/atmospherics/atmos1, obj/machinery/atmospherics/atmos2)
	var/list/list1 = atmos1.connect_types
	var/list/list2 = atmos2.connect_types
	for(var/i in 1 to length(list1))
		for(var/j in 1 to length(list2))
			if(list1[i] == list2[j])
				var/n = list1[i]
				return n
	return 0

/obj/machinery/atmospherics/proc/check_connect_types_construction(obj/machinery/atmospherics/atmos1, obj/item/pipe/pipe2)
	var/list/list1 = atmos1.connect_types
	var/list/list2 = pipe2.connect_types
	for(var/i in 1 to length(list1))
		for(var/j in 1 to length(list2))
			if(list1[i] == list2[j])
				var/n = list1[i]
				return n
	return 0

// Pipenet related functions
/obj/machinery/atmospherics/proc/returnPipenet()
	return


/**
 * Getter of a list of pipenets
 *
 * called in relaymove() to create the image for vent crawling
 */
/obj/machinery/atmospherics/proc/return_pipenets()
	return list()


/obj/machinery/atmospherics/proc/returnPipenetAir()
	return

/obj/machinery/atmospherics/proc/setPipenet()
	return

/obj/machinery/atmospherics/proc/replacePipenet()
	return

/obj/machinery/atmospherics/proc/build_network(remove_deferral = FALSE)
	// Called to build a network from this node
	if(remove_deferral)
		SSair.deferred_pipenet_rebuilds -= src

/obj/machinery/atmospherics/proc/defer_build_network()
	SSair.deferred_pipenet_rebuilds += src

/obj/machinery/atmospherics/proc/disconnect(obj/machinery/atmospherics/reference)
	return

/obj/machinery/atmospherics/proc/nullifyPipenet(datum/pipeline/P)
	if(P)
		P.other_atmosmch -= src


/obj/machinery/atmospherics/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	var/turf/our_turf = get_turf(src)
	if(!our_turf)
		return .
	if(level == 1 && (our_turf.transparent_floor == TURF_TRANSPARENT) && istype(src, /obj/machinery/atmospherics/pipe))
		to_chat(user, span_danger("You cannot interact with something that's under the floor!"))
		return .
	if(level == 1 && our_turf.intact)
		to_chat(user, span_danger("You must remove the plating first."))
		return .
	if(!can_unwrench)
		to_chat(user, span_warning("This machinery cannot be unwrenched."))
		return .
	if(!(stat & NOPOWER) && on)
		to_chat(user, span_warning("You cannot unwrench [src], turn it off first."))
		return .

	var/datum/gas_mixture/int_air = return_air()
	var/datum/gas_mixture/env_air = loc.return_air()

	var/unsafe_wrenching = FALSE
	var/internal_air = int_air ? int_air.return_pressure() : 0
	var/envire_air  = env_air ? env_air.return_pressure() : 0
	var/internal_pressure = internal_air - envire_air

	if(internal_pressure > 2 * ONE_ATMOSPHERE)
		to_chat(user, span_warning("As you begin unwrenching [src] a gust of air blows in your face... maybe you should reconsider?"))
		unsafe_wrenching = TRUE //Oh dear oh dear
	else
		to_chat(user, span_notice("You begin to unfasten [src]..."))

	if(!I.use_tool(src, user, 4 SECONDS, volume = I.tool_volume))
		return .

	user.visible_message(
		span_notice("[user] unfastens [src]."),
		span_notice("You have unfastened [src]."),
		span_italics("You hear ratcheting."),
	)
	investigate_log("was <span class='warning'>REMOVED</span> by [key_name_log(usr)]", INVESTIGATE_ATMOS)

	//You unwrenched a pipe full of pressure? let's splat you into the wall silly.
	if(unsafe_wrenching)
		if(HAS_TRAIT(user, TRAIT_GUSTPROTECTION))
			to_chat(user, span_italics("Your magboots cling to the floor as a great burst of wind bellows against you."))
		else
			unsafe_pressure_release(user, internal_pressure)

	deconstruct(TRUE)


/obj/machinery/atmospherics/attackby(obj/item/I, mob/user, params)
	var/turf/our_turf = get_turf(src)
	if(!our_turf)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(our_turf.transparent_floor == TURF_TRANSPARENT)
		to_chat(user, span_warning("You cannot interact with something that's under the floor!"))
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


//Called when an atmospherics object is unwrenched while having a large pressure difference
//with it's locs air contents.
/obj/machinery/atmospherics/proc/unsafe_pressure_release(mob/user, pressures)
	if(!user)
		return

	if(!pressures)
		var/datum/gas_mixture/int_air = return_air()
		var/datum/gas_mixture/env_air = loc.return_air()
		pressures = int_air.return_pressure() - env_air.return_pressure()

	var/fuck_you_dir = get_dir(src, user)
	var/turf/general_direction = get_edge_target_turf(user, fuck_you_dir)
	user.visible_message(span_danger("[user] is sent flying by pressure!"),span_userdanger("The pressure sends you flying!"))
	//Values based on 2*ONE_ATMOS (the unsafe pressure), resulting in 20 range and 4 speed
	user.throw_at(general_direction, pressures/10, pressures/50)

/obj/machinery/atmospherics/deconstruct(disassembled = TRUE)
	if(can_unwrench && !(obj_flags & NODECONSTRUCT))
		var/obj/item/pipe/stored = new(loc, null, null, src)
		if(!disassembled)
			stored.obj_integrity = stored.max_integrity * 0.5
		transfer_fingerprints_to(stored)
	..()

/obj/machinery/atmospherics/on_construction(D, P, C)
	if(C)
		color = C
	dir = D
	initialize_directions = P
	var/turf/T = loc
	if(!T.transparent_floor)
		level = (T.intact || !can_be_undertile) ? 2 : 1
	else
		level = 2

	update_icon(UPDATE_ICON_STATE)
	add_fingerprint(usr)
	if(!SSair.initialized) //If there's no atmos subsystem, we can't really initialize pipenets
		SSair.machinery_to_construct.Add(src)
		return
	initialize_atmos_network()

/obj/machinery/atmospherics/proc/initialize_atmos_network()
	atmos_init()
	var/list/nodes = pipeline_expansion()
	for(var/obj/machinery/atmospherics/A in nodes)
		A.atmos_init()
		A.addMember(src)
	build_network()


/**
 * Find a connecting /obj/machinery/atmospherics in specified direction, called by relaymove()
 * used by ventcrawling mobs to check if they can move inside a pipe in a specific direction
 * Arguments:
 * * direction - the direction we are checking against
 */
/obj/machinery/atmospherics/proc/find_connecting(direction)
	for(var/obj/machinery/atmospherics/target in get_step_multiz(src, direction))
		if(!(target.initialize_directions & get_dir(target, src)) && !istype(target, /obj/machinery/atmospherics/pipe/multiz))
			continue
		if(check_connect_types(target, src))
			return target


#define VENT_SOUND_DELAY (3 SECONDS)

/// Ventrcrawling
/obj/machinery/atmospherics/relaymove(mob/living/user, direction)
	if(!direction) //cant go this way.
		return

	if(user in buckled_mobs)// fixes buckle ventcrawl edgecase fuck bug
		return

	// We want to support holding two directions at once, so we do this
	var/obj/machinery/atmospherics/target_move
	for(var/check_dir in GLOB.cardinals_multiz)
		if(!(direction & check_dir))
			continue
		var/obj/machinery/atmospherics/temp_target = find_connecting(check_dir)
		if(!temp_target)
			continue
		target_move = temp_target
		// If you're at a fork with two directions held, we will always prefer the direction you didn't last use
		// This way if you find a direction you've not used before, you take it, and if you don't, you take the other
		if(user.last_vent_dir == check_dir)
			continue
		user.last_vent_dir = check_dir
		break

	if(!target_move)
		if(direction & initialize_directions)
			user.stop_ventcrawling()
		return

	if(!(target_move.vent_movement & VENTCRAWL_ALLOWED))
		return

	user.abstract_move(target_move)
	// user.loc = target_move	// we are using loc change instead of forceMove to avoid perspective reset. paradise is special

	var/list/pipenetdiff = return_pipenets() ^ target_move.return_pipenets()
	if(length(pipenetdiff))
		user.update_pipe_vision()

	if(world.time - user.last_played_vent > VENT_SOUND_DELAY)
		user.last_played_vent = world.time
		playsound(src, 'sound/machines/ventcrawl.ogg', 50, TRUE, -3)

	//Would be great if this could be implemented when someone alt-clicks the image.
	if(target_move.vent_movement & VENTCRAWL_ENTRANCE_ALLOWED)
		INVOKE_ASYNC(user, TYPE_PROC_REF(/mob/living, handle_ventcrawl), target_move)

	var/client/our_client = user.client
	if(!our_client)
		return

	our_client.set_eye(target_move)
	// Let's smooth out that movement with an animate yeah?
	// If the new x is greater (move is left to right) we get a negative offset. vis versa
	our_client.pixel_x = (x - target_move.x) * world.icon_size
	our_client.pixel_y = (y - target_move.y) * world.icon_size
	animate(our_client, pixel_x = 0, pixel_y = 0, time = 0.03 SECONDS)
	our_client.move_delay = world.time + 0.03 SECONDS

#undef VENT_SOUND_DELAY


/obj/machinery/atmospherics/AltClick(mob/living/user)
	if((vent_movement & VENTCRAWL_ALLOWED) && istype(user))
		user.handle_ventcrawl(src)
		return
	return ..()


/obj/machinery/atmospherics/proc/change_color(new_color)
	//only pass valid pipe colors please ~otherwise your pipe will turn invisible
	if(!pipe_color_check(new_color))
		return

	pipe_color = new_color
	update_icon()

// Additional icon procs
/obj/machinery/atmospherics/proc/universal_underlays(obj/machinery/atmospherics/node, direction)
	var/turf/T = get_turf(src)
	if(!istype(T))
		return
	if(node)
		var/node_dir = get_dir(src,node)
		if(node.icon_connect_type == "-supply")
			add_underlay_adapter(T, , node_dir, "")
			add_underlay_adapter(T, node, node_dir, "-supply")
			add_underlay_adapter(T, , node_dir, "-scrubbers")
		else if(node.icon_connect_type == "-scrubbers")
			add_underlay_adapter(T, , node_dir, "")
			add_underlay_adapter(T, , node_dir, "-supply")
			add_underlay_adapter(T, node, node_dir, "-scrubbers")
		else
			add_underlay_adapter(T, node, node_dir, "")
			add_underlay_adapter(T, , node_dir, "-supply")
			add_underlay_adapter(T, , node_dir, "-scrubbers")
	else
		add_underlay_adapter(T, , direction, "-supply")
		add_underlay_adapter(T, , direction, "-scrubbers")
		add_underlay_adapter(T, , direction, "")

/obj/machinery/atmospherics/proc/add_underlay_adapter(turf/T, obj/machinery/atmospherics/node, direction, icon_connect_type) //modified from add_underlay, does not make exposed underlays
	if(node)
		if(T.intact && node.level == 1 && istype(node, /obj/machinery/atmospherics/pipe) && !T.transparent_floor)
			underlays += SSair.icon_manager.get_atmos_icon("underlay", direction, color_cache_name(node), "down" + icon_connect_type)
		else
			underlays += SSair.icon_manager.get_atmos_icon("underlay", direction, color_cache_name(node), "intact" + icon_connect_type)
	else
		if(T.transparent_floor) //we want to keep pipes under transparent floors connected normally
			underlays += SSair.icon_manager.get_atmos_icon("underlay", direction, color_cache_name(node), "intact" + icon_connect_type)
		else
			underlays += SSair.icon_manager.get_atmos_icon("underlay", direction, color_cache_name(node), "retracted" + icon_connect_type)

/obj/machinery/atmospherics/singularity_pull(S, current_size)
	if(current_size >= STAGE_FIVE)
		deconstruct(FALSE)
	return ..()

/obj/machinery/atmospherics/update_remote_sight(mob/user)
	user.add_sight(SEE_TURFS|BLIND)
	. = ..()

//Used for certain children of obj/machinery/atmospherics to not show pipe vision when mob is inside it.
/obj/machinery/atmospherics/proc/can_see_pipes()
	return TRUE


/**
 * Turns the machine either on, or off. If this is done by a user, display a message to them.
 *
 * NOTE: Only applies to atmospherics machines which can be toggled on or off, such as pumps, or other devices.
 *
 * Arguments:
 * * user - the mob who is toggling the machine.
 */
/obj/machinery/atmospherics/proc/toggle(mob/living/user)
	if(!powered())
		return
	on = !on
	update_icon()
	if(user)
		to_chat(user, span_notice("You toggle [src] [on ? "on" : "off"]."))


/obj/machinery/atmospherics/proc/set_welded(new_value)
	if(welded == new_value)
		return

	. = welded
	welded = new_value
	update_icon()
	update_pipe_image()

