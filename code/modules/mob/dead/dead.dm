/mob/dead/Login()
	. = ..()
	var/turf/T = get_turf(src)
	if (isturf(T))
		update_z(T.z)

/mob/dead/Logout()
	update_z(null)
	return ..()

/mob/dead/on_changed_z_level(turf/old_turf, turf/new_turf, same_z_layer, notify_contents = TRUE)
	..()
	update_z(new_turf?.z)

/mob/dead/proc/update_z(new_z) // 1+ to register, null to unregister
	if (registered_z != new_z)
		if (registered_z)
			SSmobs.dead_players_by_zlevel[registered_z] -= src
		if (client)
			if (new_z)
				SSmobs.dead_players_by_zlevel[new_z] += src
			registered_z = new_z
		else
			registered_z = null
