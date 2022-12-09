/atom/proc/instantiate_nametag(client/C)
	maptext_width = 128
	maptext_height = 64
	maptext_y = -12
	maptext_x = -48 // Не спрашивайте, зачем это нужно.
	nametag = TRUE
	maptext = "<center><span style = 'color:white;'>[C.key]</span></center>"

/atom/proc/dismiss_nametag()
	if(!nametag)
		return
	nametag = FALSE
	maptext = null

/mob/verb/toggle_key_view()
	set name = "Toggle Key View"
	set category = "Preferences"
	if(!nametag)
		instantiate_nametag(src)
		to_chat(src, "You will see nametags.")
	else
		dismiss_nametag(src)
		to_chat(src, "You will no longer see nametags.")
