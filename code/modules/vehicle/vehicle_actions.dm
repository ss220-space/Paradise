//VEHICLE DEFAULT HANDLING

/**
 * ## generate_actions
 *
 * You override this with initialize_passenger_action_type and initialize_controller_action_type calls
 * To give passengers actions when they enter the vehicle.
 * Read the documentation on the aforementioned procs to learn the difference
 */
/obj/vehicle/proc/generate_actions()
	return

/**
 * ## generate_action_type
 *
 * A small proc to properly set up each action path.
 * args:
 * * actiontype: typepath of the action the proc sets up.
 * returns created and set up action instance
 */
/obj/vehicle/proc/generate_action_type(actiontype)
	var/datum/action/vehicle/A = new actiontype
	if(!istype(A))
		return
	A.vehicle_target = src
	return A

/**
 * ## initialize_passenger_action_type
 *
 * Gives any passenger that enters the mech this action.
 * They will lose it when they disembark.
 * args:
 * * actiontype: typepath of the action you want to give occupants.
 */
/obj/vehicle/proc/initialize_passenger_action_type(actiontype)
	autogrant_actions_passenger += actiontype
	for(var/i in occupants)
		grant_passenger_actions(i) //refresh

/**
 * ## destroy_passenger_action_type
 *
 * Removes this action type from all occupants and stops autogranting it
 * args:
 * * actiontype: typepath of the action you want to remove from occupants and the autogrant list.
 */
/obj/vehicle/proc/destroy_passenger_action_type(actiontype)
	autogrant_actions_passenger -= actiontype
	for(var/i in occupants)
		remove_action_type_from_mob(actiontype, i)

/**
 * ## initialize_controller_action_type
 *
 * Gives any passenger that enters the vehicle this action... IF they have the correct vehicle control flag.
 * This is used so passengers cannot press buttons only drivers should have, for example.
 * args:
 * * actiontype: typepath of the action you want to give occupants.
 */
/obj/vehicle/proc/initialize_controller_action_type(actiontype, control_flag)
	LAZYINITLIST(autogrant_actions_controller["[control_flag]"])
	autogrant_actions_controller["[control_flag]"] += actiontype
	for(var/i in occupants)
		grant_controller_actions(i) //refresh

/**
 * ## destroy_controller_action_type
 *
 * As the name implies, removes the actiontype from autogrant and removes it from all occupants
 * args:
 * * actiontype: typepath of the action you want to remove from occupants and autogrant.
 */
/obj/vehicle/proc/destroy_controller_action_type(actiontype, control_flag)
	autogrant_actions_controller["[control_flag]"] -= actiontype
	UNSETEMPTY(autogrant_actions_controller["[control_flag]"])
	for(var/i in occupants)
		remove_action_type_from_mob(actiontype, i)

/**
 * ## grant_action_type_to_mob
 *
 * As on the tin, it does all the annoying small stuff and sanity needed
 * to GRANT an action to a mob.
 * args:
 * * actiontype: typepath of the action you want to give to grant_to.
 * * grant_to: the mob we're giving actiontype to
 * returns TRUE if successfully granted
 */
/obj/vehicle/proc/grant_action_type_to_mob(actiontype, mob/grant_to)
	if(isnull(LAZYACCESS(occupants, grant_to)) || !actiontype)
		return FALSE
	LAZYINITLIST(occupant_actions[grant_to])
	if(occupant_actions[grant_to][actiontype])
		return TRUE
	var/datum/action/action = generate_action_type(actiontype)
	action.Grant(grant_to)
	occupant_actions[grant_to][action.type] = action
	return TRUE

/**
 * ## remove_action_type_from_mob
 *
 * As on the tin, it does all the annoying small stuff and sanity needed
 * to REMOVE an action to a mob.
 * args:
 * * actiontype: typepath of the action you want to give to grant_to.
 * * take_from: the mob we're taking actiontype to
 * returns TRUE if successfully removed
 */
/obj/vehicle/proc/remove_action_type_from_mob(actiontype, mob/take_from)
	if(isnull(LAZYACCESS(occupants, take_from)) || !actiontype)
		return FALSE
	LAZYINITLIST(occupant_actions[take_from])
	if(occupant_actions[take_from][actiontype])
		var/datum/action/action = occupant_actions[take_from][actiontype]
		// Actions don't dissipate on removal, they just sit around assuming they'll be reusued
		// Gotta qdel
		qdel(action)
		occupant_actions[take_from] -= actiontype
	return TRUE

/**
 * ## grant_passenger_actions
 *
 * Called on every passenger that enters the vehicle, goes through the list of actions it needs to give...
 * and does that.
 * args:
 * * grant_to: mob that needs to get every action the vehicle grants
 */
/obj/vehicle/proc/grant_passenger_actions(mob/grant_to)
	for(var/v in autogrant_actions_passenger)
		grant_action_type_to_mob(v, grant_to)

/**
 * ## remove_passenger_actions
 *
 * Called on every passenger that exits the vehicle, goes through the list of actions it needs to remove...
 * and does that.
 * args:
 * * take_from: mob that needs to get every action the vehicle grants
 */
/obj/vehicle/proc/remove_passenger_actions(mob/take_from)
	for(var/v in autogrant_actions_passenger)
		remove_action_type_from_mob(v, take_from)

/obj/vehicle/proc/grant_controller_actions(mob/M)
	if(!istype(M) || isnull(LAZYACCESS(occupants, M)))
		return FALSE
	for(var/i in GLOB.bitflags)
		if(occupants[M] & i)
			grant_controller_actions_by_flag(M, i)
	return TRUE

/obj/vehicle/proc/remove_controller_actions(mob/M)
	if(!istype(M) || isnull(LAZYACCESS(occupants, M)))
		return FALSE
	for(var/i in GLOB.bitflags)
		remove_controller_actions_by_flag(M, i)
	return TRUE

/obj/vehicle/proc/grant_controller_actions_by_flag(mob/M, flag)
	if(!istype(M))
		return FALSE
	for(var/v in autogrant_actions_controller["[flag]"])
		grant_action_type_to_mob(v, M)
	return TRUE

/obj/vehicle/proc/remove_controller_actions_by_flag(mob/M, flag)
	if(!istype(M))
		return FALSE
	for(var/v in autogrant_actions_controller["[flag]"])
		remove_action_type_from_mob(v, M)
	return TRUE

/obj/vehicle/proc/cleanup_actions_for_mob(mob/M)
	if(!istype(M))
		return FALSE
	for(var/path in occupant_actions[M])
		stack_trace("Leftover action type [path] in vehicle type [type] for mob type [M.type] - THIS SHOULD NOT BE HAPPENING!")
		var/datum/action/action = occupant_actions[M][path]
		action.Remove(M)
		occupant_actions[M] -= path
	occupant_actions -= M
	return TRUE

/***************** ACTION DATUMS *****************/

/datum/action/vehicle
	check_flags = AB_CHECK_HANDS_BLOCKED | AB_CHECK_IMMOBILE | AB_CHECK_CONSCIOUS
	button_icon = 'icons/mob/actions/actions_vehicle.dmi'
	button_icon_state = "vehicle_eject"
	var/obj/vehicle/vehicle_target

/datum/action/vehicle/Destroy()
	vehicle_target = null
	return ..()

/datum/action/vehicle/ridden
	var/obj/vehicle/ridden/vehicle_ridden_target


/datum/action/vehicle/ridden/ambulance/ambulance_alarm
	name = "Toggle Sirens"
	icon_icon = 'icons/obj/vehicles/vehicles.dmi'
	button_icon_state = "docwagon2"
	check_flags = AB_CHECK_HANDS_BLOCKED|AB_CHECK_CONSCIOUS|AB_CHECK_INCAPACITATED
	COOLDOWN_DECLARE(ability_cooldown)
	var/cooldown_time = 4 SECONDS

/datum/action/vehicle/ridden/ambulance/ambulance_alarm/Trigger(left_click = TRUE)
	if(!..())
		return FALSE

	var/obj/vehicle/ridden/ambulance/A = vehicle_ridden_target

	if(!istype(A) || !A.soundloop)
		return FALSE

	if(!COOLDOWN_FINISHED(src, ability_cooldown))
		return FALSE

	COOLDOWN_START(src, ability_cooldown, cooldown_time)

	if(A.soundloop.muted)
		A.soundloop.start()
		A.set_light_on(TRUE)
	else
		A.soundloop.stop()
		A.set_light_on(FALSE)

/datum/looping_sound/ambulance_alarm
	start_length = 0
	mid_sounds = list('sound/items/weeoo1.ogg' = 1)
	mid_length = 14
	volume = 100


/*

/datum/action/vehicle/sealed
	check_flags = AB_CHECK_IMMOBILE | AB_CHECK_CONSCIOUS
	var/obj/vehicle/sealed/vehicle_entered_target

/datum/action/vehicle/sealed/Destroy()
	vehicle_entered_target = null
	return ..()

/datum/action/vehicle/sealed/climb_out
	name = "Climb Out"
	desc = "Climb out of your vehicle!"
	button_icon_state = "car_eject"

/datum/action/vehicle/sealed/climb_out/Trigger(trigger_flags)
	if(..() && istype(vehicle_entered_target))
		vehicle_entered_target.mob_try_exit(owner, owner)

/datum/action/vehicle/sealed/remove_key
	name = "Remove key"
	desc = "Take your key out of the vehicle's ignition."
	button_icon_state = "car_removekey"

/datum/action/vehicle/sealed/remove_key/Trigger(trigger_flags)
	vehicle_entered_target.remove_key(owner)

*/
