ADMIN_VERB(restart_controller, R_DEBUG, "Restart Controller", "Restart one of the various periodic loop controllers for the game (be careful!)", ADMIN_CATEGORY_DEBUG, controller in list("Master", "Failsafe"))
	switch(controller)
		if("Master")
			Recreate_MC()
			BLACKBOX_LOG_ADMIN_VERB("Restart MC")
		if("Failsafe")
			new /datum/controller/failsafe()
			BLACKBOX_LOG_ADMIN_VERB("Restart Failsafe")

	message_admins("Admin [key_name_admin(user)] has restarted the [controller] controller.")

ADMIN_VERB(debug_misc_controller, R_DEBUG, "Debug Controller", "Debug the various periodic loop controllers for the game (be careful!)", ADMIN_CATEGORY_DEBUG, controller in list("Configuration", "pAI", "Cameras", "Space Manager"))
	switch(controller)
		if("Configuration")
			SSadmin_verbs.dynamic_invoke_verb(user, /datum/admin_verb/debug_variables, config)
			BLACKBOX_LOG_ADMIN_VERB("Debug Config")
		if("pAI")
			SSadmin_verbs.dynamic_invoke_verb(user, /datum/admin_verb/debug_variables, GLOB.paiController)
			BLACKBOX_LOG_ADMIN_VERB("Debug pAI")
		if("Cameras")
			SSadmin_verbs.dynamic_invoke_verb(user, /datum/admin_verb/debug_variables, GLOB.cameranet)
			BLACKBOX_LOG_ADMIN_VERB("Debug Cameras")
		if("Space Manager")
			SSadmin_verbs.dynamic_invoke_verb(user, /datum/admin_verb/debug_variables, GLOB.space_manager)
			BLACKBOX_LOG_ADMIN_VERB("Debug Space")

	message_admins("Admin [key_name_admin(user)] is debugging the [controller] controller.")

ADMIN_VERB(toggle_npcpool_suspension, R_DEBUG, "Toggle NPCpool suspension", "Toggles NPCpool suspension, when there are no alive players in sector, NPC's are not processed.", ADMIN_CATEGORY_TOGGLES)
	GLOB.npcpool_suspension = !GLOB.npcpool_suspension
	message_admins("Admin [key_name_admin(user)] toggled NPCpool suspension.")
	BLACKBOX_LOG_ADMIN_VERB("Toggle NPCpool suspension")

ADMIN_VERB(toggle_idlenpcpool_suspension, R_DEBUG, "Toggle IdleNPCpool suspension", "Toggles IdleNPCpool suspension, when there are no alive players in sector, Idle NPC's are not processed.", ADMIN_CATEGORY_TOGGLES)
	GLOB.idlenpc_suspension = !GLOB.idlenpc_suspension
	message_admins("Admin [key_name_admin(user)] toggled IdleNPCpool suspension.")
	BLACKBOX_LOG_ADMIN_VERB("Toggle IdleNPCpool suspension")

ADMIN_VERB(toggle_mobs_suspension, R_DEBUG, "Toggle Mobs suspension", "Toggles Mobs suspension, when there are no alive players in sector, mobs are not processed.", ADMIN_CATEGORY_TOGGLES)
	GLOB.mob_suspension = !GLOB.mob_suspension
	message_admins("Admin [key_name_admin(user)] toggled mobs suspension.")
	BLACKBOX_LOG_ADMIN_VERB("Toggle Mobs suspension")
