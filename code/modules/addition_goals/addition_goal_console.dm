// Addition goal console

////////////////////////////////////////
// MARK:	Addition goal console
////////////////////////////////////////

/obj/item/circuitboard/computer/addition_goals
	board_name = "addition goals console"
	build_path = /obj/machinery/computer/addition_goals
	origin_tech = "engineering=2;combat=2;bluespace=2" //TODO balance here


/obj/machinery/computer/addition_goals
	name = "addition goals console"
	desc = "Используется для управления дополнительными целями смены."
	icon_screen = "addition_goal"
	icon_keyboard = "addition_goal_key"
	req_access = list(ACCESS_CAPTAIN)
	circuit = /obj/item/circuitboard/computer/bsa_control

/obj/machinery/computer/addition_goals/get_ru_names()
	return list(
		NOMINATIVE = "консоль управления дополнительными целями смены",
		GENITIVE = "консоли управления дополнительными целями смены",
		DATIVE = "консоли управления дополнительными целями смены",
		ACCUSATIVE = "консоль управления дополнительными целями смены",
		INSTRUMENTAL = "консолью управления дополнительными целями смены",
		PREPOSITIONAL = "консоли управления дополнительными целями смены"
	)

/obj/machinery/computer/addition_goals/Initialize(mapload, obj/structure/computerframe/frame)
	. = ..()
	SSaddition_goals.console_list += src

/obj/machinery/computer/addition_goals/attack_hand(mob/user)
	. = ..()
	if(.)
		return TRUE
	ui_interact(user)

/obj/machinery/computer/addition_goals/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AdditionGoalsConsole", "Консоль побочных целей")
		ui.open()

/obj/machinery/computer/addition_goals/ui_data(mob/user)
	var/list/data = list()
	data["modal"] = ui_modal_data(src)
	data["state"] = SSaddition_goals.goal_state
	if(SSaddition_goals.shuttle)
		data["shuttle_loc"] = SSaddition_goals.get_shuttle_location()
	else
		data["shuttle_loc"] = "Шаттл не найден"
	data["refresh_available"] = SSaddition_goals.is_refresh_available()
	data["available_goals"] = get_available_goals_data()
	if(SSaddition_goals.current_goal)
		data["current_goal"] = list(
			id = "[SSaddition_goals.current_goal.id]",
			name = "[SSaddition_goals.current_goal.name]"
		)
	else
		data["current_goal"] = list(
			id = "none",
			name = "Нет текущей задачи"
		)
	return data

/obj/machinery/computer/addition_goals/proc/get_available_goals_data()
	. = list()
	for(var/datum/addition_goal/goal as anything in SSaddition_goals.available_goals)
		. += list(list(
			id = "[goal.id]",
			name = "[goal.name]"
		))


/obj/machinery/computer/addition_goals/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("refresh_available_goals")
			SSaddition_goals.refresh_available_goals()
		if("accept_goal")
			var/goal_id = params["goal"]
			var/goal = SSaddition_goals.find_goal_by_id(goal_id)
			if(!goal)
				to_chat(usr, "Ошибка, цель [goal_id] не найдена!")
				return
			to_chat(usr, "[usr.name] взял дополнительную цель смены [goal_id].")
			SSaddition_goals.accept_goal(usr, goal)
		if("complete_goal")
			SSaddition_goals.complete_current_goal(usr)
