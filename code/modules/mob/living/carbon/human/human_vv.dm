/mob/living/carbon/human/vv_get_dropdown()
	. = ..()
	VV_DROPDOWN_OPTION("", "--- /human ---")
	VV_DROPDOWN_OPTION(VV_HK_SET_SPECIES, "Set Species")
	VV_DROPDOWN_OPTION(VV_HK_COPY_OUTFIT, "Copy Outfit")
	VV_DROPDOWN_OPTION(VV_HK_MAKE_SKELETON, "Make Skeleton")

/mob/living/carbon/human/vv_do_topic(list/href_list)
	. = ..()

	if(!.)
		return

	if(href_list[VV_HK_COPY_OUTFIT])
		if(!check_rights(R_SPAWN))
			return
		copy_outfit()

	if(href_list[VV_HK_SET_SPECIES])
		if(!check_rights(R_SPAWN))
			return

		var/new_species = tgui_input_list(usr, "Please choose a new species.", "Species", GLOB.all_species)
		if(!new_species)
			return

		if(QDELETED(src))
			to_chat(usr, "Mob doesn't exist anymore", confidential = TRUE)
			return

		var/datum/species/species = GLOB.all_species[new_species]
		if(set_species(species.type))
			to_chat(usr, "Set species of [src] to [dna.species].", confidential = TRUE)
			regenerate_icons()
			log_and_message_admins("has changed the species of [key_name_admin(src)] to [new_species]")
		else
			to_chat(usr, "Failed! Something went wrong.", confidential = TRUE)

	if(href_list[VV_HK_MAKE_SKELETON])
		if(!check_rights(R_EVENT))
			return

		if(tgui_alert(usr, "Are you sure you want to turn this mob into a skeleton?", "Confirm Skeleton Transformation", list("Yes", "No")) != "Yes")
			return

		makeSkeleton()
		message_admins("[key_name(usr)] has turned [key_name(src)] into a skeleton")
		log_admin("[key_name_admin(usr)] has turned [key_name_admin(src)] into a skeleton")
