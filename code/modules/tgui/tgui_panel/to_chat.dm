/*!
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

/**
 * Circumvents the message queue and sends the message to the recipient (target) as soon as possible.
 * trailing_newline, confidential, and handle_whitespace currently have no effect, please fix this in the future or remove the arguments to lower cache!
 */
/proc/to_chat_immediate(target, html, type, text, avoid_highlighting = FALSE, handle_whitespace = TRUE, trailing_newline = TRUE, confidential = FALSE, ticket_id = -1)
	// Useful where the integer 0 is the entire message. Use case is enabling to_chat(target, some_boolean) while preventing to_chat(target, "")
	html = "[html]"
	text = "[text]"

	if(!target)
		return
	if(!html && !text)
		CRASH("Empty or null string in to_chat proc call.")
	if(target == world)
		target = GLOB.clients

	// Build a message
	var/message = list()
	if(type)
		message["type"] = type
	if(text)
		message["text"] = text
	if(html)
		message["html"] = html
	if(avoid_highlighting)
		message["avoidHighlighting"] = avoid_highlighting
	if(ticket_id != -1)
		message["ticket_id"] = ticket_id

	if(!confidential)
		SSdemo.write_chat(target, message)

	// send it immediately
	SSchat.send_immediate(target, message)

/**
 * Sends the message to the recipient (target).
 *
 * Recommended way to write to_chat calls:
 * ```
 * to_chat(client, "You have found <strong>[object]</strong>", MESSAGE_TYPE_INFO,
 * ```
 * Always remember to close spans!
 * TARGET: Refers to the target of the to_chat message. Valid targets include clients, mobs, and the static world controller
 * HTML: The Message to be sent to the TARGET. Converted to a string if not already one in this function
 * TYPE: The chat tab that this message will be sent to, a list of all valid types can be found in chat.dm
 * TEXT: Unused
 * AVOID_HIGHLIGHTING: Unused
 * trailing_newline, confidential, and handle_whitespace currently have no effect, please fix this in the future or remove the arguments to lower cache!
 */
/proc/to_chat(target, html, type, text, avoid_highlighting, handle_whitespace = TRUE, trailing_newline = TRUE, confidential = FALSE, ticket_id = -1, should_filter_content = TRUE)
	if(!target)
		return

	if(!html && !text)
		CRASH("Empty or null string in to_chat proc call.")

	if(target == world)
		target = GLOB.clients

	if(!islist(target))
		target = list(target)

	if(should_filter_content)
		to_chat_twitch_targets(target, html, type, text, avoid_highlighting, handle_whitespace, trailing_newline, confidential, ticket_id)

	html = replacetext(html, "\n", "<br>")
	if(isnull(Master) || !SSchat?.initialized || !MC_RUNNING(SSchat.init_stage))
		to_chat_immediate(target, html, type, text)
		return

	// Useful where the integer 0 is the entire message. Use case is enabling to_chat(target, some_boolean) while preventing to_chat(target, "")
	html = "[html]"
	text = "[text]"

	// Build a message
	var/message = list()
	if(type)
		message["type"] = type
	if(text)
		message["text"] = text
	if(html)
		message["html"] = html
	if(avoid_highlighting)
		message["avoidHighlighting"] = avoid_highlighting
	if(ticket_id != -1)
		message["ticket_id"] = ticket_id
	SSchat.queue(target, message, confidential)


/proc/to_chat_twitch_targets(targets, html, type, text, avoid_highlighting, handle_whitespace = TRUE, trailing_newline = TRUE, confidential = FALSE, ticket_id = -1)
	var/list/twitch_targets = list()
	for(var/mob/cur_target in targets)
		if(!cur_target.get_preference(PREFTOGGLE_3_BAD_WORDS))
			continue

		twitch_targets.Add(cur_target)

	targets -= twitch_targets
	if(twitch_targets)
		to_chat(twitch_targets, make_text_twitchable(html), type, make_text_twitchable(text), avoid_highlighting, handle_whitespace, trailing_newline, confidential, ticket_id, FALSE)


/proc/make_text_twitchable(text)
	if(!text)
		return

	for(var/bad_word as anything in GLOB.twitch_bad_words_lazy)
		text = replacetext(text, bad_word, " кхм...")

	return text
