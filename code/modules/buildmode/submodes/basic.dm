/datum/buildmode_mode/basic
	key = "basic"

/datum/buildmode_mode/basic/show_help(mob/builder)
	to_chat(builder, span_purple(chat_box_examine(
		"[span_bold("Construct / Upgrade")] -> Left Mouse Button\n\
		[span_bold("Deconstruct / Delete / Downgrade")] -> Right Mouse Button\n\
		[span_bold("R-Window")] -> Left Mouse Button + Ctrl\n\
		[span_bold("Airlock")] -> Left Mouse Button + Alt \n\
		\n\
		Use the button in the upper left corner to change the direction of built objects."))
	)

/datum/buildmode_mode/basic/handle_click(user, params, obj/object)
	var/list/modifiers = params2list(params)

	var/left_click = LAZYACCESS(modifiers, LEFT_CLICK)
	var/right_click = LAZYACCESS(modifiers, RIGHT_CLICK)
	var/alt_click = LAZYACCESS(modifiers, ALT_CLICK)
	var/ctrl_click = LAZYACCESS(modifiers, CTRL_CLICK)

	if(istype(object,/turf) && left_click && !alt_click && !ctrl_click)
		var/turf/T = object
		if(isspaceturf(object) || istype(object,/turf/simulated/openspace))
			T.ChangeTurf(/turf/simulated/floor/plasteel)
		else if(isfloorturf(object))
			T.ChangeTurf(/turf/simulated/wall)
		else if(iswallturf(object))
			T.ChangeTurf(/turf/simulated/wall/r_wall)
		log_admin("Build Mode: [key_name(user)] built [T] at [AREACOORD(T)]")
	else if(right_click)
		log_admin("Build Mode: [key_name(user)] deleted [object] at [AREACOORD(object)]")
		if(iswallturf(object))
			var/turf/T = object
			T.ChangeTurf(/turf/simulated/floor/plasteel)
		else if(isfloorturf(object))
			var/turf/T = object
			T.ChangeTurf(T.baseturf)
		else if(isreinforcedwallturf(object))
			var/turf/T = object
			T.ChangeTurf(/turf/simulated/wall)
		else if(isobj(object))
			qdel(object)
	else if(istype(object,/turf) && alt_click && left_click)
		log_admin("Build Mode: [key_name(user)] built an airlock at [AREACOORD(object)]")
		new/obj/machinery/door/airlock(get_turf(object))
	else if(istype(object,/turf) && ctrl_click && left_click)
		var/obj/structure/window/reinforced/WIN = new/obj/structure/window/reinforced(get_turf(object))
		WIN.setDir(BM.build_dir)
		log_admin("Build Mode: [key_name(user)] built a window at [AREACOORD(object)]")
