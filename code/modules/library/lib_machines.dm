#define LIBRARY_BOOKS_PER_PAGE 25

GLOBAL_DATUM_INIT(library_catalog, /datum/library_catalog, new())
GLOBAL_LIST_INIT(library_section_names, list("Any", "Fiction", "Non-Fiction", "Adult", "Reference", "Religion"))

/*
 * Borrowbook datum
 */
/datum/borrowbook // Datum used to keep track of who has borrowed what when and for how long.
	var/bookname
	var/mobname
	var/getdate
	var/duedate

/*
 * Cachedbook datum
 */
/datum/cachedbook // Datum used to cache the SQL DB books locally in order to achieve a performance gain.
	var/id
	var/title
	var/author
	var/ckey // ADDED 24/2/2015 - N3X
	var/category
	var/content
	var/programmatic=0                // Is the book programmatically added to the catalog?
	var/forbidden=0
	var/path = /obj/item/book // Type path of the book to generate
	var/flagged = 0
	var/flaggedby

/datum/cachedbook/proc/LoadFromRow(var/list/row)
	id = row["id"]
	author = row["author"]
	title = row["title"]
	category = row["category"]
	ckey = row["ckey"]
	flagged = row["flagged"]
	flaggedby = row["flaggedby"]
	if("content" in row)
		content = row["content"]
	programmatic=0

// Builds a SQL statement
/datum/library_query
	var/author
	var/category
	var/title

// So we can have catalogs of books that are programmatic, and ones that aren't.
/datum/library_catalog
	var/list/cached_books = list()

/datum/library_catalog/New()
	var/newid=1
	for(var/typepath in subtypesof(/obj/item/book/manual))
		var/obj/item/book/B = new typepath(null)
		var/datum/cachedbook/CB = new()
		CB.forbidden = B.forbidden
		CB.title = B.name
		CB.author = B.author
		CB.programmatic=1
		CB.path=typepath
		CB.id = "M[newid]"
		newid++
		cached_books["[CB.id]"]=CB

/datum/library_catalog/proc/flag_book_by_id(mob/user, id)
	var/global/books_flagged_this_round[0]

	if("[id]" in cached_books)
		var/datum/cachedbook/CB = cached_books["[id]"]
		if(CB.programmatic)
			to_chat(user, "<span class='danger'>That book cannot be flagged in the system, as it does not actually exist in the database.</span>")
			return

	if("[id]" in books_flagged_this_round)
		to_chat(user, "<span class='danger'>This book has already been flagged this shift.</span>")
		return

	books_flagged_this_round["[id]"] = 1
	message_admins("[key_name_admin(user)] has flagged book #[id] as inappropriate.")

	log_game("[user] (ckey: [user.key]) has flagged book #[id] as inappropriate.")

	var/datum/db_query/query = SSdbcore.NewQuery("UPDATE [format_table_name("library")] SET flagged = flagged + 1, flaggedby=:flaggedby WHERE id=:id", list(
		"id" = text2num(id),
		"flaggedby" = user.key
	))
	if(!query.warn_execute())
		qdel(query)
		return
	qdel(query)

/datum/library_catalog/proc/rmBookByID(mob/user, id)
	if("[id]" in cached_books)
		var/datum/cachedbook/CB = cached_books["[id]"]
		if(CB.programmatic)
			to_chat(user, "<span class='danger'>That book cannot be removed from the system, as it does not actually exist in the database.</span>")
			return

	var/datum/db_query/query = SSdbcore.NewQuery("DELETE FROM [format_table_name("library")] WHERE id=:id", list(
		"id" = text2num(id)
	))
	if(!query.warn_execute())
		qdel(query)
		return
	qdel(query)

/datum/library_catalog/proc/getBookByID(id)
	if("[id]" in cached_books)
		return cached_books["[id]"]

	var/datum/db_query/query = SSdbcore.NewQuery("SELECT id, author, title, category, content, ckey, flagged, flaggedby FROM [format_table_name("library")] WHERE id=:id", list(
		"id" = text2num(id)
	))
	if(!query.warn_execute())
		qdel(query)
		return

	var/list/results=list()
	while(query.NextRow())
		var/datum/cachedbook/CB = new()
		CB.LoadFromRow(list(
			"id"      =query.item[1],
			"author"  =query.item[2],
			"title"   =query.item[3],
			"category"=query.item[4],
			"content" =query.item[5],
			"ckey"    =query.item[6],
			"flagged" =query.item[7],
			"flaggedby"=query.item[8]
		))
		results += CB
		cached_books["[id]"]=CB
		qdel(query)
		return CB
	qdel(query)
	return results

/** Scanner **/
/obj/machinery/libraryscanner
	name = "scanner"
	icon = 'icons/obj/library.dmi'
	icon_state = "bigscanner"
	anchored = TRUE
	density = TRUE
	var/obj/item/book/cache		// Last scanned book


/obj/machinery/libraryscanner/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(I, /obj/item/book))
		add_fingerprint(user)
		// NT with those pesky DRM schemes
		var/obj/item/book/book = I
		if(book.has_drm)
			atom_say("Copyrighted material detected. Scanner is unable to copy book to memory.")
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(book, src))
			return ..()
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/machinery/libraryscanner/wrench_act(mob/living/user, obj/item/I)
	return default_unfasten_wrench(user, I)


/obj/machinery/libraryscanner/attack_hand(mob/user)
	if(istype(user,/mob/dead))
		to_chat(user, "<span class='danger'>Nope.</span>")
		return
	add_fingerprint(user)
	usr.set_machine(src)
	var/dat = {"<meta charset="UTF-8"><HEAD><TITLE>Scanner Control Interface</TITLE></HEAD><BODY>\n"} // <META HTTP-EQUIV='Refresh' CONTENT='10'>
	if(cache)
		dat += "<FONT color=#005500>Data stored in memory.</FONT><BR>"
	else
		dat += "No data stored in memory.<BR>"
	dat += "<a href='byond://?src=[UID()];scan=1'>\[Scan\]</A>"
	if(cache)
		dat += "       <a href='byond://?src=[UID()];clear=1'>\[Clear Memory\]</A><BR><BR><a href='byond://?src=[UID()];eject=1'>\[Remove Book\]</A>"
	else
		dat += "<BR>"
	user << browse(dat, "window=scanner")
	onclose(user, "scanner")

/obj/machinery/libraryscanner/Topic(href, href_list)
	if(..())
		usr << browse(null, "window=scanner")
		onclose(usr, "scanner")
		return

	if(href_list["scan"])
		for(var/obj/item/book/B in contents)
			cache = B
			break
	if(href_list["clear"])
		cache = null
	if(href_list["eject"])
		for(var/obj/item/book/B in contents)
			B.loc = src.loc
	src.add_fingerprint(usr)
	src.updateUsrDialog()
	return


/*
 * Book binder
 */
/obj/machinery/bookbinder
	name = "Book Binder"
	icon = 'icons/obj/library.dmi'
	icon_state = "binder"
	anchored = TRUE
	density = TRUE


/obj/machinery/bookbinder/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(I, /obj/item/paper))
		add_fingerprint(user)
		var/obj/item/paper/paper = I
		if(!user.drop_transfer_item_to_loc(paper, src))
			return ..()
		user.visible_message(
			span_notice("[user] has loaded some paper into [src]. The machine begins to hum as it warms up its printing drums."),
			span_notice("You have loaded some paper into [src]. The machine begins to hum as it warms up its printing drums"),
		)
		atom_say("Imprinting the new book...")
		addtimer(CALLBACK(src, PROC_REF(finalize_printing), paper), rand(20 SECONDS, 40 SECONDS))
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/machinery/bookbinder/proc/finalize_printing(obj/item/paper/paper)
	if(QDELETED(paper) || paper.loc != src)
		return
	var/obj/item/book/new_book = new(loc)
	new_book.dat = paper.info
	new_book.name = "Print Job #[rand(100, 999)]"
	new_book.icon_state = "book[rand(1,16)]"
	atom_say("A new book has been printed.")
	qdel(paper)


/obj/machinery/libraryscanner/wrench_act(mob/living/user, obj/item/I)
	return default_unfasten_wrench(user, I)

