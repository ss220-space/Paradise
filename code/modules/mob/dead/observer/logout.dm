/mob/dead/observer/Logout()
	if(client)
		client.images -= GLOB.ghost_images
	..()
	update_admin_actions()
	spawn(0)
		if(src && !key)	//we've transferred to another mob. This ghost should be deleted.
			qdel(src)
