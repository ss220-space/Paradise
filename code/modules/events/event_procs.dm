
/client/proc/forceEvent()
	set name = "Trigger Event"
	set category = "Event"

	if(!check_rights(R_EVENT))
		return
	var/type = tgui_input_list(src, "Выберите событие для запуска", "Выбор события", SSevents.allEvents)
	if(ispath(type))
		new type(new /datum/event_meta(EVENT_LEVEL_MAJOR))
		message_admins("[key_name_admin(usr)] has triggered an event. ([type])")

/client/proc/event_manager_panel()
	set name = "Event Manager Panel"
	set category = "Event"
	if(SSevents)
		SSevents.Interact(usr)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Event Manager") //If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!
	return


/proc/findEventArea() //Here's a nice proc to use to find an area for your event to land in!
	var/static/list/possible_areas
	if(!length(possible_areas))
		var/list/safe_areas = typecacheof(list(
			/area/turret_protected/ai,
			/area/turret_protected/ai_upload,
			/area/engineering,
			/area/holodeck,
			/area/shuttle,
			/area/maintenance,
			/area/toxins/test_area,
			/area/space,
			/area/solar,
			/area/crew_quarters/sleep))

		//These are needed because /area/station/engineering has to be removed from the list, but we still want these areas to get fucked up.
		var/list/allowed_areas = list(
			/area/engineering/break_room,
			/area/engineering/equipmentstorage,
			/area/engineering/chiefs_office,
			/area/engineering/controlroom,
			/area/engineering/mechanic_workshop
		)

		var/list/remove_these_areas = safe_areas - allowed_areas
		possible_areas = typecache_filter_list_reverse(SSmapping.existing_station_areas, remove_these_areas)

	return pick(possible_areas)

// Returns how many characters are currently active(not logged out, not AFK for more than 10 minutes)
// with a specific role.
// Note that this isn't sorted by department, because e.g. having a roboticist shouldn't make meteors spawn.
/proc/number_active_with_role()
	var/list/active_with_role = list()
	active_with_role["Engineer"] = 0
	active_with_role["Medical"] = 0
	active_with_role["Security"] = 0
	active_with_role["Scientist"] = 0
	active_with_role["AI"] = 0
	active_with_role["Cyborg"] = 0
	active_with_role["Janitor"] = 0
	active_with_role["Any"] = GLOB.player_list.len

	for(var/mob/M in GLOB.player_list)
		if(!M.mind || !M.client || M.client.inactivity > 10 * 10 * 60) // longer than 10 minutes AFK counts them as inactive
			continue

		if(istype(M, /mob/living/silicon/robot))
			var/mob/living/silicon/robot/R = M
			if(R.module && (R.module.name == "engineering robot module"))
				active_with_role["Engineer"]++

			if(R.module && (R.module.name == "medical robot module"))
				active_with_role["Medical"]++

			if(R.module && (R.module.name == "security robot module"))
				active_with_role["Security"]++

		if(M.mind.assigned_role in list(JOB_TITLE_CHIEF, JOB_TITLE_ENGINEER, JOB_TITLE_ENGINEER_TRAINEE))
			active_with_role["Engineer"]++

		if(M.mind.assigned_role in list(JOB_TITLE_CMO, JOB_TITLE_DOCTOR, JOB_TITLE_INTERN))
			active_with_role["Medical"]++

		if(M.mind.assigned_role in GLOB.security_positions)
			active_with_role["Security"]++

		if(M.mind.assigned_role in list(JOB_TITLE_RD, JOB_TITLE_SCIENTIST, JOB_TITLE_SCIENTIST_STUDENT))
			active_with_role["Scientist"]++

		if(M.mind.assigned_role == JOB_TITLE_AI)
			active_with_role["AI"]++

		if(M.mind.assigned_role == JOB_TITLE_CYBORG)
			active_with_role["Cyborg"]++

		if(M.mind.assigned_role == JOB_TITLE_JANITOR)
			active_with_role["Janitor"]++

	return active_with_role

/datum/event/proc/num_players()
	var/players = 0
	for(var/mob/living/carbon/human/P in GLOB.player_list)
		if(P.client)
			players++
	return players
