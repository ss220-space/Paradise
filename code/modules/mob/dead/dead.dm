/mob/dead/Login()
	. = ..()
	if(!. || !client)
		return FALSE
	var/turf/T = get_turf(src)
	if(isturf(T))
		update_z(T.z)
	SStitle.hide_title_screen_from(client)


/mob/dead/Logout()
	update_z(null)
	return ..()


/mob/dead/on_changed_z_level(turf/old_turf, turf/new_turf, same_z_layer, notify_contents = TRUE)
	..()
	update_z(new_turf?.z)


/**
 * updates the Z level for dead players
 * If they don't have a new z, we'll keep the old one, preventing bugs from ghosting and re-entering, among others
 */
/mob/dead/proc/update_z(new_z)
	if(registered_z == new_z)
		return
	if(registered_z)
		SSmobs.dead_players_by_zlevel[registered_z] -= src
	if(isnull(client))
		registered_z = null
		return
	registered_z = new_z
	SSmobs.dead_players_by_zlevel[new_z] += src

