/client/proc/mark_datum(datum/datum)
	if(!holder)
		return

	if(!datum.allow_mark_datum())
		return

	if(holder.marked_datum)
		holder.UnregisterSignal(holder.marked_datum, COMSIG_QDELETING)
		vv_update_display(holder.marked_datum, "marked", "")

	holder.marked_datum = datum
	holder.RegisterSignal(holder.marked_datum, COMSIG_QDELETING, TYPE_PROC_REF(/datum/admins, handle_marked_del))
	vv_update_display(datum, "marked", VV_MSG_MARKED)

ADMIN_VERB_ONLY_CONTEXT_MENU(mark_datum, R_NONE, "Mark Object", datum/target as mob|obj|turf|area in view())
	user.mark_datum(target)

/datum/admins/proc/handle_marked_del(datum/source)
	SIGNAL_HANDLER
	UnregisterSignal(marked_datum, COMSIG_QDELETING)
	marked_datum = null

/// Will this datum allow itself to be marked by VV?
/datum/proc/allow_mark_datum()
	return TRUE
