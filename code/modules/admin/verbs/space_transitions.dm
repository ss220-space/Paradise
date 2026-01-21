ADMIN_VERB_VISIBILITY(redo_space_transitions, ADMIN_VERB_VISIBLITY_FLAG_MAPPING_DEBUG)
ADMIN_VERB(redo_space_transitions, R_ADMIN|R_DEBUG, "Remake Space Transitions", "Re-assigns all space transitions.", ADMIN_CATEGORY_DEBUG)
	var/choice = tgui_alert(user, "Do you want to rebuild space transitions?", null, list("Yes", "No"))

	if(choice == "No")
		return

	message_admins("[key_name_admin(user)] re-assigned all space transitions")
	GLOB.space_manager.do_transition_setup()
	log_admin("[key_name(user)] re-assigned all space transitions")

	BLACKBOX_LOG_ADMIN_VERB("Remake Space Transitions")

ADMIN_VERB_VISIBILITY(make_turf_space_map, ADMIN_VERB_VISIBLITY_FLAG_MAPPING_DEBUG)
ADMIN_VERB(make_turf_space_map, R_ADMIN|R_DEBUG, "Make Space Map", "Create a map of the space levels as turfs at your feet.", ADMIN_CATEGORY_DEBUG)
	var/choice = tgui_alert(user, "Are you sure you want to make a space map out of turfs?", null, list("Yes", "No"))

	if(choice == "No")
		return

	message_admins("[key_name_admin(user)] made a space map")

	GLOB.space_manager.map_as_turfs(get_turf(user.mob))
	log_admin("[key_name(user)] made a space map")

	BLACKBOX_LOG_ADMIN_VERB("Make Space Map")
