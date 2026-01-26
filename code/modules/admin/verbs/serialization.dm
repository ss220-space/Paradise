ADMIN_VERB(serialize_datum, R_ADMIN|R_DEBUG, "Serialize Marked Datum", "Turns your marked object into a JSON string you can later use to re-create the object.", ADMIN_CATEGORY_DEBUG)
	if(!istype(user.holder.marked_datum, /atom/movable))
		to_chat(user, "The marked datum is not an atom/movable!")
		return

	var/atom/movable/AM = user.holder.marked_datum
	var/json_data = json_encode(AM.serialize())
	to_chat(user, chat_box_examine(json_data))

ADMIN_VERB(deserialize_json, R_SPAWN, "Deserialize JSON datum", "Creates an object from a JSON string.", ADMIN_CATEGORY_DEBUG)
	var/json_text = tgui_input_text(user, "Enter the JSON code:", "Text", multiline = TRUE, encode = FALSE)
	if(json_text)
		json_to_object(json_text, get_turf(user.mob))
		message_admins("[key_name_admin(user)] spawned an atom from a custom JSON object.")
		log_admin("[key_name(user)] spawned an atom from a custom JSON object, JSON Text: [json_text]")
