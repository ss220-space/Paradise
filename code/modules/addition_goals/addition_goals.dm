/// Addition goals system

	//States
#define AGS_STATE_NOT_STARTED 0
#define AGS_STATE_IDLE 1
#define AGS_STATE_GOAL_IN_PROGRESS 2
#define AGS_STATE_GOAL_COMPLETE 3

/// How many goals available to choose
#define AVAILABLE_GOALS_COUNT 6
/// Refresh goals button activation cooldown
#define REFRESH_AVAILABLE_GOALS_COOLDOWN (15 MINUTES)

/// Delay between accept goal and send shuttle to station
#define ACCEPT_GOAL_SHUTTLE_SEND_DELAY 10
/// Delay between complete goal and send shuttle to centcom
#define COMPLETE_GOAL_SHUTTLE_SEND_DELAY 10
/// Addition goals system shuttle identifier
#define AGS_SHUTTLE_ID "addition_goal"
/// Centom stationary dock id
#define AGS_SHUTTLE_CENTCOM_DOCK "addition_goal_dock"
/// Station stationary dock id
#define AGS_SHUTTLE_STATION_DOCK "graveyard_church"




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
	var/goal_state = AGS_STATE_NOT_STARTED

		//goals stuff
	var/list/goal_types = list()
	var/list/available_goals = list()
	var/datum/addition_goal/current_goal = null
	var/goals_id_counter = 1
	var/available_goals_refresh_time = 0

		//shuttle stuff
	var/obj/docking_port/mobile/shuttle

		//console stuff
	var/list/console_list = list()


/// Initialization
/datum/controller/subsystem/addition_goals/Initialize()
	init_goal_types()
	init_shuttle()
	refresh_available_goals(force = TRUE)
	goal_state = AGS_STATE_IDLE
	return SS_INIT_SUCCESS

/datum/controller/subsystem/addition_goals/proc/init_goal_types()
	for(var/typepath in subtypesof(/datum/addition_goal))
		goal_types += typepath

/datum/controller/subsystem/addition_goals/proc/init_shuttle()
	shuttle = SSshuttle.getShuttle(AGS_SHUTTLE_ID)
	if(shuttle)
		RegisterSignal(shuttle, COMSIG_SHUTTLE_DOCK, PROC_REF(on_shuttle_dock))


/// Fire
/datum/controller/subsystem/addition_goals/fire(resumed = FALSE)
	//TODO need?




////////////////////////////////////////
// MARK:	Goals logic
////////////////////////////////////////

/// Check available refresh
/datum/controller/subsystem/addition_goals/proc/is_refresh_available()
	var/current_time = world.time / 10
	return available_goals_refresh_time + REFRESH_AVAILABLE_GOALS_COOLDOWN <= current_time

/// Refresh available goals list (delete old goals, create new goals)
/datum/controller/subsystem/addition_goals/proc/refresh_available_goals(force = FALSE)
	if(!force && !is_refresh_available())
		return FALSE
	available_goals_refresh_time = world.time / 10
	for(var/goal as anything in available_goals) // delete old available goals
		qdel(goal)
		available_goals -= goal
	for(var/i = 0; i < AVAILABLE_GOALS_COUNT; i++) // create new goals as available
		var/goal_type = pick(goal_types)
		var/datum/addition_goal/goal = new goal_type()
		goal.id = "goal_[goals_id_counter]"
		goals_id_counter += 1
		goal.setup()
		available_goals += goal
	return TRUE

/// Find goal from available list
/datum/controller/subsystem/addition_goals/proc/find_goal_by_id(goal_id)
	for(var/datum/addition_goal/goal as anything in available_goals)
		if(goal.id == goal_id)
			return goal

/// Accept goal to work
/datum/controller/subsystem/addition_goals/proc/accept_goal(mob/user, datum/addition_goal/goal)
	. = FALSE
	if(current_goal)
		return
	if(!is_shuttle_in_centcom())
		return
	var/shutte_turfs = get_shuttle_turfs()
	if(!goal.spawn_shuttle_contain(shutte_turfs))
		return
	goal_state = AGS_STATE_GOAL_IN_PROGRESS
	current_goal = goal
	available_goals -= goal
	print_accept_goal_details(user, goal)
	addtimer(CALLBACK(src, PROC_REF(send_shuttle_to_station), user), ACCEPT_GOAL_SHUTTLE_SEND_DELAY SECONDS)
	return TRUE

/datum/controller/subsystem/addition_goals/proc/complete_current_goal(mob/user)
	if(!is_shuttle_in_station())
		message_admins("[user.name] try complete addition goal, error - shuttle not exists on station dock")
		return FALSE
	if(goal_state != AGS_STATE_GOAL_IN_PROGRESS)
		message_admins("[user.name] try complete addition goal, error - invalid state [goal_state]")
		return FALSE
	goal_state = AGS_STATE_GOAL_COMPLETE
	addtimer(CALLBACK(src, PROC_REF(send_shuttle_to_centcom), user), COMPLETE_GOAL_SHUTTLE_SEND_DELAY SECONDS)
	message_admins("[user.name] complete addition goal [current_goal.id]")
	return TRUE


/// When dock shuttle to dock (signal handler)
/datum/controller/subsystem/addition_goals/proc/on_shuttle_dock(datum/source, /obj/docking_port/mobile/shuttle, obj/docking_port/stationary/new_dock)
	SIGNAL_HANDLER
	message_admins("addition goal shuttle dock into [new_dock.id] state=[goal_state]")
	if(goal_state != AGS_STATE_GOAL_COMPLETE)
		return
	if(new_dock.id != AGS_SHUTTLE_CENTCOM_DOCK)
		message_admins("addition goals shuttle dock to unknown location=[new_dock.id] in goal complete state")
		return
	if(!current_goal)
		message_admins("can not complete goal - goal not exists")
		goal_state = AGS_STATE_IDLE
		return
	message_admins("complete addition goal [current_goal.id]")
	var/progress = current_goal.check_completion()
	print_complete_goal_details(current_goal, progress)
	current_goal = null
	clear_shuttle_turfs()
	if(!length(available_goals))
		refresh_available_goals(force = TRUE)
	goal_state = AGS_STATE_IDLE




////////////////////////////////////////
// MARK:	Shuttle logic
////////////////////////////////////////

/// Try send shuttle to station (call shuttle)
/datum/controller/subsystem/addition_goals/proc/send_shuttle_to_station(mob/user)
	SSshuttle.moveShuttle(shuttle.id, AGS_SHUTTLE_STATION_DOCK, FALSE, user)

/// Try send shuttle to centrom (return shuttle)
/datum/controller/subsystem/addition_goals/proc/send_shuttle_to_centcom(mob/user)
	SSshuttle.moveShuttle(shuttle.id, AGS_SHUTTLE_CENTCOM_DOCK, FALSE, user)

/// Get text where shuttle docked
/datum/controller/subsystem/addition_goals/proc/get_shuttle_location()
	if(!shuttle)
		return "Неизвестно"
	var/dock_id = shuttle.getDockedId()
	switch(dock_id)
		if(AGS_SHUTTLE_CENTCOM_DOCK)
			return "На ЦК"
		if(AGS_SHUTTLE_STATION_DOCK)
			return "На станции"
		else
			return shuttle.getStatusText()

/// Check shuttle ready to call (docked in centcom sector)
/datum/controller/subsystem/addition_goals/proc/is_shuttle_in_centcom()
	if(!shuttle)
		return FALSE
	var/dock_id = shuttle.getDockedId()
	return dock_id == AGS_SHUTTLE_CENTCOM_DOCK

/// Check shuttle ready to return (docked in station sector)
/datum/controller/subsystem/addition_goals/proc/is_shuttle_in_station()
	if(!shuttle)
		return FALSE
	var/dock_id = shuttle.getDockedId()
	return dock_id == AGS_SHUTTLE_STATION_DOCK

/// Collect shuttle floor turfs
/datum/controller/subsystem/addition_goals/proc/get_shuttle_turfs()
	. = list()
	if(!shuttle)
		return
	var/turf/shuttle_anchor = shuttle.loc
	//TODO change it
	for(var/x = 1; x <= 5; x++)
		for(var/y=-5; y <= 1; y++)
			var/turf/shuttle_turf = locate(shuttle_anchor.x + x, shuttle_anchor.y + y, shuttle_anchor.z)
			. += shuttle_turf

/// Clear all objects in shuttle
/datum/controller/subsystem/addition_goals/proc/clear_shuttle_turfs()
	if(!shuttle)
		return
	for(var/turf/turf in get_shuttle_turfs())
		for(var/atom/movable/obstacle in turf.contents)
			if(istype(obstacle,/obj/machinery/computer/shuttle/addition_goals))
				continue
			qdel(obstacle)

/// Only for test
/datum/controller/subsystem/addition_goals/proc/toggle_shuttle(mob/user)
	. = FALSE
	if(!shuttle)
		return
	var/dock_id = shuttle.getDockedId()
	switch(dock_id)
		if(AGS_SHUTTLE_CENTCOM_DOCK)
			send_shuttle_to_station(user)
			return TRUE
		if(AGS_SHUTTLE_STATION_DOCK)
			send_shuttle_to_centcom(user)
			return TRUE




////////////////////////////////////////
// MARK:	Console logic
////////////////////////////////////////

/datum/controller/subsystem/addition_goals/proc/print_accept_goal_details(mob/user, datum/addition_goal/goal)
	goal.directive = "Nanotrasen Directive [pick(GLOB.phonetic_alphabet)] \Roman[rand(1,50)]"
	var/report = goal.format_accept_report(user)
	var/report_message = "<div style='text-align:center;'><img src = ntlogo.png>" + "<h3>[goal.directive]</h3></div><hr>[report]"
	print_report_on_console(goal.directive, report_message, stamp = TRUE)

/datum/controller/subsystem/addition_goals/proc/print_complete_goal_details(datum/addition_goal/goal, progress)
	var/report_message = "<div style='text-align:center;'><img src = ntlogo.png>" + "<h3>[goal.directive]</h3></div><hr>Выполнено на [progress]%.<br>Ваша награда:<br>"
	print_report_on_console(goal.directive, report_message, stamp = TRUE)

/// Print report paper on all Addition goal consoles
/datum/controller/subsystem/addition_goals/proc/print_report_on_console(directive, message, stamp = FALSE)
	for(var/obj/machinery/computer/addition_goals/console as anything in console_list)
		if(console.stat & (BROKEN|NOPOWER))
			continue
		var/obj/item/paper/paper = new (console.loc)
		paper.name = "[directive]"
		paper.info = message
		if(stamp)
			paper.stamp(/obj/item/stamp/navcom)




////////////////////////////////////////
// MARK:	Basic Addition Goal
////////////////////////////////////////

/datum/addition_goal
	/// Unique goal name
	var/name
	/// Goal unique identifier (Same type goals can have difficult identifiers)
	var/id

	// Accept goal data
	var/directive = "Unknown"



/datum/addition_goal/proc/setup()
	message_admins("addition goal '[name]' not implement setup")

/datum/addition_goal/proc/spawn_shuttle_contain(list/turf/shuttle_turfs)
	message_admins("addition goal '[name]' not implement spawn_shuttle_contain")
	return FALSE

/datum/addition_goal/proc/format_accept_report(mob/user)
	message_admins("addition goal '[name]' not implement format_accept_report")
	return "<b>Adddition Goal System ERROR</b><br>Report admins about this paper."

/datum/addition_goal/proc/check_completion(list/turf/shuttle_turfs)
	message_admins("addition goal '[name]' not implement check_completion")
	return 0
