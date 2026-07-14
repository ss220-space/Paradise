/// how much paper it takes from the printer to create a canvas.
#define CANVAS_PAPER_COST 10
/**
 * ## the art gallery viewer/printer!
 *
 * Program that lets the curator (or anyone really) browse all of the portraits in the database
 * Stationary consoles can also print them out as they please as long as they've enough paper
 */
/obj/machinery/computer/portrait_printer
	name = "Portrait Printer"
	desc = "Marlowe Treeby's Art Galaxy. This console connects to a Spinward Sector community art site for viewing and printing art, the latter only available on stationary consoles"
	use_power = ACTIVE_POWER_USE
	idle_power_usage = 20
	active_power_usage = 80
	light_color = LIGHT_COLOR_DIM_YELLOW
	circuit = /obj/item/circuitboard/portrait_printer
	/**
	* The last input in the search tab, stored here and reused in the UI to show successive users if
	* the current list of paintings is limited to the results of a search or not.
	*/
	/// The amount of paper currently stored in the cosole
	var/stored_paper = 10
	///The max amount of paper that can be held at once.
	var/max_paper = 30
	var/search_string
	/// Whether the search function will check the title of the painting or the author's name.
	var/search_mode = PAINTINGS_FILTER_SEARCH_TITLE
	/// Stores the result of the search, for later access.
	var/list/matching_paintings

/obj/machinery/computer/portrait_printer/attack_hand(mob/user)
	. = ..()
	if(!.)
		return
	ui_interact(user)

/obj/machinery/computer/portrait_printer/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "NtosPortraitPrinter")
		ui.open()

/obj/machinery/computer/portrait_printer/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	. = ..()
	if(istype(tool, /obj/item/paper))
		return paper_act(user, tool)

/obj/machinery/computer/portrait_printer/proc/paper_act(mob/user, obj/item/paper/new_paper)
	if(stored_paper >= max_paper)
		balloon_alert(user, "no more room!")
		return ITEM_INTERACT_BLOCKING
	if(!user.temporarily_remove_item_from_inventory(new_paper))
		return ITEM_INTERACT_BLOCKING
	balloon_alert(user, "inserted paper")
	qdel(new_paper)
	playsound(src, 'sound/machines/computer/paper_insert.ogg', 40, vary = TRUE)
	stored_paper++
	return ITEM_INTERACT_SUCCESS

/obj/machinery/computer/portrait_printer/examine(mob/user)
	. = ..()
	if(IsReachableBy(user))
		. += span_notice("Paper level: [stored_paper] / [max_paper].")

/obj/machinery/computer/portrait_printer/ui_static_data(mob/user)
	. = ..()
	.["is_console"] = TRUE

/obj/machinery/computer/portrait_printer/ui_data(mob/user)
	var/list/data = list()
	data["paintings"] = matching_paintings || SSpersistent_paintings.painting_ui_data()
	data["search_string"] = search_string
	data["search_mode"] = search_mode == PAINTINGS_FILTER_SEARCH_TITLE ? "Title" : "Author"
	return data

/obj/machinery/computer/portrait_printer/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/simple/portraits)
	)


/obj/machinery/computer/portrait_printer/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	switch(action)
		if("search")
			if(search_string != params["to_search"])
				search_string = params["to_search"]
				generate_matching_paintings_list()
			. = TRUE
		if("change_search_mode")
			search_mode = search_mode == PAINTINGS_FILTER_SEARCH_TITLE ? PAINTINGS_FILTER_SEARCH_CREATOR : PAINTINGS_FILTER_SEARCH_TITLE
			generate_matching_paintings_list()
			. = TRUE
		if("print")
			print_painting(params["selected"])
		/*
		if("download")
			download_painting(params["selected"])
		*/

/obj/machinery/computer/portrait_printer/proc/generate_matching_paintings_list()
	matching_paintings = null
	if(!search_string)
		return
	matching_paintings = SSpersistent_paintings.painting_ui_data(filter = search_mode, search_text = search_string)

/obj/machinery/computer/portrait_printer/proc/print_painting(selected_painting)
	if(stored_paper < CANVAS_PAPER_COST)
		to_chat(usr, span_notice("Printing error: Your printer needs at least [CANVAS_PAPER_COST] paper to print a canvas."))
		return

	//canvas printing!
	var/datum/painting/chosen_portrait = locateUID(selected_painting)

	var/obj/item/canvas/new_canvas = chosen_portrait.spawn_canvas(get_turf(src))
	if(!new_canvas)
		to_chat(usr, span_notice("Printing error: An unknown error has occurred."))
		return

	stored_paper -= CANVAS_PAPER_COST
	to_chat(usr, span_notice("You have printed [chosen_portrait.title] onto a new canvas."))
	playsound(src, 'sound/machines/printer.ogg', 100, TRUE)

/*
/obj/machinery/computer/portrait_printer/proc/download_painting(selected_painting)
	var/datum/painting/chosen_portrait = locate(selected_painting) in SSpersistent_paintings.paintings
	var/icon/portrait_icon = chosen_portrait.get_icon()
	var/datum/computer_file/image/image_file = new(portrait_icon, display_name = chosen_portrait.title, source_photo_or_painting = chosen_portrait)
	if(!computer.store_file(image_file, usr))
		to_chat(usr, span_notice("Unable to download [chosen_portrait.title].[/datum/computer_file/image::filetype]."))
		return
	to_chat(usr, span_notice("Downloaded [chosen_portrait.title].[/datum/computer_file/image::filetype]."))
*/
#undef CANVAS_PAPER_COST
