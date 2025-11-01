// Unique Datum Identifiers

// Basically, a replacement for plain \refs that ensure the reference still
// points to the exact same datum/client, but doesn't prevent GC like tags do.

// An unintended side effect of the way UIDs are formatted is that the locate()
// proc will ignore the number and attempt to locate the reference. I consider
// this a feature, since it means they're conveniently backwards compatible.

// Turns this:
//   var/myref = "\ref[mydatum]"
//   var/datum/D = locate(myref)
// into this:
//   var/myUID = mydatum.UID()
//   var/datum/D = locateUID(myUID)

/// Log of all UIDs created in the round. Assoc list with type as key and amount as value
GLOBAL_LIST_EMPTY(uid_log)

/**
 * Gets or creates the UID of a datum
 *
 * BYOND refs are recycled, so this system prevents that. If a datum does not have a UID when this proc is ran, one will be created
 * Returns the UID of the datum
 */
/datum/proc/UID()
	if(!unique_datum_id)
		unique_datum_id = RUSTLIB_CALL(get_uuid, src)
		GLOB.uid_log[type]++

	return unique_datum_id

/proc/UID_of(datum/target)
	if(!isdatum(target))
		CRASH("Non-datum passed as argument.")

	return target.UID()


/**
 * Locates a datum based off of the UID
 *
 * Replacement for locate() which takes a UID instead of a ref
 * Returns the datum, if found
 */
/proc/locateUID(uid)
	if(!uid)
		return

	return RUSTLIB_CALL(get_by_uuid, uid)


/**
 * If the list `L` contains a datum UID who's type matches `D`'s type, returns the UID of that datum in the list. Otherwise returns null.
 */
/proc/is_type_in_UID_list(datum/D, list/L)
	if(!length(L))
		return

	for(var/datum_UID in L)
		var/datum/A = locateUID(datum_UID)
		if(istype(D, A))
			return datum_UID


/**
 * Opens a lof of UIDs
 *
 * In-round ability to view what has created a UID, and how many times a UID for that path has been declared
 */
/client/proc/uid_log()
	set name = "View UID Log"
	set category = "Debug"
	set desc = "Shows the log of created UIDs this round"

	if(!check_rights(R_DEBUG))
		return

	var/list/sorted = sortTim(GLOB.uid_log, cmp = /proc/cmp_numeric_dsc, associative = TRUE)
	var/list/text = list("<h1>UID Log</h1>", "<p>Current UID: [RUSTLIB_CALL(get_uuid_counter_value)]</p>", "<ul>")
	for(var/key in sorted)
		text += "<li>[key] - [sorted[key]]</li>"

	text += "</ul>"
	var/datum/browser/popup = new(usr, "uidlog", "UID log")
	popup.set_content(text.Join())
	popup.open(FALSE)
