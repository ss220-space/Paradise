//a three-way junction that sorts objects
/obj/structure/disposalpipe/sortjunction
	name = "disposal sorting pipe"
	icon_state = "pipe-j1s"
	base_icon_state = "pipe-j1s"
	flip_type = /obj/structure/disposalpipe/sortjunction/reversed
	initialize_dirs = DISP_DIR_RIGHT|DISP_DIR_FLIP
	/// Look at the list called TAGGERLOCATIONS in /code/_globalvars/lists/flavor_misc.dm
	var/sortType = 0


/obj/structure/disposalpipe/sortjunction/Initialize(mapload, obj/structure/disposalconstruct/made_from)
	. = ..()
	update_appearance(UPDATE_NAME|UPDATE_DESC)


/obj/structure/disposalpipe/sortjunction/update_name(updates = ALL)
	. = ..()
	name = "sort junction"
	if(sortType > 0)
		name = GLOB.TAGGERLOCATIONS[sortType]


/obj/structure/disposalpipe/sortjunction/update_desc(updates = ALL)
	. = ..()
	desc = "An underfloor disposal pipe with a package sorting mechanism."
	if(sortType > 0)
		var/tag = uppertext(GLOB.TAGGERLOCATIONS[sortType])
		desc += "\nIt's tagged with [tag]"


/obj/structure/disposalpipe/sortjunction/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(I, /obj/item/destTagger))
		add_fingerprint(user)
		var/obj/item/destTagger/tagger = I
		if(sortType == tagger.currTag)
			to_chat(user, span_warning("The pipe is already configured this way."))
			return ATTACK_CHAIN_PROCEED
		sortType = tagger.currTag
		to_chat(user, span_notice("The filter is changed to *[uppertext(GLOB.TAGGERLOCATIONS[tagger.currTag])]*."))
		playsound(loc, 'sound/machines/twobeep.ogg', 100, TRUE)
		update_appearance(UPDATE_NAME|UPDATE_DESC)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()


/obj/structure/disposalpipe/sortjunction/nextdir(obj/structure/disposalholder/holder)
	var/sortdir = dpdir & ~(dir | REVERSE_DIR(dir))
	if(holder.dir != sortdir) // probably came from the negdir
		if(holder.destinationTag == sortType) // if destination matches filtered type...
			return sortdir // exit through sortdirection

	// go with the flow to positive direction
	return dir


/obj/structure/disposalpipe/sortjunction/reversed
	icon_state = "pipe-j2s"
	base_icon_state = "pipe-j2s"
	flip_type = /obj/structure/disposalpipe/sortjunction
	initialize_dirs = DISP_DIR_LEFT|DISP_DIR_FLIP


//a three-way junction that sorts objects destined for the mail office mail table (tomail = 1)
/obj/structure/disposalpipe/wrapsortjunction
	name = "disposal mail-sorting pipe"
	desc = "An underfloor disposal pipe which sorts wrapped and unwrapped objects."
	icon_state = "pipe-j1s"
	base_icon_state = "pipe-j1s"
	flip_type = /obj/structure/disposalpipe/wrapsortjunction/reversed
	initialize_dirs = DISP_DIR_RIGHT|DISP_DIR_FLIP


/obj/structure/disposalpipe/wrapsortjunction/nextdir(obj/structure/disposalholder/holder)
	var/sortdir = dpdir & ~(dir | REVERSE_DIR(dir))
	if(holder.dir != sortdir) // probably came from the negdir
		if(holder.tomail) // if destination matches filtered type...
			return sortdir // exit through sortdirection

	// go with the flow to positive direction
	return dir


/obj/structure/disposalpipe/wrapsortjunction/reversed
	icon_state = "pipe-j2s"
	base_icon_state = "pipe-j2s"
	flip_type = /obj/structure/disposalpipe/wrapsortjunction
	initialize_dirs = DISP_DIR_LEFT|DISP_DIR_FLIP

