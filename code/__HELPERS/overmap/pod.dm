/proc/overmap_pod_user_ok(mob/user, obj/spacepod/craft)
	if(!user || !isspacepod(craft))
		return FALSE
	if(IS_DEAD_OR_INCAP(user))
		return FALSE
	return user.loc == craft
