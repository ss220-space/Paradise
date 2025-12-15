/datum/admins/proc/admin_rank_modification(adm_ckey, new_rank, new_rigths = 0)
	if(!check_rights(R_PERMISSIONS))
		return

	if(!SSdbcore.IsConnected())
		to_chat(usr, span_warning("Failed to establish database connection"))
		return

	if(!adm_ckey || !new_rank)
		return

	adm_ckey = ckey(adm_ckey)

	if(!adm_ckey)
		return

	if(!istext(adm_ckey) || !istext(new_rank))
		return

	var/admin_id = check_admin_exist(adm_ckey)

	flag_account_for_forum_sync(adm_ckey)
	if(!admin_id)
		var/datum/db_query/insert_query = SSdbcore.NewQuery("INSERT INTO [format_table_name("admin")] (`id`, `ckey`, `rank`, `level`, `flags`) VALUES (null, :adm_ckey, :new_rank, -1, :new_flags)", list(
			"adm_ckey" = adm_ckey,
			"new_rank" = new_rank,
			"new_flags" = new_rigths
		))
		if(!insert_query.warn_execute())
			qdel(insert_query)
			return
		qdel(insert_query)

		var/logtxt = "Added new admin [adm_ckey] to rank [new_rank] with permissions [rights2text(new_rigths, " ")]"
		log_admin_modification(logtxt)
		to_chat(usr, span_notice("New admin added."))
		return

	if(isnull(admin_id) || !isnum(admin_id))
		return

	var/datum/db_query/insert_query = SSdbcore.NewQuery("UPDATE [format_table_name("admin")] SET rank=:new_rank, flags=:new_flags WHERE id=:admin_id", list(
		"new_rank" = new_rank,
		"new_flags" = new_rigths,
		"admin_id" = admin_id,
	))
	if(!insert_query.warn_execute())
		qdel(insert_query)
		return
	qdel(insert_query)

	var/logtxt = "Edited the rank of [adm_ckey] to [new_rank] with permissions [rights2text(new_rigths, " ")]"
	log_admin_modification(logtxt)
	to_chat(usr, span_notice("Admin rank changed."))

/datum/admins/proc/admin_rank_only_modification(adm_ckey, new_rank)
	if(!check_rights(R_PERMISSIONS))
		return

	if(!SSdbcore.IsConnected())
		to_chat(usr, span_warning("Failed to establish database connection"))
		return

	if(!adm_ckey || !new_rank)
		return

	adm_ckey = ckey(adm_ckey)

	if(!adm_ckey)
		return

	if(!istext(adm_ckey) || !istext(new_rank))
		return

	var/admin_id = check_admin_exist(adm_ckey)

	flag_account_for_forum_sync(adm_ckey)

	var/datum/db_query/insert_query = SSdbcore.NewQuery("UPDATE [format_table_name("admin")] SET rank=:new_rank WHERE id=:admin_id", list(
		"new_rank" = new_rank,
		"admin_id" = admin_id,
	))

	if(!insert_query.warn_execute())
		qdel(insert_query)
		return

	qdel(insert_query)

	var/logtxt = "Edited the rank of [adm_ckey] to [new_rank]"
	log_admin_modification(logtxt)
	to_chat(usr, span_notice("Admin rank changed."))

/datum/admins/proc/admin_permission_modification(adm_ckey, new_permission)
	if(IsAdminAdvancedProcCall())
		to_chat(usr, span_boldannounceooc("Admin edit blocked: Advanced ProcCall detected."))
		log_and_message_admins("attempted to edit admin ranks via advanced proc-call")
		return

	if(!check_rights(R_PERMISSIONS))
		return

	if(!SSdbcore.IsConnected())
		to_chat(usr, span_warning("Failed to establish database connection"))
		return

	if(!adm_ckey || isnull(new_permission))
		return

	adm_ckey = ckey(adm_ckey)

	if(!adm_ckey)
		return

	if(istext(new_permission))
		new_permission = text2num(new_permission)

	if(!istext(adm_ckey) || !isnum(new_permission))
		return

	var/admin_id = check_admin_exist(adm_ckey)
	if(!admin_id)
		return

	flag_account_for_forum_sync(adm_ckey)
	var/datum/db_query/insert_query = SSdbcore.NewQuery("UPDATE [format_table_name("admin")] SET flags=:newflags WHERE id=:admin_id", list(
		"newflags" = new_permission,
		"admin_id" = admin_id
	))
	if(!insert_query.warn_execute())
		qdel(insert_query)
		return
	qdel(insert_query)

	var/logtxt = "Updated permission [rights2text(new_permission, " ")] (flags = [new_permission]) to admin [adm_ckey]"
	log_admin_modification(logtxt)
	to_chat(usr, span_notice("Permission Updated."))

/datum/admins/proc/update_rank_to_db(ckey, new_rank)
	if(IsAdminAdvancedProcCall())
		to_chat(usr, span_boldannounceooc("Admin edit blocked: Advanced ProcCall detected."))
		log_and_message_admins("attempted to edit admin ranks via advanced proc-call")
		return

	if(!SSdbcore.IsConnected())
		return

	if(!check_rights(R_PERMISSIONS))
		return

	if(!ckey || !new_rank)
		return

	var/datum/db_query/query_update = SSdbcore.NewQuery("UPDATE [format_table_name("player")] SET lastadminrank=:admin_rank WHERE ckey=:ckey", list(
		"admin_rank" = new_rank,
		"ckey" = ckey
	))

	if(!query_update.warn_execute())
		qdel(query_update)
		return

	qdel(query_update)

/datum/admins/proc/check_admin_exist(admin_ckey)
	var/datum/db_query/select_query = SSdbcore.NewQuery("SELECT id FROM [format_table_name("admin")] WHERE ckey=:adm_ckey", list(
		"adm_ckey" = admin_ckey
	))
	if(!select_query.warn_execute())
		qdel(select_query)
		return null

	var/admin_id

	while(select_query.NextRow())
		admin_id = text2num(select_query.item[1])

	qdel(select_query)
	if(!admin_id)
		return admin_id
	return admin_id

/datum/admins/proc/log_admin_modification(logtxt)
	var/datum/db_query/log_query = SSdbcore.NewQuery({"
		INSERT INTO [format_table_name("admin_log")] (`datetime` ,`adminckey` ,`adminip` ,`log`)
		VALUES (Now() , :uckey, :uip, :logtxt)"}, list(
			"uckey" = usr.ckey,
			"uip" = usr.client.address,
			"logtxt" = logtxt
		))

	if(!log_query.warn_execute())
		qdel(log_query)
		return

	qdel(log_query)

// TODO: remove with legacy admin system
ADMIN_VERB(edit_admin_permissions_legacy, R_PERMISSIONS, "Permissions Panel (Legacy)", "Edit admin permissions.", ADMIN_CATEGORY_MAIN)
	user.holder.edit_admin_permissions()

/datum/admins/proc/edit_admin_permissions()
	if(!check_rights(R_PERMISSIONS))
		return

	var/datum/asset/permissions_asset = get_asset_datum(/datum/asset/simple/permissions)
	permissions_asset.send(usr)

	var/output = {"
<body onload='selectTextField(); updateSearch();'>
<style>
table {
	table-layout: fixed; /* Фиксирует ширину колонок */
	width: 100%; /* Заставляет таблицу занимать всю доступную ширину */
	border-collapse: collapse;
	max-width: 100%;
}

#main {
	overflow:hidden;
	max-width: 600px;
}

td, th {
	overflow: hidden; /* Скрывает содержимое, выходящее за пределы */
	white-space: nowrap; /* Запрещает перенос текста */
	margin: 5px;
	text-align:center;
}

</style>
<div id='main'>
<table id='searchable'>
<colgroup>
	<col style='width: 20%;'>
	<col style='width: 20%;'>
	<col style='width: 60%;'>
</colgroup>
<thead>
<tr class='title'>
<th>CKEY <a class='small' href='byond://?src=[UID()];editrights=add'>\[+\]</a></th>
<th>RANK</th>
<th>PERMISSIONS</th>
</tr>
</thead>
<tbody>
"}

	for(var/adm_ckey in GLOB.admin_datums)
		var/datum/admins/D = GLOB.admin_datums[adm_ckey]
		if(!D)	continue
		var/rank = D.rank ? D.rank : NONE_SELECT
		var/rights = rights2text(D.rights," ")
		if(!rights)
			rights = NONE_SELECT
		output += {"<tr>
<td style='min-width: 20%;'>[adm_ckey] <a class='small' href='byond://?src=[UID()];editrights=remove;ckey=[adm_ckey]'>\[-\]</a></td>
<td slyle='min-width: 20%;'><a href='byond://?src=[UID()];editrights=rank;ckey=[adm_ckey]'>[rank]</a></td>
<td style='min-width: 60%;'><a class='small' href='byond://?src=[UID()];editrights=permissions;ckey=[adm_ckey]'>[rights]</a></td>
</tr>"}

	output += {"
</tbody>
</table>
</div>
<div id='top'><b>Search:</b> <input type='text' id='filter' value='' style='width:70%;' onkeyup='updateSearch();'></div>
</body>
"}

	var/datum/browser/popup = new(usr, "editrights", "<div align='center'>Permissions Panel</div>", 600, 500)
	popup.set_content(output)
	popup.set_window_options("can_close=1;can_minimize=0;can_maximize=0;can_resize=0;titlebar=1;")
	//popup.add_stylesheet("dark_inputs", "html/panels.css")
	popup.add_stylesheet("dark_inputs", "html/dark_inputs.css")
	popup.add_script("search", "html/search.js")
	popup.open()
	onclose(usr, "editrights")

/datum/admins/proc/permissions_topic(task, ckey)
	if(!check_rights(R_PERMISSIONS))
		log_and_message_admins("attempted to edit the admin permissions without sufficient rights.")
		return
	var/adm_ckey
	if(task == "add")
		var/new_ckey = ckey(tgui_input_text(usr, "Сикей нового админа", "Добавление админа", null, encode=FALSE))
		if(!new_ckey)	return
		if(new_ckey in GLOB.admin_datums)
			to_chat(usr, "<span style='color: red;'>Ошибка: Topic 'editrights': [new_ckey] уже админ!</span>", confidential=TRUE)
			return
		adm_ckey = new_ckey
		task = "rank"
	else if(task != "show")
		adm_ckey = ckey(ckey)
		if(!adm_ckey)
			to_chat(usr, "<span style='color: red;'>Ошибка: Topic 'editrights': Неверный сикей</span>", confidential=TRUE)
			return

	var/datum/admins/D = GLOB.admin_datums[adm_ckey]

	if(task == "remove")
		if(tgui_alert(usr, "Вы уверены что хотите удалить [adm_ckey]?","Внимание!",list("Да", "Отмена")) == "Да")
			if(!D)	return
			GLOB.admin_datums -= adm_ckey
			D.disassociate()

			update_rank_to_db(adm_ckey, PLAYER_RANK)
			message_admins("[key_name_admin(usr)] удалил [adm_ckey] из списка админов")
			log_admin("[key_name(usr)] удалил [adm_ckey] из списка админов")
			admin_rank_modification(adm_ckey, DELETED_RANK)

	else if(task == "rank")
		var/new_rank
		if(length(GLOB.admin_ranks))
			new_rank = tgui_input_list(usr, "Выберите стандартный ранг или создайте новый", "Выбор ранга", (GLOB.admin_ranks|"*Новый Ранг*"), null)
		else
			CRASH("GLOB.admin_ranks is empty, inform coders")

		var/rights = 0
		if(D)
			rights = D.rights
		switch(new_rank)
			if(null, "")
				return
			if("*Новый Ранг*")
				new_rank = tgui_input_text(usr, "Введите название нового ранга", "Новый Ранг", null, encode = FALSE)
				if(!new_rank)
					to_chat(usr, "<span style='color: red;'>Ошибка: Topic 'editrights': Неверный ранг</span>", confidential=TRUE)
					return
				if(new_rank in GLOB.admin_ranks)
					rights = GLOB.admin_ranks[new_rank]		//we typed a rank which already exists, use its rights
				else
					GLOB.admin_ranks[new_rank] = 0			//add the new rank to admin_ranks
			else
				rights = GLOB.admin_ranks[new_rank]				//we input an existing rank, use its rights

		if(D)
			D.disassociate()								//remove adminverbs and unlink from client
			D.rank = new_rank								//update the rank
			D.rights = rights								//update the rights based on admin_ranks (default: 0)
		else
			D = new /datum/admins(new_rank, rights, adm_ckey)

		var/client/C = GLOB.directory[adm_ckey]						//find the client with the specified ckey (if they are logged in)
		D.associate(C)											//link up with the client and add verbs

		update_rank_to_db(adm_ckey, new_rank)
		message_admins("[key_name_admin(usr)] изменил ранг админа [adm_ckey] на [new_rank]")
		log_admin("[key_name(usr)] изменил ранг админа [adm_ckey] на [new_rank]")
		admin_rank_modification(adm_ckey, new_rank, rights)

	else if(task == "permissions")
		if(!D)
			return
		var/new_value = input_bitfield(usr, "rights", D.rights)
		if(!new_value)
			return
		var/add_bits = new_value & ~D.rights
		var/removed_bits = D.rights & ~new_value
		D.rights = new_value
		edit_admin_permissions()
		message_admins("[key_name_admin(usr)] переключил флаги админу [adm_ckey]: [add_bits? " ВКЛ — [rights2text(add_bits, " ")]" : ""][removed_bits? " ВЫКЛ — [rights2text(removed_bits, " ")]":""]")
		log_admin("[key_name(usr)] переключил флаги админу [adm_ckey]: [add_bits? " ВКЛ — [rights2text(add_bits, " ")]" : ""][removed_bits? " ВЫКЛ — [rights2text(removed_bits, " ")]":""]")
		admin_permission_modification(adm_ckey, new_value )

	edit_admin_permissions()
