/datum/buildmode_mode/fill
	key = "fill"

	use_corner_selection = TRUE
	var/atom/objholder = null

/datum/buildmode_mode/fill/show_help(mob/user)
	to_chat(user, span_purple(chat_box_examine(
		"[span_bold("Select corner")] -> Left Mouse Button on turf/obj/mob\n\
		[span_bold("Delete region")] -> Left Mouse Button + Alt on turf/obj/mob\n\
		[span_bold("Select object type")] -> Right Mouse Button on buildmode button"))
	)

/datum/buildmode_mode/fill/change_settings(mob/user)
	var/target_path = tgui_input_text(user,"Введите путь типа:", "Путь типа", "/obj/structure/closet")
	objholder = text2path(target_path)
	if(!ispath(objholder))
		objholder = pick_closest_path(target_path)
		if(!objholder)
			tgui_alert(user, "Путь не выбран.")
			return
		else if(ispath(objholder, /area))
			objholder = null
			tgui_alert(user, "В этом режиме не поддерживаются пути к областям, вместо этого используйте режим редактирования областей.")
			return
	BM.preview_selected_item(objholder)
	deselect_region()

/datum/buildmode_mode/fill/handle_click(mob/user, params, obj/object)
	var/list/modifiers = params2list(params)

	var/left_click = LAZYACCESS(modifiers, LEFT_CLICK)
	var/alt_click = LAZYACCESS(modifiers, ALT_CLICK)

	var/region_check = cornerA && cornerB
	if(left_click && alt_click && !region_check)
		if(isturf(object) || isobj(object) || ismob(object))
			objholder = object.type
			to_chat(user, span_notice("[capitalize(object.declent_ru(NOMINATIVE))] ([object.type]) выбран[genderize_ru(object.gender, "", "a", "о", "ы")]."))
			return
		else
			to_chat(user, span_notice("[capitalize(object.declent_ru(NOMINATIVE))] не турф, объект, или существо! Пожалуйста, выберите еще раз."))
	. = ..()

/datum/buildmode_mode/fill/handle_selected_area(mob/user, params)
	var/list/modifiers = params2list(params)

	if(LAZYACCESS(modifiers, LEFT_CLICK)) //rectangular
		if(LAZYACCESS(modifiers, ALT_CLICK))
			empty_region(block(cornerA,cornerB))
		else
			if(isnull(objholder))
				to_chat(user, span_warning("Сначала выберите тип объекта."))
				deselect_region()
				return
			for(var/turf/T in block(cornerA,cornerB))
				if(ispath(objholder,/turf))
					T = T.ChangeTurf(objholder)
					T.setDir(BM.build_dir)
				else
					var/obj/A = new objholder(T)
					A.setDir(BM.build_dir)
			log_admin("Build Mode: [key_name(user)] with path [objholder], filled the region from [AREACOORD(cornerA)] through [AREACOORD(cornerB)]")
