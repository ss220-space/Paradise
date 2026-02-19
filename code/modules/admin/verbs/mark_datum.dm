/client/proc/mark_datum(datum/datum)
	if(!holder)
		return

	if(holder.marked_datum)
		holder.UnregisterSignal(holder.marked_datum, COMSIG_QDELETING)
		vv_update_display(holder.marked_datum, "marked", "")

	holder.marked_datum = datum
	holder.RegisterSignal(holder.marked_datum, COMSIG_QDELETING, TYPE_PROC_REF(/datum/admins, handle_marked_del))
	vv_update_display(datum, "marked", VV_MSG_MARKED)

/datum/admins/proc/handle_marked_del(datum/source)
	SIGNAL_HANDLER
	UnregisterSignal(marked_datum, COMSIG_QDELETING)
	marked_datum = null
