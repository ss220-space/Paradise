GLOBAL_LIST_EMPTY(open_logging_views)

ADMIN_VERB(logging_view, R_ADMIN|R_MOD, "Logging View", "Opens the detailed logging viewer.", ADMIN_CATEGORY_TICKETS, mob/target as null, clear_view as null)
	var/datum/log_viewer/cur_view = GLOB.open_logging_views[user.ckey]
	if(!cur_view)
		cur_view = new /datum/log_viewer()
		GLOB.open_logging_views[user.ckey] = cur_view
	else if(clear_view)
		cur_view.clear_all()

	if(istype(target))
		cur_view.add_mobs(list(target))

	cur_view.show_ui(user.mob)
