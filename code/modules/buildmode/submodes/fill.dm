/datum/buildmode_mode/fill
	key = "fill"

	use_corner_selection = TRUE
	var/objholder = null

/datum/buildmode_mode/fill/show_help(mob/user)
	to_chat(user, span_notice("***********************************************************"))
	to_chat(user, span_notice("ЛКМ на turf/obj/mob      = Выбрать угол"))
	to_chat(user, span_notice("ЛКМ + Alt после выбора региона = Удалить регион"))
	to_chat(user, span_notice("ПКМ по кнопке билдмода = Выбрать тип"))
	to_chat(user, span_notice("ЛКМ + Alt на turf/obj/mob = Копировать тип объекта"))
	to_chat(user, span_notice("***********************************************************"))

/datum/buildmode_mode/fill/change_settings(mob/user)
	var/target_path = tgui_input_text(user,"Введите путь типа:" ,"Путь типа", "/obj/structure/closet")
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
	deselect_region()

/datum/buildmode_mode/fill/handle_click(mob/user, params, obj/object)
	var/list/pa = params2list(params)
	var/alt_click = pa.Find("alt")
	var/left_click = pa.Find("left")
	var/region_check = cornerA && cornerB
	if(left_click && alt_click && !region_check)
		if(isturf(object) || isobj(object) || ismob(object))
			objholder = object.type
			to_chat(user, span_notice("[capitalize(object.declent_ru(NOMINATIVE))] ([object.type]) выбран[genderize_ru(object.gender, "", "a", "о", "ы")]."))
			return
		else
			to_chat(user, span_notice("[capitalize(object.declent_ru(NOMINATIVE))] не турф, объект, или существо! Пожалуйста, выберите еще раз."))
	. = ..()

/datum/buildmode_mode/fill/handle_selected_region(mob/user, params)
	var/list/pa = params2list(params)
	var/left_click = pa.Find("left")
	var/alt_click = pa.Find("alt")

	if(left_click) //rectangular
		if(alt_click)
			empty_region(block(cornerA,cornerB))
		else
			if(isnull(objholder))
				to_chat(user, span_warning("Сначала выберите тип объекта."))
				deselect_region()
				return
			for(var/turf/T in block(cornerA,cornerB))
				if(ispath(objholder,/turf))
					T.ChangeTurf(objholder)
				else
					var/obj/A = new objholder(T)
					A.setDir(BM.build_dir)
