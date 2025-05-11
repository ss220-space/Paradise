/client/proc/cmd_admin_drop_everything(mob/M as mob in GLOB.mob_list)
	set name = "Drop Everything"

	if(!check_rights(R_DEBUG|R_ADMIN))
		return

	var/confirm = tgui_alert(src, "Make [M] drop everything?", "Message", list("Yes", "No"))
	if(confirm != "Yes")
		return

	for(var/obj/item/W in M)
		M.drop_item_ground(W)

	log_and_message_admins("made [key_name_admin(M)] drop everything!")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Drop Everything") //If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!

/client/proc/cmd_admin_prison(mob/M as mob in GLOB.mob_list)
	set category = "Admin.Fun"
	set name = "Prison"

	if(!check_rights(R_ADMIN))
		return

	if(ismob(M))
		if(istype(M, /mob/living/silicon/ai))
			tgui_alert(usr, "The AI can't be sent to prison you jerk!")
			return

		var/turf/prison_cell = pick(GLOB.prisonwarp)

		if(!prison_cell)
			return

		var/obj/structure/closet/supplypod/centcompod/prison_warp/pod = new()
		pod.reverse_dropoff_coords = list(prison_cell.x, prison_cell.y, prison_cell.z)
		pod.target = M
		new /obj/effect/pod_landingzone(M, pod)

		log_and_message_admins("<span class='notice'>sent [key_name_admin(M)] to the prison station.</span>")
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Prison") //If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!

/client/proc/cmd_admin_subtle_message(mob/M as mob in GLOB.mob_list)
	set name = "\[Admin\] Subtle Message"

	if(!ismob(M))
		return

	if(!check_rights(R_EVENT))
		return

	var/msg = tgui_input_text(src, "Message:", text("Subtle PM to [M.key]"), multiline = TRUE, encode = FALSE)

	if(!msg)
		return

	msg = admin_pencode_to_html(msg)

	if(usr)
		if(usr.client)
			if(usr.client.holder)
				to_chat(M, "<b>You hear a voice in your head... <i>[msg]</i></b>")

	log_and_message_admins("<span class='boldnotice'>sent subtle message to [key_name_admin(M)] : [msg]</span>")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Subtle Message") //If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!

/client/proc/cmd_mentor_check_new_players()	//Allows mentors / admins to determine who the newer players are.
	set category = "Admin.Admin"
	set name = "Check new Players"

	if(!check_rights(R_MENTOR|R_MOD|R_ADMIN))
		return

	var/age = tgui_alert(src, "Age check", "Show accounts yonger then _____ days", list("7", "30" , "All"))

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
			if(check_rights(R_ADMIN, 0))
				msg += "[key_name_admin(C.mob)]: [C.player_age] days old<br>"
			else
				msg += "[key_name_mentor(C.mob)]: [C.player_age] days old<br>"

	if(missing_ages)
		to_chat(src, "Some accounts did not have proper ages set in their clients.  This function requires database to be present", confidential=TRUE)

	if(msg != "")
		var/datum/browser/popup = new(src, "player_age_check", "Player Age Check")
		popup.set_content(msg)
		popup.open(FALSE)
		
	else
		to_chat(src, "No matches for that age range found.", confidential=TRUE)


/client/proc/cmd_admin_world_narrate() // Allows administrators to fluff events a little easier -- TLE
	set category = "Admin.Event"
	set name = "Global Narrate"

	if(!check_rights(R_SERVER|R_EVENT))
		return

	var/msg = tgui_input_text(usr, "Message:", "Enter the text you wish to appear to everyone:")

	if(!msg)
		return
	msg = admin_pencode_to_html(msg)
	to_chat(world, msg)
	log_and_message_admins("<span class='boldnotice'>Sent Global Narrate: [msg]<br></span>")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Global Narrate") //If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!

/client/proc/cmd_admin_local_narrate(var/atom/A)
	set category = "Admin.Event"
	set name = "Local Narrate"

	if(!check_rights(R_SERVER|R_EVENT))
		return
	if(!A)
		return
	var/msg = tgui_input_text(usr, "Message:", "Enter the text you wish to appear to everyone within view:")
	if (!msg)
		return
	msg = admin_pencode_to_html(msg)
	for(var/mob/living/M in view(7,A))
		to_chat(M, msg)
	log_and_message_admins("<span class='boldnotice'>local narrated at [AREACOORD(A)]: [msg]<br></span>")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Local Narrate") //If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!

/client/proc/cmd_admin_direct_narrate(var/mob/M)	// Targetted narrate -- TLE
	if(!check_rights(R_SERVER|R_EVENT))
		return

	if(!M)
		M = tgui_input_list(usr, "Direct narrate to who?", "Active Players", get_mob_with_client_list())

	if(!M)
		return

	var/msg = tgui_input_text(usr, "Message:", "Enter the text you wish to appear to your target:")
	if(!msg)
		return
	msg = admin_pencode_to_html(msg)
	to_chat(M, msg)
	log_and_message_admins("<span class='boldnotice'>directly narrated to [key_name_admin(M)]: [msg]<br></span>")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Direct Narrate") //If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!




/client/proc/cmd_admin_headset_message(mob/M in GLOB.mob_list)
	set name = "\[Admin\] Headset Message"

	admin_headset_message(M)

/client/proc/admin_headset_message(mob/M in GLOB.mob_list, sender = null)
	var/mob/living/carbon/human/H = M

	if(!check_rights(R_EVENT))
		return

	if(!istype(H))
		to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human", confidential=TRUE)
		return
	if(!istype(H.l_ear, /obj/item/radio/headset) && !istype(H.r_ear, /obj/item/radio/headset))
		to_chat(usr, "The person you are trying to contact is not wearing a headset", confidential=TRUE)
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
	to_chat(H, "<span class = 'specialnoticebold'>Incoming priority transmission from [sender == "Syndicate" ? "your benefactor" : "Central Command"].  Message as follows[sender == "Syndicate" ? ", agent." : ":"]</span><span class = 'specialnotice'> [input]</span>")




/client/proc/cmd_admin_godmode(mob/mob as mob in GLOB.mob_list)
	set category = "Admin.Fun"
	set name = "Godmode"

	if(!check_rights(R_ADMIN))
		return

	var/had_trait = HAS_TRAIT_FROM(mob, TRAIT_GODMODE, ADMIN_TRAIT)
	if(had_trait)
		REMOVE_TRAIT(mob, TRAIT_GODMODE, ADMIN_TRAIT)
	else
		ADD_TRAIT(mob, TRAIT_GODMODE, ADMIN_TRAIT)

	to_chat(usr, span_notice("Toggled [had_trait ? "OFF" : "ON"]"), confidential=TRUE)
	log_and_message_admins("has toggled [key_name_admin(mob)]'s nodamage to [had_trait ? "Off" : "On"]")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Godmode") //If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!


/proc/cmd_admin_mute(mob/M as mob, mute_type, automute = 0)
	if(automute)
		if(!CONFIG_GET(flag/automute_on))
			return
	else
		if(!usr || !usr.client)
			return
		if(!check_rights(R_ADMIN|R_MOD))
			to_chat(usr, "<span style='color: red;'>Error: cmd_admin_mute: You don't have permission to do this.</span>", confidential=TRUE)
			return
		if(!M.client)
			to_chat(usr, "<span style='color: red;'>Error: cmd_admin_mute: This mob doesn't have a client tied to it.</span>", confidential=TRUE)
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
		to_chat(M, "You have been [muteunmute] from [mute_string] by the SPAM AUTOMUTE system. Contact an admin.", confidential=TRUE)
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Automute") //If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!
		return

	toggle_mute(M.client.ckey, mute_type)

	if(check_mute(M.client.ckey, mute_type))
		muteunmute = "muted"
	else
		muteunmute = "unmuted"

	log_and_message_admins("has [muteunmute] [key_name_admin(M)] from [mute_string].")
	to_chat(M, "You have been [muteunmute] from [mute_string].", confidential=TRUE)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Mute") //If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!

/client/proc/cmd_admin_add_random_ai_law()
	set category = "Admin.Fun"
	set name = "Add Random AI Law"

	if(!check_rights(R_EVENT))
		return

	var/confirm = tgui_alert(src, "You sure?", "Confirm", list("Yes", "No"))
	if(confirm != "Yes") return
	log_admin("[key_name(src)] has added a random AI law.")
	message_admins("[key_name_admin(src)] has added a random AI law.")

	var/show_log = tgui_alert(src, "Show ion message?", "Message", list("Yes", "No"))
	var/announce_ion_laws = (show_log == "Yes" ? 1 : -1)

	var/datum/event_meta/meta_info = new(EVENT_LEVEL_MAJOR, "Admin ([key_name(src)]) added random law.", /datum/event/ion_storm)
	new /datum/event/ion_storm(EM = meta_info, botEmagChance = 0, announceEvent = announce_ion_laws)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Add Random AI Law") //If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!

/client/proc/toggle_antagHUD_use()
	set category = "Admin.Toggles"
	set name = "Toggle antagHUD usage"
	set desc = "Toggles antagHUD usage for observers"

	if(!check_rights(R_SERVER))
		return

	var/action=""
	if(CONFIG_GET(flag/allow_antag_hud))
		for(var/mob/dead/observer/g in get_ghosts())
			if(g.antagHUD)
				g.antagHUD = FALSE						// Disable it on those that have it enabled
				g.has_enabled_antagHUD = FALSE				// We'll allow them to respawn
				to_chat(g, "<span class='danger'>The Administrator has disabled AntagHUD.</span>")

		CONFIG_SET(flag/allow_antag_hud, FALSE)
		to_chat(src, "<span class='danger'>AntagHUD usage has been disabled.</span>", confidential=TRUE)
		action = "disabled"
	else
		for(var/mob/dead/observer/g in get_ghosts())
			if(!g.client.holder)						// Add the verb back for all non-admin ghosts
				to_chat(g, "<span class='boldnotice'>The Administrator has enabled AntagHUD.</span>")// Notify all observers they can now use AntagHUD

		CONFIG_SET(flag/allow_antag_hud, TRUE)
		action = "enabled"
		to_chat(src, "<span class='boldnotice'>AntagHUD usage has been enabled.</span>", confidential=TRUE)


	log_and_message_admins("has [action] antagHUD usage for observers")

/client/proc/toggle_antagHUD_restrictions()
	set category = "Admin.Toggles"
	set name = "Toggle antagHUD Restrictions"
	set desc = "Restricts players that have used antagHUD from being able to join this round."

	if(!check_rights(R_SERVER))
		return

	var/action=""
	if(CONFIG_GET(flag/antag_hud_restricted))
		for(var/mob/dead/observer/g in get_ghosts())
			to_chat(g, "<span class='boldnotice'>The administrator has lifted restrictions on joining the round if you use AntagHUD.</span>")
		action = "lifted restrictions"
		CONFIG_SET(flag/antag_hud_restricted, FALSE)
		to_chat(src, "<span class='boldnotice'>AntagHUD restrictions have been lifted.</span>", confidential=TRUE)
	else
		for(var/mob/dead/observer/g in get_ghosts())
			to_chat(g, "<span class='danger'>The administrator has placed restrictions on joining the round if you use AntagHUD.</span>")
			to_chat(g, "<span class='danger'>Your AntagHUD has been disabled, you may choose to re-enabled it but will be under restrictions.</span>")
			g.antagHUD = FALSE
			g.has_enabled_antagHUD = FALSE
		action = "placed restrictions"
		CONFIG_SET(flag/antag_hud_restricted, TRUE)
		to_chat(src, "<span class='danger'>AntagHUD restrictions have been enabled.</span>", confidential=TRUE)

	log_and_message_admins("has [action] on joining the round if they use AntagHUD")

/*
If a guy was gibbed and you want to revive him, this is a good way to do so.
Works kind of like entering the game with a new character. Character receives a new mind if they didn't have one.
Traitors and the like can also be revived with the previous role mostly intact.
/N */
/client/proc/respawn_character()
	set category = "Admin.Event"
	set name = "Respawn Character"
	set desc = "Respawn a person that has been gibbed/dusted/killed. They must be a ghost for this to work and preferably should not have a body to go back into."

	if(!check_rights(R_SPAWN))
		return

	var/input = ckey(tgui_input_text(src, "Please specify which key will be respawned.", "Key", "", encode = FALSE))
	if(!input)
		return

	var/mob/dead/observer/G_found
	for(var/mob/dead/observer/G in GLOB.player_list)
		if(G.ckey == input)
			G_found = G
			break

	if(!G_found)//If a ghost was not found.
		to_chat(usr, "<span style='color: red;'>There is no active key like that in the game or the person is not currently a ghost.</span>", confidential=TRUE)
		return

	if(G_found.mind && !G_found.mind.active)	//mind isn't currently in use by someone/something
		//Check if they were an alien
		if(G_found.mind.assigned_role=="Alien")
			if(tgui_alert(usr, "This character appears to have been an alien. Would you like to respawn them as such?",, list("Yes", "No")) == "Yes")
				var/turf/T
				if(GLOB.xeno_spawn.len)	T = pick(GLOB.xeno_spawn)
				else				T = pick(GLOB.latejoin)

				var/mob/living/carbon/alien/new_xeno
				switch(G_found.mind.special_role)//If they have a mind, we can determine which caste they were.
					if("Hunter")	new_xeno = new /mob/living/carbon/alien/humanoid/hunter(T)
					if("Sentinel")	new_xeno = new /mob/living/carbon/alien/humanoid/sentinel(T)
					if("Drone")		new_xeno = new /mob/living/carbon/alien/humanoid/drone(T)
					if("Queen")		new_xeno = new /mob/living/carbon/alien/humanoid/queen(T)
					else//If we don't know what special role they have, for whatever reason, or they're a larva.
						create_xeno(G_found.ckey)
						return

				//Now to give them their mind back.
				G_found.mind.transfer_to(new_xeno)	//be careful when doing stuff like this! I've already checked the mind isn't in use
				new_xeno.key = G_found.key
				to_chat(new_xeno, "You have been fully respawned. Enjoy the game.")
				log_and_message_admins("<span class='notice'>has respawned [new_xeno.key] as a filthy xeno.</span>")
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

	new_character.key = G_found.key

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
			var/obj/effect/landmark/synd_spawn = locate("landmark*Syndicate-Spawn")
			if(synd_spawn)
				new_character.forceMove(get_turf(synd_spawn))
			call(/datum/game_mode/proc/equip_syndicate)(new_character)

		if("Death Commando")//Leaves them at late-join spawn.
			new_character.equipOutfit(/datum/outfit/admin/death_commando)
			new_character.update_action_buttons_icon()
		else//They may also be a cyborg or AI.
			switch(new_character.mind.assigned_role)
				if(JOB_TITLE_CYBORG)//More rigging to make em' work and check if they're traitor.
					new_character = new_character.Robotize()
					if(new_character.mind.special_role=="traitor")
						new_character.mind.add_antag_datum(/datum/antagonist/traitor)
					SSticker?.score?.save_silicon_laws(new_character, src.mob, additional_info = "admin respawn", log_all_laws = TRUE)
				if(JOB_TITLE_AI)
					new_character = new_character.AIize()
					var/mob/living/silicon/ai/ai_character = new_character
					ai_character.moveToAILandmark()
					if(new_character.mind.special_role=="traitor")
						new_character.mind.add_antag_datum(/datum/antagonist/traitor)
					SSticker?.score?.save_silicon_laws(ai_character, src.mob, additional_info = "admin respawn", log_all_laws = TRUE)
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

	log_and_message_admins("<span class='notice'>has respawned [key_name_admin(G_found)] as [new_character.real_name].</span>")

	to_chat(new_character, "You have been fully respawned. Enjoy the game.")

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Respawn Character") //If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!
	return new_character

//I use this proc for respawn character too. /N
/proc/create_xeno(ckey)
	if(!ckey)
		var/list/candidates = list()
		for(var/mob/M in GLOB.player_list)
			if(M.stat != DEAD)		continue	//we are not dead!
			if(!(ROLE_ALIEN in M.client.prefs.be_special))	continue	//we don't want to be an alium
			if(jobban_isbanned(M, "alien") || jobban_isbanned(M, "Syndicate")) continue //we are jobbanned
			if(M.client.is_afk())	continue	//we are afk
			if(M.mind && M.mind.current && M.mind.current.stat != DEAD)	continue	//we have a live body we are tied to
			candidates += M.ckey
		if(candidates.len)
			ckey = tgui_input_list(usr, "Pick the player you want to respawn as a xeno.", "Suitable Candidates", candidates)
		else
			to_chat(usr, "<span style='color: red;'>Error: create_xeno(): no suitable candidates.</span>", confidential=TRUE)
	if(!istext(ckey))	return 0

	var/alien_caste = input(usr, "Please choose which caste to spawn.","Pick a caste",null) as null|anything in list("Queen","Hunter","Sentinel","Drone","Larva")
	var/obj/effect/landmark/spawn_here = GLOB.xeno_spawn.len ? pick(GLOB.xeno_spawn) : pick(GLOB.latejoin)
	var/mob/living/carbon/alien/new_xeno
	switch(alien_caste)
		if("Queen")		new_xeno = new /mob/living/carbon/alien/humanoid/queen/large(spawn_here)
		if("Hunter")	new_xeno = new /mob/living/carbon/alien/humanoid/hunter(spawn_here)
		if("Sentinel")	new_xeno = new /mob/living/carbon/alien/humanoid/sentinel(spawn_here)
		if("Drone")		new_xeno = new /mob/living/carbon/alien/humanoid/drone(spawn_here)
		if("Larva")		new_xeno = new /mob/living/carbon/alien/larva(spawn_here)
		else			return 0

	new_xeno.ckey = ckey
	log_and_message_admins("<span class='notice'>has spawned [ckey] as a filthy xeno [alien_caste].</span>")
	return 1


/client/proc/get_ghosts(var/notify = 0,var/what = 2)
	// what = 1, return ghosts ass list.
	// what = 2, return mob list

	var/list/mobs = list()
	var/list/ghosts = list()
	var/list/sortmob = sortAtom(GLOB.mob_list)                           // get the mob list.
	var/any=0
	for(var/mob/dead/observer/M in sortmob)
		mobs.Add(M)                                             //filter it where it's only ghosts
		any = 1                                                 //if no ghosts show up, any will just be 0
	if(!any)
		if(notify)
			to_chat(src, "There doesn't appear to be any ghosts for you to select.", confidential=TRUE)
		return

	for(var/mob/M in mobs)
		var/name = M.name
		ghosts[name] = M                                        //get the name of the mob for the popup list
	if(what==1)
		return ghosts
	else
		return mobs

/client/proc/cmd_admin_add_freeform_ai_law()
	set category = "Admin.Event"
	set name = "Add Custom AI law"

	if(!check_rights(R_EVENT))
		return

	var/input = tgui_input_text(usr, "Please enter anything you want the AI to do. Anything. Serious.", "What?", "", encode = FALSE)
	if(!input)
		return

	log_admin("Admin [key_name(usr)] has added a new AI law - [input]")
	message_admins("Admin [key_name_admin(usr)] has added a new AI law - [input]")

	var/show_log = tgui_alert(src, "Show ion message?", "Message", list("Yes", "No"))
	var/announce_ion_laws = (show_log == "Yes" ? 1 : -1)

	var/datum/event_meta/meta_info = new(EVENT_LEVEL_MAJOR, "Admin ([key_name(src)]) added freeform law.", /datum/event/ion_storm)
	new /datum/event/ion_storm(EM = meta_info, botEmagChance = 0, announceEvent = announce_ion_laws, ionMessage = input)

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Add Custom AI Law") //If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!

/client/proc/cmd_admin_rejuvenate(mob/living/M as mob in GLOB.mob_list)
	set name = "\[Admin\] Rejuvenate"

	if(!check_rights(R_REJUVINATE))
		return

	if(!mob)
		return
	if(!istype(M))
		tgui_alert(usr, "Cannot revive a ghost")
		return
	M.revive()

	log_and_message_admins("<span class='warning'>healed / revived [key_name_admin(M)]!</span>")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Rejuvenate") //If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!

/client/proc/cmd_admin_offer_control(mob/M as mob in GLOB.mob_list)
	set name = "\[Admin\] Offer control to ghosts"

	if(!check_rights(R_ADMIN))
		return

	if(!mob)
		return
	if(!istype(M))
		tgui_alert(src, "This can only be used on instances of type /mob")
		return
	offer_control(M)

/client/proc/cmd_admin_create_centcom_report()
	set category = "Admin.Admin"
	set name = "Create Communications Report"

	if(!check_rights(R_SERVER|R_EVENT))
		return

//the stuff on the list is |"report type" = "report title"|, if that makes any sense
	var/list/MsgType = list("Сообщение Центрального Командования" = "Обновление НаноТрейзен",
		"Официальное сообщение Синдиката" = "Сообщение Синдиката",
		"Сообщение Федерации Космических Волшебников" = "Заколдованное сообщение",
		"Официальное сообщение Клана Паука" = "Сообщение Клана Паука",
		"Вражеское Сообщение" = "Неизвестное сообщение",
		"Свой тип" = "Загадочное сообщение")

	var/list/MsgSound = list("Beep" = 'sound/misc/announce_dig.ogg',
		"Enemy Communications Intercepted" = 'sound/AI/intercept2.ogg',
		"New Command Report Created" = 'sound/AI/commandreport.ogg')

	var/type = tgui_input_list(usr, "Выберите тип сообщения для отправки.", "Тип сообщения", MsgType, "")

	if(type == "Свой тип")
		type = tgui_input_text(usr, "Введите тип сообщения.", "Тип сообщения", "Зашифрованная передача", encode = FALSE)

	var/customname = tgui_input_text(usr, "Введите заголовок сообщения.", "Заголовок", MsgType[type], encode = FALSE)
	if(!customname)
		return
	var/input = tgui_input_text(usr, "Введите всё, что хотите. Что угодно. Серьёзно.", "Какое сообщение?", multiline = TRUE, encode = FALSE)
	if(!input)
		return

	switch(tgui_alert(usr, "Должно ли это быть объявлено всем?",, list("Да","Нет", "Отмена")))
		if("Да")
			var/beepsound = tgui_input_list(usr, "Какой звук должен издавать анонс?", "Звук анонса", MsgSound)

			GLOB.command_announcement.Announce(input, customname, MsgSound[beepsound], , , type)
			print_command_report(input, customname)
		if("Нет")
			//same thing as the blob stuff - it's not public, so it's classified, dammit
			GLOB.event_announcement.Announce("Отчёт был загружен и распечатан на всех консолях связи.", "Входящее засекреченное сообщение.", 'sound/AI/commandreport.ogg', from = "[command_name()] обновление")
			print_command_report(input, "Секретно: [customname]")
		else
			return

	log_admin("[key_name(src)] has created a communications report: [input]")
	message_admins("[key_name_admin(src)] has created a communications report")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Create Comms Report") //If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!


/client/proc/cmd_admin_delete(atom/A as obj|mob|turf in view(maxview()))
	set name = "\[Admin\] Delete"

	if(!check_rights(R_ADMIN))
		return

	admin_delete(A)

/client/proc/admin_delete(datum/D)
	if(istype(D) && !D.can_vv_delete())
		to_chat(src, "[D] rejected your deletion", confidential=TRUE)
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

	if (tgui_alert(src, "Are you sure you want to delete:\n[D]\n[coords]?", "Confirmation", list("Yes", "No")) == "Yes")
		log_admin("[key_name(usr)] deleted [D] [coords]")
		message_admins("[key_name_admin(usr)] deleted [D] [jmp_coords]")
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Delete") //If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!
		if(isturf(D))
			var/turf/T = D
			T.ChangeTurf(T.baseturf)
		else
			vv_update_display(D, "deleted", VV_MSG_DELETED)
			qdel(D)
			if(!QDELETED(D))
				vv_update_display(D, "deleted", "")

/client/proc/cmd_admin_list_open_jobs()
	set category = "Admin.Admin"
	set name = "List free slots"

	if(!check_rights(R_ADMIN))
		return

	if(SSjobs)
		var/currentpositiontally
		var/totalpositiontally
		to_chat(src, "<span class='notice'>Job Name: Filled job slot / Total job slots <b>(Free job slots)</b></span>", confidential=TRUE)
		for(var/datum/job/job in SSjobs.occupations)
			to_chat(src, "<span class='notice'>[job.title]: [job.current_positions] / \
			[job.total_positions == -1 ? "<b>UNLIMITED</b>" : job.total_positions] \
			 <b>([job.total_positions == -1 ? "UNLIMITED" : job.total_positions - job.current_positions])</b></span>")
			if(job.total_positions != -1) // Only count position that isn't unlimited
				currentpositiontally += job.current_positions
				totalpositiontally += job.total_positions
		to_chat(src, "<b>Currently filled job slots (Excluding unlimited): [currentpositiontally] / [totalpositiontally] ([totalpositiontally - currentpositiontally])</b>", confidential=TRUE)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "List Free Slots") //If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!

/client/proc/cmd_admin_explosion(atom/O as obj|mob|turf in view(maxview()))
	set category = "Admin.Fun"
	set name = "Explosion"

	if(!check_rights(R_DEBUG|R_EVENT))
		return

	var/devastation = tgui_input_number(usr, "Range of total devastation. -1 to none", "Input")
	if(devastation == null) return
	var/heavy = tgui_input_number(usr, "Range of heavy impact. -1 to none", "Input")
	if(heavy == null) return
	var/light = tgui_input_number(usr, "Range of light impact. -1 to none", "Input")
	if(light == null) return
	var/flash = tgui_input_number(usr, "Range of flash. -1 to none", "Input")
	if(flash == null) return
	var/flames = tgui_input_number(usr, "Range of flames. -1 to none", "Input")
	if(flames == null) return

	if((devastation != -1) || (heavy != -1) || (light != -1) || (flash != -1) || (flames != -1))
		if((devastation > 20) || (heavy > 20) || (light > 20) || (flames > 20))
			if(tgui_alert(src, "Are you sure you want to do this? It will laaag.", "Confirmation", list("Yes", "No")) == "No")
				return

		explosion(O, devastation, heavy, light, flash, null, null,flames)
		log_and_message_admins("created an explosion ([devastation],[heavy],[light],[flames]) at [COORD(O)]")
		SSblackbox.record_feedback("tally", "admin_verb", 1, "EXPL") //If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!
		return
	else
		return

/client/proc/cmd_admin_emp(atom/O as obj|mob|turf in view(maxview()))
	set category = "Admin.Fun"
	set name = "EM Pulse"

	if(!check_rights(R_DEBUG|R_EVENT))
		return

	var/heavy = tgui_input_number(usr, "Range of heavy pulse.", "Input")
	if(heavy == null) return
	var/light = tgui_input_number(usr, "Range of light pulse.", "Input")
	if(light == null) return

	if(heavy || light)

		empulse(O, heavy, light)
		log_and_message_admins("created an EM pulse ([heavy], [light]) at [COORD(O)]")
		SSblackbox.record_feedback("tally", "admin_verb", 1, "EMP") //If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!

		return
	else
		return

/client/proc/cmd_admin_gib(mob/M as mob in GLOB.mob_list)
	set category = "Admin.Fun"
	set name = "Gib"

	if(!check_rights(R_ADMIN|R_EVENT))
		return

	var/confirm = tgui_alert(src, "You sure?", "Confirm", list("Yes", "No"))
	if(confirm != "Yes") return
	//Due to the delay here its easy for something to have happened to the mob
	if(!M)	return

	log_and_message_admins("has gibbed [key_name_admin(M)]")

	if(istype(M, /mob/dead/observer))
		gibs(M.loc)
		return

	M.gib()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Gib") //If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!

/client/proc/cmd_admin_gib_self()
	set name = "Gibself"
	set category = "Admin.Fun"

	if(!check_rights(R_ADMIN|R_EVENT))
		return

	var/confirm = tgui_alert(src, "You sure?", "Confirm", list("Yes", "No"))
	if(confirm == "Yes")
		if(istype(mob, /mob/dead/observer)) // so they don't spam gibs everywhere
			return
		else
			mob.gib()

		log_and_message_admins("<span class='notice'>used gibself.</span>")
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Gibself") //If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!

/client/proc/cmd_admin_check_contents(mob/living/M as mob in GLOB.mob_list)
	set name = "\[Admin\] Check Contents"

	if(!check_rights(R_ADMIN))
		return

	var/list/L = M.get_contents()
	for(var/atom/t in L)
		to_chat(usr, "[t] [ADMIN_VV(t,"VV")] ", confidential=TRUE)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Check Contents") //If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!


/client/proc/toggle_view_range()
	set category = "Admin.Toggles"
	set name = "Change View Range"
	set desc = "switches between 1x and custom views"

	if(!check_rights(R_ADMIN))
		return

	var/client_view = prefs.viewrange

	if(view == client_view)
		var/input = tgui_input_list(usr, "Select view range:", "View Range", list(1,2,3,4,5,6,7,8,9,10,11,12,13,14,"MAX"), 7)
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

		view = "[view_x]x[view_y]"

	else
		view = client_view

	fit_viewport()

	log_admin("[key_name(usr)] changed their view range to [view].")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Change View Range") //If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!


/client/proc/admin_call_shuttle()

	set category = "Admin.Admin"
	set name = "Call Shuttle"

	if(EMERGENCY_AT_LEAST_DOCKED)
		return

	if(!check_rights(R_ADMIN))
		return

	var/confirm = tgui_alert(src, "You sure?", "Confirm", list("Yes", "No"))
	if(confirm != "Yes") return

	if(tgui_alert(usr, "Set Shuttle Recallable (Select Yes unless you know what this does)", "Recallable?", list("Yes", "No")) == "Yes")
		SSshuttle.emergency.canRecall = TRUE
	else
		SSshuttle.emergency.canRecall = FALSE

	if(seclevel2num(get_security_level()) >= SEC_LEVEL_RED)
		SSshuttle.emergency.request(coefficient = 0.5, redAlert = TRUE)
	else
		SSshuttle.emergency.request()

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Call Shuttle") //If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!
	log_admin("[key_name(usr)] admin-called the emergency shuttle.")
	message_admins("<span class='adminnotice'>[key_name_admin(usr)] admin-called the emergency shuttle.</span>")
	return

/client/proc/admin_cancel_shuttle()
	set category = "Admin.Admin"
	set name = "Cancel Shuttle"

	if(!check_rights(R_ADMIN))
		return

	if(tgui_alert(src, "You sure?", "Confirm", list("Yes", "No")) != "Yes")
		return

	if(EMERGENCY_AT_LEAST_DOCKED)
		return

	if(SSshuttle.emergency.canRecall == FALSE)
		if(tgui_alert(usr, "Shuttle is currently set to be nonrecallable. Recalling may break things. Respect Recall Status?", "Override Recall Status?", list("Yes", "No")) == "Yes")
			return
		else
			var/keepStatus = tgui_alert(usr, "Maintain recall status on future shuttle calls?", "Maintain Status?", list("Yes", "No")) == "Yes" //Keeps or drops recallability
			SSshuttle.emergency.canRecall = TRUE // must be true for cancel proc to work
			SSshuttle.emergency.cancel()
			if(keepStatus)
				SSshuttle.emergency.canRecall = FALSE // restores original status
	else
		SSshuttle.emergency.cancel()

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Cancel Shuttle") //If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!
	log_admin("[key_name(usr)] admin-recalled the emergency shuttle.")
	message_admins("<span class='adminnotice'>[key_name_admin(usr)] admin-recalled the emergency shuttle.</span>")
	return

/client/proc/toggle_pacifism_gt()
	set name = "Toggle Pacifism After Greentext"
	set category = "Admin.Toggles"

	if(!check_rights(R_ADMIN))
		return

	if(SSticker.current_state == GAME_STATE_FINISHED)
		if(GLOB.pacifism_after_gt)
			if(tgui_alert(src, "Вы готовы убрать пацифизм у всех?",, list("Да", "Нет")) == "Нет")
				return
			GLOB.pacifism_after_gt = FALSE
			log_and_message_admins("removed pacifism from all mobs.")
		else
			if(tgui_alert(src, "Вы хотите вернуть пацифизм всем?",, list("Да", "Нет")) == "Нет")
				return
			GLOB.pacifism_after_gt = TRUE
			log_and_message_admins("added pacifism to all mobs.")

	else
		SSticker.toggle_pacifism = (SSticker.toggle_pacifism) ? FALSE : TRUE
		log_and_message_admins("toggled pacifism after greentext in [(SSticker.toggle_pacifism) ? "On" : "Off"].")

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Toggle Pacifism")

/client/proc/toogle_ghost_vision()
	set name = "Toggle Ghost Vision After Greentext"
	set category = "Admin.Toggles"

	if(!check_rights(R_ADMIN))
		return

	if(SSticker.current_state == GAME_STATE_FINISHED)
		if(!GLOB.observer_default_invisibility)
			if(tgui_alert(src, "Вы хотите выключить видимость призраков?",, list("Да", "Нет")) == "Нет")
				return
			set_observer_default_invisibility(INVISIBILITY_OBSERVER)
			log_and_message_admins("Ghosts are no longer visible.")
		else
			if(tgui_alert(src, "Вы хотите включить видимость призраков?",, list("Да", "Нет")) == "Нет")
				return
			set_observer_default_invisibility(0)
			log_and_message_admins("Ghosts are now visible.")
	else
		SSticker.toogle_gv = (SSticker.toogle_gv) ? FALSE : TRUE
		log_and_message_admins("toggled ghost vision after greentext in [(SSticker.toogle_gv) ? "On" : "Off"].")


/client/proc/everyone_random()
	set category = "Admin.Fun"
	set name = "Make Everyone Random"
	set desc = "Make everyone have a random appearance. You can only use this before rounds!"

	if(!check_rights(R_SERVER|R_EVENT))
		return

	if(SSticker && SSticker.mode)
		to_chat(usr, "Nope you can't do this, the game's already started. This only works before rounds!", confidential=TRUE)
		return

	if(SSticker.random_players)
		SSticker.random_players = 0
		message_admins("Admin [key_name_admin(usr)] has disabled \"Everyone is Special\" mode.")
		to_chat(usr, "Disabled.", confidential=TRUE)
		return


	var/notifyplayers = tgui_alert(src, "Do you want to notify the players?", "Options", list("Yes", "No", "Cancel"))
	if(notifyplayers == "Cancel")
		return

	log_and_message_admins("has forced the players to have random appearances.")

	if(notifyplayers == "Yes")
		to_chat(world, "<span class='notice'><b>Admin [usr.key] has forced the players to have completely random identities!</span>")

	to_chat(usr, "<i>Remember: you can always disable the randomness by using the verb again, assuming the round hasn't started yet</i>.", confidential=TRUE)

	SSticker.random_players = 1
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Make Everyone Random") //If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!

/client/proc/toggle_random_events()
	set category = "Admin.Toggles"
	set name = "Toggle random events on/off"

	set desc = "Toggles random events such as meteors, black holes, blob (but not space dust) on/off"
	if(!check_rights(R_SERVER|R_EVENT))
		return

	if(!CONFIG_GET(flag/allow_random_events))
		CONFIG_SET(flag/allow_random_events, TRUE)
		to_chat(usr, "Random events enabled", confidential=TRUE)
		log_and_message_admins("has enabled random events.")
	else
		CONFIG_SET(flag/allow_random_events, FALSE)
		to_chat(usr, "Random events disabled", confidential=TRUE)
		log_and_message_admins("has disabled random events.")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Toggle Random Events") //If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!

/client/proc/reset_all_tcs()
	set category = "Admin.Debug"
	set name = "Reset NTTC Configuration"
	set desc = "Resets NTTC to the default configuration."

	if(!check_rights(R_ADMIN))
		return

	var/confirm = tgui_alert(src, "You sure you want to reset NTTC?", "Confirm", list("Yes", "No"))
	if(confirm != "Yes")
		return

	for(var/obj/machinery/tcomms/core/C in GLOB.tcomms_machines)
		C.nttc.reset()

	log_admin("[key_name(usr)] reset NTTC scripts.")
	message_admins("[key_name_admin(usr)] reset NTTC scripts.")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Reset NTTC Configuration") //If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!

/client/proc/list_ssds_afks()
	set category = "Admin.Admin"
	set name = "List SSDs and AFKs"
	set desc = "Lists SSD and AFK players"

	if(!check_rights(R_ADMIN))
		return

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
	var/datum/browser/popup = new(src, "player_ssd_afk_check", "SSD & AFK Report", 600, 300)
	popup.set_content(msg)
	popup.open(FALSE)
	

/client/proc/toggle_ert_calling()
	set category = "Admin.Toggles"
	set name = "Toggle ERT"

	set desc = "Toggle the station's ability to call a response team."
	if(!check_rights(R_EVENT))
		return

	if(SSticker.mode.ert_disabled)
		SSticker.mode.ert_disabled = 0
		to_chat(usr, "<span class='notice'>ERT has been <b>Enabled</b>.</span>", confidential=TRUE)
		log_admin("Admin [key_name(src)] has enabled ERT calling.")
		log_and_message_admins("has enabled ERT calling.")
	else
		SSticker.mode.ert_disabled = 1
		to_chat(usr, "<span class='warning'>ERT has been <b>Disabled</b>.</span>", confidential=TRUE)
		log_admin("Admin [key_name(src)] has disabled ERT calling.")
		log_and_message_admins("has disabled ERT calling.")

/client/proc/show_tip()
	set category = "Admin.Fun"
	set name = "Show Custom Tip"
	set desc = "Sends a tip (that you specify) to all players. After all \
		you're the experienced player here."

	if(!check_rights(R_EVENT))
		return

	var/input = tgui_input_text(usr, "Please specify your tip that you want to send to the players.", "Tip", "", encode = FALSE, multiline = TRUE)
	if(!input)
		return

	if(!SSticker)
		return

	SSticker.selected_tip = input

	// If we've already tipped, then send it straight away.
	if(SSticker.tipped)
		SSticker.send_tip_of_the_round()

	message_admins("[key_name_admin(usr)] sent a Tip of the round.")
	log_admin("[key_name(usr)] sent \"[input]\" as the Tip of the Round.")

/client/proc/modify_goals()
	set category = "Admin.Event"
	set name = "Modify Station Goals"

	if(!check_rights(R_EVENT))
		return

	holder.modify_goals()

/datum/admins/proc/modify_goals()
	if(!SSticker || !SSticker.mode)
		to_chat(usr, "<span class='warning'>This verb can only be used if the round has started.</span>", confidential=TRUE)
		return

	var/dat = {"<!DOCTYPE html><meta charset="UTF-8">"}
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

/client/proc/cmd_change_command_name()
	set category = "Admin.Event"
	set name = "Change Command Name"

	if(!check_rights(R_ADMIN | R_EVENT))
		return

	var/input = tgui_input_text(usr, "Введите имя для Центрального Командования.", "Что?", "", encode = FALSE)
	if(!input)
		return
	change_command_name(input)
	log_and_message_admins("has changed Central Command's name to [input]")


/client/proc/polymorph_all()
	set category = "Admin.Event"
	set name = "Polymorph All"
	set desc = "Applies the effects of the bolt of change to every single mob."

	if(!holder)
		return

	var/confirm = tgui_alert(src, "Пожалуйста, подтвердите, что вы хотите полиморфировать всех?", "Подтверждение", list("Да", "Нет"))
	if(confirm != "Да")
		return

	var/keep_name = tgui_alert(src, "Вы хотите, чтобы существа сохранили свои имена?", "Сохранить имена?", list("Да", "Нет"))

	var/list/mobs = shuffle(GLOB.alive_player_list.Copy()) // might change while iterating

	log_and_message_admins("polymorphed ALL living mobs.")

	for(var/mob/living/M in mobs)
		CHECK_TICK

		if(!M || !M.name || !M.real_name)
			continue

		M.audible_message(span_italics("...ваббаджек...ваббаджек..."))
		playsound(M.loc, 'sound/magic/Staff_Change.ogg', 50, 1, -1)
		var/name = M.name
		var/real_name = M.real_name

		var/mob/living/new_mob = wabbajack(M)
		if(keep_name == "Да" && new_mob)
			new_mob.name = name
			new_mob.real_name = real_name


