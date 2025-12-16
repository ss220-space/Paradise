/client/verb/vote()
	set category = VERB_CATEGORY_OOC
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

ADMIN_VERB(start_vote, R_ADMIN, "Start Vote", "Start a vote on the server.", ADMIN_CATEGORY_MAIN)
	// Ask admins which type of vote they want to start
	var/vote_types = subtypesof(/datum/vote)
	vote_types |= "\[CUSTOM\]"

	// This needs to be a map to instance it properly. I do hate it as well, dont worry.
	var/list/votemap = list()
	for(var/vtype in vote_types)
		votemap["[vtype]"] = vtype

	var/choice = tgui_input_list(user, "Select a vote type", "Vote", vote_types)

	if(choice == null)
		return

	if(choice != "\[CUSTOM\]")
		// Not custom, figure it out
		var/datum/vote/votetype = votemap["[choice]"]
		SSvote.start_vote(new votetype(user.ckey))
		return

	// Its custom, lets ask
	var/question = tgui_input_text(user, "What is the vote for?", "Create Vote", encode = FALSE)
	if(isnull(question))
		return

	var/list/choices = list()
	for(var/i in 1 to 10)
		var/option = tgui_input_text(user, "Please enter an option or hit cancel to finish", "Create Vote", encode = FALSE)
		if(isnull(option) || !user)
			break
		choices |= option

	var/c2 = tgui_alert(user, "Show counts while vote is happening?", "Counts", list("Yes", "No"))
	var/c3 = tgui_input_list(user, "Select a result calculation type", "Vote", list(VOTE_RESULT_TYPE_MAJORITY), VOTE_RESULT_TYPE_MAJORITY)

	var/datum/vote/V = new /datum/vote(user.ckey, question, choices, TRUE)
	V.show_counts = (c2 == "Yes")
	V.vote_result_type = c3
	SSvote.start_vote(V)
	BLACKBOX_LOG_ADMIN_VERB("Start Vote")

ADMIN_VERB(togglevotedead, R_ADMIN, "Toggle Dead Vote", "Allow the dead to vote.", ADMIN_CATEGORY_TOGGLES)
	if(!SSvote.active_vote)
		to_chat(user, "<b>Нет активного голосования!</b>")
		return

	SSvote.active_vote.no_dead_vote = !SSvote.active_vote.no_dead_vote
	SSvote.active_vote.no_offstation_vote = !SSvote.active_vote.no_offstation_vote
	if(SSvote.active_vote.no_dead_vote)
		to_chat(world, "<b>Dead Vote has been disabled!</b>")
	else
		to_chat(world, "<b>Dead Vote has been enabled!</b>")
	log_and_message_admins("toggled Dead Vote.")
	BLACKBOX_LOG_ADMIN_VERB("Toggle Dead Vote")
