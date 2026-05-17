/atom/movable/vv_get_dropdown()
	. = ..()
	VV_DROPDOWN_OPTION("", "--- /movable ---")
	VV_DROPDOWN_OPTION(VV_HK_OBSERVE_FOLLOW, "Observe Follow")
	VV_DROPDOWN_OPTION(VV_HK_GET_MOVABLE, "Get Movable")
	VV_DROPDOWN_OPTION(VV_HK_EDIT_PARTICLES, "Edit Particles")
	VV_DROPDOWN_OPTION(VV_HK_DEADCHAT_PLAYS, "Start/Stop Deadchat Plays")

/atom/movable/vv_do_topic(list/href_list)
	. = ..()

	if(!.)
		return

	if(href_list[VV_HK_OBSERVE_FOLLOW])
		if(!check_rights(R_ADMIN))
			return
		usr.client?.admin_follow(src)

	if(href_list[VV_HK_GET_MOVABLE])
		if(!check_rights(R_ADMIN))
			return
		if(QDELETED(src))
			return
		forceMove(get_turf(usr))

	if(href_list[VV_HK_EDIT_PARTICLES])
		if(!check_rights(R_VAREDIT))
			return
		usr.client?.open_particle_editor(src)

	if(href_list[VV_HK_DEADCHAT_PLAYS])
		if(!check_rights(R_EVENT))
			return
		if(tgui_alert(usr, "Allow deadchat to control [src] via chat commands?", "Deadchat Plays [src]", list("Allow", "Cancel")) != "Allow")
			return
		// Alert is async, so quick sanity check to make sure we should still be doing this.
		if(QDELETED(src))
			return
		// This should never happen, but if it does it should not be silent.
		if(deadchat_plays() == COMPONENT_INCOMPATIBLE)
			to_chat(usr, span_warning("Deadchat control not compatible with [src]."))
			CRASH("deadchat_control component incompatible with object of type: [type]")
		to_chat(usr, span_notice("Deadchat now control [src]."))
		log_admin("[key_name(usr)] has added deadchat control to [src]")
		message_admins(span_adminnotice("[key_name(usr)] has added deadchat control to [src]"))
