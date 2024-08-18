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
	/// Things allowed in the bookcase
	var/list/allowed_books = list(
		/obj/item/book,
		/obj/item/spellbook,
		/obj/item/storage/bible,
		/obj/item/tome,
	)


/obj/structure/bookcase/Initialize()
	. = ..()
	for(var/obj/item/I in loc)
		if(is_type_in_list(I, allowed_books))
			I.forceMove(src)
	update_icon(UPDATE_ICON_STATE)


/obj/structure/bookcase/attackby(obj/item/O, mob/user, params)
	if(is_type_in_list(O, allowed_books))
		if(!user.drop_transfer_item_to_loc(O, src))
			return
		add_fingerprint(user)
		update_icon(UPDATE_ICON_STATE)
		return TRUE
	if(istype(O, /obj/item/storage/bag/books))
		var/obj/item/storage/bag/books/B = O
		for(var/obj/item/T in B.contents)
			if(is_type_in_list(T, allowed_books))
				T.add_fingerprint(user)
				B.remove_from_storage(T, src)
		add_fingerprint(user)
		to_chat(user, span_notice("You empty [O] into [src]."))
		update_icon(UPDATE_ICON_STATE)
		return TRUE
	if(is_pen(O))
		add_fingerprint(user)
		rename_interactive(user, O)
		return TRUE
	return ..()


/obj/structure/bookcase/screwdriver_act(mob/user, obj/item/I)
	if(obj_flags & NODECONSTRUCT)
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	TOOL_ATTEMPT_DISMANTLE_MESSAGE
	if(!I.use_tool(src, user, 2 SECONDS, volume = I.tool_volume))
		return
	TOOL_DISMANTLE_SUCCESS_MESSAGE
	deconstruct(TRUE)


/obj/structure/bookcase/wrench_act(mob/user, obj/item/I)
	. = TRUE
	default_unfasten_wrench(user, I, 0)


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
	for(var/obj/item/I in contents)
		if(is_type_in_list(I, allowed_books))
			I.forceMove(get_turf(src))
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

/obj/item/book/attack_self(var/mob/user as mob)
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

/obj/item/book/attackby(obj/item/W as obj, mob/user as mob, params)
	if(carved)
		if(!store)
			if(W.w_class < WEIGHT_CLASS_NORMAL)
				user.drop_from_active_hand()
				W.forceMove(src)
				store = W
				to_chat(user, "<span class='notice'>You put [W] in [title].</span>")
				return 1
			else
				to_chat(user, "<span class='notice'>[W] won't fit in [title].</span>")
				return 1
		else
			to_chat(user, "<span class='notice'>There's already something in [title]!</span>")
			return 1
	if(is_pen(W))
		if(unique)
			to_chat(user, "These pages don't seem to take the ink well. Looks like you can't modify it.")
			return 1
		var/choice = tgui_input_list(user, "What would you like to change?", "Book Edit", list("Title", "Contents", "Author", "Cancel"))
		switch(choice)
			if("Title")
				var/newtitle = reject_bad_text(tgui_input_text(user, "Write a new title:", "Title", title))
				if(isnull(newtitle))
					to_chat(usr, "The title is invalid.")
					return 1
				else
					src.name = newtitle
					src.title = newtitle
			if("Contents")
				var/content = tgui_input_text(user, "Write your book's contents (HTML NOT allowed):", "Summary", max_length = MAX_BOOK_MESSAGE_LEN, multiline = TRUE)
				if(isnull(content))
					to_chat(usr, "The content is invalid.")
					return 1
				else
					src.dat += content
			if("Author")
				var/newauthor = tgui_input_text(user, "Write the author's name:", "Author", author, MAX_NAME_LEN)
				if(isnull(newauthor))
					to_chat(usr, "The name is invalid.")
					return 1
				else
					src.author = newauthor
		return 1
	else if(istype(W, /obj/item/barcodescanner))
		var/obj/item/barcodescanner/scanner = W
		if(!scanner.computer)
			to_chat(user, "[W]'s screen flashes: 'No associated computer found!'")
		else
			switch(scanner.mode)
				if(0)
					scanner.book = src
					to_chat(user, "[W]'s screen flashes: 'Book stored in buffer.'")
				if(1)
					scanner.book = src
					scanner.computer.buffer_book = src.name
					to_chat(user, "[W]'s screen flashes: 'Book stored in buffer. Book title stored in associated computer buffer.'")
				if(2)
					scanner.book = src
					for(var/datum/borrowbook/b in scanner.computer.checkouts)
						if(b.bookname == src.name)
							scanner.computer.checkouts.Remove(b)
							to_chat(user, "[W]'s screen flashes: 'Book stored in buffer. Book has been checked in.'")
							return 1
					to_chat(user, "[W]'s screen flashes: 'Book stored in buffer. No active check-out record found for current title.'")
				if(3)
					scanner.book = src
					for(var/obj/item/book in scanner.computer.inventory)
						if(book == src)
							to_chat(user, "[W]'s screen flashes: 'Book stored in buffer. Title already present in inventory, aborting to avoid duplicate entry.'")
							return 1
					scanner.computer.inventory.Add(src)
					to_chat(user, "[W]'s screen flashes: 'Book stored in buffer. Title added to general inventory.'")
		return 1
	else if(istype(W, /obj/item/kitchen/knife) && !carved)
		carve_book(user, W)
	else
		return ..()

/obj/item/book/wirecutter_act(mob/user, obj/item/I)
	return carve_book(user, I)

/obj/item/book/attack(mob/M, mob/living/user)
	if(user.a_intent == INTENT_HELP)
		force = 0
		attack_verb = list("educated")
	else
		force = initial(force)
		attack_verb = list("bashed", "whacked")
	..()

/obj/item/book/proc/carve_book(mob/user, obj/item/I)
	if(!I.sharp && I.tool_behaviour != TOOL_WIRECUTTER) //Only sharp and wirecutter things can carve books
		to_chat(user, "<span class='warning>You can't carve [title] using that!</span>")
		return
	if(carved)
		return
	to_chat(user, "<span class='notice'>You begin to carve out [title].</span>")
	if(I.use_tool(src, user, 30, volume = I.tool_volume))
		to_chat(user, "<span class='notice'>You carve out the pages from [title]! You didn't want to read it anyway.</span>")
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

/obj/item/barcodescanner/attack_self(mob/user as mob)
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
