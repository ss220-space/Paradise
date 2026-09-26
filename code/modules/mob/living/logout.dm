/mob/living/Logout()
	update_pipe_vision()
	update_z(null)
	if(ranged_ability && client)
		ranged_ability.remove_mousepointer(client)

	if(isobj(loc))
		var/obj/our_location = loc
		if(length(our_location.client_mobs_in_contents))
			our_location.client_mobs_in_contents -= src // if you jackhammer click this as an admeme you can cause runtimes without a length check
	..()
	if(mind)
		if(!key) //key and mind have become seperated. I believe this is for when a staff member aghosts.
			mind.active = FALSE	//This is to stop say, a mind.transfer_to call on a corpse causing a ghost to re-enter its body.
		if(mind.active)
			last_logout = world.time

	set_SSD(TRUE)

