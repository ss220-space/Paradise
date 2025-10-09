/datum/buildmode_mode/save
	key = "save"

	use_corner_selection = TRUE
	var/use_json = TRUE

/datum/buildmode_mode/save/show_help(mob/user)
	to_chat(user, span_purple(chat_box_examine(
		"[span_bold("Select corner")] -> Left Mouse Button on turf/obj/mob"))
	)

/datum/buildmode_mode/save/change_settings(mob/user)
	use_json = (tgui_alert(usr, "Would you like to use json (Default is \"Yes\")?", null, list("Yes", "No")) == "Yes")

/datum/buildmode_mode/save/handle_selected_area(mob/user, params)
	var/list/modifiers = params2list(params)

	if(LAZYACCESS(modifiers, LEFT_CLICK))
		var/map_name = tgui_input_text(user, "Please select a name for your map", "Buildmode", "", encode = FALSE)
		if(map_name == "")
			return
		var/map_flags = 0
		if(use_json)
			map_flags = 32 // Magic number defined in `writer.dm` that I can't use directly
			// because #defines are for some reason our coding standard
		var/our_map = GLOB.maploader.save_map(cornerA, cornerB, map_name, map_flags)
		user << ftp(our_map) // send the map they've made! Or are stealing, whatever
		to_chat(user, "Map saving complete! [our_map]")
