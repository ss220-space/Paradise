/datum/buildmode_mode/basic
	key = "basic"

/datum/buildmode_mode/basic/show_help(mob/builder)
	to_chat(builder, span_purple(chat_box_examine(
		"[span_bold("Строительство / Улучшение")] -> ЛКМ\n\
		[span_bold("Разобрать / Удалить / Ухудшение")] -> ПКМ\n\
		[span_bold("Укреплённое окно")] -> ЛКМ + Ctrl\n\
		[span_bold("Шлюз")] -> ЛКМ + Alt \n\
		\n\
		Используйте кнопку в левом верхнем углу, чтобы изменить направление построенных объектов."))
	)

/datum/buildmode_mode/basic/handle_click(user, params, obj/object)
	var/list/modifiers = params2list(params)

	var/left_click = LAZYACCESS(modifiers, LEFT_CLICK)
	var/right_click = LAZYACCESS(modifiers, RIGHT_CLICK)
	var/alt_click = LAZYACCESS(modifiers, ALT_CLICK)
	var/ctrl_click = LAZYACCESS(modifiers, CTRL_CLICK)

	if(istype(object, /turf) && left_click && !alt_click && !ctrl_click)
		var/turf/clicked_turf = object
		if(isspaceturf(object) || istype(object, /turf/simulated/openspace))
			clicked_turf.ChangeTurf(/turf/simulated/floor/plasteel)
		else if(isfloorturf(object))
			clicked_turf.ChangeTurf(/turf/simulated/wall)
		else if(iswallturf(object))
			clicked_turf.ChangeTurf(/turf/simulated/wall/r_wall)
		log_admin("Build Mode: [key_name(user)] built [clicked_turf] at [AREACOORD(clicked_turf)]")
	else if(right_click)
		log_admin("Build Mode: [key_name(user)] deleted [object] at [AREACOORD(object)]")
		if(iswallturf(object))
			var/turf/clicked_turf = object
			clicked_turf.ChangeTurf(/turf/simulated/floor/plasteel)
		else if(isfloorturf(object))
			var/turf/clicked_turf = object
			clicked_turf.ChangeTurf(clicked_turf.baseturf)
		else if(isreinforcedwallturf(object))
			var/turf/clicked_turf = object
			clicked_turf.ChangeTurf(/turf/simulated/wall)
		else if(isobj(object))
			qdel(object)
	else if(istype(object, /turf) && alt_click && left_click)
		log_admin("Build Mode: [key_name(user)] built an airlock at [AREACOORD(object)]")
		new/obj/machinery/door/airlock(get_turf(object))
	else if(istype(object, /turf) && ctrl_click && left_click)
		var/obj/structure/window/reinforced/window
		if(BM.build_dir in GLOB.diagonals)
			window = new /obj/structure/window/full/reinforced(get_turf(object))
		else
			window = new /obj/structure/window/reinforced(get_turf(object))
			window.setDir(BM.build_dir)
		log_admin("Build Mode: [key_name(user)] built a window at [AREACOORD(object)]")
