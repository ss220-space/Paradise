
/**
 * Deadchat Plays Things - The Componenting
 *
 * Allows deadchat to control stuff and things by typing commands into chat.
 * These commands will then trigger callbacks to execute procs!
 */
/datum/component/deadchat_control
	dupe_mode = COMPONENT_DUPE_UNIQUE

	/// The id for the DEADCHAT_DEMOCRACY_MODE looping vote timer.
	var/timerid
	/// Assoc list of key-chat command string, value-callback pairs. list("right" = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(_step), src, EAST))
	var/list/datum/callback/inputs = list()
	/// Assoc list of ckey:value pairings. In DEADCHAT_DEMOCRACY_MODE, value is the player's vote. In DEADCHAT_ANARCHY_MODE, value is world.time when their cooldown expires.
	var/list/ckey_to_cooldown = list()
	/// List of everything orbitting this component's parent.
	var/orbiters = list()
	/// A bitfield containing the mode which this component uses (DEADCHAT_DEMOCRACY_MODE or DEADCHAT_ANARCHY_MODE) and other settings)
	var/deadchat_mode = DEADCHAT_DEMOCRACY_MODE
	/// In DEADCHAT_DEMOCRACY_MODE, this is how long players have to vote on an input. In DEADCHAT_ANARCHY_MODE, this is how long between inputs for each unique player.
	var/input_cooldown
	///Set to true if a point of interest was created for an object, and needs to be removed if deadchat control is removed. Needed for preventing objects from having two points of interest.
	var/generated_point_of_interest = FALSE
	/// Callback invoked when this component is Destroy()ed to allow the parent to return to a non-deadchat controlled state.
	var/datum/callback/on_removal

/datum/component/deadchat_control/Initialize(_deadchat_mode, _inputs, _input_cooldown = 12 SECONDS, _on_removal)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_ATOM_ORBIT_BEGIN, PROC_REF(orbit_begin))
	RegisterSignal(parent, COMSIG_ATOM_ORBIT_STOP, PROC_REF(orbit_stop))
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))
	deadchat_mode = _deadchat_mode
	inputs = _inputs
	input_cooldown = _input_cooldown
	on_removal = _on_removal
	if(deadchat_mode & DEADCHAT_DEMOCRACY_MODE)
		if(deadchat_mode & DEADCHAT_ANARCHY_MODE) // Choose one, please.
			stack_trace("deadchat_control component added to [parent.type] with both democracy and anarchy modes enabled.")
		timerid = addtimer(CALLBACK(src, PROC_REF(democracy_loop)), input_cooldown, TIMER_STOPPABLE | TIMER_LOOP)

	var/list/input_names = list()
	for(var/item in inputs)
		input_names |= item
	var/atom/atom_parent = parent
	notify_ghosts("[capitalize(atom_parent.declent_ru(NOMINATIVE))] теперь может контролироваться призраками из чата! Возможные команды: [english_list(input_names)]", source = parent, action = NOTIFY_FOLLOW, title="Контроль дедчата!")
	if(!ismob(parent) && !(parent in GLOB.poi_list))
		GLOB.poi_list |= parent
		generated_point_of_interest = TRUE
	message_admins("[parent] has been given deadchat control in [deadchat_mode == DEADCHAT_ANARCHY_MODE ? "anarchy" : "democracy"] mode with a cooldown of [input_cooldown] second\s.")

	var/atom/A = parent
	for(var/mob/dead/observer/ghost in A.orbiters)
		// get started with anyone who's already following
		orbit_begin(A, ghost)

/datum/component/deadchat_control/Destroy(force, silent)
	var/atom/atom_parent = parent
	var/message = "<span class='deadsay italics bold'>[capitalize(atom_parent.declent_ru(NOMINATIVE))] теперь не контролируется призраками.</span>"
	for(var/mob/dead/observer/M in orbiters)
		to_chat(M, message)
	on_removal?.Invoke()
	inputs = null
	orbiters = null
	ckey_to_cooldown = null
	if(generated_point_of_interest)
		GLOB.poi_list -= parent
	return ..()

/datum/component/deadchat_control/proc/deadchat_react(mob/source, message)
	SIGNAL_HANDLER  // COMSIG_MOB_DEADSAY

	message = lowertext(message)

	if(!inputs[message])
		return

	if(deadchat_mode & DEADCHAT_ANARCHY_MODE)
		if(!source || !source.ckey)
			return
		var/cooldown = ckey_to_cooldown[source.ckey] - world.time
		if(cooldown > 0)
			var/ceil_cooldown = CEILING(cooldown * 0.1, 1)
			to_chat(source, span_warning("Управление командами будет доступно через [ceil_cooldown] секунд[declension_ru(ceil_cooldown,"у", "ы", "")]."))
			return MOB_DEADSAY_SIGNAL_INTERCEPT
		ckey_to_cooldown[source.ckey] = world.time + input_cooldown
		addtimer(CALLBACK(src, PROC_REF(end_cooldown), source.ckey), input_cooldown)
		inputs[message].Invoke()
		var/input_cooldown_s = input_cooldown * 0.1
		to_chat(source, span_notice("Команда \"[message]\" принята. Следующий ввод будет доступен через [input_cooldown_s] секунд[declension_ru(input_cooldown_s,"у", "ы", "")]."))
		return MOB_DEADSAY_SIGNAL_INTERCEPT

	if(deadchat_mode & DEADCHAT_DEMOCRACY_MODE)
		ckey_to_cooldown[source.ckey] = message
		to_chat(source, span_notice("Вы проголосовали за команду \"[message]\"."))
		return MOB_DEADSAY_SIGNAL_INTERCEPT

/datum/component/deadchat_control/proc/democracy_loop()
	var/atom/atom_parent = parent
	if(QDELETED(parent) || !(deadchat_mode & DEADCHAT_DEMOCRACY_MODE))
		deltimer(timerid)
		return
	var/result = count_democracy_votes()
	if(!isnull(result))
		inputs[result].Invoke()
		if(!(deadchat_mode & MUTE_DEADCHAT_DEMOCRACY_MESSAGES))
			var/input_cooldown_s = input_cooldown * 0.1
			var/message = "<span class='deadsay italics bold'>[capitalize(atom_parent.declent_ru(NOMINATIVE))] выполнил команду [result]!<br>Новое голосование начато. Оно закончится через [input_cooldown_s] секунд[declension_ru(input_cooldown_s,"у", "ы", "")].</span>"
			for(var/mob/dead/observer/M in orbiters)
				to_chat(M, message)
	else if(!(deadchat_mode & MUTE_DEADCHAT_DEMOCRACY_MESSAGES))
		var/message = "<span class='deadsay italics bold'>В этом цикле не было голосов.</span>"
		for(var/mob/dead/observer/M in orbiters)
			to_chat(M, message)

/datum/component/deadchat_control/proc/count_democracy_votes()
	if(!length(ckey_to_cooldown))
		return
	var/list/votes = list()
	for(var/command in inputs)
		votes["[command]"] = 0
	for(var/vote in ckey_to_cooldown)
		votes[ckey_to_cooldown[vote]]++
		ckey_to_cooldown.Remove(vote)

	// Solve which had most votes.
	var/prev_value = 0
	var/result
	for(var/vote in votes)
		if(votes[vote] > prev_value)
			prev_value = votes[vote]
			result = vote

	if(result in inputs)
		return result

/datum/component/deadchat_control/vv_edit_var(var_name, var_value)
	. = ..()
	if(!.)
		return
	if(var_name != NAMEOF(src, deadchat_mode))
		return
	ckey_to_cooldown = list()
	if(var_value == DEADCHAT_DEMOCRACY_MODE)
		timerid = addtimer(CALLBACK(src, PROC_REF(democracy_loop)), input_cooldown, TIMER_STOPPABLE | TIMER_LOOP)
	else
		deltimer(timerid)

/datum/component/deadchat_control/proc/orbit_begin(atom/source, atom/orbiter)
	SIGNAL_HANDLER  // COMSIG_ATOM_ORBIT_BEGIN

	var/atom/atom_parent = parent

	if(isobserver(orbiter))
		var/mob/dead/observer/O = orbiter
		if(O.client && !(O.client.prefs.toggles & PREFTOGGLE_CHAT_DEAD))
			to_chat(O, span_deadsay("У вас отключён дедчат, и поэтому вы не будете получать сообщения, связанные с этим объектом, и не сможете управлять им."))
			to_chat(O, span_notice("Если вы хотите принять участие, включите дедчат и снова прыгните на этот объект."))
			return
		else
			to_chat(O, span_deadsay("[capitalize(atom_parent.declent_ru(NOMINATIVE))] контролируется призраками через чат! Осмотрите [atom_parent.declent_ru(ACCUSATIVE)] чтобы увидеть команды управления, которые вы можете использовать пока летаете вокруг [genderize_ru(atom_parent.gender, "него", "неё", "него", "них")]!"))

	RegisterSignal(orbiter, COMSIG_MOB_DEADSAY, PROC_REF(deadchat_react))
	RegisterSignal(orbiter, COMSIG_MOB_AUTOMUTE_CHECK, PROC_REF(waive_automute))
	orbiters |= orbiter


/datum/component/deadchat_control/proc/orbit_stop(atom/source, atom/orbiter)
	SIGNAL_HANDLER  // COMSIG_ATOM_ORBIT_STOP

	if(orbiter in orbiters)
		UnregisterSignal(orbiter, list(
			COMSIG_MOB_DEADSAY,
			COMSIG_MOB_AUTOMUTE_CHECK,
		))
		orbiters -= orbiter

/**
 * Prevents messages used to control the parent from counting towards the automute threshold for repeated identical messages.
 *
 * Arguments:
 * - [speaker][/client]: The mob that is trying to speak.
 * - [client][/client]: The client that is trying to speak.
 * - message: The message that the speaker is trying to say.
 * - mute_type: Which type of mute the message counts towards.
 */
/datum/component/deadchat_control/proc/waive_automute(mob/speaker, client/client, message, mute_type)
	SIGNAL_HANDLER  // COMSIG_MOB_AUTOMUTE_CHECK
	if(mute_type == MUTE_DEADCHAT && inputs[lowertext(message)])
		return WAIVE_AUTOMUTE_CHECK
	return NONE


/// Informs any examiners to the inputs available as part of deadchat control, as well as the current operating mode and cooldowns.
/datum/component/deadchat_control/proc/on_examine(atom/object, mob/user, list/examine_list)
	SIGNAL_HANDLER  // COMSIG_PARENT_EXAMINE

	if(!isobserver(user))
		return

	examine_list += span_notice("[genderize_ru(object.gender, "Он", "Она", "Оно", "Они")] контролируется призраками через чат по [(deadchat_mode & DEADCHAT_DEMOCRACY_MODE) ? "демократическому" : "анархическому"] набору правил!")

	if(user.client && !(user.client.prefs.toggles & PREFTOGGLE_CHAT_DEAD))
		examine_list += span_deadsay("Поскольку у вас отключён дедчат, вы не увидите сообщения о голосовании и не сможете участвовать в нем.")
		return

	if(!(user in orbiters))
		examine_list += "<span class='deadsay bold'>Прыгнете на [genderize_ru(object.gender, "него", "неё", "него", "них")]] и осмотрите снова, чтобы увидеть список доступных команд.</span>"
		return

	var/input_cooldown_s = input_cooldown * 0.1

	if(deadchat_mode & DEADCHAT_DEMOCRACY_MODE)
		examine_list += span_notice("Введите команду в чат, чтобы проголосовать за действие. Это происходит один раз в [input_cooldown_s] секунд[declension_ru(input_cooldown_s,"у", "ы", "")].")
	else if(deadchat_mode & DEADCHAT_ANARCHY_MODE)
		examine_list += span_notice("Введите команду в чат для выполнения действия. Вы можете делать это один раз в [input_cooldown_s] секунд[declension_ru(input_cooldown_s,"у", "ы", "")].")

	var/extended_examine = "Список команд:"

	extended_examine += english_list(inputs)

	extended_examine += "."

	examine_list += span_notice(extended_examine)

/// Removes the ghost from the ckey_to_cooldown list and lets them know they are free to submit a command for the parent again.
/datum/component/deadchat_control/proc/end_cooldown(ghost_ckey)
	ckey_to_cooldown -= ghost_ckey
	var/mob/ghost = get_mob_by_ckey(ghost_ckey)
	if(!ghost || isliving(ghost))
		return
	var/atom/atom_parent = parent
	to_chat(ghost, span_green("Вы можете снова ввести команду для управления [atom_parent.declent_ru(INSTRUMENTAL)] ([ghost_follow_link(parent, ghost)])."))

/// Dummy to call since we can't proc reference builtins
/datum/component/deadchat_control/proc/_step(ref, dir)
	step(ref, dir)

/**
 * Deadchat Moves Things
 *
 * A special variant of the deadchat_control component that comes pre-baked with all the hottest inputs for a spicy
 * singularity or vomit goose.
 */
/datum/component/deadchat_control/cardinal_movement/Initialize(_deadchat_mode, _inputs, _input_cooldown, _on_removal)
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE

	_inputs["вверх"] = CALLBACK(src, PROC_REF(_step), parent, NORTH)
	_inputs["вниз"] = CALLBACK(src, PROC_REF(_step), parent, SOUTH)
	_inputs["влево"] = CALLBACK(src, PROC_REF(_step), parent, WEST)
	_inputs["вправо"] = CALLBACK(src, PROC_REF(_step), parent, EAST)

	return ..()

/**
 * Deadchat Moves Things
 *
 * A special variant of the deadchat_control component that comes pre-baked with all the hottest inputs for spicy
 * immovable rod.
 */
/datum/component/deadchat_control/immovable_rod/Initialize(_deadchat_mode, _inputs, _input_cooldown, _on_removal)
	if(!istype(parent, /obj/effect/immovablerod))
		return COMPONENT_INCOMPATIBLE

	_inputs["вверх"] = CALLBACK(parent, TYPE_PROC_REF(/obj/effect/immovablerod, walk_in_direction), NORTH)
	_inputs["вниз"] = CALLBACK(parent, TYPE_PROC_REF(/obj/effect/immovablerod, walk_in_direction), SOUTH)
	_inputs["влево"] = CALLBACK(parent, TYPE_PROC_REF(/obj/effect/immovablerod, walk_in_direction), WEST)
	_inputs["вправо"] = CALLBACK(parent, TYPE_PROC_REF(/obj/effect/immovablerod, walk_in_direction), EAST)

	return ..()


/**
 * Deadchat Moves Things
 *
 * A special variant of the deadchat_control component that comes pre-baked with basic inputs for moving humans around,
 * with special behavior that has them resist while moving.
 */
/datum/component/deadchat_control/human/Initialize(_deadchat_mode, _inputs, _input_cooldown, _on_removal)
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE
	_inputs["вверх"] = CALLBACK(parent, TYPE_PROC_REF(/mob/living/carbon/human/, dchat_step), NORTH)
	_inputs["вниз"] = CALLBACK(parent, TYPE_PROC_REF(/mob/living/carbon/human/, dchat_step), SOUTH)
	_inputs["влево"] = CALLBACK(parent, TYPE_PROC_REF(/mob/living/carbon/human/, dchat_step), WEST)
	_inputs["вправо"] = CALLBACK(parent, TYPE_PROC_REF(/mob/living/carbon/human/, dchat_step), EAST)
	return ..()
