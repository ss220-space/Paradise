//admin verb groups - They can overlap if you so wish. Only one of each verb will exist in the verbs list regardless
GLOBAL_LIST_INIT(admin_verbs_default, list(
	/client/proc/deadmin_self,			/*destroys our own admin datum so we can play as a regular player*/
	/client/proc/hide_verbs,			/*hides all our adminverbs*/
	/client/proc/cmd_mentor_check_new_players,
	/client/proc/cmd_mentor_check_player_exp, /* shows players by playtime */
))
GLOBAL_LIST_INIT(admin_verbs_admin, list(
	/client/proc/check_antagonists,		/*shows all antags*/
	/datum/admins/proc/show_player_panel,
	/client/proc/fax_panel,
	/client/proc/player_panel_new,		/*shows an interface for all players, with links to various panels*/
	/client/proc/invisimin,				/*allows our mob to go invisible/visible*/
	/datum/admins/proc/announce,		/*priority announce something to all clients.*/
	/client/proc/admin_ghost,			/*allows us to ghost/reenter body at will*/
	/client/proc/toggle_view_range,		/*changes how far we can see*/
	/client/proc/cmd_admin_pm_context,	/*right-click adminPM interface*/
	/client/proc/cmd_admin_pm_panel,	/*admin-pm list*/
	/client/proc/cmd_admin_pm_by_key_panel,	/*admin-pm list by key*/
	/client/proc/cmd_admin_delete,		/*delete an instance/object/mob/etc*/
	/client/proc/cmd_admin_offer_control,
	/client/proc/cmd_admin_check_contents,	/*displays the contents of an instance*/
	/client/proc/cmd_admin_open_logging_view,
	/client/proc/getserverlogs,			/*allows us to fetch server logs (diary) for other days*/
	/client/proc/Getmob,				/*teleports a mob to our location*/
	/client/proc/Getkey,				/*teleports a mob with a certain ckey to our location*/
	/client/proc/jumptomob,				/*allows us to jump to a specific mob*/
	/client/proc/jumptoturf,			/*allows us to jump to a specific turf*/
	/client/proc/jump_to,				/*Opens a menu for jumping to an Area, Mob, Key or Coordinate*/
	/client/proc/admin_call_shuttle,	/*allows us to call the emergency shuttle*/
	/client/proc/admin_cancel_shuttle,	/*allows us to cancel the emergency shuttle, sending it back to centcomm*/
	/client/proc/admin_deny_shuttle,	/*toggles availability of shuttle calling*/
	/client/proc/check_ai_laws,			/*shows AI and borg laws*/
	/client/proc/manage_silicon_laws,	/* Allows viewing and editing silicon laws. */
	/client/proc/open_borgopanel,		/* Opens Cyborg Panel to change anything in it */
	/client/proc/admin_memo,			/*admin memo system. show/delete/write. +SERVER needed to delete admin memos of others*/
	/client/proc/dsay,					/*talk in deadchat using our ckey/fakekey*/
	/client/proc/investigate_show,		/*various admintools for investigation. Such as a singulo grief-log*/
	/datum/admins/proc/toggleooc,		/*toggles ooc on/off for everyone*/
	/datum/admins/proc/togglelooc,		/*toggles looc on/off for everyone*/
	/datum/admins/proc/toggleoocdead,	/*toggles ooc on/off for everyone who is dead*/
	/datum/admins/proc/togglevotedead,	/*toggles vote on/off for everyone who is dead*/
	/datum/admins/proc/toggledsay,		/*toggles dsay on/off for everyone*/
	/datum/admins/proc/toggleemoji,     /*toggles using emoji in ooc for everyone*/
	/client/proc/game_panel,			/*game panel, allows to change game-mode etc*/
	/client/proc/cmd_admin_say,			/*admin-only ooc chat*/
	/datum/admins/proc/PlayerNotes,
	/client/proc/cmd_mentor_say,
	/datum/admins/proc/show_player_notes,
	/client/proc/free_slot,			/*frees slot for chosen job*/
	/client/proc/global_man_up,
	/client/proc/delbook,
	/client/proc/view_flagged_books,
	/client/proc/view_asays,
	/client/proc/empty_ai_core_toggle_latejoin,
	/client/proc/aooc,
	/client/proc/freeze,
	/client/proc/debug_variables,
	/client/proc/reset_all_tcs,			/*resets all telecomms scripts*/
	/client/proc/toggle_mentor_chat,
	/client/proc/toggle_advanced_interaction, /*toggle admin ability to interact with not only machines, but also atoms such as buttons and doors*/
	/client/proc/start_vote,
	/client/proc/list_ssds_afks,
	/client/proc/ccbdb_lookup_ckey,
	/client/proc/toggle_pacifism_gt,
	/client/proc/toogle_ghost_vision,
	/client/proc/admin_change_title_screen,
	/client/proc/change_title_screen_notice,
	/client/proc/debugstatpanel,
	/client/proc/openAdminTicketUI,
	/client/proc/openMentorTicketUI,
	/client/proc/resolveAllAdminTickets,
	/client/proc/resolveAllMentorTickets,
))
GLOBAL_LIST_INIT(admin_verbs_ban, list(
	/client/proc/ban_panel,
	/client/proc/stickybanpanel,
	/datum/admins/proc/vpn_whitelist,
))
GLOBAL_LIST_INIT(admin_verbs_sounds, list(
	/client/proc/play_local_sound,
	/client/proc/play_sound,
	/client/proc/play_server_sound,
	/client/proc/play_intercomm_sound,
	/client/proc/stop_global_admin_sounds,
	/client/proc/play_web_sound,
))
GLOBAL_LIST_INIT(admin_verbs_event, list(
	/client/proc/secrets,
	/client/proc/object_talk,
	/client/proc/cmd_admin_dress,
	/client/proc/cmd_admin_gib_self,
	/client/proc/drop_bomb,
	/client/proc/cinematic,
	/client/proc/one_click_antag,
	/client/proc/cmd_admin_add_freeform_ai_law,
	/client/proc/cmd_admin_add_random_ai_law,
	/client/proc/make_sound,
	/client/proc/toggle_random_events,
	/client/proc/toggle_random_events,
	/client/proc/toggle_ert_calling,
	/client/proc/show_tip,
	/client/proc/cmd_admin_change_custom_event,
	/client/proc/cmd_admin_subtle_message,	/*send an message to somebody as a 'voice in their head'*/
	/client/proc/cmd_admin_world_narrate,	/*sends text to all players with no padding*/
	/client/proc/response_team, // Response Teams admin verb
	/client/proc/cmd_admin_create_centcom_report,
	/client/proc/event_manager_panel,
	/client/proc/modify_goals,
	/client/proc/outfit_manager,
	/client/proc/cmd_admin_headset_message,
	/client/proc/force_hijack,
	/client/proc/requests,
))
GLOBAL_LIST_INIT(admin_verbs_spawn, list(
	/datum/admins/proc/spawn_atom,		/*allows us to spawn instances*/
	/client/proc/respawn_character,
	/client/proc/admin_deserialize,
))
GLOBAL_LIST_INIT(admin_verbs_server, list(
	/client/proc/reload_admins,
	/client/proc/Set_Holiday,
	/datum/admins/proc/startnow,
	/datum/admins/proc/restart,
	/datum/admins/proc/end_round,
	/datum/admins/proc/delay,
	/datum/admins/proc/toggleaban,
	/datum/admins/proc/toggleenter,		/*toggles whether people can join the current game*/
	/datum/admins/proc/toggleguests,	/*toggles whether guests can join the current game*/
	/client/proc/select_next_map,
	/client/proc/toggle_log_hrefs,
	/client/proc/toggle_twitch_censor,
	/client/proc/everyone_random,
	/datum/admins/proc/toggleAI,
	/client/proc/cmd_admin_delete,		/*delete an instance/object/mob/etc*/
	/client/proc/cmd_debug_del_sing,
	/client/proc/delbook,
	/client/proc/view_flagged_books,
	/client/proc/view_asays,
	/client/proc/toggle_antagHUD_use,
	/client/proc/toggle_antagHUD_restrictions,
))
GLOBAL_LIST_INIT(admin_verbs_debug, list(
	/client/proc/cmd_admin_list_open_jobs,
	/client/proc/Debug2,
	/client/proc/cmd_debug_make_powernets,
	/client/proc/debug_controller,
	/client/proc/cmd_debug_mob_lists,
	/client/proc/cmd_admin_delete,
	/client/proc/cmd_debug_del_sing,
	/client/proc/restart_controller,
	/client/proc/enable_debug_verbs,
	/client/proc/cmd_display_del_log,
	/client/proc/cmd_display_del_log_simple,
	/client/proc/debugNatureMapGenerator,
	/client/proc/check_bomb_impacts,
	/client/proc/test_movable_UI,
	/client/proc/test_snap_UI,
	/proc/machine_upgrade,
	/client/proc/map_template_load,
	/client/proc/map_template_upload,
	/client/proc/view_runtimes,
	/client/proc/admin_serialize,
	/client/proc/jump_to_ruin,
	/client/proc/toggle_medal_disable,
	/client/proc/uid_log,
	/client/proc/visualise_active_turfs,
	/client/proc/reestablish_db_connection,
	/client/proc/ss_breakdown,
	/client/proc/dmjit_debug_toggle_call_counts,
	/client/proc/dmjit_debug_dump_call_count,
	/client/proc/dmjit_debug_dump_opcode_count,
	/client/proc/dmjit_debug_toggle_hooks,
	/client/proc/dmjit_debug_dump_deopts,
	/client/proc/timer_log,
	/client/proc/debug_timers,
	/client/proc/force_verb_bypass,
	/client/proc/reregister_docks,
	/client/proc/cmd_display_overlay_log,
	/client/proc/toggle_mobs_suspension,
	/client/proc/toggle_Idlenpcpool_suspension,
	/client/proc/toggle_npcpool_suspension,
	/client/proc/debug_atom_init,
	/client/proc/debugstatpanel,
	/client/proc/allow_browser_inspect, // XSS prevention
	/client/proc/change_title_screen_html
))
GLOBAL_LIST_INIT(admin_verbs_possess, list(
	/proc/possess,
	/proc/release,
))
GLOBAL_LIST_INIT(admin_verbs_permissions, list(
	/client/proc/edit_admin_permissions,
	/client/proc/big_brother,
))
GLOBAL_LIST_INIT(admin_verbs_rejuv, list(
	/client/proc/respawn_character,
	/client/proc/cmd_admin_rejuvenate,
))
GLOBAL_LIST_INIT(admin_verbs_mod, list(
	/client/proc/cmd_admin_pm_context,	/*right-click adminPM interface*/
	/client/proc/cmd_admin_pm_panel,	/*admin-pm list*/
	/client/proc/cmd_admin_pm_by_key_panel,	/*admin-pm list by key*/
	/datum/admins/proc/PlayerNotes,
	/client/proc/admin_ghost,			/*allows us to ghost/reenter body at will*/
	/client/proc/cmd_mentor_say,
	/datum/admins/proc/show_player_notes,
	/client/proc/player_panel_new,
	/client/proc/dsay,
	/datum/admins/proc/show_player_panel,
	/client/proc/ban_panel,
	/client/proc/debug_variables,		/*allows us to -see- the variables of any instance in the game. +VAREDIT needed to modify*/
	/client/proc/openAdminTicketUI,
))
GLOBAL_LIST_INIT(admin_verbs_mentor, list(
	/client/proc/cmd_admin_pm_context,	/*right-click adminPM interface*/
	/client/proc/cmd_admin_pm_panel,	/*admin-pm list*/
	/client/proc/cmd_admin_pm_by_key_panel,	/*admin-pm list by key*/
	/client/proc/openMentorTicketUI,
	/client/proc/cmd_mentor_say,	/* mentor say*/
	// cmd_mentor_say is added/removed by the toggle_mentor_chat verb
))
GLOBAL_LIST_INIT(admin_verbs_proccall, list(
	/client/proc/callproc,
	/client/proc/callproc_datum,
	/client/proc/SDQL2_query,
))
GLOBAL_LIST_INIT(view_runtimes_verbs, list(
	/client/proc/view_runtimes,
	/client/proc/ss_breakdown,
	/client/proc/debug_variables,
))

/client/proc/add_admin_verbs()
	if(holder)
		// If they have ANYTHING OTHER THAN ONLY VIEW RUNTIMES (65536), then give them the default admin verbs
		if(holder.rights != R_VIEWRUNTIMES)
			add_verb(src, GLOB.admin_verbs_default)
		if(holder.rights & R_BUILDMODE)
			add_verb(src, /client/proc/togglebuildmodeself)
		if(holder.rights & R_ADMIN)
			add_verb(src, GLOB.admin_verbs_admin)
			spawn(1)
				control_freak = 0
		if(holder.rights & R_BAN)
			add_verb(src, GLOB.admin_verbs_ban)
		if(holder.rights & R_EVENT)
			add_verb(src, GLOB.admin_verbs_event)
		if(holder.rights & R_SERVER)
			add_verb(src, GLOB.admin_verbs_server)
		if(holder.rights & R_DEBUG)
			add_verb(src, GLOB.admin_verbs_debug)
			spawn(1)
				control_freak = 0 // Setting control_freak to 0 allows you to use the Profiler and other client-side tools
		if(holder.rights & R_POSSESS)
			add_verb(src, GLOB.admin_verbs_possess)
		if(holder.rights & R_PERMISSIONS)
			add_verb(src, GLOB.admin_verbs_permissions)
		if(holder.rights & R_STEALTH)
			add_verb(src, /client/proc/stealth)
		if(holder.rights & R_REJUVINATE)
			add_verb(src, GLOB.admin_verbs_rejuv)
		if(holder.rights & R_SOUNDS)
			add_verb(src, GLOB.admin_verbs_sounds)
		if(holder.rights & R_SPAWN)
			add_verb(src, GLOB.admin_verbs_spawn)
		if(holder.rights & R_MOD)
			add_verb(src, GLOB.admin_verbs_mod)
		if(holder.rights & R_MENTOR)
			add_verb(src, GLOB.admin_verbs_mentor)
		if(holder.rights & R_PROCCALL)
			add_verb(src, GLOB.admin_verbs_proccall)
		if(holder.rights == R_HOST)
			add_verb(src, /client/proc/view_pingstat)
			add_verb(src, /client/proc/profiler_start)
			add_verb(src, /client/proc/profiler_stop)
		if(holder.rights & R_VIEWRUNTIMES)
			add_verb(src, GLOB.view_runtimes_verbs)
			spawn(1) // This setting exposes the profiler for people with R_VIEWRUNTIMES. They must still have it set in cfg/admin.txt
				control_freak = 0


/client/proc/hide_verbs()
	set name = "Adminverbs - Hide All"
	set category = "Admin"

	if(!holder)
		return

	remove_verb(src, list(
		GLOB.admin_verbs_default,
		/client/proc/togglebuildmodeself,
		GLOB.admin_verbs_admin,
		GLOB.admin_verbs_ban,
		GLOB.admin_verbs_event,
		GLOB.admin_verbs_server,
		GLOB.admin_verbs_debug,
		GLOB.admin_verbs_possess,
		GLOB.admin_verbs_permissions,
		/client/proc/view_pingstat,
		/client/proc/profiler_start,
		/client/proc/profiler_stop,
		GLOB.admin_verbs_rejuv,
		GLOB.admin_verbs_sounds,
		GLOB.admin_verbs_spawn,
		GLOB.admin_verbs_mod,
		GLOB.admin_verbs_mentor,
		GLOB.admin_verbs_proccall,
		GLOB.admin_verbs_show_debug_verbs,
		/client/proc/stealth,
	))
	add_verb(src, /client/proc/show_verbs)

	to_chat(src, "<span class='interface'>Almost all of your adminverbs have been hidden.</span>", confidential=TRUE)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Hide Admin Verbs") //If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!
	return

/client/proc/show_verbs()
	set name = "Adminverbs - Show"
	set category = "Admin"

	if(!holder)
		return

	remove_verb(src, /client/proc/show_verbs)
	add_admin_verbs()

	to_chat(src, "<span class='interface'>All of your adminverbs are now visible.</span>", confidential=TRUE)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Show Admin Verbs") //If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!

/client/proc/admin_ghost()
	set category = "Admin"
	set name = "Aghost"

	if(!check_rights(R_ADMIN|R_MOD|R_POSSESS))
		return

	if(istype(mob,/mob/dead/observer))
		//re-enter
		var/mob/dead/observer/ghost = mob
		ghost.can_reenter_corpse = 1			//just in-case.
		ghost.reenter_corpse()
		log_admin("[key_name(usr)] re-entered their body")
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Aghost") //If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!
		if(ishuman(mob))
			var/mob/living/carbon/human/H = mob
			H.regenerate_icons() // workaround for #13269
	else if(isnewplayer(mob))
		to_chat(src, "<font color='red'>Error: Aghost: Can't admin-ghost whilst in the lobby. Join or observe first.</font>", confidential=TRUE)
	else
		//ghostize
		var/mob/body = mob
		body.ghostize(1)
		if(body && !body.key)
			body.key = "@[key]"	//Haaaaaaaack. But the people have spoken. If it breaks; blame adminbus
		log_admin("[key_name(usr)] has admin-ghosted")
		// TODO: SStgui.on_transfer() to move windows from old and new
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Aghost") //If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!

/client/proc/invisimin()
	set name = "Invisimin"
	set category = "Admin"
	set desc = "Toggles ghost-like invisibility (Don't abuse this)"

	if(!check_rights(R_ADMIN))
		return
	if(!isliving(mob))
		return

	if(mob.invisibility == INVISIBILITY_OBSERVER)
		mob.invisibility = initial(mob.invisibility)
		mob.add_to_all_human_data_huds()
		to_chat(mob, "<span class='danger'>Invisimin off. Invisibility reset.</span>", confidential=TRUE)
		log_admin("[key_name(mob)] has turned Invisimin OFF")
	else
		mob.invisibility = INVISIBILITY_OBSERVER
		mob.remove_from_all_data_huds()
		to_chat(mob, "<span class='notice'>Invisimin on. You are now as invisible as a ghost.</span>", confidential=TRUE)
		log_admin("[key_name(mob)] has turned Invisimin ON")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Invisimin")

/client/proc/player_panel_new()
	set name = "Player Panel"
	set category = "Admin"

	if(!check_rights(R_ADMIN | R_MOD))
		return

	holder.player_panel_new()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Player Panel") //If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!
	return

/client/proc/check_antagonists()
	set name = "Check Antagonists"
	set category = "Admin"

	if(!check_rights(R_ADMIN))
		return

	holder.check_antagonists()
	log_admin("[key_name(usr)] checked antagonists")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Check Antags") //If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!
	return

/client/proc/ban_panel()
	set name = "Ban Panel"
	set category = "Admin"

	if(!check_rights(R_BAN))
		return

	if(CONFIG_GET(flag/ban_legacy_system))
		holder.unbanpanel()
	else
		holder.DB_ban_panel()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Ban Panel") //If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!
	return

/client/proc/game_panel()
	set name = "Game Panel"
	set category = "Event"

	if(!check_rights(R_ADMIN | R_EVENT))
		return

	holder.Game()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Game Panel") //If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!
	return

/client/proc/secrets()
	set name = "Secrets"
	set category = "Event"

	if(!check_rights(R_ADMIN | R_EVENT))
		return

	holder.Secrets()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Secrets") //If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!
	return

/client/proc/getStealthKey()
	return GLOB.stealthminID[ckey]

/client/proc/createStealthKey()
	var/num = (rand(0,1000))
	var/i = 0
	while(i == 0)
		i = 1
		for(var/P in GLOB.stealthminID)
			if(num == GLOB.stealthminID[P])
				num++
				i = 0
	GLOB.stealthminID["[ckey]"] = "@[num2text(num)]"

/client/proc/stealth()
	set category = "Admin"
	set name = "Stealth Mode"

	if(!check_rights(R_ADMIN))
		return

	if(holder)
		holder.big_brother = FALSE
		if(holder.fakekey)
			holder.fakekey = null
		else
			var/new_key = ckeyEx(clean_input("Enter your desired display name.", "Fake Key", key))
			if(!new_key)	return
			if(length(new_key) >= 26)
				new_key = copytext(new_key, 1, 26)
			holder.fakekey = new_key
			createStealthKey()
		log_and_message_admins("has turned stealth mode [holder.fakekey ? "ON with fake key: [holder.fakekey]" : "OFF"]")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Stealth Mode") //If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!

/client/proc/big_brother()
	set category = "Admin"
	set name = "Big Brother Mode"

	if(!check_rights(R_PERMISSIONS))
		return

	if(holder)
		if(holder.fakekey)
			holder.fakekey = null
			holder.big_brother = FALSE
		else
			var/new_key = ckeyEx(clean_input("Enter your desired display name. Unlike normal stealth mode, this will not appear in Who at all, except for other heads.", "Fake Key", key))
			if(!new_key)
				return
			if(length(new_key) >= 26)
				new_key = copytext(new_key, 1, 26)
			holder.fakekey = new_key
			holder.big_brother = TRUE
			createStealthKey()
		log_admin("[key_name(usr)] has turned BB mode [holder.fakekey ? "ON" : "OFF"]")
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Big Brother Mode")

/client/proc/drop_bomb() // Some admin dickery that can probably be done better -- TLE
	set category = "Event"
	set name = "Drop Bomb"
	set desc = "Cause an explosion of varying strength at your location."

	if(!check_rights(R_EVENT))
		return

	var/turf/epicenter = mob.loc
	var/list/choices = list("Small Bomb", "Medium Bomb", "Big Bomb", "Custom Bomb")
	var/choice = input("What size explosion would you like to produce?") as null|anything in choices
	switch(choice)
		if(null)
			return 0
		if("Small Bomb")
			explosion(epicenter, 1, 2, 3, 3, cause = "Admin Drop Bomb")
		if("Medium Bomb")
			explosion(epicenter, 2, 3, 4, 4, cause = "Admin Drop Bomb")
		if("Big Bomb")
			explosion(epicenter, 3, 5, 7, 5, cause = "Admin Drop Bomb")
		if("Custom Bomb")
			var/devastation_range = tgui_input_number(src, "Devastation range (in tiles):", "Custom Bomb", max_value = 255)
			if(isnull(devastation_range))
				return
			var/heavy_impact_range = tgui_input_number(src, "Heavy impact range (in tiles):", "Custom Bomb", max_value = 255)
			if(isnull(heavy_impact_range))
				return
			var/light_impact_range = tgui_input_number(src, "Light impact range (in tiles):", "Custom Bomb", max_value = 255)
			if(isnull(light_impact_range))
				return
			var/flash_range = tgui_input_number(src, "Flash range (in tiles):", "Custom Bomb", max_value = 255)
			if(isnull(flash_range))
				return
			explosion(epicenter, devastation_range, heavy_impact_range, light_impact_range, flash_range, 1, 1, cause = "Admin Drop Bomb")
	log_admin("[key_name(usr)] created an admin explosion at [epicenter.loc]")
	message_admins("<span class='adminnotice'>[key_name_admin(usr)] created an admin explosion at [epicenter.loc]</span>")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Drop Bomb") //If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!

/client/proc/bless(mob/living/M as mob)
	set category = "Event"
	set name = "Bless"
	if(!check_rights(R_EVENT))
		return
	if(!istype(M))
		to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob/living</span>", confidential=TRUE)
		return
	var/btypes = list("To Arrivals", "Moderate Heal")
	var/mob/living/carbon/human/H
	if(ishuman(M))
		H = M
		btypes += "Spawn Cookie"
		btypes += "Heal Over Time"
		btypes += "Permanent Regeneration"
		btypes += "Super Powers"
		btypes += "Scarab Guardian"
		btypes += "Human Protector"
		btypes += "Sentient Pet"
		btypes += "All Access"
	var/blessing = tgui_input_list(usr, "How would you like to bless [M]?", "Its good to be good...", btypes)
	if(!(blessing in btypes))
		return
	var/logmsg = null
	switch(blessing)
		if("Spawn Cookie")
			H.equip_to_slot_or_del( new /obj/item/reagent_containers/food/snacks/cookie(H), ITEM_SLOT_HAND_LEFT )
			if(!(istype(H.l_hand,/obj/item/reagent_containers/food/snacks/cookie)))
				H.equip_to_slot_or_del( new /obj/item/reagent_containers/food/snacks/cookie(H), ITEM_SLOT_HAND_RIGHT )
				if(!(istype(H.r_hand,/obj/item/reagent_containers/food/snacks/cookie)))
					log_and_message_admins("tried to spawn for [key_name(H)] a cookie, but their hands were full, so they did not receive their cookie.")
					return
				else
					H.update_inv_r_hand()//To ensure the icon appears in the HUD
			else
				H.update_inv_l_hand()
			logmsg = "spawn cookie."
		if("To Arrivals")
			M.forceMove(pick(GLOB.latejoin))
			to_chat(M, "<span class='userdanger'>You are abruptly pulled through space!</span>", confidential=TRUE)
			logmsg = "a teleport to arrivals."
		if("Moderate Heal")
			var/update = NONE
			update |= M.heal_overall_damage(25, 25, updating_health = FALSE, affect_robotic = TRUE)
			update |= M.heal_damages(tox = 25, oxy = 25, updating_health = FALSE)
			if(update)
				M.updatehealth()
			to_chat(M,"<span class='userdanger'>You feel invigorated!</span>", confidential=TRUE)
			logmsg = "a moderate heal."
		if("Heal Over Time")
			H.reagents.add_reagent("salglu_solution", 30)
			H.reagents.add_reagent("salbutamol", 20)
			H.reagents.add_reagent("spaceacillin", 20)
			logmsg = "a heal over time."
		if("Permanent Regeneration")
			H.force_gene_block(GLOB.regenerateblock, TRUE)
			H.gene_stability = 100
			logmsg = "permanent regeneration."
		if("Super Powers")
			var/list/default_genes = list(GLOB.regenerateblock, GLOB.breathlessblock, GLOB.coldblock)
			for(var/gene in default_genes)
				H.force_gene_block(gene, TRUE)
			H.gene_stability = 100
			logmsg = "superpowers."
		if("Scarab Guardian")
			var/obj/item/guardiancreator/biological/scarab = new /obj/item/guardiancreator/biological(H)
			var/list/possible_guardians = list("Chaos", "Standard", "Ranged", "Support", "Explosive", "Random")
			var/typechoice = input("Select Guardian Type", "Type") as null|anything in possible_guardians
			if(isnull(typechoice))
				return
			if(typechoice != "Random")
				possible_guardians -= "Random"
				scarab.possible_guardians = list()
				scarab.possible_guardians += typechoice
			scarab.attack_self(H)
			spawn(700)
				qdel(scarab)
			logmsg = "scarab guardian."
		if("Sentient Pet")
			var/pets = subtypesof(/mob/living/simple_animal)
			var/petchoice = input("Select pet type", "Pets") as null|anything in pets
			if(isnull(petchoice))
				return
			var/list/mob/dead/observer/candidates = SSghost_spawns.poll_candidates("Play as the special event pet [H]?", poll_time = 20 SECONDS, min_hours = 10, source = petchoice)
			var/mob/dead/observer/theghost = null
			if(candidates.len)
				var/mob/living/simple_animal/pet/P = new petchoice(H.loc)
				theghost = pick(candidates)
				P.key = theghost.key
				P.master_commander = H
				P.universal_speak = TRUE
				P.universal_understand = TRUE
				P.set_can_collar(TRUE)
				P.faction = list("neutral")
				var/obj/item/clothing/accessory/petcollar/C = new
				P.add_collar(C)
				var/obj/item/card/id/I = H.wear_id
				if(I)
					var/obj/item/card/id/D = new /obj/item/card/id(C)
					D.access = I.access
					D.registered_name = P.name
					D.assignment = "Pet"
					C.access_id = D
				spawn(30)
					var/newname = sanitize(copytext_char(input(P, "You are [P], special event pet of [H]. Change your name to something else?", "Name change", P.name) as null|text,1,MAX_NAME_LEN))
					if(newname && newname != P.name)
						P.name = newname
						if(P.mind)
							P.mind.name = newname
				logmsg = "pet ([P])."
			else
				to_chat(usr, "<span class='warning'>WARNING: Nobody volunteered to play the special event pet.</span>", confidential=TRUE)
				logmsg = "pet (no volunteers)."
		if("Human Protector")
			usr.client.create_eventmob_for(H, 0)
			logmsg = "syndie protector."
		if("All Access")
			var/obj/item/card/id/I = H.wear_id
			if(I)
				var/list/access_to_give = get_all_accesses()
				for(var/this_access in access_to_give)
					if(!(this_access in I.access))
						// don't have it - add it
						I.access |= this_access
			else
				to_chat(usr, "<span class='warning'>ERROR: [H] is not wearing an ID card.</span>", confidential=TRUE)
			logmsg = "all access."
	if(logmsg)
		log_and_message_admins("blessed [key_name_log(M)] with: [logmsg]")

/client/proc/smite(mob/living/M as mob)
	set category = "Event"
	set name = "Smite"
	if(!check_rights(R_EVENT))
		return
	var/mob/living/carbon/human/H
	if(!istype(M))
		to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob/living</span>", confidential=TRUE)
		return
	var/ptypes = list("Lightning bolt", "Fire Death", "Gib")
	if(ishuman(M))
		H = M
		ptypes += "Brain Damage"
		ptypes += "Honk Tumor"
		ptypes += "Hallucinate"
		ptypes += "Cold"
		ptypes += "Hunger"
		ptypes += "Cluwne"
		ptypes += "Mutagen Cookie"
		ptypes += "Hellwater Cookie"
		ptypes += "Hunter"
		ptypes += "Crew Traitor"
		ptypes += "Floor Cluwne"
		ptypes += "Shamebrero"
		ptypes += "Dust"
		ptypes += "Shitcurity Goblin"
		ptypes += "High RP"
	var/punishment = tgui_input_list(usr, "How would you like to smite [M]?", "Its good to be baaaad...", ptypes)
	if(!(punishment in ptypes))
		return
	var/logmsg = null
	switch(punishment)
		// These smiting types are valid for all living mobs
		if("Lightning bolt")
			M.electrocute_act(5, "молнии", flags = SHOCK_NOGLOVES)
			playsound(get_turf(M), 'sound/magic/lightningshock.ogg', 50, 1, -1)
			M.adjustFireLoss(75)
			M.Weaken(10 SECONDS)
			to_chat(M, "<span class='userdanger'>The gods have punished you for your sins!</span>")
			logmsg = "a lightning bolt."
		if("Fire Death")
			to_chat(M,"<span class='userdanger'>You feel hotter than usual. Maybe you should lowe-wait, is that your hand melting?</span>")
			var/turf/simulated/T = get_turf(M)
			new /obj/effect/hotspot(T)
			M.adjustFireLoss(150)
			logmsg = "a firey death."
		if("Gib")
			M.gib(FALSE)
			logmsg = "gibbed."

		// These smiting types are only valid for ishuman() mobs
		if("Brain Damage")
			H.adjustBrainLoss(75)
			logmsg = "75 brain damage."
		if("Honk Tumor")
			if(!H.get_int_organ(/obj/item/organ/internal/honktumor))
				var/obj/item/organ/internal/organ = new /obj/item/organ/internal/honktumor
				to_chat(H, "<span class='userdanger'>Life seems funnier, somehow.</span>")
				organ.insert(H)
			logmsg = "a honk tumor."
		if("Hallucinate")
			H.Hallucinate(1000 SECONDS)
			H.last_hallucinator_log = "Hallucination smite"
			logmsg = "hallucinations."
		if("Cold")
			H.reagents.add_reagent("frostoil", 40)
			H.reagents.add_reagent("ice", 40)
			logmsg = "cold."
		if("Hunger")
			H.set_nutrition(NUTRITION_LEVEL_CURSED)
			logmsg = "starvation."
		if("Cluwne")
			H.makeCluwne()
			ADD_TRAIT(H, TRAIT_NO_CLONE, ADMIN_TRAIT)
			logmsg = "cluwned."
		if("Mutagen Cookie")
			var/obj/item/reagent_containers/food/snacks/cookie/evilcookie = new /obj/item/reagent_containers/food/snacks/cookie
			evilcookie.reagents.add_reagent("mutagen", 10)
			evilcookie.desc = "It has a faint green glow."
			evilcookie.bitesize = 100
			evilcookie.item_flags |= DROPDEL
			ADD_TRAIT(evilcookie, TRAIT_NODROP, ADMIN_TRAIT)
			H.drop_l_hand()
			H.equip_to_slot_or_del(evilcookie, ITEM_SLOT_HAND_LEFT)
			logmsg = "a mutagen cookie."
		if("Hellwater Cookie")
			var/obj/item/reagent_containers/food/snacks/cookie/evilcookie = new /obj/item/reagent_containers/food/snacks/cookie
			evilcookie.reagents.add_reagent("hell_water", 25)
			evilcookie.desc = "Sulphur-flavored."
			evilcookie.bitesize = 100
			evilcookie.item_flags |= DROPDEL
			ADD_TRAIT(evilcookie, TRAIT_NODROP, ADMIN_TRAIT)
			H.drop_l_hand()
			H.equip_to_slot_or_del(evilcookie, ITEM_SLOT_HAND_LEFT)
			logmsg = "a hellwater cookie."
		if("Hunter")
			ADD_TRAIT(H, TRAIT_NO_CLONE, ADMIN_TRAIT)
			usr.client.create_eventmob_for(H, 1)
			logmsg = "hunter."
		if("Crew Traitor")
			if(!H.mind)
				to_chat(usr, "<span class='warning'>ERROR: This mob ([H]) has no mind!</span>", confidential=TRUE)
				return
			var/list/possible_traitors = list()
			for(var/mob/living/player in GLOB.alive_mob_list)
				if(player.client && player.mind && player.stat != DEAD && player != H)
					if(ishuman(player) && !player.mind.special_role)
						if(player.client && (ROLE_TRAITOR in player.client.prefs.be_special) && !jobban_isbanned(player, ROLE_TRAITOR) && !jobban_isbanned(player, "Syndicate"))
							possible_traitors += player.mind
			for(var/datum/mind/player in possible_traitors)
				if(player.current)
					if(ismindshielded(player.current))
						possible_traitors -= player
			if(possible_traitors.len)
				var/datum/mind/newtraitormind = pick(possible_traitors)
				var/datum/objective/assassinate/kill_objective = new()
				kill_objective.target = H.mind
				kill_objective.owner = newtraitormind
				kill_objective.explanation_text = "Assassinate [H.mind.name], the [H.mind.assigned_role]"
				newtraitormind.objectives += kill_objective
				var/datum/antagonist/traitor/T = new()
				T.give_objectives = FALSE
				to_chat(newtraitormind.current, "<span class='danger'>ATTENTION:</span> It is time to pay your debt to the Syndicate...")
				to_chat(newtraitormind.current, "<b>Goal: <span class='danger'>KILL [H.real_name]</span>, currently in [get_area(H.loc)]</b>")
				newtraitormind.add_antag_datum(T)
			else
				to_chat(usr, "<span class='warning'>ERROR: Unable to find any valid candidate to send after [H].</span>", confidential=TRUE)
				return
			logmsg = "crew traitor."
		if("Floor Cluwne")
			var/turf/T = get_turf(M)
			var/mob/living/simple_animal/hostile/floor_cluwne/FC = new /mob/living/simple_animal/hostile/floor_cluwne(T)
			FC.smiting = TRUE
			FC.Acquire_Victim(M)
			logmsg = "floor cluwne"
		if("Shamebrero")
			if(H.head)
				H.drop_item_ground(H.head, force = TRUE)
			var/obj/item/clothing/head/sombrero/shamebrero/S = new(H.loc)
			H.equip_to_slot_or_del(S, ITEM_SLOT_HEAD)
			logmsg = "shamebrero"
		if("Dust")
			H.dust()
			logmsg = "dust"
		if("Shitcurity Goblin")
			var/turf/T = get_turf(M)
			var/mob/living/simple_animal/hostile/shitcur_goblin/goblin = new (T)
			goblin.GiveTarget(M)
			logmsg = "shitcurity goblin"
		if("High RP")
			var/obj/item/organ/internal/high_rp_tumor/hrp_tumor = H.get_int_organ(/obj/item/organ/internal/high_rp_tumor)
			if(!hrp_tumor)
				var/list/effect_variants = list("15 - 50", "30 - 45", "30 - 75",
				"30 - 100", "60 - 100", "60 - 150", "60 - 200", "custom")
				var/effect_strength = input("What effect strength do you want?(delay in seconds -  oxy damage)", "") as null|anything in effect_variants
				var/pdelay
				var/oxy_dmg
				if(effect_strength == "custom")
					pdelay = input("Input pump delay.") as num|null
					oxy_dmg = input("Input oxy damage.") as num|null
				else
					var/list/strenght = text2numlist(effect_strength, " - ")
					pdelay = strenght[1]
					oxy_dmg = strenght[2]
				H.curse_high_rp(pdelay*10, oxy_dmg)
				LAZYADD(H.mind.curses, "high_rp")
				logmsg = "high rp([pdelay] - [oxy_dmg])"
			else
				hrp_tumor.remove(H)
				qdel(hrp_tumor)
				LAZYREMOVE(H.mind.curses, "high_rp")
				logmsg = "high rp(cure)"

	if(logmsg)
		log_and_message_admins("smited [key_name_log(M)] with: [logmsg]")

/client/proc/give_spell(mob/T as mob in GLOB.mob_list) // -- Urist
	set category = "Event"
	set name = "Give Spell"
	set desc = "Gives a spell to a mob."

	if(!check_rights(R_EVENT))
		return

	var/list/spell_list = list()
	var/type_length = length("/obj/effect/proc_holder/spell") + 2
	for(var/A in GLOB.spells)
		spell_list[copytext("[A]", type_length)] = A
	var/obj/effect/proc_holder/spell/S = input("Choose the spell to give to that guy", "ABRAKADABRA") as null|anything in spell_list
	if(!S)
		return
	S = spell_list[S]
	if(T.mind)
		T.mind.AddSpell(new S)
	else
		T.AddSpell(new S)

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Give Spell") //If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!
	log_and_message_admins("gave [key_name_log(T)] the spell [S].")

/client/proc/give_disease(mob/T in GLOB.mob_list)
	set category = "Event"
	set name = "Give Disease"
	set desc = "Gives a Disease to a mob."
	var/choosen_disease = input("Choose the disease to give to that guy", "ACHOO") as null|anything in GLOB.diseases
	if(!choosen_disease) return
	var/datum/disease/D = new choosen_disease()
	D.Contract(T)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Give Disease") //If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!
	log_and_message_admins("gave [key_name_log(T)] the disease [D].")

/client/proc/make_sound(obj/O in view(maxview())) // -- TLE
	set name = "\[Admin\] Make Sound"
	set desc = "Display a message to everyone who can hear the target"

	if(!check_rights(R_SOUNDS))
		return

	if(O)
		var/message = clean_input("What do you want the message to be?", "Make Sound")
		if(!message)
			return
		for(var/mob/V in hearers(O))
			V.show_message(admin_pencode_to_html(message), 2)
		log_and_message_admins("made [O] at [COORD(O)] make a sound")
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Make Sound") //If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!

/client/proc/togglebuildmodeself()
	set name = "Toggle Build Mode Self"
	set category = "Event"

	if(!check_rights(R_EVENT))
		return

	if(src.mob)
		togglebuildmode(src.mob)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Toggle Build Mode") //If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!

/client/proc/object_talk(var/msg as text) // -- TLE
	set name = "oSay"
	set desc = "Display a message to everyone who can hear the target"

	if(!check_rights(R_EVENT))
		return

	if(mob.control_object)
		if(!msg)
			return
		for(var/mob/V in hearers(mob.control_object))
			V.show_message("<b>[mob.control_object.name]</b> says: \"" + msg + "\"", 2)
		log_admin("[key_name(usr)] used oSay on [mob.control_object]: [msg]")
		message_admins("[key_name_admin(usr)] used oSay on [mob.control_object]: [msg]")

	SSblackbox.record_feedback("tally", "admin_verb", 1, "oSay") //If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!

/client/proc/force_hijack()
	set category = "Event"
	set name = "Toggle Shuttle Force Hijack"
	set desc = "Force shuttle fly to syndicate base."

	if(!check_rights(R_EVENT))
		return

	var/obj/docking_port/mobile/emergency/S = locate()
	if(!S)
		return
	S.forceHijacked = !S.forceHijacked
	var/admin_verb = S.forceHijacked ? "enabled" : "disabled"
	log_and_message_admins("[admin_verb] forced shuttle hijack.")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "[admin_verb] forced shuttle hijack")

/client/proc/deadmin_self()
	set name = "De-admin self"
	set category = "Admin"

	if(!check_rights(R_ADMIN|R_MOD|R_MENTOR))
		return

	log_admin("[key_name(usr)] deadmined themself.")
	message_admins("[key_name_admin(usr)] deadmined themself.")
	deadmin()
	add_verb(src, /client/proc/readmin)
	GLOB.deadmins += ckey
	update_active_keybindings()
	to_chat(src, "<span class='interface'>You are now a normal player.</span>", confidential=TRUE)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "De-admin") //If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!

/client/proc/readmin()
	set name = "Re-admin self"
	set category = "Admin"
	set desc = "Regain your admin powers."

	var/datum/admins/D = GLOB.admin_datums[ckey]
	var/rank = null
	if(CONFIG_GET(flag/admin_legacy_system))
		//load text from file
		var/list/Lines = file2list("config/admins.txt")
		for(var/line in Lines)
			if(findtext(line, "#")) // Skip comments
				continue

			var/list/splitline = splittext(line, " - ")
			if(length(splitline) != 2) // Always 'ckey - rank'
				continue
			if(lowertext(splitline[1]) == ckey)
				rank = splitline[2]
				break
			continue

	else
		if(!SSdbcore.IsConnected())
			to_chat(src, "Warning, MYSQL database is not connected.", confidential=TRUE)
			return

		var/datum/db_query/rank_read = SSdbcore.NewQuery(
			"SELECT rank FROM [format_table_name("admin")] WHERE ckey=:ckey",
			list("ckey" = ckey)
		)

		if(!rank_read.warn_execute())
			qdel(rank_read)
			return FALSE

		while(rank_read.NextRow())
			rank = rank_read.item[1]

		qdel(rank_read)
	if(!D)
		if(CONFIG_GET(flag/admin_legacy_system))
			if(GLOB.admin_ranks[rank] == null)
				error("Error while re-adminning [src], admin rank ([rank]) does not exist.")
				to_chat(src, "Error while re-adminning, admin rank ([rank]) does not exist.", confidential=TRUE)
				return

			D = new(rank, GLOB.admin_ranks[rank], ckey)
		else
			if(!SSdbcore.IsConnected())
				to_chat(src, "Warning, MYSQL database is not connected.", confidential=TRUE)
				return

			var/datum/db_query/admin_read = SSdbcore.NewQuery(
				"SELECT ckey, rank, flags FROM [format_table_name("admin")] WHERE ckey=:ckey",
				list("ckey" = ckey)
			)

			if(!admin_read.warn_execute())
				qdel(admin_read)
				return FALSE

			while(admin_read.NextRow())
				var/admin_ckey = admin_read.item[1]
				var/admin_rank = admin_read.item[2]
				var/flags = admin_read.item[3]
				if(!admin_ckey)
					to_chat(src, "Error while re-adminning, ckey [admin_ckey] was not found in the admin database.", confidential=TRUE)
					qdel(admin_read)
					return
				if(admin_rank == "Удален") //This person was de-adminned. They are only in the admin list for archive purposes.
					to_chat(src, "Error while re-adminning, ckey [admin_ckey] is not an admin.", confidential=TRUE)
					qdel(admin_read)
					return

				if(istext(flags))
					flags = text2num(flags)
				D = new(admin_rank, flags, ckey)

			qdel(admin_read)

		var/client/C = GLOB.directory[ckey]
		D.associate(C)
		update_active_keybindings()
		message_admins("[key_name_admin(usr)] re-adminned themselves.")
		log_admin("[key_name(usr)] re-adminned themselves.")
		update_active_keybindings()
		GLOB.deadmins -= ckey
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Re-admin")
		return
	else
		to_chat(src, "You are already an admin.", confidential=TRUE)
		remove_verb(src, /client/proc/readmin)
		GLOB.deadmins -= ckey
		return

/client/proc/select_next_map()
	set name = "Select next map"
	set category = "Server"

	if(!check_rights(R_SERVER | R_EVENT))
		return

	var/list/all_maps = subtypesof(/datum/map)
	var/next_map = input("Select next map:", "Next map", SSmapping.map_datum.type) as null|anything in all_maps

	if(next_map)
		message_admins("[key_name_admin(usr)] select [next_map] as next map")
		log_admin("[key_name(usr)] select [next_map] as next map")
		SSmapping.next_map = new next_map
		to_chat(world, "<B>The next map is - [SSmapping.next_map.name]!</B>")

/client/proc/toggle_log_hrefs()
	set name = "Toggle href logging"
	set category = "Server"

	if(!check_rights(R_SERVER))
		return

	if(config)
		if(CONFIG_GET(flag/log_hrefs))
			CONFIG_SET(flag/log_hrefs, FALSE)
			to_chat(src, "<b>Stopped logging hrefs</b>", confidential=TRUE)
		else
			CONFIG_SET(flag/log_hrefs, TRUE)
			to_chat(src, "<b>Started logging hrefs</b>", confidential=TRUE)

/client/proc/toggle_twitch_censor()
	set name = "Toggle Twitch censor"
	set category = "Server"

	if(!check_rights(R_SERVER))
		return

	if(config)
		CONFIG_SET(flag/twitch_censor, !CONFIG_GET(flag/twitch_censor))
		to_chat(src, "<b>Twitch censor is [CONFIG_GET(flag/twitch_censor) ? "enabled" : "disabled"]</b>", confidential=TRUE)

/client/proc/check_ai_laws()
	set name = "Check AI Laws"
	set category = "Admin"

	if(!check_rights(R_ADMIN))
		return

	holder.output_ai_laws()

/client/proc/manage_silicon_laws()
	set name = "Manage Silicon Laws"
	set category = "Admin"

	if(!check_rights(R_ADMIN))
		return

	var/mob/living/silicon/S = input("Select silicon.", "Manage Silicon Laws") as null|anything in GLOB.silicon_mob_list
	if(!S) return

	var/datum/ui_module/law_manager/L = new(S)
	L.ui_interact(usr)
	log_and_message_admins("has opened [S]'s law manager.")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Manage Silicon Laws") //If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!

/client/proc/change_human_appearance_admin(mob/living/carbon/human/H)
	if(!check_rights(R_EVENT))
		return

	if(!istype(H))
		if(isbrain(H))
			var/mob/living/carbon/brain/B = H
			if(istype(B.container, /obj/item/mmi/robotic_brain/positronic))
				var/obj/item/mmi/robotic_brain/positronic/C = B.container
				var/obj/item/organ/internal/brain/mmi_holder/posibrain/P = C.loc
				if(ishuman(P.owner))
					H = P.owner
			else
				return
		else
			return

	if(holder)
		log_and_message_admins("is altering the appearance of [H].")
		H.change_appearance(APPEARANCE_ALL, usr, usr, check_species_whitelist = 0)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "CMA - Admin") //If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!

/client/proc/change_human_appearance_self(mob/living/carbon/human/H)
	if(!check_rights(R_EVENT))
		return

	if(!istype(H))
		if(isbrain(H))
			var/mob/living/carbon/brain/B = H
			if(istype(B.container, /obj/item/mmi/robotic_brain/positronic))
				var/obj/item/mmi/robotic_brain/positronic/C = B.container
				var/obj/item/organ/internal/brain/mmi_holder/posibrain/P = C.loc
				if(ishuman(P.owner))
					H = P.owner
			else
				return
		else
			return

	if(!H.client)
		to_chat(usr, "Only mobs with clients can alter their own appearance.", confidential=TRUE)
		return

	switch(alert("Do you wish for [H] to be allowed to select non-whitelisted races?","Alter Mob Appearance","Yes","No","Cancel"))
		if("Yes")
			log_and_message_admins("has allowed [H] to change [H.p_their()] appearance, without whitelisting of races.")
			H.change_appearance(APPEARANCE_ALL, H.loc, check_species_whitelist = 0)
		if("No")
			log_and_message_admins("has allowed [H] to change [H.p_their()] appearance, with whitelisting of races.")
			H.change_appearance(APPEARANCE_ALL, H.loc, check_species_whitelist = 1)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "CMA - Self") //If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!

/client/proc/free_slot()
	set name = "Free Job Slot"
	set category = "Admin"

	if(!check_rights(R_ADMIN))
		return

	var/list/jobs = list()
	for(var/datum/job/J in SSjobs.occupations)
		if(J.current_positions >= J.total_positions && J.total_positions != -1)
			jobs += J.title
	if(!jobs.len)
		to_chat(usr, "There are no fully staffed jobs.", confidential=TRUE)
		return
	var/job = input("Please select job slot to free", "Free Job Slot") as null|anything in jobs
	if(job)
		SSjobs.FreeRole(job)
		log_admin("[key_name(usr)] has freed a job slot for [job].")
		message_admins("[key_name_admin(usr)] has freed a job slot for [job].")

/client/proc/man_up(mob/T)
	if(!check_rights(R_ADMIN))
		return

	to_chat(T, chat_box_notice_thick(span_notice("<b><font size=4>Man up.<br> Deal with it.</font></b><br>Move on.")))
	T << 'sound/voice/manup1.ogg'

	log_and_message_admins("told [key_name_log(T)] to man up and deal with it.")

/client/proc/global_man_up()
	set category = "Admin"
	set name = "Man Up Global"
	set desc = "Tells everyone to man up and deal with it."

	if(!check_rights(R_ADMIN))
		return

	var/confirm = alert("Are you sure you want to send the global message?", "Confirm Man Up Global", "Yes", "No")

	if(confirm == "Yes")
		for(var/mob/T as mob in GLOB.mob_list)
			to_chat(T, chat_box_notice_thick(span_notice("<b><font size=4>Man up.<br> Deal with it.</font></b><br>Move on.")))
			T << 'sound/voice/manup1.ogg'

		log_admin("[key_name(usr)] told everyone to man up and deal with it.")
		message_admins("[key_name_admin(usr)] told everyone to man up and deal with it.")

/client/proc/toggle_advanced_interaction()
	set name = "Toggle Advanced Admin Interaction"
	set category = "Admin"
	set desc = "Allows you to interact with atoms such as buttons and doors, on top of regular machinery interaction."

	if(!check_rights(R_ADMIN))
		return

	advanced_admin_interaction = !advanced_admin_interaction

	log_admin("[key_name(usr)] has [advanced_admin_interaction ? "activated" : "deactivated"] their advanced admin interaction.")
	message_admins("[key_name_admin(usr)] has [advanced_admin_interaction ? "activated" : "deactivated"] their advanced admin interaction.")

/client/proc/cmd_admin_alert_message(mob/about_to_be_banned)
	set name = "Send Alert Message"
	set category = "Admin"

	if(!ismob(about_to_be_banned))
		return

	if(!check_rights(R_ADMIN))
		return

	var/alert_type = alert(src, "Do you wish to send an admin alert to [key_name(about_to_be_banned, FALSE)]?",,"Yes", "No", "Custom Message")

	switch(alert_type)
		if("Yes")
			var/message = "Администратор пытается связаться с тобой! \nОткрой диалоговое окно с администратором, нажав на его сикей в чате, в случае игнорирования, вы можете получить бан!"
			show_blurb(about_to_be_banned, 15, message, null, "center", "center", COLOR_RED, null, null, 1)
			log_admin("[key_name(src)] sent a default admin alert to [key_name(about_to_be_banned)].")
			message_admins("[key_name(src)] sent a default admin alert to [key_name(about_to_be_banned)].")

		if("Custom Message")
			var/message = input(src, "Input your custom admin alert text:", "Message") as text|null
			if(!message)
				return
			message = strip_html(message, 500)

			var/message_color = input(src, "Input your message color:", "Color Selector") as color|null
			if(!message_color)
				return

			var/alert_type2 = alert(src, "Do you wish to change speed of an admin alert to? (No - default speed)",,"Yes", "No")
			switch(alert_type2)
				if("Yes")
					var/speedmsg = input(src, "Input speed (0.5 - 2x faster. 2 - 2x slower):", "speedmsg") as text|null
					if(!speedmsg)
						return
					speedmsg = text2num(speedmsg)
					show_blurb(about_to_be_banned, 15, message, null, "center", "center", message_color, null, null, speedmsg)
					log_admin("[key_name(src)] sent an admin alert to [key_name(about_to_be_banned)] with custom message [message].")
					message_admins("[key_name(src)] sent an admin alert to [key_name(about_to_be_banned)] with custom message [message].")
				if("No")
					show_blurb(about_to_be_banned, 15, message, null, "center", "center", message_color, null, null, 1)
					log_admin("[key_name(src)] sent an admin alert to [key_name(about_to_be_banned)] with custom message [message].")
					message_admins("[key_name(src)] sent an admin alert to [key_name(about_to_be_banned)] with custom message [message].")

				else
					return

/client/proc/debugstatpanel()
	set name = "Debug Stat Panel"
	set category = "Debug"

	src.stat_panel.send_message("create_debug")
