/**
 * Datum which holds details of a poll option loaded from the database.
 *
 * Used to minimize the need for querying this data every time it's needed.
 *
 */
/datum/poll_option
	///Reference to the poll this option belongs to
	var/datum/poll_question/parent_poll
	///Table id of this option, will be null until poll has been created.
	var/option_id
	///Description/name of this option
	var/text
	///For rating polls, the minimum selectable value allowed; Supported value range is -2147483648 to 2147483647
	var/min_val
	///For rating polls, the maximum selectable value allowed; Supported value range is -2147483648 to 2147483647
	var/max_val
	///Optional for rating polls, description shown next to the minimum value
	var/desc_min = ""
	///Optional for rating polls, description shown next to the rounded whole middle value
	var/desc_mid = ""
	///Optional for rating polls, description shown next to the maximum value
	var/desc_max = ""
	///Hint for statbus, not used by the game; If this option should be included by default when calculating the resulting percentages of all options for this poll
	var/default_percentage_calc

/datum/poll_option/New(id, text, minval, maxval, descmin, descmid, descmax, default_percentage_calc)
	option_id = text2num(id)
	src.text = text
	min_val = text2num(minval)
	max_val = text2num(maxval)
	desc_min = descmin
	desc_mid = descmid
	desc_max = descmax
	src.default_percentage_calc = text2num(default_percentage_calc)
	GLOB.poll_options += src

/datum/poll_option/Destroy()
	parent_poll?.options -= src
	parent_poll = null
	GLOB.poll_options -= src
	return ..()

/**
 * Inserts or updates a poll option to the database.
 *
 * Uses INSERT ON DUPLICATE KEY UPDATE to handle both inserting and updating at once.
 * The list of columns and values is built dynamically to avoid excess data being sent when not a rating type poll.
 *
 */
/datum/poll_option/proc/save_option()
	if(!check_rights(R_SERVER))
		return
	if(!SSdbcore.Connect())
		to_chat(usr, span_danger("Failed to establish database connection."), confidential = TRUE)
		return

	var/list/values = list("text" = text, "default_percentage_calc" = default_percentage_calc, "pollid" = parent_poll.poll_id, "id" = option_id)
	if(parent_poll.poll_type == POLLTYPE_RATING)
		values["minval"] = min_val
		values["maxval"] = max_val
		values["descmin"] = desc_min
		values["descmid"] = desc_mid
		values["descmax"] = desc_max

	var/update_data = list()
	for (var/k in values)
		update_data += "[k] = VALUES([k])"

	var/datum/db_query/query_update_poll_option = SSdbcore.NewQuery(
		"INSERT INTO [format_table_name("poll_option")] ([jointext(values, ",")]) VALUES (:[jointext(values, ",:")]) ON DUPLICATE KEY UPDATE [jointext(update_data, ", ")]",
		values
	)
	if(!query_update_poll_option.warn_execute())
		qdel(query_update_poll_option)
		return
	if (!option_id)
		option_id = query_update_poll_option.last_insert_id
	qdel(query_update_poll_option)

/**
 * Sets a poll option and its votes as deleted in the database then deletes its datum.
 *
 */
/datum/poll_option/proc/delete_option()
	if(!check_rights(R_SERVER))
		return
	. = parent_poll
	if(option_id)
		if(!SSdbcore.Connect())
			to_chat(usr, span_danger("Failed to establish database connection."), confidential = TRUE)
			return
		var/datum/db_query/query_delete_poll_option = SSdbcore.NewQuery(
			"UPDATE [format_table_name("poll_option")] AS o INNER JOIN [format_table_name("poll_vote")] AS v ON o.id = v.optionid SET o.deleted = 1, v.deleted = 1 WHERE o.id = :option_id",
			list("option_id" = option_id)
		)
		if(!query_delete_poll_option.warn_execute())
			qdel(query_delete_poll_option)
			return
		qdel(query_delete_poll_option)
	qdel(src)
