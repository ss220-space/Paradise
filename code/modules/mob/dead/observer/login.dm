/mob/dead/observer/Login()
	..()
	if(ghostimage)
		ghostimage.icon_state = src.icon_state
	updateghostimages()
	if(!get_preference(PREFTOGGLE_CHAT_GHOSTRADIO))
		GLOB.permanent_radio_listeners |= src
	if(GLOB.non_respawnable_keys[ckey])
		can_reenter_corpse = 0
		GLOB.respawnable_list -= src
	update_admin_actions()
