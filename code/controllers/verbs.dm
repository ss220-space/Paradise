ADMIN_VERB(restart_controller, R_DEBUG, "Restart Controller", "Restart one of the various periodic loop controllers for the game (be careful!)", ADMIN_CATEGORY_DEBUG, controller in list("Master", "Failsafe"))
	switch(controller)
		if("Master")
			Recreate_MC()
			BLACKBOX_LOG_ADMIN_VERB("Restart MC")
		if("Failsafe")
			new /datum/controller/failsafe()
			BLACKBOX_LOG_ADMIN_VERB("Restart Failsafe")

	message_admins("Admin [key_name_admin(user)] has restarted the [controller] controller.")

ADMIN_VERB(debug_controller, R_DEBUG, "Debug Controller", "Debug the various periodic loop controllers for the game (be careful!)", ADMIN_CATEGORY_DEBUG)
	var/list/controllers = list()
	var/list/controller_choices = list()

	for(var/var_key in global.vars)
		var/datum/controller/controller = global.vars[var_key]
		if(!istype(controller) || istype(controller, /datum/controller/subsystem))
			continue

		controllers[controller.name] = controller //we use an associated list to ensure clients can't hold references to controllers
		controller_choices += controller.name

	var/datum/controller/controller_string = tgui_input_list(user, "Select controller to debug", "Debug Controller", controller_choices)
	var/datum/controller/controller = controllers[controller_string]

	if(!istype(controller))
		return

	user.debug_variables(controller)

	BLACKBOX_LOG_ADMIN_VERB("Debug Controller")
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
