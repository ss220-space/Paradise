GLOBAL_LIST_INIT(wire_node_generating_types, typecacheof(list(
	/obj/structure/grille,
	/obj/structure/fence,
	/obj/machinery/atmospherics/miner,
)))

/**
 * # Cable directions (d1 and d2)
 *
 * 9   1   5
 *   \ | /
 * 8 - 0 - 4
 *   / | \
 * 10  2   6
 *
 * If d1 = 0 and d2 = 0, there's no cable
 * If d1 = 0 and d2 = dir, it's a O-X cable, getting from the center of the tile to dir (knot cable)
 * If d1 = dir1 and d2 = dir2, it's a full X-X cable, getting from dir1 to dir2
 * By design, d1 is the smallest direction and d2 is the highest
 */

/**
 * # /obj/structure/cable
 *
 * The red wire thingies you see on the ground all over the station in maintenance
 * the d1 and d2 vars deal with the "directions" of the cables, since all instances of this cable structure are
 * just lines, they have two endpoints (d1 and d2).
 */
/obj/structure/cable
	level = 1
	anchored = TRUE
	on_blueprints = TRUE
	name = "power cable"
	desc = "A flexible superconducting cable for heavy-duty power transfer"
	icon = 'icons/obj/engines_and_power/power_cond/power_cond_white.dmi'
	icon_state = "node_all" // icon for mappers
	layer = WIRE_LAYER //Just below unary stuff, which is at 2.45 and above pipes, which are at 2.4
	color = CABLE_HEX_COLOR_RED
	var/node = FALSE
	var/cable_color = CABLE_COLOR_RED
	var/linked_dirs = NONE
	var/cable_layer = CABLE_LAYER_2
	var/datum/powernet/powernet
	/// Dir bitflags in which we cannot connect due to being cut
	var/banned_links = NONE


/obj/structure/cable/layer1
	color = CABLE_HEX_COLOR_YELLOW
	cable_color = CABLE_COLOR_YELLOW
	cable_layer = CABLE_LAYER_1
	layer = WIRE_LAYER - 0.01
	icon_state = "node_all1"

/obj/structure/cable/layer3
	color = CABLE_HEX_COLOR_BLUE
	cable_color = CABLE_COLOR_BLUE
	cable_layer = CABLE_LAYER_3
	layer = WIRE_LAYER + 0.01
	icon_state = "node_all3"

/obj/structure/cable/yellow
	color = CABLE_HEX_COLOR_YELLOW

/obj/structure/cable/green
	color = CABLE_HEX_COLOR_GREEN

/obj/structure/cable/blue
	color = CABLE_HEX_COLOR_BLUE

/obj/structure/cable/pink
	color = CABLE_HEX_COLOR_PINK

/obj/structure/cable/orange
	color = CABLE_HEX_COLOR_ORANGE

/obj/structure/cable/cyan
	color = CABLE_HEX_COLOR_CYAN

/obj/structure/cable/white
	color = CABLE_HEX_COLOR_WHITE



/obj/structure/cable/Initialize(mapload)
	. = ..()
	if(cable_layer < CABLE_LAYER_2)
		src.transform = TRANSLATE_MATRIX(4, 4)
	else if(cable_layer > CABLE_LAYER_2)
		src.transform = TRANSLATE_MATRIX(-4, -4)
	connect_cable()
	LAZYADD(GLOB.cable_list, src) //add it to the global cable list
	AddElement(/datum/element/undertile)

/obj/structure/cable/LateInitialize()
	node = check_nodeness()
	update_appearance(UPDATE_ICON|UPDATE_OVERLAYS)

/obj/structure/cable/proc/check_nodeness()
	node = !!banned_links
	if(!node)
		for(var/obj/connector in loc)
			if(GLOB.wire_node_generating_types[connector.type])
				node = TRUE
				break
			if(!istype(connector, /obj/machinery/power))
				continue
			var/obj/machinery/power/power_node = connector
			if(power_node.should_have_node())
				node = TRUE
				break
	return node

/obj/structure/cable/Destroy()
	disconnect_cable()

	if(powernet)
		cut_cable_from_powernet()				// update the powernets
	LAZYREMOVE(GLOB.cable_list, src)
	return ..()

/obj/structure/cable/deconstruct(disassembled = TRUE)
	var/turf/T = get_turf(src)
	if(usr)
		investigate_log("was deconstructed by [key_name_log(usr)] at [COORD(T)]", INVESTIGATE_WIRES)
	if(!(obj_flags & NODECONSTRUCT))
		new/obj/item/stack/cable_coil(T, 1, TRUE, cable_color)
	qdel(src)

///////////////////////////////////
// General procedures
///////////////////////////////////

/obj/structure/cable/update_icon_state()
	if(!linked_dirs)
		icon_state = "circle"
	else if(banned_links == ALL)
		icon_state = "why do this- ill render something but why"
	else
		icon_state = "node"

/obj/structure/cable/update_overlays()
	. = ..()
	var/list/cable_list = get_dir_strings(linked_dirs, node)
	if(!cable_list)
		return
	for(var/overlay_state in cable_list)
		. += "0-[overlay_state]"

/obj/structure/cable/proc/get_dir_string(links)
	if(!links)
		return "l[cable_layer]-noconnection"

	var/list/dir_icon_list = get_dir_strings(links)

	var/dir_string = dir_icon_list.Join("-")
	if(length(dir_icon_list) == 1 || !node)
		return "l[cable_layer]-[dir_string]"
	return "l[cable_layer]-[dir_string]-node"

/obj/structure/cable/proc/get_dir_strings(links)
	if(!links)
		return FALSE

	var/list/dir_icon_list = list()
	for(var/check_dir in CABLE_DIRECTIONS)
		if(links & check_dir)
			dir_icon_list += "[check_dir]"

	return dir_icon_list


////////////////////////////////////////////
// Power related
///////////////////////////////////////////

// All power generation handled in add_avail()
// Machines should use add_load(), surplus(), avail()
// Non-machines should use add_delayedload(), delayed_surplus(), newavail()

/obj/structure/cable/proc/add_avail(amount)
	if(powernet)
		powernet.newavail += amount

/obj/structure/cable/proc/add_load(amount)
	if(powernet)
		powernet.load += amount

/obj/structure/cable/proc/surplus()
	if(powernet)
		return clamp(powernet.avail-powernet.load, 0, powernet.avail)
	else
		return 0

/obj/structure/cable/proc/avail()
	if(powernet)
		return powernet.avail
	else
		return 0

/obj/structure/cable/proc/add_delayedload(amount)
	if(powernet)
		powernet.delayedload += amount

/obj/structure/cable/proc/delayed_surplus()
	if(powernet)
		return clamp(powernet.newavail - powernet.delayedload, 0, powernet.newavail)
	else
		return 0

/obj/structure/cable/proc/newavail()
	if(powernet)
		return powernet.newavail
	else
		return 0

//Telekinesis has no effect on a cable
/obj/structure/cable/attack_tk(mob/user)
	return

/obj/structure/cable/attackby(obj/item/I, mob/user, list/modifiers)
	var/turf/our_turf = get_turf(src)
	if(!our_turf)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(HAS_TRAIT(src, TRAIT_UNDERFLOOR))
		to_chat(user, span_danger("You cannot interact with something that's under the floor!"))
		return ATTACK_CHAIN_BLOCKED_ALL
/*
	if(iscoil(I))
		add_fingerprint(user)
		var/obj/item/stack/cable_coil/coil = I
		if(coil.get_amount() < 1)
			to_chat(user, span_warning("Not enough cable!"))
			return ATTACK_CHAIN_PROCEED
		coil.cable_join(src, user)
		return ATTACK_CHAIN_BLOCKED_ALL
*/
	if(istype(I, /obj/item/twohanded/rcl))
		add_fingerprint(user)
		var/obj/item/twohanded/rcl/rcl = I
		if(!rcl.loaded)
			to_chat(user, span_warning("The [rcl.name] has no cable!"))
			return ATTACK_CHAIN_PROCEED/*
		rcl.loaded.cable_join(src, user)*/
		rcl.is_empty(user)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(iscrayon(I))
		add_fingerprint(user)
		var/obj/item/toy/crayon/crayon = I
		cable_color(crayon.colourName)
		return ATTACK_CHAIN_PROCEED

	if((I.flags & CONDUCT) && shock(user, 50, 0.7))
		add_fingerprint(user)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()

/obj/structure/cable/multitool_act(mob/user, obj/item/I)
	. = TRUE
	if(HAS_TRAIT(src, TRAIT_UNDERFLOOR))
		return
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	to_chat(user, generate_power_message())
	shock(user, 5, 0.2)

/obj/structure/cable/proc/generate_power_message()
	if(powernet && (powernet.avail > 0))
		return boxed_message(span_notice("Total power: [display_power(powernet.avail)]\nLoad: [display_power(powernet.load)]\nSurplus: [display_power(surplus())]"))
	else
		return span_warning("The cable is not powered.")

/obj/structure/cable/examine(mob/user)
	. = ..()
	if(isobserver(user))
		. += generate_power_message()

/obj/structure/cable/wirecutter_act(mob/user, obj/item/I)
	. = TRUE
	var/turf/T = get_turf(src)
	if(HAS_TRAIT(src, TRAIT_UNDERFLOOR))
		to_chat(user, span_danger("You can't interact with something that's under the floor!"))
		return
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(shock(user, 50))
		return
	user.visible_message("[user] cuts the cable.", span_notice("You cut the cable."))
	investigate_log("was cut by [key_name_log(usr)] at [COORD(T)]", INVESTIGATE_WIRES)
	deconstruct()

// shock the user with probability prb
/obj/structure/cable/proc/shock(mob/user, prb, siemens_coeff = 1)
	CALCULATE_SKILL_MOD(user, ELECTRICITY_NEGATIVE_CHANCE_MOD, prob_mod)
	if(!prob(prb * prob_mod))
		return FALSE
	if(electrocute_mob(user, powernet, src, siemens_coeff))
		do_sparks(5, TRUE, src)
		return TRUE
	else
		return FALSE

/obj/structure/cable/singularity_pull(atom/singularity, current_size)
	..()
	if(current_size < STAGE_FIVE)
		return
	deconstruct()

/obj/structure/cable/proc/cable_color(colorC)
	if(!colorC)
		color = CABLE_HEX_COLOR_RED
	else if(colorC == "rainbow")
		color = color_rainbow()
	else if(colorC == "orange") //byond only knows 16 colors by name, and orange isn't one of them
		color = CABLE_HEX_COLOR_ORANGE
	else
		color = colorC

/obj/structure/cable/proc/color_rainbow()
	color = pick(CABLE_HEX_COLOR_RED, CABLE_HEX_COLOR_BLUE, CABLE_HEX_COLOR_GREEN, CABLE_HEX_COLOR_PINK, CABLE_HEX_COLOR_YELLOW, CABLE_HEX_COLOR_CYAN)
	return color

/////////////////////////////////////////////////
// Cable laying helpers
////////////////////////////////////////////////

#define UNDER_SMES -1
#define UNDER_TERMINAL 1

///Set the linked indicator bitflags
/obj/structure/cable/proc/connect_cable(clear_before_updating = FALSE)
	var/under_thing = NONE
	if(clear_before_updating)
		linked_dirs = NONE

	var/obj/machinery/power/search_parent = locate(/obj/machinery/power/terminal) in loc
	if(!isnull(search_parent))
		under_thing = UNDER_TERMINAL
	else
		search_parent = locate(/obj/machinery/power/smes) in loc
		if(!isnull(search_parent))
			under_thing = UNDER_SMES

	for(var/check_dir in CABLE_DIRECTIONS)
		if(check_dir & banned_links)
			continue
		var/turf/step_turf = get_step(src, check_dir)
		//don't link from smes to its terminal
		if(under_thing)
			switch(under_thing)
				if(UNDER_SMES)
					var/obj/machinery/power/terminal/term = locate(/obj/machinery/power/terminal) in step_turf
					//Why null or equal to the search parent?
					//during map init it's possible for a placed smes terminal to not have initialized to the smes yet
					//but the cable underneath it is ready to link.
					//I don't believe null is even a valid state for a smes terminal while the game is actually running
					//So in the rare case that this happens, we also shouldn't connect
					//This might break.
					if(term && (!term.master || term.master == search_parent))
						continue

				if(UNDER_TERMINAL)
					var/obj/machinery/power/smes/S = locate(/obj/machinery/power/smes) in step_turf
					if(S && (!S.terminal || S.terminal == search_parent))
						continue

		var/inverse = REVERSE_DIR(check_dir)
		for(var/obj/structure/cable/other_cable in step_turf)
			if(!(other_cable.cable_layer & cable_layer) || (other_cable.banned_links & inverse))
				continue
			linked_dirs |= check_dir
			other_cable.linked_dirs |= inverse

			other_cable.update_appearance(UPDATE_ICON|UPDATE_OVERLAYS)

	update_appearance(UPDATE_ICON|UPDATE_OVERLAYS)

#undef UNDER_SMES
#undef UNDER_TERMINAL

///Clear the linked indicator bitflags
/obj/structure/cable/proc/disconnect_cable()
	for(var/check_dir in CABLE_DIRECTIONS)
		if(!(linked_dirs & check_dir))
			continue
		var/inverse = REVERSE_DIR(check_dir)
		var/turf/check_turf = get_step(loc, check_dir)
		for(var/obj/structure/cable/other_cable in check_turf)
			if(!(other_cable.cable_layer & cable_layer))
				continue
			other_cable.linked_dirs &= ~inverse
			other_cable.update_appearance()

// merge with the powernets of power objects in the given direction
/obj/structure/cable/proc/mergeConnectedNetworks(direction)

	var/inverse_dir = (!direction)? 0 : REVERSE_DIR(direction) //flip the direction, to match with the source position on its turf

	var/turf/TB = get_step(src, direction)

	for(var/obj/structure/cable/C in TB)
		if(!C)
			continue

		if(src == C)
			continue

		if(!(cable_layer & C.cable_layer))
			continue

		if(C.linked_dirs & inverse_dir) //we've got a matching cable in the neighbor turf
			if(!C.powernet) //if the matching cable somehow got no powernet, make him one (should not happen for cables)
				var/datum/powernet/newPN = new()
				newPN.add_cable(C)

			if(powernet) //if we already have a powernet, then merge the two powernets
				merge_powernets(powernet, C.powernet)
			else
				C.powernet.add_cable(src) //else, we simply connect to the matching cable powernet

// merge with the powernets of power objects in the source turf
/obj/structure/cable/proc/mergeConnectedNetworksOnTurf()
	var/list/to_connect = list()

	if(!powernet) //if we somehow have no powernet, make one (should not happen for cables)
		var/datum/powernet/newPN = new()
		newPN.add_cable(src)

	//first let's add turf cables to our powernet
	//then we'll connect machines on turf where a cable is present
	for(var/atom/movable/AM in loc)
		if(istype(AM, /obj/machinery/power/apc))
			var/obj/machinery/power/apc/N = AM
			if(!N.terminal)
				continue // APC are connected through their terminal

			if(N.terminal.powernet == powernet) //already connected
				continue

			to_connect += N.terminal //we'll connect the machines after all cables are merged

		else if(istype(AM, /obj/machinery/power)) //other power machines
			var/obj/machinery/power/M = AM

			if(M.powernet == powernet)
				continue

			to_connect += M //we'll connect the machines after all cables are merged

	//now that cables are done, let's connect found machines
	for(var/obj/machinery/power/PM in to_connect)
		if(!PM.connect_to_network())
			PM.disconnect_from_network() //if we somehow can't connect the machine to the new powernet, remove it from the old nonetheless

//////////////////////////////////////////////
// Powernets handling helpers
//////////////////////////////////////////////

//if powernetless_only = 1, will only get connections without powernet
/obj/structure/cable/proc/get_cable_connections(powernetless_only)
	. = list()
	var/turf/T = get_turf(src)
	for(var/check_dir in CABLE_DIRECTIONS)
		if(linked_dirs & check_dir)
			T = get_step(src, check_dir)
			for(var/obj/structure/cable/C in T)
				if(cable_layer & C.cable_layer)
					. += C

/obj/structure/cable/proc/get_machine_connections(powernetless_only)
	. = list()
	for(var/obj/machinery/power/P in get_turf(src))
		if(!powernetless_only || !P.powernet)
			if(P.anchored)
				. += P

/obj/structure/cable/proc/auto_propagate_cut_cable(obj/O)
	if(O && !QDELETED(O))
		var/datum/powernet/newPN = new()// creates a new powernet...
		propagate_network(O, newPN)//... and propagates it to the other side of the cable

//should be called after placing a cable which extends another cable, creating a "smooth" cable that no longer terminates in the centre of a turf.
//needed as this can, unlike other placements, disconnect cables
/obj/structure/cable/proc/denode()
	var/turf/T1 = loc
	if(!T1)
		return

	var/list/powerlist = power_list(T1,src,0,0) //find the other cables that ended in the centre of the turf, with or without a powernet
	if(length(powerlist)>0)
		var/datum/powernet/PN = new()
		propagate_network(powerlist[1],PN) //propagates the new powernet beginning at the source cable

		if(PN.is_empty()) //can happen with machines made nodeless when smoothing cables
			qdel(PN)

// cut the cable's powernet at this cable and updates the powergrid
/obj/structure/cable/proc/cut_cable_from_powernet(remove = TRUE)
	if(!powernet)
		return

	var/turf/T1 = loc
	if(!T1)
		return

	//clear the powernet of any machines on tile first
	for(var/obj/machinery/power/P in T1)
		P.disconnect_from_network()

	var/list/P_list = list()
	for(var/dir_check in CABLE_DIRECTIONS)
		if(linked_dirs & dir_check)
			T1 = get_step(loc, dir_check)
			P_list += locate(/obj/structure/cable) in T1

	// remove the cut cable from its turf and powernet, so that it doesn't get count in propagate_network worklist
	if(remove)
		moveToNullspace()
	powernet.remove_cable(src) //remove the cut cable from its powernet

	var/first = TRUE
	for(var/obj/O in P_list)
		if(first)
			first = FALSE
			continue
		addtimer(CALLBACK(O, PROC_REF(auto_propagate_cut_cable), O), 0) //so we don't rebuild the network X times when singulo/explosion destroys a line of X cables
