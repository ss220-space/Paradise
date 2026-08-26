ADMIN_VERB_AND_CONTEXT_MENU(machine_upgrade, R_DEBUG, "Tweak Component Ratings", ADMIN_VERB_NO_DESCRIPTION, ADMIN_CATEGORY_HIDDEN, obj/machinery/machine in world)
	if(!istype(machine))
		to_chat(user, span_danger("This can only be used on subtypes of /obj/machinery."))
		return

	var/new_rating = tgui_input_number(user, "", "Enter new rating:")
	if(new_rating && machine.component_parts)
		for(var/obj/item/stock_parts/part in machine.component_parts)
			part.rating = new_rating
		machine.RefreshParts()

		message_admins("[key_name_admin(user)] has set the component rating of [machine] to [new_rating]")
		log_admin("[key_name(user)] has set the component rating of [machine] to [new_rating]")

	BLACKBOX_LOG_ADMIN_VERB("Machine Upgrade")
