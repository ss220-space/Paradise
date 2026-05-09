/**
 * # Unique Datum Identifiers
 *
 * A replacement for plain \refs. Ensures the reference still points to the exact same datum/client,
 * but doesn't prevent GC like tags do.
 *
 * An unintended side effect of how UIDs are formatted: locate() ignores the number and attempts
 * to locate the reference. This is considered a feature — backwards compatibility.
 *
 * Before:
 *   var/my_ref = "\ref[my_datum]"
 *   var/datum/thing = locate(my_ref)
 *
 * After:
 *   var/my_UID = my_datum.UID()
 *   var/datum/thing = locateUID(my_UID)
 */
/* --- */

/// Log of all UIDs created in the round. Assoc list with type as key and amount as value
GLOBAL_LIST_EMPTY(uid_log)

/**
 * Gets or creates the UID of a datum
 *
 * BYOND refs are recycled, so this system prevents that. If a datum does not have a UID when this proc is ran, one will be created
 *
 * Returns: the UID of the datum
 */
/datum/proc/UID()
	if(!unique_datum_id)
		unique_datum_id = RUSTLIB_CALL(get_uuid, src)
		GLOB.uid_log[type]++

	return unique_datum_id

/**
 * Returns the UID of a datum or a text ref of a list. Crashes on non-datum, non-list.
 *
 * * target - A datum or a list.
 *
 * Returns: UID string if datum, text_ref if list.
 */
/proc/UID_of(target)
	if(islist(target) || isappearance(target))
		return text_ref(target)

	if(!isdatum(target))
		CRASH("Non-datum, non-list passed as argument: '[target]'")

	var/datum/target_datum = target
	return target_datum.UID()

/**
 * Locates a datum based off of the UID
 *
 * Replacement for locate() which takes a UID instead of a ref
 *
 * Returns: the datum, if found
 */
/proc/locateUID(uid)
	if(!uid)
		return

	return RUSTLIB_CALL(get_by_uuid, uid)

/**
 * If the list `UID_list` contains a datum UID who's type matches `thing`'s type, returns the UID of that datum in the list. Otherwise returns null.
 */
/proc/is_type_in_UID_list(datum/thing, list/UID_list)
	if(!length(UID_list))
		return

	for(var/datum_UID in UID_list)
		var/datum/current_thing = locateUID(datum_UID)
		if(istype(thing, current_thing))
			return datum_UID

/**
 * Opens a lof of UIDs
 *
 * In-round ability to view what has created a UID, and how many times a UID for that path has been declared
 */
ADMIN_VERB(uid_log, R_DEBUG, "View UID Log", "Shows the log of created UIDs this round.", ADMIN_CATEGORY_DEBUG)
	var/list/sorted = sortTim(GLOB.uid_log, GLOBAL_PROC_REF(cmp_numeric_dsc), associative = TRUE)
	var/list/text = list("<h1>UID Log</h1>", "<p>Current UID: [RUSTLIB_CALL(get_uuid_counter_value)]</p>", "<ul>")
	for(var/key in sorted)
		text += "<li>[key] - [sorted[key]]</li>"

	text += "</ul>"
	var/datum/browser/popup = new(user, "uidlog", "UID log")
	popup.set_content(text.Join())
	popup.open(FALSE)
