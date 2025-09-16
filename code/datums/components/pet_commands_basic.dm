// None of these are really complex enough to merit their own file

/**
 * # Pet Command: Idle
 * Tells a pet to resume its idle behaviour, usually staying put where you leave it
 */
/datum/pet_command/idle
	command_name = "Стоп"
	command_desc = "Прикажите своему питомцу прекратить двигаться."
	radial_icon_state = "halt"
	speech_commands = list("сидеть", "стой", "стоп", "фу")
	command_feedback = "sits"


/datum/pet_command/idle/execute_action(datum/ai_controller/controller)
	return SUBTREE_RETURN_FINISH_PLANNING // This cancels further AI planning


/datum/pet_command/idle/retrieve_command_text(atom/living_pet, atom/target)
	return "приказывает [living_pet.declent_ru(DATIVE)] стоять на месте!"


/**
 * # Pet Command: Stop
 * Tells a pet to exit command mode and resume its normal behaviour, which includes regular target-seeking and what have you
 */
/datum/pet_command/free
	command_name = "Свободен"
	command_desc = "Позвольте вашему питомцу вернуться к своему естественному поведению."
	radial_icon_state = "free"
	speech_commands = list("свободен", "свободна", "свободно", "гуляй", "гулять")
	command_feedback = "relaxes"


/datum/pet_command/free/execute_action(datum/ai_controller/controller)
	controller.clear_blackboard_key(BB_ACTIVE_PET_COMMAND)
	return // Just move on to the next planning subtree.


/datum/pet_command/free/retrieve_command_text(atom/living_pet, atom/target)
	return "говорит [living_pet.declent_ru(DATIVE)] что он может делать что хочет!"


/**
 * # Pet Command: Follow
 * Tells a pet to follow you until you tell it to do something else
 */
/datum/pet_command/follow
	command_name = "Следуй"
	command_desc = "Прикажите вашему питомцу следовать за вами."
	radial_icon_state = "follow"
	speech_commands = list("к ноге", "ко мне", "следуй", "следовать", "к ноге")
	//callout_type = /datum/callout_option/move
	///the behavior we use to follow
	var/follow_behavior = /datum/ai_behavior/pet_follow_friend
	///should we activate immediately if we're doing nothing else and gain a friend?
	var/activate_on_befriend = FALSE


/datum/pet_command/follow/set_command_active(mob/living/parent, mob/living/commander)
	. = ..()
	set_command_target(parent, commander)


/datum/pet_command/follow/retrieve_command_text(atom/living_pet, atom/target)
	return "приказывает [living_pet.declent_ru(DATIVE)] следовать за хозяином!"


/datum/pet_command/follow/execute_action(datum/ai_controller/controller)
	controller.queue_behavior(follow_behavior, BB_CURRENT_PET_TARGET)
	return SUBTREE_RETURN_FINISH_PLANNING


/datum/pet_command/follow/add_new_friend(mob/living/tamer)
	. = ..()
	var/mob/living/parent = weak_parent.resolve()
	if(!parent)
		return

	if(!activate_on_befriend || parent.ai_controller.blackboard_key_exists(BB_ACTIVE_PET_COMMAND))
		return

	try_activate_command(tamer)


/// Like follow but start active
/datum/pet_command/follow/start_active
	activate_on_befriend = TRUE


/**
 * # Pet Command: Play Dead
 * Pretend to be dead for a random period of time
 */
/datum/pet_command/play_dead
	command_name = "Притворись мертвым"
	command_desc = "Сыграйте жуткую шутку."
	radial_icon_state = "play_dead"
	speech_commands = list("притворись мертвым", "прикинься мертвым") // Don't get too creative here, people talk about dying pretty often


/datum/pet_command/play_dead/execute_action(datum/ai_controller/controller)
	controller.queue_behavior(/datum/ai_behavior/play_dead)
	return SUBTREE_RETURN_FINISH_PLANNING


/datum/pet_command/play_dead/retrieve_command_text(atom/living_pet, atom/target)
	return "приказывает [living_pet.declent_ru(DATIVE)] притвориться мертвым!"


/**
 * # Pet Command: Good Boy
 * React if complimented
 */
/datum/pet_command/good_boy
	command_name = "Хороший хальчик"
	command_desc = "Похвалите своего питомца."
	hidden = TRUE
	speech_commands = list("молодец")


/datum/pet_command/good_boy/New(mob/living/parent)
	. = ..()
	switch(parent.gender)
		if(MALE)
			speech_commands += "хороший мальчик"
			return

		if(FEMALE)
			speech_commands += "хорошая девочка"
			return

	// If we get past this point someone has finally added a non-binary dog


/datum/pet_command/good_boy/execute_action(datum/ai_controller/controller)
	controller.clear_blackboard_key(BB_ACTIVE_PET_COMMAND)
	var/mob/living/parent = weak_parent.resolve()
	if(!parent)
		return SUBTREE_RETURN_FINISH_PLANNING

	new /obj/effect/temp_visual/heart(parent.loc)
	parent.emote("spin")
	return SUBTREE_RETURN_FINISH_PLANNING


/*
/**
 * # Pet Command: Use ability
 * Use an an ability that does not require any targets
 */
/datum/pet_command/untargeted_ability
	///untargeted ability we will use
	var/ability_key

/datum/pet_command/untargeted_ability/execute_action(datum/ai_controller/controller)
	var/obj/effect/proc_holder/spell/ability = controller.blackboard[ability_key]
	if(!ability?.IsAvailable())
		return

	controller.queue_behavior(/datum/ai_behavior/use_mob_ability, ability_key)
	controller.clear_blackboard_key(BB_ACTIVE_PET_COMMAND)
	return SUBTREE_RETURN_FINISH_PLANNING

/datum/pet_command/untargeted_ability/retrieve_command_text(atom/living_pet, atom/target)
	return "приказывает [living_pet.declent_ru(DATIVE)] использовать свою способность!"
*/

/**
 * # Pet Command: Attack
 * Tells a pet to chase and bite the next thing you point at
 */
/datum/pet_command/attack
	command_name = "Атакуй"
	command_desc = "Прикажите своему питомцу атаковать то, на что вы ему укажете."
	radial_icon_state = "attack"
	requires_pointing = TRUE
	//callout_type = /datum/callout_option/attack
	speech_commands = list("атакуй", "фас", "убей", "убить", "кусай", "куси", "укуси", "хватай")
	command_feedback = "рычит"
	pointed_reaction = "и воет"
	/// Balloon alert to display if providing an invalid target
	var/refuse_reaction = "качает головой"
	/// Attack behaviour to use
	var/attack_behaviour = /datum/ai_behavior/basic_melee_attack


// Refuse to target things we can't target, chiefly other friends
/datum/pet_command/attack/set_command_target(mob/living/parent, atom/target)
	if(!target)
		return FALSE

	var/mob/living/living_parent = parent
	if(!living_parent.ai_controller)
		return FALSE

	var/datum/targetting_datum/targeter = GET_TARGETING_STRATEGY(living_parent.ai_controller.blackboard[targeting_strategy_key])
	if(!targeter)
		return FALSE

	if(!targeter.can_attack(living_parent, target))
		refuse_target(parent, target)
		return FALSE

	return ..()


/datum/pet_command/attack/retrieve_command_text(atom/living_pet, atom/target)
	return isnull(target) ? null : "приказывает [living_pet.declent_ru(DATIVE)] атаковать [target.declent_ru(ACCUSATIVE)]!"


/// Display feedback about not targeting something
/datum/pet_command/attack/proc/refuse_target(mob/living/parent, atom/target)
	var/mob/living/living_parent = parent
	living_parent.balloon_alert_to_viewers("[refuse_reaction]")
	living_parent.visible_message(span_notice("[living_parent.declent_ru(NOMINATIVE)] отказывается атаковать [target.declent_ru(ACCUSATIVE)]."))


/datum/pet_command/attack/execute_action(datum/ai_controller/controller)
	controller.queue_behavior(attack_behaviour, BB_CURRENT_PET_TARGET, targeting_strategy_key)
	return SUBTREE_RETURN_FINISH_PLANNING


/**
 * # Pet Command: Targetted Ability
 * Tells a pet to use some kind of ability on the next thing you point at
 */
/datum/pet_command/use_ability
	command_name = "Используй способность"
	command_desc = "Прикажите своему питомцу использовать один из его особых навыков на том, на что вы ему укажете."
	radial_icon = 'icons/mob/actions/actions_spells.dmi'
	radial_icon_state = "projectile"
	requires_pointing = TRUE
	speech_commands = list("стреляй", "стрельни", "шмаляй", "шмальни", "скастуй", "скастони", "кастуй", "кастони")
	command_feedback = "рычит"
	pointed_reaction = "и воет"
	/// Blackboard key where a reference to some kind of mob ability is stored
	var/pet_ability_key
	/// The AI behavior to use for the ability
	var/ability_behavior = /datum/ai_behavior/pet_use_ability


/datum/pet_command/use_ability/execute_action(datum/ai_controller/controller)
	if(!pet_ability_key)
		return

	var/obj/effect/proc_holder/spell/using_action = controller.blackboard[pet_ability_key]
	if(QDELETED(using_action))
		return

	// We don't check if the target exists because we want to 'sit attentively' if we've been instructed to attack but not given one yet
	// We also don't check if the cooldown is over because there's no way a pet owner can know that, the behaviour will handle it
	controller.queue_behavior(ability_behavior, pet_ability_key, BB_CURRENT_PET_TARGET)
	return SUBTREE_RETURN_FINISH_PLANNING


/datum/pet_command/use_ability/retrieve_command_text(atom/living_pet, atom/target)
	return isnull(target) ? null : "приказывает [living_pet.declent_ru(DATIVE)] использовать свою способность на [target.declent_ru(DATIVE)]!"


/datum/pet_command/protect_owner
	command_name = "Охраняй хозяина"
	command_desc = "Ваш питомец прибежит к вам на помощь."
	hidden = TRUE
	//callout_type = /datum/callout_option/guard
	///the range our owner needs to be in for us to protect him
	var/protect_range = 9
	///the behavior we will use when he is attacked
	var/protect_behavior = /datum/ai_behavior/basic_melee_attack
	///message cooldown to prevent too many people from telling you not to commit suicide
	COOLDOWN_DECLARE(self_harm_message_cooldown)


/datum/pet_command/protect_owner/add_new_friend(mob/living/tamer)
	RegisterSignal(tamer, COMSIG_ATOM_WAS_ATTACKED, PROC_REF(set_attacking_target))
	if(HAS_TRAIT(tamer, TRAIT_RELAYING_ATTACKER))
		return

	tamer.AddElement(/datum/element/relay_attackers)


/datum/pet_command/protect_owner/remove_friend(mob/living/unfriended)
	UnregisterSignal(unfriended, COMSIG_ATOM_WAS_ATTACKED)


/datum/pet_command/protect_owner/execute_action(datum/ai_controller/controller)
	var/mob/living/victim = controller.blackboard[BB_CURRENT_PET_TARGET]
	if(QDELETED(victim))
		return
	// cancel the action if they're below our given crit stat, OR if we're trying to attack ourselves (this can happen on tamed mobs w/ protect subtree rarely)
	if(victim.stat > controller.blackboard[BB_TARGET_MINIMUM_STAT] || victim == controller.pawn)
		controller.clear_blackboard_key(BB_ACTIVE_PET_COMMAND)
		return

	controller.queue_behavior(protect_behavior, BB_CURRENT_PET_TARGET, BB_PET_TARGETING_STRATEGY)
	return SUBTREE_RETURN_FINISH_PLANNING


/datum/pet_command/protect_owner/set_command_active(mob/living/parent, mob/living/victim)
	. = ..()
	set_command_target(parent, victim)


/datum/pet_command/protect_owner/proc/set_attacking_target(atom/source, mob/living/attacker)
	SIGNAL_HANDLER

	var/mob/living/simple_animal/owner = weak_parent.resolve()
	if(isnull(owner))
		return

	if(source == attacker)
		var/list/interventions = owner.ai_controller?.blackboard[BB_OWNER_SELF_HARM_RESPONSES] || list()
		if(!(length(interventions) && COOLDOWN_FINISHED(src, self_harm_message_cooldown) && prob(30)))
			return

		COOLDOWN_START(src, self_harm_message_cooldown, 5 SECONDS)
		var/chosen_statement = pick(interventions)
		INVOKE_ASYNC(owner, TYPE_PROC_REF(/mob, say), chosen_statement)
		return

	var/mob/living/current_target = owner.ai_controller?.blackboard[BB_CURRENT_PET_TARGET]
	if(attacker == current_target) //we are already dealing with this target
		return

	if(!isliving(attacker) || !can_see(owner, attacker, protect_range))
		return

	set_command_active(owner, attacker)


/datum/pet_command/move
	command_name = "Иди"
	command_desc = "Прикажите вашему питомцу идти куда-то!"
	requires_pointing = TRUE
	radial_icon_state = "move"
	speech_commands = list("иди", "идти")
	///the behavior we use to walk towards targets
	var/datum/ai_behavior/walk_behavior = /datum/ai_behavior/travel_towards


/datum/pet_command/move/set_command_target(mob/living/parent, atom/target)
	if(isnull(target) || !can_see(parent, target, 9))
		return FALSE

	return ..()


/datum/pet_command/move/execute_action(datum/ai_controller/controller)
	if(controller.blackboard_key_exists(BB_CURRENT_PET_TARGET))
		controller.queue_behavior(walk_behavior, BB_CURRENT_PET_TARGET)

	return SUBTREE_RETURN_FINISH_PLANNING


/datum/pet_command/move/retrieve_command_text(atom/living_pet, atom/target)
	return "приказывает [living_pet.declent_ru(DATIVE)] идти!"
