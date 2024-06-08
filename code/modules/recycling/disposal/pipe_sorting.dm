//a three-way junction that sorts objects
/obj/structure/disposalpipe/sortjunction

	icon_state = "pipe-j1s"
	var/sortType = 0	//Look at the list called TAGGERLOCATIONS in /code/_globalvars/lists/flavor_misc.dm
	var/posdir = 0
	var/negdir = 0
	var/sortdir = 0


/obj/structure/disposalpipe/sortjunction/update_name(updates = ALL)
	. = ..()
	name = GLOB.TAGGERLOCATIONS[sortType]


/obj/structure/disposalpipe/sortjunction/update_desc(updates = ALL)
	. = ..()
	desc = "An underfloor disposal pipe with a package sorting mechanism."
	if(sortType > 0)
		var/tag = uppertext(GLOB.TAGGERLOCATIONS[sortType])
		desc += "\nIt's tagged with [tag]"


/obj/structure/disposalpipe/sortjunction/proc/updatedir()
	posdir = dir
	negdir = turn(posdir, 180)

	if(icon_state == "pipe-j1s")
		sortdir = turn(posdir, -90)
	else
		icon_state = "pipe-j2s"
		sortdir = turn(posdir, 90)

	dpdir = sortdir|posdir|negdir


/obj/structure/disposalpipe/sortjunction/Initialize(mapload)
	. = ..()
	updatedir()
	update_appearance(UPDATE_DESC)
	update()


/obj/structure/disposalpipe/sortjunction/attackby(obj/item/I, mob/user, params)
	if(..())
		return

	if(istype(I, /obj/item/destTagger))
		var/obj/item/destTagger/tagger = I

		if(tagger.currTag > 0)	// Tag set
			sortType = tagger.currTag
			playsound(loc, 'sound/machines/twobeep.ogg', 100, TRUE)
			var/tag = uppertext(GLOB.TAGGERLOCATIONS[tagger.currTag])
			to_chat(user, span_notice("Changed filter to [tag]."))
			update_appearance(UPDATE_NAME|UPDATE_DESC)


	// next direction to move
	// if coming in from negdir, then next is primary dir or sortdir
	// if coming in from posdir, then flip around and go back to posdir
	// if coming in from sortdir, go to posdir

/obj/structure/disposalpipe/sortjunction/nextdir(fromdir, sortTag)
	//var/flipdir = turn(fromdir, 180)
	if(fromdir != sortdir)	// probably came from the negdir

		if(sortType == sortTag) //if destination matches filtered types...
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

/obj/structure/disposalpipe/sortjunction/reversed
	icon_state = "pipe-j2s"

//a three-way junction that sorts objects destined for the mail office mail table (tomail = 1)
/obj/structure/disposalpipe/wrapsortjunction
	desc = "An underfloor disposal pipe which sorts wrapped and unwrapped objects."
	icon_state = "pipe-j1s"
	var/posdir = NONE
	var/negdir = NONE
	var/sortdir = NONE

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

/obj/structure/wrapsortjunction/reversed
	icon_state = "pipe-j2s"
