/mob/dead/observer/proc/update_admin_actions()
	for(var/datum/action/innate/admin/action in actions)
		if(!check_rights(action.rights_required, FALSE, src))
			qdel(action)

	if(!client || !client.holder)
		return
	if(ckey && (ckey in (GLOB.de_admins + GLOB.de_mentors + GLOB.de_devs)))
		return

	for(var/datum/action/innate/admin/action as anything in subtypesof(/datum/action/innate/admin))
		if(check_rights(action.rights_required, FALSE, src))
			var/datum/action/innate/admin/given_action = new action()
			given_action.Grant(src)

/datum/action/innate/admin
	button_icon = 'icons/mob/actions/actions_admin.dmi'
	var/rights_required = R_ADMIN
	allow_observer_click = TRUE

/datum/action/innate/admin/Trigger(mob/clicker, trigger_flags)
	if(!..())
		return FALSE
	if(!check_rights(rights_required, TRUE, usr))
		return
	admin_click(usr)

/datum/action/innate/admin/proc/admin_click(mob/user)
	return

/datum/action/innate/admin/ticket
	name = ADMINHELP_SYSTEM_NAME
	desc = "Открыто 0 тикетов."
	button_icon_state = "adminhelp"
	var/ticket_amt = 0

/datum/action/innate/admin/ticket/New(Target)
	button_icon_state = "nohelp"
	. = ..()
	register_ticket_signals()

/datum/action/innate/admin/ticket/admin_click(mob/user)
	SStickets.showUI(user)

/datum/action/innate/admin/ticket/proc/register_ticket_signals()
	RegisterSignal(SStickets, COMSIGN_TICKET_COUNT_UPDATE, PROC_REF(update_tickets))
	SStickets.open_ticket_count_updated() // update the starting count

/datum/action/innate/admin/ticket/proc/update_tickets(ticketsystem, _ticket_amt)
	ticket_amt = _ticket_amt
	desc = "Открыто [ticket_amt] тикет[DECL_CREDIT(ticket_amt)]."
	if(ticket_amt > 0)
		button_icon_state = initial(button_icon_state)
	else
		button_icon_state = "nohelp"
	UpdateButtonIcon()

/datum/action/innate/admin/ticket/create_button()
	var/atom/movable/screen/movable/action_button/button = ..()
	button.maptext = "[ticket_amt]"
	button.maptext_x = 2
	return button


/datum/action/innate/admin/ticket/update_button_status(atom/movable/screen/movable/action_button/button, force = FALSE)
	if(ticket_amt <= 0)
		button.maptext = ""
		return
	button.maptext = MAPTEXT("<b>[ticket_amt]</b>")

/datum/action/innate/admin/ticket/mentor
	name = MENTORHELP_SYSTEM_NAME
	button_icon_state = "mentorhelp"
	rights_required = R_MENTOR|R_ADMIN

/datum/action/innate/admin/ticket/mentor/register_ticket_signals()
	RegisterSignal(SSmentor_tickets, COMSIGN_TICKET_COUNT_UPDATE, PROC_REF(update_tickets))
	SSmentor_tickets.open_ticket_count_updated() // update the starting count

/datum/action/innate/admin/ticket/mentor/admin_click(mob/user)
	SSmentor_tickets.showUI(user)
