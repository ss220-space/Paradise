ADMIN_VERB(open_mentor_tickets, R_MENTOR|R_ADMIN, "Open Mentor Ticket Interface", "Opens the mhelp panel", ADMIN_CATEGORY_TICKETS)
	SSmentor_tickets.showUI(user.mob)

ADMIN_VERB(resolve_all_mentor_tickets, R_ADMIN, "Resolve All Open Mentor Tickets", "Resolves all open mhelps", ADMIN_CATEGORY_HIDDEN)
	if(tgui_alert(user, "Are you sure you want to resolve ALL open mentor tickets?", "Resolve all open mentor tickets?", list("Yes", "No")) != "Yes")
		return
	SSmentor_tickets.resolveAllOpenTickets()

/client/verb/openMentorUserUI()
	set name = "Ментор запросы"
	set category = ADMIN_CATEGORY_TICKETS
	SSmentor_tickets.userDetailUI(usr)
