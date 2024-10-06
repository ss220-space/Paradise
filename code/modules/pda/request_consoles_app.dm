/datum/data/pda/app/request_console
	name = "Request Console"
	title = "Request Console"
	icon = "archive"
	template = "pda_request_console"
	category = "Request Console"
	update = PDA_APP_UPDATE
	var/department_name = ""
	var/obj/machinery/requests_console/requests_console

/datum/data/pda/app/request_console/New()
	. = ..()
	for(var/C in (GLOB.allRequestConsoles))
		var/obj/machinery/requests_console/console = C
		if(QDELETED(console) || !istype(console))
			continue
		if(console.department == department_name)
			requests_console = console
			name = requests_console.name
			title = requests_console.name
			break
	if(requests_console)
		requests_console.connected_apps |= src
		RegisterSignal(requests_console, COMSIG_RC_MESSAGE_RECEIVED, PROC_REF(on_rc_message_recieved))

/datum/data/pda/app/request_console/Destroy()
	if(requests_console)
		UnregisterSignal(requests_console, COMSIG_RC_MESSAGE_RECEIVED)
		requests_console = null
	. = ..()
/datum/data/pda/app/request_console/proc/on_rc_destroyed()
	UnregisterSignal(requests_console, COMSIG_RC_MESSAGE_RECEIVED)
	requests_console = null
	SStgui.update_uis(pda)

/datum/data/pda/app/request_console/proc/on_rc_message_recieved(datum/source, message)
	SIGNAL_HANDLER
	notify(message)


/datum/data/pda/app/request_console/update_ui(mob/user, list/data)
	if(requests_console)
		data += requests_console.ui_data(user)
		data["not_found"] = null
	else
		data["not_found"] = TRUE


/datum/data/pda/app/request_console/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	requests_console?.ui_act(action, params, ui, state)
	login()
	SStgui.update_uis(pda)


/datum/data/pda/app/request_console/on_id_updated()
	login()


/datum/data/pda/app/request_console/proc/login()
	if(pda.id)
		requests_console.login_console(requests_console.screen, pda.id, pda, usr)


/datum/data/pda/app/request_console/stamp_act(obj/item/stamp/stamp)
	if(!..())
		return FALSE
	var/result = requests_console.stamp_messauth(requests_console.screen, stamp, pda, usr)
	if(ATTACK_CHAIN_SUCCESS_CHECK(result))
		return TRUE
	return FALSE


/datum/data/pda/app/request_console/medbay
	department_name = "Medbay"

/datum/data/pda/app/request_console/virology
	department_name = "Virology"

/datum/data/pda/app/request_console/engineering
	department_name = "Engineering"

/datum/data/pda/app/request_console/security
	department_name = "Security"

/datum/data/pda/app/request_console/detective
	department_name = "Detective"

/datum/data/pda/app/request_console/warden
	department_name = "Warden"

/datum/data/pda/app/request_console/research_director_desk
	department_name = "Research Director's Desk"

/datum/data/pda/app/request_console/bar
	department_name = "Bar"

/datum/data/pda/app/request_console/tech_storage
	department_name = "Tech storage"

/datum/data/pda/app/request_console/head_of_personnel_desk
	department_name = "Head of Personnel's Desk"

/datum/data/pda/app/request_console/ai
	department_name = "AI"

/datum/data/pda/app/request_console/robotics
	department_name = "Robotics"

/datum/data/pda/app/request_console/science
	department_name = "Science"

/datum/data/pda/app/request_console/bridge
	department_name = "Bridge"

/datum/data/pda/app/request_console/cargo_bay
	department_name = "Cargo Bay"

/datum/data/pda/app/request_console/captain_desk
	department_name = "Captain's Desk"

/datum/data/pda/app/request_console/xenobiology
	department_name = "Xenobiology"

/datum/data/pda/app/request_console/genetics
	department_name = "Genetics"

/datum/data/pda/app/request_console/hydroponics
	department_name = "Hydroponics"

/datum/data/pda/app/request_console/blueshield
	department_name = "Blueshield"

/datum/data/pda/app/request_console/head_of_security_desk
	department_name = "Head of Security's Desk"

/datum/data/pda/app/request_console/internal_affairs_office
	department_name = "Internal Affairs Office"

/datum/data/pda/app/request_console/chief_engineer_desk
	department_name = "Chief Engineer's Desk"

/datum/data/pda/app/request_console/nt_representative
	department_name = "NT Representative"

/datum/data/pda/app/request_console/chief_medical_officer_desk
	department_name = "Chief Medical Officer's Desk"

/datum/data/pda/app/request_console/quartermaster_desk
	department_name = "Quartermaster's Desk"

/datum/data/pda/app/request_console/mechanic
	department_name = "Mechanic"

/datum/data/pda/app/request_console/morgue
	department_name = "Morgue"

/datum/data/pda/app/request_console/chemistry
	department_name = "Chemistry"

/datum/data/pda/app/request_console/atmospherics
	department_name = "Atmospherics"

/datum/data/pda/app/request_console/janitorial
	department_name = "Janitorial"

/datum/data/pda/app/request_console/kitchen
	department_name = "Kitchen"

/datum/data/pda/app/request_console/chapel
	department_name = "Chapel"

/datum/data/pda/app/request_console/research
	department_name = "Research"

/datum/data/pda/app/request_console/central_command
	department_name = "Central Command"
