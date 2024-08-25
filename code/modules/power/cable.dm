///////////////////////////////
//CABLE STRUCTURE
///////////////////////////////


////////////////////////////////
// Definitions
////////////////////////////////

/* Cable directions (d1 and d2)


  9   1   5
	\ | /
  8 - 0 - 4
	/ | \
  10  2   6

If d1 = 0 and d2 = 0, there's no cable
If d1 = 0 and d2 = dir, it's a O-X cable, getting from the center of the tile to dir (knot cable)
If d1 = dir1 and d2 = dir2, it's a full X-X cable, getting from dir1 to dir2
By design, d1 is the smallest direction and d2 is the highest
*/

/obj/structure/cable
	level = 1
	anchored = TRUE
	on_blueprints = TRUE
	var/datum/powernet/powernet
	name = "power cable"
	desc = "A flexible superconducting cable for heavy-duty power transfer"
	icon = 'icons/obj/engines_and_power/power_cond/power_cond_white.dmi'
	icon_state = "0-1"
	var/d1 = 0
	var/d2 = 1
	plane = GAME_PLANE
	layer = WIRE_LAYER //Just below unary stuff, which is at 2.45 and above pipes, which are at 2.4
	color = WIRE_COLOR_RED

/obj/structure/cable/yellow
	color = WIRE_COLOR_YELLOW

/obj/structure/cable/green
	color = WIRE_COLOR_GREEN

/obj/structure/cable/blue
	color = WIRE_COLOR_BLUE

/obj/structure/cable/pink
	color = WIRE_COLOR_PINK

/obj/structure/cable/orange
	color = WIRE_COLOR_ORANGE

/obj/structure/cable/cyan
	color = WIRE_COLOR_CYAN

/obj/structure/cable/white
	color = WIRE_COLOR_WHITE

/obj/structure/cable/Initialize(mapload)
	. = ..()

	// ensure d1 & d2 reflect the icon_state for entering and exiting cable
	var/dash = findtext(icon_state, "-")
	d1 = text2num(copytext( icon_state, 1, dash ))
	d2 = text2num(copytext( icon_state, dash+1 ))

	var/turf/T = get_turf(src)			// hide if turf is not intact
	LAZYADD(GLOB.cable_list, src) //add it to the global cable list
	if(level == 1)
		hide(T.intact)

/obj/structure/cable/Destroy()					// called when a cable is deleted
	if(powernet)
		cut_cable_from_powernet()				// update the powernets
	LAZYREMOVE(GLOB.cable_list, src)			//remove it from global cable list
	return ..()									// then go ahead and delete the cable

/obj/structure/cable/deconstruct(disassembled = TRUE)
	var/turf/T = get_turf(src)
	if(usr)
		investigate_log("was deconstructed by [key_name_log(usr)] at [COORD(T)]", INVESTIGATE_WIRES)
	if(!(obj_flags & NODECONSTRUCT))
		if(d1)	// 0-X cables are 1 unit, X-X cables are 2 units long
			new/obj/item/stack/cable_coil(T, 2, TRUE, color)
		else
			new/obj/item/stack/cable_coil(T, 1, TRUE, color)
	qdel(src)

///////////////////////////////////
// General procedures
///////////////////////////////////

//If underfloor, hide the cable
/obj/structure/cable/hide(i)
	if(level == 1 && isturf(loc))
		invisibility = i ? INVISIBILITY_MAXIMUM : 0
	update_icon(UPDATE_ICON_STATE)


/obj/structure/cable/update_icon_state()
	if(invisibility)
		icon_state = "[d1]-[d2]-f"
	else
		icon_state = "[d1]-[d2]"
	var/turf/T = get_turf(src)
	if(T.transparent_floor)
		SET_PLANE_IMPLICIT(src, FLOOR_PLANE)
	else
		SET_PLANE_IMPLICIT(src, GAME_PLANE)


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


/obj/structure/cable/attackby(obj/item/I, mob/user, params)
	var/turf/our_turf = get_turf(src)
	if(!our_turf)
		return ATTACK_CHAIN_BLOCKED_ALL

	if((our_turf.transparent_floor == TURF_TRANSPARENT) || our_turf.intact)
		to_chat(user, span_danger("You cannot interact with something that's under the floor!"))
		return ATTACK_CHAIN_BLOCKED_ALL

	if(iscoil(I))
		add_fingerprint(user)
		var/obj/item/stack/cable_coil/coil = I
		if(coil.get_amount() < 1)
			to_chat(user, span_warning("Not enough cable!"))
			return ATTACK_CHAIN_PROCEED
		coil.cable_join(src, user)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/twohanded/rcl))
		add_fingerprint(user)
		var/obj/item/twohanded/rcl/rcl = I
		if(!rcl.loaded)
			to_chat(user, span_warning("The [rcl.name] has no cable!"))
			return ATTACK_CHAIN_PROCEED
		rcl.loaded.cable_join(src, user)
		rcl.is_empty(user)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/toy/crayon))
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
	var/turf/T = get_turf(src)
	if(T.intact)
		return
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(powernet && (powernet.avail > 0))		// is it powered?
		to_chat(user, "<span class='danger'>Total power: [DisplayPower(powernet.avail)]\nLoad: [DisplayPower(powernet.load)]\nExcess power: [DisplayPower(surplus())]</span>")
	else
		to_chat(user, "<span class='danger'>The cable is not powered.</span>")
	shock(user, 5, 0.2)

/obj/structure/cable/wirecutter_act(mob/user, obj/item/I)
	. = TRUE
	var/turf/T = get_turf(src)
	if((T.transparent_floor == TURF_TRANSPARENT) || T.intact)
		to_chat(user, "<span class='danger'>You can't interact with something that's under the floor!</span>")
		return
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(shock(user, 50))
		return
	user.visible_message("[user] cuts the cable.", "<span class='notice'>You cut the cable.</span>")
	investigate_log("was cut by [key_name_log(usr)] at [COORD(T)]", INVESTIGATE_WIRES)
	deconstruct()

// shock the user with probability prb
/obj/structure/cable/proc/shock(mob/user, prb, siemens_coeff = 1)
	if(!prob(prb))
		return FALSE
	if(electrocute_mob(user, powernet, src, siemens_coeff))
		do_sparks(5, 1, src)
		return TRUE
	else
		return FALSE

/obj/structure/cable/singularity_pull(S, current_size)
	..()
	if(current_size >= STAGE_FIVE)
		deconstruct()

/obj/structure/cable/proc/cable_color(colorC)
	if(!colorC)
		color = WIRE_COLOR_RED
	else if(colorC == "rainbow")
		color = color_rainbow()
	else if(colorC == "orange") //byond only knows 16 colors by name, and orange isn't one of them
		color = WIRE_COLOR_ORANGE
	else
		color = colorC

/obj/structure/cable/proc/color_rainbow()
	color = pick(WIRE_COLOR_RED, WIRE_COLOR_BLUE, WIRE_COLOR_GREEN, WIRE_COLOR_PINK, WIRE_COLOR_YELLOW, WIRE_COLOR_CYAN)
	return color

/////////////////////////////////////////////////
// Cable laying helpers
////////////////////////////////////////////////

//handles merging diagonally matching cables
//for info : direction^3 is flipping horizontally, direction^12 is flipping vertically
/obj/structure/cable/proc/mergeDiagonalsNetworks(direction)

	//search for and merge diagonally matching cables from the first direction component (north/south)
	var/turf/T  = get_step(src, direction&3)//go north/south

	for(var/obj/structure/cable/C in T)

		if(!C)
			continue

		if(src == C)
			continue

		if(C.d1 == (direction^3) || C.d2 == (direction^3)) //we've got a diagonally matching cable
			if(!C.powernet) //if the matching cable somehow got no powernet, make him one (should not happen for cables)
				var/datum/powernet/newPN = new()
				newPN.add_cable(C)

			if(powernet) //if we already have a powernet, then merge the two powernets
				merge_powernets(powernet,C.powernet)
			else
				C.powernet.add_cable(src) //else, we simply connect to the matching cable powernet

	//the same from the second direction component (east/west)
	T  = get_step(src, direction&12)//go east/west

	for(var/obj/structure/cable/C in T)

		if(!C)
			continue

		if(src == C)
			continue
		if(C.d1 == (direction^12) || C.d2 == (direction^12)) //we've got a diagonally matching cable
			if(!C.powernet) //if the matching cable somehow got no powernet, make him one (should not happen for cables)
				var/datum/powernet/newPN = new()
				newPN.add_cable(C)

			if(powernet) //if we already have a powernet, then merge the two powernets
				merge_powernets(powernet,C.powernet)
			else
				C.powernet.add_cable(src) //else, we simply connect to the matching cable powernet

// merge with the powernets of power objects in the given direction
/obj/structure/cable/proc/mergeConnectedNetworks(direction)

	var/fdir = (!direction)? 0 : turn(direction, 180) //flip the direction, to match with the source position on its turf

	if(!(d1 == direction || d2 == direction)) //if the cable is not pointed in this direction, do nothing
		return

	var/turf/TB  = get_step(src, direction)

	for(var/obj/structure/cable/C in TB)

		if(!C)
			continue

		if(src == C)
			continue

		if(C.d1 == fdir || C.d2 == fdir) //we've got a matching cable in the neighbor turf
			if(!C.powernet) //if the matching cable somehow got no powernet, make him one (should not happen for cables)
				var/datum/powernet/newPN = new()
				newPN.add_cable(C)

			if(powernet) //if we already have a powernet, then merge the two powernets
				merge_powernets(powernet,C.powernet)
			else
				C.powernet.add_cable(src) //else, we simply connect to the matching cable powernet

// merge with the powernets of power objects in the source turf
/obj/structure/cable/proc/mergeConnectedNetworksOnTurf()
	var/list/to_connect = list()

	if(!powernet) //if we somehow have no powernet, make one (should not happen for cables)
		var/datum/powernet/newPN = new()
		newPN.add_cable(src)

	//first let's add turf cables to our powernet
	//then we'll connect machines on turf with a node cable is present
	for(var/AM in loc)
		if(istype(AM, /obj/structure/cable))
			var/obj/structure/cable/C = AM
			if(C.d1 == d1 || C.d2 == d1 || C.d1 == d2 || C.d2 == d2) //only connected if they have a common direction
				if(C.powernet == powernet)
					continue
				if(C.powernet)
					merge_powernets(powernet, C.powernet)
				else
					powernet.add_cable(C) //the cable was powernetless, let's just add it to our powernet
			else if(istype(C, /obj/structure/cable/multiz) && d1 == 0) // we're dot and we got multiz hub
				if(C.powernet == powernet)
					continue
				if(C.powernet)
					merge_powernets(powernet, C.powernet)
				else
					powernet.add_cable(C) //the cable was powernetless, let's just add it to our powernet

		else if(isapc(AM))
			var/obj/machinery/power/apc/N = AM
			if(!N.terminal)
				continue // APC are connected through their terminal

			if(N.terminal.powernet == powernet)
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
/obj/structure/cable/proc/get_connections(powernetless_only = 0)
	. = list()	// this will be a list of all connected power objects
	var/turf/T

	//get matching cables from the first direction
	if(d1) //if not a node cable
		T = get_step(src, d1)
		if(T)
			. += power_list(T, src, turn(d1, 180), powernetless_only) //get adjacents matching cables

	if(d1&(d1-1)) //diagonal direction, must check the 4 possibles adjacents tiles
		T = get_step(src,d1&3) // go north/south
		if(T)
			. += power_list(T, src, d1 ^ 3, powernetless_only) //get diagonally matching cables
		T = get_step(src,d1&12) // go east/west
		if(T)
			. += power_list(T, src, d1 ^ 12, powernetless_only) //get diagonally matching cables

	. += power_list(loc, src, d1, powernetless_only) //get on turf matching cables

	//do the same on the second direction (which can't be 0)
	T = get_step(src, d2)
	if(T)
		. += power_list(T, src, turn(d2, 180), powernetless_only) //get adjacents matching cables

	if(d2&(d2-1)) //diagonal direction, must check the 4 possibles adjacents tiles
		T = get_step(src,d2&3) // go north/south
		if(T)
			. += power_list(T, src, d2 ^ 3, powernetless_only) //get diagonally matching cables
		T = get_step(src,d2&12) // go east/west
		if(T)
			. += power_list(T, src, d2 ^ 12, powernetless_only) //get diagonally matching cables
	. += power_list(loc, src, d2, powernetless_only) //get on turf matching cables

	return .

//should be called after placing a cable which extends another cable, creating a "smooth" cable that no longer terminates in the centre of a turf.
//needed as this can, unlike other placements, disconnect cables
/obj/structure/cable/proc/denode()
	var/turf/T1 = loc
	if(!T1)
		return

	var/list/powerlist = power_list(T1,src,0,0) //find the other cables that ended in the centre of the turf, with or without a powernet
	if(powerlist.len>0)
		var/datum/powernet/PN = new()
		propagate_network(powerlist[1],PN) //propagates the new powernet beginning at the source cable

		if(PN.is_empty()) //can happen with machines made nodeless when smoothing cables
			qdel(PN)

// cut the cable's powernet at this cable and updates the powergrid
/obj/structure/cable/proc/cut_cable_from_powernet(remove=TRUE)
	var/turf/T1 = loc
	var/list/P_list
	if(!T1)
		return
	if(d1)
		T1 = get_step(T1, d1)
		P_list = power_list(T1, src, turn(d1,180),0,cable_only = 1)	// what adjacently joins on to cut cable...

	P_list += power_list(loc, src, d1, 0, cable_only = 1)//... and on turf


	if(P_list.len == 0)//if nothing in both list, then the cable was a lone cable, just delete it and its powernet
		powernet.remove_cable(src)

		for(var/obj/machinery/power/P in T1)//check if it was powering a machine
			if(!P.connect_to_network()) //can't find a node cable on a the turf to connect to
				P.disconnect_from_network() //remove from current network (and delete powernet)
		return

	var/obj/O = P_list[1]
	// remove the cut cable from its turf and powernet, so that it doesn't get count in propagate_network worklist
	if(remove)
		loc = null
	powernet.remove_cable(src) //remove the cut cable from its powernet

	// queue it to rebuild
	SSmachines.deferred_powernet_rebuilds += O

	// Disconnect machines connected to nodes
	if(d1 == 0) // if we cut a node (O-X) cable
		for(var/obj/machinery/power/P in T1)
			if(!P.connect_to_network()) //can't find a node cable on a the turf to connect to
				P.disconnect_from_network() //remove from current network
