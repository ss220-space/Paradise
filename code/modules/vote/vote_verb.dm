/client/verb/vote()
	set category = STATPANEL_OOC
	set name = "Голосование"

	if(SSvote.active_vote)
		SSvote.active_vote.ui_interact(usr)
	else
		to_chat(usr, "<b>Нет активного голосования!<b>")

/mob/proc/immediate_vote()
	if(SSvote.active_vote)
		SSvote.active_vote.ui_interact(src)
	else
		to_chat(src, "<b>Нет активного голосования!<b>")

/client/proc/start_vote()
	set category = STATPANEL_ADMIN_ADMIN
	set name = "Start Vote"
	set desc = "Start a vote on the server"

	if(!check_rights(R_ADMIN))
		return


	// Ask admins which type of vote they want to start
	var/vote_types = subtypesof(/datum/vote)
	vote_types |= "\[CUSTOM]"

	// This needs to be a map to instance it properly. I do hate it as well, dont worry.
	var/list/votemap = list()
	for(var/vtype in vote_types)
		votemap["[vtype]"] = vtype

	var/choice = tgui_input_list(usr, "Select a vote type", "Vote", vote_types)

	if(choice == null)
		return

	if(choice != "\[CUSTOM]")
		// Not custom, figure it out
		var/datum/vote/votetype = votemap["[choice]"]
		SSvote.start_vote(new votetype(usr.ckey))
		return

	// Its custom, lets ask
	var/question = tgui_input_text(usr, "What is the vote for?", "Create Vote", encode = FALSE)
	if(isnull(question))
		return

	var/list/choices = list()
	for(var/i in 1 to 10)
		var/option = tgui_input_text(usr, "Please enter an option or hit cancel to finish", "Create Vote", encode = FALSE)
		if(isnull(option) || !usr.client)
			break
		choices |= option

	var/c2 = tgui_alert(usr, "Show counts while vote is happening?", "Counts", list("Yes", "No"))
	var/c3 = tgui_input_list(usr, "Select a result calculation type", "Vote", list(VOTE_RESULT_TYPE_MAJORITY), VOTE_RESULT_TYPE_MAJORITY)

	var/datum/vote/V = new /datum/vote(usr.ckey, question, choices, TRUE)
	V.show_counts = (c2 == "Yes")
	V.vote_result_type = c3
	SSvote.start_vote(V)
	BLACKBOX_LOG_ADMIN_VERB("Start Vote")

/datum/admins/proc/togglevotedead()
	set category = STATPANEL_ADMIN_TOGGLES
	set desc = "Toggle Dead Vote."
	set name = "Toggle Dead Vote"

	if(!check_rights(R_ADMIN))
		return

	if(!SSvote.active_vote)
		to_chat(usr, "<b>Нет активного голосования!</b>")
		return

	SSvote.active_vote.no_dead_vote = !SSvote.active_vote.no_dead_vote
	if(SSvote.active_vote.no_dead_vote)
		to_chat(world, "<b>Dead Vote has been disabled!</b>")
	else
		to_chat(world, "<b>Dead Vote has been enabled!</b>")
	log_and_message_admins("toggled Dead Vote.")
	BLACKBOX_LOG_ADMIN_VERB("Toggle Dead Vote")
