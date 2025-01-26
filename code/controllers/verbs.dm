//TODO: rewrite and standardise all controller datums to the datum/controller type
//TODO: allow all controllers to be deleted for clean restarts (see WIP master controller stuff) - MC done - lighting done


/client/proc/restart_controller(controller in list("Master", "Failsafe"))
	set category = "Debug"
	set name = "Restart Controller"
	set desc = "Restart one of the various periodic loop controllers for the game (be careful!)"

	if(!check_rights(R_DEBUG))
		return
	switch(controller)
		if("Master")
			Recreate_MC()
			SSblackbox.record_feedback("tally", "admin_verb", 1, "Restart MC")
		if("Failsafe")
			new /datum/controller/failsafe()
			SSblackbox.record_feedback("tally", "admin_verb", 1, "Restart Failsafe")

	message_admins("Admin [key_name_admin(usr)] has restarted the [controller] controller.")

/client/proc/debug_controller(controller in list("Configuration", "pAI", "Cameras", "Space Manager"))
	set category = "Debug"
	set name = "Debug Misc Controller"
	set desc = "Debug the various non-subsystem controllers for the game (be careful!)"

	if(!check_rights(R_DEBUG))
		return
	switch(controller)
		if("Configuration")
			debug_variables(config)
			SSblackbox.record_feedback("tally", "admin_verb", 1, "Debug Config")
		if("pAI")
			debug_variables(GLOB.paiController)
			SSblackbox.record_feedback("tally", "admin_verb", 1, "Debug pAI")
		if("Cameras")
			debug_variables(GLOB.cameranet)
			SSblackbox.record_feedback("tally", "admin_verb", 1, "Debug Cameras")
		if("Space Manager")
			debug_variables(GLOB.space_manager)
			SSblackbox.record_feedback("tally", "admin_verb", 1, "Debug Space")

	message_admins("Admin [key_name_admin(usr)] is debugging the [controller] controller.")

/client/proc/toggle_npcpool_suspension()
	set category = "Debug"
	set name = "Toggle NPCpool suspension"
	set desc = "Toggles NPCpool suspension, when there are no alive players in sector, NPC's are not processed."
	if(!check_rights(R_DEBUG))
		return

	GLOB.npcpool_suspension = !GLOB.npcpool_suspension
	message_admins("Admin [key_name_admin(usr)] toggled NPCpool suspension.")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Toggle NPCpool suspension")

/client/proc/toggle_Idlenpcpool_suspension()
	set category = "Debug"
	set name = "Toggle IdleNPCpool suspension"
	set desc = "Toggles IdleNPCpool suspension, when there are no alive players in sector, Idle NPC's are not processed."
	if(!check_rights(R_DEBUG))
		return

	GLOB.idlenpc_suspension = !GLOB.idlenpc_suspension
	message_admins("Admin [key_name_admin(usr)] toggled IdleNPCpool suspension.")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Toggle IdleNPCpool suspension")

/client/proc/toggle_mobs_suspension()
	set category = "Debug"
	set name = "Toggle Mobs suspension"
	set desc = "Toggles Mobs suspension, when there are no alive players in sector, mobs are not processed."
	if(!check_rights(R_DEBUG))
		return

	GLOB.mob_suspension = !GLOB.mob_suspension
	message_admins("Admin [key_name_admin(usr)] toggled mobs suspension.")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Toggle Mobs suspension")
