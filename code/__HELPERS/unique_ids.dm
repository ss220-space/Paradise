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

/// The next UID to be used (Increments by 1 for each UID)
GLOBAL_VAR_INIT(next_unique_datum_id, 1)
/// Every time GLOB.next_unique_datum_id goes above 16777215, we will add new letter and reset the counter.
GLOBAL_VAR_INIT(unique_datum_id_letters, "")
/// Log of all UIDs created in the round. Assoc list with type as key and amount as value
GLOBAL_LIST_EMPTY(uid_log)

/**
  * Gets or creates the UID of a datum
  *
  * BYOND refs are recycled, so this system prevents that. If a datum does not have a UID when this proc is ran, one will be created.
  * If we go above 54 * 16777216 UIDs in a round shit breaks.
  *
  * Returns the UID of the datum
  */
/datum/proc/UID()
	if(!unique_datum_id)
		var/tag_backup = tag
		// Grab the raw ref, not the tag
		tag = null
		var/new_ref = "\ref[src]"
		tag = tag_backup
		GLOB.next_unique_datum_id++
		if(GLOB.next_unique_datum_id >= (SHORT_REAL_LIMIT - 1))
			var/static/list/free_unique_letters = GLOB.alphabet.Copy() + GLOB.alphabet_uppercase.Copy()
			if(!free_unique_letters.len)
				stack_trace("UID is out of unique strings. Time to switch on weakrefs.")
				return
			var/new_letter = pick(free_unique_letters)
			free_unique_letters -= new_letter
			GLOB.unique_datum_id_letters = "[GLOB.unique_datum_id_letters][new_letter]"
			GLOB.next_unique_datum_id = 1
		// we nee to use num2text since BYOND will print a number in scientific notation if its big enough, breaking the refs
		unique_datum_id = "[new_ref]_[GLOB.unique_datum_id_letters]|[num2text(GLOB.next_unique_datum_id, 8)]"
		GLOB.uid_log[type]++
	return unique_datum_id


/proc/UID_of(datum/target)
	if(!isdatum(target))
		CRASH("Non-datum passed as argument.")
	return target.UID()


/**
  * Locates a datum based off of the UID
  *
  * Replacement for locate() which takes a UID instead of a ref.
  * This will return `null` if the datum was deleted. This MUST be respected.
  */
/proc/locateUID(uid)
	if(!istext(uid))
		return null

	var/splitat = findlasttext(uid, "_")

	if(!splitat)
		return null

	var/datum/found = locate(copytext(uid, 1, splitat))

	if(!QDELETED(found) && found.unique_datum_id == uid)
		return found

	return null


/**
 * Like locateUID, but doesn't care if the datum is being qdeleted but hasn't been deleted yet.
 *
 * Just use locateUID, unless you specifically know what you are doing.
 */
/proc/hardlocateUID(uid)
	if(!istext(uid))
		return null

	var/splitat = findlasttext(uid, "_")

	if(!splitat)
		return null

	var/datum/found = locate(copytext(uid, 1, splitat))

	if(found && found.unique_datum_id == uid)
		return found

	return null


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
  * Opens a lot of UIDs
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
	var/stringlen = length(GLOB.unique_datum_id_letters)
	var/list/text = list("<h1>UID Log</h1>", "<p>Current UID: [stringlen ? "[num2text(stringlen * SHORT_REAL_LIMIT, 100)] + " : ""][GLOB.next_unique_datum_id]</p>", "<ul>")
	for(var/key in sorted)
		text += "<li>[key] - [sorted[key]]</li>"

	text += "</ul>"
	usr << browse(text.Join(), "window=uidlog")
