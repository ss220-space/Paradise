SUBSYSTEM_DEF(vote)
	name = "Vote"
	wait = 10
	flags = SS_KEEP_TIMING|SS_NO_INIT
	runlevels = RUNLEVEL_LOBBY | RUNLEVELS_DEFAULT
	offline_implications = "Votes (Endround shuttle) will no longer function. Shuttle call recommended."
	cpu_display = SS_CPUDISPLAY_LOW
	ss_id = "vote"

	/// Active vote, if any
	var/datum/vote/active_vote
	//Queue of votes being processed
	var/list/votes_queue = list()

/datum/controller/subsystem/vote/fire()
	if(active_vote)
		active_vote.tick()

/datum/controller/subsystem/vote/proc/start_vote(datum/vote/V)
	// This will be fun if DM ever gets concurrency
	if(active_vote)
		votes_queue += V
		return
	active_vote = V
	active_vote.start()

/datum/controller/subsystem/vote/proc/on_vote_end()
	for(var/datum/vote/vote in votes_queue)
		votes_queue -= vote
		if(QDELETED(vote))
			continue
		start_vote(vote)
		break;

/datum/controller/subsystem/vote/proc/clear_transfer_votes()
	for(var/datum/vote/vote in votes_queue)
		if(istype(vote, /datum/vote/crew_transfer))
			votes_queue -= vote
			if(!QDELETED(vote))
				qdel(vote)

/datum/controller/subsystem/vote/Topic(href, list/href_list)
	if(href_list["vote"] == "open")
		usr.client.vote()
