/datum/buildmode_mode/advanced
	key = "advanced"
	var/atom/objholder = null

/datum/buildmode_mode/advanced/show_help(mob/builder)
	to_chat(builder, span_purple(chat_box_examine(
		"[span_bold("Установите тип объекта")] -> ПКМ по кнопке buildmode\n\
		[span_bold("Копировать тип объекта")] -> Alt на turf/obj + ЛКМ\n\
		[span_bold("Разместить объект")] -> ЛКМ на turf/obj\n\
		[span_bold("Удалить объект")] -> ПКМ\n\
		\n\
		Используйте кнопку в левом верхнем углу, чтобы изменить направление построенных объектов."))
	)

/datum/buildmode_mode/advanced/change_settings(mob/user)
	var/target_path = tgui_input_text(user, "Enter typepath:", "Typepath", "/obj/structure/closet", encode = FALSE)
	objholder = text2path(target_path)
	if(!ispath(objholder))
		objholder = pick_closest_path(target_path)
		if(!objholder)
			tgui_alert(usr, "No path was selected")
			return
		else if(ispath(objholder, /area))
			objholder = null
			tgui_alert(usr, "That path is not allowed.")
			return
	BM.preview_selected_item(objholder)

/datum/buildmode_mode/advanced/handle_click(user, params, obj/object)
	var/list/modifiers = params2list(params)

	var/left_click = LAZYACCESS(modifiers, LEFT_CLICK)
	var/right_click = LAZYACCESS(modifiers, RIGHT_CLICK)
	var/alt_click = LAZYACCESS(modifiers, ALT_CLICK)

	if(left_click && alt_click)
		if (isturf(object) || isobj(object) || ismob(object))
			objholder = object.type
			to_chat(user, span_notice("[initial(object.name)] ([object.type]) selected."))
			BM.preview_selected_item(objholder)
		else
			to_chat(user, span_notice("[initial(object.name)] is not a turf, object, or mob! Please select again."))
	else if(left_click)
		if(ispath(objholder, /turf))
			var/turf/clicked_turf = get_turf(object)
			log_admin("Build Mode: [key_name(user)] modified [clicked_turf] in [AREACOORD(object)] to [objholder]")
			clicked_turf = clicked_turf.ChangeTurf(objholder)
			clicked_turf.setDir(BM.build_dir)
		else if(!isnull(objholder))
			var/obj/clicked_object = new objholder (get_turf(object))
			clicked_object.setDir(BM.build_dir)
			log_admin("Build Mode: [key_name(user)] modified [clicked_object]'s [COORD(clicked_object)] dir to [BM.build_dir]")
		else
			to_chat(user, span_warning("Select object type first."))
	else if(right_click)
		if(isobj(object) || isanimal(object))
			log_admin("Build Mode: [key_name(user)] deleted [object] at [AREACOORD(object)]")
			qdel(object)

