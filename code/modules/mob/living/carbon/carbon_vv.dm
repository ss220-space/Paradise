/mob/living/carbon/vv_get_dropdown()
	. = ..()
	VV_DROPDOWN_OPTION("", "--- /carbon ---")
	VV_DROPDOWN_OPTION(VV_HK_ADD_ORGAN, "Add Organ")
	VV_DROPDOWN_OPTION(VV_HK_REMOVE_ORGAN, "Remove Organ")
	VV_DROPDOWN_OPTION(VV_HK_MARTIAL_ART, "Give Martial Arts")
	VV_DROPDOWN_OPTION(VV_HK_GIVE_TRAUMA, "Give Brain Trauma")
	VV_DROPDOWN_OPTION(VV_HK_CURE_TRAUMA, "Cure Brain Traumas")

/mob/living/carbon/vv_do_topic(list/href_list)
	. = ..()

	if(!.)
		return

	if(href_list[VV_HK_MARTIAL_ART])
		if(!check_rights(R_SERVER|R_EVENT))
			return

		var/list/artpaths = subtypesof(/datum/martial_art)
		var/list/artnames = list()
		for(var/i in artpaths)
			var/datum/martial_art/M = i
			artnames[initial(M.name)] = M

		var/result = tgui_input_list(usr, "Choose the martial art to teach", "JUDO CHOP", sort_list(artnames, GLOBAL_PROC_REF(cmp_typepaths_asc)))
		if(!usr)
			return
		if(QDELETED(src))
			to_chat(usr, span_notice("Mob doesn't exist anymore."))
			return

		if(result)
			var/chosenart = artnames[result]
			var/datum/martial_art/MA = new chosenart
			MA.teach(src)
			log_admin("[key_name(usr)] has taught [MA] to [key_name(src)].")
			message_admins(span_notice("[key_name_admin(usr)] has taught [MA] to [key_name_admin(src)]."))

	else if(href_list[VV_HK_GIVE_TRAUMA])
		if(!check_rights(R_SERVER|R_EVENT))
			return

		var/list/trauma_types = list()
		for(var/datum/brain_trauma/trauma as anything in subtypesof(/datum/brain_trauma))
			if(trauma::abstract_type == trauma)
				continue
			trauma_types += trauma

		var/chosen_trauma = tgui_input_list(usr, "Choose the brain trauma to apply", "Traumatize", sort_list(trauma_types, GLOBAL_PROC_REF(cmp_typepaths_asc)))
		if(!chosen_trauma)
			return

		if(QDELETED(src))
			to_chat(usr, span_notice("Mob doesn't exist anymore."))
			return

		var/datum/brain_trauma/applied_trauma = gain_trauma(chosen_trauma)
		if(!applied_trauma)
			to_chat(usr, span_notice("Mob cannot gain that trauma."))
			return

		log_admin("[key_name(usr)] has traumatized [key_name(src)] with [applied_trauma.name].")
		message_admins(span_notice("[key_name_admin(usr)] has traumatized [key_name_admin(src)] with [applied_trauma.name]."))

	else if(href_list[VV_HK_CURE_TRAUMA])
		if(!check_rights(R_SERVER|R_EVENT))
			return

		cure_all_traumas(TRAUMA_RESILIENCE_ABSOLUTE)
		log_admin("[key_name(usr)] has cured all brain traumas of [key_name(src)].")
		message_admins(span_notice("[key_name_admin(usr)] has cured all brain traumas of [key_name_admin(src)]."))

	else if(href_list[VV_HK_ADD_ORGAN])
		if(!check_rights(R_SPAWN))
			return

		var/new_organ = tgui_input_list(usr, "Please choose an organ to add.", "Organ", subtypesof(/obj/item/organ))
		if(!new_organ)
			return

		if(QDELETED(src))
			to_chat(usr, span_notice("Mob doesn't exist anymore."))
			return

		if(locateUID(new_organ) in internal_organs)
			to_chat(usr, span_notice("Mob already has that organ."))
			return
		var/obj/item/organ/internal/organ = new new_organ
		organ.insert(src)
		message_admins("[key_name_admin(usr)] has given [key_name_admin(src)] the organ [new_organ]")
		log_admin("[key_name(usr)] has given [key_name(src)] the organ [new_organ]")

	else if(href_list[VV_HK_REMOVE_ORGAN])
		if(!check_rights(R_SPAWN))
			return

		var/obj/item/organ/internal/rem_organ = tgui_input_list(usr, "Please choose an organ to remove.", "Organ", internal_organs)

		if(QDELETED(src))
			to_chat(usr, span_notice("Mob doesn't exist anymore."))
			return

		if(!(rem_organ in internal_organs))
			to_chat(usr, span_notice("Mob does not have that organ."))
			return

		to_chat(usr, span_notice("Removed [rem_organ] from [src]."))
		rem_organ.remove(src)
		message_admins("[key_name_admin(usr)] has removed the organ [rem_organ] from [key_name_admin(src)]")
		log_admin("[key_name(usr)] has removed the organ [rem_organ] from [key_name(src)]")
		qdel(rem_organ)
