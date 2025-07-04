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
	desc = "Большой книжный шкаф."
	ru_names = list(
		NOMINATIVE = "книжный шкаф",
		GENITIVE = "книжного шкафа",
		DATIVE = "книжному шкафу",
		ACCUSATIVE = "книжный шкаф",
		INSTRUMENTAL = "книжным шкафом",
		PREPOSITIONAL = "книжном шкафе"
	)
	gender = MALE
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
	var/desc_text


/obj/structure/bookcase/Initialize(mapload)
	. = ..()
	generate_allowed_books()
	if(mapload)
		addtimer(CALLBACK(src, PROC_REF(take_contents)), 0)

/obj/structure/bookcase/examine(mob/user)
	if(icon_state = "book-0")
		desc += "Его полки давно не протирали..."
	else
		desc += "На его полках стоят книги."

	. = ..()

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

/obj/structure/bookcase/MouseDrop_T(atom/movable/thing, mob/user, params)
	if(!istype(user, /mob/living/simple_animal/pet/library_owl))
		return
	if(!is_type_in_typecache(thing, allowed_books))
		return
	if(!user.drop_transfer_item_to_loc(thing, src))
		return ..()
	to_chat(user, span_notice("Вы положили [I.declent_ru(ACCUSATIVE)] в [declent_ru(ACCUSATIVE)]."))
	add_fingerprint(user)
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
			user.balloon_alert(user, "сумка пуста!")
			return ATTACK_CHAIN_PROCEED
		src.balloon_alert(user, "опустошено")
		update_icon(UPDATE_ICON_STATE)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(is_type_in_typecache(I, allowed_books))
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		to_chat(user, span_notice("Вы положили [I.declent_ru(ACCUSATIVE)] в [declent_ru(ACCUSATIVE)]."))
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

	var/obj/item/book/choice = tgui_input_list(user, "Какую книгу вы хотели бы достать из книжного шкафа?", "Книжный шкаф", contents)
	if(!choice || user.incapacitated() || !Adjacent(user))
		return
	add_fingerprint(user)
	choice.forceMove_turf()
	user.put_in_hands(choice, ignore_anim = FALSE)
	update_icon(UPDATE_ICON_STATE)

/obj/structure/bookcase/attack_animal(mob/living/simple_animal/M)
	if(istype(M, /mob/living/simple_animal/pet/library_owl))
		attack_hand(M)
	else
		. = ..()

/obj/structure/bookcase/deconstruct(disassembled = TRUE)
	new /obj/item/stack/sheet/wood(loc, 5)
	var/atom/drop_loc = drop_location()
	for(var/atom/movable/thing as anything in contents)
		if(is_type_in_typecache(thing, allowed_books))
			thing.forceMove(drop_loc)
	..()


/obj/structure/bookcase/update_icon_state()
	icon_state = "book-[min(length(contents), 5)]"

/obj/structure/bookcase/manuals
	var/manual_name = ""
	var/manual_name_ru = ""

/obj/structure/bookcase/manuals/Initialize(mapload)
	. = ..()
	name = manual_name + name
	if(ru_names)
		ru_names[NOMINATIVE] += manual_name_ru
		ru_names[GENITIVE] += manual_name_ru
		ru_names[DATIVE] += manual_name_ru
		ru_names[ACCUSATIVE] += manual_name_ru
		ru_names[INSTRUMENTAL] += manual_name_ru
		ru_names[PREPOSITIONAL] += manual_name_ru


/obj/structure/bookcase/manuals/medical
	manual_name = "Medical Manuals "
	manual_name_ru = " с учебниками по медицине"
	desc_text = "На его полках стоит различная медицинская литература."

/obj/structure/bookcase/manuals/medical/Initialize()
	. = ..()
	new /obj/item/book/manual/medical_cloning(src)
	update_icon(UPDATE_ICON_STATE)


/obj/structure/bookcase/manuals/engineering
	manual_name = "Engineering Manuals "
	manual_name_ru = " с руководствами по инженерному делу"
	desc_text = "На его полках стоят различные руководства по инженерному делу."



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
	manual_name = "R&D Manuals "
	manual_name_ru = " с учебниками по научной деятельности"
	desc_text = "На его полках стоят различные учебники по научной деятельности."



/obj/structure/bookcase/manuals/research_and_development/Initialize()
	. = ..()
	new /obj/item/book/manual/research_and_development(src)
	update_icon(UPDATE_ICON_STATE)


/*
 * Book
 */
/obj/item/book
	name = "book"
	desc = "Напечатанная книга в твёрдом переплёте."
	ru_names = list(
		NOMINATIVE = "книга",
		GENITIVE = "книги",
		DATIVE = "книге",
		ACCUSATIVE = "книгу",
		INSTRUMENTAL = "книгой",
		PREPOSITIONAL = "книге"
	)
	gender = FEMALE
	icon = 'icons/obj/library.dmi'
	icon_state ="book"
	throw_speed = 1
	throw_range = 5
	force = 2
	w_class = WEIGHT_CLASS_NORMAL		 //upped to three because books are, y'know, pretty big. (and you could hide them inside eachother recursively forever)
	attack_verb = list("ударил", "огрел")
	resistance_flags = FLAMMABLE
	drop_sound = 'sound/items/handling/book_drop.ogg'
	pickup_sound =  'sound/items/handling/book_pickup.ogg'

	/// Actual page content
	var/dat
	/// Game time in 1/10th seconds
	var/due_date = 0
	/// Who wrote the thing, can be changed by pen or PC. It is not automatically assigned
	var/author
	/// FALSE - Normal book, TRUE - Should not be treated as normal book, unable to be copied, unable to be modified
	var/unique = FALSE
	/// The real name of the book.
	var/title
	/// Has the book been hollowed out for use as a secret storage item?
	var/carved = 0
	/// Prevent ordering of this book. (0=no, 1=yes, 2=emag only)
	var/forbidden = 0
	/// What's in the book?
	var/obj/item/store
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
			. += span_notice("Вам стоит одойдти ближе, чтобы её прочесть.")
	else
		. += span_notice("Вы не умеете читать.")

/obj/item/book/attack_self(mob/user)
	if(carved)
		if(store)
			to_chat(user, span_notice("[capitalize(store.declent_ru(NOMINATIVE))] выпадает из [title]!"))
			store.forceMove(get_turf(loc))
			store = null
			return
		else
			to_chat(user, span_notice("Кто-то вырезал страницы [title]!"))
			return
	if(src.dat)
		var/datum/browser/popup = new(user, "book", title)
		popup.include_default_stylesheet = FALSE
		popup.set_content("<tt><i>За авторством [author].</i></tt><br>" + "[dat]")
		popup.open(TRUE)
		if(!isobserver(user))
			user.visible_message("[user] открывает книгу под заголовком \"[title]\" и начина[pluralize_ru(user.gender, "ет", "ют")] внимательно её читать.")
		onclose(user, "book")
	else
		to_chat(user, "Эта книга полностью пуста!")


/obj/item/book/attackby(obj/item/I, mob/user, params)
	if(carved)
		add_fingerprint(user)
		if(store)
			src.balloon_alert(user, "занято!")
			return ATTACK_CHAIN_PROCEED
		if(I.w_class >= WEIGHT_CLASS_NORMAL)
			src.balloon_alert(user, "слишком большое!")
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		store = I
		to_chat(user, span_notice("Вы кладёте [I.declent_ru(ACCUSATIVE)] в [title]."))
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
		var/choice = tgui_input_list(user, "Что вы хотели бы изменить?", "Редактура", list("Заголовок", "Содержание", "Автор", "Отмена"))
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
		attack_verb = list("обучил")
	else
		force = initial(force)
		attack_verb = list("ударил", "огрел")
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
	icon_state = "scanner"
	lefthand_file = 'icons/mob/inhands/equipment/library_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/library_righthand.dmi'
	item_state = "scanner"
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
