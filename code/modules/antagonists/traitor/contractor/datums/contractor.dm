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
	antag_menu_name = "Контрактник"
	/// The associated contractor uplink. Only present if the offer was accepted.
	var/obj/item/contractor_uplink/contractor_uplink = null


/datum/antagonist/contractor/Destroy(force)
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
		stack_trace("Сontractor [owner] spawned without a hidden uplink!")
		return


/datum/antagonist/contractor/greet()
	// Greet them with the unique message
	var/list/messages = list()
	var/greet_text = "Вы приняли предложение. Выполняйте контракты, получайте теллекристаллы и докажите, что ваши наниматели в вас не ошиблись."
	messages.Add(span_fontsize4(span_fontcolor_red("<b>Вы Контрактник.</b><br>")))
	messages.Add(span_fontcolor_red("[greet_text]"))
	return messages

/datum/antagonist/contractor/on_gain()
	if(!owner?.current)
		return FALSE

	owner.special_role = special_role
	add_owner_to_gamemode()
	var/list/messages = list()
	messages.Add(greet())
	apply_innate_effects()
	finalize_antag()
	messages.Add(span_motd("С полной информацией вы можете ознакомиться на вики: <a href=\"[CONFIG_GET(string/wikiurl)]/index.php/Contractor\">Контрактор"))
	to_chat(owner.current, chat_box_red(messages.Join("<br>")))
	if(is_banned(owner.current) && replace_banned)
		INVOKE_ASYNC(src, PROC_REF(replace_banned_player))
	owner.current.create_log(MISC_LOG, "[owner.current] was made into \an [special_role]")
	return TRUE

