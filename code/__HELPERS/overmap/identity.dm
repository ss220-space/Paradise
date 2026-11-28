/proc/build_overmap_shuttle_profiles()
	. = list()
	for(var/path in subtypesof(/datum/overmap_shuttle_profile))
		var/datum/overmap_shuttle_profile/profile = new path
		if(!profile.shuttle_id)
			continue
		.[profile.shuttle_id] = profile
