//Verbs

/client/proc/openMentorTicketUI()

	set name = "Open Mentor Ticket Interface"
	set category = STATPANEL_ADMIN_TICKETS

	if(!check_rights(R_MENTOR))
		return

	SSmentor_tickets.showUI(usr)

/client/proc/resolveAllMentorTickets()
	set name = "Resolve All Open Mentor Tickets"

	if(!check_rights(R_ADMIN))
		return

	if(tgui_alert(usr, "Are you sure you want to resolve ALL open mentor tickets?", "Resolve all open mentor tickets?", list("Yes", "No")) != "Yes")
		return

	SSmentor_tickets.resolveAllOpenTickets()

/client/verb/openMentorUserUI()
	set name = "Ментор запросы"
	set category = STATPANEL_ADMIN_TICKETS
	SSmentor_tickets.userDetailUI(usr)
