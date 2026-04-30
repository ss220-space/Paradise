/**
 * Chat message data type, stores data about messages themselves.
 */
/datum/messenger_message
	var/message_id
	/// The message itself.
	var/text_message
	/// The photo owner message ; чекни SecurityRecords
	var/photo_name
	/// The station time at which this message was made.
	var/timestamp
	/// for display on tgui
	var/sender_name
	// for logic
	var/sender_ref

/datum/messenger_message/New(text, sender_name, sender_ref, photo_name = null)
	src.message_id = src.UID()
	src.text_message = text
	src.photo_name = photo_name
	src.timestamp = station_time_timestamp(world.time)
	src.sender_name = sender_name
	src.sender_ref = sender_ref

/datum/messenger_message/proc/get_ui_data(datum/messenger_account/last_login_owner)
	var/list/data = list()
	data["message_id"] = message_id
	data["text_message"] = text_message
	data["outgoing"] = (last_login_owner.UID() == sender_ref)
	data["photo_name"] = photo_name
	data["timestamp"] = timestamp
	data["sender_name"] = sender_name
	data["sender_ref"] = sender_ref
	return data
