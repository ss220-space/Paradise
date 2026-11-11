/proc/overmap_pod_user_ok(mob/user, obj/spacepod/craft)
	if(!user || !isspacepod(craft))
		return FALSE
	if(user.incapacitated())
		return FALSE
	return user.loc == craft
