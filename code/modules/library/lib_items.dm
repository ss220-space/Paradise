/* Library Items
 *
 * Contains:
 *		Bookcase
 *		Book
 *		Barcode Scanner
 */


/*
 * Bookcase
 */

/obj/structure/bookcase
	name = "bookcase"
	icon = 'icons/obj/library.dmi'
	icon_state = "book-0"
	anchored = TRUE
	density = TRUE
	opacity = TRUE
	resistance_flags = FLAMMABLE
	max_integrity = 200
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 0)
	/// Typecache of the things allowed in the bookcase. Populated in [/proc/generate_allowed_books()] on Initialize.
	var/list/allowed_books


/obj/structure/bookcase/Initialize(mapload)
	. = ..()
	generate_allowed_books()
	if(mapload)
		addtimer(CALLBACK(src, PROC_REF(take_contents)), 0)


/// Populates typecache with the things allowed to store
/obj/structure/bookcase/proc/generate_allowed_books()
	allowed_books = typecacheof(list(
		/obj/item/book,
		/obj/item/spellbook,
		/obj/item/storage/bible,
		/obj/item/tome,
	))


/// This is called on Initialize to add contents on the tile
/obj/structure/bookcase/proc/take_contents()
	var/update = FALSE
	for(var/atom/movable/thing as anything in loc)
		if(is_type_in_typecache(thing, allowed_books))
			update = TRUE
			thing.forceMove(src)
	if(update)
		update_icon(UPDATE_ICON_STATE)


/obj/structure/bookcase/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(is_pen(I))
		rename_interactive(user, I)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(istype(I, /obj/item/storage/bag/books))
		add_fingerprint(user)
		var/obj/item/storage/bag/books/bag = I
		var/loaded = 0
		for(var/obj/item/book as anything in bag.contents)
			if(is_type_in_typecache(book, allowed_books))
				loaded++
				book.add_fingerprint(user)
				bag.remove_from_storage(book, src)
		if(!loaded)
			to_chat(user, span_warning("There are no books in [bag]."))
			return ATTACK_CHAIN_PROCEED
		to_chat(user, span_notice("You have emptied [bag] into [src]."))
		update_icon(UPDATE_ICON_STATE)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(is_type_in_typecache(I, allowed_books))
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		to_chat(user, span_notice("You have added [I] into [src]."))
		add_fingerprint(user)
		update_icon(UPDATE_ICON_STATE)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/structure/bookcase/screwdriver_act(mob/user, obj/item/I)
	if(obj_flags & NODECONSTRUCT)
		return FALSE
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return .
	TOOL_ATTEMPT_DISMANTLE_MESSAGE
	if(!I.use_tool(src, user, 2 SECONDS, volume = I.tool_volume))
		return .
	TOOL_DISMANTLE_SUCCESS_MESSAGE
	deconstruct(TRUE)


/obj/structure/bookcase/wrench_act(mob/user, obj/item/I)
	return default_unfasten_wrench(user, I, 0)


/obj/structure/bookcase/attack_hand(mob/user)
	if(!length(contents))
		return

	var/obj/item/book/choice = tgui_input_list(user, "Which book would you like to remove from [src]?", "Bookcase", contents)
	if(!choice || user.incapacitated() || !Adjacent(user))
		return
	add_fingerprint(user)
	choice.forceMove_turf()
	user.put_in_hands(choice, ignore_anim = FALSE)
	update_icon(UPDATE_ICON_STATE)


/obj/structure/bookcase/deconstruct(disassembled = TRUE)
	new /obj/item/stack/sheet/wood(loc, 5)
	var/atom/drop_loc = drop_location()
	for(var/atom/movable/thing as anything in contents)
		if(is_type_in_typecache(thing, allowed_books))
			thing.forceMove(drop_loc)
	..()


/obj/structure/bookcase/update_icon_state()
	icon_state = "book-[min(length(contents), 5)]"


/obj/structure/bookcase/manuals/medical
	name = "Medical Manuals bookcase"


/obj/structure/bookcase/manuals/medical/Initialize()
	. = ..()
	new /obj/item/book/manual/medical_cloning(src)
	update_icon(UPDATE_ICON_STATE)


/obj/structure/bookcase/manuals/engineering
	name = "Engineering Manuals bookcase"


/obj/structure/bookcase/manuals/engineering/Initialize()
	. = ..()
	new /obj/item/book/manual/engineering_construction(src)
	new /obj/item/book/manual/engineering_particle_accelerator(src)
	new /obj/item/book/manual/engineering_hacking(src)
	new /obj/item/book/manual/engineering_guide(src)
	new /obj/item/book/manual/engineering_singularity_safety(src)
	new /obj/item/book/manual/robotics_cyborgs(src)
	update_icon(UPDATE_ICON_STATE)


/obj/structure/bookcase/manuals/research_and_development
	name = "R&D Manuals bookcase"


/obj/structure/bookcase/manuals/research_and_development/Initialize()
	. = ..()
	new /obj/item/book/manual/research_and_development(src)
	update_icon(UPDATE_ICON_STATE)


/*
 * Book
 */
/obj/item/book
	name = "book"
	icon = 'icons/obj/library.dmi'
	icon_state ="book"
	throw_speed = 1
	throw_range = 5
	force = 2
	w_class = WEIGHT_CLASS_NORMAL		 //upped to three because books are, y'know, pretty big. (and you could hide them inside eachother recursively forever)
	attack_verb = list("bashed", "whacked")
	resistance_flags = FLAMMABLE
	drop_sound = 'sound/items/handling/book_drop.ogg'
	pickup_sound =  'sound/items/handling/book_pickup.ogg'

	var/dat			 // Actual page content
	var/due_date = 0 // Game time in 1/10th seconds
	var/author		 // Who wrote the thing, can be changed by pen or PC. It is not automatically assigned
	var/unique = 0   // 0 - Normal book, 1 - Should not be treated as normal book, unable to be copied, unable to be modified
	var/title		 // The real name of the book.
	var/carved = 0	 // Has the book been hollowed out for use as a secret storage item?
	var/forbidden = 0     // Prevent ordering of this book. (0=no, 1=yes, 2=emag only)
	var/obj/item/store	// What's in the book?
	/// Book DRM. If this var is TRUE, it cannot be scanned and re-uploaded
	var/has_drm = FALSE

/obj/item/book/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/falling_hazard, damage = 5, hardhat_safety = TRUE, crushes = FALSE, impact_sound = drop_sound)

/obj/item/book/examine(mob/user)
	. = ..()
	if(user.is_literate())
		if(in_range(user, src) || istype(user, /mob/dead/observer))
			attack_self(user)
		else
			. += "<span class='notice'>You have to go closer if you want to read it.</span>"
	else
		. += "<span class='notice'>You don't know how to read.</span>"

/obj/item/book/attack_self(mob/user)
	if(carved)
		if(store)
			to_chat(user, "<span class='notice'>[store] falls out of [title]!</span>")
			store.forceMove(get_turf(loc))
			store = null
			return
		else
			to_chat(user, "<span class='notice'>The pages of [title] have been cut out!</span>")
			return
	if(src.dat)
		user << browse({"<meta charset="UTF-8"><TT><I>Penned by [author].</I></TT> <BR>"} + "[dat]", "window=book")
		if(!isobserver(user))
			user.visible_message("[user] opens a book titled \"[title]\" and begins reading intently.")
		onclose(user, "book")
	else
		to_chat(user, "This book is completely blank!")


/obj/item/book/attackby(obj/item/I, mob/user, params)
	if(carved)
		add_fingerprint(user)
		if(store)
			to_chat(user, span_warning("There's already something in [title]!"))
			return ATTACK_CHAIN_PROCEED
		if(I.w_class >= WEIGHT_CLASS_NORMAL)
			to_chat(user, span_warning("The [I.name] won't fit in [title]!"))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		store = I
		to_chat(user, span_notice("You have put [I] into [title]."))
		return ATTACK_CHAIN_BLOCKED_ALL

	if(is_sharp(I))
		add_fingerprint(user)
		if(!carve_book(user, I))
			return ATTACK_CHAIN_PROCEED
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(is_pen(I))
		add_fingerprint(user)
		if(unique)
			to_chat(user, span_warning("These pages don't seem to take the ink well. Looks like you can't modify it."))
			return ATTACK_CHAIN_PROCEED
		var/choice = tgui_input_list(user, "What would you like to change?", "Book Edit", list("Title", "Contents", "Author", "Cancel"))
		switch(choice)
			if("Title")
				var/newtitle = reject_bad_text(tgui_input_text(user, "Write a new title:", "Title", title))
				if(isnull(newtitle))
					to_chat(user, span_warning("The title is invalid."))
					return ATTACK_CHAIN_PROCEED
				name = newtitle
				title = newtitle
			if("Contents")
				var/content = tgui_input_text(user, "Write your book's contents (HTML NOT allowed):", "Summary", max_length = MAX_BOOK_MESSAGE_LEN, multiline = TRUE)
				if(isnull(content))
					to_chat(user, span_warning("The contents is invalid."))
					return ATTACK_CHAIN_PROCEED
				dat += content
			if("Author")
				var/newauthor = tgui_input_text(user, "Write the author's name:", "Author", author, MAX_NAME_LEN)
				if(isnull(newauthor))
					to_chat(user, span_warning("The name is invalid."))
					return ATTACK_CHAIN_PROCEED
				author = newauthor
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(istype(I, /obj/item/barcodescanner))
		add_fingerprint(user)
		var/obj/item/barcodescanner/scanner = I
		if(!scanner.computer)
			to_chat(user, span_warning("The [scanner.name]'s screen flashes: 'No associated computer found!'"))
			return ATTACK_CHAIN_PROCEED
		switch(scanner.mode)
			if(0)
				scanner.book = src
				to_chat(user, span_notice("The [scanner.name]'s screen flashes: 'Book stored in buffer.'"))
			if(1)
				scanner.book = src
				scanner.computer.buffer_book = name
				to_chat(user, span_notice("The [scanner.name]'s screen flashes: 'Book stored in buffer. Book title stored in associated computer buffer.'"))
			if(2)
				scanner.book = src
				for(var/datum/borrowbook/borrowbook as anything in scanner.computer.checkouts)
					if(borrowbook.bookname == name)
						scanner.computer.checkouts.Remove(borrowbook)
						to_chat(user, span_notice("The [scanner.name]'s screen flashes: 'Book stored in buffer. Book has been checked in.'"))
						return ATTACK_CHAIN_PROCEED_SUCCESS
				to_chat(user, span_notice("The [scanner.name]'s screen flashes: 'Book stored in buffer. No active check-out record found for current title.'"))
			if(3)
				scanner.book = src
				for(var/obj/item/book as anything in scanner.computer.inventory)
					if(book == src)
						to_chat(user, span_notice("The [scanner.name]'s screen flashes: 'Book stored in buffer. Title already present in inventory, aborting to avoid duplicate entry.'"))
						return ATTACK_CHAIN_PROCEED_SUCCESS
				scanner.computer.inventory.Add(src)
				to_chat(user, span_notice("The [scanner.name]'s screen flashes: 'Book stored in buffer. Title added to general inventory.'"))
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()


/obj/item/book/wirecutter_act(mob/user, obj/item/I)
	return carve_book(user, I)


/obj/item/book/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(user.a_intent == INTENT_HELP)
		force = 0
		attack_verb = list("educated")
	else
		force = initial(force)
		attack_verb = list("bashed", "whacked")
	return ..()


/obj/item/book/proc/carve_book(mob/user, obj/item/I)
	if(!is_sharp(I) && I.tool_behaviour != TOOL_WIRECUTTER) //Only sharp and wirecutter things can carve books
		to_chat(user, span_warning("You can't carve [title] using that!"))
		return FALSE
	if(carved)
		to_chat(user, span_warning("The [title] is already carved!"))
		return FALSE
	to_chat(user, span_notice("You start to carve out [title]..."))
	if(!I.use_tool(src, user, 3 SECONDS, volume = I.tool_volume) || carved)
		return FALSE
	to_chat(user, span_notice("You have carved out the pages from [title]! You didn't want to read it anyway."))
	carved = TRUE
	return TRUE


/*
 * Barcode Scanner
 */
/obj/item/barcodescanner
	name = "barcode scanner"
	icon = 'icons/obj/library.dmi'
	icon_state ="scanner"
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_TINY
	var/obj/machinery/computer/library/checkout/computer // Associated computer - Modes 1 to 3 use this
	var/obj/item/book/book	 //  Currently scanned book
	var/mode = 0 					// 0 - Scan only, 1 - Scan and Set Buffer, 2 - Scan and Attempt to Check In, 3 - Scan and Attempt to Add to Inventory

/obj/item/barcodescanner/attack_self(mob/user)
	mode += 1
	if(mode > 3)
		mode = 0
	to_chat(user, "[src] Status Display:")
	var/modedesc
	switch(mode)
		if(0)
			modedesc = "Scan book to local buffer."
		if(1)
			modedesc = "Scan book to local buffer and set associated computer buffer to match."
		if(2)
			modedesc = "Scan book to local buffer, attempt to check in scanned book."
		if(3)
			modedesc = "Scan book to local buffer, attempt to add book to general inventory."
		else
			modedesc = "ERROR"
	to_chat(user, " - Mode [mode] : [modedesc]")
	if(src.computer)
		to_chat(user, "<font color=green>Computer has been associated with this unit.</font>")
	else
		to_chat(user, "<font color=red>No associated computer found. Only local scans will function properly.</font>")
	to_chat(user, "\n")
