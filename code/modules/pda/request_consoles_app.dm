/datum/data/pda/app/request_console
	name = "Request Consoles"
	title = "Request Consoles"
	icon = "archive"
	template = "pda_request_console"
	category = "Request Console"
	update = PDA_APP_UPDATE
	var/list/department_list
	var/list/possible_consoles = list()
	var/list/consoles_mute = list()
	var/ore_message_reciver_dep
	var/obj/machinery/requests_console/selected_console

/datum/data/pda/app/request_console/New()
	. = ..()
	for(var/C in (GLOB.allRequestConsoles))
		var/obj/machinery/requests_console/console = C
		if(QDELETED(console) || !istype(console))
			continue
		if(console.department in department_list)
			possible_consoles |= console
			department_list -= console.department
			console.connected_apps |= src


/datum/data/pda/app/request_console/Destroy()
	selected_console = null
	LAZYNULL(possible_consoles)
	. = ..()

/datum/data/pda/app/request_console/proc/on_rc_destroyed(datum/source)
	possible_consoles -= source
	SStgui.update_uis(pda)

/datum/data/pda/app/request_console/proc/on_rc_message_recieved(obj/machinery/requests_console/source, message, isoremessage)
	SIGNAL_HANDLER
	if(isoremessage && source.department != ore_message_reciver_dep)
		return
	var/rendered_message = "Recieved on [source.name] : [message]"
	if(!QDELETED(pda) && !consoles_mute[source])
		notify(rendered_message)


/datum/data/pda/app/request_console/update_ui(mob/user, list/data)
	if(selected_console)
		data += selected_console.ui_data(user)
		data["selected_console"] = selected_console.name
	else
		data["selected_console"] = null
		var/list/possible_consoles_data= list()
		for(var/obj/machinery/requests_console/console as anything in possible_consoles)
			possible_consoles_data += list(list("name" = console.name, "priority" = console.newmessagepriority, "muted" = consoles_mute[console]))
		data["consoles_data"] = possible_consoles_data

/datum/data/pda/app/request_console/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	var/name = params["name"]
	var/obj/machinery/requests_console/clicked_console
	for(var/atom/console as anything in possible_consoles)
		if(console.name == name)
			clicked_console = console
			break
	switch(action)
		if("select")
			if(!clicked_console)
				return
			selected_console = clicked_console
			title = clicked_console.name
			unnotify()
		if("mute")
			if(!clicked_console)
				return
			consoles_mute[clicked_console] = !consoles_mute[clicked_console]
		if("back")
			selected_console = null
			title = initial(title)
		else
			selected_console?.ui_act(action, params, ui, state)
			login()
	SStgui.update_uis(pda)


/datum/data/pda/app/request_console/on_id_updated()
	login()


/datum/data/pda/app/request_console/proc/login()
	if(pda.id && selected_console)
		selected_console.login_console(selected_console.screen, pda.id, pda, usr)


/datum/data/pda/app/request_console/stamp_act(obj/item/stamp/stamp)
	if(!..() || !selected_console)
		return FALSE
	var/result = selected_console.stamp_messauth(selected_console.screen, stamp, pda, usr)
	if(ATTACK_CHAIN_SUCCESS_CHECK(result))
		return TRUE
	return FALSE

/datum/data/pda/app/request_console/cargo
	department_list = list(RC_CARGO_BAY)

/datum/data/pda/app/request_console/shaftminer
	department_list = list(RC_CARGO_BAY)

/datum/data/pda/app/request_console/botanist
	department_list = list(RC_HYDROPONICS)

/datum/data/pda/app/request_console/chef
	department_list = list(RC_KITCHEN)

/datum/data/pda/app/request_console/bar
	department_list = list(RC_BAR)

/datum/data/pda/app/request_console/janitor
	department_list = list(RC_JANITORIAL)

/datum/data/pda/app/request_console/chaplain
	department_list = list(RC_CHAPEL)

/datum/data/pda/app/request_console/security
	department_list = list(RC_SECURITY)

/datum/data/pda/app/request_console/clown_security
	department_list = list(RC_SECURITY)

/datum/data/pda/app/request_console/lawyer
	department_list = list(RC_INTERNAL_AFFAIRS_OFFICE)

/datum/data/pda/app/request_console/medical
	department_list = list(
							RC_MEDBAY,
							RC_MORGUE
						)

/datum/data/pda/app/request_console/viro
	department_list = list(
							RC_MEDBAY,
							RC_VIROLOGY,
							RC_MORGUE
						)

/datum/data/pda/app/request_console/engineering
	department_list = list(
							RC_TECH_STORAGE,
							RC_ENGINEERING,
							RC_ATMOSPHERICS,
							RC_MECHANIC
						)
	ore_message_reciver_dep = RC_MECHANIC


/datum/data/pda/app/request_console/detective
	department_list = list(
							RC_SECURITY,
							RC_DETECTIVE
						)

/datum/data/pda/app/request_console/warden
	department_list = list(
							RC_SECURITY,
							RC_WARDEN,
							RC_LABOR_CAMP
						)

/datum/data/pda/app/request_console/toxins
	department_list = list(
							RC_SCIENCE,
							RC_ROBOTICS,
							RC_RESEARCH,
							RC_XENOBIOLOGY
						)
	ore_message_reciver_dep = RC_RESEARCH

/datum/data/pda/app/request_console/hop
	department_list = list(
							RC_BAR,
							RC_KITCHEN,
							RC_HEAD_OF_PERSONNEL_DESK,
							RC_BRIDGE,
							RC_HYDROPONICS,
							RC_JANITORIAL,
							RC_CHAPEL
						)

/datum/data/pda/app/request_console/hos
	department_list =	list(RC_SECURITY,
							RC_WARDEN,
							RC_LABOR_CAMP,
							RC_HEAD_OF_SECURITY_DESK,
							RC_BRIDGE,
							RC_DETECTIVE)

/datum/data/pda/app/request_console/ce
	department_list = list(
							RC_TECH_STORAGE,
							RC_ENGINEERING,
							RC_ATMOSPHERICS,
							RC_MECHANIC,
							RC_BRIDGE,
							RC_AI,
							RC_CHIEF_ENGINEER_DESK
						)
	ore_message_reciver_dep = RC_MECHANIC

/datum/data/pda/app/request_console/cmo
	department_list = list(
							RC_MEDBAY,
							RC_VIROLOGY,
							RC_MORGUE,
							RC_GENETICS,
							RC_BRIDGE,
							RC_CHEMISTRY,
							RC_CHIEF_MEDICAL_OFFICER_DESK
						)

/datum/data/pda/app/request_console/rd
	department_list = list(
							RC_SCIENCE,
							RC_ROBOTICS,
							RC_RESEARCH,
							RC_XENOBIOLOGY,
							RC_GENETICS,
							RC_BRIDGE,
							RC_AI,
							RC_RESEARCH_DIRECTOR_DESK
						)
	ore_message_reciver_dep = RC_RESEARCH

/datum/data/pda/app/request_console/captain
	department_list = list(
							RC_CHIEF_ENGINEER_DESK,
							RC_CHIEF_MEDICAL_OFFICER_DESK,
							RC_HEAD_OF_PERSONNEL_DESK,
							RC_HEAD_OF_SECURITY_DESK,
							RC_BRIDGE,
							RC_QUARTERMASTER_DESK,
							RC_AI,
							RC_CAPTAIN_DESK,
							RC_RESEARCH_DIRECTOR_DESK
						)
	ore_message_reciver_dep = RC_RESEARCH_DIRECTOR_DESK

/datum/data/pda/app/request_console/ntrep
	department_list = list(
							RC_NT_REPRESENTATIVE,
							RC_BLUESHIELD,
							RC_INTERNAL_AFFAIRS_OFFICE,
							RC_BRIDGE
						)

/datum/data/pda/app/request_console/magistrate
	department_list = list(
							RC_INTERNAL_AFFAIRS_OFFICE,
							RC_BRIDGE
						)

/datum/data/pda/app/request_console/blueshield
	department_list = list(
							RC_BLUESHIELD,
							RC_BRIDGE
						)

/datum/data/pda/app/request_console/quartermaster
	department_list = list(
							RC_CARGO_BAY,
							RC_QUARTERMASTER_DESK,
							RC_BRIDGE
						)

/datum/data/pda/app/request_console/roboticist
	department_list = list(
							RC_RESEARCH,
							RC_SCIENCE,
							RC_ROBOTICS
						)
	ore_message_reciver_dep = RC_ROBOTICS

/datum/data/pda/app/request_console/atmos
	department_list = list(
							RC_TECH_STORAGE,
							RC_ATMOSPHERICS,
							RC_ENGINEERING
						)
	ore_message_reciver_dep = RC_ATMOSPHERICS

/datum/data/pda/app/request_console/chemist
	department_list = list(
							RC_CHEMISTRY,
							RC_MEDBAY
						)

/datum/data/pda/app/request_console/geneticist
	department_list = list(
							RC_GENETICS,
							RC_MEDBAY
						)

/datum/data/pda/app/request_console/centcom
	department_list = list(
							RC_BRIDGE,
							RC_AI,
							RC_BLUESHIELD,
							RC_INTERNAL_AFFAIRS_OFFICE,
							RC_NT_REPRESENTATIVE,
							RC_CENTRAL_COMMAND,
							RC_CAPTAIN_DESK
						)
