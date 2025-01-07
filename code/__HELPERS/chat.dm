/// Sends a message to all dead and observing players, if a source is provided a follow link will be attached.
/proc/send_to_observers(message, source)
	var/list/all_observers = GLOB.dead_player_list + GLOB.current_observers_list
	for(var/mob/observer as anything in all_observers)
		if(isnull(source))
			to_chat(observer, "[message]")
			continue
		var/link = FOLLOW_LINK(observer, source)
		to_chat(observer, "[link] [message]")

/// Sends a message to everyone within the list, as well as all observers.
/proc/relay_to_list_and_observers(message, list/mob_list, source)
	for(var/mob/creature as anything in mob_list)
		to_chat(creature, message)
	send_to_observers(message, source)
