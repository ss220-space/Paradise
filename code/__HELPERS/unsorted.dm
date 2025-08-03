/*
 * A large number of misc global procs.
 */

 /* Get the direction of startObj relative to endObj.
  * Return values: To the right, 1. Below, 2. To the left, 3. Above, 4. Not found adjacent in cardinal directions, 0.
  */
/proc/getRelativeDirection(var/atom/movable/startObj, var/atom/movable/endObj)
	if(endObj.x == startObj.x + 1 && endObj.y == startObj.y)
		return EAST

	if(endObj.x == startObj.x - 1 && endObj.y == startObj.y)
		return WEST

	if(endObj.y == startObj.y + 1 && endObj.x == startObj.x)
		return NORTH

	if(endObj.y == startObj.y - 1 && endObj.x == startObj.x)
		return SOUTH

	return 0

//Returns the middle-most value
/proc/dd_range(low, high, num)
	return max(low, min(high, num))

//Returns whether or not A is the middle most value
/proc/InRange(A, lower, upper)
	if(A < lower)
		return FALSE
	if(A > upper)
		return FALSE
	return TRUE


/proc/get_angle_tgmc(atom/start, atom/end)//For beams.
	if(!start || !end)
		CRASH("get_angle_tgmc called for inexisting atoms: [isnull(start) ? "null" : start] to [isnull(end) ? "null" : end].")
	if(!start.z)
		start = get_turf(start)
		if(!start)
			CRASH("get_angle_tgmc called for inexisting atoms (start): [isnull(start.loc) ? "null loc" : start.loc] [start] to [isnull(end.loc) ? "null loc" : end.loc] [end].") //Atoms are not on turfs.
	if(!end.z)
		end = get_turf(end)
		if(!end)
			CRASH("get_angle_tgmc called for inexisting atoms (end): [isnull(start.loc) ? "null loc" : start.loc] [start] to [isnull(end.loc) ? "null loc" : end.loc] [end].") //Atoms are not on turfs.
	var/dy = (32 * end.y + end.pixel_y) - (32 * start.y + start.pixel_y)
	var/dx = (32 * end.x + end.pixel_x) - (32 * start.x + start.pixel_x)
	if(!dy)
		return (dx >= 0) ? 90 : 270
	. = arctan(dx / dy)
	if(dy < 0)
		. += 180
	else if(dx < 0)
		. += 360

/proc/Get_Pixel_Angle(y, x) // For getting the angle when animating something's pixel_x and pixel_y
	if(!y)
		return (x >= 0)?90:270
	. = arctan(x / y)
	if(y<0)
		. += 180
	else if(x < 0)
		. += 360

/proc/is_in_teleport_proof_area(atom/O)
	if(!O)
		return FALSE
	var/area/A = get_area(O)
	if(!A)
		return FALSE
	if(A.tele_proof)
		return TRUE
	if(!is_teleport_allowed(O.z))
		return TRUE
	else
		return FALSE

// Returns true if direction is blocked from loc
// Checks if doors are open
/proc/DirBlocked(turf/loc,var/dir)
	for(var/obj/structure/window/D in loc)
		if(!D.density)
			continue
		if(D.fulltile)
			return 1
		if(D.dir == dir)
			return 1

	for(var/obj/machinery/door/D in loc)
		if(!D.density)//if the door is open
			continue
		else return 1	// if closed, it's a real, air blocking door
	return 0

/////////////////////////////////////////////////////////////////////////


//Same as the thing below just for density and without support for atoms.
/proc/can_line(atom/source, atom/target, length = 5)
	var/turf/current = get_turf(source)
	var/turf/target_turf = get_turf(target)
	var/steps = 0

	while(current != target_turf)
		if(steps > length)
			return FALSE
		if(!current)
			return FALSE
		if(current.density)
			return FALSE
		current = get_step_towards(current, target_turf)
		steps++
	return TRUE

//Returns whether or not a player is a guest using their ckey as an input
/proc/IsGuestKey(key)
	if(findtext(key, "Guest-", 1, 7) != 1) //was findtextEx
		return FALSE

	var/i, ch, len = length(key)

	for(i = 7, i <= len, ++i) //we know the first 6 chars are Guest-
		ch = text2ascii(key, i)
		if (ch < 48 || ch > 57) //0-9
			return FALSE
	return TRUE

//Ensure the frequency is within bounds of what it should be sending/recieving at
/proc/sanitize_frequency(var/f, var/low = PUBLIC_LOW_FREQ, var/high = PUBLIC_HIGH_FREQ)
	f = round(f)
	f = max(low, f)
	f = min(high, f)
	if((f % 2) == 0) //Ensure the last digit is an odd number
		f += 1
	return f

//Turns 1479 into 147.9
/proc/format_frequency(var/f)
	return "[round(f / 10)].[f % 10]"

//Picks a string of symbols to display as the law number for hacked or ion laws
/proc/ionnum()
	return "[pick("!","@","#","$","%","^","&","*")][pick("!","@","#","$","%","^","&","*")][pick("!","@","#","$","%","^","&","*")][pick("!","@","#","$","%","^","&","*")]"

//When an AI is activated, it can choose from a list of non-slaved borgs to have as a slave.
/proc/freeborg()
	var/select = null
	var/list/borgs = list()
	for(var/mob/living/silicon/robot/A in GLOB.player_list)
		if(A.stat == DEAD || A.connected_ai || A.scrambledcodes || isdrone(A) || iscogscarab(A) || isclocker(A))
			continue
		var/name = "[A.real_name] ([A.modtype?.name] [A.braintype])"
		borgs[name] = A

	if(borgs.len)
		select = tgui_input_list(usr, "Unshackled borg signals detected:", "Borg selection", borgs, null)
		return borgs[select]

//When a borg is activated, it can choose which AI it wants to be slaved to
/proc/active_ais()
	. = list()
	for(var/mob/living/silicon/ai/A in GLOB.alive_mob_list)
		if(A.stat == DEAD)
			continue
		if(A.control_disabled)
			continue
		if(isclocker(A)) //the active ais list used for uploads. Avoiding to changing the laws even the AI is fully converted
			continue
		. += A
	return .

//Find an active ai with the least borgs. VERBOSE PROCNAME HUH!
/proc/select_active_ai_with_fewest_borgs()
	var/mob/living/silicon/ai/selected
	var/list/active = active_ais()
	for(var/thing in active)
		var/mob/living/silicon/ai/A = thing
		if(!selected || (length(selected.connected_robots) > length(A.connected_robots)))
			selected = A

	return selected

/proc/select_active_ai(var/mob/user)
	var/list/ais = active_ais()
	if(ais.len)
		if(user)	. = tgui_input_list(usr, "AI signals detected:", "AI selection", ais)
		else		. = pick(ais)
	return .

/proc/get_sorted_mobs()
	var/list/old_list = getmobs()
	var/list/AI_list = list()
	var/list/Dead_list = list()
	var/list/keyclient_list = list()
	var/list/key_list = list()
	var/list/logged_list = list()
	for(var/named in old_list)
		var/mob/M = old_list[named]
		if(issilicon(M))
			AI_list |= M
		else if(isobserver(M) || M.stat == DEAD)
			Dead_list |= M
		else if(M.key && M.client)
			keyclient_list |= M
		else if(M.key)
			key_list |= M
		else
			logged_list |= M
		old_list.Remove(named)
	var/list/new_list = list()
	new_list += AI_list
	new_list += keyclient_list
	new_list += key_list
	new_list += logged_list
	new_list += Dead_list
	return new_list

//Returns a list of all mobs with their name
/proc/getmobs()

	var/list/mobs = sortmobs()
	var/list/names = list()
	var/list/creatures = list()
	var/list/namecounts = list()
	for(var/mob/M in mobs)
		var/name = M.name
		if(name in names)
			namecounts[name]++
			name = "[name] ([namecounts[name]])"
		else
			names.Add(name)
			namecounts[name] = 1
		if(M.real_name && M.real_name != M.name)
			name += " \[[M.real_name]\]"
		if(M.stat == DEAD)
			if(istype(M, /mob/dead/observer/))
				name += " \[ghost\]"
			else
				name += " \[dead\]"
		creatures[name] = M

	return creatures

//Orders mobs by type then by name
/proc/sortmobs()
	var/list/moblist = list()
	var/list/sortmob = sortAtom(GLOB.mob_list)
	for(var/mob/living/silicon/ai/mob in sortmob)
		moblist.Add(mob)
		if(mob.eyeobj)
			moblist.Add(mob.eyeobj)
	for(var/mob/living/silicon/pai/mob in sortmob)
		moblist.Add(mob)
	for(var/mob/living/silicon/robot/mob in sortmob)
		moblist.Add(mob)
	for(var/mob/living/carbon/human/mob in sortmob)
		moblist.Add(mob)
	for(var/mob/living/carbon/true_devil/mob in sortmob)
		moblist.Add(mob)
	for(var/mob/living/carbon/brain/mob in sortmob)
		moblist.Add(mob)
	for(var/mob/living/carbon/alien/mob in sortmob)
		moblist.Add(mob)
	for(var/mob/dead/observer/mob in sortmob)
		moblist.Add(mob)
	for(var/mob/new_player/mob in sortmob)
		moblist.Add(mob)
	for(var/mob/living/simple_animal/slime/mob in sortmob)
		moblist.Add(mob)
	for(var/mob/living/simple_animal/mob in sortmob)
		moblist.Add(mob)
	for(var/mob/camera/blob/mob in sortmob)
		moblist.Add(mob)
	return moblist

// Format a power value in W, kW, MW, or GW.
/proc/DisplayPower(powerused)
	if(powerused < 1000) //Less than a kW
		return "[powerused] W"
	else if(powerused < 1000000) //Less than a MW
		return "[round((powerused * 0.001), 0.01)] kW"
	else if(powerused < 1000000000) //Less than a GW
		return "[round((powerused * 0.000001), 0.001)] MW"
	return "[round((powerused * 0.000000001), 0.0001)] GW"

//Forces a variable to be posative
/proc/modulus(var/M)
	if(M >= 0)
		return M
	if(M < 0)
		return -M

/proc/get_mob_by_ckey(key)
	if(!key)
		return

	for(var/mob/mob as anything in GLOB.player_list)
		if(mob.ckey != key)
			continue

		return mob

	for(var/mob/mob as anything in GLOB.left_player_list)
		if(mob.ckey != key)
			continue

		return mob

/proc/get_client_by_ckey(ckey)
	if(cmptext(copytext(ckey, 1, 2),"@"))
		ckey = findStealthKey(ckey)
	return GLOB.directory[ckey]


/proc/findStealthKey(txt)
	if(txt)
		for(var/P in GLOB.stealthminID)
			if(GLOB.stealthminID[P] == txt)
				return P




/*
Returns 1 if the chain up to the area contains the given typepath
0 otherwise
*/
/atom/proc/is_found_within(var/typepath)
	var/atom/A = src
	while(A.loc)
		if(istype(A.loc, typepath))
			return 1
		A = A.loc
	return 0








//Makes sure MIDDLE is between LOW and HIGH. If not, it adjusts it. Returns the adjusted value.
/proc/between(var/low, var/middle, var/high)
	return max(min(middle, high), low)

//returns random gauss number
/proc/GaussRand(var/sigma)
  var/x,y,rsq
  do
    x=2*rand()-1
    y=2*rand()-1
    rsq=x*x+y*y
  while(rsq>1 || !rsq)
  return sigma*y*sqrt(-2*log(rsq)/rsq)

//returns random gauss number, rounded to 'roundto'
/proc/GaussRandRound(var/sigma,var/roundto)
	return round(GaussRand(sigma),roundto)

//Will return the contents of an atom recursivly to a depth of 'searchDepth'
/atom/proc/GetAllContents(searchDepth = 5)
	var/list/toReturn = list()

	for(var/atom/part in contents)
		toReturn += part
		if(part.contents.len && searchDepth)
			toReturn += part.GetAllContents(searchDepth - 1)

	return toReturn

//Searches contents of the atom and returns the sum of all w_class of obj/item within
/atom/proc/GetTotalContentsWeight(searchDepth = 5)
	var/weight = 0
	var/list/content = GetAllContents(searchDepth)
	for(var/obj/item/I in content)
		weight += I.w_class
	return weight







//Takes: Area type as text string or as typepath OR an instance of the area.
//Returns: A list of all atoms	(objs, turfs, mobs) in areas of that type of that type in the world.
/proc/get_area_all_atoms(var/areatype)
	if(!areatype) return null
	if(istext(areatype)) areatype = text2path(areatype)
	if(isarea(areatype))
		var/area/areatemp = areatype
		areatype = areatemp.type

	var/list/atoms = new/list()
	for(var/area/N as anything in GLOB.areas)
		if(istype(N, areatype))
			for(var/atom/A in N)
				atoms += A
	return atoms

/datum/coords //Simple datum for storing coordinates.
	var/x_pos = null
	var/y_pos = null
	var/z_pos = null

/proc/DuplicateObject(obj/original, perfectcopy = FALSE , sameloc = FALSE, atom/newloc = null)
	if(!original)
		return null

	var/obj/O = null

	if(sameloc)
		O=new original.type(original.loc)
	else
		O=new original.type(newloc)

	if(perfectcopy)
		if(O)
			var/static/list/forbidden_vars = list("type","loc","locs","vars", "parent","parent_type", "verbs","ckey","key","power_supply","contents","reagents","stat","x","y","z","group", "comp_lookup", "datum_components")

			for(var/V in original.vars - forbidden_vars)
				if(istype(original.vars[V],/list))
					var/list/L = original.vars[V]
					O.vars[V] = L.Copy()
				else if(isdatum(original.vars[V]))
					continue	// this would reference the original's object, that will break when it is used or deleted.
				else
					O.vars[V] = original.vars[V]
	if(istype(O))
		O.update_icon()
	return O

// Я хочу чтобы этот прок умер
/area/proc/copy_contents_to(area/A , platingRequired = FALSE, perfect_copy = TRUE)
	//Takes: Area. Optional: If it should copy to areas that don't have plating
	//Returns: Nothing.
	//Notes: Attempts to move the contents of one area to another area.
	//       Movement based on lower left corner. Tiles that do not fit
	//		 into the new area will not be moved.

	if(!A || !src)
		return FALSE

	var/list/turfs_src = get_area_turfs(src.type)
	var/list/turfs_trg = get_area_turfs(A.type)

	var/src_min_x = 0
	var/src_min_y = 0
	for(var/turf/T in turfs_src)
		if(T.x < src_min_x || !src_min_x)
			src_min_x	= T.x
		if(T.y < src_min_y || !src_min_y)
			src_min_y	= T.y

	var/trg_min_x = 0
	var/trg_min_y = 0
	for(var/turf/T in turfs_trg)
		if(T.x < trg_min_x || !trg_min_x)
			trg_min_x	= T.x
		if(T.y < trg_min_y || !trg_min_y)
			trg_min_y	= T.y

	var/list/refined_src = new/list()
	for(var/turf/T in turfs_src)
		refined_src += T
		refined_src[T] = new/datum/coords
		var/datum/coords/C = refined_src[T]
		C.x_pos = (T.x - src_min_x)
		C.y_pos = (T.y - src_min_y)

	var/list/refined_trg = new/list()
	for(var/turf/T in turfs_trg)
		refined_trg += T
		refined_trg[T] = new/datum/coords
		var/datum/coords/C = refined_trg[T]
		C.x_pos = (T.x - trg_min_x)
		C.y_pos = (T.y - trg_min_y)

	var/list/toupdate = new/list()

	var/copiedobjs = list()


	moving:
		for(var/turf/T in refined_src)
			var/datum/coords/C_src = refined_src[T]
			for(var/turf/B in refined_trg)
				var/datum/coords/C_trg = refined_trg[B]
				if(C_src.x_pos == C_trg.x_pos && C_src.y_pos == C_trg.y_pos)
					var/old_dir1 = T.dir
					var/old_icon_state1 = T.icon_state
					var/old_icon1 = T.icon

					if(platingRequired)
						if(isspaceturf(B))
							continue moving
					var/turf/X = new T.type(B)
					X.dir = old_dir1
					X.icon_state = old_icon_state1
					X.icon = old_icon1 //Shuttle floors are in shuttle.dmi while the defaults are floors.dmi

					for(var/obj/O in T)
						copiedobjs += DuplicateObject(O, perfect_copy, newloc = X)

					for(var/mob/M in T)
						if(!M.move_on_shuttle)
							continue
						copiedobjs += DuplicateObject(M, perfect_copy, newloc = X)

					for(var/V in T.vars)
						if(!(V in list("type","loc","locs","vars", "parent", "parent_type","verbs","ckey","key","x","y","z","destination_z", "destination_x", "destination_y","contents", "luminosity", "group")))
							X.vars[V] = T.vars[V]

					toupdate += X

					refined_src -= T
					refined_trg -= B
					continue moving



	if(toupdate.len)
		for(var/turf/simulated/T1 in toupdate)
			T1.CalculateAdjacentTurfs()
			SSair.add_to_active(T1,1)


	return copiedobjs





/proc/view_or_range(distance = world.view , center = usr , type)
	switch(type)
		if("view")
			. = view(distance,center)
		if("range")
			. = range(distance,center)
	return

/proc/oview_or_orange(distance = world.view , center = usr , type)
	switch(type)
		if("view")
			. = oview(distance,center)
		if("range")
			. = orange(distance,center)
	return

/proc/get_mob_with_client_list()
	var/list/mobs = list()
	for(var/mob/M in GLOB.mob_list)
		if(M.client)
			mobs += M
	return mobs

GLOBAL_LIST_INIT(body_zone, list(
	BODY_ZONE_HEAD = list(NOMINATIVE = "голова", GENITIVE = "головы", DATIVE = "голове", ACCUSATIVE = "голову", INSTRUMENTAL = "головой", PREPOSITIONAL = "голове"),
    BODY_ZONE_CHEST = list(NOMINATIVE = "грудь", GENITIVE = "груди", DATIVE = "груди", ACCUSATIVE = "грудь", INSTRUMENTAL = "грудью", PREPOSITIONAL = "груди"),
    BODY_ZONE_L_ARM = list(NOMINATIVE = "левая рука", GENITIVE = "левой руки", DATIVE = "левой руке", ACCUSATIVE = "левую руку", INSTRUMENTAL = "левой рукой", PREPOSITIONAL = "левой руке"),
    BODY_ZONE_R_ARM = list(NOMINATIVE = "правая рука", GENITIVE = "правой руки", DATIVE = "правой руке", ACCUSATIVE = "правую руку", INSTRUMENTAL = "правой рукой", PREPOSITIONAL = "правой руке"),
    BODY_ZONE_L_LEG = list(NOMINATIVE = "левая нога", GENITIVE = "левой ноги", DATIVE = "левой ноге", ACCUSATIVE = "левую ногу", INSTRUMENTAL = "левой ногой", PREPOSITIONAL = "левой ноге"),
    BODY_ZONE_R_LEG = list(NOMINATIVE = "правая нога", GENITIVE = "правой ноги", DATIVE = "правой ноге", ACCUSATIVE = "правую ногу", INSTRUMENTAL = "правой ногой", PREPOSITIONAL = "правой ноге"),
    BODY_ZONE_TAIL = list(NOMINATIVE = "хвост", GENITIVE = "хвоста", DATIVE = "хвосту", ACCUSATIVE = "хвост", INSTRUMENTAL = "хвостом", PREPOSITIONAL = "хвосте"),
    BODY_ZONE_WING = list(NOMINATIVE = "крылья", GENITIVE = "крыльев", DATIVE = "крыльям", ACCUSATIVE = "крылья", INSTRUMENTAL = "крыльями", PREPOSITIONAL = "крыльях"),
    BODY_ZONE_PRECISE_EYES = list(NOMINATIVE = "глаза", GENITIVE = "глаз", DATIVE = "глазам", ACCUSATIVE = "глаза", INSTRUMENTAL = "глазами", PREPOSITIONAL = "глазах"),
    BODY_ZONE_PRECISE_MOUTH = list(NOMINATIVE = "рот", GENITIVE = "рта", DATIVE = "рту", ACCUSATIVE = "рот", INSTRUMENTAL = "ртом", PREPOSITIONAL = "рте"),
    BODY_ZONE_PRECISE_GROIN = list(NOMINATIVE = "живот", GENITIVE = "живота", DATIVE = "животу", ACCUSATIVE = "живот", INSTRUMENTAL = "животом", PREPOSITIONAL = "животе"),
    BODY_ZONE_PRECISE_L_HAND = list(NOMINATIVE = "левая кисть", GENITIVE = "левой кисти", DATIVE = "левой кисти", ACCUSATIVE = "левую кисть", INSTRUMENTAL = "левой кистью", PREPOSITIONAL = "левой кисти"),
    BODY_ZONE_PRECISE_R_HAND = list(NOMINATIVE = "правая кисть", GENITIVE = "правой кисти", DATIVE = "правой кисти", ACCUSATIVE = "правую кисть", INSTRUMENTAL = "правой кистью", PREPOSITIONAL = "правой кисти"),
    BODY_ZONE_PRECISE_L_FOOT = list(NOMINATIVE = "левая ступня", GENITIVE = "левой ступни", DATIVE = "левой ступне", ACCUSATIVE = "левую ступню", INSTRUMENTAL = "левой ступнёй", PREPOSITIONAL = "левой ступне"),
    BODY_ZONE_PRECISE_R_FOOT = list(NOMINATIVE = "правая ступня", GENITIVE = "правой ступни", DATIVE = "правой ступне", ACCUSATIVE = "правую ступню", INSTRUMENTAL = "правой ступнёй", PREPOSITIONAL = "правой ступне")
))

/proc/parse_zone(zone)
	switch(zone)
		if(BODY_ZONE_HEAD)
			return "голова"
		if(BODY_ZONE_CHEST)
			return "грудь"
		if(BODY_ZONE_L_ARM)
			return "левая рука"
		if(BODY_ZONE_R_ARM)
			return "правая рука"
		if(BODY_ZONE_L_LEG)
			return "левая нога"
		if(BODY_ZONE_R_LEG)
			return "правая нога"
		if(BODY_ZONE_TAIL)
			return "хвост"
		if(BODY_ZONE_WING)
			return "крылья"
		if(BODY_ZONE_PRECISE_EYES)
			return "глаза"
		if(BODY_ZONE_PRECISE_MOUTH)
			return "рот"
		if(BODY_ZONE_PRECISE_GROIN)
			return "живот"
		if(BODY_ZONE_PRECISE_L_HAND)
			return "левая кисть"
		if(BODY_ZONE_PRECISE_R_HAND)
			return "правая кисть"
		if(BODY_ZONE_PRECISE_L_FOOT)
			return "левая ступня"
		if(BODY_ZONE_PRECISE_R_FOOT)
			return "правая ступня"
		else
			stack_trace("Wrong zone input.")



//Finds the distance between two atoms, in pixels
//centered = 0 counts from turf edge to edge
//centered = 1 counts from turf center to turf center
//of course mathematically this is just adding world.icon_size on again
/proc/getPixelDistance(var/atom/A, var/atom/B, var/centered = 1)
	if(!istype(A)||!istype(B))
		return 0
	. = bounds_dist(A, B) + sqrt((((A.pixel_x+B.pixel_x)**2) + ((A.pixel_y+B.pixel_y)**2)))
	if(centered)
		. += world.icon_size



/proc/get_turf_or_move(turf/location)
	return get_turf(location)


//For objects that should embed, but make no sense being is_sharp or is_pointed()
//e.g: rods
GLOBAL_LIST_INIT(can_embed_types, typecacheof(list(
	/obj/item/stack/rods,
	/obj/item/pipe)))

/proc/can_embed(obj/item/W)
	if(is_sharp(W))
		return 1
	if(is_pointed(W))
		return 1

	if(is_type_in_typecache(W, GLOB.can_embed_types))
		return 1

//Whether or not the given item counts as sharp in terms of dealing damage
/proc/is_sharp(obj/item/item)
	if(!istype(item))
		return FALSE
	if(item.sharp)
		return TRUE
	return FALSE

/proc/reverse_direction(var/dir)
	switch(dir)
		if(NORTH)
			return SOUTH
		if(NORTHEAST)
			return SOUTHWEST
		if(EAST)
			return WEST
		if(SOUTHEAST)
			return NORTHWEST
		if(SOUTH)
			return NORTH
		if(SOUTHWEST)
			return NORTHEAST
		if(WEST)
			return EAST
		if(NORTHWEST)
			return SOUTHEAST
		if(UP)
			return DOWN
		if(DOWN)
			return UP

/*
Checks if that loc and dir has a item on the wall
*/
GLOBAL_LIST_INIT(wall_items, typecacheof(list(/obj/machinery/power/apc, /obj/machinery/alarm,
	/obj/item/radio/intercom, /obj/structure/extinguisher_cabinet, /obj/structure/reagent_dispensers/peppertank,
	/obj/machinery/status_display, /obj/machinery/requests_console, /obj/machinery/light_switch, /obj/structure/sign,
	/obj/machinery/newscaster, /obj/machinery/firealarm, /obj/structure/noticeboard, /obj/machinery/door_control,
	/obj/machinery/computer/security/telescreen, /obj/machinery/embedded_controller/radio/airlock,
	/obj/item/storage/secure/safe, /obj/machinery/door_timer, /obj/machinery/flasher, /obj/machinery/keycard_auth,
	/obj/structure/mirror, /obj/structure/closet/fireaxecabinet, /obj/machinery/computer/security/telescreen/entertainment,
	/obj/structure/sign)))

/proc/gotwallitem(loc, dir)
	for(var/obj/O in loc)
		if(is_type_in_typecache(O, GLOB.wall_items))
			//Direction works sometimes
			if(O.dir == dir)
				return 1

			//Some stuff doesn't use dir properly, so we need to check pixel instead
			switch(dir)
				if(SOUTH)
					if(O.pixel_y > 10)
						return 1
				if(NORTH)
					if(O.pixel_y < -10)
						return 1
				if(WEST)
					if(O.pixel_x > 10)
						return 1
				if(EAST)
					if(O.pixel_x < -10)
						return 1

	//Some stuff is placed directly on the wallturf (signs)
	for(var/obj/O in get_step(loc, dir))
		if(is_type_in_typecache(O, GLOB.wall_items))
			if(abs(O.pixel_x) <= 10 && abs(O.pixel_y) <= 10)
				return 1
	return 0


/proc/get_angle(atom/a, atom/b)
	return atan2(b.y - a.y, b.x - a.x)

/proc/atan2(x, y)
	if(!x && !y) return 0
	return y >= 0 ? arccos(x / sqrt(x * x + y * y)) : -arccos(x / sqrt(x * x + y * y))

/proc/format_text(text)
	return replacetext(replacetext(text,"\proper ",""),"\improper ","")

/*
Standard way to write links -Sayu
*/

/proc/topic_link(var/datum/D, var/arglist, var/content)
	if(istype(arglist,/list))
		arglist = list2params(arglist)
	return "<a href='byond://?src=[D.UID()];[arglist]'>[content]</a>"


// This proc is made to check if we can interact or use (directly or in the other way) the specific bodypart
// Not to check if one clothing blocks access to the other clothing
// for that we have flags_inv var
/proc/get_location_accessible(mob/M, location)
	var/covered_locations	= 0	//based on body_parts_covered
	var/eyesmouth_covered	= 0	//based on flags_cover
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		for(var/obj/item/clothing/I in list(C.back, C.wear_mask))
			covered_locations |= I.body_parts_covered
			eyesmouth_covered |= I.flags_cover
		if(ishuman(C))
			var/mob/living/carbon/human/H = C
			for(var/obj/item/I in list(H.wear_suit, H.w_uniform, H.shoes, H.belt, H.gloves, H.glasses, H.head, H.r_ear, H.l_ear, H.neck))
				covered_locations |= I.body_parts_covered
				eyesmouth_covered |= I.flags_cover
	// If we check for mouth or eyes for gods sake use the appropriate flags for THEM!
	// Not for the face, head e.t.c.
	// HIDENAME(formerly known as HIDEFACE) flag was made to check if we appear as unknown
	// HIDEGLASSES(formerly known as HIDEEYES) flag was made, ironically, to check if it hides our GLASSES
	// not to check if it makes using the fucking mouth/eyes impossible!!!
	switch(location)
		if(BODY_ZONE_HEAD)
			if(covered_locations & HEAD)
				return FALSE
		if(BODY_ZONE_PRECISE_EYES)
			if(eyesmouth_covered & MASKCOVERSEYES || eyesmouth_covered & GLASSESCOVERSEYES || eyesmouth_covered & HEADCOVERSEYES)
				return FALSE
		if(BODY_ZONE_PRECISE_MOUTH)
			if(eyesmouth_covered & HEADCOVERSMOUTH || eyesmouth_covered & MASKCOVERSMOUTH)
				return FALSE
		if(BODY_ZONE_CHEST)
			if(covered_locations & UPPER_TORSO)
				return FALSE
		if(BODY_ZONE_PRECISE_GROIN)
			if(covered_locations & LOWER_TORSO)
				return FALSE
		if(BODY_ZONE_L_ARM)
			if(covered_locations & ARM_LEFT)
				return FALSE
		if(BODY_ZONE_R_ARM)
			if(covered_locations & ARM_RIGHT)
				return FALSE
		if(BODY_ZONE_L_LEG)
			if(covered_locations & LEG_LEFT)
				return FALSE
		if(BODY_ZONE_R_LEG)
			if(covered_locations & LEG_RIGHT)
				return FALSE
		if(BODY_ZONE_PRECISE_L_HAND)
			if(covered_locations & HAND_LEFT)
				return FALSE
		if(BODY_ZONE_PRECISE_R_HAND)
			if(covered_locations & HAND_RIGHT)
				return FALSE
		if(BODY_ZONE_PRECISE_L_FOOT)
			if(covered_locations & FOOT_LEFT)
				return FALSE
		if(BODY_ZONE_PRECISE_R_FOOT)
			if(covered_locations & FOOT_RIGHT)
				return FALSE

	return TRUE

/proc/check_target_facings(mob/living/initator, mob/living/target)
	/*This can be used to add additional effects on interactions between mobs depending on how the mobs are facing each other, such as adding a crit damage to blows to the back of a guy's head.
	Given how click code currently works (Nov '13), the initiating mob will be facing the target mob most of the time
	That said, this proc should not be used if the change facing proc of the click code is overriden at the same time*/
	if(!ismob(target) || target.body_position == LYING_DOWN)
	//Make sure we are not doing this for things that can't have a logical direction to the players given that the target would be on their side
		return FACING_FAILED
	if(initator.dir == target.dir) //mobs are facing the same direction
		return FACING_SAME_DIR
	if(is_A_facing_B(initator, target) && is_A_facing_B(target, initator)) //mobs are facing each other
		return FACING_EACHOTHER
	if(initator.dir + 2 == target.dir || initator.dir - 2 == target.dir || initator.dir + 6 == target.dir || initator.dir - 6 == target.dir) //Initating mob is looking at the target, while the target mob is looking in a direction perpendicular to the 1st
		return FACING_INIT_FACING_TARGET_TARGET_FACING_PERPENDICULAR


/atom/proc/GetTypeInAllContents(typepath)
	var/list/processing_list = list(src)
	var/list/processed = list()

	var/atom/found = null

	while(processing_list.len && found==null)
		var/atom/A = processing_list[1]
		if(istype(A, typepath))
			found = A

		processing_list -= A

		for(var/atom/a in A)
			if(!(a in processed))
				processing_list |= a

		processed |= A

	return found



/proc/get_random_colour(var/simple, var/lower, var/upper)
	var/colour
	if(simple)
		colour = pick(list("FF0000","FF7F00","FFFF00","00FF00","0000FF","4B0082","8F00FF"))
	else
		for(var/i=1;i<=3;i++)
			var/temp_col = "[num2hex(rand(lower, upper), 2)]"
			if(length(temp_col )<2)
				temp_col  = "0[temp_col]"
			colour += temp_col
	return colour

/proc/get_distant_turf(var/turf/T,var/direction,var/distance)
	if(!T || !direction || !distance)	return

	var/dest_x = T.x
	var/dest_y = T.y
	var/dest_z = T.z

	if(direction & NORTH)
		dest_y = min(world.maxy, dest_y+distance)
	if(direction & SOUTH)
		dest_y = max(0, dest_y-distance)
	if(direction & EAST)
		dest_x = min(world.maxy, dest_x+distance)
	if(direction & WEST)
		dest_x = max(0, dest_x-distance)

	return locate(dest_x,dest_y,dest_z)

GLOBAL_DATUM_INIT(dview_mob, /mob/dview, new)

//Version of view() which ignores darkness, because BYOND doesn't have it.
/proc/dview(var/range = world.view, var/center, var/invis_flags = 0)
	if(!center)
		return

	GLOB.dview_mob.loc = center

	GLOB.dview_mob.set_invis_see(invis_flags)

	. = view(range, GLOB.dview_mob)
	GLOB.dview_mob.loc = null

/mob/dview
	invisibility = INVISIBILITY_ABSTRACT
	density = FALSE
	move_force = 0
	pull_force = 0
	move_resist = INFINITY
	simulated = 0


/mob/dview/New() //For whatever reason, if this isn't called, then BYOND will throw a type mismatch runtime when attempting to add this to the mobs list. -Fox
	SHOULD_CALL_PARENT(FALSE)

/mob/dview/Destroy()
	SHOULD_CALL_PARENT(FALSE)
	// should never be deleted
	return QDEL_HINT_LETMELIVE

/proc/IsValidSrc(A)
	if(isdatum(A))
		var/datum/D = A
		return !QDELETED(D)
	if(isclient(A))
		return TRUE
	return FALSE











//Get the dir to the RIGHT of dir if they were on a clock
//NORTH --> NORTHEAST
/proc/get_clockwise_dir(dir)
	. = angle2dir(dir2angle(dir)+45)

//Get the dir to the LEFT of dir if they were on a clock
//NORTH --> NORTHWEST
/proc/get_anticlockwise_dir(dir)
	. = angle2dir(dir2angle(dir)-45)


//Compare A's dir, the clockwise dir of A and the anticlockwise dir of A
//To the opposite dir of the dir returned by get_dir(B,A)
//If one of them is a match, then A is facing B
/proc/is_A_facing_B(atom/A, atom/B)
	if(!istype(A) || !istype(B))
		return 0
	if(isliving(A))
		var/mob/living/LA = A
		if(LA.body_position == LYING_DOWN)
			return 0
	var/goal_dir = angle2dir(dir2angle(get_dir(B, A)+180))
	var/clockwise_A_dir = get_clockwise_dir(A.dir)
	var/anticlockwise_A_dir = get_anticlockwise_dir(B.dir)

	if(A.dir == goal_dir || clockwise_A_dir == goal_dir || anticlockwise_A_dir == goal_dir)
		return 1
	return 0

//This is just so you can stop an orbit.
//orbit() can run without it (swap orbiting for A)
//but then you can never stop it and that's just silly.
/atom/movable/var/atom/orbiting = null
/atom/movable/var/cached_transform = null
//A: atom to orbit
//radius: range to orbit at, radius of the circle formed by orbiting
//clockwise: whether you orbit clockwise or anti clockwise
//rotation_speed: how fast to rotate
//rotation_segments: the resolution of the orbit circle, less = a more block circle, this can be used to produce hexagons (6 segments) triangles (3 segments), and so on, 36 is the best default.
//pre_rotation: Chooses to rotate src 90 degress towards the orbit dir (clockwise/anticlockwise), useful for things to go "head first" like ghosts
//lockinorbit: Forces src to always be on A's turf, otherwise the orbit cancels when src gets too far away (eg: ghosts)

/atom/movable/proc/orbit(atom/A, radius = 10, clockwise = FALSE, rotation_speed = 20, rotation_segments = 36, pre_rotation = TRUE, lockinorbit = FALSE, forceMove = FALSE)
	if(!istype(A))
		return

	if(orbiting)
		stop_orbit()

	orbiting = A
	LAZYOR(A.orbiters, src)
	SEND_SIGNAL(orbiting, COMSIG_ATOM_ORBIT_BEGIN, src)
	if(ismob(A))
		var/mob/M = A
		M.ghost_orbiting += 1
	var/matrix/initial_transform = matrix(transform)
	cached_transform = initial_transform
	var/lastloc = loc

	//Head first!
	if(pre_rotation)
		var/matrix/M = matrix(transform)
		var/pre_rot = 90
		if(!clockwise)
			pre_rot = -90
		M.Turn(pre_rot)
		transform = M

	var/matrix/shift = matrix(transform)
	shift.Translate(0,radius)
	transform = shift

	SpinAnimation(rotation_speed, -1, clockwise, rotation_segments, parallel = FALSE)

	while(orbiting && orbiting == A && A.loc)
		var/targetloc = get_turf(A)
		if(!targetloc || (!lockinorbit && loc != lastloc && loc != targetloc))
			break
		if(forceMove)
			forceMove(targetloc)
		else
			loc = targetloc
		lastloc = loc
		var/atom/movable/B = A
		if(istype(B))
			glide_size = B.glide_size
		sleep(0.6)

	if(orbiting == A) //make sure we haven't started orbiting something else.
		stop_orbit()


/atom/movable/proc/stop_orbit()
	if(ismob(orbiting))
		var/mob/M = orbiting
		M.ghost_orbiting -= 1

	SEND_SIGNAL(orbiting, COMSIG_ATOM_ORBIT_STOP, src)
	LAZYREMOVE(orbiting.orbiters, src)
	orbiting = null
	transform = cached_transform
	SpinAnimation(0, 0, parallel = FALSE)
	// После, потому что сначало надо занулить orbiting дабы худ показался ЧИСТЫЙ
	SEND_SIGNAL(src, COMSIG_ORBITER_ORBIT_STOP)


//Centers an image.
//Requires:
//The Image
//The x dimension of the icon file used in the image
//The y dimension of the icon file used in the image
// eg: center_image(I, 32,32)
// eg2: center_image(I, 96,96)
/proc/center_image(image/I, x_dimension = 0, y_dimension = 0)
	if(!I)
		return

	if(!x_dimension || !y_dimension)
		return

	//Get out of here, punk ass kids calling procs needlessly
	if((x_dimension == world.icon_size) && (y_dimension == world.icon_size))
		return I

	//Offset the image so that it's bottom left corner is shifted this many pixels
	//This makes it infinitely easier to draw larger inhands/images larger than world.iconsize
	//but still use them in game
	var/x_offset = -((x_dimension/world.icon_size)-1)*(world.icon_size*0.5)
	var/y_offset = -((y_dimension/world.icon_size)-1)*(world.icon_size*0.5)

	//Correct values under world.icon_size
	if(x_dimension < world.icon_size)
		x_offset *= -1
	if(y_dimension < world.icon_size)
		y_offset *= -1

	I.pixel_x = x_offset
	I.pixel_y = y_offset

	return I





/proc/urange_multiz(dist=0, atom/center=usr, orange=0, areas=0)
	if(!dist)
		if(!orange)
			return list(center)
		else
			return list()
	var/list/stations_z = levels_by_trait(STATION_LEVEL)
	var/min_z = max(center.z - dist, stations_z[1])
	var/max_z = min(center.z + dist, stations_z[length(stations_z)])
	var/list/turfs = RANGE_TURFS_MULTIZ(dist, center, min_z, max_z)
	if(orange)
		turfs -= get_turf(center)
	. = list()
	for(var/V in turfs)
		var/turf/T = V
		. += T
		. += T.contents
		if(areas)
			. |= T.loc

/proc/is_there_multiz()
	return SSmapping?.map_datum?.traits?.len > 1


/proc/screen_loc2turf(scr_loc, turf/origin)
	var/tX = splittext(scr_loc, ",")
	var/tY = splittext(tX[2], ":")
	var/tZ = origin.z
	tY = tY[1]
	tX = splittext(tX[1], ":")
	tX = tX[1]
	tX = max(1, min(world.maxx, origin.x + (text2num(tX) - (world.view + 1))))
	tY = max(1, min(world.maxy, origin.y + (text2num(tY) - (world.view + 1))))
	return locate(tX, tY, tZ)





//Key thing that stops lag. Cornerstone of performance in ss13, Just sitting here, in unsorted.dm.

//Increases delay as the server gets more overloaded,
//as sleeps aren't cheap and sleeping only to wake up and sleep again is wasteful
#define DELTA_CALC max(((max(TICK_USAGE, world.cpu) / 100) * max(Master.sleep_delta-1,1)), 1)

//returns the number of ticks slept
/proc/stoplag(initial_delay)
	if (!Master || Master.init_stage_completed < INITSTAGE_MAX)
		sleep(world.tick_lag)
		return 1
	if(!initial_delay)
		initial_delay = world.tick_lag
	. = 0
	var/i = DS2TICKS(initial_delay)
	do
		. += CEILING(i*DELTA_CALC, 1)
		sleep(i*world.tick_lag*DELTA_CALC)
		i *= 2
	while(TICK_USAGE > min(TICK_LIMIT_TO_RUN, Master.current_ticklimit))

#undef DELTA_CALC

/*
 * This proc gets a list of all "points of interest" (poi's) that can be used by admins to track valuable mobs or atoms (such as the nuke disk).
 * @param mobs_only if set to TRUE it won't include locations to the returned list
 * @param skip_mindless if set to TRUE it will skip mindless mobs
 * @param force_include_bots if set to TRUE it will include bots even if skip_mindless is set to TRUE
 * @param force_include_cameras if set to TRUE it will include camera eyes even if skip_mindless is set to TRUE
 * @return returns a list with the found points of interest
*/
/proc/getpois(mobs_only = FALSE, skip_mindless = FALSE, force_include_bots = FALSE, force_include_cameras = FALSE)
	var/list/mobs = sortmobs()
	var/list/names = list()
	var/list/pois = list()
	var/list/namecounts = list()

	for(var/mob/M in mobs)
		if(skip_mindless && (!M.mind && !M.ckey))
			if(!(force_include_bots && isbot(M)) && !(force_include_cameras && istype(M, /mob/camera)))
				continue
		if(M.client && M.client.holder && M.client.holder.fakekey) //stealthmins
			continue
		var/name = M.name
		if(name in names)
			namecounts[name]++
			name = "[name] ([namecounts[name]])"
		else
			names.Add(name)
			namecounts[name] = 1
		if(M.real_name && M.real_name != M.name)
			name += " \[[M.real_name]\]"
		if(M.stat == DEAD)
			if(istype(M, /mob/dead/observer/))
				name += " \[ghost\]"
			else
				name += " \[dead\]"
		pois[name] = M

	if(!mobs_only)
		for(var/atom/A in GLOB.poi_list)
			if(!A || !A.loc)
				continue
			var/name = A.name
			if(names.Find(name))
				namecounts[name]++
				name = "[name] ([namecounts[name]])"
			else
				names.Add(name)
				namecounts[name] = 1
			pois[name] = A

	return pois

/proc/get_observers()
	var/list/ghosts = list()
	for(var/mob/dead/observer/M in GLOB.player_list) // for every observer with a client
		ghosts += M

	return ghosts

/proc/flash_color(mob_or_client, flash_color=COLOR_CULT_RED, flash_time=20)
	var/client/C
	if(istype(mob_or_client, /mob))
		var/mob/M = mob_or_client
		if(M.client)
			C = M.client
		else
			return
	else if(isclient(mob_or_client))
		C = mob_or_client

	if(!istype(C))
		return

	C.color = flash_color
	spawn(0)
		animate(C, color = initial(C.color), time = flash_time)

#define RANDOM_COLOUR (rgb(rand(0,255),rand(0,255),rand(0,255)))

/proc/make_bit_triplet()
	var/list/num_sample  = list(1, 2, 3, 4, 5, 6, 7, 8, 9)
	var/result = 0
	for(var/i = 0, i < 3, i++)
		var/num = pick(num_sample)
		num_sample -= num
		result += (1 << num)
	return result

/proc/pixel_shift_dir(var/dir, var/amount_x = 32, var/amount_y = 32) //Returns a list with pixel_shift values that will shift an object's icon one tile in the direction passed.
	amount_x = min(max(0, amount_x), 32) //No less than 0, no greater than 32.
	amount_y = min(max(0, amount_x), 32)
	var/list/shift = list("x" = 0, "y" = 0)
	switch(dir)
		if(NORTH)
			shift["y"] = amount_y
		if(SOUTH)
			shift["y"] = -amount_y
		if(EAST)
			shift["x"] = amount_x
		if(WEST)
			shift["x"] = -amount_x
		if(NORTHEAST)
			shift = list("x" = amount_x, "y" = amount_y)
		if(NORTHWEST)
			shift = list("x" = -amount_x, "y" = amount_y)
		if(SOUTHEAST)
			shift = list("x" = amount_x, "y" = -amount_y)
		if(SOUTHWEST)
			shift = list("x" = -amount_x, "y" = -amount_y)

	return shift

/**
  * Returns a list of atoms in a location of a given type. Can be refined to look for pixel-shift.
  *
  * Arguments:
  * * loc - The atom to look in.
  * * type - The type to look for.
  * * check_shift - If true, will exclude atoms whose pixel_x/pixel_y do not match shift_x/shift_y.
  * * shift_x - If check_shift is true, atoms whose pixel_x is different to this will be excluded.
  * * shift_y - If check_shift is true, atoms whose pixel_y is different to this will be excluded.
  */
/proc/get_atoms_of_type(atom/loc, type, check_shift = FALSE, shift_x = 0, shift_y = 0)
	. = list()
	if(!loc)
		return
	for(var/atom/A as anything in loc)
		if(!istype(A, type))
			continue
		if(check_shift && !(A.pixel_x == shift_x && A.pixel_y == shift_y))
			continue
		. += A


/atom/proc/Shake(pixelshiftx = 15, pixelshifty = 15, duration = 250)
	var/initialpixelx = pixel_x
	var/initialpixely = pixel_y
	var/shiftx = rand(-pixelshiftx,pixelshiftx)
	var/shifty = rand(-pixelshifty,pixelshifty)
	animate(src, pixel_x = pixel_x + shiftx, pixel_y = pixel_y + shifty, time = 0.2, loop = duration)
	pixel_x = initialpixelx
	pixel_y = initialpixely





/proc/params2turf(scr_loc, turf/origin, client/C)
	if(!scr_loc)
		return null
	var/tX = splittext(scr_loc, ",")
	var/tY = splittext(tX[2], ":")
	var/tZ = origin.z
	tY = tY[1]
	tX = splittext(tX[1], ":")
	tX = tX[1]
	var/list/actual_view = getviewsize(C ? C.view : world.view)
	tX = clamp(origin.x + text2num(tX) - round(actual_view[1] / 2) - 1, 1, world.maxx)
	tY = clamp(origin.y + text2num(tY) - round(actual_view[2] / 2) - 1, 1, world.maxy)
	return locate(tX, tY, tZ)

/proc/CallAsync(datum/source, proctype, list/arguments)
	set waitfor = FALSE
	return call(source, proctype)(arglist(arguments))

/proc/IsFrozen(atom/A)
	if(A in GLOB.frozen_atom_list)
		return TRUE
	return FALSE

/**
 * Proc which gets all adjacent turfs to `src`, including the turf that `src` is on.
 *
 * This is similar to doing `for(var/turf/T in range(1, src))`. However it is slightly more performant.
 * Additionally, the above proc becomes more costly the more atoms there are nearby. This proc does not care about that.
 */
/atom/proc/get_all_adjacent_turfs()
	var/turf/src_turf = get_turf(src)
	var/list/_list = list(
		src_turf,
		get_step(src_turf, NORTH),
		get_step(src_turf, NORTHEAST),
		get_step(src_turf, NORTHWEST),
		get_step(src_turf, SOUTH),
		get_step(src_turf, SOUTHEAST),
		get_step(src_turf, SOUTHWEST),
		get_step(src_turf, EAST),
		get_step(src_turf, WEST)
	)
	return _list


/**
  * Returns the clean name of an audio channel.
  *
  * Arguments:
  * * channel - The channel number.
  */
/proc/get_channel_name(channel)
	switch(channel)
		if(CHANNEL_GENERAL)
			return "Основные звуки"
		if(CHANNEL_LOBBYMUSIC)
			return "Музыка в лобби"
		if(CHANNEL_ADMIN)
			return "Админские MIDI"
		if(CHANNEL_VOX)
			return "Оповещения ИИ"
		if(CHANNEL_JUKEBOX)
			return "Танцевальные машины"
		if(CHANNEL_HEARTBEAT)
			return "Сердцебиение"
		if(CHANNEL_BUZZ)
			return "Белый шум"
		if(CHANNEL_AMBIENCE)
			return "Эмбиент"
		if(CHANNEL_TTS_LOCAL)
			return "TTS рядом"
		if(CHANNEL_TTS_RADIO)
			return "TTS в радиосвязи"
		if(CHANNEL_RADIO_NOISE)
			return "Звуки радиосвязи"
		if(CHANNEL_INTERACTION_SOUNDS)
			return "Звуки взаимодействия с предметами"
		if(CHANNEL_BOSS_MUSIC)
			return "Музыка боссов"

/proc/get_compass_dir(atom/start, atom/end) //get_dir() only considers an object to be north/south/east/west if there is zero deviation. This uses rounding instead. // Ported from CM-SS13
	if(!start || !end)
		return 0
	if(!start.z || !end.z)
		return 0 //Atoms are not on turfs.

	var/dy = end.y - start.y
	var/dx = end.x - start.x
	if(!dy)
		return (dx >= 0) ? 4 : 8

	var/angle = arctan(dx / dy)
	if(dy < 0)
		angle += 180
	else if(dx < 0)
		angle += 360

	switch(angle) //diagonal directions get priority over straight directions in edge cases
		if (22.5 to 67.5)
			return NORTHEAST
		if (112.5 to 157.5)
			return SOUTHEAST
		if (202.5 to 247.5)
			return SOUTHWEST
		if (292.5 to 337.5)
			return NORTHWEST
		if (0 to 22.5)
			return NORTH
		if (67.5 to 112.5)
			return EAST
		if (157.5 to 202.5)
			return SOUTH
		if (247.5 to 292.5)
			return WEST
		else
			return NORTH

/proc/slot_string_to_slot_bitfield(input_string) //Doesn't work with right/left hands (diffrent var is used), l_/r_ stores and PDA (they dont have icons)
	switch(input_string)
		if(ITEM_SLOT_EAR_LEFT_STRING)
			return ITEM_SLOT_EAR_LEFT
		if(ITEM_SLOT_EAR_RIGHT_STRING)
			return ITEM_SLOT_EAR_RIGHT
		if(ITEM_SLOT_BELT_STRING)
			return ITEM_SLOT_BELT
		if(ITEM_SLOT_BACK_STRING)
			return ITEM_SLOT_BACK
		if(ITEM_SLOT_CLOTH_OUTER_STRING)
			return ITEM_SLOT_CLOTH_OUTER
		if(ITEM_SLOT_CLOTH_INNER_STRING)
			return ITEM_SLOT_CLOTH_INNER
		if(ITEM_SLOT_EYES_STRING)
			return ITEM_SLOT_EYES
		if(ITEM_SLOT_MASK_STRING)
			return ITEM_SLOT_MASK
		if(ITEM_SLOT_HEAD_STRING)
			return ITEM_SLOT_HEAD
		if(ITEM_SLOT_FEET_STRING)
			return ITEM_SLOT_FEET
		if(ITEM_SLOT_ID_STRING)
			return ITEM_SLOT_ID
		if(ITEM_SLOT_NECK_STRING)
			return ITEM_SLOT_NECK
		if(ITEM_SLOT_GLOVES_STRING)
			return ITEM_SLOT_GLOVES
		if(ITEM_SLOT_SUITSTORE_STRING)
			return ITEM_SLOT_SUITSTORE
		if(ITEM_SLOT_HANDCUFFED_STRING)
			return ITEM_SLOT_HANDCUFFED
		if(ITEM_SLOT_LEGCUFFED_STRING)
			return ITEM_SLOT_LEGCUFFED
		if(ITEM_SLOT_ACCESSORY_STRING)
			return ITEM_SLOT_ACCESSORY

/proc/slot_bitfield_to_slot_string(input_bitfield) //Doesn't work with right/left hands (diffrent var is used), l_/r_ stores and PDA (they dont render)
	switch(input_bitfield)
		if(ITEM_SLOT_EAR_LEFT)
			return ITEM_SLOT_EAR_LEFT_STRING
		if(ITEM_SLOT_EAR_RIGHT)
			return ITEM_SLOT_EAR_RIGHT_STRING
		if(ITEM_SLOT_BELT)
			return ITEM_SLOT_BELT_STRING
		if(ITEM_SLOT_BACK)
			return ITEM_SLOT_BACK_STRING
		if(ITEM_SLOT_CLOTH_OUTER)
			return ITEM_SLOT_CLOTH_OUTER_STRING
		if(ITEM_SLOT_CLOTH_INNER)
			return ITEM_SLOT_CLOTH_INNER_STRING
		if(ITEM_SLOT_GLOVES)
			return ITEM_SLOT_GLOVES_STRING
		if(ITEM_SLOT_EYES)
			return ITEM_SLOT_EYES_STRING
		if(ITEM_SLOT_MASK)
			return ITEM_SLOT_MASK_STRING
		if(ITEM_SLOT_HEAD)
			return ITEM_SLOT_HEAD_STRING
		if(ITEM_SLOT_FEET)
			return ITEM_SLOT_FEET_STRING
		if(ITEM_SLOT_ID)
			return ITEM_SLOT_ID_STRING
		if(ITEM_SLOT_NECK)
			return ITEM_SLOT_NECK_STRING
		if(ITEM_SLOT_SUITSTORE)
			return ITEM_SLOT_SUITSTORE_STRING
		if(ITEM_SLOT_HANDCUFFED)
			return ITEM_SLOT_HANDCUFFED_STRING
		if(ITEM_SLOT_LEGCUFFED)
			return ITEM_SLOT_LEGCUFFED_STRING
		if(ITEM_SLOT_ACCESSORY)
			return ITEM_SLOT_ACCESSORY_STRING


// Among other things, used by flamethrower and boiler spray to calculate if flame/spray can pass through.
// Returns an atom for specific effects (primarily flames and acid spray) that damage things upon contact
//
// This is a copy-and-paste of the Enter() proc for turfs with tweaks related to the applications
// of LinkBlocked
/proc/LinkBlocked(atom/movable/mover, turf/start_turf, turf/target_turf, list/atom/forget)
	if (!mover)
		return null

	/// the actual dir between the start and target turf
	var/fdir = get_dir(start_turf, target_turf)
	if (!fdir)
		return null

	var/fd1 = fdir & (fdir-1)
	var/fd2 = fdir - fd1

	/// The direction that mover's path is being blocked by
	var/blocking_dir = 0

	var/obstacle
	var/turf/T
	var/atom/A

	var/datum/can_pass_info/pass = new(mover, no_id = FALSE)

	blocking_dir |= start_turf.CanAStarPass(fdir, pass)
	for (obstacle in start_turf) //First, check objects to block exit
		if (mover == obstacle || (obstacle in forget))
			continue
		if (!isstructure(obstacle) && !ismob(obstacle) && !isvehicle(obstacle))
			continue
		A = obstacle
		blocking_dir |= A.CanAStarPass(fdir, pass)
		if ((!fd1 || blocking_dir & fd1) && (!fd2 || blocking_dir & fd2))
			return A

	// Check for atoms in adjacent turf EAST/WEST
	if (fd1 && fd1 != fdir)
		T = get_step(start_turf, fd1)
		if (T.CanAStarPass(fd2, pass) || T.CanAStarPass(fd1, pass))
			blocking_dir |= fd1
			if ((!fd1 || blocking_dir & fd1) && (!fd2 || blocking_dir & fd2))
				return T
		for (obstacle in T)
			if(obstacle in forget)
				continue
			if (!isstructure(obstacle) && !ismob(obstacle) && !isvehicle(obstacle))
				continue
			A = obstacle
			if (A.CanAStarPass(fd2, pass) || A.CanAStarPass(fd1, pass))
				blocking_dir |= fd1
				if ((!fd1 || blocking_dir & fd1) && (!fd2 || blocking_dir & fd2))
					return A
				break

	// Check for atoms in adjacent turf NORTH/SOUTH
	if (fd2 && fd2 != fdir)
		T = get_step(start_turf, fd2)
		if (T.CanAStarPass(fd1, pass) || T.CanAStarPass(fd2, pass))
			blocking_dir |= fd2
			if ((!fd1 || blocking_dir & fd1) && (!fd2 || blocking_dir & fd2))
				return T
		for (obstacle in T)
			if(obstacle in forget)
				continue
			if (!isstructure(obstacle) && !ismob(obstacle) && !isvehicle(obstacle))
				continue
			A = obstacle
			if (A.CanAStarPass(fd1, pass) || A.CanAStarPass(fd2, pass))
				blocking_dir |= fd2
				if ((!fd1 || blocking_dir & fd1) && (!fd2 || blocking_dir & fd2))
					return A
				break

	// Check the turf itself
	blocking_dir |= target_turf.CanAStarPass(fdir, pass)
	if ((!fd1 || blocking_dir & fd1) && (!fd2 || blocking_dir & fd2))
		return target_turf
	for (obstacle in target_turf) // Finally, check atoms in the target turf
		if(obstacle in forget)
			continue
		if (!isstructure(obstacle) && !ismob(obstacle) && !isvehicle(obstacle))
			continue
		A = obstacle
		blocking_dir |= A.CanAStarPass(fdir, pass)
		if((fd1 && blocking_dir == fd1) || (fd2 && blocking_dir == fd2))
			return A
		if((!fd1 || blocking_dir & fd1) && (!fd2 || blocking_dir & fd2))
			return A

	return null // Nothing found to block the link of mover from start_turf to target_turf
