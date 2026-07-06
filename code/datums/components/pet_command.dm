/**
 * # Pet Command
 * Set some AI blackboard commands in response to receiving instructions.
 * This is abstract and should be extended for actual behaviour.
 * Ported from tg (minus the callout/automute hooks master220 lacks).
 */
/datum/pet_command
	/// Weak reference to who follows this command
	var/datum/weakref/weak_parent
	/// Unique name used for radial selection, should not be shared with other commands on one mob
	var/command_name = "Command"
	/// Description to display in radial menu
	var/command_desc
	/// If true, command will not appear in radial menu and can only be accessed through speech
	var/hidden = FALSE
	/// Icon to display in radial menu
	var/icon/radial_icon = 'icons/hud/radial_pets.dmi'
	/// Icon state to display in radial menu
	var/radial_icon_state
	/// Speech strings to listen out for
	var/list/speech_commands = list()
	/// Shown above the mob's head when it hears you
	var/command_feedback
	/// How close a mob needs to be to a target to respond to a command
	var/sense_radius = 7
	/// does this pet command need a point to activate?
	var/requires_pointing = FALSE
	/// Blackboard key for targeting strategy, this is likely going to need it
	var/targeting_strategy_key = BB_PET_TARGETING_STRATEGY
	///our pointed reaction we play
	var/pointed_reaction

/datum/pet_command/New(mob/living/parent)
	. = ..()
	weak_parent = WEAKREF(parent)

/// Register a new guy we want to listen to
/datum/pet_command/proc/add_new_friend(mob/living/tamer)
	RegisterSignal(tamer, COMSIG_MOB_SAY, PROC_REF(respond_to_command))
	if(requires_pointing)
		RegisterSignal(tamer, COMSIG_MOB_POINTED, PROC_REF(point_on_target))

/// Stop listening to a guy
/datum/pet_command/proc/remove_friend(mob/living/unfriended)
	UnregisterSignal(unfriended, list(COMSIG_MOB_SAY, COMSIG_MOB_POINTED, COMSIG_MOB_CLICKON))

/// Respond to something that one of our friends has asked us to do
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
	for(var/command in speech_commands)
		if(findtext(spoken_text, command))
			return TRUE
	return FALSE

/datum/pet_command/proc/pet_able_to_respond()
	var/mob/living/parent = weak_parent?.resolve()
	return parent?.ai_controller && !IS_DEAD_OR_INCAP(parent)

/// Apply a command state if conditions are right, return command if successful
/datum/pet_command/proc/try_activate_command(mob/living/commander, radial_command = FALSE)
	if(!pet_able_to_respond())
		return FALSE
	var/mob/living/parent = weak_parent.resolve()
	set_command_active(parent, commander, radial_command)
	return TRUE

/datum/pet_command/proc/generate_emote_command(atom/target)
	var/mob/living/living_pet = weak_parent?.resolve()
	return isnull(living_pet) ? null : retrieve_command_text(living_pet, target)

/datum/pet_command/proc/retrieve_command_text(atom/living_pet, atom/target)
	return "приказывает [living_pet] действовать!"

/// Activate the command, extend to add visible messages and the like
/datum/pet_command/proc/set_command_active(mob/living/parent, mob/living/commander, radial_command = FALSE)
	parent.ai_controller.clear_blackboard_key(BB_CURRENT_PET_TARGET)
	parent.ai_controller.CancelActions()
	parent.ai_controller.set_blackboard_key(BB_ACTIVE_PET_COMMAND, src)
	if(command_feedback)
		parent.balloon_alert_to_viewers("[command_feedback]")
	if(!radial_command)
		return
	// tg parity: picking a pointing command from the radial arms your next click as the point,
	// with a paw cursor; non-pointing commands emote instead.
	if(!requires_pointing)
		var/manual_emote_text = generate_emote_command()
		if(manual_emote_text)
			commander.manual_emote(manual_emote_text)
		return
	RegisterSignal(commander, COMSIG_MOB_CLICKON, PROC_REF(click_on_target))
	commander.client?.mouse_override_icon = 'icons/effects/mouse_pointers/pet_paw.dmi'
	commander.update_mouse_pointer()

/datum/pet_command/proc/click_on_target(mob/living/source, atom/target, list/modifiers)
	SIGNAL_HANDLER
	if(!can_see(source, target, 9))
		return COMSIG_MOB_CANCEL_CLICKON
	var/manual_emote_text = generate_emote_command(target)
	if(on_target_set(source, target) && !isnull(manual_emote_text))
		INVOKE_ASYNC(source, TYPE_PROC_REF(/mob, manual_emote), manual_emote_text)
	UnregisterSignal(source, COMSIG_MOB_CLICKON)
	if(source.client)
		source.client.mouse_override_icon = null
	source.update_mouse_pointer()
	return COMSIG_MOB_CANCEL_CLICKON

/// Store the target for the AI blackboard
/datum/pet_command/proc/set_command_target(mob/living/parent, atom/target)
	parent.ai_controller.set_blackboard_key(BB_CURRENT_PET_TARGET, target)
	return TRUE

/// Target the pointed atom for actions
/datum/pet_command/proc/on_target_set(mob/living/friend, atom/potential_target)
	var/mob/living/parent = weak_parent?.resolve()
	if(!parent?.ai_controller || !potential_target || !can_see(parent, potential_target, sense_radius))
		return FALSE
	parent.ai_controller.CancelActions()
	if(!set_command_target(parent, potential_target))
		return FALSE
	if(pointed_reaction)
		parent.visible_message(span_warning("[parent] следит за жестом [friend] в сторону [potential_target] и [pointed_reaction]"))
	return TRUE

/datum/pet_command/proc/point_on_target(mob/living/friend, atom/potential_target)
	SIGNAL_HANDLER
	on_target_set(friend, potential_target)

/// Provide information about how to display this command in a radial menu
/datum/pet_command/proc/provide_radial_data()
	if(hidden)
		return
	var/datum/radial_menu_choice/choice = new()
	choice.name = command_name
	choice.image = icon(icon = radial_icon, icon_state = radial_icon_state)
	choice.info = command_desc
	return list("[command_name]" = choice)

/**
 * Execute an AI action on the provided controller, what we should actually do when this command is active.
 * This should basically always be called from a planning subtree which passes its own controller.
 * Return SUBTREE_RETURN_FINISH_PLANNING to pass that instruction on to the controller, or don't if you don't want that.
 */
/datum/pet_command/proc/execute_action(datum/ai_controller/controller)
	return
