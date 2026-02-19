/// Requests from prayers
#define REQUEST_PRAYER "request_prayer"
/// Requests for Centcom
#define REQUEST_CENTCOM "request_centcom"
/// Requests for the Syndicate
#define REQUEST_SYNDICATE "request_syndicate"
/// Requests for ERT
#define REQUEST_ERT "request_ert"
/// Requests for HONK
#define REQUEST_HONK "request_honk"
/// Requests for the nuke code
#define REQUEST_NUKE "request_nuke"

GLOBAL_DATUM_INIT(requests, /datum/request_manager, new)

/**
 * # Request Manager
 *
 * Handles all player requests (prayers, centcom requests, syndicate requests)
 * that occur in the duration of a round.
 */
/datum/request_manager
	/// Associative list of ckey -> list of requests
	var/list/requests = list()
	/// List where requests can be accessed by ID
	var/list/requests_by_id = list()

/datum/request_manager/Destroy(force)
	QDEL_LIST(requests)
	return ..()

/**
 * Used in the new client pipeline to catch when clients are reconnecting and need to have their
 * reference re-assigned to the 'owner' variable of any requests
 *
 * Arguments:
 * * C - The client who is logging in
 */
/datum/request_manager/proc/client_login(client/C)
	if(!requests[C.ckey])
		return
	for(var/datum/request/request as anything in requests[C.ckey])
		request.owner = C

/**
 * Used in the destroy client pipeline to catch when clients are disconnecting and need to have their
 * reference nulled on the 'owner' variable of any requests
 *
 * Arguments:
 * * C - The client who is logging out
 */
/datum/request_manager/proc/client_logout(client/C)
	if(!requests[C.ckey])
		return
	for(var/datum/request/request as anything in requests[C.ckey])
		request.owner = null

/**
 * Creates a request for a prayer, and notifies admins who have the sound notifications enabled when appropriate
 *
 * Arguments:
 * * C - The client who is praying
 * * message - The prayer
 * * is_chaplain - Boolean operator describing if the prayer is from a chaplain
 */
/datum/request_manager/proc/pray(client/C, message, is_chaplain)
	request_for_client(C, REQUEST_PRAYER, message)

/**
 * Creates a request for a Centcom message
 *
 * Arguments:
 * * C - The client who is sending the request
 * * message - The message
 */
/datum/request_manager/proc/message_centcom(client/C, message)
	request_for_client(C, REQUEST_CENTCOM, message)

/**
 * Creates a request for a Syndicate message
 *
 * Arguments:
 * * C - The client who is sending the request
 * * message - The message
 */
/datum/request_manager/proc/message_syndicate(client/C, message)
	request_for_client(C, REQUEST_SYNDICATE, message)

/**
 * Creates a request for a ERT request
 *
 * Arguments:
 * * C - The client who is sending the request
 * * message - The message
 */
/datum/request_manager/proc/request_ert(client/C, message)
	request_for_client(C, REQUEST_ERT, message)

/**
 * Creates a request for a Honk message
 *
 * Arguments:
 * * C - The client who is sending the request
 * * message - The message
 */
/datum/request_manager/proc/message_honk(client/C, message)
	request_for_client(C, REQUEST_HONK, message)

/**
 * Creates a request for the nuclear self destruct codes
 *
 * Arguments:
 * * C - The client who is sending the request
 * * message - The message
 */
/datum/request_manager/proc/nuke_request(client/C, message)
	request_for_client(C, REQUEST_NUKE, message)

/**
 * Creates a request and registers the request with all necessary internal tracking lists
 *
 * Arguments:
 * * C - The client who is sending the request
 * * type - The type of request, see defines
 * * message - The message
 */
/datum/request_manager/proc/request_for_client(client/C, type, message)
	var/datum/request/request = new(C, type, message)
	if(!requests[C.ckey])
		requests[C.ckey] = list()
	requests[C.ckey] += request
	requests_by_id.len++
	requests_by_id[request.id] = request

	var/data = " **\[[uppertext(replacetext(type, "request_", ""))]\]** [C.ckey]/([C?.mob?.name ? C.mob.name : "INVALID"]): [message]"
	SSdiscord.send2discord_simple(DISCORD_WEBHOOK_REQUESTS, data)

/datum/request_manager/ui_state(mob/user)
	return ADMIN_STATE(R_ADMIN)

/datum/request_manager/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RequestManager", "Requests")
		ui.autoupdate = TRUE
		ui.open()

/datum/request_manager/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	// Only admins should be sending actions
	if(!check_rights(R_ADMIN))
		to_chat(usr, "You do not have permission to do this, you require +ADMIN", confidential = TRUE)
		return

	// Get the request this relates to
	var/id = params["id"] != null ? text2num(params["id"]) : null
	if(!id)
		to_chat(usr, "Failed to find a request ID in your action, please report this", confidential = TRUE)
		CRASH("Received an action without a request ID, this shouldn't happen!")
	var/datum/request/request = !id ? null : requests_by_id[id]

	switch(action)
		if("pp")
			var/mob/selected_mob = request.owner?.mob
			usr.client.VUAP_selected_mob = selected_mob
			usr.client.selectedPlayerCkey = selected_mob.ckey
			SSadmin_verbs.dynamic_invoke_verb(usr, /datum/admin_verb/vuap_personal, selected_mob)
			return TRUE
		if("vv")
			var/mob/selected_mob = request.owner?.mob
			usr.client.debug_variables(selected_mob)
			return TRUE
		if("sm")
			if(!check_rights(R_EVENT))
				to_chat(usr, "Insufficient permissions to smite, you require +EVENT", confidential = TRUE)
				return TRUE
			var/mob/selected_mob = request.owner?.mob
			SSadmin_verbs.dynamic_invoke_verb(usr, /datum/admin_verb/cmd_admin_subtle_message, selected_mob)
			return TRUE
		if("tp")
			if(!SSticker.HasRoundStarted())
				tgui_alert(usr, "The game hasn't started yet!")
				return TRUE
			var/mob/selected_mob = request.owner?.mob
			SSadmin_verbs.dynamic_invoke_verb(usr, /datum/admin_verb/show_traitor_panel, selected_mob)
			return TRUE
		if("logs")
			var/mob/selected_mob = request.owner?.mob
			if(!ismob(selected_mob))
				to_chat(usr, "This can only be used on instances of type /mob.", confidential = TRUE)
				return TRUE
			SSadmin_verbs.dynamic_invoke_verb(usr, /datum/admin_verb/logging_view, selected_mob, TRUE)
			return TRUE
		if("bless")
			if(!check_rights(R_EVENT))
				to_chat(usr, "Insufficient permissions to bless, you require +EVENT", confidential = TRUE)
				return TRUE
			var/mob/living/selected_mob = request.owner?.mob
			SSadmin_verbs.dynamic_invoke_verb(usr, /datum/admin_verb/bless, selected_mob)
			return TRUE
		if("smite")
			if(!check_rights(R_EVENT))
				to_chat(usr, "Insufficient permissions to smite, you require +EVENT", confidential = TRUE)
				return TRUE
			var/mob/living/selected_mob = request.owner?.mob
			SSadmin_verbs.dynamic_invoke_verb(usr, /datum/admin_verb/admin_smite, selected_mob)
			return TRUE
		if("rply")
			if(request.req_type == REQUEST_PRAYER)
				to_chat(usr, "Cannot reply to a prayer")
				return TRUE
			var/mob/selected_mob = request.owner?.mob
			usr.client.admin_headset_message(selected_mob, request.req_type == REQUEST_SYNDICATE ? "Syndicate" : "Centcomm")
			return TRUE
		if("ertreply")
			if(request.req_type != REQUEST_ERT)
				to_chat(usr, "You cannot respond with ert for a non-ert-request request!", confidential = TRUE)
				return TRUE

			if(tgui_alert(usr, "Accept or Deny ERT request?", "CentComm Response", list("Accept", "Deny")) == "No")
				var/mob/living/carbon/human/H = request.owner?.mob
				if(!istype(H))
					to_chat(usr, span_warning("This can only be used on instances of type /mob/living/carbon/human"), confidential = TRUE)
					return

				var/reason = tgui_input_text(usr, "Please enter a reason for denying [key_name(H)]'s ERT request.", "Outgoing message from CentComm", multiline = TRUE, encode = FALSE)
				if(!reason)
					return
				var/announce_to_crew = tgui_alert(usr, "Announce ERT request denial to crew or only to the sender [key_name(H)]?", "Send reason to who", "Crew", "Sender") == "Crew"
				GLOB.ert_request_answered = TRUE
				log_admin("[usr] denied [key_name(H)]'s ERT request with the message [reason]. Announced to [announce_to_crew ? "the entire crew." : "only the sender"].")

				if(announce_to_crew)
					GLOB.major_announcement.announce(
						message = "[station_name()], к сожалению, в настоящее время мы не можем направить к вам отряд быстрого реагирования. Ваш запрос на ОБР был отклонен по следующим причинам:\n[reason]",
						new_title = ANNOUNCE_ERT_UNAVAIL_RU
					)
					return

				if(H.stat != CONSCIOUS)
					to_chat(usr, span_warning("The person you are trying to contact is not conscious. ERT denied but no message has been sent."), confidential = TRUE)
					return
				if(!istype(H.l_ear, /obj/item/radio/headset) && !istype(H.r_ear, /obj/item/radio/headset))
					to_chat(usr, span_warning("The person you are trying to contact is not wearing a headset. ERT denied but no message has been sent."), confidential = TRUE)
					return
				to_chat(usr, span_notice("You sent [reason] to [H] via a secure channel."), confidential = TRUE)
				to_chat(H, "[span_specialnotice("Incoming priority transmission from Central Command. Message as follows,")][span_specialnotice(" Ваш запрос на ОБР был отклонен по следующим причинам: [reason].")]", confidential = TRUE)
			else
				usr.client.send_response_team()

		if("getcode")
			if(request.req_type != REQUEST_NUKE)
				to_chat(usr, span_warning("Warning! That this is a non-nuke-code-request request!"), confidential = TRUE)
			to_chat(usr, "<b>The nuke code is: [get_nuke_code()]!</b>", confidential = TRUE)
			return TRUE

/datum/request_manager/ui_data(mob/user)
	. = list(
		"requests" = list()
	)
	for(var/ckey in requests)
		for(var/datum/request/request as anything in requests[ckey])
			var/list/data = list(
				"id" = request.id,
				"req_type" = request.req_type,
				"owner" = request.owner,
				"owner_ckey" = request.owner_ckey,
				"owner_name" = request.owner_name,
				"message" = request.message,
				"timestamp" = request.timestamp,
				"timestamp_str" = gameTimestamp(wtime = request.timestamp)
			)
			.["requests"] += list(data)

#undef REQUEST_PRAYER
#undef REQUEST_CENTCOM
#undef REQUEST_SYNDICATE
#undef REQUEST_ERT
#undef REQUEST_HONK
#undef REQUEST_NUKE
