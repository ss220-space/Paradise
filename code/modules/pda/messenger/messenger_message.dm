/**
 * Chat message data type, stores data about messages themselves.
 */
/datum/messenger_message
	/// The message itself.
	var/text_message
	/// Whether the message is sent by the user or not.
	var/outgoing
	/// The photo owner message ; чекни SecurityRecords
	var/photo_name
	/// The station time at which this message was made.
	var/timestamp
	/// for display on tgui
	var/sender_name
	// for logic
	var/sender_ref

/datum/messenger_message/New(text, outgoing, sender_name, sender_ref, photo_name = null)
	src.text_message = text
	src.outgoing = outgoing
	src.photo_name = photo_name
	src.timestamp = world.time
	src.sender_name = sender_name
	src.sender_ref = sender_ref

/datum/messenger_message/proc/get_ui_data(mob/user)
	var/list/data = list()
	data["text_message"] = text_message
	data["outgoing"] = outgoing
	data["photo_name"] = photo_name
	data["timestamp"] = timestamp
	data["sender_name"] = sender_name
	data["sender_ref"] = sender_ref
	return data
