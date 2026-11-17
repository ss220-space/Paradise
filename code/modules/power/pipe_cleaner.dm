//This is the old cable code, but minus any actual powernet logic

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
 * # /obj/structure/pipe_cleaner
 *
 * The red wire thingies you see on the ground all over the station in maintenance
 * the d1 and d2 vars deal with the "directions" of the cables, since all instances of this cable structure are
 * just lines, they have two endpoints (d1 and d2).
 */
/obj/structure/pipe_cleaner
	name = "pipe cleaner"
	desc = "A bendable piece of wire covered in fuzz. Fun for arts and crafts!"
	level = 1
	anchored = TRUE
	on_blueprints = TRUE
	icon = 'icons/obj/engines_and_power/pipe_cleaner.dmi'
	icon_state = "0-1"
	var/d1 = 0
	var/d2 = 1
	layer = WIRE_LAYER //Just below unary stuff, which is at 2.45 and above pipes, which are at 2.4
	color = CABLE_HEX_COLOR_RED

/obj/structure/pipe_cleaner/Initialize(mapload)
	. = ..()

	// ensure d1 & d2 reflect the icon_state for entering and exiting cable
	var/dash = findtext(icon_state, "-")
	d1 = text2num(copytext( icon_state, 1, dash ))
	d2 = text2num(copytext( icon_state, dash+1 ))

	AddElement(/datum/element/undertile)

/obj/structure/pipe_cleaner/deconstruct(disassembled = TRUE)
	var/turf/T = get_turf(src)
	if(usr)
		investigate_log("was deconstructed by [key_name_log(usr)] at [COORD(T)]", INVESTIGATE_WIRES)
	if(!(obj_flags & NODECONSTRUCT))
		if(d1)	// 0-X cables are 1 unit, X-X cables are 2 units long
			new/obj/item/stack/pipe_cleaner(T, 2, TRUE, color)
		else
			new/obj/item/stack/pipe_cleaner(T, 1, TRUE, color)
	qdel(src)

///////////////////////////////////
// General procedures
///////////////////////////////////

/obj/structure/pipe_cleaner/update_icon_state()
	icon_state = "[d1]-[d2]"

//Telekinesis has no effect on a cable
/obj/structure/pipe_cleaner/attack_tk(mob/user)
	return

/obj/structure/pipe_cleaner/attackby(obj/item/I, mob/user, list/modifiers)
	var/turf/our_turf = get_turf(src)
	if(!our_turf)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(HAS_TRAIT(src, TRAIT_UNDERFLOOR))
		to_chat(user, span_danger("You cannot interact with something that's under the floor!"))
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/stack/pipe_cleaner))
		add_fingerprint(user)
		var/obj/item/stack/pipe_cleaner/coil = I
		if(coil.get_amount() < 1)
			to_chat(user, span_warning("Not enough cable!"))
			return ATTACK_CHAIN_PROCEED
		coil.cable_join(src, user)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(iscrayon(I))
		add_fingerprint(user)
		var/obj/item/toy/crayon/crayon = I
		cable_color(crayon.colourName)
		return ATTACK_CHAIN_PROCEED

	if(I.flags & CONDUCT)
		add_fingerprint(user)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()

/obj/structure/pipe_cleaner/multitool_act(mob/user, obj/item/I)
	. = TRUE
	if(HAS_TRAIT(src, TRAIT_UNDERFLOOR))
		return
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	to_chat(user, generate_power_message())

/obj/structure/pipe_cleaner/proc/generate_power_message()
	if(prob(50))
		return boxed_message(span_notice("Total power: \[Rubber\]\nLoad: \[That's not a cable\]\nSurplus: \[No reading\]"))
	else
		return span_warning("The cable is not a cable.")

/obj/structure/pipe_cleaner/examine(mob/user)
	. = ..()
	if(isobserver(user))
		. += generate_power_message()

/obj/structure/pipe_cleaner/wirecutter_act(mob/user, obj/item/I)
	. = TRUE
	var/turf/T = get_turf(src)
	if(HAS_TRAIT(src, TRAIT_UNDERFLOOR))
		to_chat(user, span_danger("You can't interact with something that's under the floor!"))
		return
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	user.visible_message("[user] cuts the cable.", span_notice("You cut the cable."))
	investigate_log("was cut by [key_name_log(usr)] at [COORD(T)]", INVESTIGATE_WIRES)
	deconstruct()

/obj/structure/pipe_cleaner/singularity_pull(atom/singularity, current_size)
	..()
	if(current_size < STAGE_FIVE)
		return
	deconstruct()

/obj/structure/pipe_cleaner/proc/cable_color(colorC)
	if(!colorC)
		color = CABLE_HEX_COLOR_RED
	else if(colorC == "rainbow")
		color = color_rainbow()
	else if(colorC == "orange") //byond only knows 16 colors by name, and orange isn't one of them
		color = CABLE_HEX_COLOR_ORANGE
	else
		color = colorC

/obj/structure/pipe_cleaner/proc/color_rainbow()
	color = pick(CABLE_HEX_COLOR_RED, CABLE_HEX_COLOR_BLUE, CABLE_HEX_COLOR_GREEN, CABLE_HEX_COLOR_PINK, CABLE_HEX_COLOR_YELLOW, CABLE_HEX_COLOR_CYAN)
	return color

//////////////////////////////////////////////
// Powernets handling helpers
//////////////////////////////////////////////

//if powernetless_only = 1, will only get connections without powernet
/obj/structure/pipe_cleaner/proc/get_connections(powernetless_only = 0)
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
/obj/structure/pipe_cleaner/proc/denode()
	var/turf/T1 = loc
	if(!T1)
		return

	var/list/powerlist = power_list(T1,src,0,0) //find the other cables that ended in the centre of the turf, with or without a powernet
	if(length(powerlist)>0)
		var/datum/powernet/PN = new()
		propagate_network(powerlist[1],PN) //propagates the new powernet beginning at the source cable

		if(PN.is_empty()) //can happen with machines made nodeless when smoothing cables
			qdel(PN)

//
// PIPE CLEANER STACK!
//
/obj/item/stack/pipe_cleaner
	name = "pipe cleaner"
	singular_name = "pipe cleaner"
	desc = "A coil of artistic pipe cleaner."
	icon = 'icons/obj/engines_and_power/power.dmi'
	icon_state = "pipe_cleaner"
	righthand_file = 'icons/mob/inhands/tools_righthand.dmi'
	lefthand_file = 'icons/mob/inhands/tools_lefthand.dmi'
	item_state = "coil_red"
	belt_icon = "coil_red"
	amount = MAXCOIL
	max_amount = MAXCOIL
	merge_type = /obj/item/stack/pipe_cleaner // This is here to let its children merge between themselves
	color = CABLE_HEX_COLOR_RED
	w_class = WEIGHT_CLASS_SMALL
	full_w_class = WEIGHT_CLASS_SMALL
	throw_range = 5
	materials = list(MAT_METAL=10, MAT_GLASS=5)
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BELT
	attack_verb = list("хлестнул", "стегнул", "проучил", "выпорол")
	usesound = 'sound/items/deconstruct.ogg'
	toolbox_radial_menu_compatibility = TRUE

	var/static/list/wire_colors = list(
		CABLE_HEX_COLOR_BLUE = "blue",
		CABLE_HEX_COLOR_CYAN = "cyan",
		CABLE_HEX_COLOR_GREEN = "green",
		CABLE_HEX_COLOR_ORANGE = "orange",
		CABLE_HEX_COLOR_PINK = "pink",
		CABLE_HEX_COLOR_RED = "red",
		CABLE_HEX_COLOR_WHITE = "white",
		CABLE_HEX_COLOR_YELLOW = "yellow"
	)

/obj/item/stack/pipe_cleaner/Initialize(mapload, new_amount, merge = TRUE, cable_color = null)
	. = ..()
	if(cable_color)
		color = cable_color
	pixel_x = rand(-2,2)
	pixel_y = rand(-2,2)
	update_appearance(UPDATE_ICON_STATE|UPDATE_NAME)
	update_weight()

/obj/item/stack/pipe_cleaner/split()
	var/obj/item/stack/pipe_cleaner/C = ..()
	C.color = color
	return C

/obj/item/stack/pipe_cleaner/update_name(updates = ALL)
	. = ..()
	if(amount > 2)
		name = "pipe cleaner coil"
	else
		name = "pipe cleaner"

/obj/item/stack/pipe_cleaner/update_icon_state()
	if(!color)
		color = pick(CABLE_HEX_COLOR_RED, CABLE_HEX_COLOR_BLUE, CABLE_HEX_COLOR_GREEN, CABLE_HEX_COLOR_ORANGE, CABLE_HEX_COLOR_WHITE, CABLE_HEX_COLOR_PINK, CABLE_HEX_COLOR_YELLOW, CABLE_HEX_COLOR_CYAN)
	if(amount == 1)
		icon_state = "pipe_cleaner1"
	else if(amount == 2)
		icon_state = "pipe_cleaner2"
	else
		icon_state = "pipe_cleaner"
	item_state = "coil_[wire_colors[color]]"
	belt_icon = "coil_[wire_colors[color]]"

/obj/item/stack/pipe_cleaner/update_weight()
	if(amount == 1)
		w_class = WEIGHT_CLASS_TINY
	else
		w_class = WEIGHT_CLASS_SMALL

/obj/item/stack/pipe_cleaner/examine(mob/user)
	. = ..()
	if(is_cyborg || !in_range(user, src))
		return
	if(get_amount() == 1)
		. += span_notice("A short piece of pipe cleaner.")
	else if(get_amount() == 2)
		. += span_notice("A piece of pipe cleaner.")
	else
		. += span_notice("A coil of pipe cleaner. There are [get_amount()] lengths of cleaner in the coil.")

/obj/item/stack/pipe_cleaner/suicide_act(mob/user)
	if(locate(/obj/structure/chair/stool) in user.loc)
		user.visible_message(span_suicide("[user] is making a noose with the [name]! It looks like [user.p_theyre()] trying to commit suicide."))
	else
		user.visible_message(span_suicide("[user] is strangling [user.p_them()]self with the [name]! It looks like [user.p_theyre()] trying to commit suicide."))
	return OXYLOSS

///////////////////////////////////
// General procedures
///////////////////////////////////

/obj/item/stack/pipe_cleaner/attackby(obj/item/I, mob/user, params)
	if(iscrayon(I))
		add_fingerprint(user)
		var/obj/item/toy/crayon/crayon = I
		cable_color(crayon.colourName)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()

///////////////////////////////////////////////
// Cable laying procedures
//////////////////////////////////////////////

/obj/item/stack/pipe_cleaner/proc/get_new_cable(location)
	var/obj/structure/pipe_cleaner/C = new(location)
	C.cable_color(color)

	return C

// called when cable_coil is clicked on a turf/simulated/floor
/obj/item/stack/pipe_cleaner/proc/place_turf(turf/T, mob/user, dirnew)
	if(!isturf(user.loc))
		return

	if(!isturf(T) || !T.can_have_cabling()) // a little surprise, you can place them above turfs
		to_chat(user, span_warning("You can only lay cables on catwalks and floor!"))
		return

	if(get_amount() < 1) // Out of cable
		to_chat(user, span_warning("There is no cable left!"))
		return

	if(get_dist(T,user.loc) > 1) // Too far
		to_chat(user, span_warning("You can't lay cable at a place that far away!"))
		return

	var/dirn
	if(!dirnew) //If we weren't given a direction, come up with one! (Called as null from catwalk.dm and floor.dm)
		if(user.loc == T)
			dirn = user.dir //If laying on the tile we're on, lay in the direction we're facing
		else
			dirn = get_dir(T, user)
	else
		dirn = dirnew

	for(var/obj/structure/pipe_cleaner/LC in T)
		if(LC.d2 == dirn && LC.d1 == 0)
			to_chat(user, span_warning("There's already a cable at that position!"))
			return

	var/obj/structure/pipe_cleaner/C = get_new_cable(T)

	//set up the new cable
	C.d1 = 0 //it's a O-X node cable
	C.d2 = dirn
	C.add_fingerprint(user)
	C.update_icon(UPDATE_ICON_STATE)

	use(1)
	return C

// called when cable_coil is click on an installed obj/cable
// or click on a turf that already contains a "node" cable
/obj/item/stack/pipe_cleaner/proc/cable_join(obj/structure/pipe_cleaner/C, mob/user)
	var/turf/U = user.loc
	if(!isturf(U))
		return

	var/turf/T = get_turf(C)

	if(!isturf(T) || HAS_TRAIT(C, TRAIT_UNDERFLOOR))		// sanity checks, also stop use interacting with T-scanner revealed cable
		return

	if(get_dist(C, user) > 1)		// make sure it's close enough
		to_chat(user, span_warning("You can't lay cable at a place that far away!"))
		return

	if(U == T) //if clicked on the turf we're standing on, try to put a cable in the direction we're facing
		place_turf(T,user)
		return

	var/dirn = get_dir(C, user)
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_CABLE_UPDATED, T)

	// one end of the clicked cable is pointing towards us
	if(C.d1 == dirn || C.d2 == dirn)
		if(U.underfloor_accessibility != UNDERFLOOR_INTERACTABLE)						// can't place a cable if the floor is complete
			to_chat(user, span_warning("You can't lay cable there unless the floor tiles are removed!"))
			return
		// cable is pointing at us, we're standing on an open tile
		// so create a stub pointing at the clicked cable on our tile

		var/fdirn = turn(dirn, 180)		// the opposite direction

		for(var/obj/structure/pipe_cleaner/LC in U)		// check to make sure there's not a cable there already
			if(LC.d1 == fdirn || LC.d2 == fdirn)
				to_chat(user, span_warning("There's already a cable at that position!"))
				return

		var/obj/structure/pipe_cleaner/NC = get_new_cable (U)

		NC.d1 = 0
		NC.d2 = fdirn
		NC.add_fingerprint(user)
		NC.update_icon()

		//create a new powernet with the cable, if needed it will be merged later
		var/datum/powernet/newPN = new()
		newPN.add_cable(NC)

		use(1)

	// exisiting cable doesn't point at our position, so see if it's a stub
	else if(C.d1 == 0)
							// if so, make it a full cable pointing from it's old direction to our dirn
		var/nd1 = C.d2	// these will be the new directions
		var/nd2 = dirn

		if(nd1 > nd2)		// swap directions to match icons/states
			nd1 = dirn
			nd2 = C.d2

		for(var/obj/structure/pipe_cleaner/LC in T)		// check to make sure there's no matching cable
			if(LC == C)			// skip the cable we're interacting with
				continue
			if((LC.d1 == nd1 && LC.d2 == nd2) || (LC.d1 == nd2 && LC.d2 == nd1))	// make sure no cable matches either direction
				to_chat(user, span_warning("There's already a cable at that position!"))
				return

		C.cable_color(color)

		C.d1 = nd1
		C.d2 = nd2

		C.add_fingerprint()
		C.update_icon(UPDATE_ICON_STATE)

		use(1)

		C.denode()// this call may have disconnected some cables that terminated on the centre of the turf, if so split the powernets.

//////////////////////////////
// Misc.
/////////////////////////////

/obj/item/stack/pipe_cleaner/cut
	item_state = "coil2"

/obj/item/stack/pipe_cleaner/cut/Initialize(mapload, new_amount, merge = TRUE, cable_color = null)
	. = ..(mapload, rand(1,2), merge, cable_color)

/obj/item/stack/pipe_cleaner/yellow
	color = CABLE_HEX_COLOR_YELLOW

/obj/item/stack/pipe_cleaner/blue
	color = CABLE_HEX_COLOR_BLUE

/obj/item/stack/pipe_cleaner/green
	color = CABLE_HEX_COLOR_GREEN

/obj/item/stack/pipe_cleaner/pink
	color = CABLE_HEX_COLOR_PINK

/obj/item/stack/pipe_cleaner/orange
	color = CABLE_HEX_COLOR_ORANGE

/obj/item/stack/pipe_cleaner/cyan
	color = CABLE_HEX_COLOR_CYAN

/obj/item/stack/pipe_cleaner/white
	color = CABLE_HEX_COLOR_WHITE

/obj/item/stack/pipe_cleaner/random/Initialize(mapload, new_amount, merge = TRUE, cable_color = null)
	var/random_color = pick(CABLE_HEX_COLOR_RED, CABLE_HEX_COLOR_BLUE, CABLE_HEX_COLOR_GREEN, CABLE_HEX_COLOR_WHITE, CABLE_HEX_COLOR_PINK, CABLE_HEX_COLOR_YELLOW, CABLE_HEX_COLOR_CYAN)
	. = ..(mapload, new_amount, merge, random_color)

/obj/item/stack/pipe_cleaner/proc/cable_color(colorC)
	if(!colorC)
		color = CABLE_HEX_COLOR_RED
	else if(colorC == "rainbow")
		color = color_rainbow()
	else if(colorC == "orange") //byond only knows 16 colors by name, and orange isn't one of them
		color = CABLE_HEX_COLOR_ORANGE
	else
		color = colorC

/obj/item/stack/pipe_cleaner/proc/color_rainbow()
	color = pick(CABLE_HEX_COLOR_RED, CABLE_HEX_COLOR_BLUE, CABLE_HEX_COLOR_GREEN, CABLE_HEX_COLOR_PINK, CABLE_HEX_COLOR_YELLOW, CABLE_HEX_COLOR_CYAN)
	return color

/obj/item/stack/pipe_cleaner/cyborg
	name = "cyborg pipe cleaner"
	is_cyborg = TRUE
	energy_type = /datum/robot_energy_storage/wire

/obj/item/stack/pipe_cleaner/cyborg/attack_self(mob/user)
	var/cablecolor = tgui_input_list(user, "Pick a cable color.", "Cable Color", list("red", "yellow", "green", "blue", "pink", "orange", "cyan", "white"))
	color = cablecolor
	update_icon()
