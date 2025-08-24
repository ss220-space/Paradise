/datum/buildmode_mode/copy
	key = "copy"
	var/atom/movable/stored = null

/datum/buildmode_mode/copy/exit_mode()
	stored = null
	return ..()

/datum/buildmode_mode/copy/show_help(mob/builder)
	to_chat(builder, span_purple(chat_box_examine(
		"[span_bold("Spawn a copy of selected target")] -> Left Mouse Button on obj/turf/mob\n\
		[span_bold("Select target to copy")] -> Right Mouse Button on obj/mob"))
	)

/datum/buildmode_mode/copy/handle_click(user, params, obj/object)
	var/list/modifiers = params2list(params)

	if(LAZYACCESS(modifiers, LEFT_CLICK))
		var/turf/turf = get_turf(object)
		if(stored)
			DuplicateObject(stored, perfectcopy=1, sameloc=0,newloc=turf)
			log_admin("Build Mode: [key_name(user)] copied [stored] to [AREACOORD(object)]")
	else if(LAZYACCESS(modifiers, RIGHT_CLICK))
		if(ismovable(object)) // No copying turfs for now.
			to_chat(user, span_notice("[object] set as template."))
			stored = object
