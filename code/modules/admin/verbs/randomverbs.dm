ADMIN_VERB(drop_everything, R_DEBUG|R_ADMIN, "Drop Everything", ADMIN_VERB_NO_DESCRIPTION, ADMIN_CATEGORY_HIDDEN, mob/dropee as mob in GLOB.mob_list)
	var/confirm = tgui_alert(user, "Make [dropee] drop everything?", "Message", list("Yes", "No"))
	if(confirm != "Yes")
		return

	for(var/obj/item/item in dropee)
		dropee.drop_item_ground(item)

	log_admin("[key_name(user)] made [key_name(dropee)] drop everything!")
	message_admins("[key_name_admin(user)] made [ADMIN_LOOKUPFLW(dropee)] drop everything!")
	BLACKBOX_LOG_ADMIN_VERB("Drop Everything")

ADMIN_VERB(imprison, R_ADMIN, "Prison", ADMIN_VERB_NO_DESCRIPTION, ADMIN_CATEGORY_HIDDEN, mob/victim as mob in GLOB.mob_list)
	if(!istype(victim))
		return

	if(isAI(victim))
		tgui_alert(user, "The AI can't be sent to prison you jerk!")
		return

	if(!length(GLOB.prisonwarp))
		tgui_alert(user, "No prison warps!")
		return

	var/turf/prison_cell = pick(GLOB.prisonwarp)

	if(!prison_cell)
		return

	var/obj/structure/closet/supplypod/centcompod/prison_warp/pod = new()
	pod.reverse_dropoff_coords = list(prison_cell.x, prison_cell.y, prison_cell.z)
	pod.target = victim
	new /obj/effect/pod_landingzone(victim, pod)

	log_admin("[key_name(user)] sent [key_name(victim)] to the prison station.")
	message_admins(span_adminnotice("[key_name_admin(user)] sent [key_name_admin(victim)] to the prison station."))
	BLACKBOX_LOG_ADMIN_VERB("Prison")

ADMIN_VERB(imprison_in_list, R_ADMIN, "Prison in List", "Send a mob to prison.", ADMIN_CATEGORY_FUN)
	var/mob/victim = tgui_input_list(user, "Please, select a player!", "Prison", GLOB.mob_list)
	if(!victim)
		return

	SSadmin_verbs.dynamic_invoke_verb(user, /datum/admin_verb/imprison, victim)

ADMIN_VERB_AND_CONTEXT_MENU(cmd_admin_subtle_message, R_ADMIN, "Subtle Message", ADMIN_VERB_NO_DESCRIPTION, ADMIN_CATEGORY_HIDDEN, mob/target in GLOB.mob_list)
	if(!ismob(target))
		return

	message_admins("[key_name_admin(user)] has started answering [ADMIN_LOOKUPFLW(target)]'s prayer.")
	var/msg = tgui_input_text(user, "Message:", text("Subtle PM to [target.key]"), multiline = TRUE, encode = FALSE)

	if(!msg)
		message_admins("[key_name_admin(user)] decided not to answer [ADMIN_LOOKUPFLW(target)]'s prayer")
		return

	msg = admin_pencode_to_html(msg)

	target.balloon_alert(target, "вы слышите голос...")
	to_chat(target, span_italics("Вы слышите голос в своей голове... [span_bold(msg)]"), confidential = TRUE)

	log_admin("SubtlePM: [key_name(user)] -> [key_name(target)] : [msg]")
	message_admins(span_adminnotice("<b> SubtleMessage: [key_name_admin(user)] -> [key_name_admin(target)] :</b> [msg]"))
	BLACKBOX_LOG_ADMIN_VERB("Subtle Message")

ADMIN_VERB(check_new_players, R_MENTOR|R_MOD|R_ADMIN, "Check New Players", "Perform a player account age check.", ADMIN_CATEGORY_MAIN)
	var/age = tgui_alert(user, "Age check", "Show accounts yonger then _____ days", list("7", "30" , "All"))

	if(age == "All")
		age = 9999999
	else
		age = text2num(age)

	var/missing_ages = 0
	var/msg = ""
	for(var/client/C in GLOB.clients)
		if(C.player_age == "Requires database")
			missing_ages = 1
			continue
		if(C.player_age < age)
			if(check_rights(R_ADMIN, FALSE))
				msg += "[key_name_admin(C.mob)]: [C.player_age] days old<br>"
			else
				msg += "[key_name_mentor(C.mob)]: [C.player_age] days old<br>"

	if(missing_ages)
		to_chat(user, "Some accounts did not have proper ages set in their clients.  This function requires database to be present", confidential = TRUE)

	if(msg != "")
		var/datum/browser/popup = new(user, "player_age_check", "Player Age Check")
		popup.set_content(msg)
		popup.open(FALSE)

	else
		to_chat(user, "No matches for that age range found.", confidential = TRUE)

ADMIN_VERB(cmd_admin_world_narrate, R_SERVER|R_EVENT, "Global Narrate", "Send a direct narration to all connected players.", ADMIN_CATEGORY_EVENTS)
	var/msg = tgui_input_text(user, "Message:", "Enter the text you wish to appear to everyone:")
	if(!msg)
		return

	msg = admin_pencode_to_html(msg)
	to_chat(world, "[msg]", confidential = TRUE)
	log_admin("GlobalNarrate: [key_name(user)] : [msg]")
	message_admins(span_adminnotice("[key_name_admin(user)] Sent a global narrate"))
	BLACKBOX_LOG_ADMIN_VERB("Global Narrate")

ADMIN_VERB_AND_CONTEXT_MENU(cmd_admin_local_narrate, R_SERVER|R_EVENT, "Local Narrate", ADMIN_VERB_NO_DESCRIPTION, ADMIN_CATEGORY_HIDDEN, atom/locale in world)
	var/range = tgui_input_text(user, "Range:", "Narrate to mobs within how many tiles:", 7)
	if(!range)
		return

	var/msg = tgui_input_text(user, "Message:", "Enter the text you wish to appear to everyone within view:")
	if(!msg)
		return

	msg = admin_pencode_to_html(msg)
	for(var/mob/target in view(range, locale))
		to_chat(target, msg, confidential = TRUE)

	log_admin("LocalNarrate: [key_name(user)] at [AREACOORD(locale)]: [msg]")
	message_admins(span_adminnotice("<b> LocalNarrate: [key_name_admin(user)] at [ADMIN_VERBOSEJMP(locale)]:</b> [msg]<br>"))
	BLACKBOX_LOG_ADMIN_VERB("Local Narrate")

ADMIN_VERB_AND_CONTEXT_MENU(cmd_admin_direct_narrate, R_SERVER|R_EVENT, "Direct Narrate", ADMIN_VERB_NO_DESCRIPTION, ADMIN_CATEGORY_HIDDEN, mob/target in GLOB.player_list)
	if(!target)
		return

	var/msg = tgui_input_text(user, "Message:", "Enter the text you wish to appear to your target:")
	if(!msg)
		return

	msg = admin_pencode_to_html(msg)
	to_chat(target, msg, confidential = TRUE)
	log_admin("DirectNarrate: [key_name(user)] to ([key_name(target)]): [msg]")
	message_admins(span_adminnotice("<b> DirectNarrate: [key_name_admin(user)] to ([key_name_admin(target)]):</b> [msg]<br>"))
	BLACKBOX_LOG_ADMIN_VERB("Direct Narrate")

ADMIN_VERB_AND_CONTEXT_MENU(cmd_admin_headset_message, R_EVENT, "Headset Message", ADMIN_VERB_NO_DESCRIPTION, ADMIN_CATEGORY_HIDDEN, mob/target in GLOB.mob_list)
	user.admin_headset_message(target)

/client/proc/admin_headset_message(mob/M in GLOB.mob_list, sender = null)
	var/mob/living/carbon/human/H = M
	if(!istype(H))
		to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human", confidential = TRUE)
		return
	if(!istype(H.l_ear, /obj/item/radio/headset) && !istype(H.r_ear, /obj/item/radio/headset))
		to_chat(usr, "The person you are trying to contact is not wearing a headset", confidential = TRUE)
		return

	if(!sender)
		sender = tgui_input_list(src, "Who is the message from?", "Sender", list("Centcomm", "Syndicate"))
		if(!sender)
			return

	message_admins("[key_name_admin(src)] has started answering [key_name_admin(H)]'s [sender] request.")
	var/input = tgui_input_text(src, "Please enter a message to reply to [key_name(H)] via their headset.", "Outgoing message from [sender]", multiline = TRUE, encode = FALSE)
	if(!input)
		message_admins("[key_name_admin(src)] decided not to answer [key_name_admin(H)]'s [sender] request.")
		return

	log_admin("[key_name(src)] replied to [key_name(H)]'s [sender] message with the message [input].")
	message_admins("[key_name_admin(src)] replied to [key_name_admin(H)]'s [sender] message with: \"[input]\"")
	to_chat(H, "<span class = specialnotice>Incoming priority transmission from [sender == "Syndicate" ? "your benefactor" : "Central Command"].  Message as follows[sender == "Syndicate" ? ", agent." : ":"]</span><span class = 'specialnotice'> [input]</span>")

	SEND_SOUND(H, sound('sound/effects/headset_message.ogg'))

ADMIN_VERB(cmd_admin_godmode, R_ADMIN, "Godmode", ADMIN_VERB_NO_DESCRIPTION, ADMIN_CATEGORY_HIDDEN, mob/target as mob in GLOB.mob_list)
	var/had_trait = HAS_TRAIT_FROM(target, TRAIT_GODMODE, ADMIN_TRAIT)
	if(had_trait)
		REMOVE_TRAIT(target, TRAIT_GODMODE, ADMIN_TRAIT)
	else
		ADD_TRAIT(target, TRAIT_GODMODE, ADMIN_TRAIT)

	to_chat(user, span_notice("Toggled [had_trait ? "OFF" : "ON"]"), confidential = TRUE)
	log_admin("[key_name(user)] has toggled [key_name(target)]'s nodamage to [had_trait ? "Off" : "On"]")
	message_admins("[key_name_admin(user)] has toggled [ADMIN_LOOKUPFLW(target)]'s nodamage to [had_trait ? "Off" : "On"]")
	BLACKBOX_LOG_ADMIN_VERB("Godmode")

ADMIN_VERB(cmd_admin_godmode_in_list, R_ADMIN, "Godmode in List", "Toggles godmode on a mob.", ADMIN_CATEGORY_GAME)
	var/mob/target = tgui_input_list(user, "Please, select a player!", "Godmode", GLOB.mob_list)
	if(!target)
		return

	SSadmin_verbs.dynamic_invoke_verb(user, /datum/admin_verb/cmd_admin_godmode, target)

/proc/cmd_admin_mute(mob/M, mute_type, automute = 0)
	if(automute)
		if(!CONFIG_GET(flag/automute_on))
			return
	else
		if(!usr || !usr.client)
			return
		if(!check_rights(R_ADMIN|R_MOD))
			to_chat(usr, span_red("Error: cmd_admin_mute: You don't have permission to do this."), confidential = TRUE)
			return
		if(!M.client)
			to_chat(usr, span_red("Error: cmd_admin_mute: This mob doesn't have a client tied to it."), confidential = TRUE)
	if(!M.client)
		return

	var/muteunmute
	var/mute_string

	switch(mute_type)
		if(MUTE_IC)
			mute_string = "IC (say and emote)"
		if(MUTE_OOC)
			mute_string = "OOC"
		if(MUTE_PRAY)
			mute_string = "pray"
		if(MUTE_ADMINHELP)
			mute_string = "adminhelp, admin PM and ASAY"
		if(MUTE_DEADCHAT)
			mute_string = "deadchat and DSAY"
		if(MUTE_TTS)
			mute_string = "text to speech"
		if(MUTE_EMOTE)
			mute_string = "emote"
		if(MUTE_ALL)
			mute_string = "everything"
		else
			return

	if(automute)
		muteunmute = "auto-muted"
		force_add_mute(M.client.ckey, mute_type)
		log_admin("SPAM AUTOMUTE: [muteunmute] [key_name(M)] from [mute_string]")
		message_admins("SPAM AUTOMUTE: [muteunmute] [key_name_admin(M)] from [mute_string].")
		to_chat(M, "You have been [muteunmute] from [mute_string] by the SPAM AUTOMUTE system. Contact an admin.", confidential = TRUE)
		BLACKBOX_LOG_ADMIN_VERB("Automute")
		return

	toggle_mute(M.client.ckey, mute_type)

	if(check_mute(M.client.ckey, mute_type))
		muteunmute = "muted"
	else
		muteunmute = "unmuted"

	log_and_message_admins("has [muteunmute] [key_name_admin(M)] from [mute_string].")
	to_chat(M, "You have been [muteunmute] from [mute_string].", confidential = TRUE)
	BLACKBOX_LOG_ADMIN_VERB("Mute")

ADMIN_VERB(add_random_ai_law, R_EVENT, "Add Random AI Law", "Add a random law to the AI.", ADMIN_CATEGORY_FUN)
	var/confirm = tgui_alert(user, "You sure?", "Confirm", list("Yes", "No"))
	if(confirm != "Yes")
		return
	log_admin("[key_name(user)] has added a random AI law.")
	message_admins("[key_name_admin(user)] has added a random AI law.")

	var/show_log = tgui_alert(user, "Show ion message?", "Message", list("Yes", "No"))
	var/announce_ion_laws = (show_log == "Yes" ? 1 : -1)

	var/datum/event_meta/meta_info = new(EVENT_LEVEL_MAJOR, "Admin ([key_name(user)]) added random law.", /datum/event/ion_storm)
	new /datum/event/ion_storm(EM = meta_info, botEmagChance = 0, announceEvent = announce_ion_laws)
	BLACKBOX_LOG_ADMIN_VERB("Add Random AI Law")

ADMIN_VERB(toggle_antaghud_use, R_SERVER, "Toggle antagHUD usage", "Toggles antagHUD usage for observers", ADMIN_CATEGORY_TOGGLES)
	var/action = ""
	if(CONFIG_GET(flag/allow_antag_hud))
		for(var/mob/dead/observer/g in user.get_ghosts())
			if(g.antagHUD)
				g.antagHUD = FALSE						// Disable it on those that have it enabled
				g.has_enabled_antagHUD = FALSE				// We'll allow them to respawn
				to_chat(g, span_danger("The Administrator has disabled AntagHUD."))

		CONFIG_SET(flag/allow_antag_hud, FALSE)
		to_chat(user, span_danger("AntagHUD usage has been disabled."), confidential = TRUE)
		action = "disabled"
	else
		for(var/mob/dead/observer/g in user.get_ghosts())
			if(!g.client.holder)						// Add the verb back for all non-admin ghosts
				to_chat(g, span_boldnotice("The Administrator has enabled AntagHUD."))// Notify all observers they can now use AntagHUD

		CONFIG_SET(flag/allow_antag_hud, TRUE)
		action = "enabled"
		to_chat(user, span_boldnotice("AntagHUD usage has been enabled."), confidential = TRUE)

	log_and_message_admins("has [action] antagHUD usage for observers")

ADMIN_VERB(toggle_antaghug_restrictions, R_SERVER, "Toggle antagHUD Restrictions", "Restricts players that have used antagHUD from being able to join this round.", ADMIN_CATEGORY_TOGGLES)
	var/action = ""
	if(CONFIG_GET(flag/antag_hud_restricted))
		for(var/mob/dead/observer/ghost in user.get_ghosts())
			to_chat(ghost, span_boldnotice("The administrator has lifted restrictions on joining the round if you use AntagHUD"), confidential = TRUE)
		action = "lifted restrictions"
		CONFIG_SET(flag/antag_hud_restricted, FALSE)
		to_chat(user, span_boldnotice("AntagHUD restrictions have been lifted"), confidential = TRUE)
	else
		for(var/mob/dead/observer/ghost in user.get_ghosts())
			to_chat(ghost, span_danger("The administrator has placed restrictions on joining the round if you use AntagHUD"), confidential = TRUE)
			to_chat(ghost, span_danger("Your AntagHUD has been disabled, you may choose to re-enabled it but will be under restrictions."), confidential = TRUE)
			ghost.antagHUD = FALSE
			ghost.has_enabled_antagHUD = FALSE
		action = "placed restrictions"
		CONFIG_SET(flag/antag_hud_restricted, TRUE)
		to_chat(user, span_danger("AntagHUD restrictions have been enabled."), confidential = TRUE)

	log_and_message_admins("has [action] on joining the round if they use AntagHUD")

/*
If a guy was gibbed and you want to revive him, this is a good way to do so.
Works kind of like entering the game with a new character. Character receives a new mind if they didn't have one.
Traitors and the like can also be revived with the previous role mostly intact.
/N */
ADMIN_VERB(respawn_character, R_SPAWN, "Respawn Character", "Respawn a player that has been round removed in some manner. They must be a ghost.", ADMIN_CATEGORY_GAME)
	var/input = ckey(tgui_input_text(user, "Please specify which key will be respawned.", "Key", "", encode = FALSE))
	if(!input)
		return

	var/mob/dead/observer/G_found
	for(var/mob/dead/observer/G in GLOB.player_list)
		if(G.ckey == input)
			G_found = G
			break

	if(!G_found)//If a ghost was not found.
		to_chat(user, "<span style='color: red;'>There is no active key like that in the game or the person is not currently a ghost.</span>", confidential = TRUE)
		return

	if(G_found.mind && !G_found.mind.active)	//mind isn't currently in use by someone/something
		//Check if they were an alien
		if(G_found.mind.assigned_role=="Alien")
			if(tgui_alert(user, "This character appears to have been an alien. Would you like to respawn them as such?",, list("Yes", "No")) == "Yes")
				var/turf/T
				if(length(GLOB.xeno_spawn))
					T = pick(GLOB.xeno_spawn)
				else
					T = pick(GLOB.latejoin)

				var/mob/living/carbon/alien/new_xeno
				switch(G_found.mind.special_role)//If they have a mind, we can determine which caste they were.
					if("Hunter")
						new_xeno = new /mob/living/carbon/alien/humanoid/hunter(T)
					if("Sentinel")
						new_xeno = new /mob/living/carbon/alien/humanoid/sentinel(T)
					if("Drone")
						new_xeno = new /mob/living/carbon/alien/humanoid/drone(T)
					if("Queen")
						new_xeno = new /mob/living/carbon/alien/humanoid/queen(T)
					else//If we don't know what special role they have, for whatever reason, or they're a larva.
						create_xeno(G_found.ckey)
						return

				//Now to give them their mind back.
				G_found.mind.transfer_to(new_xeno)	//be careful when doing stuff like this! I've already checked the mind isn't in use
				new_xeno.possess_by_player(G_found.key)
				to_chat(new_xeno, "You have been fully respawned. Enjoy the game.")
				log_and_message_admins(span_notice("has respawned [new_xeno.key] as a filthy xeno."))
				return	//all done. The ghost is auto-deleted

	var/mob/living/carbon/human/new_character = new(pick(GLOB.latejoin))//The mob being spawned.

	var/datum/data/record/record_found			//Referenced to later to either randomize or not randomize the character.
	if(G_found.mind && !G_found.mind.active)	//mind isn't currently in use by someone/something
		/*Try and locate a record for the person being respawned through data_core.
		This isn't an exact science but it does the trick more often than not.*/
		var/id = md5("[G_found.real_name][G_found.mind.assigned_role]")
		for(var/datum/data/record/t in GLOB.data_core.locked)
			if(t.fields["id"]==id)
				record_found = t//We shall now reference the record.
				break

	if(record_found)//If they have a record we can determine a few things.
		new_character.real_name = record_found.fields["name"]
		new_character.change_gender(record_found.fields["sex"])
		new_character.age = record_found.fields["age"]
		new_character.dna.blood_type = record_found.fields["blood_type"]
	else
		new_character.change_gender(pick(MALE,FEMALE))
		var/datum/preferences/A = new()
		A.real_name = G_found.real_name
		A.copy_to(new_character)

	if(!new_character.real_name)
		new_character.real_name = random_name(new_character.gender)
	new_character.name = new_character.real_name

	if(G_found.mind && !G_found.mind.active)
		G_found.mind.transfer_to(new_character)	//be careful when doing stuff like this! I've already checked the mind isn't in use
		new_character.mind.special_verbs = list()
	else
		new_character.mind_initialize()
	if(!new_character.mind.assigned_role)
		new_character.mind.assigned_role = JOB_TITLE_CIVILIAN//If they somehow got a null assigned role.

	//DNA
	if(record_found)//Pull up their name from database records if they did have a mind.
		new_character.dna = new()//Let's first give them a new DNA.
		new_character.dna.unique_enzymes = record_found.fields["b_dna"]//Enzymes are based on real name but we'll use the record for conformity.

		// I HATE BYOND.  HATE.  HATE. - N3X
		var/list/newSE= record_found.fields["enzymes"]
		var/list/newUI = record_found.fields["identity"]
		new_character.dna.SE = newSE.Copy() //This is the default of enzymes so I think it's safe to go with.
		new_character.dna.UpdateSE()
		new_character.UpdateAppearance(newUI.Copy())//Now we configure their appearance based on their unique identity, same as with a DNA machine or somesuch.
	else//If they have no records, we just do a random DNA for them, based on their random appearance/savefile.
		new_character.dna.ready_dna(new_character)

	new_character.possess_by_player(G_found.key)

	/*
	The code below functions with the assumption that the mob is already a traitor if they have a special role.
	So all it does is re-equip the mob with powers and/or items. Or not, if they have no special role.
	If they don't have a mind, they obviously don't have a special role.
	*/

	//Now for special roles and equipment.
	switch(new_character.mind.special_role)
		if("traitor")
			if(new_character.mind.has_antag_datum(/datum/antagonist/traitor))
				var/datum/antagonist/traitor/T = new_character?.mind?.has_antag_datum(/datum/antagonist/traitor)
				T.give_uplink()
			else
				new_character.mind.add_antag_datum(/datum/antagonist/traitor)
		if("Wizard")
			new_character.forceMove(pick(GLOB.wizardstart))
			//ticker.mode.learn_basic_spells(new_character)
			SSticker.mode.equip_wizard(new_character)
		if("Syndicate")
			var/obj/effect/landmark/synd_spawn = locate(/obj/effect/landmark/spawner/syndie)
			if(synd_spawn)
				new_character.forceMove(get_turf(synd_spawn))
			var/datum/antagonist/nuclear_operative/datum = new_character.mind.has_antag_datum(/datum/antagonist/nuclear_operative)
			if(!datum)
				datum = new_character.mind.add_antag_datum(/datum/antagonist/nuclear_operative, /datum/team/nuclear_team)
			datum.equip()

		if("Death Commando")//Leaves them at late-join spawn.
			new_character.equipOutfit(/datum/outfit/admin/death_commando)
			new_character.update_action_buttons_icon()
		else//They may also be a cyborg or AI.
			switch(new_character.mind.assigned_role)
				if(JOB_TITLE_CYBORG)//More rigging to make em' work and check if they're traitor.
					new_character = new_character.Robotize()
					if(new_character.mind.special_role=="traitor")
						new_character.mind.add_antag_datum(/datum/antagonist/traitor)
					SSticker?.score?.save_silicon_laws(new_character, user.mob, additional_info = "admin respawn", log_all_laws = TRUE)
				if(JOB_TITLE_AI)
					new_character = new_character.AIize()
					var/mob/living/silicon/ai/ai_character = new_character
					ai_character.moveToAILandmark()
					if(new_character.mind.special_role=="traitor")
						new_character.mind.add_antag_datum(/datum/antagonist/traitor)
					SSticker?.score?.save_silicon_laws(ai_character, user.mob, additional_info = "admin respawn", log_all_laws = TRUE)
				//Add aliens.
				else
					SSjobs.AssignRank(new_character, new_character.mind.assigned_role, 0)
					SSjobs.EquipRank(new_character, new_character.mind.assigned_role, 1)//Or we simply equip them.

	//Announces the character on all the systems, based on the record.
	if(!issilicon(new_character))//If they are not a cyborg/AI.
		if(!record_found && new_character.mind.assigned_role != new_character.mind.special_role)//If there are no records for them. If they have a record, this info is already in there. Offstation special characters announced anyway.
			//Power to the user!
			if(tgui_alert(new_character,"Warning: No data core entry detected. Would you like to announce the arrival of this character by adding them to various databases, such as medical records?",, list("Yes", "No")) == "Yes")
				GLOB.data_core.manifest_inject(new_character)

			if(tgui_alert(new_character,"Would you like an active AI to announce this character?",, list("Yes", "No")) == "Yes")
				call(/mob/new_player/proc/AnnounceArrival)(new_character, new_character.mind.assigned_role)

	log_and_message_admins(span_notice("has respawned [key_name_admin(G_found)] as [new_character.real_name]."))

	to_chat(new_character, "You have been fully respawned. Enjoy the game.", confidential = TRUE)

	BLACKBOX_LOG_ADMIN_VERB("Respawn Character")
	return new_character

//I use this proc for respawn character too. /N
/proc/create_xeno(ckey)
	if(!ckey)
		var/list/candidates = list()
		for(var/mob/M in GLOB.player_list)
			if(M.stat != DEAD)
				continue //we are not dead!
			if(!(ROLE_ALIEN in M.client.prefs.be_special))
				continue //we don't want to be an alium
			if(jobban_isbanned(M, "alien") || jobban_isbanned(M, "Syndicate"))
				continue //we are jobbanned
			if(M.client.is_afk())
				continue //we are afk
			if(M.mind && M.mind.current && M.mind.current.stat != DEAD)
				continue //we have a live body we are tied to
			candidates += M.ckey
		if(length(candidates))
			ckey = tgui_input_list(usr, "Pick the player you want to respawn as a xeno.", "Suitable Candidates", candidates)
		else
			to_chat(usr, span_red("Error: create_xeno(): no suitable candidates."), confidential = TRUE)
	if(!istext(ckey))
		return 0

	var/alien_caste = tgui_input_list(usr, "Please choose which caste to spawn.", "Pick a caste", list("Queen", "Hunter", "Sentinel", "Drone", "Larva"), null)
	var/obj/effect/landmark/spawn_here = length(GLOB.xeno_spawn) ? pick(GLOB.xeno_spawn) : pick(GLOB.latejoin)
	var/mob/living/carbon/alien/new_xeno
	switch(alien_caste)
		if("Queen")
			new_xeno = new /mob/living/carbon/alien/humanoid/queen/large(spawn_here)
		if("Hunter")
			new_xeno = new /mob/living/carbon/alien/humanoid/hunter(spawn_here)
		if("Sentinel")
			new_xeno = new /mob/living/carbon/alien/humanoid/sentinel(spawn_here)
		if("Drone")
			new_xeno = new /mob/living/carbon/alien/humanoid/drone(spawn_here)
		if("Larva")
			new_xeno = new /mob/living/carbon/alien/larva(spawn_here)
		else
			return 0

	new_xeno.possess_by_player(ckey)
	log_and_message_admins(span_notice("has spawned [ckey] as a filthy xeno [alien_caste]."))
	return 1

/client/proc/get_ghosts(notify = 0, what = 2)
	// what = 1, return ghosts ass list.
	// what = 2, return mob list

	var/list/mobs = list()
	var/list/ghosts = list()
	var/list/sortmob = sortAtom(GLOB.mob_list) // get the mob list.
	var/any=0
	for(var/mob/dead/observer/M in sortmob)
		mobs.Add(M) //filter it where it's only ghosts
		any = 1 //if no ghosts show up, any will just be 0
	if(!any)
		if(notify)
			to_chat(src, "There doesn't appear to be any ghosts for you to select.", confidential = TRUE)
		return

	for(var/mob/M in mobs)
		var/name = M.name
		ghosts[name] = M //get the name of the mob for the popup list
	if(what==1)
		return ghosts
	else
		return mobs

ADMIN_VERB(cmd_admin_add_freeform_ai_law, R_EVENT, "Add Custom AI Law", "Add a custom law to the Silicons.", ADMIN_CATEGORY_EVENTS)
	var/input = tgui_input_text(user, "Please enter anything you want the AI to do. Anything. Serious.", "What?", "", encode = FALSE)
	if(!input)
		return

	log_admin("Admin [key_name(user)] has added a new AI law - [input]")
	message_admins("Admin [key_name_admin(user)] has added a new AI law - [input]")

	var/show_log = tgui_alert(user, "Show ion message?", "Message", list("Yes", "No"))
	var/announce_ion_laws = (show_log == "Yes" ? 1 : -1)

	var/datum/event_meta/meta_info = new(EVENT_LEVEL_MAJOR, "Admin ([key_name(user)]) added freeform law.", /datum/event/ion_storm)
	new /datum/event/ion_storm(EM = meta_info, botEmagChance = 0, announceEvent = announce_ion_laws, ionMessage = input)

	BLACKBOX_LOG_ADMIN_VERB("Add Custom AI Law")

ADMIN_VERB_ONLY_CONTEXT_MENU(admin_rejuvenate, R_REJUVINATE, "Rejuvenate", mob/living/M as mob in GLOB.mob_list)
	if(!user.mob)
		return
	if(!istype(M))
		tgui_alert(user, "Cannot revive a ghost")
		return
	M.revive()

	log_and_message_admins(span_warning("healed / revived [key_name_admin(M)]!"))
	BLACKBOX_LOG_ADMIN_VERB("Rejuvenate")

ADMIN_VERB_ONLY_CONTEXT_MENU(admin_offer_control, R_ADMIN, "Offer control to ghosts", mob/M as mob in GLOB.mob_list)
	if(!user.mob)
		return
	if(!istype(M))
		tgui_alert(user, "This can only be used on instances of type /mob")
		return
	offer_control(M)

#define CUSTOM_MESSAGE_TYPE "Свой тип."

ADMIN_VERB(cmd_admin_create_centcom_report, R_SERVER|R_EVENT, "Create Communications Report", "Send an IC announcement to the game world.", ADMIN_CATEGORY_EVENTS)
	//the stuff on the list is |"report type" = "report title"|, if that makes any sense
	var/list/message_type = list(
		"Сообщение Центрального командования." = "Обновление \"Нанотрейзен\".",
		"Официальное сообщение \"Синдиката\"." = "Сообщение \"Синдиката\".",
		"Сообщение Федерации Космических Волшебников." = "Заколдованное сообщение.",
		"Официальное сообщение Клана Паука." = "Сообщение Клана Паука.",
		"Вражеское сообщение." = "Неизвестное сообщение.",
		CUSTOM_MESSAGE_TYPE = "Загадочное сообщение."
	)

	var/list/message_sound = list(
		"Уведомление *бип*" = 'sound/misc/notice2.ogg',
		"Перехвачены вражеские сообщения" = 'sound/AI/intercept.ogg',
		"Составлен отчёт о новой команде" = 'sound/AI/commandreport.ogg'
	)

	var/type = tgui_input_list(user, "Выберите тип сообщения для отправки.", "Тип сообщения", message_type, "")

	if(type == CUSTOM_MESSAGE_TYPE)
		type = tgui_input_text(user, "Введите тип сообщения.", "Тип сообщения", "Зашифрованная передача", encode = FALSE)

	var/subtitle = tgui_input_text(user, "Введите заголовок сообщения.", "Заголовок", message_type[type], encode = FALSE)
	if(!subtitle)
		return
	var/input_message = tgui_input_text(user, "Введите всё, что хотите. Что угодно. Серьёзно.", "Какое сообщение?", multiline = TRUE, encode = FALSE)
	if(!input_message)
		return

	switch(tgui_alert(user, "Должно ли это быть объявлено всем?", null, list("Да", "Нет", "Отмена")))
		if("Да")
			var/beepsound = tgui_input_list(user, "Какой звук должен издавать анонс?", "Звук анонса", message_sound)
			GLOB.major_announcement.announce(
				message = input_message,
				new_title = type,
				new_subtitle = subtitle,
				new_sound = message_sound[beepsound]
			)
			print_command_report(input_message, subtitle)
		if("Нет")
			//same thing as the blob stuff - it's not public, so it's classified, dammit
			radio_announce("Отчёт был загружен и распечатан на всех консолях связи.", "Консоль связи", COMM_FREQ)
			print_command_report(input_message, "Секретно: [subtitle]")
		else
			return

	log_admin("[key_name(user)] has created a communications report: [input_message]")
	message_admins("[key_name_admin(user)] has created a communications report")
	BLACKBOX_LOG_ADMIN_VERB("Create Comms Report")

#undef CUSTOM_MESSAGE_TYPE

ADMIN_VERB_AND_CONTEXT_MENU(cmd_admin_delete, R_ADMIN, "Delete", ADMIN_VERB_NO_DESCRIPTION, ADMIN_CATEGORY_HIDDEN, atom/target as obj|mob|turf in world)
	user.admin_delete(target)

/client/proc/admin_delete(datum/D)
	if(istype(D) && !D.can_vv_delete())
		to_chat(src, "[D] rejected your deletion", confidential = TRUE)
		return
	var/atom/A = D
	var/coords = ""
	var/jmp_coords = ""
	if(istype(A))
		var/turf/T = get_turf(A)
		if(T)
			coords = "at [COORD(T)]"
			jmp_coords = "at [ADMIN_COORDJMP(T)]"
		else
			jmp_coords = coords = "in nullspace"

	if(tgui_alert(src, "Are you sure you want to delete:\n[D]\n[coords]?", "Confirmation", list("Yes", "No")) == "Yes")
		log_admin("[key_name(usr)] deleted [D] [coords]")
		message_admins("[key_name_admin(usr)] deleted [D] [jmp_coords]")
		BLACKBOX_LOG_ADMIN_VERB("Delete")
		if(isturf(D))
			var/turf/T = D
			T.ChangeTurf(T.baseturf)
		else
			vv_update_display(D, "deleted", VV_MSG_DELETED)
			qdel(D)
			if(!QDELETED(D))
				vv_update_display(D, "deleted", "")

ADMIN_VERB(list_open_jobs, R_ADMIN, "List free slots", "List available station jobs.", ADMIN_CATEGORY_MAIN)
	if(SSjobs)
		var/currentpositiontally
		var/totalpositiontally
		to_chat(user, span_notice("Job Name: Filled job slot / Total job slots <b>(Free job slots)</b>"), confidential = TRUE)
		for(var/datum/job/job in SSjobs.occupations)
			to_chat(user, span_notice("[job.title]: [job.current_positions] / \
			[job.total_positions == -1 ? "<b>UNLIMITED</b>" : job.total_positions] \
			<b>([job.total_positions == -1 ? "UNLIMITED" : job.total_positions - job.current_positions])</b>"))
			if(job.total_positions != -1) // Only count position that isn't unlimited
				currentpositiontally += job.current_positions
				totalpositiontally += job.total_positions
		to_chat(user, "<b>Currently filled job slots (Excluding unlimited): [currentpositiontally] / [totalpositiontally] ([totalpositiontally - currentpositiontally])</b>", confidential = TRUE)
	BLACKBOX_LOG_ADMIN_VERB("List Free Slots")

ADMIN_VERB(admin_explosion, R_DEBUG|R_EVENT, "Explosion", ADMIN_VERB_NO_DESCRIPTION, ADMIN_CATEGORY_HIDDEN, atom/orignator as obj|mob|turf)
	var/devastation = tgui_input_number(user, "Range of total devastation. -1 to none", "Input")
	if(devastation == null)
		return

	var/heavy = tgui_input_number(user, "Range of heavy impact. -1 to none", "Input")
	if(heavy == null)
		return

	var/light = tgui_input_number(user, "Range of light impact. -1 to none", "Input")
	if(light == null)
		return

	var/flash = tgui_input_number(user, "Range of flash. -1 to none", "Input")
	if(flash == null)
		return

	var/flames = tgui_input_number(user, "Range of flames. -1 to none", "Input")
	if(flames == null)
		return

	if((devastation != -1) || (heavy != -1) || (light != -1) || (flash != -1) || (flames != -1))
		if((devastation > 20) || (heavy > 20) || (light > 20) || (flames > 20))
			if(tgui_alert(user, "Are you sure you want to do this? It will laaag.", "Confirmation", list("Yes", "No")) == "No")
				return

		explosion(orignator, devastation_range = devastation, heavy_impact_range = heavy, light_impact_range = light, flash_range = flash, adminlog = null, ignorecap = null, flame_range = flames)
		log_and_message_admins("created an explosion ([devastation],[heavy],[light],[flames]) at [AREACOORD(orignator)]")
		BLACKBOX_LOG_ADMIN_VERB("Explosion")

ADMIN_VERB(admin_emp, R_DEBUG|R_EVENT, "EM Pulse", ADMIN_VERB_NO_DESCRIPTION, ADMIN_CATEGORY_HIDDEN, atom/orignator as obj|mob|turf)
	var/heavy = tgui_input_number(user, "Range of heavy pulse.", "Input")
	if(heavy == null)
		return

	var/light = tgui_input_number(user, "Range of light pulse.", "Input")
	if(light == null)
		return

	if(heavy || light)
		empulse(orignator, heavy, light)
		log_admin("[key_name(user)] created an EM Pulse ([heavy],[light]) at [AREACOORD(orignator)]")
		message_admins("[key_name_admin(user)] created an EM Pulse ([heavy],[light]) at [AREACOORD(orignator)]")
		BLACKBOX_LOG_ADMIN_VERB("EM Pulse")

ADMIN_VERB(gib_them, R_ADMIN|R_EVENT, "Gib", ADMIN_VERB_NO_DESCRIPTION, ADMIN_CATEGORY_HIDDEN, mob/victim as mob in GLOB.mob_list)
	var/confirm = tgui_alert(user, "You sure?", "Confirm", list("Yes", "No"))
	if(confirm != "Yes")
		return

	//Due to the delay here its easy for something to have happened to the mob
	if(isnull(victim))
		return

	log_and_message_admins("has gibbed [key_name_admin(victim)]")

	if(isobserver(victim))
		gibs(victim.loc)
		return

	victim.gib()
	BLACKBOX_LOG_ADMIN_VERB("Gib")

ADMIN_VERB(gib_self, R_ADMIN|R_EVENT, "Gibself", "Give yourself the same treatment you give others.", ADMIN_CATEGORY_FUN)
	var/confirm = tgui_alert(user, "You sure?", "Confirm", list("Yes", "No"))
	if(confirm != "Yes")
		return

	var/mob/living/ourself = user.mob
	if(istype(ourself))
		ourself.gib()

	log_admin("[key_name(user)] used gibself.")
	message_admins(span_adminnotice("[key_name_admin(user)] used gibself."))
	BLACKBOX_LOG_ADMIN_VERB("Gib Self")

ADMIN_VERB_AND_CONTEXT_MENU(cmd_check_contents, R_ADMIN, "Check Contents", ADMIN_VERB_NO_DESCRIPTION, ADMIN_CATEGORY_HIDDEN, mob/living/target as mob in GLOB.mob_list)
	var/list/mob_contents = target.get_contents()
	for(var/atom/content in mob_contents)
		to_chat(user, "[content] [ADMIN_VV(content, "VV")]", confidential = TRUE)
	BLACKBOX_LOG_ADMIN_VERB("Check Contents")

ADMIN_VERB(toggle_view_range, R_ADMIN, "Change View Range", "Switch between 1x and custom views.", ADMIN_CATEGORY_GAME)
	var/client_view = user.prefs.viewrange

	if(user.view == client_view)
		var/input = tgui_input_list(user, "Select view range:", "View Range", list(1,2,3,4,5,6,7,8,9,10,11,12,13,14,"MAX"), 7)
		if(!input)
			return

		var/list/viewscales = getviewsize(client_view)
		var/aspect_ratio = viewscales[1] / viewscales[2]

		var/view_x
		var/view_y
		if(input == "MAX")
			if(viewscales[1] == viewscales[2])
				view_x = 71	// 71 is max for X
				view_y = 67	// 67 is max for Y
			else
				view_x = 71
				view_y = round(71 / aspect_ratio)
		else
			view_y = (input * 2) % 2 ? input * 2 : input * 2 + 1
			var/rounded_x = round(view_y * aspect_ratio)
			view_x = rounded_x % 2 ? rounded_x : rounded_x + 1

		user.view = "[view_x]x[view_y]"
	else
		user.view = client_view

	user.fit_viewport()

	log_admin("[key_name(user)] changed their view range to [user.view].")
	BLACKBOX_LOG_ADMIN_VERB("Change View Range")

ADMIN_VERB(toggle_pacifism_gt, R_ADMIN, "Toggle Pacifism After Greentext", "Toggle Pacifism After Greentext.", ADMIN_CATEGORY_TOGGLES)
	if(SSticker.current_state == GAME_STATE_FINISHED)
		if(GLOB.pacifism_after_gt)
			if(tgui_alert(user, "Вы готовы убрать пацифизм у всех?",, list("Да", "Нет")) == "Нет")
				return
			GLOB.pacifism_after_gt = FALSE
			log_and_message_admins("removed pacifism from all mobs.")
		else
			if(tgui_alert(user, "Вы хотите вернуть пацифизм всем?",, list("Да", "Нет")) == "Нет")
				return
			GLOB.pacifism_after_gt = TRUE
			log_and_message_admins("added pacifism to all mobs.")

	else
		SSticker.toggle_pacifism = (SSticker.toggle_pacifism) ? FALSE : TRUE
		log_and_message_admins("toggled pacifism after greentext in [(SSticker.toggle_pacifism) ? "On" : "Off"].")

	BLACKBOX_LOG_ADMIN_VERB("Toggle Pacifism")

ADMIN_VERB(toggle_ghost_vision, R_ADMIN, "Toggle Ghost Vision After Greentext", "Toggle Ghost Vision after greentext.", ADMIN_CATEGORY_TOGGLES)
	if(SSticker.current_state == GAME_STATE_FINISHED)
		if(!GLOB.observer_default_invisibility)
			if(tgui_alert(user, "Вы хотите выключить видимость призраков?",, list("Да", "Нет")) == "Нет")
				return
			set_observer_default_invisibility(INVISIBILITY_OBSERVER)
			log_and_message_admins("Ghosts are no longer visible.")
		else
			if(tgui_alert(user, "Вы хотите включить видимость призраков?",, list("Да", "Нет")) == "Нет")
				return
			set_observer_default_invisibility(INVISIBILITY_NONE)
			log_and_message_admins("Ghosts are now visible.")
	else
		SSticker.toggle_gv = (SSticker.toggle_gv) ? FALSE : TRUE
		log_and_message_admins("toggled ghost vision after greentext in [(SSticker.toggle_gv) ? "On" : "Off"].")
	BLACKBOX_LOG_ADMIN_VERB("Toggle Ghost Vision")

ADMIN_VERB(everyone_random, R_SERVER|R_EVENT, "Make Everyone Random", "Make everyone have a random appearance. You can only use this before rounds!", ADMIN_CATEGORY_FUN)
	if(SSticker.HasRoundStarted())
		to_chat(user, "Nope you can't do this, the game's already started. This only works before rounds!", confidential = TRUE)
		return

	if(SSticker.random_players)
		SSticker.random_players = 0
		message_admins("Admin [key_name_admin(user)] has disabled \"Everyone is Special\" mode.")
		to_chat(user, "Disabled.", confidential = TRUE)
		return

	var/notifyplayers = tgui_alert(user, "Do you want to notify the players?", "Options", list("Yes", "No", "Cancel"))
	if(notifyplayers == "Cancel")
		return

	log_and_message_admins("has forced the players to have random appearances.")

	if(notifyplayers == "Yes")
		to_chat(world, span_adminnotice("Admin [user.key] has forced the players to have completely random identities!"), confidential = TRUE)

	to_chat(user, "<i>Remember: you can always disable the randomness by using the verb again, assuming the round hasn't started yet</i>.", confidential = TRUE)

	SSticker.random_players = 1
	BLACKBOX_LOG_ADMIN_VERB("Make Everyone Random")

ADMIN_VERB(toggle_random_events, R_SERVER|R_EVENT, "Toggle Random Events", "Toggles random events on or off.", ADMIN_CATEGORY_TOGGLES)
	if(!CONFIG_GET(flag/allow_random_events))
		CONFIG_SET(flag/allow_random_events, TRUE)
		to_chat(user, "Random events enabled", confidential = TRUE)
		log_and_message_admins("has enabled random events.")
	else
		CONFIG_SET(flag/allow_random_events, FALSE)
		to_chat(user, "Random events disabled", confidential = TRUE)
		log_and_message_admins("has disabled random events.")
	BLACKBOX_LOG_ADMIN_VERB("Toggle Random Events")

ADMIN_VERB(reset_telecoms, R_ADMIN, "Reset NTTC Configuration", "Resets NTTC to the default configuration.", ADMIN_CATEGORY_GAME)
	var/confirm = tgui_alert(user, "You sure you want to reset NTTC?", "Confirm", list("Yes", "No"))
	if(confirm != "Yes")
		return

	for(var/obj/machinery/tcomms/core/C in GLOB.tcomms_machines)
		C.nttc.reset()

	log_admin("[key_name(user)] reset NTTC scripts.")
	message_admins("[key_name_admin(user)] reset NTTC scripts.")
	BLACKBOX_LOG_ADMIN_VERB("Reset NTTC Configuration")

ADMIN_VERB(list_ssds_afks, R_ADMIN, "List SSDs and AFKs", "List SSDs and AFK players", ADMIN_CATEGORY_GAME)
	/* ======== SSD Section ========= */
	var/msg = ""
	msg += "SSD Players:<br><table border='1'>"
	msg += "<tr><td><b>Key</b></td><td><b>Real Name</b></td><td><b>Job</b></td><td><b>Mins SSD</b></td><td><b>Special Role</b></td><td><b>Area</b></td><td><b>PPN</b></td><td><b>Cryo</b></td></tr>"
	var/mins_ssd
	var/job_string
	var/key_string
	var/role_string
	var/obj_count = 0
	var/obj_string = ""
	for(var/thing in GLOB.human_list)
		var/mob/living/carbon/human/H = thing
		if(!isLivingSSD(H))
			continue
		mins_ssd = round((world.time - H.last_logout) / 600)
		if(H.job)
			job_string = H.job
		else
			job_string = "-"
		key_string = H.key
		if(job_string in GLOB.command_positions)
			job_string = "<u>" + job_string + "</u>"
		role_string = "-"
		obj_count = 0
		obj_string = ""
		if(H.mind)
			if(H.mind.special_role)
				role_string = "<u>[H.mind.special_role]</u>"
			if(!H.key && H.mind.key)
				key_string = H.mind.key
			for(var/datum/objective/O in GLOB.all_objectives)
				if(O.target == H.mind)
					obj_count++
			if(obj_count > 0)
				obj_string = "<br><u>Obj Target</u>"
		msg += "<tr><td>[key_string]</td><td>[H.real_name]</td><td>[job_string]</td><td>[mins_ssd]</td><td>[role_string][obj_string]</td>"
		msg += "<td>[get_area(H)]</td><td>[ADMIN_PP(H,"PP")]</td>"
		if(istype(H.loc, /obj/machinery/cryopod))
			msg += "<td><a href='byond://?_src_=holder;cryossd=[H.UID()]'>De-Spawn</a></td>"
		else
			msg += "<td><a href='byond://?_src_=holder;cryossd=[H.UID()]'>Cryo</a></td>"
		msg += "</tr>"
	msg += "</table><br>"

	/* ======== AFK Section ========= */
	msg += "AFK Players:<br><table border='1'>"
	msg += "<tr><td><b>Key</b></td><td><b>Real Name</b></td><td><b>Job</b></td><td><b>Mins AFK</b></td><td><b>Special Role</b></td><td><b>Area</b></td><td><b>PPN</b></td><td><b>Cryo</b></td></tr>"
	var/mins_afk
	for(var/thing in GLOB.human_list)
		var/mob/living/carbon/human/H = thing
		if(H.client == null || H.stat == DEAD) // No clientless or dead
			continue
		mins_afk = round(H.client.inactivity / 600)
		if(mins_afk < CONFIG_GET(number/list_afk_minimum))
			continue
		if(H.job)
			job_string = H.job
		else
			job_string = "-"
		key_string = H.key
		if(job_string in GLOB.command_positions)
			job_string = "<u>" + job_string + "</u>"
		role_string = "-"
		obj_count = 0
		obj_string = ""
		if(H.mind)
			if(H.mind.special_role)
				role_string = "<u>[H.mind.special_role]</u>"
			if(!H.key && H.mind.key)
				key_string = H.mind.key
			for(var/datum/objective/O in GLOB.all_objectives)
				if(O.target == H.mind)
					obj_count++
			if(obj_count > 0)
				obj_string = "<br><u>Obj Target</u>"
		msg += "<tr><td>[key_string]</td><td>[H.real_name]</td><td>[job_string]</td><td>[mins_afk]</td><td>[role_string][obj_string]</td>"
		msg += "<td>[get_area(H)]</td><td>[ADMIN_PP(H,"PP")]</td>"
		if(istype(H.loc, /obj/machinery/cryopod))
			msg += "<td><a href='byond://?_src_=holder;cryossd=[H.UID()];cryoafk=1'>De-Spawn</a></td>"
		else
			msg += "<td><a href='byond://?_src_=holder;cryossd=[H.UID()];cryoafk=1'>Cryo</a></td>"
		msg += "</tr>"
	msg += "</table>"
	var/datum/browser/popup = new(user, "player_ssd_afk_check", "SSD & AFK Report", 600, 300)
	popup.set_content(msg)
	popup.open(FALSE)

ADMIN_VERB(toggle_ert_calling, R_EVENT, "Toggle ERT", "Toggle the station's ability to call a response team.", ADMIN_CATEGORY_TOGGLES)
	if(SSticker.mode.ert_disabled)
		SSticker.mode.ert_disabled = 0
		to_chat(user, span_notice("ERT has been <b>Enabled</b>."), confidential = TRUE)
		log_admin("Admin [key_name(user)] has enabled ERT calling.")
		log_and_message_admins("has enabled ERT calling.")
	else
		SSticker.mode.ert_disabled = 1
		to_chat(user, span_warning("ERT has been <b>Disabled</b>."), confidential = TRUE)
		log_admin("Admin [key_name(user)] has disabled ERT calling.")
		log_and_message_admins("has disabled ERT calling.")

ADMIN_VERB(show_tip, R_EVENT, "Show Tip", "Sends a tip to all players.", ADMIN_CATEGORY_FUN)
	var/input = tgui_input_text(user, "Please specify your tip that you want to send to the players.", "Tip", "", encode = FALSE, multiline = TRUE)
	if(!input)
		return

	if(!SSticker)
		return

	SSticker.selected_tip = input

	// If we've already tipped, then send it straight away.
	if(SSticker.tipped)
		SSticker.send_tip_of_the_round()

	message_admins("[key_name_admin(user)] sent a Tip of the round.")
	log_admin("[key_name(user)] sent \"[input]\" as the Tip of the Round.")
	BLACKBOX_LOG_ADMIN_VERB("Show Tip")

ADMIN_VERB(modify_goals, R_EVENT, "Modify Goals", "Modify the station goals for the shift.", ADMIN_CATEGORY_EVENTS)
	user.holder.modify_goals()

/datum/admins/proc/modify_goals()
	if(!SSticker || !SSticker.mode)
		to_chat(usr, span_warning("This verb can only be used if the round has started."), confidential = TRUE)
		return

	var/dat = ""
	for(var/datum/station_goal/S in SSticker.mode.station_goals)
		dat += "[S.name] - <a href='byond://?src=[S.UID()];announce=1'>Announce</a> | <a href='byond://?src=[S.UID()];remove=1'>Remove</a><br>"
	dat += "<br><a href='byond://?src=[UID()];add_station_goal=1'>Add New Goal</a>"
	var/datum/browser/popup = new(usr, "goals", "Modify Goals", 400, 400)
	popup.set_content(dat)
	popup.open(FALSE)

/// Allow admin to add or remove traits of datum
/datum/admins/proc/modify_traits(datum/D)
	if(!D)
		return

	var/add_or_remove = tgui_input_list(usr, "Remove/Add?", "Trait Remove/Add", list("Add", "Remove"))
	if(!add_or_remove)
		return
	var/list/availible_traits = list()

	switch(add_or_remove)
		if("Add")
			for(var/key in GLOB.traits_by_type)
				if(istype(D,key))
					availible_traits += GLOB.traits_by_type[key]
		if("Remove")
			if(!GLOB.global_trait_name_map)
				GLOB.global_trait_name_map = generate_global_trait_name_map()
			for(var/trait in D._status_traits)
				var/name = GLOB.global_trait_name_map[trait] || trait
				availible_traits[name] = trait

	var/chosen_trait = tgui_input_list(usr, "Select trait to modify", "Trait", availible_traits)
	if(!chosen_trait)
		return
	chosen_trait = availible_traits[chosen_trait]

	var/source = "adminabuse"
	switch(add_or_remove)
		if("Add") //Not doing source choosing here intentionally to make this bit faster to use, you can always vv it.
			ADD_TRAIT(D, chosen_trait, source)
		if("Remove")
			var/specific = tgui_input_list(usr, "All or specific source ?", "Trait Remove/Add", list("All","Specific"))
			if(!specific)
				return
			switch(specific)
				if("All")
					source = null
				if("Specific")
					source = tgui_input_list(usr, "Source to be removed", "Trait Remove/Add", D._status_traits[chosen_trait])
					if(!source)
						return
			REMOVE_TRAIT(D, chosen_trait, source)

ADMIN_VERB(change_command_name, R_EVENT, "Change Command Name", "Change the name of Central Command.", ADMIN_CATEGORY_EVENTS)
	var/input = tgui_input_text(user, "Введите имя для Центрального командования.", "Что?", "", encode = FALSE)
	if(!input)
		return
	change_command_name(input)
	log_and_message_admins("has changed Central Command's name to [input]")

ADMIN_VERB(polymorph_all, R_EVENT, "Polymorph All", "Applies the effects of the bolt of change to every single mob.", ADMIN_CATEGORY_FUN)
	var/confirm = tgui_alert(user, "Пожалуйста, подтвердите, что вы хотите полиморфировать всех?", "Подтверждение", list("Да", "Нет"))
	if(confirm != "Да")
		return

	var/keep_name = tgui_alert(user, "Вы хотите, чтобы существа сохранили свои имена?", "Сохранить имена?", list("Да", "Нет"))

	var/list/mobs = shuffle(GLOB.alive_player_list.Copy()) // might change while iterating
	var/who_did_it = key_name_admin(user)

	log_and_message_admins("polymorphed ALL living mobs.")
	BLACKBOX_LOG_ADMIN_VERB("Polymorph All")

	for(var/mob/living/selected_mob in mobs)
		CHECK_TICK

		if(!selected_mob || !selected_mob.name || !selected_mob.real_name)
			continue

		selected_mob.audible_message(span_hear("...ваббаджек...ваббаджек..."))
		playsound(selected_mob.loc, 'sound/magic/Staff_Change.ogg', 50, TRUE, -1)
		var/name = selected_mob.name
		var/real_name = selected_mob.real_name

		var/mob/living/new_mob = wabbajack(selected_mob)
		if(keep_name == "Да" && new_mob)
			new_mob.name = name
			new_mob.real_name = real_name

	message_admins("Mass polymorph started by [who_did_it] is complete.")
