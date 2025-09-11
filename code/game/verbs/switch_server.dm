#ifdef MULTIINSTANCE
/client/verb/switch_server()
	set name = "Switch Server"
	set desc = "Switch to a different Paradise server"
	set category = STATPANEL_OOC

	// First get our peers
	var/datum/db_query/dbq1 = SSdbcore.NewQuery({"
		SELECT server_id, key_name, key_value FROM instance_data_cache WHERE server_id IN
		(SELECT server_id FROM instance_data_cache WHERE
		key_name='heartbeat' AND last_updated BETWEEN NOW() - INTERVAL 60 SECOND AND NOW())
		AND key_name IN ("playercount", "server_port", "server_name")"})
	if(!dbq1.warn_execute())
		qdel(dbq1)
		return

	var/servers_outer = list()
	while(dbq1.NextRow())
		if(!servers_outer[dbq1.item[1]])
			servers_outer[dbq1.item[1]] = list()

		servers_outer[dbq1.item[1]][dbq1.item[2]] = dbq1.item[3] // This should assoc load our data

	qdel(dbq1) //clear our query
	// Format the server names into an assoc list of K: name V: port
	var/list/formatted_servers = list()
	for(var/server in servers_outer)
		var/server_data = servers_outer[server]
		formatted_servers["[server_data["server_name"]] - ([server_data["playercount"]] playing)"] = text2num(server_data["server_port"])

	if(length(formatted_servers) == 1)
		to_chat(usr, span_warning("Вы уже подключены к единственному серверу!"))
		return

	var/selected_server = tgui_input_list(usr, "Выберите сервер", "Выбор сервера", formatted_servers)
	if(!selected_server)
		return

	if(formatted_servers[selected_server] == world.port)
		to_chat(usr, span_warning("Вы уже подключены к данному серверу."))
		return

	// Now we reconnect them
	to_chat(usr, span_notice("Подключение к: [span_bold(selected_server)]..."))

	// Formulate a connection URL
	var/target = "byond://[world.internet_address]:[formatted_servers[selected_server]]"
	src << link(target)
#endif
