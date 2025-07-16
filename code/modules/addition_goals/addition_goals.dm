/// Addition goals system

/// How many goals available to choose
#define AVAILABLE_GOALS_COUNT 6

#define SHUTTLE_CENTCOM_DOCK "addition_goal_dock"
#define SHUTTLE_STATION_DOCK "graveyard_church"

////////////////////////////////////////
// MARK:	Sybsystem
////////////////////////////////////////
SUBSYSTEM_DEF(addition_goals)
	name = "Addition Goals"
	wait = 1 SECONDS
	init_order = INIT_ORDER_CARGO_QUESTS
	flags = SS_KEEP_TIMING
	offline_implications = "Addition goals will no longer function."
	ss_id = "addition_goals"

		//goals stuff
	var/list/goal_types = list()
	var/list/available_goals = list()
	var/datum/addition_goal/current_goal = null

		//shuttle stuff
	var/obj/docking_port/mobile/shuttle



/datum/controller/subsystem/addition_goals/Initialize()
	init_goal_types()
	init_shuttle()
	refresh_available_goals()
	return SS_INIT_SUCCESS

/datum/controller/subsystem/addition_goals/proc/init_goal_types()
	for(var/typepath in subtypesof(/datum/addition_goal))
		goal_types += typepath

/datum/controller/subsystem/addition_goals/proc/init_shuttle()
	shuttle = SSshuttle.getShuttle("addition_goal")

/datum/controller/subsystem/addition_goals/proc/refresh_available_goals()
	for(var/i = 0; i < AVAILABLE_GOALS_COUNT; i++)
		var/goal_type = pick(goal_types)
		var/datum/addition_goal/goal = new goal_type()
		goal.setup()
		available_goals += goal


/datum/controller/subsystem/addition_goals/fire(resumed = FALSE)
	//TODO need?


/datum/controller/subsystem/addition_goals/proc/apply_goal(datum/addition_goal/goal)
	current_goal = goal
	available_goals -= goal
	goal.spawn_shuttle_contain(get_shuttle_turfs())
	send_shuttle_to_station()

/datum/controller/subsystem/addition_goals/proc/get_shuttle_turfs()
	. = list()
	if(shuttle)
		var/area/shuttle_area = shuttle.areaInstance
		for(var/turf/T in shuttle_area.contained_turfs)
			. += T
		return
	. += locate(128, 128, 3)
	. += locate(127, 128, 3)
	. += locate(128, 127, 3)
	. += locate(127, 127, 3)

/datum/controller/subsystem/addition_goals/proc/send_shuttle_to_station()
	//TODO implement

/datum/controller/subsystem/addition_goals/proc/send_shuttle_to_centcom()
	//TODO implement

/datum/controller/subsystem/addition_goals/proc/get_shuttle_location()
	if(!shuttle)
		return "Неизвестно"
	var/dock_id = shuttle.getDockedId()
	switch(dock_id)
		if(SHUTTLE_CENTCOM_DOCK)
			return "На ЦК"
		if(SHUTTLE_STATION_DOCK)
			return "На станции"
		else
			return shuttle.getStatusText()

/datum/controller/subsystem/addition_goals/proc/toggle_shuttle(mob/user)
	. = FALSE
	if(!shuttle)
		return
	var/dock_id = shuttle.getDockedId()
	switch(dock_id)
		if(SHUTTLE_CENTCOM_DOCK)
			SSshuttle.moveShuttle(shuttle.id, SHUTTLE_STATION_DOCK, TRUE, user)
			return TRUE
		if(SHUTTLE_STATION_DOCK)
			SSshuttle.moveShuttle(shuttle.id, SHUTTLE_CENTCOM_DOCK, TRUE, user)
			return TRUE



////////////////////////////////////////
// MARK:	Machinery
////////////////////////////////////////

/area/shuttle/addition_goals
	icon_state = "shuttle3"
	name = "Addition Goals Shuttle"

/obj/machinery/computer/shuttle/addition_goals
	name = "Addition Goal Shuttle Console"
	desc = "Используется для вызова и отправки шаттла дополнительных целей смены."
	shuttleId = "addition_goal"
	possible_destinations = "graveyard_church;addition_goal_dock"

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
	data["shuttle_loc"] = SSaddition_goals.get_shuttle_location()
	return data

/obj/machinery/computer/addition_goals/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("refresh_available_goals")
			to_chat(usr, "Пока не реализовано!")
		if("accept_goal")
			to_chat(usr, "Пока не реализовано!")
		if("call_shuttle")
			to_chat(usr, "Тестовая реализация!")
			SSaddition_goals.toggle_shuttle(usr)



////////////////////////////////////////
// MARK:	Goals
////////////////////////////////////////

/datum/addition_goal
	/// Unique goal name
	var/name

/datum/addition_goal/proc/setup()
	message_admins("addition goal '[name]' not implement setup")

/datum/addition_goal/proc/spawn_shuttle_contain(list/turf/shuttle_turfs)
	message_admins("addition goal '[name]' not implement spawn shuttle contain")

/datum/addition_goal/proc/check_completion(list/turf/shuttle_turfs)
	message_admins("addition goal '[name]' not implement check completion")


/datum/addition_goal/funeral
	name = "Шаттл с трупами"
	var/corpse_count
	var/list/corpses = list()

/datum/addition_goal/funeral/setup()
	corpse_count = rand(3, 5)

/datum/addition_goal/funeral/spawn_shuttle_contain(list/turf/shuttle_turfs)
	for(var/i = 0; i < corpse_count; i++)
		var/turf/random_turf = pick(shuttle_turfs)
		var/obj/effect/mob_spawn/spawner = new /obj/effect/mob_spawn/human/corpse/addition_goal/funeral(random_turf)
		var/mob/living/corpse = spawner.create(prefs = TRUE)
		corpses += corpse

/obj/effect/mob_spawn/human/corpse/addition_goal/funeral
	random = TRUE
	outfit = /datum/outfit/space_graveyard

/datum/addition_goal/funeral/check_completion(list/turf/shuttle_turfs)
	var/exists_corpses_count = 0
	for(var/mob/living/corpse in corpses)
		if(corpse)
			exists_corpses_count += 1
	return exists_corpses_count / corpse_count * 100
