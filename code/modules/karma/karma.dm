//#define KARMA_ENABLE

/*	KARMA
	Everything karma related is here.
	Part of karma purchase is handled in client_procs.dm	*/

/proc/sql_report_karma(var/mob/spender, var/mob/receiver)
	var/receiverrole = "None"
	var/receiverspecial = "None"

	if(receiver.mind)
		if(receiver.mind.special_role)
			receiverspecial = receiver.mind.special_role
		if(receiver.mind.assigned_role)
			receiverrole = receiver.mind.assigned_role

	if(!SSdbcore.IsConnected())
		return

	var/datum/db_query/log_query = SSdbcore.NewQuery({"
		INSERT INTO [format_table_name("karma")] (spendername, spenderkey, receivername, receiverkey, receiverrole, receiverspecial, spenderip, time)
		VALUES (:sname, :skey, :rname, :rkey, :rrole, :rspecial, :sip, Now())"}, list(
			"sname" = spender.name,
			"skey" = spender.ckey,
			"rname" = receiver.name,
			"rkey" = receiver.ckey,
			"rrole" = receiverrole,
			"rspecial" = receiverspecial,
			"sip" = spender.client.address
		))

	if(!log_query.warn_execute())
		qdel(log_query)
		return

	qdel(log_query)

	var/datum/db_query/select_spender = SSdbcore.NewQuery("SELECT id, karma FROM [format_table_name("karmatotals")] WHERE byondkey=:rkey", list(
		"rkey" = receiver.ckey
	))

	if(!select_spender.warn_execute())
		qdel(select_spender)
		return

	var/karma
	var/id
	while(select_spender.NextRow())
		id = select_spender.item[1]
		karma = text2num(select_spender.item[2])

	qdel(select_spender)

	if(karma == null)
		karma = 1

		var/datum/db_query/insert_query = SSdbcore.NewQuery("INSERT INTO [format_table_name("karmatotals")] (byondkey, karma) VALUES (:rkey, :karma)", list(
			"rkey" = receiver.ckey,
			"karma" = karma
		))
		if(!insert_query.warn_execute())
			qdel(insert_query)
			return
		qdel(insert_query)
	else
		karma++
		var/datum/db_query/update_query = SSdbcore.NewQuery("UPDATE [format_table_name("karmatotals")] SET karma=:karma WHERE id=:id", list(
			"karma" = karma,
			"id" = id
		))
		if(!update_query.warn_execute())
			qdel(update_query)
			return
		qdel(update_query)

GLOBAL_LIST_EMPTY(karma_spenders)

// Returns TRUE if mob can give karma at all; if not, tells them why
/mob/proc/can_give_karma()
	if(!client)
		to_chat(src, "<span class='warning'>You can't award karma without being connected.</span>")
		return FALSE
	if(CONFIG_GET(flag/disable_karma))
		to_chat(src, "<span class='warning'>Karma is disabled.</span>")
		return FALSE
	if(!SSticker || !GLOB.player_list.len || (SSticker.current_state == GAME_STATE_PREGAME))
		to_chat(src, "<span class='warning'>You can't award karma until the game has started.</span>")
		return FALSE
	if(client.karma_spent || (ckey in GLOB.karma_spenders))
		to_chat(src, "<span class='warning'>You've already spent your karma for the round.</span>")
		return FALSE
	return TRUE

// Returns TRUE if mob can give karma to M; if not, tells them why
/mob/proc/can_give_karma_to_mob(mob/M)
	if(!can_give_karma())
		return FALSE
	if(!istype(M))
		to_chat(src, "<span class='warning'>That's not a mob.</span>")
		return FALSE
	if(!M.client)
		to_chat(src, "<span class='warning'>That mob has no client connected at the moment.</span>")
		return FALSE
	if(M.ckey == ckey)
		to_chat(src, "<span class='warning'>You can't spend karma on yourself!</span>")
		return FALSE
	if(client.address == M.client.address)
		message_admins("<span class='warning'>Illegal karma spending attempt detected from [key] to [M.key]. Using the same IP!</span>")
		add_game_logs("Illegal karma spending attempt detected from [key] to [M.key]. Using the same IP!")
		to_chat(src, "<span class='warning'>You can't spend karma on someone connected from the same IP.</span>")
		return FALSE
	if(M.get_preference(PREFTOGGLE_DISABLE_KARMA))
		to_chat(src, "<span class='warning'>That player has turned off incoming karma.")
		return FALSE
	return TRUE

#ifdef KARMA_ENABLE

/mob/verb/spend_karma_list()
	set name = "Award Karma"
	set desc = "Let the gods know whether someone's been nice. Can only be used once per round."
	set category = "Special Verbs"

	if(!can_give_karma())
		return

	var/list/karma_list = list()
	for(var/mob/M in GLOB.player_list)
		if(!(M.client && M.mind))
			continue
		if(M == src)
			continue
		if(!isobserver(src) && isNonCrewAntag(M))
			continue // Don't include special roles for non-observers, because players use it to meta
		karma_list += M

	if(!karma_list.len)
		to_chat(usr, "<span class='warning'>There's no-one to spend your karma on.</span>")
		return

	var/pickedmob = input("Who would you like to award Karma to?", "Award Karma", "Cancel") as null|mob in karma_list

	if(isnull(pickedmob))
		return

	spend_karma(pickedmob)

/mob/verb/spend_karma(var/mob/M)
	set name = "Award Karma to Player"
	set desc = "Let the gods know whether someone's been nice. Can only be used once per round."
	set category = "Special Verbs"

	if(!M)
		to_chat(usr, "Please right click a mob to award karma directly, or use the 'Award Karma' verb to select a player from the player listing.")
		return
	if(CONFIG_GET(flag/disable_karma)) // this is here because someone thought it was a good idea to add an alert box before checking if they can even give a mob karma
		to_chat(usr, "<span class='warning'>Karma is disabled.</span>")
		return
	if(alert("Give [M.name] good karma?", "Karma", "Yes", "No") != "Yes")
		return
	if(!can_give_karma_to_mob(M))
		return // Check again, just in case things changed while the alert box was up

	M.client.karma++
	to_chat(usr, "Good karma spent on [M.name].")
	client.karma_spent = TRUE
	GLOB.karma_spenders += ckey

	var/special_role = "None"
	var/assigned_role = "None"
	var/karma_diary = wrap_file("[GLOB.log_directory]/karma.log")
	if(M.mind)
		if(M.mind.special_role)
			special_role = M.mind.special_role
		if(M.mind.assigned_role)
			assigned_role = M.mind.assigned_role
	karma_diary << "[M.name] ([M.key]) [assigned_role]/[special_role]: [M.client.karma] - [time2text(world.timeofday, "hh:mm:ss")] given by [key]"

	sql_report_karma(src, M)

/client/verb/check_karma()
	set name = "Check Karma"
	set desc = "Reports how much karma you have accrued."
	set category = "Special Verbs"

	if(CONFIG_GET(flag/disable_karma))
		to_chat(src, "<span class='warning'>Karma is disabled.</span>")
		return

	var/currentkarma = verify_karma()
	if(!isnull(currentkarma))
		to_chat(usr, {"<br>You have <b>[currentkarma]</b> available."})

/client/proc/verify_karma()
	var/currentkarma = 0
	if(!SSdbcore.IsConnected())
		to_chat(usr, "<span class='warning'>Unable to connect to karma database. Please try again later.<br></span>")
		return

	var/datum/db_query/query = SSdbcore.NewQuery("SELECT karma, karmaspent FROM [format_table_name("karmatotals")] WHERE byondkey=:ckey", list(
		"ckey" = ckey
	))
	if(!query.warn_execute())
		qdel(query)
		return

	var/totalkarma
	var/karmaspent
	while(query.NextRow())
		totalkarma = query.item[1]
		karmaspent = query.item[2]
	qdel(query)
	currentkarma = (text2num(totalkarma) - text2num(karmaspent))

	return currentkarma

#endif
