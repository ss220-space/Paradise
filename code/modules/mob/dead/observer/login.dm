/mob/dead/observer/Login()
	..()
	if(ghostimage)
		ghostimage.icon_state = src.icon_state
	updateghostimages()
	if(!get_preference(PREFTOGGLE_CHAT_GHOSTRADIO))
		GLOB.permanent_radio_listeners |= src
	if(GLOB.non_respawnable_keys[ckey])
		can_reenter_corpse = FALSE
		remove_from_respawnable_list()
	update_admin_actions()
	client?.set_right_click_menu_mode(FALSE)
