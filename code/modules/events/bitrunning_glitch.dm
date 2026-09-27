/datum/event_meta/bitrunning_glitch/get_weight(list/active_with_role)
	if(!length(get_glitch_ready_servers()))
		return 0
	return ..()

/datum/event/bitrunning_glitch

/datum/event/bitrunning_glitch/start()
	INVOKE_ASYNC(src, PROC_REF(wrapped_start))

/datum/event/bitrunning_glitch/proc/wrapped_start()
	var/list/obj/machinery/quantum_server/loaded_servers = get_glitch_ready_servers()
	if(!length(loaded_servers))
		log_and_message_admins("Random event attempted to spawn a bitrunning glitch, but no quantum server had a running domain.")
		reroll_event_in_category()
		return

	var/obj/machinery/quantum_server/unlucky_server = pick(loaded_servers)
	if(isnull(unlucky_server.setup_glitch()))
		log_and_message_admins("Random event attempted to spawn a bitrunning glitch, but the glitch failed to spawn.")
		reroll_event_in_category()
		return
