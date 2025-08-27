/datum/buildmode_mode/mapgen
	key = "mapgen"

	use_corner_selection = TRUE
	var/generator_path

/datum/buildmode_mode/mapgen/show_help(mob/user)
	to_chat(user, span_purple(chat_box_examine(
		"[span_bold("Select corner")] -> Left Mouse Button on turf/obj/mob\n\
		[span_bold("Select generator")] -> Right Mouse Button on buildmode button"))
	)

/datum/buildmode_mode/mapgen/change_settings(mob/user)
	var/list/gen_paths = subtypesof(/datum/mapGenerator)

	var/type = tgui_input_list(user, "Select Generator Type", "Type", gen_paths)
	if(!type)
		return

	generator_path = type
	deselect_region()

/datum/buildmode_mode/mapgen/handle_click(mob/user, params, obj/object)
	if(isnull(generator_path))
		to_chat(user, span_warning("Select generator type first."))
		deselect_region()
		return
	..()

/datum/buildmode_mode/mapgen/handle_selected_area(mob/user, params)
	var/list/modifiers = params2list(params)

	if(LAZYACCESS(modifiers, LEFT_CLICK))
		if(cornerA && cornerB)
			var/datum/mapGenerator/G = new generator_path
			G.defineRegion(cornerA, cornerB, 1)
			highlight_region(G.map)
			var/confirm = tgui_alert(user, "Are you sure you want run the map generator?", "Run generator", list("Yes", "No"))
			if(confirm == "Yes")
				G.generate()
			log_admin("Build Mode: [key_name(user)] ran the map generator in the region from [AREACOORD(cornerA)] to [AREACOORD(cornerB)]")
