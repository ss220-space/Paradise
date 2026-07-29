#define PHOTOCOPIER_DELAY 5 SECONDS
///Global limit on copied papers and photos, bundles are counted as a sum of their parts
#define MAX_COPIES_PRINTABLE 300

/obj/machinery/photocopier
	name = "photocopier"
	desc = "Устройство для сканирования и печати важных документов. На корпусе имеется надпись: \"НЕ САДИТЬСЯ!\"."
	icon = 'icons/obj/library.dmi'
	icon_state = "bigscanner"
	anchored = TRUE
	density = TRUE
	idle_power_usage = 30
	active_power_usage = 200
	max_integrity = 300
	integrity_failure = 100
	atom_say_verb = "пищит"
	interaction_flags_mouse_drop = NEED_DEXTERITY | ALLOW_RESTING

	COOLDOWN_DECLARE(copying_cooldown)

	var/insert_anim = "bigscanner_work"
	///Is the photocopier performing an action currently?
	var/copying = FALSE

	///Current obj stored in the copier to be copied
	var/obj/item/copyitem = null
	///Current folder obj stored in the copier to copy into
	var/obj/item/folder = null
	///Mob that is currently on the photocopier
	var/mob/living/copymob = null

	var/copies = 1

	/// A reference to the toner cartridge that's inserted into the copier. Null if there is no cartridge.
	var/obj/item/toner/toner_cartridge
	/// Type path of toner this photocopier should starts with. Null if he should start without it.
	var/obj/item/toner/starting_toner = /obj/item/toner

	/// How long it takes to print something in seconds
	var/time_to_print
	/// How efficent our toner is when printing
	var/toner_efficiency

	///Max number of copies that can be made at one time
	var/maxcopies = 10
	var/max_saved_documents = 5

	///Lazy init list, Objs currently saved inside the photocopier for printing later
	var/list/saved_documents

	///Total copies printed from copymachines globally
	var/static/total_copies = 0
	var/static/max_copies_reached = FALSE

	/// Selected form's category
	var/category = ""
	/// Selected form's id
	var/form_id = ""
	/// List of available forms
	var/list/forms
	/// Selected form's datum
	var/obj/item/paper/form/form = null // selected form for print
	/// Printing sound
	var/list/print_sounds = list('sound/goonstation/machines/printer_dotmatrix.ogg',
								'sound/machines/printer_dotmatrix2.ogg',
								'sound/machines/printer_dotmatrix3.ogg',
								'sound/machines/printer_dotmatrix4.ogg')
	var/syndicate = FALSE
	var/info_box = "Если у вас есть пожелания или\
					идеи для улучшения стандартных\
					форм, обратитесь в Отдел\
					стандартизации \"Нанотрейзен\"."
	var/info_box_color = "blue"
	var/ui_theme = "nanotrasen"// Если темы нету, будет взята стандартная НТ тема для интерфейса

/obj/machinery/photocopier/get_ru_names()
	return alist(
		NOMINATIVE = "ксерокс",
		GENITIVE = "ксерокса",
		DATIVE = "ксероксу",
		ACCUSATIVE = "ксерокс",
		INSTRUMENTAL = "ксероксом",
		PREPOSITIONAL = "ксероксе",
	)

/obj/machinery/photocopier/syndie
	name = "Syndicate photocopier"
	desc = "Устройство для сканирования и печати важных документов. Они даже не пытаются скрыть, что это их собственность..."
	syndicate = TRUE
	icon_state = "syndiebigscanner"
	insert_anim = "syndiebigscanner_work"
	info_box = "При использовании любой из данных форм,\
				обратите внимание на все пункты снизу. \
				Синдикат напоминает, что в ваших же интересах \
				соблюдать данные указания."
	ui_theme = "syndicate"

/obj/machinery/photocopier/syndie/get_ru_names()
	return alist(
		NOMINATIVE = "ксерокс \"Синдиката\"",
		GENITIVE = "ксерокса \"Синдиката\"",
		DATIVE = "ксероксу \"Синдиката\"",
		ACCUSATIVE = "ксерокс \"Синдиката\"",
		INSTRUMENTAL = "ксероксом \"Синдиката\"",
		PREPOSITIONAL = "ксероксе \"Синдиката\"",
	)

/obj/machinery/photocopier/ComponentInitialize()
	AddElement(/datum/element/elevation, pixel_shift = 8) //enough to look like your bums are on the machine.

/obj/machinery/photocopier/Initialize(mapload)
	. = ..()
	forms = new
	if(starting_toner)
		toner_cartridge = new starting_toner(src)
	component_parts = list()
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stock_parts/scanning_module(null)
	RefreshParts()

/obj/machinery/photocopier/RefreshParts()
	. = ..()
	toner_efficiency = 1
	for(var/obj/item/stock_parts/micro_laser/micro_laser in component_parts)
		toner_efficiency += micro_laser.rating

	time_to_print = PHOTOCOPIER_DELAY
	for(var/obj/item/stock_parts/scanning_module/scanning_module in component_parts)
		time_to_print -= (scanning_module.rating SECONDS)

/obj/machinery/photocopier/Destroy()
	QDEL_NULL(toner_cartridge)
	QDEL_LIST(saved_documents)
	return ..()

/obj/machinery/photocopier/attack_ai(mob/user)
	src.add_hiddenprint(user)
	parse_forms(user)
	ui_interact(user)

/obj/machinery/photocopier/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/photocopier/attack_hand(mob/user)
	if(..())
		return TRUE
	parse_forms(user)
	ui_interact(user)

/**
 * Public proc for copying paper objs
 *
 * Takes a paper object and makes a copy of it. This proc specifically does not change toner which allows more versatile use for child objects
 * returns null if paper failed to be copied and returns the new copied paper obj if succesful
 * Arguments:
 * * obj/item/paper/copy - The paper obj to be copied
 * * scanning -  If true, the photo is stored inside the photocopier and we do not check for toner
 * * bundled - If true the photo is stored inside the photocopier, used by bundlecopy() to construct paper bundles
 */
/obj/machinery/photocopier/proc/papercopy(obj/item/paper/copy, scanning = FALSE, bundled = FALSE)
	if(!scanning)
		if(toner_cartridge.charges < 1)
			balloon_alert(usr, "недостаточно чернил!")
			visible_message(span_notice("На корпусе [declent_ru(GENITIVE)] загорается жёлтая лампочка, обозначая недостаток чернил для завершения операции."))
			return null
		total_copies++
	var/obj/item/paper/c = new /obj/item/paper (loc)
	if(scanning || bundled)
		c.forceMove(src)
	else if(folder)
		c.forceMove(folder)
	c.header = copy.header
	c.info = copy.info
	c.footer = copy.footer
	c.name = copy.name // -- Doohl
	c.fields = copy.fields
	c.stamps = copy.stamps
	c.language = copy.language
	c.stamped = LAZYLISTDUPLICATE(copy.stamped)
	if(LAZYLEN(copy.stamp_overlays))
		for(var/mutable_appearance/overlay as anything in copy.stamp_overlays)	//gray overlay onto the copy
			var/mutable_appearance/new_mutable
			if(findtext(overlay.icon_state, "cap") || findtext(overlay.icon_state, "cent") || findtext(overlay.icon_state, "rep") || findtext(overlay.icon_state, "magistrate") || findtext(overlay.icon_state, "navcom"))
				new_mutable = mutable_appearance('icons/obj/bureaucracy.dmi', "paper_stamp-circle")
			else if(findtext(overlay.icon_state, "deny"))
				new_mutable = mutable_appearance('icons/obj/bureaucracy.dmi', "paper_stamp-x")
			else if(findtext(overlay.icon_state, "ok"))
				new_mutable = mutable_appearance('icons/obj/bureaucracy.dmi', "paper_stamp-check")
			else
				new_mutable = mutable_appearance('icons/obj/bureaucracy.dmi', "paper_stamp-dots")
			new_mutable.pixel_w = overlay.pixel_w
			new_mutable.pixel_z = overlay.pixel_z
			LAZYADD(c.stamp_overlays, new_mutable)
	c.updateinfolinks()
	c.update_icon()
	return c

/**
 * Public proc for copying photo objs
 *
 * Takes a photo object and makes a copy of it. This proc specifically does not change toner which allows more versatile use for child objects
 * returns null if photo failed to be copied and returns the new copied photo object if succesful
 * Arguments:
 * * obj/item/photo/photocopy - The photo obj to be copied
 * * scanning -  If true, the photo is stored inside the photocopier and we do not check for toner
 * * bundled - If true the photo is stored inside the photocopier, used by bundlecopy() to construct paper bundles
 */
/obj/machinery/photocopier/proc/photocopy(obj/item/photo/photocopy, scanning = FALSE, bundled = FALSE)
	if(!scanning) //If we're just storing this as a file inside the copier then we don't expend toner
		if(toner_cartridge.charges < 5)
			balloon_alert(usr, "недостаточно чернил!")
			visible_message(span_notice("На корпусе [declent_ru(GENITIVE)] загорается жёлтая лампочка, обозначая недостаток чернил для завершения операции."))
			return null
		total_copies++

	var/obj/item/photo/p = new /obj/item/photo (loc)
	if(scanning || bundled)
		p.forceMove(src)
	else if(folder)
		p.forceMove(folder)
	p.name = photocopy.name
	p.icon = photocopy.icon
	p.tiny = photocopy.tiny
	p.img = photocopy.img
	p.desc = photocopy.desc
	p.pixel_x = rand(-10, 10)
	p.pixel_y = rand(-10, 10)
	if(photocopy.scribble)
		p.scribble = photocopy.scribble
	return p

/obj/machinery/photocopier/proc/blueprintcopy(obj/item/craft_blueprints/original)
	if(!original.copy_type)
		balloon_alert(usr, "невозможно копировать!")
		return

	if(toner_cartridge.charges < original.required_toner)
		balloon_alert(usr, "недостаточно чернил!")
		visible_message(span_notice("На корпусе [declent_ru(GENITIVE)] загорается жёлтая лампочка, обозначая недостаток чернил для завершения операции."))
		return

	total_copies++

	var/obj/item/craft_blueprints/copy = new original.copy_type(loc)
	copy.name = original.name
	copy.crafting_name = original.crafting_name
	copy.crafting_item = original.crafting_item
	copy.tools = original.tools
	copy.components = original.components
	copy.craft_duration = original.craft_duration
	copy.crafting_name = original.crafting_name
	copy.copy_type = null
	copy.pixel_x = rand(-10, 10)
	copy.pixel_y = rand(-10, 10)
	return copy

/obj/machinery/photocopier/proc/copyass(scanning = FALSE)
	if(!scanning) //If we're just storing this as a file inside the copier then we don't expend toner
		if(toner_cartridge.charges < 5)
			balloon_alert(usr, "недостаточно чернил!")
			visible_message(span_notice("На корпусе [declent_ru(GENITIVE)] загорается жёлтая лампочка, обозначая недостаток чернил для завершения операции."))
			return null
		total_copies++

	var/icon/temp_img

	if(emagged)
		if(ishuman(copymob))
			copymob.apply_damage(30, BURN, BODY_ZONE_PRECISE_GROIN)
			if(copymob.has_pain())
				copymob.emote("scream")
		else
			copymob.apply_damage(30, BURN)
		to_chat(copymob, span_notice("Что-то жаренным запахло..."))
	if(ishuman(copymob)) //Suit checks are in check_mob
		var/mob/living/carbon/human/H = copymob
		temp_img = icon('icons/obj/butts.dmi', H.dna.species.butt_sprite)
	else if(isdrone(copymob))
		temp_img = icon('icons/obj/butts.dmi', "drone")
	else if(isnymph(copymob))
		temp_img = icon('icons/obj/butts.dmi', "nymph")
	else if(isalien(copymob) || istype(copymob,/mob/living/simple_animal/hostile/alien)) //Xenos have their own asses, thanks to Pybro.
		temp_img = icon('icons/obj/butts.dmi', "xeno")
	else
		return
	var/obj/item/photo/p = new /obj/item/photo(loc)
	if(scanning)
		p.forceMove(src)
	else if(folder)
		p.forceMove(folder)
	p.desc = "На фото вы видите задницу [copymob.declent_ru(GENITIVE)]."
	p.pixel_x = rand(-10, 10)
	p.pixel_y = rand(-10, 10)
	p.img = temp_img
	var/icon/small_img = icon(temp_img) //Icon() is needed or else temp_img will be rescaled too >.>
	var/icon/ic = icon('icons/obj/items.dmi',"photo")
	small_img.Scale(8, 8)
	ic.Blend(small_img,ICON_OVERLAY, 10, 13)
	p.icon = ic
	return p

/**
 * A public proc for copying bundles of paper
 *
 * It iterates through each object in the bundle and calls papercopy() and photocopy() and stores the produce photo/paper in the bundle
 * Arguments:
 * * bundle - The paper bundle object being copied
 * * scanning - If true, the paper bundle is stored inside the photocopier
 * * use_toner - If true, this operation uses toner, this is not done in copy() because partial bundles would be impossible otherwise
 */
/obj/machinery/photocopier/proc/bundlecopy(obj/item/paper_bundle/bundle, scanning = FALSE, use_toner = FALSE)
	var/obj/item/paper_bundle/P = new(src, FALSE)	//Bundle is initially inside copier to give copier time to build the bundle before the player can pick it up
	for(var/obj/item/thing as anything in bundle.papers)
		if(istype(thing, /obj/item/paper))
			thing = papercopy(thing, bundled = TRUE)
			if(use_toner && thing)
				use_toner(1) //In order to allow partial bundles we have to handle toner +- inside the proc
		else if(istype(thing, /obj/item/photo))
			thing = photocopy(thing, bundled = TRUE)
			if(use_toner && thing)
				use_toner(5)
		if(!thing)
			break
		thing.forceMove(P)
		P.amount++
		P.papers += thing
	P.amount-- //amount variable should be the number of pages in addition to the first (#pages - 1) this avoids runtimes from index errors
	if(P.amount <= 0) //if we did not have enough toner to complete the second page, delete the bundle
		qdel(P)
		return FALSE
	if(!scanning)
		total_copies++
		if(folder) //Since bundle is still inside the copier, we need to finally move it out
			P.forceMove(folder)
		else
			P.forceMove(loc)

	P.update_appearance(UPDATE_ICON|UPDATE_DESC)
	P.name = bundle.name
	P.pixel_y = rand(-8, 8)
	P.pixel_x = rand(-9, 9)
	return P

/obj/machinery/photocopier/proc/remove_document()
	if(copying)
		balloon_alert(usr, "сканер ещё работает!")
		return
	if(copyitem)
		copyitem.forceMove(get_turf(src))
		if(ishuman(usr))
			usr.put_in_hands(copyitem)
		to_chat(usr, span_notice("Вы вынимаете [copyitem.declent_ru(ACCUSATIVE)] из [declent_ru(GENITIVE)]."))
		copyitem = null

	else if(check_mob())
		to_chat(copymob, span_notice("Вы ощущаете лёгкое давление на вашу задницу."))
		atom_say("Внимание: Не удается извлечь крупный предмет!", FALSE)

/obj/machinery/photocopier/proc/remove_folder()
	if(copying)
		balloon_alert(usr, "сканер ещё работает!")
		return
	if(folder)
		folder.forceMove(get_turf(src))
		if(ishuman(usr))
			usr.put_in_hands(folder)
		to_chat(usr, span_notice("Вы вынимаете [folder.declent_ru(ACCUSATIVE)] из [declent_ru(GENITIVE)]."))
		folder = null

/**
 * An internal proc for checking if a photocopier is able to copy an object
 *
 * It performs early checks/returns to see if the copier has any toner, if the copier is powered/working,
 * if the copier is currently perfoming an action, or if we've hit the global copy limit. Used to inform
 * the player in-game if they're using the photocopier incorrectly (no toner, no item inside, etc)
 * Arguments:
 * * scancopy - If TRUE, cancopy does not check for an item on/inside the copier to copy, used for copying stored files
 */
/obj/machinery/photocopier/proc/cancopy(scancopy = FALSE) //are we able to make a copy of a doc?
	if(stat & (BROKEN|NOPOWER))
		return FALSE
	if(copying) //are we in the process of copying something already?
		balloon_alert(usr, "сканер ещё работает!")
		return FALSE
	if(!scancopy && toner_cartridge.charges <= 0) //if we're not scanning lets check early that we actually have toner
		balloon_alert(usr, "недостаточно чернил!")
		visible_message(span_notice("На корпусе [declent_ru(GENITIVE)] загорается жёлтая лампочка, обозначая недостаток чернил для завершения операции."))
		return FALSE
	if(max_copies_reached)
		visible_message(span_warning("На экране сканера появляется надпись: \"ДОСТИГНУТО МАКСИМАЛЬНОЕ КОЛИЧЕСТВО КОПИЙ, КСЕРОКС ОТКЛЮЧЕН ОТ СЕТИ: ПОЖАЛУЙСТА, СВЯЖИТЕСЬ С СИСТЕМНЫМ АДМИНИСТРАТОРОМ\""))
		return FALSE
	if(total_copies >= MAX_COPIES_PRINTABLE)
		visible_message(span_warning("На экране сканера появляется надпись: \"ДОСТИГНУТО МАКСИМАЛЬНОЕ КОЛИЧЕСТВО КОПИЙ, КСЕРОКС ОТКЛЮЧЕН ОТ СЕТИ: ПОЖАЛУЙСТА, СВЯЖИТЕСЬ С СИСТЕМНЫМ АДМИНИСТРАТОРОМ\""))
		message_admins("Photocopier cap of [MAX_COPIES_PRINTABLE] paper copies reached, all photocopiers are now disabled.")
		max_copies_reached = TRUE
	if(!check_mob() && (!copyitem && !scancopy)) //is there anything in or ontop of the machine? If not, is this a scanned file?
		balloon_alert(usr, "сканер пуст!")
		visible_message(span_notice("На корпусе [declent_ru(GENITIVE)] загорается красная лампочка, обозначая то, что в устройстве нечего копировать."))
		return FALSE
	return TRUE

/**
 * Public proc for copying items
 *
 * Determines what item needs to be copied whether it's a mob's ass, paper, bundle, or photo and then calls the respective
 * proc for it. Most toner var changing happens here so that the faxmachine child obj does not need to worry about toner
 * Arguments:
 * * obj/item/C - The item stored inside the photocopier to be copied (obj/paper, obj/photo, obj/paper_bundle)
 * * scancopy - Indicates that obj/item/C is a stored file, we need to pass this on to cancopy() so it passes the check
 */
/obj/machinery/photocopier/proc/copy(obj/item/C, scancopy = FALSE)
	if(!cancopy(scancopy))
		return
	copying = TRUE

	var/count_of_copies = 0

	if(istype(C, /obj/item/paper))
		for(var/i in copies to 1 step -1)
			if(!papercopy(C))
				break
			use_toner(1)
			count_of_copies++
			use_power(active_power_usage)
			addtimer(CALLBACK(src, PROC_REF(finish_copying)), time_to_print)
	else if(istype(C, /obj/item/photo))
		for(var/i in copies to 1 step -1)
			if(!photocopy(C))
				break
			use_toner(5)
			count_of_copies++
			use_power(active_power_usage)
			addtimer(CALLBACK(src, PROC_REF(finish_copying)), time_to_print)
	else if(istype(C, /obj/item/paper_bundle))
		var/obj/item/paper_bundle/B = C
		for(var/i in copies to 1 step -1)
			if(!bundlecopy(C, use_toner = TRUE))
				break
			count_of_copies++
			use_power(active_power_usage)
			addtimer(CALLBACK(src, PROC_REF(finish_copying)), time_to_print * (B.amount + 1))
	else if(check_mob()) //Once we've scanned the copy_mob's ass we do not need to again
		for(var/i in copies to 1 step -1)
			if(!copyass())
				balloon_alert(usr, "нельзя отсканировать!")
				break
			use_toner(5)
			count_of_copies++
		finish_copying()
	else if(istype(C, /obj/item/craft_blueprints))
		var/obj/item/craft_blueprints/original = C
		for(var/i in copies to 1 step -1)
			if(!blueprintcopy(original))
				break
			use_toner(original.required_toner)
			count_of_copies++
			use_power(active_power_usage)
			addtimer(CALLBACK(src, PROC_REF(finish_copying)), time_to_print)
	else
		balloon_alert(usr, "нельзя отсканировать!")
		to_chat(usr, span_warning("[DECLENT_RU_CAP(src, NOMINATIVE)] не способен отсканировать [copyitem.declent_ru(ACCUSATIVE)], [copyitem.declent_ru(NOMINATIVE)] будет извлечен[GEND_A_O_Y(copyitem)]."))
		copyitem.forceMove(loc) // fuckery detected! get off my photocopier... shitbird!
		finish_copying()
	if(count_of_copies) // if there is at least one copy
		playsound(loc, pick(print_sounds), 50, TRUE)
		return
	balloon_alert(usr, "нельзя отсканировать!")

/obj/machinery/photocopier/proc/finish_copying()
	copying = FALSE

/obj/machinery/photocopier/proc/scan_document() //scan a document into a file
	if(!cancopy())
		return
	if(length(saved_documents) >= max_saved_documents)
		balloon_alert(usr, "нет памяти!")
		to_chat(usr, span_warning("[DECLENT_RU_CAP(src, NOMINATIVE)] не способен отсканировать [copyitem.declent_ru(ACCUSATIVE)] в связи с тем, что лимит сохранённых файлов был достигнут. Для продолжения операции освободите память устройства."))
		return
	copying = TRUE
	var/obj/item/O
	//Instead of calling copy() we jump ahead and use the procs that do the heavy lifting to avoid using toner since we're only scanning
	if(istype(copyitem, /obj/item/paper))
		O = papercopy(copyitem, scanning = TRUE)
	else if(istype(copyitem, /obj/item/photo))
		O = photocopy(copyitem, scanning = TRUE)
	else if(istype(copyitem, /obj/item/paper_bundle))
		O = bundlecopy(copyitem, scanning = TRUE, use_toner = FALSE)
	else if(copymob && copymob.loc == loc)
		O = copyass(scanning = TRUE)
	else
		to_chat(usr, span_warning("[declent_ru(NOMINATIVE)] не может отсканировать [copyitem.declent_ru(ACCUSATIVE)]."))
		copying = FALSE
		return
	use_power(active_power_usage)
	COOLDOWN_START(src, copying_cooldown, time_to_print)
	LAZYADD(saved_documents, O)
	copying = FALSE
	playsound(loc, 'sound/machines/ping.ogg', 50, FALSE)
	atom_say("Документ успешно отсканирован!", FALSE)

/obj/machinery/photocopier/proc/delete_file(uid)
	var/document = locateUID(uid)
	if(LAZYIN(saved_documents, document)) //double checking that the list exists b4 we find document
		LAZYREMOVE(saved_documents, document)
		qdel(document)

/obj/machinery/photocopier/proc/file_copy(uid)
	var/document = locateUID(uid)
	if(LAZYIN(saved_documents, document))
		copy(document, scancopy = TRUE)

/obj/machinery/photocopier/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/photocopier/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Photocopier", "Ксерокс")
		ui.open()

/obj/machinery/photocopier/ui_data(mob/user)
	if(!length(forms))
		parse_forms(user)

	var/list/data = list()
	data["isAI"] = issilicon(user)
	data["copies"] = copies
	data["maxcopies"] = maxcopies
	if(toner_cartridge)
		data["has_toner"] = TRUE
		data["current_toner"] = toner_cartridge.charges
		data["max_toner"] = toner_cartridge.max_charges
	else
		data["has_toner"] = FALSE
	data["copyitem"] = (copyitem ? copyitem.name : null)
	data["folder"] = (folder ? folder.name : null)
	data["mob"] = (copymob ? copymob.name : null)
	data["form"] = form
	data["category"] = category
	data["form_id"] = form_id
	data["forms"] = forms
	data["ui_theme"] = ui_theme
	return data

/obj/machinery/photocopier/ui_act(action, list/params, datum/tgui/ui)
	if(..())
		return
	. = FALSE
	if(!COOLDOWN_FINISHED(src, copying_cooldown))
		balloon_alert(usr, "сканер ещё работает!")
		return
	add_fingerprint(usr)
	switch(action)
		if("copy")
			copy(copyitem)
		if("removedocument")
			remove_document()
			. = TRUE
		if("removefolder")
			remove_folder()
			. = TRUE
		if("add")
			if(copies < maxcopies)
				copies++
				. = TRUE
		if("minus")
			if(copies > 0)
				copies--
				. = TRUE
		if("scandocument")
			scan_document()
		if("ai_text")
			ai_text(ui.user)
		if("ai_pic")
			ai_pic()
		if("filecopy")
			file_copy(params["uid"])
		if("deletefile")
			delete_file(params["uid"])
			. = TRUE
		if("print_form")
			for(var/i in 1 to copies)
				if(toner_cartridge.charges <= 0)
					break
				print_form(form)
			. = TRUE
		if("choose_form")
			form = params["path"]
			form_id = params["id"]
			. = TRUE
		if("choose_category")
			category = params["category"]
			. = TRUE
		if("copies")
			copies = clamp(text2num(params["new"]), 0, maxcopies)

		if("remove_toner")
			var/success = usr.put_in_hands(toner_cartridge)
			if(!success)
				toner_cartridge.forceMove(drop_location())

			toner_cartridge = null
			return TRUE

	update_appearance(UPDATE_ICON)


/obj/machinery/photocopier/proc/ai_text(mob/user)
	if(!issilicon(user))
		return
	if(stat & (BROKEN|NOPOWER))
		return

	var/text = tgui_input_text(user, "Напишите то, что хотите:", "Письмо")
	if(!text)
		return
	if(toner_cartridge.charges < 1 || !user)
		return
	playsound(loc, pick(print_sounds), 50, TRUE)
	var/obj/item/paper/p = new (loc)
	text = p.parsepencode(text, null, user)
	p.info = text
	p.populatefields()
	use_toner(1)
	use_power(active_power_usage)
	COOLDOWN_START(src, copying_cooldown, time_to_print)

/obj/machinery/photocopier/proc/ai_pic()
	if(!issilicon(usr))
		return
	if(stat & (BROKEN|NOPOWER))
		return
	if(toner_cartridge.charges < 5)
		return
	var/mob/living/silicon/tempAI = usr
	var/obj/item/camera/siliconcam/camera = tempAI.aiCamera

	if(!camera)
		return
	var/datum/picture/selection = camera.selectpicture()
	if(!selection)
		return

	playsound(loc, pick(print_sounds), 50, TRUE)
	var/obj/item/photo/p = new /obj/item/photo(loc)
	p.construct(selection)
	if(p.desc == "")
		p.desc += "Ксерокопия была сделана [tempAI.name]"
	else
		p.desc += " – Ксерокопия была сделана [tempAI.name]"
	use_toner(5)
	use_power(active_power_usage)
	COOLDOWN_START(src, copying_cooldown, time_to_print)

/obj/machinery/photocopier/proc/parse_forms(mob/user)
	var/list/access = user.get_access()
	forms = list()
	var/static/list/printer_forms
	if(!printer_forms)
		printer_forms = valid_subtypesof(/obj/item/paper/form)
	var/cached_syndicate = syndicate
	for(var/obj/item/paper/form/form_type as anything in printer_forms)
		var/req_access = form_type.access
		if(req_access && !(req_access in access))
			continue
		if(cached_syndicate && !(form_type.syndicate))
			continue
		if(!cached_syndicate && !emagged && (form_type.syndicate))
			continue
		var/list/form = list()
		form["path"] = form_type
		form["id"] = form_type.id
		form["altername"] = form_type.altername
		form["category"] = form_type.category
		forms += list(form)

/obj/machinery/photocopier/proc/print_form(obj/item/paper/form/form)
	if(copying)
		balloon_alert(usr, "сканер ещё работает!")
		return FALSE

	use_toner(1)
	copying = TRUE
	playsound(loc, pick(print_sounds), 50)
	use_power(active_power_usage)
	addtimer(CALLBACK(src, PROC_REF(do_print_form_paper), form), time_to_print)

/obj/machinery/photocopier/proc/do_print_form_paper(obj/item/paper/form/form)
	var/obj/item/paper/paper = new form(loc)
	paper.pixel_x = rand(-10, 10)
	paper.pixel_y = rand(-10, 10)
	finish_copying()

/obj/machinery/photocopier/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(I, /obj/item/paper) || istype(I, /obj/item/photo) || istype(I, /obj/item/paper_bundle) || istype(I, /obj/item/craft_blueprints))
		add_fingerprint(user)
		if(copyitem)
			balloon_alert(user, "ксерокс занят!")
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		copyitem = I
		to_chat(user, span_notice("Вы вставляете [I.declent_ru(ACCUSATIVE)] в [declent_ru(ACCUSATIVE)]."))
		flick(insert_anim, src)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/toner))
		add_fingerprint(user)
		if(toner_cartridge)
			balloon_alert(user, "another cartridge inside!")
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		toner_cartridge = I
		balloon_alert(user, "вставлено")
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()

/obj/machinery/photocopier/grab_attack(mob/living/grabber, atom/movable/grabbed_thing)
	. = TRUE
	if(grabber.grab_state < GRAB_AGGRESSIVE || !isliving(grabbed_thing) || grabbed_thing == copymob)
		return .
	add_fingerprint(grabber)
	visible_message(span_warning("[grabber] затаскива[PLUR_ET_YUT(grabber)] [grabbed_thing.declent_ru(ACCUSATIVE)] на [declent_ru(ACCUSATIVE)]!"))
	var/turf/source_turf = get_turf(src)
	grabbed_thing.forceMove(source_turf)
	copymob = grabbed_thing
	if(copyitem)
		copyitem.forceMove(source_turf)
		copyitem = null

/obj/machinery/photocopier/wrench_act(mob/user, obj/item/I)
	. = TRUE
	default_unfasten_wrench(user, I)

/obj/machinery/photocopier/obj_break(damage_flag)
	. = ..()
	if(. && toner_cartridge?.charges && !(obj_flags & NODECONSTRUCT))
		new /obj/effect/decal/cleanable/blood/oil(get_turf(src))
		toner_cartridge.charges = 0

/obj/machinery/photocopier/mouse_drop_receive(mob/target, mob/living/user, params)
	if(!istype(target) || target.buckled || get_dist(user, src) > 1 || get_dist(user, target) > 1 || user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || isAI(user))
		return
	if(check_mob()) //is target mob or another mob on this photocopier already?
		return
	add_fingerprint(user)
	if(target == user)
		visible_message(span_warning("[user] запрыгива[PLUR_ET_YUT(user)] на [declent_ru(ACCUSATIVE)]!"))
	else if(target != user)
		if(target.anchored || !ishuman(user))
			return
		visible_message(span_warning("[user] затаскива[PLUR_ET_YUT(user)] [target.declent_ru(ACCUSATIVE)] на [declent_ru(ACCUSATIVE)]!"))
	target.forceMove(get_turf(src))
	copymob = target
	if(copyitem)
		copyitem.forceMove(get_turf(src))
		visible_message(span_notice("[DECLENT_RU_CAP(copymob, NOMINATIVE)] сталкива[PLUR_ET_YUT(user)] [copyitem.declent_ru(ACCUSATIVE)] со своего пути!"))
		copyitem = null
	playsound(loc, 'sound/machines/ping.ogg', 50, FALSE)
	atom_say("Внимание: На стеклянной плаформе обнаружены ягодицы!", FALSE)
	SStgui.update_uis(src)

/**
 * Internal proc for checking the Mob on top of the copier
 * Reports FALSE if there is no copymob or if the copymob is in a diff location than the copy machine, otherwise reports TRUE
 */
/obj/machinery/photocopier/proc/check_mob()
	if(!copymob)
		return FALSE
	if(copymob.loc != loc)
		copymob = null
		return FALSE
	else
		return TRUE

/obj/machinery/photocopier/emag_act(mob/user)
	if(!emagged)
		emagged = TRUE
		if(user)
			balloon_alert(user, "взломано")
	else if(user)
		balloon_alert(user, "уже взломано!")

/**
 * Removes a certain amount of toner that is affected by the efficiency of stock parts
 */
/obj/machinery/photocopier/proc/use_toner(amount)
	toner_cartridge.charges -= (amount / toner_efficiency)

/*
 * Toner cartridge
 */
/obj/item/toner
	name = "toner cartridge"
	desc = "Стандартный картридж с чернилами для ксероксов на 30 использований. Пользуется высоким спросом у бюрократов."
	icon = 'icons/obj/device.dmi'
	icon_state = "tonercartridge"
	w_class = WEIGHT_CLASS_SMALL
	//custom_materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT * 0.1, /datum/material/glass = SMALL_MATERIAL_AMOUNT * 0.1)
	var/charges = 5
	var/max_charges = 5

/obj/item/toner/get_ru_names()
	return alist(
		NOMINATIVE = "тонер-картридж",
		GENITIVE = "тонер-картриджа",
		DATIVE = "тонер-картриджу",
		ACCUSATIVE = "тонер-картридж",
		INSTRUMENTAL = "тонер-картриджом",
		PREPOSITIONAL = "тонер-картридже",
	)
/*
/obj/item/toner/grind_results()
	return list(/datum/reagent/iodine = 40, /datum/reagent/iron = 10)
*/

/obj/item/toner/examine(mob/user)
	. = ..()
	. += span_notice("The ink level gauge on the side reads [round(charges / max_charges * 100)]%")

/obj/item/toner/large
	name = "large toner cartridge"
	desc = "A hefty cartridge of Nanotrasen ValueBrand toner. Fits photocopiers and autopainters alike."
	//custom_materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT * 0.5, /datum/material/glass = SMALL_MATERIAL_AMOUNT * 0.5)
	charges = 25
	max_charges = 25

/obj/item/toner/large/get_ru_names()
	return alist(
		NOMINATIVE = "большой тонер-картридж",
		GENITIVE = "большого тонер-картриджа",
		DATIVE = "большому тонер-картриджу",
		ACCUSATIVE = "большой тонер-картридж",
		INSTRUMENTAL = "большим тонер-картриджом",
		PREPOSITIONAL = "большом тонер-картридже",
	)
/*
/obj/item/toner/large/grind_results()
	return list(/datum/reagent/iodine = 90, /datum/reagent/iron = 10)
*/

/obj/item/toner/extreme
	name = "extremely large toner cartridge"
	desc = "Why would ANYONE need THIS MUCH TONER?"
	w_class = WEIGHT_CLASS_NORMAL
	//custom_materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT * 4, /datum/material/glass = SMALL_MATERIAL_AMOUNT * 4)
	charges = 200
	max_charges = 200

/obj/item/toner/extreme/get_ru_names()
	return alist(
		NOMINATIVE = "огромный тонер-картридж",
		GENITIVE = "огромного тонер-картриджа",
		DATIVE = "огромному тонер-картриджу",
		ACCUSATIVE = "огромный тонер-картридж",
		INSTRUMENTAL = "огромным тонер-картриджом",
		PREPOSITIONAL = "огромном тонер-картридже",
	)

/obj/item/toner/infinite
	name = "infinite toner cartridge"
	desc = "...are you satisfied now?"
	charges = INFINITY
	max_charges = INFINITY

/obj/item/toner/infinite/get_ru_names()
	return alist(
		NOMINATIVE = "бесконечный тонер-картридж",
		GENITIVE = "бесконечного тонер-картриджа",
		DATIVE = "бесконечному тонер-картриджу",
		ACCUSATIVE = "бесконечный тонер-картридж",
		INSTRUMENTAL = "бесконечным тонер-картриджом",
		PREPOSITIONAL = "бесконечном тонер-картридже",
	)

#undef PHOTOCOPIER_DELAY
#undef MAX_COPIES_PRINTABLE
