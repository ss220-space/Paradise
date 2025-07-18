// Addition goal console

////////////////////////////////////////
// MARK:	Addition goal console
////////////////////////////////////////

/obj/item/circuitboard/computer/addition_goals
	board_name = "Addition Goals Console"
	build_path = /obj/machinery/computer/addition_goals
	origin_tech = "engineering=2;combat=2;bluespace=2" //TODO balance here

/obj/machinery/computer/addition_goals
	name = "Addition Goals Console"
	desc = "Используется для управления дополнительными целями смены."
	ru_names = list(
		NOMINATIVE = "консоль управления дополнительными целями смены",
		GENITIVE = "консоли управления дополнительными целями смены",
		DATIVE = "консоли управления дополнительными целями смены",
		ACCUSATIVE = "консоль управления дополнительными целями смены",
		INSTRUMENTAL = "консолью управления дополнительными целями смены",
		PREPOSITIONAL = "консоли управления дополнительными целями смены"
	)
	icon_screen = "supply"
	req_access = list(ACCESS_CAPTAIN)
	circuit = /obj/item/circuitboard/computer/bsa_control

/obj/machinery/computer/addition_goals/attack_hand(mob/user)
	. = ..()
	if(.)
		return TRUE
	ui_interact(user)

/obj/machinery/computer/addition_goals/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AdditionGoalsConsole", "Консоль управления дополнительными целями")
		ui.open()

/obj/machinery/computer/addition_goals/ui_data(mob/user)
	var/list/data = list()
	data["modal"] = ui_modal_data(src)
	if(SSaddition_goals.shuttle)
		data["online"] = TRUE
	else
		data["online"] = FALSE
	var/datum/addition_goal/first_avail_goal = SSaddition_goals.available_goals[1]
	data["goal"] = first_avail_goal.id
	data["shuttle_loc"] = SSaddition_goals.get_shuttle_location()
	return data

/obj/machinery/computer/addition_goals/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("refresh_available_goals")
			to_chat(usr, "Пока не реализовано!")
		if("accept_goal")
			var/goal_id = params["goal"]
			to_chat(usr, "[usr.name] взял дополнительную цель смены [goal_id]")
			SSaddition_goals.accept_goal_by_id(usr, goal_id)
		if("complete_goal")
			SSaddition_goals.complete_current_goal(usr)
		if("call_shuttle")
			to_chat(usr, "Тестовая реализация!")
			SSaddition_goals.toggle_shuttle(usr)




////////////////////////////////////////
// MARK:	Other addition goal machinery
////////////////////////////////////////

/area/shuttle/addition_goals
	icon_state = "shuttle3"
	name = "Addition Goals Shuttle"

/obj/machinery/computer/shuttle/addition_goals
	name = "Addition Goal Shuttle Console"
	desc = "Используется для вызова и отправки шаттла дополнительных целей смены."
	shuttleId = "addition_goal"
	possible_destinations = "graveyard_church;addition_goal_dock"
