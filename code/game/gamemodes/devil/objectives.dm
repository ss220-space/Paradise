/datum/objective/devil

/datum/objective/devil/sacrifice
	needs_target = TRUE
	antag_menu_name = "Завладеть душой"
	check_cryo = TRUE
	explanation_text = "Ошибка. Цель не сгенерирована"

/datum/objective/devil/sacrifice/proc/forge()
	if(!target)
		return FALSE

	explanation_text = "Принесите в жертву [target.name], [target.assigned_role].\n<br>"

	return TRUE

/datum/objective/devil/sacrifice/is_invalid_target(datum/mind/possible_target)
	. = ..()
	if(.)
		return .
	var/datum/antagonist/devil/devil = owner.has_antag_datum(/datum/antagonist/devil)
	if(LAZYIN(devil.devil_targets, possible_target))
		return TRUE

/datum/objective/devil/sacrifice/proc/is_valid_prof(datum/mind/possible_target)
	return TRUE

/datum/objective/devil/sacrifice/find_target(list/target_blacklist)
	if(!needs_target)
		return

	var/list/prof_targets
	var/list/other_targets
	for(var/datum/mind/possible_target in SSticker.minds)
		if(is_invalid_target(possible_target) || (possible_target in target_blacklist))
			continue

		if(is_valid_prof(possible_target))
			LAZYADD(prof_targets, possible_target)
		else
			LAZYADD(other_targets, possible_target)

	if(!LAZYLEN(prof_targets) && !LAZYLEN(prof_targets))
		return

	target = LAZYLEN(prof_targets)? pick_n_take(prof_targets) : pick_n_take(other_targets)
	RegisterSignal(target, COMSIG_DEVIL_SACRIFICE_CHECK, PROC_REF(on_devil_sacrifice_check))
	RegisterSignal(target, COMSIG_DEVIL_SACRIFICE, PROC_REF(on_devil_sacrifice))
	var/datum/antagonist/devil/devil = owner.has_antag_datum(/datum/antagonist/devil)

	LAZYOR(devil.devil_targets, target)

	forge()

	SEND_SIGNAL(src, COMSIG_OBJECTIVE_TARGET_FOUND, target)

/datum/objective/devil/sacrifice/Destroy(force)
	if(target)
		UnregisterSignal(target, list(COMSIG_DEVIL_SACRIFICE_CHECK, COMSIG_DEVIL_SACRIFICE))
	. = ..()

/datum/objective/devil/sacrifice/proc/on_devil_sacrifice_check()
	SIGNAL_HANDLER
	return COMPONENT_SACRIFICE_VALID


/datum/objective/devil/sacrifice/proc/on_devil_sacrifice()
	SIGNAL_HANDLER
	completed = TRUE
	return

/datum/objective/devil/sacrifice/other

/datum/objective/devil/sacrifice/command/is_valid_prof(datum/mind/possible_target)
	return LAZYIN(GLOB.command_positions, possible_target.assigned_role)

/datum/objective/devil/sacrifice/security/is_valid_prof(datum/mind/possible_target)
	return LAZYIN(GLOB.security_positions, possible_target.assigned_role)

/datum/objective/devil/sintouch
	needs_target = FALSE
	explanation_text = "Вы не должны видеть этот текст. Error: DEVIL3"
	antag_menu_name = "Осквернить души"

/datum/objective/devil/sintouch/New()
	target_amount = pick(4, 5)
	explanation_text = "Убедитесь, что хотя бы [target_amount] смертных было осквернено грехом."

/datum/objective/devil/sintouch/check_completion()
	return target_amount <= SSticker.mode.sintouched.len

/datum/objective/devil/ascend
	explanation_text = "Возвыситься до Архидьявола. Для ритуала возвышения вам понадобится 2 жертвы из списка."
	needs_target = FALSE
	antag_menu_name = "Возвыситься"

/datum/objective/devil/ascend/check_completion()
	return  isascendeddevil(owner)

/datum/objective/imp
	explanation_text = "Постарайтесь получить повышение до следующего адского ранга."
	needs_target = FALSE
	antag_menu_name = "Получить повышение"
