/mob/vv_get_dropdown()
	. = ..()
	VV_DROPDOWN_OPTION("", "--- /mob ---")
	VV_DROPDOWN_OPTION(VV_HK_PLAYER_PANEL, "Show player panel")
	VV_DROPDOWN_OPTION(VV_HK_ADD_LANGUAGE, "Add Language")
	VV_DROPDOWN_OPTION(VV_HK_REMOVE_LANGUAGE, "Remove Language")
	VV_DROPDOWN_OPTION(VV_HK_GRANT_ALL_LANGUAGE, "Grant All Language")
	VV_DROPDOWN_OPTION(VV_HK_ADD_VERB, "Add Verb")
	VV_DROPDOWN_OPTION(VV_HK_REMOVE_VERB, "Remove Verb")
	VV_DROPDOWN_OPTION(VV_HK_BUILDMODE, "Toggle Buildmode")
	VV_DROPDOWN_OPTION(VV_HK_CHANGE_VOICE, "Change Voice")
	VV_DROPDOWN_OPTION(VV_HK_DIRECT_CONTROL, "Assume Direct Control")
	VV_DROPDOWN_OPTION(VV_HK_OFFER_GHOSTS, "Offer Control to Ghosts")
	VV_DROPDOWN_OPTION(VV_HK_DROP_ALL, "Drop Everything")
	VV_DROPDOWN_OPTION(VV_HK_GIVE_DISEASE, "Give Disease")
	VV_DROPDOWN_OPTION(VV_HK_GIVE_SPELL, "Give Spell")
	VV_DROPDOWN_OPTION(VV_HK_GODMODE, "Toggle Godmode")
	VV_DROPDOWN_OPTION(VV_HK_REGEN_ICONS, "Regenerate Icons")
	VV_DROPDOWN_OPTION(VV_HK_GIB, "Gib")

/mob/vv_do_topic(list/href_list)
	. = ..()

	if(!.)
		return

	if(href_list[VV_HK_ADD_LANGUAGE])
		if(!check_rights(R_SPAWN))
			return

		var/new_language = tgui_input_list(usr, "Please choose a language to add.", "Language", GLOB.all_languages)
		if(!new_language)
			return

		if(QDELETED(src))
			to_chat(usr, "Mob doesn't exist anymore", confidential = TRUE)
			return

		if(add_language(new_language))
			to_chat(usr, "Added [new_language] to [src].", confidential = TRUE)
			message_admins(span_adminnotice("[key_name_admin(usr)] has given [key_name_admin(src)] the language [new_language]"))
			log_admin("[key_name(usr)] has given [key_name(src)] the language [new_language]")
		else
			to_chat(usr, "Mob already knows that language.", confidential = TRUE)

	if(href_list[VV_HK_REMOVE_LANGUAGE])
		if(!check_rights(R_SPAWN))
			return

		if(!length(languages))
			to_chat(usr, "This mob knows no languages (Perhaps because he was stricken with Babylonian Fewer).", confidential = TRUE)
			return

		var/datum/language/rem_language = tgui_input_list(usr, "Please choose a language to remove.", "Language", languages)
		if(!rem_language)
			return

		if(QDELETED(src))
			to_chat(usr, "Mob doesn't exist anymore", confidential = TRUE)
			return

		if(remove_language(rem_language.name))
			to_chat(usr, "Removed [rem_language] from [src].", confidential = TRUE)
			message_admins(span_adminnotice("[key_name_admin(usr)] has removed language [rem_language] from [key_name_admin(src)]"))
			log_admin("[key_name(usr)] has removed language [rem_language] from [key_name(src)]")
		else
			to_chat(usr, "Mob doesn't know that language.", confidential = TRUE)

	if(href_list[VV_HK_GRANT_ALL_LANGUAGE])
		if(!check_rights(R_SPAWN))
			return

		grant_all_languages()
		to_chat(usr, "Added all languages to [src].", confidential = TRUE)
		log_and_message_admins("has given [key_name(src)] all languages.")

	if(href_list[VV_HK_CHANGE_VOICE])
		if(!check_rights(R_SPAWN))
			return

		var/old_tts_seed = tts_seed
		var/new_tts_seed = change_voice(usr)
		if(!new_tts_seed)
			return

		to_chat(usr, "Changed voice from [old_tts_seed] to [new_tts_seed] for [src].", confidential = TRUE)
		to_chat(src, span_notice("Your voice has been changed from [old_tts_seed] to [new_tts_seed]."), confidential = TRUE)
		log_and_message_admins("has changed [key_name(src)]'s voice from [old_tts_seed] to [new_tts_seed]")

	if(href_list[VV_HK_ADD_VERB])
		if(!check_rights(R_DEBUG))
			return

		var/list/possibleverbs = list()
		possibleverbs += "Cancel" // One for the top...
		possibleverbs += typesof(/mob/proc, /mob/verb, /mob/living/proc, /mob/living/verb)
		switch(type)
			if(/mob/living/carbon/human)
				possibleverbs += typesof(/mob/living/carbon/proc, /mob/living/carbon/verb, /mob/living/carbon/human/verb, /mob/living/carbon/human/proc)
			if(/mob/living/silicon/robot)
				possibleverbs += typesof(/mob/living/silicon/proc, /mob/living/silicon/robot/proc, /mob/living/silicon/robot/verb)
			if(/mob/living/silicon/ai)
				possibleverbs += typesof(/mob/living/silicon/proc, /mob/living/silicon/ai/proc, /mob/living/silicon/ai/verb)
		possibleverbs -= verbs
		possibleverbs += "Cancel" // ...And one for the bottom

		var/verb = tgui_input_list(usr, "Select a verb!", "Verbs", possibleverbs, null)
		if(QDELETED(src))
			to_chat(usr, "Mob doesn't exist anymore", confidential = TRUE)
			return
		if(!verb || verb == "Cancel")
			return

		add_verb(src, verb)
		message_admins("[key_name_admin(usr)] has given [key_name_admin(src)] the verb [verb]")
		log_admin("[key_name(usr)] has given [key_name(src)] the verb [verb]")

	if(href_list[VV_HK_REMOVE_VERB])
		if(!check_rights(R_DEBUG))
			return

		var/verb = tgui_input_list(usr, "Please choose a verb to remove.", "Verbs", verbs)
		if(QDELETED(src))
			to_chat(usr, "Mob doesn't exist anymore", confidential = TRUE)
			return
		if(!verb)
			return

		remove_verb(src, verb)
		message_admins("[key_name_admin(usr)] has removed verb [verb] from [key_name_admin(src)]")
		log_admin("[key_name(usr)] has removed verb [verb] from [key_name(src)]")

	if(href_list[VV_HK_REGEN_ICONS])
		if(!check_rights(R_DEBUG|R_ADMIN))
			return
		regenerate_icons()

	if(href_list[VV_HK_OFFER_GHOSTS])
		if(!check_rights(R_DEBUG|R_ADMIN))
			return
		offer_control(src)

	if(href_list[VV_HK_DIRECT_CONTROL])
		return SSadmin_verbs.dynamic_invoke_verb(usr, /datum/admin_verb/cmd_assume_direct_control, src)

	if(href_list[VV_HK_DROP_ALL])
		return SSadmin_verbs.dynamic_invoke_verb(usr, /datum/admin_verb/drop_everything, src)

	if(href_list[VV_HK_GIVE_DISEASE])
		SSadmin_verbs.dynamic_invoke_verb(usr, /datum/admin_verb/give_disease, src)

	if(href_list[VV_HK_GIVE_SPELL])
		return SSadmin_verbs.dynamic_invoke_verb(usr, /datum/admin_verb/give_spell, src)

	if(href_list[VV_HK_MOB_PLAYER_PANEL])
		return SSadmin_verbs.dynamic_invoke_verb(usr, /datum/admin_verb/vuap_personal, src)

	if(href_list[VV_HK_GODMODE])
		if(!check_rights(R_REJUVINATE))
			return
		SSadmin_verbs.dynamic_invoke_verb(usr, /datum/admin_verb/cmd_admin_godmode, src)

	if(href_list[VV_HK_GIB])
		return SSadmin_verbs.dynamic_invoke_verb(usr, /datum/admin_verb/gib_them, src)

	if(href_list[VV_HK_BUILDMODE])
		if(!check_rights(R_BUILDMODE))
			return
		togglebuildmode(src)

/mob/vv_auto_rename(new_name, list/ru_declensions)
	// Do not do parent's actions, as we *usually* do this differently.
	rename_character(real_name, new_name)
