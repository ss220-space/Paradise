/**
  * # Contractor antagonist datum
  *
  * A variant of the Traitor, Contractors rely on kidnapping crew members to earn TC.
  *
  * Contractors are supplied with some unique items
  * and three random low cost contraband items to help kickstart their contracts.
  * A Traitor may become a Contractor if given the chance (random).
  * They will forfeit all their initial TC and receive the above items.
  * The opportunity to become a Contractor goes away after some time or if the traitor spends any initial TC.
  */
/datum/antagonist/contractor
	name = "Contractor"
	job_rank = ROLE_TRAITOR
	special_role = SPECIAL_ROLE_TRAITOR
	antag_hud_type = ANTAG_HUD_TRAITOR
	/// How many telecrystals a traitor must forfeit to become a contractor.
	var/tc_cost = 100
	/// How long a traitor's chance to become a contractor lasts before going away. In deciseconds.
	var/offer_duration = 10 MINUTES
	/// world.time at which the offer will expire.
	var/offer_deadline = -1
	/// The associated contractor uplink. Only present if the offer was accepted.
	var/obj/item/contractor_uplink/contractor_uplink = null


/datum/antagonist/contractor/Destroy(force, ...)
	var/datum/antagonist/traitor/traitor_datum = owner?.has_antag_datum(/datum/antagonist/traitor)
	if(traitor_datum)
		traitor_datum.hidden_uplink?.contractor = null

	if(contractor_uplink)
		contractor_uplink.hub?.owner = null
		contractor_uplink.hub?.contractor_uplink = null

	return ..()


/datum/antagonist/contractor/add_antag_hud(mob/living/antag_mob)
	if(locate(/datum/objective/hijack) in owner.get_all_objectives())
		antag_hud_name = contractor_uplink ? "hudhijackcontractor" : "hudhijack"
	else
		antag_hud_name = contractor_uplink ? "hudcontractor" : "hudsyndicate"
	return ..()


/datum/antagonist/contractor/finalize_antag()

	// Setup the vars and contractor stuff in the uplink
	var/datum/antagonist/traitor/traitor_datum = owner?.has_antag_datum(/datum/antagonist/traitor)
	if(!traitor_datum)
		return

	var/obj/item/uplink/hidden/hidden_uplink = traitor_datum.hidden_uplink
	if(!hidden_uplink)
		stack_trace("Potential contractor [owner] spawned without a hidden uplink!")
		return

	hidden_uplink.contractor = src
	offer_deadline = world.time + offer_duration


/datum/antagonist/contractor/greet()
	// Greet them with the unique message
	var/list/messages = list()
	var/greet_text = "Contractors forfeit [tc_cost] telecrystals for the privilege of taking on kidnapping contracts for credit and TC payouts that can add up to more than the normal starting amount of TC.<br>"\
	 + "If you are interested, simply access your hidden uplink and select the \"Contracting Opportunity\" tab for more information.<br>"
	messages.Add("<b><font size=4 color=red>You have been offered a chance to become a Contractor.</font></b><br>")
	messages.Add("<font color=red>[greet_text]</font>")
	messages.Add("<b><i><font color=red>This offer will expire in 10 minutes starting now (expiry time: <u>[station_time_timestamp(time = offer_deadline)]</u>).</font></i></b>")
	return messages

/datum/antagonist/contractor/on_gain()
	if(!owner?.current)
		return FALSE

	owner.special_role = special_role
	add_owner_to_gamemode()
	var/list/messages = list()
	messages.Add(greet())
	apply_innate_effects()
	messages.Add(finalize_antag())
	messages.Add("<span class='motd'>С полной информацией вы можете ознакомиться на вики: <a href=\"https://wiki.ss220.space/index.php/Contractor\">Контрактор</span>")
	to_chat(owner.current, chat_box_red(messages.Join("<br>")))
	if(is_banned(owner.current) && replace_banned)
		INVOKE_ASYNC(src, PROC_REF(replace_banned_player))
	owner.current.create_log(MISC_LOG, "[owner.current] was made into \an [special_role]")
	return TRUE

/**
  * Accepts the offer to be a contractor if possible.
  */
/datum/antagonist/contractor/proc/become_contractor(mob/living/carbon/human/user, obj/item/uplink/uplink)
	if(contractor_uplink || !istype(user))
		return

	if(uplink.uses < tc_cost || world.time >= offer_deadline)
		var/reason = (uplink.uses < tc_cost) ? \
			"you have insufficient telecrystals ([tc_cost] needed in total)" : \
			"the deadline has passed"
		to_chat(user, span_warning("You can no longer become a contractor as [reason]."))
		return

	// Give the kit
	var/obj/item/storage/box/syndie_kit/contractor/contractor_kit = new(user)
	user.put_in_hands(contractor_kit)
	contractor_uplink = locate(/obj/item/contractor_uplink, contractor_kit)
	contractor_uplink.hub = new(user.mind, contractor_uplink)

	// Update AntagHUD icon
	remove_antag_hud(owner.current)
	add_antag_hud(owner.current)

	// Remove the TC
	uplink.uses -= tc_cost
