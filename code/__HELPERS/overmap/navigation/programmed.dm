/proc/build_overmap_programmed_profiles()
	. = list()
	for(var/path in subtypesof(/datum/overmap_programmed_profile))
		if(path == /datum/overmap_programmed_profile/escape_pod)
			continue
		var/datum/overmap_programmed_profile/profile = new path
		if(!profile.shuttle_id)
			continue
		.[profile.shuttle_id] = profile
	for(var/i in 1 to 4)
		var/datum/overmap_programmed_profile/escape_pod/pod_profile = new
		pod_profile.shuttle_id = "pod[i]"
		pod_profile.add_hidden_leg("pod[i]_away", null)
		.[pod_profile.shuttle_id] = pod_profile

/proc/build_overmap_programmed_shuttle_ids()
	. = list()
	for(var/shuttle_id in GLOB.overmap_programmed_profiles)
		.[shuttle_id] = TRUE

/proc/is_overmap_programmed_dock(dock_id)
	var/static/list/programmed_docks
	if(isnull(programmed_docks))
		programmed_docks = list()
		for(var/shuttle_id, profile_entry in GLOB.overmap_programmed_profiles)
			var/datum/overmap_programmed_profile/profile = profile_entry
			for(var/profile_dock in profile.dock_ids())
				programmed_docks[profile_dock] = TRUE
	return programmed_docks[dock_id]

/proc/is_overmap_programmed_shuttle(obj/docking_port/mobile/shuttle)
	if(!shuttle?.id)
		return FALSE
	if(GLOB.overmap_programmed_shuttle_ids[shuttle.id])
		return TRUE
	return istype(shuttle, /obj/docking_port/mobile/pod)
