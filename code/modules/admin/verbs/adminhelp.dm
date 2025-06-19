//This is a list of words which are ignored by the parser when comparing message contents for names. MUST BE IN LOWER CASE!
GLOBAL_LIST_INIT(adminhelp_ignored_words, list("unknown", "the", "a", "an", "of", "monkey", "alien", "as"))

/client/verb/adminhelp()
	set category = STATPANEL_ADMIN_TICKETS
	set name = "Запрос помощи"

	//handle muting and automuting
	if(check_mute(ckey, MUTE_ADMINHELP))
		to_chat(src, span_red("Error: Admin-PM: You cannot send adminhelps (Muted)."), MESSAGE_TYPE_ADMINPM, confidential = TRUE)
		return

	adminhelped = TRUE //Determines if they get the message to reply by clicking the name.

	var/msg
	var/list/type = list(MENTORHELP, ADMINHELP)
	var/selected_type = tgui_input_list(src, "Выберите, чья помощь вам необходима", "Запрос помощи", type)
	if(selected_type)
		msg = tgui_input_text(src, "Please enter your message.", selected_type, multiline = TRUE, encode = FALSE)

	if(!msg)
		return

	if(handle_spam_prevention(msg, MUTE_ADMINHELP, OOC_COOLDOWN))
		return

	msg = sanitize_simple(copytext_char(msg, 1, MAX_MESSAGE_LEN))
	msg = sanitize_censored_patterns(msg)
	if(!msg) // No message after sanitisation
		return

	var/span_type
	var/message_type
	var/datum/ticket/T
	if(selected_type == MENTORHELP)
		T = SSmentor_tickets.newHelpRequest(src, msg) // Mhelp
		span_type = "mentorhelp"
		message_type = MESSAGE_TYPE_MENTORPM
		//show it to the person mentorhelping too
		to_chat(src, chat_box_mhelp("<span class='[span_type]'><b>[selected_type]</b><br><br>[msg]</span>"), message_type, confidential = TRUE)
	else
		T = SStickets.newHelpRequest(src, msg) // Ahelp
		span_type = "adminhelp"
		message_type = MESSAGE_TYPE_ADMINPM
		//show it to the person adminhelping too
		to_chat(src, chat_box_ahelp("<span class='[span_type]'><b>[selected_type]</b><br><br>[msg]</span>"), message_type, confidential = TRUE)

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Adminhelp") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

	switch(selected_type)
		if(ADMINHELP)
			//See how many staff are on
			var/list/admincount = staff_countup(R_BAN)
			var/active_admins = admincount[1]

			log_admin("[selected_type]: [key_name(src)]: [msg] - heard by [active_admins] non-AFK admins.")
			SSdiscord.send2discord_simple_noadmins("**\[Adminhelp]** Ticket [T.ticketNum], [key_name(src)]: [msg]", check_send_always = TRUE)

		if(MENTORHELP)
			var/list/mentorcount = staff_countup(R_MENTOR)
			var/active_mentors = mentorcount[1]

			log_admin("[selected_type]: [key_name(src)]: [msg] - heard by [active_mentors] non-AFK mentors.")
			SSdiscord.send2discord_simple(DISCORD_WEBHOOK_MENTOR, "Ticket [T.ticketNum], [key_name(src)]: [msg]")
