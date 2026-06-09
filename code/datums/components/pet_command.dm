/**
 * Minimal pet command datum used by the heretic star gazer port.
 * The full selfharm radial-command UI depends on assets and AI helpers absent in master220.
 */
/datum/pet_command
	var/datum/weakref/weak_parent
	var/command_name = "Command"
	var/command_desc
	var/hidden = FALSE
	var/list/speech_commands = list()
	var/command_feedback
	var/sense_radius = 7
	var/requires_pointing = FALSE
	var/targeting_strategy_key = BB_PET_TARGETING_STRATEGY
	var/pointed_reaction

/datum/pet_command/New(mob/living/parent)
	. = ..()
	weak_parent = WEAKREF(parent)

/datum/pet_command/proc/add_new_friend(mob/living/tamer)
	RegisterSignal(tamer, COMSIG_MOB_SAY, PROC_REF(respond_to_command))
	if(requires_pointing)
		RegisterSignal(tamer, COMSIG_MOB_POINTED, PROC_REF(point_on_target))

/datum/pet_command/proc/remove_friend(mob/living/unfriended)
	UnregisterSignal(unfriended, list(COMSIG_MOB_SAY, COMSIG_MOB_POINTED))

/datum/pet_command/proc/respond_to_command(mob/living/speaker, speech_args)
	SIGNAL_HANDLER
	var/mob/living/parent = weak_parent?.resolve()
	if(!parent || !parent.ai_controller || !can_see(parent, speaker, sense_radius))
		return
	var/spoken_text = speech_args[SPEECH_MESSAGE]
	if(!find_command_in_text(spoken_text))
		return
	try_activate_command(speaker, FALSE)

/datum/pet_command/proc/find_command_in_text(spoken_text, check_verbosity = FALSE)
	for(var/command as anything in speech_commands)
		if(findtext(spoken_text, command))
			return TRUE
	return FALSE

/datum/pet_command/proc/pet_able_to_respond()
	var/mob/living/parent = weak_parent?.resolve()
	return parent?.ai_controller && !IS_DEAD_OR_INCAP(parent)

/datum/pet_command/proc/try_activate_command(mob/living/commander, radial_command = FALSE)
	if(!pet_able_to_respond())
		return FALSE
	var/mob/living/parent = weak_parent.resolve()
	set_command_active(parent, commander, radial_command)
	return TRUE

/datum/pet_command/proc/set_command_active(mob/living/parent, mob/living/commander, radial_command = FALSE)
	parent.ai_controller.clear_blackboard_key(BB_CURRENT_PET_TARGET)
	parent.ai_controller.CancelActions()
	parent.ai_controller.set_blackboard_key(BB_ACTIVE_PET_COMMAND, src)
	if(command_feedback)
		parent.balloon_alert_to_viewers("[command_feedback]")

/datum/pet_command/proc/set_command_target(mob/living/parent, atom/target)
	parent.ai_controller.set_blackboard_key(BB_CURRENT_PET_TARGET, target)
	return TRUE

/datum/pet_command/proc/on_target_set(mob/living/friend, atom/potential_target)
	var/mob/living/parent = weak_parent?.resolve()
	if(!parent?.ai_controller || !potential_target || !can_see(parent, potential_target, sense_radius))
		return FALSE
	parent.ai_controller.CancelActions()
	return set_command_target(parent, potential_target)

/datum/pet_command/proc/point_on_target(mob/living/friend, atom/potential_target)
	SIGNAL_HANDLER
	on_target_set(friend, potential_target)

/datum/pet_command/proc/provide_radial_data()
	return

/datum/pet_command/proc/execute_action(datum/ai_controller/controller)
	return
