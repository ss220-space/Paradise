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
	gender = MALE
	icon = 'icons/obj/library.dmi'
	icon_state = "book-0"
	anchored = TRUE
	density = TRUE
	opacity = TRUE
	resistance_flags = FLAMMABLE
	max_integrity = 200
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 50, ACID = 0)
	/// Typecache of the things allowed in the bookcase. Populated in [/proc/generate_allowed_books()] on Initialize.
	var/list/allowed_books

/obj/structure/bookcase/get_ru_names()
	return list(
		NOMINATIVE = "книжный шкаф",
		GENITIVE = "книжного шкафа",
		DATIVE = "книжному шкафу",
		ACCUSATIVE = "книжный шкаф",
		INSTRUMENTAL = "книжным шкафом",
		PREPOSITIONAL = "книжном шкафе"
	)

/obj/structure/bookcase/Initialize(mapload)
	. = ..()
	generate_allowed_books()
	if(mapload)
		addtimer(CALLBACK(src, PROC_REF(take_contents)), 0)


/obj/structure/bookcase/examine(mob/user)
	if(length(contents) > 0)
		desc = "Большой книжный шкаф. На его полках стоят книги."
	else
		desc = "Большой книжный шкаф. Его полки давно не протирали..."

	. = ..()

/obj/structure/bookcase/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_WOOD, -40, 5)


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
	balloon_alert(user, "поставлено на полку")
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
			balloon_alert(user, "сумка пуста!")
			return ATTACK_CHAIN_PROCEED
		balloon_alert(user, "опустошено")
		update_icon(UPDATE_ICON_STATE)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(is_type_in_typecache(I, allowed_books))
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		to_chat(user, span_notice("Вы поместили [I.declent_ru(ACCUSATIVE)] в [declent_ru(ACCUSATIVE)]."))
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

/obj/structure/bookcase/manuals/medical/Initialize(mapload)
	. = ..()
	new /obj/item/book/manual/medical_cloning(src)
	update_icon(UPDATE_ICON_STATE)


/obj/structure/bookcase/manuals/engineering
	manual_name = "Engineering Manuals "
	manual_name_ru = " с руководствами по инженерному делу"



/obj/structure/bookcase/manuals/engineering/Initialize(mapload)
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



/obj/structure/bookcase/manuals/research_and_development/Initialize(mapload)
	. = ..()
	new /obj/item/book/manual/research_and_development(src)
	update_icon(UPDATE_ICON_STATE)


/*
 * Book
 */
/obj/item/book
	name = "book"
	desc = "Напечатанная книга в твёрдом переплёте."
	gender = FEMALE
	icon = 'icons/obj/library.dmi'
	lefthand_file = 'icons/mob/inhands/equipment/library_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/library_righthand.dmi'
	icon_state = "book"
	item_state = "book"
	throw_speed = 1
	throw_range = 5
	force = 2
	w_class = WEIGHT_CLASS_NORMAL		 //upped to three because books are, y'know, pretty big. (and you could hide them inside eachother recursively forever)
	attack_verb = list("ударил", "огрел")
	resistance_flags = FLAMMABLE
	drop_sound = 'sound/items/handling/drop/book_drop.ogg'
	pickup_sound =  'sound/items/handling/pickup/book_pickup.ogg'

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

/obj/item/book/get_ru_names()
	return list(
		NOMINATIVE = "книга",
		GENITIVE = "книги",
		DATIVE = "книге",
		ACCUSATIVE = "книгу",
		INSTRUMENTAL = "книгой",
		PREPOSITIONAL = "книге"
	)

/obj/item/book/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/falling_hazard, damage = 5, hardhat_safety = TRUE, crushes = FALSE, impact_sound = drop_sound)

/obj/item/book/examine(mob/user)
	. = ..()
	if(user.is_literate())
		if(in_range(user, src) || istype(user, /mob/dead/observer))
			attack_self(user)
		else
			. += span_notice("Вам стоит подойти ближе, чтобы её прочесть.")
	else
		. += span_notice("Вы не умеете читать.")

/obj/item/book/attack_self(mob/user)
	if(carved)
		if(store)
			to_chat(user, span_notice("[capitalize(store.declent_ru(NOMINATIVE))] выпада[pluralize_ru(store, "ет", "ют")] из \"[title]\"!"))
			store.forceMove(get_turf(loc))
			store = null
			return
		else
			to_chat(user, span_notice("Кто-то вырезал страницы из \"[title]\"!"))
			return
	if(src.dat)
		var/datum/browser/popup = new(user, "book", title)
		popup.include_default_stylesheet = FALSE
		popup.set_content("<tt><i>Автор — [author].</i></tt><br>" + "[dat]")
		popup.open(TRUE)
		if(!isobserver(user))
			user.visible_message("[user] открыва[pluralize_ru(user.gender, "ет", "ют")] книгу под заголовком \"[title]\" и начина[pluralize_ru(user.gender, "ет", "ют")] внимательно её читать.")
		onclose(user, "book")
	else
		to_chat(user, "Эта книга полностью пуста!")


/obj/item/book/attackby(obj/item/I, mob/user, params)
	if(carved)
		add_fingerprint(user)
		if(store)
			balloon_alert(user, "занято!")
			return ATTACK_CHAIN_PROCEED
		if(I.w_class >= WEIGHT_CLASS_NORMAL)
			balloon_alert(user, "слишком большое!")
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		store = I
		to_chat(user, span_notice("Вы помещаете [I.declent_ru(ACCUSATIVE)] в \"[title]\"."))
		return ATTACK_CHAIN_BLOCKED_ALL

	if(is_sharp(I))
		add_fingerprint(user)
		if(!carve_book(user, I))
			return ATTACK_CHAIN_PROCEED
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(is_pen(I))
		add_fingerprint(user)
		if(unique)
			to_chat(user, span_warning("На страницы этой книги плохо ложатся чернила. По всей видимости, вы ничего не сможете с ней сделать."))
			return ATTACK_CHAIN_PROCEED
		var/choice = tgui_input_list(user, "Что вы хотели бы изменить?", "Редактура", list("Заголовок", "Содержание", "Автор", "Отмена"))
		switch(choice)
			if("Заголовок")
				var/newtitle = reject_bad_text(tgui_input_text(user, "Напишите новый заголовок:", "Название", title))
				if(isnull(newtitle))
					balloon_alert(user, "недопустимый формат!")
					return ATTACK_CHAIN_PROCEED
				name = newtitle
				title = newtitle
			if("Содержание")
				var/content = tgui_input_text(user, "Напишите содержание книги (HTML ЗАПРЕЩЁН):", "Содержание", max_length = MAX_BOOK_MESSAGE_LEN, multiline = TRUE)
				if(isnull(content))
					balloon_alert(user, "недопустимое содержание!")
					return ATTACK_CHAIN_PROCEED
				dat += content
			if("Автор")
				var/newauthor = tgui_input_text(user, "Напишите имя автора:", "Автор", author, MAX_NAME_LEN)
				if(isnull(newauthor))
					balloon_alert(user, "недопустимое имя!")
					return ATTACK_CHAIN_PROCEED
				author = newauthor
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(istype(I, /obj/item/barcodescanner))
		add_fingerprint(user)
		var/obj/item/barcodescanner/scanner = I
		if(!scanner.computer)
			playsound(src, 'sound/machines/buzz-sigh.ogg', 20)
			to_chat(user, span_warning("Экран [scanner.declent_ru(GENITIVE)] загорается: \"Привязанный компьютер не найден!\"."))
			return ATTACK_CHAIN_PROCEED

		switch(scanner.mode)
			if(0)
				playsound(src, 'sound/machines/ping.ogg', 20)
				scanner.book = src
				to_chat(user, span_notice("Экран [scanner.declent_ru(GENITIVE)] загорается: \"Книга добавлена в локальное хранилище.\"."))
			if(1)
				playsound(src, 'sound/machines/ping.ogg', 20)
				scanner.book = src
				scanner.computer.buffer_book = name
				to_chat(user, span_notice("Экран [scanner.declent_ru(GENITIVE)] загорается: \"Книга добавлена в локальное хранилище. Книга была занесена в буфер привязанного компьютера.\"."))
			if(2)
				scanner.book = src
				for(var/datum/borrowbook/borrowbook as anything in scanner.computer.checkouts)
					if(borrowbook.bookname == name)
						playsound(src, 'sound/machines/ping.ogg', 20)
						scanner.computer.checkouts.Remove(borrowbook)
						to_chat(user, span_notice("Экран [scanner.declent_ru(GENITIVE)] загорается: \"Книга добавлена в локальное хранилище. Бронирование книги было зарегистрированно.\"."))
						return ATTACK_CHAIN_PROCEED_SUCCESS
				playsound(src, 'sound/machines/boop.ogg', 20)
				to_chat(user, span_notice("Экран [scanner.declent_ru(GENITIVE)] загорается: \"Книга добавлена в локальное хранилище. Для данной книги ещё не было офорлено бронирование.\"."))
			if(3)
				scanner.book = src
				for(var/obj/item/book as anything in scanner.computer.inventory)
					if(book == src)
						playsound(src, 'sound/machines/boop.ogg', 20)
						to_chat(user, span_notice("Экран [scanner.declent_ru(GENITIVE)] загорается: \"Книга добавлена в локальное хранилище. Книга уже была добавлена в базу данных. Действие отменено во избежание дублирования.\"."))
						return ATTACK_CHAIN_PROCEED_SUCCESS
				scanner.computer.inventory.Add(src)
				playsound(src, 'sound/machines/ping.ogg', 20)
				to_chat(user, span_notice("Экран [scanner.declent_ru(GENITIVE)] загорается: \"Книга добавлена в локальное хранилище. Книга была занесена в базу данных.\"."))
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
	if(I.tool_behaviour != TOOL_WIRECUTTER) //Only sharp and wirecutter things can carve books
		return FALSE
	if(!is_sharp(I))
		balloon_alert(user, "недостаточно острое!")
		return FALSE
	if(carved)
		balloon_alert(user, "уже изрезано!")
		return FALSE
	balloon_alert(user, "режем страницы...")
	if(!I.use_tool(src, user, 3 SECONDS, volume = I.tool_volume) || carved)
		return FALSE
	balloon_alert(user, "страницы вырезаны")
	carved = TRUE
	return TRUE


/*
 * Barcode Scanner
 */
/obj/item/barcodescanner
	name = "barcode scanner"
	desc = "Небольшое устройство для считывания штрих-кода с книг."
	gender = MALE
	icon = 'icons/obj/library.dmi'
	lefthand_file = 'icons/mob/inhands/equipment/library_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/library_righthand.dmi'
	icon_state = "scanner"
	item_state = "scanner"
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_TINY
	var/obj/machinery/computer/library/checkout/computer // Associated computer - Modes 1 to 3 use this
	var/obj/item/book/book	 //  Currently scanned book
	var/mode = 0					// 0 - Scan only, 1 - Scan and Set Buffer, 2 - Scan and Attempt to Check In, 3 - Scan and Attempt to Add to Inventory

/obj/item/barcodescanner/get_ru_names()
	return list(
		NOMINATIVE = "сканнер штрих-кодов",
		GENITIVE = "сканнера штрих-кодов",
		DATIVE = "сканнеру штрих-кодов",
		ACCUSATIVE = "сканнер штрих-кодов",
		INSTRUMENTAL = "сканнером штрих-кодов",
		PREPOSITIONAL = "сканнере штрих-кодов"
	)

/obj/item/barcodescanner/attack_self(mob/user)
	mode += 1
	if(mode > 4)
		mode = 0
	switch(mode)
		if(0)
			if(computer)
				to_chat(user, span_notice("Сканирование книг в локальное хранилище с попыткой добавление в базу данных."))
			else
				mode += 1

		if(1)
			if(computer)
				to_chat(user, span_green("Устройство привязанно к компьютеру."))
			else
				to_chat(user, span_red("Привязанный к устройству компьютер не найден. Доступно только локальное сканирование."))

		if(2)
			to_chat(user, span_notice("Сканирование книг в локальное хранилище."))

		if(3)
			if(computer)
				to_chat(user, span_notice("Сканирование книг в локальное хранилище с добалением в буфер привязанного компьютера."))
			else
				mode += 1

		if(4)
			if(computer)
				to_chat(user, span_notice("Сканирование книг в локальное хранилище с оформлением их брони."))
			else
				mode += 1

		else
			to_chat(user, span_notice("ОШИБКА."))
