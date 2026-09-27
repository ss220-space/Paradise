/**
 * # Pet Command: Idle
 * Tells a pet to resume its idle behaviour, usually staying put where you leave it
 */
/datum/pet_command/idle
	command_name = "Stop"
	command_desc = "Прикажите питомцу оставаться на этом месте."
	radial_icon_state = "halt"
	speech_commands = list("сидеть", "стоять", "жди", "стой")
	command_feedback = "останавливается"

/datum/pet_command/idle/execute_action(datum/ai_controller/controller)
	return SUBTREE_RETURN_FINISH_PLANNING

/datum/pet_command/idle/retrieve_command_text(atom/living_pet, atom/target)
	return "приказывает [living_pet] оставаться на месте!"

/**
 * # Pet Command: Stop
 * Tells a pet to exit command mode and resume its normal behaviour, which includes regular target-seeking and what have you
 */
/datum/pet_command/free
	command_name = "Free"
	command_desc = "Позвольте питомцу вести себя как обычно."
	radial_icon_state = "free"
	speech_commands = list("гуляй", "вольно", "свободен")
	command_feedback = "расслабляется"

/datum/pet_command/free/execute_action(datum/ai_controller/controller)
	controller.clear_blackboard_key(BB_ACTIVE_PET_COMMAND)
	return

/datum/pet_command/free/retrieve_command_text(atom/living_pet, atom/target)
	return "отпускает [living_pet] гулять!"

/**
 * # Pet Command: Follow
 * Tells a pet to follow you until you tell it to do something else
 */
/datum/pet_command/follow
	command_name = "Follow"
	command_desc = "Прикажите питомцу сопровождать вас."
	radial_icon_state = "follow"
	speech_commands = list("за мной", "рядом", "ко мне")
	command_feedback = "следует"
	var/follow_behavior = /datum/ai_behavior/pet_follow_friend

/datum/pet_command/follow/set_command_active(mob/living/parent, mob/living/commander, radial_command = FALSE)
	. = ..()
	set_command_target(parent, commander)

/datum/pet_command/follow/execute_action(datum/ai_controller/controller)
	controller.queue_behavior(follow_behavior, BB_CURRENT_PET_TARGET)
	return SUBTREE_RETURN_FINISH_PLANNING

/datum/pet_command/follow/retrieve_command_text(atom/living_pet, atom/target)
	return "приказывает [living_pet] следовать за собой!"

/**
 * # Pet Command: Attack
 * Tells a pet to chase and bite the next thing you point at
 */
/datum/pet_command/attack
	command_name = "Attack"
	command_desc = "Прикажите питомцу атаковать цель, на которую вы укажете."
	radial_icon_state = "attack"
	requires_pointing = TRUE
	speech_commands = list("атакуй", "убей")
	command_feedback = "рычит"
	pointed_reaction = "рычит!"
	/// Balloon alert to display if providing an invalid target
	var/refuse_reaction = "отказывается"
	/// Attack behaviour to use
	var/attack_behaviour = /datum/ai_behavior/basic_melee_attack

// Refuse to target things we can't target, chiefly other friends
/datum/pet_command/attack/set_command_target(mob/living/parent, atom/target)
	if(!target || !parent.ai_controller)
		return FALSE
	var/targeting_strategy = parent.ai_controller.blackboard[targeting_strategy_key]
	var/datum/targetting_datum/targeter = ispath(targeting_strategy) ? new targeting_strategy() : targeting_strategy
	if(targeter && !targeter.can_attack(parent, target))
		parent.balloon_alert_to_viewers("[refuse_reaction]")
		return FALSE
	return ..()

/datum/pet_command/attack/retrieve_command_text(atom/living_pet, atom/target)
	return isnull(target) ? null : "приказывает [living_pet] атаковать [target]!"

/datum/pet_command/attack/execute_action(datum/ai_controller/controller)
	if(!controller.blackboard[BB_CURRENT_PET_TARGET])
		return SUBTREE_RETURN_FINISH_PLANNING
	controller.queue_behavior(attack_behaviour, BB_CURRENT_PET_TARGET, targeting_strategy_key, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION)
	return SUBTREE_RETURN_FINISH_PLANNING
