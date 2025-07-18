/// Addition goals system

/// How many goals available to choose
#define AVAILABLE_GOALS_COUNT 6

#define SHUTTLE_CENTCOM_DOCK "addition_goal_dock"
#define SHUTTLE_STATION_DOCK "graveyard_church"
#define ACCEPT_GOAL_SHUTTLE_SEND_DELAY 10
#define GOAL_CHECK_DELAY 10
#define REFRESH_AVAILABLE_GOALS_COOLDOWN (15 MINUTES)


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
	var/goals_id_counter = 1
	var/available_goals_refresh_time = 0

		//shuttle stuff
	var/obj/docking_port/mobile/shuttle


/// Initialization
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
/datum/controller/subsystem/addition_goals/proc/refresh_available_goals()
	if(!is_refresh_available())
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
	if(!is_shuttle_available())
		return
	var/shutte_turfs = get_shuttle_turfs()
	if(!goal.spawn_shuttle_contain(shutte_turfs))
		return
	current_goal = goal
	available_goals -= goal
	addtimer(CALLBACK(src, PROC_REF(send_shuttle_to_station), user), ACCEPT_GOAL_SHUTTLE_SEND_DELAY SECONDS)
	return TRUE

/datum/controller/subsystem/addition_goals/proc/complete_current_goal(mob/user)
	send_shuttle_to_centcom(user)
	addtimer(CALLBACK(src, PROC_REF(on_complete_goal), user), GOAL_CHECK_DELAY SECONDS)

/datum/controller/subsystem/addition_goals/proc/on_complete_goal(mob/user)
	var/progress = current_goal.check_completion()
	clear_shuttle_turfs()

/// Shuttle
/datum/controller/subsystem/addition_goals/proc/get_shuttle_turfs()
	. = list()
	if(!shuttle)
		return
	var/turf/shuttle_anchor = shuttle.loc
	for(var/x = 1; x <= 5; x++)
		for(var/y=-5; y <= 1; y++)
			var/turf/shuttle_turf = locate(shuttle_anchor.x + x, shuttle_anchor.y + y, shuttle_anchor.z)
			. += shuttle_turf




////////////////////////////////////////
// MARK:	Shuttle logic
////////////////////////////////////////

/// Clear all objects in shuttle
/datum/controller/subsystem/addition_goals/proc/clear_shuttle_turfs()
	if(!shuttle)
		return
	for(var/turf/turf in get_shuttle_turfs())
		for(var/atom/movable/obstacle in turf.contents)
			if(istype(obstacle,/obj/machinery/computer/shuttle/addition_goals))
				continue
			qdel(obstacle)

/// Try send shuttle to station (call shuttle)
/datum/controller/subsystem/addition_goals/proc/send_shuttle_to_station(mob/user)
	SSshuttle.moveShuttle(shuttle.id, SHUTTLE_STATION_DOCK, TRUE, user)

/// Try send shuttle to centrom (return shuttle)
/datum/controller/subsystem/addition_goals/proc/send_shuttle_to_centcom(mob/user)
	SSshuttle.moveShuttle(shuttle.id, SHUTTLE_CENTCOM_DOCK, TRUE, user)

/// Get text where shuttle docked
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

/// Check shuttle ready to call (docked in centcom sector)
/datum/controller/subsystem/addition_goals/proc/is_shuttle_available()
	if(!shuttle)
		return FALSE
	var/dock_id = shuttle.getDockedId()
	return dock_id == SHUTTLE_CENTCOM_DOCK

/// Only for test
/datum/controller/subsystem/addition_goals/proc/toggle_shuttle(mob/user)
	. = FALSE
	if(!shuttle)
		return
	var/dock_id = shuttle.getDockedId()
	switch(dock_id)
		if(SHUTTLE_CENTCOM_DOCK)
			send_shuttle_to_station(user)
			return TRUE
		if(SHUTTLE_STATION_DOCK)
			send_shuttle_to_centcom(user)
			return TRUE


////////////////////////////////////////
// MARK:	Basic Addition Goal
////////////////////////////////////////

/datum/addition_goal
	/// Unique goal name
	var/name

	/// Goal unique identifier (Same type goals can have difficult identifiers)
	var/id



/datum/addition_goal/proc/setup()
	message_admins("addition goal '[name]' not implement setup")

/datum/addition_goal/proc/spawn_shuttle_contain(list/turf/shuttle_turfs)
	message_admins("addition goal '[name]' not implement spawn shuttle contain")

/datum/addition_goal/proc/check_completion(list/turf/shuttle_turfs)
	message_admins("addition goal '[name]' not implement check completion")

