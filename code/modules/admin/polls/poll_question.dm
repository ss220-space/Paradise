/**
 * Datum which holds details of a running poll loaded from the database and supplementary info.
 *
 * Used to minimize the need for querying this data every time it's needed.
 *
 */
/datum/poll_question
	///Reference list of the options for this poll, not used by text response polls.
	var/list/options = list()
	///Table id of this poll, will be null until poll has been created.
	var/poll_id
	///The type of poll to be created, must be POLLTYPE_OPTION, POLLTYPE_TEXT, POLLTYPE_RATING, POLLTYPE_MULTI.
	var/poll_type
	///Count of how many players have voted or responded to this poll.
	var/poll_votes
	///Ckey of the poll's original author
	var/created_by
	///Date and time the poll opens, timestamp format is YYYY-MM-DD HH:MM:SS.
	var/start_datetime
	///Date and time the poll will run until, timestamp format is YYYY-MM-DD HH:MM:SS.
	var/end_datetime
	///The title text of the poll, shows up on the list of polls.
	var/question
	///Supplementary text displayed only when responding to a poll.
	var/subtitle
	///Hides the poll from any client without a holder datum.
	var/admin_only
	///The number of responses allowed in a multiple-choice poll, more can be selected but won't be recorded.
	var/options_allowed
	///Hint for statbus, not used by the game; Stops the results of a poll from being displayed until the end_datetime is reached.
	var/dont_show
	///Allows a player to change their vote to a poll they've already voted on, off by default.
	var/allow_revoting
	///Indicates if a poll has been submitted or loaded from the DB so the management panel will open with edit functions.
	var/edit_ready = FALSE
	///Holds duration data when creating or editing a poll and refreshing the poll creation window.
	var/duration
	///Holds interval data when creating or editing a poll and refreshing the poll creation window.
	var/interval
	///Indicates a poll is set to not start in the future, still visible for editing but not voting on.
	var/future_poll
	///Minimum playtime in hours to vote on the poll
	var/minimum_playtime = 0

/datum/poll_question/New(id, polltype, starttime, endtime, question, subtitle, adminonly, multiplechoiceoptions, dontshow, allow_revoting, vote_count, creator, future, active_poll, minimum_playtime, dbload = FALSE)
	poll_id = text2num(id)
	poll_type = polltype
	start_datetime = starttime
	end_datetime = endtime
	src.question = question //item[5]
	src.subtitle = subtitle
	admin_only = text2num(adminonly)
	options_allowed = text2num(multiplechoiceoptions)
	dont_show = text2num(dontshow)
	src.allow_revoting = text2num(allow_revoting)  //item[10]
	poll_votes = text2num(vote_count) || 0
	created_by = creator
	future_poll = text2num(future)
	if (active_poll)
		GLOB.active_polls += src
	src.minimum_playtime = text2num(minimum_playtime) || 0  //item[15]
	edit_ready = dbload

	GLOB.polls += src

/datum/poll_question/Destroy()
	GLOB.active_polls -= src
	GLOB.polls -= src
	return ..()

/**
 * Sets a poll and its associated data as deleted in the database.
 *
 * Calls the procedure set_poll_deleted to set the deleted column to 1 for each row in the poll_ tables matching the poll id used.
 * Then deletes each option datum and finally the poll itself.
 *
 */
/datum/poll_question/proc/delete_poll()
	if(!check_rights(R_SERVER))
		return
	if(!SSdbcore.Connect())
		to_chat(usr, span_danger("Failed to establish database connection."), confidential = TRUE)
		return
	var/datum/db_query/query_delete_poll = SSdbcore.NewQuery(
		"CALL set_poll_deleted(:poll_id)",
		list("poll_id" = poll_id)
	)
	if(!query_delete_poll.warn_execute())
		qdel(query_delete_poll)
		return
	qdel(query_delete_poll)
	for(var/o in options)
		var/datum/poll_option/option = o
		qdel(option)
	GLOB.polls -= src
	qdel(src)

/**
 * Inserts or updates a poll question to the database.
 *
 * Uses INSERT ON DUPLICATE KEY UPDATE to handle both inserting and updating at once.
 * The start and end datetimes and poll id for new polls is then retrieved for the poll datum.
 * Arguments:
 * * clear_votes - When true will call clear_poll_votes() to delete all votes matching this poll id.
 *
 */
/datum/poll_question/proc/save_poll_data(clear_votes)
	if(!check_rights(R_SERVER))
		return
	if(!SSdbcore.Connect())
		to_chat(usr, span_danger("Failed to establish database connection."), confidential = TRUE)
		return
	var/new_poll = !poll_id
	if(poll_type != POLLTYPE_MULTI)
		options_allowed = null
	var/admin_ckey = created_by

	var/end_datetime_sql
	if (interval in list("SECOND", "MINUTE", "HOUR", "DAY", "WEEK", "MONTH", "YEAR"))
		end_datetime_sql = "NOW() + INTERVAL :duration [interval]"
	else
		end_datetime_sql = ":duration"

	var/datum/db_query/query_save_poll = SSdbcore.NewQuery({"
		INSERT INTO [format_table_name("poll_question")] (id, polltype, created_datetime, starttime, endtime, question, subtitle, adminonly, multiplechoiceoptions, createdby_ckey, dontshow, allow_revoting, minimum_playtime)
		VALUES (:poll_id, :poll_type, NOW(), COALESCE(:start_datetime, NOW()), [end_datetime_sql], :question, :subtitle, :admin_only, :options_allowed, :admin_ckey, :dont_show, :allow_revoting, :minimum_playtime)
		ON DUPLICATE KEY UPDATE starttime = :start_datetime, endtime = [end_datetime_sql], question = :question, subtitle = :subtitle, adminonly = :admin_only, multiplechoiceoptions = :options_allowed, dontshow = :dont_show, allow_revoting = :allow_revoting, minimum_playtime = :minimum_playtime
	"}, list(
		"poll_id" = poll_id, "poll_type" = poll_type, "start_datetime" = start_datetime, "duration" = duration,
		"question" = question, "subtitle" = subtitle, "admin_only" = admin_only, "options_allowed" = options_allowed,
		"admin_ckey" = admin_ckey, "dont_show" = dont_show, "allow_revoting" = allow_revoting,
		"minimum_playtime" = minimum_playtime
	))
	if(!query_save_poll.warn_execute())
		qdel(query_save_poll)
		return
	if (!poll_id)
		poll_id = query_save_poll.last_insert_id
	qdel(query_save_poll)
	var/datum/db_query/query_get_poll_id_start_endtime = SSdbcore.NewQuery(
		"SELECT starttime, endtime, IF(starttime > NOW(), 1, 0) FROM [format_table_name("poll_question")] WHERE id = :poll_id",
		list("poll_id" = poll_id)
	)
	if(!query_get_poll_id_start_endtime.warn_execute())
		qdel(query_get_poll_id_start_endtime)
		return
	if(query_get_poll_id_start_endtime.NextRow())
		start_datetime = query_get_poll_id_start_endtime.item[1]
		end_datetime = query_get_poll_id_start_endtime.item[2]
		future_poll = text2num(query_get_poll_id_start_endtime.item[3])
	qdel(query_get_poll_id_start_endtime)
	if(clear_votes)
		clear_poll_votes()
	edit_ready = TRUE
	log_and_message_admins("has [new_poll ? "created a new" : "edited a"][admin_only ? " admin only" : ""] server poll. Question: [question]")

/**
 * Saves all options of a poll to the database.
 *
 * Saves all the created options for a poll when it's submitted to the DB for the first time and associated an id with the options.
 * Insertion and id querying for each option is done separately to ensure data integrity; this is less performant, but not significantly.
 * Using MassInsert() would mean having to query a list of rows by poll_id or matching by fields afterwards, which doesn't guarantee accuracy.
 *
 */
/datum/poll_question/proc/save_all_options()
	if(!SSdbcore.Connect())
		to_chat(usr, span_danger("Failed to establish database connection."), confidential = TRUE)
		return
	for(var/o in options)
		var/datum/poll_option/option = o
		option.save_option()

/**
 * Deletes all votes or text replies for this poll, depending on its type.
 *
 */
/datum/poll_question/proc/clear_poll_votes()
	if(!check_rights(R_SERVER))
		return
	if(!SSdbcore.Connect())
		to_chat(usr, span_danger("Failed to establish database connection."), confidential = TRUE)
		return
	var/table = "poll_vote"
	if(poll_type == POLLTYPE_TEXT)
		table = "poll_textreply"
	var/datum/db_query/query_clear_poll_votes = SSdbcore.NewQuery(
		"UPDATE [format_table_name(table)] SET deleted = 1 WHERE pollid = :poll_id",
		list("poll_id" = poll_id)
	)
	if(!query_clear_poll_votes.warn_execute())
		qdel(query_clear_poll_votes)
		return
	qdel(query_clear_poll_votes)
	poll_votes = 0
	to_chat(usr, span_danger("Poll [poll_type == POLLTYPE_TEXT ? "responses" : "votes"] cleared."), confidential = TRUE)
