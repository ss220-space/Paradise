/datum/ui_module/permissions_edit
	name = "Permissions Edit"
	var/list/ranks = list()

/datum/ui_module/permissions_edit/New(datum/_host)
	. = ..()
	var/datum/db_query/query = SSdbcore.NewQuery("SELECT ckey, rank, level, flags FROM [format_table_name("admin")]")
	if(!query.warn_execute(async=FALSE))
		qdel(query)
		return

	while(query.NextRow())
		var/ckey = query.item[1]
		var/rank = query.item[2]
		var/rights = query.item[4]
		if(istext(rights))
			rights = text2num(rights)
		if((!rank || rank == DELETED_RANK) && !rights)
			continue
		ranks[ckey] = list(
			"rank" = rank,
			"rights" = rights,
		)

	qdel(query)

	if(usr.ckey in ranks)
		return

	if(CONFIG_GET(flag/disable_localhost_admin))
		return

	if(!usr.client.is_connecting_from_localhost())
		return

	ranks[usr.ckey] = list(
				"rank" = "!LOCALHOST!",
				"rights" = R_HOST,
			)

/datum/ui_module/permissions_edit/ui_state(mob/user)
	return GLOB.admin_state

/datum/ui_module/permissions_edit/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PermissionsEdit", name)
		ui.open()

/datum/ui_module/permissions_edit/ui_static_data(mob/user)
	. = list()
	.["possible_permissions"] = GLOB.permissions_name_to_flag
	.["possible_ranks"] = GLOB.admin_ranks
	return .

/datum/ui_module/permissions_edit/ui_data(mob/user)
	. = list()
	var/list/admins = list()
	for(var/adm_ckey in ranks)
		admins += list(
			list(
				"ckey" = adm_ckey,
				"rank" = ranks[adm_ckey]["rank"] ? ranks[adm_ckey]["rank"] : NONE_SELECT,
				"flags" = rights2text_tgui(ranks[adm_ckey]["rights"]),
				"de_admin" = (adm_ckey in GLOB.de_admins) || (adm_ckey in GLOB.de_mentors) || (adm_ckey in GLOB.de_devs)
			)
		)

	.["admins"] = admins
	return .


/datum/ui_module/permissions_edit/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	if(!check_rights(R_PERMISSIONS))
		return

	if(IsAdminAdvancedProcCall())
		to_chat(usr, span_boldannounceooc("Admin edit blocked: Advanced ProcCall detected."))
		log_and_message_admins("attempted to edit admin ranks via advanced proc-call")
		return

	switch(action)
		if("load_preset")
			var/ckey = params["selected_ckey"]
			var/preset = params["selected_preset"]
			var/permissions = GLOB.admin_ranks[preset]
			if(!update_permissions(ckey, permissions))
				return
			log_and_message_admins("sets [preset] preset to [ckey]")
			return TRUE

		if("edit_rank")
			var/ckey = params["ckey"]
			var/rank = params["rank"]

			if(!istext(ckey) || !istext(rank))
				return


			usr.client.holder.update_rank_to_db(ckey, rank)
			usr.client.holder.admin_rank_only_modification(ckey, rank)
			ranks[ckey]["rank"] = rank

			if(rank == DELETED_RANK)
				clear_admin_datum(ckey)
				log_and_message_admins("sets [rank] rank to [ckey].")
				return

			var/datum/admins/admin = GLOB.admin_datums[ckey]
			admin.rank = rank
			log_and_message_admins("sets [rank] rank to [ckey].")
			return TRUE

		if("add_flag")
			var/ckey = params["ckey"]
			var/flag = params["selected_flag"]
			var/permissions = ranks[ckey]["rights"] | GLOB.permissions_name_to_flag[flag]
			if(!update_permissions(ckey, permissions))
				return
			log_and_message_admins("add [flag] flag to [ckey]")
			return TRUE

		if("remove_flag")
			var/ckey = params["ckey"]
			var/flag = params["selected_flag"]
			var/permissions = ranks[ckey]["rights"] & ~GLOB.permissions_name_to_flag[flag]
			if(!update_permissions(ckey, permissions))
				return
			log_and_message_admins("remove [flag] flag from [ckey]")
			return TRUE

		if("force_re_admin")
			var/ckey = params["ckey"]
			force_re_admin(ckey)
			return TRUE

		if("force_de_admin")
			var/ckey = params["ckey"]
			force_de_admin(ckey)
			return TRUE

		if("remove_admin")
			var/ckey = params["ckey"]
			var/result = tgui_alert(
				usr,
				"Вы действительно хотите это сделать? Это полностью удалит запись со всеми флагами и рангом. Если есть хотя бы шанс, что человек вернется на свой пост - просто выставьте ранг [DELETED_RANK]. Это заблокирует загрузку прав из БД, но не удалит запись полностью.",
				"Предупреждение",
				list("Да", "Нет")
			)
			if(result == "Нет")
				return
			remove_admin(ckey)
			return TRUE

		if("create_new_admin")
			var/ckey = params["ckey"]
			var/rank = params["rank"]
			var/preset = params["preset"]
			var/permissions = GLOB.admin_ranks[preset]
			add_new_admin(ckey, rank, permissions)


/datum/ui_module/permissions_edit/proc/update_permissions(ckey, permissions)
	if(IsAdminAdvancedProcCall())
		to_chat(usr, span_boldannounceooc("Admin edit blocked: Advanced ProcCall detected."))
		log_and_message_admins("attempted to edit admin ranks via advanced proc-call")
		return

	if(!istext(ckey) || !isnum(permissions))
		return FALSE

	usr.client.holder.admin_permission_modification(ckey, permissions)
	var/datum/admins/admin = GLOB.admin_datums[ckey]
	if(admin)
		admin.rights = permissions
	ranks[ckey]["rights"] = permissions
	update_byond_configs(ckey, permissions)
	var/client/client = GLOB.directory[ckey]
	update_buttons(client)
	return TRUE

/datum/ui_module/permissions_edit/proc/update_byond_configs(ckey, permissions)
	if(IsAdminAdvancedProcCall())
		to_chat(usr, span_boldannounceooc("Admin edit blocked: Advanced ProcCall detected."))
		log_and_message_admins("attempted to edit admin ranks via advanced proc-call")
		return

	if(permissions & R_DEBUG || permissions & R_VIEWRUNTIMES)
		world.SetConfig("APP/admin", ckey, "role=admin")
		return

	world.SetConfig("APP/admin", ckey, null)

/datum/ui_module/permissions_edit/proc/force_re_admin(ckey)
	if(IsAdminAdvancedProcCall())
		to_chat(usr, span_boldannounceooc("Admin edit blocked: Advanced ProcCall detected."))
		log_and_message_admins("attempted to edit admin ranks via advanced proc-call")
		return

	var/datum/admins/admin_datum

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
			to_chat(src, "Error while re-adminning, ckey [admin_ckey] was not found in the admin database.", confidential = TRUE)
			qdel(admin_read)
			return

		if(admin_rank == DELETED_RANK) //This person was de-adminned. They are only in the admin list for archive purposes.
			to_chat(src, "Error while re-adminning, ckey [admin_ckey] is not an admin.", confidential = TRUE)
			qdel(admin_read)
			return

		if(istext(flags))
			flags = text2num(flags)

		admin_datum = new(admin_rank, flags, ckey)

	qdel(admin_read)
	var/client/client = GLOB.directory[ckey]
	admin_datum.associate(client)
	log_and_message_admins("force re-admin [ckey]")
	GLOB.de_admins -= ckey
	GLOB.de_mentors -= ckey
	GLOB.de_devs -= ckey
	update_buttons(client)
	remove_verb(client, /client/proc/readmin)
	BLACKBOX_LOG_ADMIN_VERB("Re-admin")

/datum/ui_module/permissions_edit/proc/clear_admin_datum(ckey)
	var/client/client = GLOB.directory[ckey]
	client?.deadmin()
	update_buttons(client)
	var/datum/admins/admin_datum = GLOB.admin_datums[ckey]

	if(!QDELETED(admin_datum))
		qdel(admin_datum)

	GLOB.admin_datums -= ckey

/datum/ui_module/permissions_edit/proc/force_de_admin(ckey)
	if(IsAdminAdvancedProcCall())
		to_chat(usr, span_boldannounceooc("Admin edit blocked: Advanced ProcCall detected."))
		log_and_message_admins("attempted to edit admin ranks via advanced proc-call")
		return

	var/client/client = GLOB.directory[ckey]

	if(!client)
		return

	if(check_rights(R_ADMIN, FALSE, client.mob))
		GLOB.de_admins |= ckey
	else if(check_rights(R_MENTOR, FALSE, client.mob))
		GLOB.de_mentors |= ckey
	else
		GLOB.de_devs |= ckey

	client.deadmin()
	update_buttons(client)
	add_verb(client, /client/proc/readmin)
	to_chat(client, span_interface("You are now a normal player."), confidential = TRUE)
	log_and_message_admins("force de-admin [ckey].")
	BLACKBOX_LOG_ADMIN_VERB("De-admin")

/datum/ui_module/permissions_edit/proc/remove_admin(ckey)
	if(IsAdminAdvancedProcCall())
		to_chat(usr, span_boldannounceooc("Admin edit blocked: Advanced ProcCall detected."))
		log_and_message_admins("attempted to edit admin ranks via advanced proc-call")
		return

	usr.client.holder.update_rank_to_db(ckey, PLAYER_RANK)

	var/admin_id = usr.client.holder.check_admin_exist(ckey)

	if(!admin_id)
		return

	var/datum/db_query/delete_query = SSdbcore.NewQuery("DELETE FROM [format_table_name("admin")] WHERE id=:adm_id", list(
		"adm_id" = admin_id
	))

	if(!delete_query.warn_execute())
		qdel(delete_query)
		return null

	qdel(delete_query)
	clear_admin_datum(ckey)

	ranks -= ckey
	flag_account_for_forum_sync(ckey)
	var/logtxt = "Admin [ckey] removed"
	usr.client.holder.log_admin_modification(logtxt)
	log_and_message_admins("remove admin [ckey]")

/datum/ui_module/permissions_edit/proc/add_new_admin(ckey, rank, rights = 0)
	if(IsAdminAdvancedProcCall())
		to_chat(usr, span_boldannounceooc("Admin edit blocked: Advanced ProcCall detected."))
		log_and_message_admins("attempted to edit admin ranks via advanced proc-call")
		return

	if(!istext(ckey) || !istext(rank))
		return

	if(!isnum(rights))
		rights = 0

	usr.client.holder.admin_rank_modification(ckey, rank, rights)
	usr.client.holder.update_rank_to_db(ckey, rank)
	var/client/client = GLOB.directory[ckey]
	var/datum/admins/new_rank = new(rank, rights, ckey)

	if(client)
		new_rank.associate(client)
		update_buttons(client)

	ranks[ckey] = list(
				"rank" = rank,
				"rights" = rights,
			)
	log_and_message_admins("add new admin [ckey] to rank [rank] with permissions [rights2text(rights, " ")]")

/datum/ui_module/permissions_edit/proc/update_buttons(client/client)
	if(!client)
		return

	client.update_active_keybindings()
	client.hide_verbs()
	client.init_verbs()
	client.add_admin_verbs()

	var/mob = client.mob
	if(!isobserver(mob))
		return

	var/mob/dead/observer/observer = mob
	observer.update_admin_actions()

/client/proc/edit_admin_permissions_new()
	set category = STATPANEL_ADMIN_ADMIN
	set name = "Permissions Panel (New)"
	set desc = "Edit admin permissions"

	if(!check_rights(R_PERMISSIONS))
		return

	if(!SSdbcore.IsConnected())
		edit_admin_permissions()
		return

	var/datum/ui_module/permissions_edit/panel = new(src)
	panel.ui_interact(usr)
	qdel(panel)
