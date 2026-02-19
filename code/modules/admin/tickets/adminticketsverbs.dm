ADMIN_VERB(open_admin_tickets, R_ADMIN|R_MOD, "Open Admin Ticket Interface", "Open the ahelp panel.", ADMIN_CATEGORY_TICKETS)
	SStickets.showUI(user.mob)

ADMIN_VERB(resolve_all_admin_tickets, R_ADMIN, "Resolve All Open Admin Tickets", "Resolve All Open Admin Tickets", ADMIN_CATEGORY_HIDDEN)
	if(tgui_alert(user, "Are you sure you want to resolve ALL open admin tickets?", "Resolve all open admin tickets?", list("Yes", "No")) != "Yes")
		return
	SStickets.resolveAllOpenTickets()

ADMIN_VERB(open_admin_ui, R_ADMIN, "My Admin Tickets", "Open the Admin Ticket UI", ADMIN_CATEGORY_TICKETS)
	SStickets.userDetailUI(user.mob)
