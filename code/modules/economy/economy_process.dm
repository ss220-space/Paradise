/datum/economy_process
	abstract_type = /datum/economy_process
	var/interval
	var/queued_for_qdel

/datum/economy_process/New()
	if(!initialize(arglist(args)))
		qdel(src)
		return
	SStimed_economy?.add_economy_process(src)

/datum/economy_process/Destroy(force)
	if(!queued_for_qdel)
		on_destroy()
		queued_for_qdel = TRUE
		return QDEL_HINT_LETMELIVE
	return ..()

/datum/economy_process/proc/initialize()
	return TRUE

/datum/economy_process/proc/on_destroy()
	return

/datum/economy_process/proc/alt_process()
	SHOULD_NOT_OVERRIDE(TRUE)
	if(queued_for_qdel)
		qdel(src)
		return

	custom_process()

	SStimed_economy.add_economy_process(src)

/datum/economy_process/proc/custom_process()
	SHOULD_NOT_SLEEP(TRUE)
	return
