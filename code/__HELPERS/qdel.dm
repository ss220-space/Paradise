/proc/______qdel_list_wrapper(list/L) //the underscores are to encourage people not to use this directly.
	QDEL_LIST(L)

/**
 * # Signal qdel
 *
 * Proc intended to be used when someone wants the src datum to be qdeled when a certain signal is sent to them.
 *
 * Example usage:
 * RegisterSignal(item, COMSIG_QDELETING, /datum/proc/signal_qdel)
 */
/datum/proc/signal_qdel()
	SIGNAL_HANDLER
	qdel(src)
