/// Addition goals system

//States
#define AGS_STATE_NOT_STARTED 0
#define AGS_STATE_IDLE 10
#define AGS_STATE_GOAL_PREPARE 11
#define AGS_STATE_GOAL_IN_PROGRESS 20
#define AGS_STATE_GOAL_COMPLETE 21

/// How many goals available to choose
#define AVAILABLE_GOALS_COUNT 6
/// Refresh goals button activation cooldown
#define REFRESH_AVAILABLE_GOALS_COOLDOWN (15 MINUTES)

/// Delay between accept goal and send shuttle to station
#define ACCEPT_GOAL_SHUTTLE_SEND_DELAY 3
/// Delay between complete goal and send shuttle to centcom
#define COMPLETE_GOAL_SHUTTLE_SEND_DELAY 10
/// Addition goals system shuttle identifier
#define AGS_SHUTTLE_ID "addition_goal"
/// Funeral shuttle identifier (for recall if dock is busy)
#define AGS_FUNERAL_SHUTTLE_ID "funeral"
/// Centom stationary dock id
#define AGS_SHUTTLE_CENTCOM_DOCK "addition_goal_dock"
/// Station stationary dock id
#define AGS_SHUTTLE_STATION_DOCK "graveyard_church"
/// Funeral shuttle away stationary dock id
#define AGS_FUNERAL_SHUTTLE_AWAY_DOCK "graveyard_dock"




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
	var/available_goals_refresh_time = -REFRESH_AVAILABLE_GOALS_COOLDOWN //initially available refresh
	//shuttle stuff
	var/obj/docking_port/mobile/shuttle
	var/obj/docking_port/mobile/funeral_shuttle
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
	funeral_shuttle = SSshuttle.getShuttle(AGS_FUNERAL_SHUTTLE_ID)


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
		goal.id = "[goal.id]_[goals_id_counter]"
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
	goal_state = AGS_STATE_GOAL_PREPARE
	current_goal = goal
	available_goals -= goal
	print_accept_goal_details(user, goal)
	addtimer(CALLBACK(src, PROC_REF(send_shuttle_to_station), user), ACCEPT_GOAL_SHUTTLE_SEND_DELAY SECONDS)
	return TRUE

/datum/controller/subsystem/addition_goals/proc/complete_current_goal(mob/user)
	if(!is_shuttle_in_station())
		return FALSE
	if(goal_state != AGS_STATE_GOAL_IN_PROGRESS)
		return FALSE
	goal_state = AGS_STATE_GOAL_COMPLETE
	addtimer(CALLBACK(src, PROC_REF(send_shuttle_to_centcom), user), COMPLETE_GOAL_SHUTTLE_SEND_DELAY SECONDS)
	return TRUE


/// When dock shuttle to dock (signal handler)
/datum/controller/subsystem/addition_goals/proc/on_shuttle_dock(datum/source, /obj/docking_port/mobile/shuttle, obj/docking_port/stationary/new_dock)
	SIGNAL_HANDLER
	if(goal_state == AGS_STATE_GOAL_PREPARE)
		goal_state = AGS_STATE_GOAL_IN_PROGRESS
		return
	if(goal_state != AGS_STATE_GOAL_COMPLETE)
		return
	if(new_dock.id != AGS_SHUTTLE_CENTCOM_DOCK)
		return
	if(!current_goal)
		goal_state = AGS_STATE_IDLE
		return
	current_goal.complete_goal(src)
	current_goal = null
	clear_shuttle_turfs()
	if(!length(available_goals))
		refresh_available_goals(force = TRUE)
	goal_state = AGS_STATE_IDLE


/datum/controller/subsystem/addition_goals/proc/add_reward(credits, cargopoints)
	if(credits > 0)
		var/datum/money_account/account = GLOB.station_account
		account.credit(round(credits), "Завершение дополнительной цели", "Дополнительная цель", account.owner_name)
	if(cargopoints > 0)
		SSshuttle.points += round(cargopoints)




////////////////////////////////////////
// MARK:	Console logic
////////////////////////////////////////

/datum/controller/subsystem/addition_goals/proc/print_accept_goal_details(mob/user, datum/addition_goal/goal)
	var/report = goal.format_accept_report(user)
	report += "<br><br><b>Награда при выполнении запроса:</b>"
	var/reward_number = 1
	if(goal.reward_credits > 0)
		report += "<br>[reward_number]. [goal.reward_credits] кредитов на счет станции."
		reward_number++
	if(goal.reward_cargopoints > 0)
		report += "<br>[reward_number]. [goal.reward_cargopoints] очков поставки в карго."
	var/addition = "Данный запрос считается действительным только при наличии печати Центрального Командоваия Нанотрейзен"
	var/report_message = create_paper_content(goal.name, report, addition)
	print_report_on_console(goal.name, report_message, stamp = TRUE)

/datum/controller/subsystem/addition_goals/proc/create_paper_content(title, message, ending = "")
	return "<div style='text-align:center;'><img src=ntlogo.png><h3>[title]</h3></div><hr>[message]<hr><small><i>[ending]</i></small>"

/// Print report paper on all Addition goal consoles
/datum/controller/subsystem/addition_goals/proc/print_report_on_console(title, message, stamp = FALSE)
	for(var/obj/machinery/computer/addition_goals/console as anything in console_list)
		if(console.stat & (BROKEN|NOPOWER))
			continue
		var/obj/item/paper/paper = new (console.loc)
		paper.name = "[title]"
		paper.info = message
		if(stamp)
			paper.stamp(/obj/item/stamp/centcom)




////////////////////////////////////////
// MARK:	Basic Addition Goal
////////////////////////////////////////

/datum/addition_goal
	/// Goal unique identifier (Same type goals can have difficult identifiers)
	var/id

	// Accept goal data
	var/name
	var/description
	var/request_number
	var/reward_credits = 0
	var/reward_cargopoints = 0
	var/accept_time = "???"


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

/datum/addition_goal/proc/complete_goal(datum/controller/subsystem/addition_goals/system)
	message_admins("addition goal '[name]' not implement complete_goal")
	return 0

/datum/addition_goal/proc/contains_in_shuttle(list/turf/shuttle_turfs, atom/movable/target)
	for(var/turf/turf in shuttle_turfs)
		//open all containers before check
		for(var/atom/movable/content in turf.contents)
			if(istype(content, /obj/structure/closet))
				var/obj/structure/closet/closet = content
				closet.open()
		//check turfs contains
		for(var/atom/movable/content in turf.contents)
			if(content == target)
				return TRUE
	return FALSE


GLOBAL_LIST_INIT(addition_goal_spawn_human_types, list(
	/mob/living/carbon/human,
	/mob/living/carbon/human/vulpkanin,
	/mob/living/carbon/human/tajaran,
	/mob/living/carbon/human/unathi,
	/mob/living/carbon/human/skrell,
	/mob/living/carbon/human/kidan,
	/mob/living/carbon/human/kidan
))

/obj/effect/mob_spawn/human/addition_goal
	roundstart = FALSE
	instant = FALSE
	random = TRUE
	uses = -1

/obj/effect/mob_spawn/human/addition_goal/create(mob/plr, flavour, name, prefs, _mob_name, _mob_gender, _mob_species)
	mob_type = pick(GLOB.addition_goal_spawn_human_types)
	. = ..()
