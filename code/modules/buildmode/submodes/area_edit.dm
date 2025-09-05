/datum/buildmode_mode/area_edit
	key = "areaedit"
	var/area/storedarea
	var/image/areaimage

/datum/buildmode_mode/area_edit/New()
	areaimage = image('icons/turf/areas.dmi', null, "yellow")
	..()

/datum/buildmode_mode/area_edit/show_help(mob/builder)
	to_chat(builder, span_purple(chat_box_examine(
		"[span_bold("Select corner")] -> Left Mouse Button on obj/turf/mob\n\
		[span_bold("Paint area")] -> Left Mouse Button + Alt on turf/obj/mob\n\
		[span_bold("Select area to paint")] -> Right Mouse Button on obj/turf/mob\n\
		[span_bold("Create new area")] -> Right Mouse Button on buildmode button"))
	)

/datum/buildmode_mode/area_edit/enter_mode(datum/click_intercept/buildmode/BM)
	BM.holder.images += areaimage

/datum/buildmode_mode/area_edit/exit_mode(datum/click_intercept/buildmode/BM)
	areaimage.loc = null // de-color the area
	BM.holder.images -= areaimage
	return ..()

/datum/buildmode_mode/area_edit/Destroy()
	QDEL_NULL(areaimage)
	storedarea = null
	return ..()

/datum/buildmode_mode/area_edit/change_settings(mob/user)
	var/target_path = tgui_input_text(user, "Enter typepath:", "Typepath", "/area", encode = FALSE)
	var/areatype = text2path(target_path)
	if(ispath(areatype,/area))
		var/areaname = tgui_input_text(user,"Enter area name:", "Area name", "Area", encode = FALSE)
		if(!areaname || !length(areaname))
			return
		storedarea = new areatype
		storedarea.power_equip = 0
		storedarea.power_light = 0
		storedarea.power_environ = 0
		storedarea.always_unpowered = 0
		storedarea.name = areaname
		areaimage.loc = storedarea // color our area

/datum/buildmode_mode/area_edit/handle_click(user, params, object)
	var/list/modifiers = params2list(params)
	if(LAZYACCESS(modifiers, LEFT_CLICK))
		if(!storedarea)
			to_chat(user, span_warning("Configure or select the area you want to paint first!"))
			return
		if(LAZYACCESS(modifiers, ALT_CLICK))
			var/turf/T = get_turf(object)
			if(get_area(T) != storedarea)
				log_admin("Build Mode: [key_name(user)] added [AREACOORD(T)] to [storedarea]")
				storedarea.contents.Add(T)
			return
		return ..()
	else if(LAZYACCESS(modifiers, RIGHT_CLICK))
		var/turf/T = get_turf(object)
		storedarea = get_area(T)
		areaimage.loc = storedarea // color our area

/datum/buildmode_mode/area_edit/handle_selected_area(client/c, params)
	var/list/modifiers = params2list(params)

	if(LAZYACCESS(modifiers, LEFT_CLICK))
		var/choice = alert("Are you sure you want to fill area?", "Area Fill Confirmation", "Yes", "No")
		if(choice != "Yes")
			return
		for(var/turf/T in block(get_turf(cornerA),get_turf(cornerB)))
			storedarea.contents.Add(T)
		log_admin("Build Mode: [key_name(c)] set the area of the region from [AREACOORD(cornerA)] through [AREACOORD(cornerB)] to [storedarea].")
