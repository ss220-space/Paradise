/datum/pet_command/idle
	command_name = "Stop"
	speech_commands = list("sit", "stop", "stay")
	command_feedback = "stops"

/datum/pet_command/idle/execute_action(datum/ai_controller/controller)
	return SUBTREE_RETURN_FINISH_PLANNING

/datum/pet_command/free
	command_name = "Free"
	speech_commands = list("free", "go")
	command_feedback = "relaxes"

/datum/pet_command/free/execute_action(datum/ai_controller/controller)
	controller.clear_blackboard_key(BB_ACTIVE_PET_COMMAND)
	return

/datum/pet_command/follow
	command_name = "Follow"
	speech_commands = list("follow", "come")
	command_feedback = "follows"
	var/follow_behavior = /datum/ai_behavior/pet_follow_friend

/datum/pet_command/follow/set_command_active(mob/living/parent, mob/living/commander, radial_command = FALSE)
	. = ..()
	set_command_target(parent, commander)

/datum/pet_command/follow/execute_action(datum/ai_controller/controller)
	controller.queue_behavior(follow_behavior, BB_CURRENT_PET_TARGET)
	return SUBTREE_RETURN_FINISH_PLANNING

/datum/pet_command/attack
	command_name = "Attack"
	requires_pointing = TRUE
	speech_commands = list("attack", "kill")
	command_feedback = "growls"
	pointed_reaction = "focuses"
	var/refuse_reaction = "refuses"
	var/attack_behaviour = /datum/ai_behavior/basic_melee_attack

/datum/pet_command/attack/set_command_target(mob/living/parent, atom/target)
	if(!target || !parent.ai_controller)
		return FALSE
	var/targeting_strategy = parent.ai_controller.blackboard[targeting_strategy_key]
	var/datum/targetting_datum/targeter = ispath(targeting_strategy) ? new targeting_strategy() : targeting_strategy
	if(targeter && !targeter.can_attack(parent, target))
		parent.balloon_alert_to_viewers("[refuse_reaction]")
		return FALSE
	return ..()

/datum/pet_command/attack/execute_action(datum/ai_controller/controller)
	if(!controller.blackboard[BB_CURRENT_PET_TARGET])
		return SUBTREE_RETURN_FINISH_PLANNING
	controller.queue_behavior(attack_behaviour, BB_CURRENT_PET_TARGET, targeting_strategy_key, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION)
	return SUBTREE_RETURN_FINISH_PLANNING
